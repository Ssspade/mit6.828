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
#include <kern/sched.h>
#include <kern/cpu.h>
#include <kern/spinlock.h>

struct Env *envs = NULL;		
//内核使用curenv符号在任何给定时间跟踪当前正在执行的环境。在启动过程中，在运行第一个环境之前，curenv最初设置为NULL。
static struct Env *env_free_list;	
//不活动的Env结构保留在env_free_list上。可以轻松分配和释放环境，因为只需将其添加到空闲列表中或从中删除。
					// (linked by Env->env_link)

#define ENVGENSHIFT	12		// >= LOGNENV

// 全局描述符表
// 包含一个段的基址、界限以及属性内容
//
struct Segdesc gdt[NCPU + 5] =
{
	// 0x0 - unused (always faults -- for trapping NULL far pointers)
	SEG_NULL,

	// 0x8 - 内核代码段
	[GD_KT >> 3] = SEG(STA_X | STA_R, 0x0, 0xffffffff, 0),

	// 0x10 - 内核数据段
	[GD_KD >> 3] = SEG(STA_W, 0x0, 0xffffffff, 0),

	// 0x18 - 用户代码段
	[GD_UT >> 3] = SEG(STA_X | STA_R, 0x0, 0xffffffff, 3),

	// 0x20 - 用户数据段
	[GD_UD >> 3] = SEG(STA_W, 0x0, 0xffffffff, 3),

	// tss在trap_init_Per CPU（）中初始化
	[GD_TSS0 >> 3] = SEG_NULL
};

struct Pseudodesc gdt_pd = {
	sizeof(gdt) - 1, (unsigned long) gdt
};

//
// 将id转换为指针
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
	struct Env *e;

	// 为0返回当前进程
	if (envid == 0) {
		*env_store = curenv;
		return 0;
	}

	//通过envid的索引部分查找Env结构
	e = &envs[ENVX(envid)];
	if (e->env_status == ENV_FREE || e->env_id != envid) {
		*env_store = 0;
		return -E_BAD_ENV;
	}

	//检查调用环境是否具有操作指定环境的合法权限。
	//如果设置了checkperm，则指定环境必须是当前环境或当前环境的直接子级。
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
		*env_store = 0;
		return -E_BAD_ENV;
	}

	*env_store = e;
	return 0;
}


// envs数组中的所有Env结构，并将它们添加到env_free_list。
// 还调用env_init_percpu，它将为特权级别0（内核）和特权级别3（用户）的分段硬件配置分段硬件。
void
env_init(void)
{
	// i的类型都会导致错误,hhhhh
	int i;
	//env_free_list = NULL;
	for(i=NENV-1; i>=0; i--){
      		envs[i].env_id = 0;
        	envs[i].env_status = ENV_FREE;
        	envs[i].env_link = env_free_list;
        	env_free_list = &envs[i];
    	}
	// Per-CPU 部分的初始化
	env_init_percpu();

}

// 加载GDT和段描述符
void
env_init_percpu(void)
{
	lgdt(&gdt_pd);
	// 内核从不使用GS或FS，所以我们将这些设置留给用户数据段。
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
	// 内核使用ES、DS和SS。我们将根据需要在内核和用户数据段之间进行更改。
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
	// 将内核文本段加载到CS中
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
	// 清除本地描述符表（LDT），因为我们不使用它。

	lldt(0);
}

// 为进程分配页面目录，并初始化新进程的地址空间的内核部分。
static int
env_setup_vm(struct Env *e)
{
	int i;
	struct PageInfo *p = NULL;

	// 分配一页给页目录
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;

	// 设置进程的pgdir，初始化页目录
	p->pp_ref ++;
	pde_t* page_dir = page2kva(p);
	// 把内核部分再加上pages与envs的内容(即UTOP以上)原封不动的从kern_pgdir中复制到env_pgdir中就初始化内核部分
	memcpy(page_dir, kern_pgdir, PGSIZE);
	e->env_pgdir = page_dir;
	// 权限
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;

	return 0;
}

