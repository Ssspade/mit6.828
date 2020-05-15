// yield the processor to other environments

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am process %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("process %08x doing, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in process %08x.\n", thisenv->env_id);
}
