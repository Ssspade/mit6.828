/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <inc/mmu.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>
#include <inc/elf.h>

#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/monitor.h>

struct Env *envs = NULL;		// envs指针指向代表系统中所有环境的Env结构数组。
struct Env *curenv = NULL;		// The current env
//内核使用curenv符号在任何给定时间跟踪当前正在执行的环境。在启动过程中，在运行第一个环境之前，curenv最初设置为NULL。
static struct Env *env_free_list;	// Free environment list
//不活动的Env结构保留在env_free_list上。这种设计可以轻松分配和释放环境，因为只需将其添加到空闲列表中或从中删除。
					// (linked by Env->env_link)

#define ENVGENSHIFT	12		// >= LOGNENV

// Global descriptor table.
//
// Set up global descriptor table (GDT) with separate segments for
// kernel mode and user mode.  Segments serve many purposes on the x86.
// We don't use any of their memory-mapping capabilities, but we need
// them to switch privilege levels. 
//
// The kernel and user segments are identical except for the DPL.
// To load the SS register, the CPL must equal the DPL.  Thus,
// we must duplicate the segments for the user and the kernel.
//
// In particular, the last argument to the SEG macro used in the
// definition of gdt specifies the Descriptor Privilege Level (DPL)
// of that descriptor: 0 for kernel and 3 for user.
//
struct Segdesc gdt[] =
{
	// 0x0 - unused (always faults -- for trapping NULL far pointers)
	SEG_NULL,

	// 0x8 - kernel code segment
	[GD_KT >> 3] = SEG(STA_X | STA_R, 0x0, 0xffffffff, 0),

	// 0x10 - kernel data segment
	[GD_KD >> 3] = SEG(STA_W, 0x0, 0xffffffff, 0),

	// 0x18 - user code segment
	[GD_UT >> 3] = SEG(STA_X | STA_R, 0x0, 0xffffffff, 3),

	// 0x20 - user data segment
	[GD_UD >> 3] = SEG(STA_W, 0x0, 0xffffffff, 3),

	// 0x28 - tss, initialized in trap_init_percpu()
	[GD_TSS0 >> 3] = SEG_NULL
};

struct Pseudodesc gdt_pd = {
	sizeof(gdt) - 1, (unsigned long) gdt
};

//
// Converts an envid to an env pointer.
// If checkperm is set, the specified environment must be either the
// current environment or an immediate child of the current environment.
//将一个envid转换为一个env指针。
// RETURNS
//   0 on success, -E_BAD_ENV on error.
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
		*env_store = curenv;
		return 0;
	}

	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
	if (e->env_status == ENV_FREE || e->env_id != envid) {
		*env_store = 0;
		return -E_BAD_ENV;
	}

	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	//检查调用环境是否具有操作指定环境的合法权限。
	//如果设置了checkperm，则指定环境必须是当前环境或当前环境的直接子级。
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
		*env_store = 0;
		return -E_BAD_ENV;
	}

	*env_store = e;
	return 0;
}

// Mark all environments in 'envs' as free, set their env_ids to 0,
// and insert them into the env_free_list.
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
// envs数组中的所有Env结构，并将它们添加到env_free_list。
// 还调用env_init_percpu，它将为特权级别0（内核）和特权级别3（用户）的分段硬件配置分段硬件。
void
env_init(void)
{
	// Set up envs array i的类型都会导致错误,hhhhh
	int i;
	//env_free_list = NULL;
	for(i=NENV-1; i>=0; i--){
      		envs[i].env_id = 0;
        	envs[i].env_status = ENV_FREE;
        	envs[i].env_link = env_free_list;
        	env_free_list = &envs[i];
    	}
	// Per-CPU part of the initialization
	env_init_percpu();

}

// Load GDT and segment descriptors.
// 加载GDT和段描述符
void
env_init_percpu(void)
{
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}

// 为新环境分配页面目录，并初始化新环境的地址空间的内核部分。
// Initialize the kernel virtual memory layout for environment e.
// Allocate a page directory, set e->env_pgdir accordingly,
// and initialize the kernel portion of the new environment's address space.
// Do NOT (yet) map anything into the user portion
// of the environment's virtual address space.
//
// Returns 0 on success, < 0 on error.  Errors include:
//	-E_NO_MEM if page directory or table could not be allocated.
//
static int
env_setup_vm(struct Env *e)
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;

	// Now, set e->env_pgdir and initialize the page directory.
	//
	// Hint:
	//    - The VA space of all envs is identical above UTOP
	//	(except at UVPT, which we've set below).
	//	所有环境的VA空间在UTOP之上是相同的
	//	See inc/memlayout.h for permissions and layout.
	//	Can you use kern_pgdir as a template?  Hint: Yes.
	//	(Make sure you got the permissions right in Lab 2.)
	//    - The initial VA below UTOP is empty.
	//    - You do not need to make any more calls to page_alloc.
	//    - Note: In general, pp_ref is not maintained for
	//	physical pages mapped only above UTOP, but env_pgdir
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.
	p->pp_ref ++;
	pde_t* page_dir = page2kva(p);
	//把内核部分再加上pages与envs的内容(即UTOP以上)原封不动的从kern_pgdir中复制到env_pgdir中就初始化内核部分
	memcpy(page_dir, kern_pgdir, PGSIZE);
	e->env_pgdir = page_dir;

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;

	return 0;
}

