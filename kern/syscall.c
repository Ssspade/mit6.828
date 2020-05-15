/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>

#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/syscall.h>
#include <kern/console.h>
#include <kern/sched.h>

// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void
sys_cputs(const char *s, size_t len)
{
	// 检查权限
	user_mem_assert(curenv, s, len, 0);

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
}

// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
}

// 返回当前运行的进程
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
}

// 清除进程
static int
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	env_destroy(e);
	return 0;
}

// 调度
static void
sys_yield(void)
{
	sched_yield();
}

// 创建一个新进程
static envid_t
sys_exofork(void)
{
	
	struct Env *e;
	int err;

	err = env_alloc(&e, curenv->env_id);
	if (err != 0) {
		return err;
	}

	e->env_status = ENV_NOT_RUNNABLE;
	e->env_tf = curenv->env_tf;
	e->env_tf.tf_regs.reg_eax = 0;
	return e->env_id;
}

// 设置进程的状态
static int
sys_env_set_status(envid_t envid, int status)
{
	struct Env *e;
	int err;

	err = envid2env(envid, &e, 1);
	if (err != 0) {
		return -E_BAD_ENV;
	}

	if (status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE) {
		return -E_INVAL;
	}

	e->env_status = status;
	return 0;
}


// Set envid's trap frame to 'tf'.
// tf is modified to make sure that user environments always run at code
// protection level 3 (CPL 3), interrupts enabled, and IOPL of 0.
// 初始化新创建环境的状态
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	//panic("sys_env_set_trapframe not implemented");
	struct Env *e;
	int r = envid2env(envid, &e, 1);
	if(r)
		return r;
	user_mem_assert(e, (const void *) tf, sizeof(struct Trapframe), PTE_U);
	tf->tf_cs |=3;
	tf->tf_eflags &= ~FL_IOPL_MASK;         //普通进程不能有IO权限
	e->env_tf = *tf;
	return 0;
}

// 页错误入口函数

static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{

	struct Env *e;
	int err;

	err = envid2env(envid, &e, 1);
	if (err) {
		return -E_BAD_ENV;
	}

	e->env_pgfault_upcall = func;
	return 0;
}

// 分配页，注意权限的检查
static int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	struct Env *e;
	struct PageInfo *p;
	int err;

	err = envid2env(envid, &e, 1);
	if (err != 0) {
		return -E_BAD_ENV;
	}

	int valid_perm = (PTE_U | PTE_P);
	if (va >=  (void *)UTOP || (perm & valid_perm) != valid_perm) {
		return -E_INVAL;
	}

	p = page_alloc(ALLOC_ZERO);
	if (!p) {
		return -E_NO_MEM;
	}

	err = page_insert(e->env_pgdir, p, va, perm);
	if (err != 0) {
		page_free(p);
		return err;
	}
	return 0;
}

// 把源地址映射到目标虚拟地址中
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
	struct Env *srcenv, *dstenv;
	pte_t *pte;
	struct PageInfo *p;
	int err;

	err = envid2env(srcenvid, &srcenv, 1);
	if (err != 0) {
		return -E_BAD_ENV;
	}

	err = envid2env(dstenvid, &dstenv, 1);
	if (err != 0) {
		return -E_BAD_ENV;
	}

	if (srcva >= (void *)UTOP || dstva >= (void *)UTOP || PGOFF(srcva) || PGOFF(dstva)) {
		return -E_INVAL;
	}

	p = page_lookup(srcenv->env_pgdir, srcva, &pte);
	if (!p) {
		return -E_INVAL;
	}

	int valid_perm = (PTE_U | PTE_P);
	if ((perm & valid_perm) != valid_perm) {
		return -E_INVAL;
	}

	if ((perm & PTE_W) && !(*pte & PTE_W)) {
		return -E_INVAL;
	}

	err = page_insert(dstenv->env_pgdir, p, dstva, perm);
	if (err != 0) {
		return -E_NO_MEM;
	}

	return 0;

	
}

// 取消地址映射
static int
sys_page_unmap(envid_t envid, void *va)
{
	
	struct Env *e;
	int err;

	err = envid2env(envid, &e, 1);
	if (err != 0) {
		return -E_BAD_ENV;
	}

	if (va >= (void *)UTOP) {
		return -E_INVAL;
	}

	page_remove(e->env_pgdir, va);
	return 0;
}

//发送消息
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{

	int32_t ret;
	struct Env *other;
	pte_t *pte;
	struct PageInfo *pg;
	uint32_t recv_perm = 0;

	if ((ret = envid2env(envid, &other, 0)) < 0) {
		return ret; // -E_BAD_ENV
	}
	if (!other->env_ipc_recving) {
		return -E_IPC_NOT_RECV;
	}

	if ((uintptr_t)srcva < UTOP && other->env_ipc_dstva != NULL) {
		if ((uintptr_t)srcva % PGSIZE != 0) {
			return -E_INVAL;
		}
		if ((perm & (~PTE_SYSCALL))) {
			return -E_INVAL;
		}
		if ((pg = page_lookup(curenv->env_pgdir, srcva, &pte)) == NULL) {
			return -E_INVAL;
		}
		if ((perm & PTE_W) && !(*pte & PTE_W)) {
			return -E_INVAL;
		}
		if ((ret = page_insert(other->env_pgdir, 
				pg, other->env_ipc_dstva, perm)) < 0) {
			return ret; // -E_NO_MEM
		}
		
		recv_perm = perm;
	} 

	other->env_ipc_from = curenv->env_id;
	other->env_ipc_value = value;
	other->env_ipc_perm = recv_perm;
	other->env_ipc_recving = false;
	other->env_status = ENV_RUNNABLE;
	return 0; 
}

static int
sys_ipc_recv(void *dstva)
{	
	//地址合法
	if ((uintptr_t)dstva < UTOP && (uintptr_t)dstva % PGSIZE != 0) {
		return -E_INVAL;
	}
	if ((uintptr_t)dstva < UTOP)
		curenv->env_ipc_dstva = dstva;
	curenv->env_ipc_recving = true;
	curenv->env_status = ENV_NOT_RUNNABLE;
	curenv->env_tf.tf_regs.reg_eax = 0;
	sys_yield();
	return 0;
}

int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((char *)a1, a2);
		return 0;
	case SYS_cgetc:
		return sys_cgetc();
	case SYS_getenvid:
		return sys_getenvid();
	case SYS_env_destroy:
		return sys_env_destroy(a1);
	case SYS_yield:
		sys_yield();
		return 0;
	case SYS_exofork:
        	return sys_exofork();
    	case SYS_env_set_status:
        	return sys_env_set_status(a1, a2);
    	case SYS_page_alloc:
       	 	return sys_page_alloc(a1, (void *)a2, a3);
    	case SYS_page_map:
        	return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
    	case SYS_page_unmap:
        	return sys_page_unmap(a1, (void *)a2);
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall(a1, (void *)a2);
	case SYS_ipc_recv:
		return sys_ipc_recv((void *)a1);
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void *)a3, a4);
//---------------want to add alarm-------------------
	//case SYS_alarm:
		//return sys_alarm();
//------------------------------------------------------
	case SYS_env_set_trapframe:
                return sys_env_set_trapframe(a1, (struct Trapframe *)a2);
	default:
		return -E_INVAL;
	}
}

