/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <inc/mmu.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>

#include <kern/pmap.h>
#include <kern/kclock.h>
#include <kern/env.h>
#include <kern/cpu.h>

// These variables are set by i386_detect_memory()
size_t npages;			// Amount of physical memory (in pages)以页为单位的物理内存量
static size_t npages_basemem;	// Amount of base memory (in pages)基础内存 

// These variables are set in mem_init()
pde_t *kern_pgdir;		// Kernel's initial page directory内核的初始化页面目录
struct PageInfo *pages;		// Physical page state array物理页面状态数组
static struct PageInfo *page_free_list;	// Free list of physical pages空闲的物理页面表


// --------------------------------------------------------------
// Detect machine's physical memory setup.检测机器的物理内存设置
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
}

static void
i386_detect_memory(void)
{
	size_t basemem, extmem, ext16mem, totalmem;

	//使用CMOS调用来测量可用的基本和扩展内存
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
	extmem = nvram_read(NVRAM_EXTLO);
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;

	// 计算可用的物理内存
	if (ext16mem)
		totalmem = 16 * 1024 + ext16mem;
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);//一共有多少个页表项
	npages_basemem = basemem / (PGSIZE / 1024);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		totalmem, basemem, totalmem - basemem);
}


// --------------------------------------------------------------
// Set up memory mappings above UTOP.
// --------------------------------------------------------------

static void mem_init_mp(void);
static void boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm);
static void check_page_free_list(bool only_low_memory);
static void check_page_alloc(void);
static void check_kern_pgdir(void);
static physaddr_t check_va2pa(pde_t *pgdir, uintptr_t va);
static void check_page(void);
static void check_page_installed_pgdir(void);

// 真正分配器
// 如果n大于0，分配足够的连续物理内存，不初始化内存，返回内核虚拟地址
// n=0，返回下一个页面的空闲地址，不分配
// 此函数用于初始化
static void *
boot_alloc(uint32_t n)
{
	static char *nextfree;	// 下一个可用内存字节的虚拟地址
	char *result;

	if (!nextfree) {
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
	}

	if(n==0){
		result = nextfree;
	}
	result = nextfree;
	nextfree += ROUNDUP(n, PGSIZE);
	return result;
}

// Set up a two-level page table:
//    kern_pgdir is its linear (virtual) address of the root
void
mem_init(void)
{
	uint32_t cr0;
	size_t n;

	i386_detect_memory();
	//////////////////////////////////////////////////////////////////////
	// 初始化目录项
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
	memset(kern_pgdir, 0, PGSIZE);

	//////////////////////////////////////////////////////////////////////
	//以递归方式将PD本身作为页表插入，以在虚拟地址UVPT处形成一个虚拟页表。
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;

	//////////////////////////////////////////////////////////////////////
	// 给pageinfo分配地址空间
	pages = (struct PageInfo *)boot_alloc(npages*sizeof(struct PageInfo));
	memset(pages, 0, npages*sizeof(struct PageInfo));
	//////////////////////////////////////////////////////////////////////
	// 给进程结构分配地址空间
	envs = (struct Env *)boot_alloc(NENV*sizeof(struct Env));
	memset(envs, 0, NENV*sizeof(struct Env));
	page_init();
	//检测函数
	check_page_free_list(1);
	check_page_alloc();
	check_page();

	//////////////////////////////////////////////////////////////////////
	// 把page映射到虚拟空间UPAGES与UVPT中
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U|PTE_P);
	//////////////////////////////////////////////////////////////////////
	// 把env结构映射到UENVS与UPAGES中
	boot_map_region(kern_pgdir, UENVS, PTSIZE,PADDR(envs),PTE_U);
	//////////////////////////////////////////////////////////////////////
	// 把物理地址的booystack映射到虚拟空间KSTACKTOP
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
	//////////////////////////////////////////////////////////////////////
	// 映射所有的物理地址到KERBASE之上
	boot_map_region(kern_pgdir, KERNBASE, 0x100000000-KERNBASE,0, PTE_W|PTE_P);

	// 初始化多处理器的映射
	mem_init_mp();	

	// 检测映射
	check_kern_pgdir();

	// 切换到kern_pgdir
	lcr3(PADDR(kern_pgdir));

	check_page_free_list(0);

	
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// 检测函数
	check_page_installed_pgdir();
}