//
// Allocates and initializes a new environment.
// On success, the new environment is stored in *newenv_store.
// 
// Returns 0 on success, < 0 on failure.  Errors include:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;

	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.生成此环境的环境id。
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
	if (generation <= 0)	// Don't create a negative env_id.
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);

	// Set the basic status variables.
	e->env_parent_id = parent_id;
	e->env_type = ENV_TYPE_USER;
	e->env_status = ENV_RUNNABLE;
	e->env_runs = 0;

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));

	// Set up appropriate initial values for the segment registers.
	//为段寄存器设置适当的初始值。
	// GD_UD is the user data segment selector in the GDT, and
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
	e->env_tf.tf_es = GD_UD | 3;
	e->env_tf.tf_ss = GD_UD | 3;
	e->env_tf.tf_esp = USTACKTOP;
	e->env_tf.tf_cs = GD_UT | 3;
	// You will set e->env_tf.tf_eip later.
	//e->env_tf.tf_eip = 
	// commit the allocation
	env_free_list = e->env_link;
	*newenv_store = e;
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}

//
// Allocate len bytes of physical memory for environment env,
// and map it at virtual address va in the environment's address space.
// Does not zero or otherwise initialize the mapped pages in any way.
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
// 为环境分配和映射物理内存
static void
region_alloc(struct Env *e, void *va, size_t len)
{
	// LAB 3: Your code here.
	// (But only if you need it for load_icode.)
	struct PageInfo *p=NULL;
	void *i;
	//添加（void*）
	void *begin = (void *)ROUNDDOWN(va,PGSIZE);
	void *end = (void *)ROUNDUP(va+len, PGSIZE);//对齐
	for(i=begin;i<end; i+=PGSIZE){
		p = page_alloc(0);
		if(!p)
			panic("env region fail");
		if(page_insert(e->env_pgdir,p,i,PTE_W|PTE_U)!=0)
			panic("fail to region_alloc");
	}
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}

// 需要解析一个ELF二进制映像，就像引导加载程序已经做的那样，并将其内容加载到新环境的用户地址空间中。
// Set up the initial program binary, stack, and processor flags
// for a user process.
// 初始化进程的栈、处理器标志
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
// 在运行第一个用户环境之前，此函数仅在内核初始化期间调用
// This function loads all loadable segments from the ELF binary image
// into the environment's user memory, starting at the appropriate
// virtual addresses indicated in the ELF program header.
// 将ELF镜像加载到用户内存中，从ELF程序头中指示的适当虚拟地址开始。
// At the same time it clears to zero any portions of these segments
// that are marked in the program header as being mapped
// 同时，将这些段的任何部分清零（在程序头中标记为已映射）
// but not actually present in the ELF file - i.e., the program's bss section.
// 但实际上并未出现在ELF文件中-即程序的bss部分。
// All this is very similar to what our boot loader does, except the boot
// loader also needs to read the code from disk.  Take a look at
// boot/main.c to get ideas.
//
// Finally, this function maps one page for the program's initial stack.
//
// load_icode panics if it encounters problems.
//  - How might load_icode fail?  What might be wrong with the given input?
//
static void
load_icode(struct Env *e, uint8_t *binary)
{
	// Hints:
	//  Load each program segment into virtual memory
	//  at the address specified in the ELF segment header.
	//  You should only load segments with ph->p_type == ELF_PROG_LOAD.
	//  您只应加载ph-> p_type == ELF_PROG_LOAD的段。
	//  Each segment's virtual address can be found in ph->p_va
	//  每个段的虚拟地址可以通过ph->p_va找到
	//  and its size in memory can be found in ph->p_memsz.
	
	//  'binary+ph->p_offset'应该被复制到虚拟空间中
	//  ph->p_va.  Any remaining memory bytes should be cleared to zero.
	
	//  (The ELF header should have ph->p_filesz <= ph->p_memsz.)
	//  Use functions from the previous lab to allocate and map pages.
	//
	//  All page protection bits should be user read/write for now.
	//  ELF segments are not necessarily page-aligned, but you can
	//  assume for this function that no two segments will touch
	//  the same virtual page.
	//
	//  You may find a function like region_alloc useful.
	//
	//  Loading the segments is much simpler if you can move data
	//  directly into the virtual addresses stored in the ELF binary.
	//  So which page directory should be in force during
	//  this function?
	//  如果可以将数据直接移动到ELF二进制文件中存储的虚拟地址中，则加载段要简单得多。

	//  You must also do something with the program's entry point,
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	struct Elf *Elf_head = (struct Elf *)binary;
	if(Elf_head->e_magic != ELF_MAGIC)
		panic("The binary is not a ELF magic!\n");
	if(Elf_head->e_entry == 0)
		panic("The program can't be executed because the entry point is invalid!\n");
	

	//load this user pgdir
	lcr3(PADDR(e->env_pgdir));
	e->env_tf.tf_eip = Elf_head->e_entry;//更改eip
	//加载程序段
	struct Proghdr *ph  = (struct Proghdr *)((uint8_t *)Elf_head + Elf_head->e_phoff);
	struct Proghdr *eph;
	eph = ph + Elf_head->e_phnum;
	for(;ph < eph; ph++){
		//只应加载ph-> p_type == ELF_PROG_LOAD的段。
		if(ph->p_type == ELF_PROG_LOAD){
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
			//  ph-> p_va。任何剩余的内存字节应清零。
			//  出现<memset+73>:	rep stos %eax,%es:(%edi)错误
			//  此处不同
			memset((void *)ph->p_va, 0, ph->p_memsz);
			//  大小：ph->p_memsz
			//  The ph->p_filesz bytes from the ELF binary, starting at
			//  'binary + ph->p_offset', should be copied to virtual address
			memcpy((void *)ph->p_va, (void *)(binary+ph->p_offset), ph->p_filesz);
		}
	}
	//改为不加载
	lcr3(PADDR(kern_pgdir));
	//cprintf("new_env: %08x\n",e->env_pgdir);
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
	//cprintf("new_env: %08x\n",e->env_pgdir);
}

