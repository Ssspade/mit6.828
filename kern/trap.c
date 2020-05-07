#include <inc/mmu.h>
#include <inc/x86.h>
#include <inc/assert.h>

#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/env.h>
#include <kern/syscall.h>
#include <kern/sched.h>
#include <kern/kclock.h>
#include <kern/picirq.h>
#include <kern/cpu.h>
#include <kern/spinlock.h>

static struct Taskstate ts;

/* print_trapframe 调试
 */
static struct Trapframe *last_tf;

/*中断描述符表
 */
struct Gatedesc idt[256] = { { 0 } };
struct Pseudodesc idt_pd = {
	sizeof(idt) - 1, (uint32_t) idt
};


static const char *trapname(int trapno)
{
	static const char * const excnames[] = {
		"Divide error",
		"Debug",
		"Non-Maskable Interrupt",
		"Breakpoint",
		"Overflow",
		"BOUND Range Exceeded",
		"Invalid Opcode",
		"Device Not Available",
		"Double Fault",
		"Coprocessor Segment Overrun",
		"Invalid TSS",
		"Segment Not Present",
		"Stack Fault",
		"General Protection",
		"Page Fault",
		"(unknown trap)",
		"x87 FPU Floating-Point Error",
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
}


void
trap_init(void)
{
	extern struct Segdesc gdt[];

	void handler_divide();//0
	void handler_debug();//1
	void handler_nmi();//2
	void handler_brkpt();//3
	void handler_oflow();//4
	void handler_bound();//5
	void handler_illop();//6
	void handler_device();//7
	void handler_dblflt();//8_errocode
	//void handler_copsegover();//9
	void handler_tss();//10_errocode
	void handler_segnp();//11_errocode
	void handler_stack();//12_yes
	void handler_gpflt();//13_yes
	void handler_pgflt();//14_yes
	//void handler_res();//15
	void handler_fperr();//16
	void handler_align();//17
	void handler_mchk();//18
	void handler_simderr();//19

	void handler_syscall();//48

	void handler_irq_timer();
	void handler_irq_kbd();
	void handler_irq_serial();
	void handler_irq_spurious();
	void handler_irq_ide();
	void handler_irq_error();
	//中断门，第二个参数，1是陷阱，0是中断，中断会重置TF
	SETGATE(idt[T_DIVIDE], 0, GD_KT, handler_divide, 0);
	SETGATE(idt[T_DEBUG], 0, GD_KT, handler_debug, 0);
	SETGATE(idt[T_NMI], 0, GD_KT, handler_nmi, 0);
	SETGATE(idt[T_BRKPT], 0, GD_KT, handler_brkpt, 3);
	SETGATE(idt[T_OFLOW], 0, GD_KT, handler_oflow, 0);
	SETGATE(idt[T_BOUND], 0, GD_KT, handler_bound, 0);
	SETGATE(idt[T_ILLOP], 0, GD_KT, handler_illop, 0);
	SETGATE(idt[T_DEVICE], 0, GD_KT, handler_device, 0);
	SETGATE(idt[T_TSS], 0, GD_KT, handler_tss, 0);
	SETGATE(idt[T_SEGNP], 0, GD_KT, handler_segnp, 0);
	SETGATE(idt[T_STACK], 0, GD_KT, handler_stack, 0);
	SETGATE(idt[T_GPFLT], 0, GD_KT, handler_gpflt, 0);
	SETGATE(idt[T_PGFLT], 0, GD_KT, handler_pgflt, 0);
	SETGATE(idt[T_FPERR], 0, GD_KT, handler_fperr, 0);
	SETGATE(idt[T_ALIGN], 0, GD_KT, handler_align, 0);
	SETGATE(idt[T_MCHK], 0, GD_KT, handler_mchk, 0);
	SETGATE(idt[T_SIMDERR], 0, GD_KT, handler_simderr, 0);

	SETGATE(idt[T_SYSCALL], 0, GD_KT, handler_syscall, 3);

	SETGATE(idt[IRQ_TIMER+IRQ_OFFSET], 0, GD_KT, handler_irq_timer, 3);
	SETGATE(idt[IRQ_KBD+IRQ_OFFSET], 0, GD_KT, handler_irq_kbd, 3);
	SETGATE(idt[IRQ_SERIAL+IRQ_OFFSET], 0, GD_KT, handler_irq_serial, 3);
	SETGATE(idt[IRQ_SPURIOUS+IRQ_OFFSET], 0, GD_KT, handler_irq_spurious, 3);
	SETGATE(idt[IRQ_IDE+IRQ_OFFSET], 0, GD_KT, handler_irq_ide, 3);
	SETGATE(idt[IRQ_ERROR+IRQ_OFFSET], 0, GD_KT, handler_irq_error, 3);
	// Per-CPU setup 
	trap_init_percpu();
}

// 初始化并加载每个CPU的TSS和IDT
void
trap_init_percpu(void)
{
	int i = cpunum();
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - i*(KSTKSIZE+KSTKGAP);
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
	
	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
					sizeof(struct Taskstate) - 1, 0);

	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;

	ltr(GD_TSS0 + (i<< 3));
	//ltr时要注意是加载的描述符的偏移值，所以记得cpu_id<<3

	// Load the IDT
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
		cprintf("  cr2  0x%08x\n", rcr2());
	cprintf("  err  0x%08x", tf->tf_err);
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
	cprintf("  eip  0x%08x\n", tf->tf_eip);
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
	if ((tf->tf_cs & 3) != 0) {
		cprintf("  esp  0x%08x\n", tf->tf_esp);
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
	}
}

