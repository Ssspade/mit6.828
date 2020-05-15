#include <inc/assert.h>
#include <inc/x86.h>
#include <kern/spinlock.h>
#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/monitor.h>

void sched_halt(void);

//轮转调度
void
sched_yield(void)
{
	struct Env *idle;

	size_t i;
	idle = curenv;
	int start_envx = idle ? ENVX(idle->env_id)+1 : 0;

	for (i = 0; i < NENV; i++) {
		int next_envx = (start_envx + i) % NENV;
		if (envs[next_envx].env_status == ENV_RUNNABLE) {
			env_run(&envs[next_envx]);
		}
	}
	//时间片递增
	//idle->env_runs ++;
	//
	if (idle && idle->env_status == ENV_RUNNING) {
		env_run(idle);
	}
	// sched_halt never returns
	sched_halt();
}

// 当无事可做时停止此CPU。等到定时器中断唤醒它。此函数永不返回。
void
sched_halt(void)
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
		while (1)
			monitor(NULL);
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
	lcr3(PADDR(kern_pgdir));

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
		"movl $0, %%ebp\n"
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}