//分配一个新的进程，加载elf，设置他的env_type
// Allocates a new env with env_alloc, loads the named elf
// binary into it with load_icode, and sets its env_type.
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
	struct Env *new_env;
	if(env_alloc(&new_env,0)!=0)
		panic("env_creat failed:env_alloc faild.\n");
	load_icode(new_env, binary);
	new_env->env_type = type;
	//cprintf("new_env: %08x\n",new_env->env_pgdir);
	
}

//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
	pte_t *pt;
	uint32_t pdeno, pteno;
	physaddr_t pa;

	// 如果释放当前环境，则在释放页面目录之前切换到kern_pgdir
	// 以防万一页面被重用。
	if (e == curenv)
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	// 注意环境的消亡。
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	// 刷新地址空间用户部分中的所有映射页面
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
	e->env_pgdir = 0;
	page_decref(pa2page(pa));

	// return the environment to the free list
	e->env_status = ENV_FREE;
	e->env_link = env_free_list;
	env_free_list = e;
}

//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
	env_free(e);

	cprintf("Destroyed the only environment - nothing more to do!\n");
	while (1)
		monitor(NULL);
}


//
// Restores the register values in the Trapframe with the 'iret' instruction.
// This exits the kernel and starts executing some environment's code.
// 使用“ iret”指令在Trapframe中恢复寄存器值
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
	asm volatile(
		"\tmovl %0,%%esp\n"
		"\tpopal\n"
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
}

//
// Context switch from curenv to env e.
// Note: if this is the first call to env_run, curenv is NULL.
//
// This function does not return.
//
void
env_run(struct Env *e)
{
	// Step 1: If this is a context switch (a new environment is running):
	//	   1. Set the current environment (if any) back to
	//	      ENV_RUNNABLE if it is ENV_RUNNING (think about
	//	      what other states it can be in),
	//	   2. Set 'curenv' to the new environment,
	//	   3. Set its status to ENV_RUNNING,
	//	   4. Update its 'env_runs' counter,
	//	   5. Use lcr3() to switch to its address space.
	// Step 2: Use env_pop_tf() to restore the environment's
	//	   registers and drop into user mode in the
	//	   environment.

	// Hint: This function loads the new environment's state from
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv && curenv->env_status == ENV_RUNNING){
		curenv->env_status = ENV_RUNNABLE;
	}
	//cprintf("new_env: %08x\n",e->env_pgdir);
	curenv = e;
	curenv->env_status = ENV_RUNNING;
	curenv->env_runs ++;
	//if((uint32_t)curenv->env_pgdir < KERNBASE)
		//panic("PADDR called with invalid kva %08lx",curenv->env_pgdir);
	
	lcr3(PADDR(curenv->env_pgdir));
	//cprintf("new_env: %08x\n",curenv->env_tf);
	env_pop_tf(&curenv->env_tf);
	//panic("env_run not yet implemented");
}