void
print_regs(struct PushRegs *regs)
{
	cprintf("  edi  0x%08x\n", regs->reg_edi);
	cprintf("  esi  0x%08x\n", regs->reg_esi);
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
	cprintf("  edx  0x%08x\n", regs->reg_edx);
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
	cprintf("  eax  0x%08x\n", regs->reg_eax);
}

// 中断分配
static void
trap_dispatch(struct Trapframe *tf)
{

	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
		cprintf("Spurious interrupt on irq 7\n");
		print_trapframe(tf);
		return;
	}

	if(tf->tf_trapno == IRQ_TIMER+IRQ_OFFSET){
		lapic_eoi();
		sched_yield();
		return;
	}
	if(tf->tf_trapno == T_PGFLT)
		return page_fault_handler(tf);
	// 意外陷阱：用户进程或内核有错误
	if(tf->tf_trapno == T_BRKPT)
		return monitor(tf);
	// 系统调用
	if(tf->tf_trapno == T_SYSCALL){
		int32_t ret_ = syscall(tf->tf_regs.reg_eax,
					tf->tf_regs.reg_edx,
					tf->tf_regs.reg_ecx,
					tf->tf_regs.reg_ebx,
					tf->tf_regs.reg_edi,
					tf->tf_regs.reg_esi);
		tf->tf_regs.reg_eax = ret_;
		return;
		}
	print_trapframe(tf);
	if (tf->tf_cs == GD_KT)
		panic("unhandled trap in kernel");
	else {
		env_destroy(curenv);
		return;
	}
}

void
trap(struct Trapframe *tf)
{
	asm volatile("cld" ::: "cc");

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
		asm volatile("hlt");

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
		lock_kernel();
	// 检查中断是否被禁用.
	assert(!(read_eflags() & FL_IF));
	//cprintf("Incoming TRAP frame at %p\n", tf);
	if ((tf->tf_cs & 3) == 3) {
		// 用户模式捕捉到中断
		lock_kernel();
		assert(curenv);

		// 如果当前环境是僵尸工作
		if (curenv->env_status == ENV_DYING) {
			env_free(curenv);
			curenv = NULL;
			sched_yield();
		}

		// 将trap frame（当前位于堆栈上）复制到“curenv->env_tf”，以便在陷阱点重新启动运行环境。
		curenv->env_tf = *tf;
		// 忽略堆栈上的trapframe
		tf = &curenv->env_tf;
	}

	// 记录下tf是最后一个真正的trapframe
	last_tf = tf;

	// 分配中断
	trap_dispatch(tf);

	// 返回到当前环境
	if (curenv && curenv->env_status == ENV_RUNNING)
		env_run(curenv);
	else
		sched_yield();
}

//用户模式发生页错误将在另一个堆栈上运行用户页错误程序，即用户异常堆栈
// 通过stub汇编语言返回到原始栈中
void
page_fault_handler(struct Trapframe *tf)
{
	uint32_t fault_va;

	// 读取处理器的CR2寄存器以查找故障地址
	fault_va = rcr2();

	// 内核模式的页错误
	if((tf->tf_cs &3)==0){
		panic("kernel page fault!");
	}
	struct UTrapframe *utf;
	if(curenv->env_pgfault_upcall!=0){	//发生异常，用户环境已经在用户异常栈上运行，需要在tf->tf_esp下启动新的堆栈
		//首先推送一个空的32位word，然后是struct UTrapframe
		if(tf->tf_esp<=UXSTACKTOP-1&& tf->tf_esp>= UXSTACKTOP-PGSIZE){
			utf = (struct UTrapframe *)(tf->tf_esp-sizeof(struct UTrapframe)-4);
		}else{		//新建一个栈
			utf = (struct UTrapframe *)(UXSTACKTOP-sizeof(struct UTrapframe));
		}
		user_mem_assert(curenv, (const void *)utf, sizeof(struct UTrapframe),PTE_W);//检查异常栈是否溢出
		utf->utf_fault_va = fault_va;
		utf->utf_err = tf->tf_err;
		utf->utf_regs = tf->tf_regs;
		utf->utf_eip = tf->tf_eip;
		utf->utf_eflags = tf->tf_eflags;
		utf->utf_esp = tf->tf_esp;

		curenv->env_tf.tf_esp = (uintptr_t)utf;
		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
		env_run(curenv);
	}
		
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
	env_destroy(curenv);
}