// 多处理器内核栈的映射
static void
mem_init_mp(void)
{
	int i;
	for (i = 0; i < NCPU; i++) {
		int kstacktop_i = KSTACKTOP - KSTKSIZE - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, kstacktop_i, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
	}
}

void
page_init(void)
{
	//  此处的示例代码将所有物理页面标记为空闲。
	//  可以保留实模式IDT和BIOS结构，以备需要时使用。
	//  剩余的基本内存是空闲的
	//  有个IO不能分配
	//其中一些正在使用中，有些是免费的。物理内存中的内核在哪里？页面表和其他数据结构已经使用了哪些页面？

	size_t i;
	
	char *nextfree = boot_alloc(0);
	size_t kern_end = PGNUM(PADDR(nextfree));
	for(i=0; i<npages; i++){
		if(i==0){
			pages[i].pp_ref = 1;
		}else if(i*PGSIZE>=IOPHYSMEM && i*PGSIZE<=EXTPHYSMEM){
			pages[i].pp_ref = 1;
		}else if(i*PGSIZE>=EXTPHYSMEM && i<=kern_end){
			pages[i].pp_ref = 1;
		}else if(i*PGSIZE==MPENTRY_PADDR){
			pages[i].pp_ref = 1;
		}else{
			pages[i].pp_ref = 0;
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}
		
	}
}

//
// 分配一个空闲物理页（Info）
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in
	struct PageInfo *alloc_page = page_free_list;
	if(alloc_page==NULL){
		return NULL;
	}
	if(alloc_flags & ALLOC_ZERO){
		memset(page2kva(alloc_page), 0,PGSIZE );
	}
	
	page_free_list =alloc_page->pp_link;
	alloc_page->pp_link = NULL;
	return alloc_page;
}

//
// 释放PP
//
void
page_free(struct PageInfo *pp)
{
	if(pp->pp_ref!=0 || pp->pp_link!=NULL){
		panic("check alloc page");
		return;
	}
	pp->pp_link = page_free_list;
	page_free_list = pp;
}

//
// 释放物理页
//
void
page_decref(struct PageInfo* pp)
{
	if (--pp->pp_ref == 0)
		page_free(pp);
}

// 返回页表项指针
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	uint32_t pdx = PDX(va);   // 页目录项索引
	uint32_t ptx = PTX(va);   // 页表项索引
	pte_t   *pde;             // 页目录项指针
	pte_t   *pte;             // 页表项指针
	struct PageInfo *pp;
	pde = &pgdir[pdx];        //获取页目录项找到页表
	
	if (!(*pde & PTE_P)){
		// 二级页表不存在，
		if (!create) {
			return NULL;
		}
		// 获取一页的内存，创建一个新的页表，来存放页表项
		if(!(pp = page_alloc(ALLOC_ZERO))) {  
            		return NULL;
        }
		pte = (pte_t *)page2kva(pp);//页表项指向新建的页表
		pp->pp_ref++; 
		*pde = page2pa(pp)|PTE_P|PTE_W|PTE_U;//更新页目录项内容
	}else {
		// 二级页表有效
		// PTE_ADDR得到物理地址，KADDR转为虚拟地址
		pte = (KADDR(PTE_ADDR(*pde)));
	}
	 // 返回页表项的虚拟地址
	return &pte[ptx];                              
}


// 把虚拟地址 [va, va+size)映射到物理地址[pa, pa+size)
// 找到虚拟地址对应的页面，将物理地址写入页表
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	size_t i=0;
	for(i=0; i*PGSIZE< size; i++){
		pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
		*pte = pa|perm|PTE_P;
		va+=PGSIZE;
		pa+=PGSIZE;
	}
}

