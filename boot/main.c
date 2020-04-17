#include <inc/x86.h>
#include <inc/elf.h>

/**********************************************************************
 * This a dirt simple boot loader, whose sole job is to boot
 * an ELF kernel image from the first IDE hard disk.
 *这是一个非常简单的引导加载程序，任务是将IDE磁盘引导ELF内核映像
 * DISK LAYOUT
 *  * This program(boot.S and main.c) is the bootloader.  It should
 *    be stored in the first sector of the disk.被存储在磁盘的第一扇区
 *
 *  * The 2nd sector onward holds the kernel image.第二扇区存内核镜像
 *
 *  * The kernel image must be in ELF format.内核镜像必须是ELF格式
 *
 * BOOT UP STEPS
 *  * when the CPU boots it loads the BIOS into memory and executes it
 *  *当CPU启动时，会将BIOS加载到内存中并执行
 *  * the BIOS intializes devices, sets of the interrupt routines, and
 *    reads the first sector of the boot device(e.g., hard-drive)
 *    into memory and jumps to it.
 *  * BIOS初始化设备、中断，并将引导设备的第一个扇区读入内存
 *  * Assuming this boot loader is stored in the first sector of the
 *    hard-drive, this code takes over...
 *  * 如果这个引导加载程序在磁盘的第一个扇区中，将跳到此处
 *  * control starts in boot.S -- which sets up protected mode,
 *    and a stack so C code then run, then calls bootmain()
 *  * boot.s中设置保护模式，然后运行一个栈以便c
 *  * bootmain() in this file takes over, reads in the kernel and jumps to it.
 **********************************************************************/

#define SECTSIZE	512
#define ELFHDR		((struct Elf *) 0x10000) // scratch space 暂存空间

void readsect(void*, uint32_t);   //读磁盘数据
void readseg(uint32_t, uint32_t, uint32_t);   //读段

void
bootmain(void)
{
	struct Proghdr *ph, *eph;
	int i;

	// read 1st page off disk读第一个扇区
	readseg((uint32_t) ELFHDR, SECTSIZE*8, 0);

	// is this a valid ELF?检查其是否为有效的elf
	if (ELFHDR->e_magic != ELF_MAGIC)
		goto bad;

	// load each program segment (ignores ph flags)
	//加载程序段
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
//<<<<<<< HEAD
	for (; ph < eph; ph++) {
//=======
	//通过ELFHDR->e_phnum知道kernel有多少段
	//for (; ph < eph; ph++)
//>>>>>>> lab3
		// p_pa is the load address of this segment (as well
		// as the physical address)循环读入
		readseg(ph->p_pa, ph->p_memsz, ph->p_offset);
		for (i = 0; i < ph->p_memsz - ph->p_filesz; i++) {
			*((char *) ph->p_pa + ph->p_filesz + i) = 0;
		}
	}

	// call the entry point from the ELF header
	// note: does not return!
	((void (*)(void)) (ELFHDR->e_entry))();

bad:
	outw(0x8A00, 0x8A00);
	outw(0x8A00, 0x8E00);
	while (1)
		/* do nothing */;
}

// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked
void
readseg(uint32_t pa, uint32_t count, uint32_t offset)
{
	uint32_t end_pa;

	end_pa = pa + count;

	// round down to sector boundary向下舍入到扇区边界
	pa &= ~(SECTSIZE - 1);

	// translate from bytes to sectors, and kernel starts at sector 1从字节转换为扇区，内核从扇区1开始
	offset = (offset / SECTSIZE) + 1;

	// If this is too slow, we could read lots of sectors at a time.
	// We'd write more to memory than asked, but it doesn't matter --
	// we load in increasing order.
	while (pa < end_pa) {
		// Since we haven't enabled paging yet and we're using
		// an identity segment mapping (see boot.S), we can
		// use physical addresses directly.  This won't be the
		// case once JOS enables the MMU.
		readsect((uint8_t*) pa, offset);
		pa += SECTSIZE;
		offset++;
	}
}

void
waitdisk(void)
{
	// wait for disk reaady
	while ((inb(0x1F7) & 0xC0) != 0x40)  //1f7端口检测磁盘状态，第七位
		/* do nothing */;
}

void
readsect(void *dst, uint32_t offset)
{
	// wait for disk to be ready
	waitdisk();

	outb(0x1F2, 1);		// count = 1  要读取的扇区数目
	outb(0x1F3, offset);	//要读取的扇区编号
	outb(0x1F4, offset >> 8);	//存放读写的低8位
	outb(0x1F5, offset >> 16);	//存放读写的高2位
	outb(0x1F6, (offset >> 24) | 0xE0);	//存放读写的磁盘头及磁盘号
	outb(0x1F7, 0x20);	// cmd 0x20 - read sectors 读取扇区命令

	// wait for disk to be ready
	waitdisk();

	// read a sector
	insl(0x1F0, dst, SECTSIZE/4);	//获取数据
}