//
// 分配新进程
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;

	// 设置进程的pgdir，初始化页目录
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// 生成此环境的环境id。
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
	if (generation <= 0)	
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);

	// 初始化状态变量
	e->env_parent_id = parent_id;
	e->env_type = ENV_TYPE_USER;
	e->env_status = ENV_RUNNABLE;
	e->env_runs = 0;

	// 初始化寄存器状态
	memset(&e->env_tf, 0, sizeof(e->env_tf));

	//为段寄存器设置适当的初始值。
	// GD_UD是GDT的用户数据段
	e->env_tf.tf_ds = GD_UD | 3;
	e->env_tf.tf_es = GD_UD | 3;
	e->env_tf.tf_ss = GD_UD | 3;
	e->env_tf.tf_esp = USTACKTOP;
	e->env_tf.tf_cs = GD_UT | 3;
	e->env_tf.tf_eflags |= FL_IF;

	// 清除页面错误处理程序
	e->env_pgfault_upcall = 0;

	// 清除IPC标志
	e->env_ipc_recving = 0;

	env_free_list = e->env_link;
	*newenv_store = e;
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}

//
// 为环境env分配len字节的物理内存，并将其映射到环境地址空间中的虚拟地址va。
static void
region_alloc(struct Env *e, void *va, size_t len)
{
	// load_icode.
	struct PageInfo *p=NULL;
	void *i;
	//添加（void*）
	void *begin = (void *)ROUNDDOWN(va,PGSIZE);
	void *end = (void *)ROUNDUP(va+len, PGSIZE);//对齐
	for(i=begin;i<end; i+=PGSIZE){
		p = page_alloc(0);
		if(!p)
			panic("env region fail");
		if(page_insert(e->env_pgdir,p,i,PTE_W|PTE_U)!=0)//把物理地址放入二级页表中
			panic("fail to region_alloc");
	}
}

// 需要解析一个ELF二进制映像，就像引导加载程序已经做的那样，并将其内容加载到新环境的用户地址空间中。
// 初始化进程的栈、处理器标志
// 在运行第一个用户环境之前，此函数仅在内核初始化期间调用
// 将ELF镜像加载到用户内存中，从ELF程序头中指示的适当虚拟地址开始。
// 同时，将这些段的任何部分清零（在程序头中标记为已映射）
// 但实际上并未出现在ELF文件中-即程序的bss部分。

static void
load_icode(struct Env *e, uint8_t *binary)
{
	// 只应加载ph-> p_type == ELF_PROG_LOAD的段。
	//  每个段的虚拟地址可以通过ph->p_va找到
	
	//  'binary+ph->p_offset'应该被复制到虚拟空间中
	//  ph->p_va.  Any remaining memory bytes should be cleared to zero.
	//  如果可以将数据直接移动到ELF二进制文件中存储的虚拟地址中，则加载段要简单得多。

	struct Elf *Elf_head = (struct Elf *)binary;
	if(Elf_head->e_magic != ELF_MAGIC)
		panic("The binary is not a ELF magic!\n");
	if(Elf_head->e_entry == 0)
		panic("The program can't be executed because the entry point is invalid!\n");
	//load 进程的页表项
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
		
			memcpy((void *)ph->p_va, (void *)(binary+ph->p_offset), ph->p_filesz);
		}
	}
	//改为不加载
	lcr3(PADDR(kern_pgdir));
	// 映射用户栈
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
}

//创建一个新的进程，加载elf，设置他的env_type
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
// 释放进程和内存
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

	// 注意环境的消亡。
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// 刷新地址空间用户部分中的所有映射页面
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// 只看映射的页面
		if (!(e->env_pgdir[pdeno] & PTE_P))
			continue;

		// 找到表的地址
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// 取消映射此页表中的所有pte
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// 释放页表
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// 释放目录项
	pa = PADDR(e->env_pgdir);
	e->env_pgdir = 0;
	page_decref(pa2page(pa));

	// return the environment to the free list
	e->env_status = ENV_FREE;
	e->env_link = env_free_list;
	env_free_list = e;
}

//
// 释放进程
//
void
env_destroy(struct Env *e)
{

	if (e->env_status == ENV_RUNNING && curenv != e) {
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);

	if (curenv == e) {
		curenv = NULL;
		sched_yield();
	}
}


//
// 使用“ iret”指令在Trapframe中恢复寄存器值
//
void
env_pop_tf(struct Trapframe *tf)
{
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();

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
// 进程上下文切换
void
env_run(struct Env *e)
{

	if(curenv && curenv->env_status == ENV_RUNNING){
		curenv->env_status = ENV_RUNNABLE;
	}
	curenv = e;
	curenv->env_status = ENV_RUNNING;
	curenv->env_runs ++;

	
	lcr3(PADDR(curenv->env_pgdir));
	unlock_kernel();
	env_pop_tf(&curenv->env_tf);

}