//
// 把虚拟地址的情况映射到物理页面信息pp中。
//  已经有一个页映射到va，就删除
// 若需要，页表被分配并插入到页表项中
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	
	pte_t *pte = pgdir_walk(pgdir, va,1);
	if(!pte)
		return -E_NO_MEM;
	//若va对应的页面存在
	pp->pp_ref++;
	if(*pte & PTE_P){
		page_remove(pgdir, va);
	}
	//not 
	*pte = page2pa(pp)|perm|PTE_P;
	return 0;
}


//查找虚拟地址va对应的页表项，返回页表项内保存的物理页在PageInfo结构体中的索引值
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t *pte = pgdir_walk(pgdir, va, 0);
	if(!pte||!(*pte & PTE_P))
		return NULL;
	if(pte_store != 0)
		*pte_store = pte;//why,used by remove
	
	return pa2page(PTE_ADDR(*pte));
}

// 移除物理页
//  the page table.TLB 翻译缓存 必须变为不可用状态如果移除了页表入口
void
page_remove(pde_t *pgdir, void *va)
{
	
	pte_t *pte;
	struct PageInfo *pp = page_lookup(pgdir, va, &pte);//find infopage
	if(pp){
		page_decref(pp);
		*pte = 0;
		tlb_invalidate(pgdir, va);
	}
}

//
// 使TLB项无效，但前提是正在编辑的页表是处理器当前使用的页表。
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
	//刷新
	if (!curenv || curenv->env_pgdir == pgdir)
		invlpg(va);
}


// 在MMIO区域中保留大小字节，并在此位置映射[pa，pa+size]。返回保留区域的基。大小*不*必须是PGSIZE的倍数。


void *
mmio_map_region(physaddr_t pa, size_t size)
{
	static uintptr_t base = MMIOBASE;
	size_t start = ROUNDDOWN(pa, PGSIZE);
	size_t end = ROUNDUP(pa+size, PGSIZE);
	size_t map_size = end-start;
	if(base + map_size >= MMIOLIM){
		panic("overflow MMIOLIM");
	}
	boot_map_region(kern_pgdir, base, map_size, pa, PTE_PCD|PTE_PWT|PTE_W);
	uintptr_t result = base;
	base = base+map_size;
	return (void *)result;
}

static uintptr_t user_mem_check_addr;

// 检测用户空间内存地址
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	pte_t *pte;
	uint32_t start = (uint32_t)ROUNDDOWN(va, PGSIZE);
	uint32_t end = (uint32_t)ROUNDUP(va+len, PGSIZE);
	uint32_t i = 0;
	for(i=start; i<end;i+=PGSIZE){
		pte = pgdir_walk(env->env_pgdir, (void *)i, 0);
		if((i>=ULIM)||!pte||!(*pte&PTE_P)||(*pte&perm)!=perm){
			user_mem_check_addr = (i >= (uint32_t)va ? i : (uint32_t)va);
			return -E_FAULT;
		}
	}
	return 0;
}

//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
		cprintf("[%08x] user_mem_check assertion failure for "
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
	}
}

//------------
void
pte_print(pte_t *pte)
{
    char perm_w = (*pte & PTE_W) ? 'W' : '-';
    char perm_u = (*pte & PTE_U) ? 'U' : '-';
    cprintf("perm: P%c%c\n", perm_w, perm_u);
}
// --------------------------------------------------------------
// 检测函数
// --------------------------------------------------------------

//
// 检查page_free_list中的页面是否合理。
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
		*tp[0] = pp2;
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
		assert(pp < pages + npages);
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}

