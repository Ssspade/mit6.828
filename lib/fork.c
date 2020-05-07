// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW		0x800

//
// 写时复制的页错误处理
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;
	// 检查权限,检查错误代码中的FEC_WR,PTE标记为PTE_COW
	if(!((err & FEC_WR)&&(uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)))){
		cprintf("va = %x, err = %x, uvpd = %x, uvpt = %x\n", addr, err, uvpd[PDX(addr)], uvpt[PGNUM(addr)]);
		panic("pgfault conditions wrong!\n");
	// 分配一个空闲页面，将其映射到一个临时位置(PFTEMP)，将数据从旧页面复制到新页面，然后将新页面移动到旧页面的地址。
	}
	envid_t envid = sys_getenvid();
	// 分配一个映射到临时位置的新页面，并将故障页面的内容复制到其中
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P|PTE_W|PTE_U);
	if(r)
		panic("page alloc fault!\n");
	addr = ROUNDDOWN(addr, PGSIZE);
	memcpy((void *)PFTEMP, (const void *)addr, PGSIZE);
	r = sys_page_map(envid, (void *)PFTEMP, envid, (void *)addr, PTE_P|PTE_W|PTE_U);
	if(r)
		panic("page map fault!\n");
	r = sys_page_unmap(envid, (void *)PFTEMP);//取消临时地址的映射
	if(r)
		panic("page umap fault!\n");

	//panic("pgfault not implemented");
}

//
// 将写时复制的页面映射到子进程的地址空间
// 然后在自己的地址空间中重新映射写时复制的页面。
static int
duppage(envid_t envid, unsigned pn)
{
	int r;

	void *addr = (void *)(pn << 12);	//虚拟地址为页号*PGSIZE
	envid_t cid = sys_getenvid();
	if(uvpt[pn] & (PTE_W|PTE_COW)){	//是否需要写时复制
		r = sys_page_map(cid, (void *)addr, envid,(void *)addr,  PTE_COW|PTE_U| PTE_P);
		if(r)
			return r;//panic("page map fault in duppage!\n");
		r = sys_page_map(cid, (void *)addr, cid,(void *)addr,  PTE_COW|PTE_U| PTE_P);
		if(r)
			return r;
	}else{//注意权限的设置
		r = sys_page_map(cid, (void *)addr, envid,(void *)addr,PTE_U | PTE_P);
		if(r)
			return r;
	}
	return 0;
}


//
envid_t
fork(void)
{
	set_pgfault_handler(pgfault);//设置

	envid_t envid = sys_exofork();
	unsigned char *addr;
	if (envid < 0) {
		panic("sys_exofork: %e", envid);
	}

	// child process
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	// parent process
	extern unsigned char end[];
	for (addr = 0; addr < (unsigned char *)USTACKTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}
	}


	int err;
	err = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
	if (err != 0) {
		panic("sys_page_alloc error: %e", err);
	}

	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);

	err = sys_env_set_status(envid, ENV_RUNNABLE);
	if (err != 0) {
		panic("sys_env_set_status: %e", err);
	}

	return envid;
}

// Challenge!
int
sfork(void)
{
	panic("sfork not implemented");
	return -E_INVAL;
}