//
// Check the physical page allocator (page_alloc(), page_free(),
// and page_init()).
//
static void
check_page_alloc(void)
{
	struct PageInfo *pp, *pp0, *pp1, *pp2;
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
	assert((pp1 = page_alloc(0)));
	assert((pp2 = page_alloc(0)));

	assert(pp0);
	assert(pp1 && pp1 != pp0);
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
	assert(page2pa(pp0) < npages*PGSIZE);
	assert(page2pa(pp1) < npages*PGSIZE);
	assert(page2pa(pp2) < npages*PGSIZE);

	// temporarily steal the rest of the free pages
	fl = page_free_list;
	page_free_list = 0;

	// should be no free memory
	assert(!page_alloc(0));

	// free and re-allocate?
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
	assert((pp1 = page_alloc(0)));
	assert((pp2 = page_alloc(0)));
	assert(pp0);
	assert(pp1 && pp1 != pp0);
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
	assert(!page_alloc(0));

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;

	// free the pages we took
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
		--nfree;
	assert(nfree == 0);

	cprintf("check_page_alloc() succeeded!\n");
}

//
// Checks that the kernel part of virtual address space
// has been set up roughly correctly (by mem_init()).
//
// This function doesn't test every corner case,
// but it is a pretty good sanity check.
//

static void
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
				assert(pgdir[i] & PTE_P);
				assert(pgdir[i] & PTE_W);
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
}

// This function returns the physical address of the page containing 'va',
// defined by the page directory 'pgdir'.  The hardware normally performs
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}


// check page_insert, page_remove, &c
static void
check_page(void)
{
	struct PageInfo *pp, *pp0, *pp1, *pp2;
	struct PageInfo *fl;
	pte_t *ptep, *ptep1;
	void *va;
	uintptr_t mm1, mm2;
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
	assert((pp1 = page_alloc(0)));
	assert((pp2 = page_alloc(0)));

	assert(pp0);
	assert(pp1 && pp1 != pp0);
	assert(pp2 && pp2 != pp1 && pp2 != pp0);

	// temporarily steal the rest of the free pages
	fl = page_free_list;
	page_free_list = 0;

	// should be no free memory
	assert(!page_alloc(0));

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
	assert(pp1->pp_ref == 1);
	assert(pp0->pp_ref == 1);

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
	assert(pp2->pp_ref == 1);

	// should be no free memory
	assert(!page_alloc(0));

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
	assert(pp2->pp_ref == 1);

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
	assert(pp2->pp_ref == 1);
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
	assert(kern_pgdir[0] & PTE_U);

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
	assert(pp2->pp_ref == 0);

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
	assert(pp1->pp_ref == 1);
	assert(pp2->pp_ref == 0);

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
	assert(pp1->pp_ref);
	assert(pp1->pp_link == NULL);

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
	assert(pp1->pp_ref == 0);
	assert(pp2->pp_ref == 0);

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);

	// should be no free memory
	assert(!page_alloc(0));

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
	kern_pgdir[0] = 0;
	assert(pp0->pp_ref == 1);
	pp0->pp_ref = 0;

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
	assert(ptep == ptep1 + PTX(va));
	kern_pgdir[PDX(va)] = 0;
	pp0->pp_ref = 0;

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
	pp0->pp_ref = 0;

	// give free list back
	page_free_list = fl;

	// free the pages we took
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
	assert(check_va2pa(kern_pgdir, mm2) == 0);
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;

	cprintf("check_page() succeeded!\n");
}

// check page_insert, page_remove, &c, with an installed kern_pgdir
static void
check_page_installed_pgdir(void)
{
	struct PageInfo *pp, *pp0, *pp1, *pp2;
	struct PageInfo *fl;
	pte_t *ptep, *ptep1;
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
	assert((pp1 = page_alloc(0)));
	assert((pp2 = page_alloc(0)));
	page_free(pp0);
	memset(page2kva(pp1), 1, PGSIZE);
	memset(page2kva(pp2), 2, PGSIZE);
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
	assert(pp1->pp_ref == 1);
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
	assert(pp2->pp_ref == 1);
	assert(pp1->pp_ref == 0);
	*(uint32_t *)PGSIZE = 0x03030303U;
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
	page_remove(kern_pgdir, (void*) PGSIZE);
	assert(pp2->pp_ref == 0);

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
	kern_pgdir[0] = 0;
	assert(pp0->pp_ref == 1);
	pp0->pp_ref = 0;

	// free the pages we took
	page_free(pp0);

	cprintf("check_page_installed_pgdir() succeeded!\n");
}
