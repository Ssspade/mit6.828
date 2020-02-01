
obj/kern/kernel：     文件格式 elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 e0 18 00       	mov    $0x18e000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 b0 11 f0       	mov    $0xf011b000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 08             	sub    $0x8,%esp
f0100047:	e8 1b 01 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f010004c:	81 c3 d4 cf 08 00    	add    $0x8cfd4,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100052:	c7 c0 e0 ff 18 f0    	mov    $0xf018ffe0,%eax
f0100058:	c7 c2 e0 f0 18 f0    	mov    $0xf018f0e0,%edx
f010005e:	29 d0                	sub    %edx,%eax
f0100060:	50                   	push   %eax
f0100061:	6a 00                	push   $0x0
f0100063:	52                   	push   %edx
f0100064:	e8 e6 50 00 00       	call   f010514f <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100069:	e8 4e 05 00 00       	call   f01005bc <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006e:	83 c4 08             	add    $0x8,%esp
f0100071:	68 ac 1a 00 00       	push   $0x1aac
f0100076:	8d 83 80 85 f7 ff    	lea    -0x87a80(%ebx),%eax
f010007c:	50                   	push   %eax
f010007d:	e8 95 3b 00 00       	call   f0103c17 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100082:	e8 70 14 00 00       	call   f01014f7 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100087:	e8 d4 34 00 00       	call   f0103560 <env_init>
	trap_init();
f010008c:	e8 39 3c 00 00       	call   f0103cca <trap_init>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f0100091:	83 c4 08             	add    $0x8,%esp
f0100094:	6a 00                	push   $0x0
f0100096:	ff b3 f4 ff ff ff    	pushl  -0xc(%ebx)
f010009c:	e8 c1 36 00 00       	call   f0103762 <env_create>
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000a1:	83 c4 04             	add    $0x4,%esp
f01000a4:	c7 c0 2c f3 18 f0    	mov    $0xf018f32c,%eax
f01000aa:	ff 30                	pushl  (%eax)
f01000ac:	e8 6a 3a 00 00       	call   f0103b1b <env_run>

f01000b1 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000b1:	55                   	push   %ebp
f01000b2:	89 e5                	mov    %esp,%ebp
f01000b4:	57                   	push   %edi
f01000b5:	56                   	push   %esi
f01000b6:	53                   	push   %ebx
f01000b7:	83 ec 0c             	sub    $0xc,%esp
f01000ba:	e8 a8 00 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f01000bf:	81 c3 61 cf 08 00    	add    $0x8cf61,%ebx
f01000c5:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f01000c8:	c7 c0 e4 ff 18 f0    	mov    $0xf018ffe4,%eax
f01000ce:	83 38 00             	cmpl   $0x0,(%eax)
f01000d1:	74 0f                	je     f01000e2 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d3:	83 ec 0c             	sub    $0xc,%esp
f01000d6:	6a 00                	push   $0x0
f01000d8:	e8 71 09 00 00       	call   f0100a4e <monitor>
f01000dd:	83 c4 10             	add    $0x10,%esp
f01000e0:	eb f1                	jmp    f01000d3 <_panic+0x22>
	panicstr = fmt;
f01000e2:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f01000e4:	fa                   	cli    
f01000e5:	fc                   	cld    
	va_start(ap, fmt);
f01000e6:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f01000e9:	83 ec 04             	sub    $0x4,%esp
f01000ec:	ff 75 0c             	pushl  0xc(%ebp)
f01000ef:	ff 75 08             	pushl  0x8(%ebp)
f01000f2:	8d 83 9b 85 f7 ff    	lea    -0x87a65(%ebx),%eax
f01000f8:	50                   	push   %eax
f01000f9:	e8 19 3b 00 00       	call   f0103c17 <cprintf>
	vcprintf(fmt, ap);
f01000fe:	83 c4 08             	add    $0x8,%esp
f0100101:	56                   	push   %esi
f0100102:	57                   	push   %edi
f0100103:	e8 d8 3a 00 00       	call   f0103be0 <vcprintf>
	cprintf("\n");
f0100108:	8d 83 ce 8d f7 ff    	lea    -0x87232(%ebx),%eax
f010010e:	89 04 24             	mov    %eax,(%esp)
f0100111:	e8 01 3b 00 00       	call   f0103c17 <cprintf>
f0100116:	83 c4 10             	add    $0x10,%esp
f0100119:	eb b8                	jmp    f01000d3 <_panic+0x22>

f010011b <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010011b:	55                   	push   %ebp
f010011c:	89 e5                	mov    %esp,%ebp
f010011e:	56                   	push   %esi
f010011f:	53                   	push   %ebx
f0100120:	e8 42 00 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100125:	81 c3 fb ce 08 00    	add    $0x8cefb,%ebx
	va_list ap;

	va_start(ap, fmt);
f010012b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f010012e:	83 ec 04             	sub    $0x4,%esp
f0100131:	ff 75 0c             	pushl  0xc(%ebp)
f0100134:	ff 75 08             	pushl  0x8(%ebp)
f0100137:	8d 83 b3 85 f7 ff    	lea    -0x87a4d(%ebx),%eax
f010013d:	50                   	push   %eax
f010013e:	e8 d4 3a 00 00       	call   f0103c17 <cprintf>
	vcprintf(fmt, ap);
f0100143:	83 c4 08             	add    $0x8,%esp
f0100146:	56                   	push   %esi
f0100147:	ff 75 10             	pushl  0x10(%ebp)
f010014a:	e8 91 3a 00 00       	call   f0103be0 <vcprintf>
	cprintf("\n");
f010014f:	8d 83 ce 8d f7 ff    	lea    -0x87232(%ebx),%eax
f0100155:	89 04 24             	mov    %eax,(%esp)
f0100158:	e8 ba 3a 00 00       	call   f0103c17 <cprintf>
	va_end(ap);
}
f010015d:	83 c4 10             	add    $0x10,%esp
f0100160:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100163:	5b                   	pop    %ebx
f0100164:	5e                   	pop    %esi
f0100165:	5d                   	pop    %ebp
f0100166:	c3                   	ret    

f0100167 <__x86.get_pc_thunk.bx>:
f0100167:	8b 1c 24             	mov    (%esp),%ebx
f010016a:	c3                   	ret    

f010016b <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010016b:	55                   	push   %ebp
f010016c:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010016e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100173:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100174:	a8 01                	test   $0x1,%al
f0100176:	74 0b                	je     f0100183 <serial_proc_data+0x18>
f0100178:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010017d:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010017e:	0f b6 c0             	movzbl %al,%eax
}
f0100181:	5d                   	pop    %ebp
f0100182:	c3                   	ret    
		return -1;
f0100183:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100188:	eb f7                	jmp    f0100181 <serial_proc_data+0x16>

f010018a <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010018a:	55                   	push   %ebp
f010018b:	89 e5                	mov    %esp,%ebp
f010018d:	56                   	push   %esi
f010018e:	53                   	push   %ebx
f010018f:	e8 d3 ff ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100194:	81 c3 8c ce 08 00    	add    $0x8ce8c,%ebx
f010019a:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f010019c:	ff d6                	call   *%esi
f010019e:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001a1:	74 2e                	je     f01001d1 <cons_intr+0x47>
		if (c == 0)
f01001a3:	85 c0                	test   %eax,%eax
f01001a5:	74 f5                	je     f010019c <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f01001a7:	8b 8b e4 22 00 00    	mov    0x22e4(%ebx),%ecx
f01001ad:	8d 51 01             	lea    0x1(%ecx),%edx
f01001b0:	89 93 e4 22 00 00    	mov    %edx,0x22e4(%ebx)
f01001b6:	88 84 0b e0 20 00 00 	mov    %al,0x20e0(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f01001bd:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001c3:	75 d7                	jne    f010019c <cons_intr+0x12>
			cons.wpos = 0;
f01001c5:	c7 83 e4 22 00 00 00 	movl   $0x0,0x22e4(%ebx)
f01001cc:	00 00 00 
f01001cf:	eb cb                	jmp    f010019c <cons_intr+0x12>
	}
}
f01001d1:	5b                   	pop    %ebx
f01001d2:	5e                   	pop    %esi
f01001d3:	5d                   	pop    %ebp
f01001d4:	c3                   	ret    

f01001d5 <kbd_proc_data>:
{
f01001d5:	55                   	push   %ebp
f01001d6:	89 e5                	mov    %esp,%ebp
f01001d8:	56                   	push   %esi
f01001d9:	53                   	push   %ebx
f01001da:	e8 88 ff ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01001df:	81 c3 41 ce 08 00    	add    $0x8ce41,%ebx
f01001e5:	ba 64 00 00 00       	mov    $0x64,%edx
f01001ea:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01001eb:	a8 01                	test   $0x1,%al
f01001ed:	0f 84 06 01 00 00    	je     f01002f9 <kbd_proc_data+0x124>
	if (stat & KBS_TERR)
f01001f3:	a8 20                	test   $0x20,%al
f01001f5:	0f 85 05 01 00 00    	jne    f0100300 <kbd_proc_data+0x12b>
f01001fb:	ba 60 00 00 00       	mov    $0x60,%edx
f0100200:	ec                   	in     (%dx),%al
f0100201:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100203:	3c e0                	cmp    $0xe0,%al
f0100205:	0f 84 93 00 00 00    	je     f010029e <kbd_proc_data+0xc9>
	} else if (data & 0x80) {
f010020b:	84 c0                	test   %al,%al
f010020d:	0f 88 a0 00 00 00    	js     f01002b3 <kbd_proc_data+0xde>
	} else if (shift & E0ESC) {
f0100213:	8b 8b c0 20 00 00    	mov    0x20c0(%ebx),%ecx
f0100219:	f6 c1 40             	test   $0x40,%cl
f010021c:	74 0e                	je     f010022c <kbd_proc_data+0x57>
		data |= 0x80;
f010021e:	83 c8 80             	or     $0xffffff80,%eax
f0100221:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100223:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100226:	89 8b c0 20 00 00    	mov    %ecx,0x20c0(%ebx)
	shift |= shiftcode[data];
f010022c:	0f b6 d2             	movzbl %dl,%edx
f010022f:	0f b6 84 13 00 87 f7 	movzbl -0x87900(%ebx,%edx,1),%eax
f0100236:	ff 
f0100237:	0b 83 c0 20 00 00    	or     0x20c0(%ebx),%eax
	shift ^= togglecode[data];
f010023d:	0f b6 8c 13 00 86 f7 	movzbl -0x87a00(%ebx,%edx,1),%ecx
f0100244:	ff 
f0100245:	31 c8                	xor    %ecx,%eax
f0100247:	89 83 c0 20 00 00    	mov    %eax,0x20c0(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f010024d:	89 c1                	mov    %eax,%ecx
f010024f:	83 e1 03             	and    $0x3,%ecx
f0100252:	8b 8c 8b 00 20 00 00 	mov    0x2000(%ebx,%ecx,4),%ecx
f0100259:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010025d:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f0100260:	a8 08                	test   $0x8,%al
f0100262:	74 0d                	je     f0100271 <kbd_proc_data+0x9c>
		if ('a' <= c && c <= 'z')
f0100264:	89 f2                	mov    %esi,%edx
f0100266:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f0100269:	83 f9 19             	cmp    $0x19,%ecx
f010026c:	77 7a                	ja     f01002e8 <kbd_proc_data+0x113>
			c += 'A' - 'a';
f010026e:	83 ee 20             	sub    $0x20,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100271:	f7 d0                	not    %eax
f0100273:	a8 06                	test   $0x6,%al
f0100275:	75 33                	jne    f01002aa <kbd_proc_data+0xd5>
f0100277:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f010027d:	75 2b                	jne    f01002aa <kbd_proc_data+0xd5>
		cprintf("Rebooting!\n");
f010027f:	83 ec 0c             	sub    $0xc,%esp
f0100282:	8d 83 cd 85 f7 ff    	lea    -0x87a33(%ebx),%eax
f0100288:	50                   	push   %eax
f0100289:	e8 89 39 00 00       	call   f0103c17 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010028e:	b8 03 00 00 00       	mov    $0x3,%eax
f0100293:	ba 92 00 00 00       	mov    $0x92,%edx
f0100298:	ee                   	out    %al,(%dx)
f0100299:	83 c4 10             	add    $0x10,%esp
f010029c:	eb 0c                	jmp    f01002aa <kbd_proc_data+0xd5>
		shift |= E0ESC;
f010029e:	83 8b c0 20 00 00 40 	orl    $0x40,0x20c0(%ebx)
		return 0;
f01002a5:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002aa:	89 f0                	mov    %esi,%eax
f01002ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002af:	5b                   	pop    %ebx
f01002b0:	5e                   	pop    %esi
f01002b1:	5d                   	pop    %ebp
f01002b2:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002b3:	8b 8b c0 20 00 00    	mov    0x20c0(%ebx),%ecx
f01002b9:	89 ce                	mov    %ecx,%esi
f01002bb:	83 e6 40             	and    $0x40,%esi
f01002be:	83 e0 7f             	and    $0x7f,%eax
f01002c1:	85 f6                	test   %esi,%esi
f01002c3:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002c6:	0f b6 d2             	movzbl %dl,%edx
f01002c9:	0f b6 84 13 00 87 f7 	movzbl -0x87900(%ebx,%edx,1),%eax
f01002d0:	ff 
f01002d1:	83 c8 40             	or     $0x40,%eax
f01002d4:	0f b6 c0             	movzbl %al,%eax
f01002d7:	f7 d0                	not    %eax
f01002d9:	21 c8                	and    %ecx,%eax
f01002db:	89 83 c0 20 00 00    	mov    %eax,0x20c0(%ebx)
		return 0;
f01002e1:	be 00 00 00 00       	mov    $0x0,%esi
f01002e6:	eb c2                	jmp    f01002aa <kbd_proc_data+0xd5>
		else if ('A' <= c && c <= 'Z')
f01002e8:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002eb:	8d 4e 20             	lea    0x20(%esi),%ecx
f01002ee:	83 fa 1a             	cmp    $0x1a,%edx
f01002f1:	0f 42 f1             	cmovb  %ecx,%esi
f01002f4:	e9 78 ff ff ff       	jmp    f0100271 <kbd_proc_data+0x9c>
		return -1;
f01002f9:	be ff ff ff ff       	mov    $0xffffffff,%esi
f01002fe:	eb aa                	jmp    f01002aa <kbd_proc_data+0xd5>
		return -1;
f0100300:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100305:	eb a3                	jmp    f01002aa <kbd_proc_data+0xd5>

f0100307 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100307:	55                   	push   %ebp
f0100308:	89 e5                	mov    %esp,%ebp
f010030a:	57                   	push   %edi
f010030b:	56                   	push   %esi
f010030c:	53                   	push   %ebx
f010030d:	83 ec 1c             	sub    $0x1c,%esp
f0100310:	e8 52 fe ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100315:	81 c3 0b cd 08 00    	add    $0x8cd0b,%ebx
f010031b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f010031e:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100323:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100328:	b9 84 00 00 00       	mov    $0x84,%ecx
f010032d:	eb 09                	jmp    f0100338 <cons_putc+0x31>
f010032f:	89 ca                	mov    %ecx,%edx
f0100331:	ec                   	in     (%dx),%al
f0100332:	ec                   	in     (%dx),%al
f0100333:	ec                   	in     (%dx),%al
f0100334:	ec                   	in     (%dx),%al
	     i++)
f0100335:	83 c6 01             	add    $0x1,%esi
f0100338:	89 fa                	mov    %edi,%edx
f010033a:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010033b:	a8 20                	test   $0x20,%al
f010033d:	75 08                	jne    f0100347 <cons_putc+0x40>
f010033f:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100345:	7e e8                	jle    f010032f <cons_putc+0x28>
	outb(COM1 + COM_TX, c);
f0100347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010034a:	89 f8                	mov    %edi,%eax
f010034c:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010034f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100354:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100355:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010035a:	bf 79 03 00 00       	mov    $0x379,%edi
f010035f:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100364:	eb 09                	jmp    f010036f <cons_putc+0x68>
f0100366:	89 ca                	mov    %ecx,%edx
f0100368:	ec                   	in     (%dx),%al
f0100369:	ec                   	in     (%dx),%al
f010036a:	ec                   	in     (%dx),%al
f010036b:	ec                   	in     (%dx),%al
f010036c:	83 c6 01             	add    $0x1,%esi
f010036f:	89 fa                	mov    %edi,%edx
f0100371:	ec                   	in     (%dx),%al
f0100372:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100378:	7f 04                	jg     f010037e <cons_putc+0x77>
f010037a:	84 c0                	test   %al,%al
f010037c:	79 e8                	jns    f0100366 <cons_putc+0x5f>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010037e:	ba 78 03 00 00       	mov    $0x378,%edx
f0100383:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f0100387:	ee                   	out    %al,(%dx)
f0100388:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010038d:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100392:	ee                   	out    %al,(%dx)
f0100393:	b8 08 00 00 00       	mov    $0x8,%eax
f0100398:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f0100399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010039c:	89 fa                	mov    %edi,%edx
f010039e:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003a4:	89 f8                	mov    %edi,%eax
f01003a6:	80 cc 07             	or     $0x7,%ah
f01003a9:	85 d2                	test   %edx,%edx
f01003ab:	0f 45 c7             	cmovne %edi,%eax
f01003ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f01003b1:	0f b6 c0             	movzbl %al,%eax
f01003b4:	83 f8 09             	cmp    $0x9,%eax
f01003b7:	0f 84 b9 00 00 00    	je     f0100476 <cons_putc+0x16f>
f01003bd:	83 f8 09             	cmp    $0x9,%eax
f01003c0:	7e 74                	jle    f0100436 <cons_putc+0x12f>
f01003c2:	83 f8 0a             	cmp    $0xa,%eax
f01003c5:	0f 84 9e 00 00 00    	je     f0100469 <cons_putc+0x162>
f01003cb:	83 f8 0d             	cmp    $0xd,%eax
f01003ce:	0f 85 d9 00 00 00    	jne    f01004ad <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f01003d4:	0f b7 83 e8 22 00 00 	movzwl 0x22e8(%ebx),%eax
f01003db:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003e1:	c1 e8 16             	shr    $0x16,%eax
f01003e4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003e7:	c1 e0 04             	shl    $0x4,%eax
f01003ea:	66 89 83 e8 22 00 00 	mov    %ax,0x22e8(%ebx)
	if (crt_pos >= CRT_SIZE) {
f01003f1:	66 81 bb e8 22 00 00 	cmpw   $0x7cf,0x22e8(%ebx)
f01003f8:	cf 07 
f01003fa:	0f 87 d4 00 00 00    	ja     f01004d4 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100400:	8b 8b f0 22 00 00    	mov    0x22f0(%ebx),%ecx
f0100406:	b8 0e 00 00 00       	mov    $0xe,%eax
f010040b:	89 ca                	mov    %ecx,%edx
f010040d:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010040e:	0f b7 9b e8 22 00 00 	movzwl 0x22e8(%ebx),%ebx
f0100415:	8d 71 01             	lea    0x1(%ecx),%esi
f0100418:	89 d8                	mov    %ebx,%eax
f010041a:	66 c1 e8 08          	shr    $0x8,%ax
f010041e:	89 f2                	mov    %esi,%edx
f0100420:	ee                   	out    %al,(%dx)
f0100421:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100426:	89 ca                	mov    %ecx,%edx
f0100428:	ee                   	out    %al,(%dx)
f0100429:	89 d8                	mov    %ebx,%eax
f010042b:	89 f2                	mov    %esi,%edx
f010042d:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010042e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100431:	5b                   	pop    %ebx
f0100432:	5e                   	pop    %esi
f0100433:	5f                   	pop    %edi
f0100434:	5d                   	pop    %ebp
f0100435:	c3                   	ret    
	switch (c & 0xff) {
f0100436:	83 f8 08             	cmp    $0x8,%eax
f0100439:	75 72                	jne    f01004ad <cons_putc+0x1a6>
		if (crt_pos > 0) {
f010043b:	0f b7 83 e8 22 00 00 	movzwl 0x22e8(%ebx),%eax
f0100442:	66 85 c0             	test   %ax,%ax
f0100445:	74 b9                	je     f0100400 <cons_putc+0xf9>
			crt_pos--;
f0100447:	83 e8 01             	sub    $0x1,%eax
f010044a:	66 89 83 e8 22 00 00 	mov    %ax,0x22e8(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100451:	0f b7 c0             	movzwl %ax,%eax
f0100454:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f0100458:	b2 00                	mov    $0x0,%dl
f010045a:	83 ca 20             	or     $0x20,%edx
f010045d:	8b 8b ec 22 00 00    	mov    0x22ec(%ebx),%ecx
f0100463:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f0100467:	eb 88                	jmp    f01003f1 <cons_putc+0xea>
		crt_pos += CRT_COLS;
f0100469:	66 83 83 e8 22 00 00 	addw   $0x50,0x22e8(%ebx)
f0100470:	50 
f0100471:	e9 5e ff ff ff       	jmp    f01003d4 <cons_putc+0xcd>
		cons_putc(' ');
f0100476:	b8 20 00 00 00       	mov    $0x20,%eax
f010047b:	e8 87 fe ff ff       	call   f0100307 <cons_putc>
		cons_putc(' ');
f0100480:	b8 20 00 00 00       	mov    $0x20,%eax
f0100485:	e8 7d fe ff ff       	call   f0100307 <cons_putc>
		cons_putc(' ');
f010048a:	b8 20 00 00 00       	mov    $0x20,%eax
f010048f:	e8 73 fe ff ff       	call   f0100307 <cons_putc>
		cons_putc(' ');
f0100494:	b8 20 00 00 00       	mov    $0x20,%eax
f0100499:	e8 69 fe ff ff       	call   f0100307 <cons_putc>
		cons_putc(' ');
f010049e:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a3:	e8 5f fe ff ff       	call   f0100307 <cons_putc>
f01004a8:	e9 44 ff ff ff       	jmp    f01003f1 <cons_putc+0xea>
		crt_buf[crt_pos++] = c;		/* write the character */
f01004ad:	0f b7 83 e8 22 00 00 	movzwl 0x22e8(%ebx),%eax
f01004b4:	8d 50 01             	lea    0x1(%eax),%edx
f01004b7:	66 89 93 e8 22 00 00 	mov    %dx,0x22e8(%ebx)
f01004be:	0f b7 c0             	movzwl %ax,%eax
f01004c1:	8b 93 ec 22 00 00    	mov    0x22ec(%ebx),%edx
f01004c7:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f01004cb:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004cf:	e9 1d ff ff ff       	jmp    f01003f1 <cons_putc+0xea>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004d4:	8b 83 ec 22 00 00    	mov    0x22ec(%ebx),%eax
f01004da:	83 ec 04             	sub    $0x4,%esp
f01004dd:	68 00 0f 00 00       	push   $0xf00
f01004e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004e8:	52                   	push   %edx
f01004e9:	50                   	push   %eax
f01004ea:	e8 ad 4c 00 00       	call   f010519c <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004ef:	8b 93 ec 22 00 00    	mov    0x22ec(%ebx),%edx
f01004f5:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004fb:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100501:	83 c4 10             	add    $0x10,%esp
f0100504:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100509:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010050c:	39 d0                	cmp    %edx,%eax
f010050e:	75 f4                	jne    f0100504 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f0100510:	66 83 ab e8 22 00 00 	subw   $0x50,0x22e8(%ebx)
f0100517:	50 
f0100518:	e9 e3 fe ff ff       	jmp    f0100400 <cons_putc+0xf9>

f010051d <serial_intr>:
{
f010051d:	e8 e7 01 00 00       	call   f0100709 <__x86.get_pc_thunk.ax>
f0100522:	05 fe ca 08 00       	add    $0x8cafe,%eax
	if (serial_exists)
f0100527:	80 b8 f4 22 00 00 00 	cmpb   $0x0,0x22f4(%eax)
f010052e:	75 02                	jne    f0100532 <serial_intr+0x15>
f0100530:	f3 c3                	repz ret 
{
f0100532:	55                   	push   %ebp
f0100533:	89 e5                	mov    %esp,%ebp
f0100535:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100538:	8d 80 4b 31 f7 ff    	lea    -0x8ceb5(%eax),%eax
f010053e:	e8 47 fc ff ff       	call   f010018a <cons_intr>
}
f0100543:	c9                   	leave  
f0100544:	c3                   	ret    

f0100545 <kbd_intr>:
{
f0100545:	55                   	push   %ebp
f0100546:	89 e5                	mov    %esp,%ebp
f0100548:	83 ec 08             	sub    $0x8,%esp
f010054b:	e8 b9 01 00 00       	call   f0100709 <__x86.get_pc_thunk.ax>
f0100550:	05 d0 ca 08 00       	add    $0x8cad0,%eax
	cons_intr(kbd_proc_data);
f0100555:	8d 80 b5 31 f7 ff    	lea    -0x8ce4b(%eax),%eax
f010055b:	e8 2a fc ff ff       	call   f010018a <cons_intr>
}
f0100560:	c9                   	leave  
f0100561:	c3                   	ret    

f0100562 <cons_getc>:
{
f0100562:	55                   	push   %ebp
f0100563:	89 e5                	mov    %esp,%ebp
f0100565:	53                   	push   %ebx
f0100566:	83 ec 04             	sub    $0x4,%esp
f0100569:	e8 f9 fb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010056e:	81 c3 b2 ca 08 00    	add    $0x8cab2,%ebx
	serial_intr();
f0100574:	e8 a4 ff ff ff       	call   f010051d <serial_intr>
	kbd_intr();
f0100579:	e8 c7 ff ff ff       	call   f0100545 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f010057e:	8b 93 e0 22 00 00    	mov    0x22e0(%ebx),%edx
	return 0;
f0100584:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f0100589:	3b 93 e4 22 00 00    	cmp    0x22e4(%ebx),%edx
f010058f:	74 19                	je     f01005aa <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f0100591:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100594:	89 8b e0 22 00 00    	mov    %ecx,0x22e0(%ebx)
f010059a:	0f b6 84 13 e0 20 00 	movzbl 0x20e0(%ebx,%edx,1),%eax
f01005a1:	00 
		if (cons.rpos == CONSBUFSIZE)
f01005a2:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01005a8:	74 06                	je     f01005b0 <cons_getc+0x4e>
}
f01005aa:	83 c4 04             	add    $0x4,%esp
f01005ad:	5b                   	pop    %ebx
f01005ae:	5d                   	pop    %ebp
f01005af:	c3                   	ret    
			cons.rpos = 0;
f01005b0:	c7 83 e0 22 00 00 00 	movl   $0x0,0x22e0(%ebx)
f01005b7:	00 00 00 
f01005ba:	eb ee                	jmp    f01005aa <cons_getc+0x48>

f01005bc <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01005bc:	55                   	push   %ebp
f01005bd:	89 e5                	mov    %esp,%ebp
f01005bf:	57                   	push   %edi
f01005c0:	56                   	push   %esi
f01005c1:	53                   	push   %ebx
f01005c2:	83 ec 1c             	sub    $0x1c,%esp
f01005c5:	e8 9d fb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01005ca:	81 c3 56 ca 08 00    	add    $0x8ca56,%ebx
	was = *cp;
f01005d0:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01005d7:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01005de:	5a a5 
	if (*cp != 0xA55A) {
f01005e0:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01005e7:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005eb:	0f 84 bc 00 00 00    	je     f01006ad <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f01005f1:	c7 83 f0 22 00 00 b4 	movl   $0x3b4,0x22f0(%ebx)
f01005f8:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005fb:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100602:	8b bb f0 22 00 00    	mov    0x22f0(%ebx),%edi
f0100608:	b8 0e 00 00 00       	mov    $0xe,%eax
f010060d:	89 fa                	mov    %edi,%edx
f010060f:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100610:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100613:	89 ca                	mov    %ecx,%edx
f0100615:	ec                   	in     (%dx),%al
f0100616:	0f b6 f0             	movzbl %al,%esi
f0100619:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010061c:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100621:	89 fa                	mov    %edi,%edx
f0100623:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100624:	89 ca                	mov    %ecx,%edx
f0100626:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100627:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010062a:	89 bb ec 22 00 00    	mov    %edi,0x22ec(%ebx)
	pos |= inb(addr_6845 + 1);
f0100630:	0f b6 c0             	movzbl %al,%eax
f0100633:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f0100635:	66 89 b3 e8 22 00 00 	mov    %si,0x22e8(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010063c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100641:	89 c8                	mov    %ecx,%eax
f0100643:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100648:	ee                   	out    %al,(%dx)
f0100649:	bf fb 03 00 00       	mov    $0x3fb,%edi
f010064e:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100653:	89 fa                	mov    %edi,%edx
f0100655:	ee                   	out    %al,(%dx)
f0100656:	b8 0c 00 00 00       	mov    $0xc,%eax
f010065b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100660:	ee                   	out    %al,(%dx)
f0100661:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100666:	89 c8                	mov    %ecx,%eax
f0100668:	89 f2                	mov    %esi,%edx
f010066a:	ee                   	out    %al,(%dx)
f010066b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100670:	89 fa                	mov    %edi,%edx
f0100672:	ee                   	out    %al,(%dx)
f0100673:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100678:	89 c8                	mov    %ecx,%eax
f010067a:	ee                   	out    %al,(%dx)
f010067b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100680:	89 f2                	mov    %esi,%edx
f0100682:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100683:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100688:	ec                   	in     (%dx),%al
f0100689:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010068b:	3c ff                	cmp    $0xff,%al
f010068d:	0f 95 83 f4 22 00 00 	setne  0x22f4(%ebx)
f0100694:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100699:	ec                   	in     (%dx),%al
f010069a:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010069f:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006a0:	80 f9 ff             	cmp    $0xff,%cl
f01006a3:	74 25                	je     f01006ca <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f01006a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006a8:	5b                   	pop    %ebx
f01006a9:	5e                   	pop    %esi
f01006aa:	5f                   	pop    %edi
f01006ab:	5d                   	pop    %ebp
f01006ac:	c3                   	ret    
		*cp = was;
f01006ad:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006b4:	c7 83 f0 22 00 00 d4 	movl   $0x3d4,0x22f0(%ebx)
f01006bb:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006be:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f01006c5:	e9 38 ff ff ff       	jmp    f0100602 <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f01006ca:	83 ec 0c             	sub    $0xc,%esp
f01006cd:	8d 83 d9 85 f7 ff    	lea    -0x87a27(%ebx),%eax
f01006d3:	50                   	push   %eax
f01006d4:	e8 3e 35 00 00       	call   f0103c17 <cprintf>
f01006d9:	83 c4 10             	add    $0x10,%esp
}
f01006dc:	eb c7                	jmp    f01006a5 <cons_init+0xe9>

f01006de <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006de:	55                   	push   %ebp
f01006df:	89 e5                	mov    %esp,%ebp
f01006e1:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01006e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01006e7:	e8 1b fc ff ff       	call   f0100307 <cons_putc>
}
f01006ec:	c9                   	leave  
f01006ed:	c3                   	ret    

f01006ee <getchar>:

int
getchar(void)
{
f01006ee:	55                   	push   %ebp
f01006ef:	89 e5                	mov    %esp,%ebp
f01006f1:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01006f4:	e8 69 fe ff ff       	call   f0100562 <cons_getc>
f01006f9:	85 c0                	test   %eax,%eax
f01006fb:	74 f7                	je     f01006f4 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006fd:	c9                   	leave  
f01006fe:	c3                   	ret    

f01006ff <iscons>:

int
iscons(int fdnum)
{
f01006ff:	55                   	push   %ebp
f0100700:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100702:	b8 01 00 00 00       	mov    $0x1,%eax
f0100707:	5d                   	pop    %ebp
f0100708:	c3                   	ret    

f0100709 <__x86.get_pc_thunk.ax>:
f0100709:	8b 04 24             	mov    (%esp),%eax
f010070c:	c3                   	ret    

f010070d <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010070d:	55                   	push   %ebp
f010070e:	89 e5                	mov    %esp,%ebp
f0100710:	56                   	push   %esi
f0100711:	53                   	push   %ebx
f0100712:	e8 50 fa ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100717:	81 c3 09 c9 08 00    	add    $0x8c909,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010071d:	83 ec 04             	sub    $0x4,%esp
f0100720:	8d 83 00 88 f7 ff    	lea    -0x87800(%ebx),%eax
f0100726:	50                   	push   %eax
f0100727:	8d 83 1e 88 f7 ff    	lea    -0x877e2(%ebx),%eax
f010072d:	50                   	push   %eax
f010072e:	8d b3 23 88 f7 ff    	lea    -0x877dd(%ebx),%esi
f0100734:	56                   	push   %esi
f0100735:	e8 dd 34 00 00       	call   f0103c17 <cprintf>
f010073a:	83 c4 0c             	add    $0xc,%esp
f010073d:	8d 83 fc 88 f7 ff    	lea    -0x87704(%ebx),%eax
f0100743:	50                   	push   %eax
f0100744:	8d 83 2c 88 f7 ff    	lea    -0x877d4(%ebx),%eax
f010074a:	50                   	push   %eax
f010074b:	56                   	push   %esi
f010074c:	e8 c6 34 00 00       	call   f0103c17 <cprintf>
	return 0;
}
f0100751:	b8 00 00 00 00       	mov    $0x0,%eax
f0100756:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100759:	5b                   	pop    %ebx
f010075a:	5e                   	pop    %esi
f010075b:	5d                   	pop    %ebp
f010075c:	c3                   	ret    

f010075d <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010075d:	55                   	push   %ebp
f010075e:	89 e5                	mov    %esp,%ebp
f0100760:	57                   	push   %edi
f0100761:	56                   	push   %esi
f0100762:	53                   	push   %ebx
f0100763:	83 ec 18             	sub    $0x18,%esp
f0100766:	e8 fc f9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010076b:	81 c3 b5 c8 08 00    	add    $0x8c8b5,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100771:	8d 83 35 88 f7 ff    	lea    -0x877cb(%ebx),%eax
f0100777:	50                   	push   %eax
f0100778:	e8 9a 34 00 00       	call   f0103c17 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010077d:	83 c4 08             	add    $0x8,%esp
f0100780:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f0100786:	8d 83 24 89 f7 ff    	lea    -0x876dc(%ebx),%eax
f010078c:	50                   	push   %eax
f010078d:	e8 85 34 00 00       	call   f0103c17 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100792:	83 c4 0c             	add    $0xc,%esp
f0100795:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f010079b:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007a1:	50                   	push   %eax
f01007a2:	57                   	push   %edi
f01007a3:	8d 83 4c 89 f7 ff    	lea    -0x876b4(%ebx),%eax
f01007a9:	50                   	push   %eax
f01007aa:	e8 68 34 00 00       	call   f0103c17 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007af:	83 c4 0c             	add    $0xc,%esp
f01007b2:	c7 c0 89 55 10 f0    	mov    $0xf0105589,%eax
f01007b8:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007be:	52                   	push   %edx
f01007bf:	50                   	push   %eax
f01007c0:	8d 83 70 89 f7 ff    	lea    -0x87690(%ebx),%eax
f01007c6:	50                   	push   %eax
f01007c7:	e8 4b 34 00 00       	call   f0103c17 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007cc:	83 c4 0c             	add    $0xc,%esp
f01007cf:	c7 c0 e0 f0 18 f0    	mov    $0xf018f0e0,%eax
f01007d5:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007db:	52                   	push   %edx
f01007dc:	50                   	push   %eax
f01007dd:	8d 83 94 89 f7 ff    	lea    -0x8766c(%ebx),%eax
f01007e3:	50                   	push   %eax
f01007e4:	e8 2e 34 00 00       	call   f0103c17 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01007e9:	83 c4 0c             	add    $0xc,%esp
f01007ec:	c7 c6 e0 ff 18 f0    	mov    $0xf018ffe0,%esi
f01007f2:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f01007f8:	50                   	push   %eax
f01007f9:	56                   	push   %esi
f01007fa:	8d 83 b8 89 f7 ff    	lea    -0x87648(%ebx),%eax
f0100800:	50                   	push   %eax
f0100801:	e8 11 34 00 00       	call   f0103c17 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100806:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100809:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f010080f:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100811:	c1 fe 0a             	sar    $0xa,%esi
f0100814:	56                   	push   %esi
f0100815:	8d 83 dc 89 f7 ff    	lea    -0x87624(%ebx),%eax
f010081b:	50                   	push   %eax
f010081c:	e8 f6 33 00 00       	call   f0103c17 <cprintf>
	return 0;
}
f0100821:	b8 00 00 00 00       	mov    $0x0,%eax
f0100826:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100829:	5b                   	pop    %ebx
f010082a:	5e                   	pop    %esi
f010082b:	5f                   	pop    %edi
f010082c:	5d                   	pop    %ebp
f010082d:	c3                   	ret    

f010082e <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010082e:	55                   	push   %ebp
f010082f:	89 e5                	mov    %esp,%ebp
f0100831:	57                   	push   %edi
f0100832:	56                   	push   %esi
f0100833:	53                   	push   %ebx
f0100834:	83 ec 4c             	sub    $0x4c,%esp
f0100837:	e8 2b f9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010083c:	81 c3 e4 c7 08 00    	add    $0x8c7e4,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100842:	89 e8                	mov    %ebp,%eax
	// Your code here.
	int i;
	uint32_t eip;
	uint32_t* ebp = (uint32_t *)read_ebp();
f0100844:	89 c7                	mov    %eax,%edi

	while (ebp) {
		eip = *(ebp + 1);
		cprintf("ebp %x eip %x args", ebp, eip);
f0100846:	8d 83 4e 88 f7 ff    	lea    -0x877b2(%ebx),%eax
f010084c:	89 45 b8             	mov    %eax,-0x48(%ebp)
		uint32_t *args = ebp + 2;
		for (i = 0; i < 5; i++) {
			uint32_t argi = args[i];
			cprintf(" %08x ", argi);
f010084f:	8d 83 61 88 f7 ff    	lea    -0x8779f(%ebx),%eax
f0100855:	89 45 b4             	mov    %eax,-0x4c(%ebp)
	while (ebp) {
f0100858:	e9 83 00 00 00       	jmp    f01008e0 <mon_backtrace+0xb2>
		eip = *(ebp + 1);
f010085d:	8b 47 04             	mov    0x4(%edi),%eax
f0100860:	89 45 c0             	mov    %eax,-0x40(%ebp)
		cprintf("ebp %x eip %x args", ebp, eip);
f0100863:	83 ec 04             	sub    $0x4,%esp
f0100866:	50                   	push   %eax
f0100867:	57                   	push   %edi
f0100868:	ff 75 b8             	pushl  -0x48(%ebp)
f010086b:	e8 a7 33 00 00       	call   f0103c17 <cprintf>
f0100870:	8d 77 08             	lea    0x8(%edi),%esi
f0100873:	8d 47 1c             	lea    0x1c(%edi),%eax
f0100876:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100879:	83 c4 10             	add    $0x10,%esp
f010087c:	89 7d bc             	mov    %edi,-0x44(%ebp)
f010087f:	8b 7d b4             	mov    -0x4c(%ebp),%edi
			cprintf(" %08x ", argi);
f0100882:	83 ec 08             	sub    $0x8,%esp
f0100885:	ff 36                	pushl  (%esi)
f0100887:	57                   	push   %edi
f0100888:	e8 8a 33 00 00       	call   f0103c17 <cprintf>
f010088d:	83 c6 04             	add    $0x4,%esi
		for (i = 0; i < 5; i++) {
f0100890:	83 c4 10             	add    $0x10,%esp
f0100893:	3b 75 c4             	cmp    -0x3c(%ebp),%esi
f0100896:	75 ea                	jne    f0100882 <mon_backtrace+0x54>
f0100898:	8b 7d bc             	mov    -0x44(%ebp),%edi
		}
		cprintf("\n");
f010089b:	83 ec 0c             	sub    $0xc,%esp
f010089e:	8d 83 ce 8d f7 ff    	lea    -0x87232(%ebx),%eax
f01008a4:	50                   	push   %eax
f01008a5:	e8 6d 33 00 00       	call   f0103c17 <cprintf>
		ebp = (uint32_t *) *ebp;
f01008aa:	8b 3f                	mov    (%edi),%edi
		struct Eipdebuginfo info;
		debuginfo_eip(eip, &info);
f01008ac:	83 c4 08             	add    $0x8,%esp
f01008af:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008b2:	50                   	push   %eax
f01008b3:	8b 75 c0             	mov    -0x40(%ebp),%esi
f01008b6:	56                   	push   %esi
f01008b7:	e8 2a 3e 00 00       	call   f01046e6 <debuginfo_eip>
		cprintf("\t%s:%d: %.*s+%d\n",
f01008bc:	83 c4 08             	add    $0x8,%esp
f01008bf:	89 f0                	mov    %esi,%eax
f01008c1:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01008c4:	50                   	push   %eax
f01008c5:	ff 75 d8             	pushl  -0x28(%ebp)
f01008c8:	ff 75 dc             	pushl  -0x24(%ebp)
f01008cb:	ff 75 d4             	pushl  -0x2c(%ebp)
f01008ce:	ff 75 d0             	pushl  -0x30(%ebp)
f01008d1:	8d 83 68 88 f7 ff    	lea    -0x87798(%ebx),%eax
f01008d7:	50                   	push   %eax
f01008d8:	e8 3a 33 00 00       	call   f0103c17 <cprintf>
f01008dd:	83 c4 20             	add    $0x20,%esp
	while (ebp) {
f01008e0:	85 ff                	test   %edi,%edi
f01008e2:	0f 85 75 ff ff ff    	jne    f010085d <mon_backtrace+0x2f>
			info.eip_file,info.eip_line,
			info.eip_fn_namelen, info.eip_fn_name,
			eip-info.eip_fn_addr);
	}
	return 0;
}
f01008e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01008ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008f0:	5b                   	pop    %ebx
f01008f1:	5e                   	pop    %esi
f01008f2:	5f                   	pop    %edi
f01008f3:	5d                   	pop    %ebp
f01008f4:	c3                   	ret    

f01008f5 <xtoi>:
///////////////////challenge///////////////////////////
uint32_t xtoi(char* buf) {
f01008f5:	55                   	push   %ebp
f01008f6:	89 e5                	mov    %esp,%ebp
	uint32_t res = 0;
	buf += 2; //0x...
f01008f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01008fb:	8d 50 02             	lea    0x2(%eax),%edx
	uint32_t res = 0;
f01008fe:	b8 00 00 00 00       	mov    $0x0,%eax
	while (*buf) { 
f0100903:	eb 0d                	jmp    f0100912 <xtoi+0x1d>
		if (*buf >= 'a') *buf = *buf-'a'+'0'+10;//aha
		res = res*16 + *buf - '0';
f0100905:	c1 e0 04             	shl    $0x4,%eax
f0100908:	0f be 0a             	movsbl (%edx),%ecx
f010090b:	8d 44 08 d0          	lea    -0x30(%eax,%ecx,1),%eax
		++buf;
f010090f:	83 c2 01             	add    $0x1,%edx
	while (*buf) { 
f0100912:	0f b6 0a             	movzbl (%edx),%ecx
f0100915:	84 c9                	test   %cl,%cl
f0100917:	74 0c                	je     f0100925 <xtoi+0x30>
		if (*buf >= 'a') *buf = *buf-'a'+'0'+10;//aha
f0100919:	80 f9 60             	cmp    $0x60,%cl
f010091c:	7e e7                	jle    f0100905 <xtoi+0x10>
f010091e:	83 e9 27             	sub    $0x27,%ecx
f0100921:	88 0a                	mov    %cl,(%edx)
f0100923:	eb e0                	jmp    f0100905 <xtoi+0x10>
	}
	return res;
}
f0100925:	5d                   	pop    %ebp
f0100926:	c3                   	ret    

f0100927 <pprint>:

void pprint(pte_t *pte) {
f0100927:	55                   	push   %ebp
f0100928:	89 e5                	mov    %esp,%ebp
f010092a:	53                   	push   %ebx
f010092b:	83 ec 04             	sub    $0x4,%esp
f010092e:	e8 34 f8 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100933:	81 c3 ed c6 08 00    	add    $0x8c6ed,%ebx
	cprintf("PTE_P: %x, PTE_W: %x, PTE_U: %x\n", 
		*pte&PTE_P, *pte&PTE_W, *pte&PTE_U);
f0100939:	8b 45 08             	mov    0x8(%ebp),%eax
f010093c:	8b 00                	mov    (%eax),%eax
	cprintf("PTE_P: %x, PTE_W: %x, PTE_U: %x\n", 
f010093e:	89 c2                	mov    %eax,%edx
f0100940:	83 e2 04             	and    $0x4,%edx
f0100943:	52                   	push   %edx
f0100944:	89 c2                	mov    %eax,%edx
f0100946:	83 e2 02             	and    $0x2,%edx
f0100949:	52                   	push   %edx
f010094a:	83 e0 01             	and    $0x1,%eax
f010094d:	50                   	push   %eax
f010094e:	8d 83 08 8a f7 ff    	lea    -0x875f8(%ebx),%eax
f0100954:	50                   	push   %eax
f0100955:	e8 bd 32 00 00       	call   f0103c17 <cprintf>
}
f010095a:	83 c4 10             	add    $0x10,%esp
f010095d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100960:	c9                   	leave  
f0100961:	c3                   	ret    

f0100962 <showmappings>:

int
showmappings(int argc, char **argv, struct Trapframe *tf)
{
f0100962:	55                   	push   %ebp
f0100963:	89 e5                	mov    %esp,%ebp
f0100965:	57                   	push   %edi
f0100966:	56                   	push   %esi
f0100967:	53                   	push   %ebx
f0100968:	83 ec 1c             	sub    $0x1c,%esp
f010096b:	e8 f7 f7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100970:	81 c3 b0 c6 08 00    	add    $0x8c6b0,%ebx
f0100976:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc == 1) {
f0100979:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f010097d:	74 43                	je     f01009c2 <showmappings+0x60>
		cprintf("Usage: showmappings 0xbegin_addr 0xend_addr\n");
		return 0;
	}
	uint32_t begin = xtoi(argv[1]), end = xtoi(argv[2]);
f010097f:	83 ec 0c             	sub    $0xc,%esp
f0100982:	ff 76 04             	pushl  0x4(%esi)
f0100985:	e8 6b ff ff ff       	call   f01008f5 <xtoi>
f010098a:	89 c7                	mov    %eax,%edi
f010098c:	83 c4 04             	add    $0x4,%esp
f010098f:	ff 76 08             	pushl  0x8(%esi)
f0100992:	e8 5e ff ff ff       	call   f01008f5 <xtoi>
f0100997:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	cprintf("begin: %x, end: %x\n", begin, end);
f010099a:	83 c4 0c             	add    $0xc,%esp
f010099d:	50                   	push   %eax
f010099e:	57                   	push   %edi
f010099f:	8d 83 79 88 f7 ff    	lea    -0x87787(%ebx),%eax
f01009a5:	50                   	push   %eax
f01009a6:	e8 6c 32 00 00       	call   f0103c17 <cprintf>
	for (; begin <= end; begin += PGSIZE) {
f01009ab:	83 c4 10             	add    $0x10,%esp
		pte_t *pte = pgdir_walk(kern_pgdir, (void *) begin, 1);	//create
f01009ae:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f01009b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
		if (!pte) panic("boot_map_region panic, out of memory");
		if (*pte & PTE_P) {
			cprintf("page %x with ", begin);
			pprint(pte);
		} else cprintf("page not exist: %x\n", begin);
f01009b7:	8d 83 aa 88 f7 ff    	lea    -0x87756(%ebx),%eax
f01009bd:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for (; begin <= end; begin += PGSIZE) {
f01009c0:	eb 4c                	jmp    f0100a0e <showmappings+0xac>
		cprintf("Usage: showmappings 0xbegin_addr 0xend_addr\n");
f01009c2:	83 ec 0c             	sub    $0xc,%esp
f01009c5:	8d 83 2c 8a f7 ff    	lea    -0x875d4(%ebx),%eax
f01009cb:	50                   	push   %eax
f01009cc:	e8 46 32 00 00       	call   f0103c17 <cprintf>
		return 0;
f01009d1:	83 c4 10             	add    $0x10,%esp
	}
	return 0;
}
f01009d4:	b8 00 00 00 00       	mov    $0x0,%eax
f01009d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009dc:	5b                   	pop    %ebx
f01009dd:	5e                   	pop    %esi
f01009de:	5f                   	pop    %edi
f01009df:	5d                   	pop    %ebp
f01009e0:	c3                   	ret    
		if (!pte) panic("boot_map_region panic, out of memory");
f01009e1:	83 ec 04             	sub    $0x4,%esp
f01009e4:	8d 83 5c 8a f7 ff    	lea    -0x875a4(%ebx),%eax
f01009ea:	50                   	push   %eax
f01009eb:	6a 75                	push   $0x75
f01009ed:	8d 83 8d 88 f7 ff    	lea    -0x87773(%ebx),%eax
f01009f3:	50                   	push   %eax
f01009f4:	e8 b8 f6 ff ff       	call   f01000b1 <_panic>
		} else cprintf("page not exist: %x\n", begin);
f01009f9:	83 ec 08             	sub    $0x8,%esp
f01009fc:	57                   	push   %edi
f01009fd:	ff 75 dc             	pushl  -0x24(%ebp)
f0100a00:	e8 12 32 00 00       	call   f0103c17 <cprintf>
f0100a05:	83 c4 10             	add    $0x10,%esp
	for (; begin <= end; begin += PGSIZE) {
f0100a08:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0100a0e:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0100a11:	77 c1                	ja     f01009d4 <showmappings+0x72>
		pte_t *pte = pgdir_walk(kern_pgdir, (void *) begin, 1);	//create
f0100a13:	83 ec 04             	sub    $0x4,%esp
f0100a16:	6a 01                	push   $0x1
f0100a18:	57                   	push   %edi
f0100a19:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a1c:	ff 30                	pushl  (%eax)
f0100a1e:	e8 6d 08 00 00       	call   f0101290 <pgdir_walk>
f0100a23:	89 c6                	mov    %eax,%esi
		if (!pte) panic("boot_map_region panic, out of memory");
f0100a25:	83 c4 10             	add    $0x10,%esp
f0100a28:	85 c0                	test   %eax,%eax
f0100a2a:	74 b5                	je     f01009e1 <showmappings+0x7f>
		if (*pte & PTE_P) {
f0100a2c:	f6 00 01             	testb  $0x1,(%eax)
f0100a2f:	74 c8                	je     f01009f9 <showmappings+0x97>
			cprintf("page %x with ", begin);
f0100a31:	83 ec 08             	sub    $0x8,%esp
f0100a34:	57                   	push   %edi
f0100a35:	8d 83 9c 88 f7 ff    	lea    -0x87764(%ebx),%eax
f0100a3b:	50                   	push   %eax
f0100a3c:	e8 d6 31 00 00       	call   f0103c17 <cprintf>
			pprint(pte);
f0100a41:	89 34 24             	mov    %esi,(%esp)
f0100a44:	e8 de fe ff ff       	call   f0100927 <pprint>
f0100a49:	83 c4 10             	add    $0x10,%esp
f0100a4c:	eb ba                	jmp    f0100a08 <showmappings+0xa6>

f0100a4e <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100a4e:	55                   	push   %ebp
f0100a4f:	89 e5                	mov    %esp,%ebp
f0100a51:	57                   	push   %edi
f0100a52:	56                   	push   %esi
f0100a53:	53                   	push   %ebx
f0100a54:	83 ec 68             	sub    $0x68,%esp
f0100a57:	e8 0b f7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100a5c:	81 c3 c4 c5 08 00    	add    $0x8c5c4,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100a62:	8d 83 84 8a f7 ff    	lea    -0x8757c(%ebx),%eax
f0100a68:	50                   	push   %eax
f0100a69:	e8 a9 31 00 00       	call   f0103c17 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100a6e:	8d 83 a8 8a f7 ff    	lea    -0x87558(%ebx),%eax
f0100a74:	89 04 24             	mov    %eax,(%esp)
f0100a77:	e8 9b 31 00 00       	call   f0103c17 <cprintf>

	if (tf != NULL)
f0100a7c:	83 c4 10             	add    $0x10,%esp
f0100a7f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100a83:	74 0e                	je     f0100a93 <monitor+0x45>
		print_trapframe(tf);
f0100a85:	83 ec 0c             	sub    $0xc,%esp
f0100a88:	ff 75 08             	pushl  0x8(%ebp)
f0100a8b:	e8 64 36 00 00       	call   f01040f4 <print_trapframe>
f0100a90:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100a93:	8d bb c2 88 f7 ff    	lea    -0x8773e(%ebx),%edi
f0100a99:	eb 4a                	jmp    f0100ae5 <monitor+0x97>
f0100a9b:	83 ec 08             	sub    $0x8,%esp
f0100a9e:	0f be c0             	movsbl %al,%eax
f0100aa1:	50                   	push   %eax
f0100aa2:	57                   	push   %edi
f0100aa3:	e8 6a 46 00 00       	call   f0105112 <strchr>
f0100aa8:	83 c4 10             	add    $0x10,%esp
f0100aab:	85 c0                	test   %eax,%eax
f0100aad:	74 08                	je     f0100ab7 <monitor+0x69>
			*buf++ = 0;
f0100aaf:	c6 06 00             	movb   $0x0,(%esi)
f0100ab2:	8d 76 01             	lea    0x1(%esi),%esi
f0100ab5:	eb 79                	jmp    f0100b30 <monitor+0xe2>
		if (*buf == 0)
f0100ab7:	80 3e 00             	cmpb   $0x0,(%esi)
f0100aba:	74 7f                	je     f0100b3b <monitor+0xed>
		if (argc == MAXARGS-1) {
f0100abc:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f0100ac0:	74 0f                	je     f0100ad1 <monitor+0x83>
		argv[argc++] = buf;
f0100ac2:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100ac5:	8d 48 01             	lea    0x1(%eax),%ecx
f0100ac8:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f0100acb:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f0100acf:	eb 44                	jmp    f0100b15 <monitor+0xc7>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100ad1:	83 ec 08             	sub    $0x8,%esp
f0100ad4:	6a 10                	push   $0x10
f0100ad6:	8d 83 c7 88 f7 ff    	lea    -0x87739(%ebx),%eax
f0100adc:	50                   	push   %eax
f0100add:	e8 35 31 00 00       	call   f0103c17 <cprintf>
f0100ae2:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100ae5:	8d 83 be 88 f7 ff    	lea    -0x87742(%ebx),%eax
f0100aeb:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100aee:	83 ec 0c             	sub    $0xc,%esp
f0100af1:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100af4:	e8 e1 43 00 00       	call   f0104eda <readline>
f0100af9:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f0100afb:	83 c4 10             	add    $0x10,%esp
f0100afe:	85 c0                	test   %eax,%eax
f0100b00:	74 ec                	je     f0100aee <monitor+0xa0>
	argv[argc] = 0;
f0100b02:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100b09:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0100b10:	eb 1e                	jmp    f0100b30 <monitor+0xe2>
			buf++;
f0100b12:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100b15:	0f b6 06             	movzbl (%esi),%eax
f0100b18:	84 c0                	test   %al,%al
f0100b1a:	74 14                	je     f0100b30 <monitor+0xe2>
f0100b1c:	83 ec 08             	sub    $0x8,%esp
f0100b1f:	0f be c0             	movsbl %al,%eax
f0100b22:	50                   	push   %eax
f0100b23:	57                   	push   %edi
f0100b24:	e8 e9 45 00 00       	call   f0105112 <strchr>
f0100b29:	83 c4 10             	add    $0x10,%esp
f0100b2c:	85 c0                	test   %eax,%eax
f0100b2e:	74 e2                	je     f0100b12 <monitor+0xc4>
		while (*buf && strchr(WHITESPACE, *buf))
f0100b30:	0f b6 06             	movzbl (%esi),%eax
f0100b33:	84 c0                	test   %al,%al
f0100b35:	0f 85 60 ff ff ff    	jne    f0100a9b <monitor+0x4d>
	argv[argc] = 0;
f0100b3b:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100b3e:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100b45:	00 
	if (argc == 0)
f0100b46:	85 c0                	test   %eax,%eax
f0100b48:	74 9b                	je     f0100ae5 <monitor+0x97>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100b4a:	83 ec 08             	sub    $0x8,%esp
f0100b4d:	8d 83 1e 88 f7 ff    	lea    -0x877e2(%ebx),%eax
f0100b53:	50                   	push   %eax
f0100b54:	ff 75 a8             	pushl  -0x58(%ebp)
f0100b57:	e8 58 45 00 00       	call   f01050b4 <strcmp>
f0100b5c:	83 c4 10             	add    $0x10,%esp
f0100b5f:	85 c0                	test   %eax,%eax
f0100b61:	74 38                	je     f0100b9b <monitor+0x14d>
f0100b63:	83 ec 08             	sub    $0x8,%esp
f0100b66:	8d 83 2c 88 f7 ff    	lea    -0x877d4(%ebx),%eax
f0100b6c:	50                   	push   %eax
f0100b6d:	ff 75 a8             	pushl  -0x58(%ebp)
f0100b70:	e8 3f 45 00 00       	call   f01050b4 <strcmp>
f0100b75:	83 c4 10             	add    $0x10,%esp
f0100b78:	85 c0                	test   %eax,%eax
f0100b7a:	74 1a                	je     f0100b96 <monitor+0x148>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100b7c:	83 ec 08             	sub    $0x8,%esp
f0100b7f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100b82:	8d 83 e4 88 f7 ff    	lea    -0x8771c(%ebx),%eax
f0100b88:	50                   	push   %eax
f0100b89:	e8 89 30 00 00       	call   f0103c17 <cprintf>
f0100b8e:	83 c4 10             	add    $0x10,%esp
f0100b91:	e9 4f ff ff ff       	jmp    f0100ae5 <monitor+0x97>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100b96:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100b9b:	83 ec 04             	sub    $0x4,%esp
f0100b9e:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100ba1:	ff 75 08             	pushl  0x8(%ebp)
f0100ba4:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100ba7:	52                   	push   %edx
f0100ba8:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100bab:	ff 94 83 18 20 00 00 	call   *0x2018(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100bb2:	83 c4 10             	add    $0x10,%esp
f0100bb5:	85 c0                	test   %eax,%eax
f0100bb7:	0f 89 28 ff ff ff    	jns    f0100ae5 <monitor+0x97>
				break;
	}
}
f0100bbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100bc0:	5b                   	pop    %ebx
f0100bc1:	5e                   	pop    %esi
f0100bc2:	5f                   	pop    %edi
f0100bc3:	5d                   	pop    %ebp
f0100bc4:	c3                   	ret    

f0100bc5 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100bc5:	55                   	push   %ebp
f0100bc6:	89 e5                	mov    %esp,%ebp
f0100bc8:	56                   	push   %esi
f0100bc9:	53                   	push   %ebx
f0100bca:	e8 98 f5 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100bcf:	81 c3 51 c4 08 00    	add    $0x8c451,%ebx
f0100bd5:	89 c6                	mov    %eax,%esi
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100bd7:	83 bb f8 22 00 00 00 	cmpl   $0x0,0x22f8(%ebx)
f0100bde:	74 4b                	je     f0100c2b <boot_alloc+0x66>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	cprintf("boot_alloc memory at %x\n", nextfree);
f0100be0:	83 ec 08             	sub    $0x8,%esp
f0100be3:	ff b3 f8 22 00 00    	pushl  0x22f8(%ebx)
f0100be9:	8d 83 cd 8a f7 ff    	lea    -0x87533(%ebx),%eax
f0100bef:	50                   	push   %eax
f0100bf0:	e8 22 30 00 00       	call   f0103c17 <cprintf>
	cprintf("Next memory at %x\n", ROUNDUP((char *) (nextfree+n), PGSIZE));
f0100bf5:	83 c4 08             	add    $0x8,%esp
f0100bf8:	89 f0                	mov    %esi,%eax
f0100bfa:	03 83 f8 22 00 00    	add    0x22f8(%ebx),%eax
f0100c00:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100c05:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c0a:	50                   	push   %eax
f0100c0b:	8d 83 e6 8a f7 ff    	lea    -0x8751a(%ebx),%eax
f0100c11:	50                   	push   %eax
f0100c12:	e8 00 30 00 00       	call   f0103c17 <cprintf>
	if (n != 0) {
f0100c17:	83 c4 10             	add    $0x10,%esp
f0100c1a:	85 f6                	test   %esi,%esi
f0100c1c:	75 25                	jne    f0100c43 <boot_alloc+0x7e>
		char *next = nextfree;
		nextfree = ROUNDUP((char *) (nextfree+n), PGSIZE);
		return next;
	} else return nextfree;
f0100c1e:	8b 83 f8 22 00 00    	mov    0x22f8(%ebx),%eax
	return NULL;
}
f0100c24:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100c27:	5b                   	pop    %ebx
f0100c28:	5e                   	pop    %esi
f0100c29:	5d                   	pop    %ebp
f0100c2a:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100c2b:	c7 c0 e0 ff 18 f0    	mov    $0xf018ffe0,%eax
f0100c31:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100c36:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c3b:	89 83 f8 22 00 00    	mov    %eax,0x22f8(%ebx)
f0100c41:	eb 9d                	jmp    f0100be0 <boot_alloc+0x1b>
		char *next = nextfree;
f0100c43:	8b 83 f8 22 00 00    	mov    0x22f8(%ebx),%eax
		nextfree = ROUNDUP((char *) (nextfree+n), PGSIZE);
f0100c49:	8d 94 30 ff 0f 00 00 	lea    0xfff(%eax,%esi,1),%edx
f0100c50:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100c56:	89 93 f8 22 00 00    	mov    %edx,0x22f8(%ebx)
		return next;
f0100c5c:	eb c6                	jmp    f0100c24 <boot_alloc+0x5f>

f0100c5e <nvram_read>:
{
f0100c5e:	55                   	push   %ebp
f0100c5f:	89 e5                	mov    %esp,%ebp
f0100c61:	57                   	push   %edi
f0100c62:	56                   	push   %esi
f0100c63:	53                   	push   %ebx
f0100c64:	83 ec 18             	sub    $0x18,%esp
f0100c67:	e8 fb f4 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100c6c:	81 c3 b4 c3 08 00    	add    $0x8c3b4,%ebx
f0100c72:	89 c7                	mov    %eax,%edi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100c74:	50                   	push   %eax
f0100c75:	e8 16 2f 00 00       	call   f0103b90 <mc146818_read>
f0100c7a:	89 c6                	mov    %eax,%esi
f0100c7c:	83 c7 01             	add    $0x1,%edi
f0100c7f:	89 3c 24             	mov    %edi,(%esp)
f0100c82:	e8 09 2f 00 00       	call   f0103b90 <mc146818_read>
f0100c87:	c1 e0 08             	shl    $0x8,%eax
f0100c8a:	09 f0                	or     %esi,%eax
}
f0100c8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c8f:	5b                   	pop    %ebx
f0100c90:	5e                   	pop    %esi
f0100c91:	5f                   	pop    %edi
f0100c92:	5d                   	pop    %ebp
f0100c93:	c3                   	ret    

f0100c94 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100c94:	55                   	push   %ebp
f0100c95:	89 e5                	mov    %esp,%ebp
f0100c97:	56                   	push   %esi
f0100c98:	53                   	push   %ebx
f0100c99:	e8 57 27 00 00       	call   f01033f5 <__x86.get_pc_thunk.cx>
f0100c9e:	81 c1 82 c3 08 00    	add    $0x8c382,%ecx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100ca4:	89 d3                	mov    %edx,%ebx
f0100ca6:	c1 eb 16             	shr    $0x16,%ebx
	if (!(*pgdir & PTE_P))
f0100ca9:	8b 04 98             	mov    (%eax,%ebx,4),%eax
f0100cac:	a8 01                	test   $0x1,%al
f0100cae:	74 5a                	je     f0100d0a <check_va2pa+0x76>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100cb0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100cb5:	89 c6                	mov    %eax,%esi
f0100cb7:	c1 ee 0c             	shr    $0xc,%esi
f0100cba:	c7 c3 e8 ff 18 f0    	mov    $0xf018ffe8,%ebx
f0100cc0:	3b 33                	cmp    (%ebx),%esi
f0100cc2:	73 2b                	jae    f0100cef <check_va2pa+0x5b>
	if (!(p[PTX(va)] & PTE_P))
f0100cc4:	c1 ea 0c             	shr    $0xc,%edx
f0100cc7:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100ccd:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100cd4:	89 c2                	mov    %eax,%edx
f0100cd6:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100cd9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100cde:	85 d2                	test   %edx,%edx
f0100ce0:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100ce5:	0f 44 c2             	cmove  %edx,%eax
}
f0100ce8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ceb:	5b                   	pop    %ebx
f0100cec:	5e                   	pop    %esi
f0100ced:	5d                   	pop    %ebp
f0100cee:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cef:	50                   	push   %eax
f0100cf0:	8d 81 00 8e f7 ff    	lea    -0x87200(%ecx),%eax
f0100cf6:	50                   	push   %eax
f0100cf7:	68 2f 03 00 00       	push   $0x32f
f0100cfc:	8d 81 f9 8a f7 ff    	lea    -0x87507(%ecx),%eax
f0100d02:	50                   	push   %eax
f0100d03:	89 cb                	mov    %ecx,%ebx
f0100d05:	e8 a7 f3 ff ff       	call   f01000b1 <_panic>
		return ~0;
f0100d0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d0f:	eb d7                	jmp    f0100ce8 <check_va2pa+0x54>

f0100d11 <check_page_free_list>:
{
f0100d11:	55                   	push   %ebp
f0100d12:	89 e5                	mov    %esp,%ebp
f0100d14:	57                   	push   %edi
f0100d15:	56                   	push   %esi
f0100d16:	53                   	push   %ebx
f0100d17:	83 ec 3c             	sub    $0x3c,%esp
f0100d1a:	e8 da 26 00 00       	call   f01033f9 <__x86.get_pc_thunk.di>
f0100d1f:	81 c7 01 c3 08 00    	add    $0x8c301,%edi
f0100d25:	89 7d c4             	mov    %edi,-0x3c(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d28:	84 c0                	test   %al,%al
f0100d2a:	0f 85 dd 02 00 00    	jne    f010100d <check_page_free_list+0x2fc>
	if (!page_free_list)
f0100d30:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100d33:	83 b8 00 23 00 00 00 	cmpl   $0x0,0x2300(%eax)
f0100d3a:	74 0c                	je     f0100d48 <check_page_free_list+0x37>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d3c:	c7 45 d4 00 04 00 00 	movl   $0x400,-0x2c(%ebp)
f0100d43:	e9 2f 03 00 00       	jmp    f0101077 <check_page_free_list+0x366>
		panic("'page_free_list' is a null pointer!");
f0100d48:	83 ec 04             	sub    $0x4,%esp
f0100d4b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d4e:	8d 83 24 8e f7 ff    	lea    -0x871dc(%ebx),%eax
f0100d54:	50                   	push   %eax
f0100d55:	68 6b 02 00 00       	push   $0x26b
f0100d5a:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0100d60:	50                   	push   %eax
f0100d61:	e8 4b f3 ff ff       	call   f01000b1 <_panic>
f0100d66:	50                   	push   %eax
f0100d67:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d6a:	8d 83 00 8e f7 ff    	lea    -0x87200(%ebx),%eax
f0100d70:	50                   	push   %eax
f0100d71:	6a 56                	push   $0x56
f0100d73:	8d 83 05 8b f7 ff    	lea    -0x874fb(%ebx),%eax
f0100d79:	50                   	push   %eax
f0100d7a:	e8 32 f3 ff ff       	call   f01000b1 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d7f:	8b 36                	mov    (%esi),%esi
f0100d81:	85 f6                	test   %esi,%esi
f0100d83:	74 40                	je     f0100dc5 <check_page_free_list+0xb4>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d85:	89 f0                	mov    %esi,%eax
f0100d87:	2b 07                	sub    (%edi),%eax
f0100d89:	c1 f8 03             	sar    $0x3,%eax
f0100d8c:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100d8f:	89 c2                	mov    %eax,%edx
f0100d91:	c1 ea 16             	shr    $0x16,%edx
f0100d94:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100d97:	73 e6                	jae    f0100d7f <check_page_free_list+0x6e>
	if (PGNUM(pa) >= npages)
f0100d99:	89 c2                	mov    %eax,%edx
f0100d9b:	c1 ea 0c             	shr    $0xc,%edx
f0100d9e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100da1:	3b 11                	cmp    (%ecx),%edx
f0100da3:	73 c1                	jae    f0100d66 <check_page_free_list+0x55>
			memset(page2kva(pp), 0x97, 128);
f0100da5:	83 ec 04             	sub    $0x4,%esp
f0100da8:	68 80 00 00 00       	push   $0x80
f0100dad:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100db2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100db7:	50                   	push   %eax
f0100db8:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100dbb:	e8 8f 43 00 00       	call   f010514f <memset>
f0100dc0:	83 c4 10             	add    $0x10,%esp
f0100dc3:	eb ba                	jmp    f0100d7f <check_page_free_list+0x6e>
	first_free_page = (char *) boot_alloc(0);
f0100dc5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dca:	e8 f6 fd ff ff       	call   f0100bc5 <boot_alloc>
f0100dcf:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100dd2:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100dd5:	8b 97 00 23 00 00    	mov    0x2300(%edi),%edx
		assert(pp >= pages);
f0100ddb:	c7 c0 f0 ff 18 f0    	mov    $0xf018fff0,%eax
f0100de1:	8b 08                	mov    (%eax),%ecx
		assert(pp < pages + npages);
f0100de3:	c7 c0 e8 ff 18 f0    	mov    $0xf018ffe8,%eax
f0100de9:	8b 00                	mov    (%eax),%eax
f0100deb:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100dee:	8d 1c c1             	lea    (%ecx,%eax,8),%ebx
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100df1:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0100df4:	bf 00 00 00 00       	mov    $0x0,%edi
f0100df9:	89 75 d0             	mov    %esi,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100dfc:	e9 08 01 00 00       	jmp    f0100f09 <check_page_free_list+0x1f8>
		assert(pp >= pages);
f0100e01:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e04:	8d 83 13 8b f7 ff    	lea    -0x874ed(%ebx),%eax
f0100e0a:	50                   	push   %eax
f0100e0b:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0100e11:	50                   	push   %eax
f0100e12:	68 85 02 00 00       	push   $0x285
f0100e17:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0100e1d:	50                   	push   %eax
f0100e1e:	e8 8e f2 ff ff       	call   f01000b1 <_panic>
		assert(pp < pages + npages);
f0100e23:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e26:	8d 83 34 8b f7 ff    	lea    -0x874cc(%ebx),%eax
f0100e2c:	50                   	push   %eax
f0100e2d:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0100e33:	50                   	push   %eax
f0100e34:	68 86 02 00 00       	push   $0x286
f0100e39:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0100e3f:	50                   	push   %eax
f0100e40:	e8 6c f2 ff ff       	call   f01000b1 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100e45:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e48:	8d 83 48 8e f7 ff    	lea    -0x871b8(%ebx),%eax
f0100e4e:	50                   	push   %eax
f0100e4f:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0100e55:	50                   	push   %eax
f0100e56:	68 87 02 00 00       	push   $0x287
f0100e5b:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0100e61:	50                   	push   %eax
f0100e62:	e8 4a f2 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != 0);
f0100e67:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e6a:	8d 83 48 8b f7 ff    	lea    -0x874b8(%ebx),%eax
f0100e70:	50                   	push   %eax
f0100e71:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0100e77:	50                   	push   %eax
f0100e78:	68 8a 02 00 00       	push   $0x28a
f0100e7d:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0100e83:	50                   	push   %eax
f0100e84:	e8 28 f2 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100e89:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e8c:	8d 83 59 8b f7 ff    	lea    -0x874a7(%ebx),%eax
f0100e92:	50                   	push   %eax
f0100e93:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0100e99:	50                   	push   %eax
f0100e9a:	68 8b 02 00 00       	push   $0x28b
f0100e9f:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0100ea5:	50                   	push   %eax
f0100ea6:	e8 06 f2 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100eab:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100eae:	8d 83 7c 8e f7 ff    	lea    -0x87184(%ebx),%eax
f0100eb4:	50                   	push   %eax
f0100eb5:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0100ebb:	50                   	push   %eax
f0100ebc:	68 8c 02 00 00       	push   $0x28c
f0100ec1:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0100ec7:	50                   	push   %eax
f0100ec8:	e8 e4 f1 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ecd:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100ed0:	8d 83 72 8b f7 ff    	lea    -0x8748e(%ebx),%eax
f0100ed6:	50                   	push   %eax
f0100ed7:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0100edd:	50                   	push   %eax
f0100ede:	68 8d 02 00 00       	push   $0x28d
f0100ee3:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0100ee9:	50                   	push   %eax
f0100eea:	e8 c2 f1 ff ff       	call   f01000b1 <_panic>
	if (PGNUM(pa) >= npages)
f0100eef:	89 c6                	mov    %eax,%esi
f0100ef1:	c1 ee 0c             	shr    $0xc,%esi
f0100ef4:	39 75 cc             	cmp    %esi,-0x34(%ebp)
f0100ef7:	76 70                	jbe    f0100f69 <check_page_free_list+0x258>
	return (void *)(pa + KERNBASE);
f0100ef9:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100efe:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100f01:	77 7f                	ja     f0100f82 <check_page_free_list+0x271>
			++nfree_extmem;
f0100f03:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f07:	8b 12                	mov    (%edx),%edx
f0100f09:	85 d2                	test   %edx,%edx
f0100f0b:	0f 84 93 00 00 00    	je     f0100fa4 <check_page_free_list+0x293>
		assert(pp >= pages);
f0100f11:	39 d1                	cmp    %edx,%ecx
f0100f13:	0f 87 e8 fe ff ff    	ja     f0100e01 <check_page_free_list+0xf0>
		assert(pp < pages + npages);
f0100f19:	39 d3                	cmp    %edx,%ebx
f0100f1b:	0f 86 02 ff ff ff    	jbe    f0100e23 <check_page_free_list+0x112>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100f21:	89 d0                	mov    %edx,%eax
f0100f23:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100f26:	a8 07                	test   $0x7,%al
f0100f28:	0f 85 17 ff ff ff    	jne    f0100e45 <check_page_free_list+0x134>
	return (pp - pages) << PGSHIFT;
f0100f2e:	c1 f8 03             	sar    $0x3,%eax
f0100f31:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0100f34:	85 c0                	test   %eax,%eax
f0100f36:	0f 84 2b ff ff ff    	je     f0100e67 <check_page_free_list+0x156>
		assert(page2pa(pp) != IOPHYSMEM);
f0100f3c:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100f41:	0f 84 42 ff ff ff    	je     f0100e89 <check_page_free_list+0x178>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100f47:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100f4c:	0f 84 59 ff ff ff    	je     f0100eab <check_page_free_list+0x19a>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100f52:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100f57:	0f 84 70 ff ff ff    	je     f0100ecd <check_page_free_list+0x1bc>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100f5d:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100f62:	77 8b                	ja     f0100eef <check_page_free_list+0x1de>
			++nfree_basemem;
f0100f64:	83 c7 01             	add    $0x1,%edi
f0100f67:	eb 9e                	jmp    f0100f07 <check_page_free_list+0x1f6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f69:	50                   	push   %eax
f0100f6a:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100f6d:	8d 83 00 8e f7 ff    	lea    -0x87200(%ebx),%eax
f0100f73:	50                   	push   %eax
f0100f74:	6a 56                	push   $0x56
f0100f76:	8d 83 05 8b f7 ff    	lea    -0x874fb(%ebx),%eax
f0100f7c:	50                   	push   %eax
f0100f7d:	e8 2f f1 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100f82:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100f85:	8d 83 a0 8e f7 ff    	lea    -0x87160(%ebx),%eax
f0100f8b:	50                   	push   %eax
f0100f8c:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0100f92:	50                   	push   %eax
f0100f93:	68 8e 02 00 00       	push   $0x28e
f0100f98:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0100f9e:	50                   	push   %eax
f0100f9f:	e8 0d f1 ff ff       	call   f01000b1 <_panic>
f0100fa4:	8b 75 d0             	mov    -0x30(%ebp),%esi
	assert(nfree_basemem > 0);
f0100fa7:	85 ff                	test   %edi,%edi
f0100fa9:	7e 1e                	jle    f0100fc9 <check_page_free_list+0x2b8>
	assert(nfree_extmem > 0);
f0100fab:	85 f6                	test   %esi,%esi
f0100fad:	7e 3c                	jle    f0100feb <check_page_free_list+0x2da>
	cprintf("check_page_free_list() succeeded!\n");
f0100faf:	83 ec 0c             	sub    $0xc,%esp
f0100fb2:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100fb5:	8d 83 e8 8e f7 ff    	lea    -0x87118(%ebx),%eax
f0100fbb:	50                   	push   %eax
f0100fbc:	e8 56 2c 00 00       	call   f0103c17 <cprintf>
}
f0100fc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fc4:	5b                   	pop    %ebx
f0100fc5:	5e                   	pop    %esi
f0100fc6:	5f                   	pop    %edi
f0100fc7:	5d                   	pop    %ebp
f0100fc8:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100fc9:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100fcc:	8d 83 8c 8b f7 ff    	lea    -0x87474(%ebx),%eax
f0100fd2:	50                   	push   %eax
f0100fd3:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0100fd9:	50                   	push   %eax
f0100fda:	68 96 02 00 00       	push   $0x296
f0100fdf:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0100fe5:	50                   	push   %eax
f0100fe6:	e8 c6 f0 ff ff       	call   f01000b1 <_panic>
	assert(nfree_extmem > 0);
f0100feb:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100fee:	8d 83 9e 8b f7 ff    	lea    -0x87462(%ebx),%eax
f0100ff4:	50                   	push   %eax
f0100ff5:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0100ffb:	50                   	push   %eax
f0100ffc:	68 97 02 00 00       	push   $0x297
f0101001:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0101007:	50                   	push   %eax
f0101008:	e8 a4 f0 ff ff       	call   f01000b1 <_panic>
	if (!page_free_list)
f010100d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0101010:	8b 80 00 23 00 00    	mov    0x2300(%eax),%eax
f0101016:	85 c0                	test   %eax,%eax
f0101018:	0f 84 2a fd ff ff    	je     f0100d48 <check_page_free_list+0x37>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f010101e:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0101021:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101024:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0101027:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f010102a:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010102d:	c7 c3 f0 ff 18 f0    	mov    $0xf018fff0,%ebx
f0101033:	89 c2                	mov    %eax,%edx
f0101035:	2b 13                	sub    (%ebx),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101037:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f010103d:	0f 95 c2             	setne  %dl
f0101040:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0101043:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0101047:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0101049:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f010104d:	8b 00                	mov    (%eax),%eax
f010104f:	85 c0                	test   %eax,%eax
f0101051:	75 e0                	jne    f0101033 <check_page_free_list+0x322>
		*tp[1] = 0;
f0101053:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101056:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f010105c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010105f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101062:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101064:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101067:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010106a:	89 87 00 23 00 00    	mov    %eax,0x2300(%edi)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101070:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101077:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010107a:	8b b0 00 23 00 00    	mov    0x2300(%eax),%esi
f0101080:	c7 c7 f0 ff 18 f0    	mov    $0xf018fff0,%edi
	if (PGNUM(pa) >= npages)
f0101086:	c7 c0 e8 ff 18 f0    	mov    $0xf018ffe8,%eax
f010108c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010108f:	e9 ed fc ff ff       	jmp    f0100d81 <check_page_free_list+0x70>

f0101094 <page_init>:
{
f0101094:	55                   	push   %ebp
f0101095:	89 e5                	mov    %esp,%ebp
f0101097:	57                   	push   %edi
f0101098:	56                   	push   %esi
f0101099:	53                   	push   %ebx
f010109a:	83 ec 2c             	sub    $0x2c,%esp
f010109d:	e8 c5 f0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01010a2:	81 c3 7e bf 08 00    	add    $0x8bf7e,%ebx
	page_free_list = NULL;
f01010a8:	c7 83 00 23 00 00 00 	movl   $0x0,0x2300(%ebx)
f01010af:	00 00 00 
	int num_alloc = ((uint32_t)boot_alloc(0) - KERNBASE) / PGSIZE;
f01010b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01010b7:	e8 09 fb ff ff       	call   f0100bc5 <boot_alloc>
	    else if(i >= npages_basemem && i < npages_basemem + num_iohole + num_alloc)
f01010bc:	8b 93 04 23 00 00    	mov    0x2304(%ebx),%edx
f01010c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	int num_alloc = ((uint32_t)boot_alloc(0) - KERNBASE) / PGSIZE;
f01010c5:	05 00 00 00 10       	add    $0x10000000,%eax
f01010ca:	c1 e8 0c             	shr    $0xc,%eax
	    else if(i >= npages_basemem && i < npages_basemem + num_iohole + num_alloc)
f01010cd:	8d 44 02 60          	lea    0x60(%edx,%eax,1),%eax
f01010d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01010d4:	8b 83 00 23 00 00    	mov    0x2300(%ebx),%eax
f01010da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<npages; i++)
f01010dd:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01010e7:	c7 c2 e8 ff 18 f0    	mov    $0xf018ffe8,%edx
		pages[i].pp_ref = 0;
f01010ed:	c7 c7 f0 ff 18 f0    	mov    $0xf018fff0,%edi
f01010f3:	89 7d e0             	mov    %edi,-0x20(%ebp)
		pages[i].pp_ref = 1;
f01010f6:	89 7d d0             	mov    %edi,-0x30(%ebp)
		pages[i].pp_ref = 1;
f01010f9:	89 7d d8             	mov    %edi,-0x28(%ebp)
	for(i=0; i<npages; i++)
f01010fc:	eb 43                	jmp    f0101141 <page_init+0xad>
	    else if(i >= npages_basemem && i < npages_basemem + num_iohole + num_alloc)
f01010fe:	39 45 dc             	cmp    %eax,-0x24(%ebp)
f0101101:	77 13                	ja     f0101116 <page_init+0x82>
f0101103:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101106:	76 0e                	jbe    f0101116 <page_init+0x82>
		pages[i].pp_ref = 1;
f0101108:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010110b:	8b 36                	mov    (%esi),%esi
f010110d:	66 c7 44 c6 04 01 00 	movw   $0x1,0x4(%esi,%eax,8)
f0101114:	eb 28                	jmp    f010113e <page_init+0xaa>
f0101116:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
		pages[i].pp_ref = 0;
f010111d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0101120:	89 cf                	mov    %ecx,%edi
f0101122:	03 3e                	add    (%esi),%edi
f0101124:	89 fe                	mov    %edi,%esi
f0101126:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
		pages[i].pp_link = page_free_list;
f010112c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010112f:	89 3e                	mov    %edi,(%esi)
		page_free_list = &pages[i];
f0101131:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0101134:	03 0e                	add    (%esi),%ecx
f0101136:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0101139:	b9 01 00 00 00       	mov    $0x1,%ecx
	for(i=0; i<npages; i++)
f010113e:	83 c0 01             	add    $0x1,%eax
f0101141:	39 02                	cmp    %eax,(%edx)
f0101143:	76 11                	jbe    f0101156 <page_init+0xc2>
	    if(i==0)
f0101145:	85 c0                	test   %eax,%eax
f0101147:	75 b5                	jne    f01010fe <page_init+0x6a>
		pages[i].pp_ref = 1;
f0101149:	8b 7d d8             	mov    -0x28(%ebp),%edi
f010114c:	8b 37                	mov    (%edi),%esi
f010114e:	66 c7 46 04 01 00    	movw   $0x1,0x4(%esi)
f0101154:	eb e8                	jmp    f010113e <page_init+0xaa>
f0101156:	84 c9                	test   %cl,%cl
f0101158:	75 08                	jne    f0101162 <page_init+0xce>
}
f010115a:	83 c4 2c             	add    $0x2c,%esp
f010115d:	5b                   	pop    %ebx
f010115e:	5e                   	pop    %esi
f010115f:	5f                   	pop    %edi
f0101160:	5d                   	pop    %ebp
f0101161:	c3                   	ret    
f0101162:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101165:	89 83 00 23 00 00    	mov    %eax,0x2300(%ebx)
f010116b:	eb ed                	jmp    f010115a <page_init+0xc6>

f010116d <page_alloc>:
{
f010116d:	55                   	push   %ebp
f010116e:	89 e5                	mov    %esp,%ebp
f0101170:	56                   	push   %esi
f0101171:	53                   	push   %ebx
f0101172:	e8 f0 ef ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0101177:	81 c3 a9 be 08 00    	add    $0x8bea9,%ebx
    if (page_free_list == NULL)
f010117d:	8b b3 00 23 00 00    	mov    0x2300(%ebx),%esi
f0101183:	85 f6                	test   %esi,%esi
f0101185:	74 14                	je     f010119b <page_alloc+0x2e>
      page_free_list = result->pp_link;
f0101187:	8b 06                	mov    (%esi),%eax
f0101189:	89 83 00 23 00 00    	mov    %eax,0x2300(%ebx)
      result->pp_link = NULL;
f010118f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (alloc_flags & ALLOC_ZERO)
f0101195:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101199:	75 09                	jne    f01011a4 <page_alloc+0x37>
}
f010119b:	89 f0                	mov    %esi,%eax
f010119d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01011a0:	5b                   	pop    %ebx
f01011a1:	5e                   	pop    %esi
f01011a2:	5d                   	pop    %ebp
f01011a3:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f01011a4:	c7 c0 f0 ff 18 f0    	mov    $0xf018fff0,%eax
f01011aa:	89 f2                	mov    %esi,%edx
f01011ac:	2b 10                	sub    (%eax),%edx
f01011ae:	89 d0                	mov    %edx,%eax
f01011b0:	c1 f8 03             	sar    $0x3,%eax
f01011b3:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01011b6:	89 c1                	mov    %eax,%ecx
f01011b8:	c1 e9 0c             	shr    $0xc,%ecx
f01011bb:	c7 c2 e8 ff 18 f0    	mov    $0xf018ffe8,%edx
f01011c1:	3b 0a                	cmp    (%edx),%ecx
f01011c3:	73 1a                	jae    f01011df <page_alloc+0x72>
        memset(page2kva(result), 0, PGSIZE); 
f01011c5:	83 ec 04             	sub    $0x4,%esp
f01011c8:	68 00 10 00 00       	push   $0x1000
f01011cd:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01011cf:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01011d4:	50                   	push   %eax
f01011d5:	e8 75 3f 00 00       	call   f010514f <memset>
f01011da:	83 c4 10             	add    $0x10,%esp
f01011dd:	eb bc                	jmp    f010119b <page_alloc+0x2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011df:	50                   	push   %eax
f01011e0:	8d 83 00 8e f7 ff    	lea    -0x87200(%ebx),%eax
f01011e6:	50                   	push   %eax
f01011e7:	6a 56                	push   $0x56
f01011e9:	8d 83 05 8b f7 ff    	lea    -0x874fb(%ebx),%eax
f01011ef:	50                   	push   %eax
f01011f0:	e8 bc ee ff ff       	call   f01000b1 <_panic>

f01011f5 <page_free>:
{
f01011f5:	55                   	push   %ebp
f01011f6:	89 e5                	mov    %esp,%ebp
f01011f8:	53                   	push   %ebx
f01011f9:	83 ec 04             	sub    $0x4,%esp
f01011fc:	e8 66 ef ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0101201:	81 c3 1f be 08 00    	add    $0x8be1f,%ebx
f0101207:	8b 45 08             	mov    0x8(%ebp),%eax
      assert(pp->pp_ref == 0);
f010120a:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010120f:	75 18                	jne    f0101229 <page_free+0x34>
      assert(pp->pp_link == NULL);
f0101211:	83 38 00             	cmpl   $0x0,(%eax)
f0101214:	75 32                	jne    f0101248 <page_free+0x53>
      pp->pp_link = page_free_list;
f0101216:	8b 8b 00 23 00 00    	mov    0x2300(%ebx),%ecx
f010121c:	89 08                	mov    %ecx,(%eax)
      page_free_list = pp;
f010121e:	89 83 00 23 00 00    	mov    %eax,0x2300(%ebx)
}
f0101224:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101227:	c9                   	leave  
f0101228:	c3                   	ret    
      assert(pp->pp_ref == 0);
f0101229:	8d 83 af 8b f7 ff    	lea    -0x87451(%ebx),%eax
f010122f:	50                   	push   %eax
f0101230:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0101236:	50                   	push   %eax
f0101237:	68 55 01 00 00       	push   $0x155
f010123c:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0101242:	50                   	push   %eax
f0101243:	e8 69 ee ff ff       	call   f01000b1 <_panic>
      assert(pp->pp_link == NULL);
f0101248:	8d 83 bf 8b f7 ff    	lea    -0x87441(%ebx),%eax
f010124e:	50                   	push   %eax
f010124f:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0101255:	50                   	push   %eax
f0101256:	68 56 01 00 00       	push   $0x156
f010125b:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0101261:	50                   	push   %eax
f0101262:	e8 4a ee ff ff       	call   f01000b1 <_panic>

f0101267 <page_decref>:
{
f0101267:	55                   	push   %ebp
f0101268:	89 e5                	mov    %esp,%ebp
f010126a:	83 ec 08             	sub    $0x8,%esp
f010126d:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101270:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101274:	83 e8 01             	sub    $0x1,%eax
f0101277:	66 89 42 04          	mov    %ax,0x4(%edx)
f010127b:	66 85 c0             	test   %ax,%ax
f010127e:	74 02                	je     f0101282 <page_decref+0x1b>
}
f0101280:	c9                   	leave  
f0101281:	c3                   	ret    
		page_free(pp);
f0101282:	83 ec 0c             	sub    $0xc,%esp
f0101285:	52                   	push   %edx
f0101286:	e8 6a ff ff ff       	call   f01011f5 <page_free>
f010128b:	83 c4 10             	add    $0x10,%esp
}
f010128e:	eb f0                	jmp    f0101280 <page_decref+0x19>

f0101290 <pgdir_walk>:
{
f0101290:	55                   	push   %ebp
f0101291:	89 e5                	mov    %esp,%ebp
f0101293:	57                   	push   %edi
f0101294:	56                   	push   %esi
f0101295:	53                   	push   %ebx
f0101296:	83 ec 0c             	sub    $0xc,%esp
f0101299:	e8 c9 ee ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010129e:	81 c3 82 bd 08 00    	add    $0x8bd82,%ebx
f01012a4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int dir_index = PDX(va), page_off = PTX(va);
f01012a7:	89 f7                	mov    %esi,%edi
f01012a9:	c1 ef 0c             	shr    $0xc,%edi
f01012ac:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
f01012b2:	c1 ee 16             	shr    $0x16,%esi
	if(!(pgdir[dir_index]&PTE_P)){
f01012b5:	c1 e6 02             	shl    $0x2,%esi
f01012b8:	03 75 08             	add    0x8(%ebp),%esi
f01012bb:	f6 06 01             	testb  $0x1,(%esi)
f01012be:	75 2f                	jne    f01012ef <pgdir_walk+0x5f>
		if(create){
f01012c0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01012c4:	74 67                	je     f010132d <pgdir_walk+0x9d>
			struct PageInfo *newpg = page_alloc(ALLOC_ZERO);
f01012c6:	83 ec 0c             	sub    $0xc,%esp
f01012c9:	6a 01                	push   $0x1
f01012cb:	e8 9d fe ff ff       	call   f010116d <page_alloc>
			if(!newpg)
f01012d0:	83 c4 10             	add    $0x10,%esp
f01012d3:	85 c0                	test   %eax,%eax
f01012d5:	74 5d                	je     f0101334 <pgdir_walk+0xa4>
			newpg->pp_ref ++;
f01012d7:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f01012dc:	c7 c2 f0 ff 18 f0    	mov    $0xf018fff0,%edx
f01012e2:	2b 02                	sub    (%edx),%eax
f01012e4:	c1 f8 03             	sar    $0x3,%eax
f01012e7:	c1 e0 0c             	shl    $0xc,%eax
			pgdir[dir_index] = page2pa(newpg)| PTE_U | PTE_P| PTE_W;
f01012ea:	83 c8 07             	or     $0x7,%eax
f01012ed:	89 06                	mov    %eax,(%esi)
	pte_t *page_base = KADDR(PTE_ADDR(pgdir[dir_index]));
f01012ef:	8b 06                	mov    (%esi),%eax
f01012f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01012f6:	89 c1                	mov    %eax,%ecx
f01012f8:	c1 e9 0c             	shr    $0xc,%ecx
f01012fb:	c7 c2 e8 ff 18 f0    	mov    $0xf018ffe8,%edx
f0101301:	3b 0a                	cmp    (%edx),%ecx
f0101303:	73 0f                	jae    f0101314 <pgdir_walk+0x84>
	return &page_base[page_off];
f0101305:	8d 84 b8 00 00 00 f0 	lea    -0x10000000(%eax,%edi,4),%eax
}
f010130c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010130f:	5b                   	pop    %ebx
f0101310:	5e                   	pop    %esi
f0101311:	5f                   	pop    %edi
f0101312:	5d                   	pop    %ebp
f0101313:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101314:	50                   	push   %eax
f0101315:	8d 83 00 8e f7 ff    	lea    -0x87200(%ebx),%eax
f010131b:	50                   	push   %eax
f010131c:	68 8b 01 00 00       	push   $0x18b
f0101321:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0101327:	50                   	push   %eax
f0101328:	e8 84 ed ff ff       	call   f01000b1 <_panic>
			}else return NULL;
f010132d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101332:	eb d8                	jmp    f010130c <pgdir_walk+0x7c>
				return NULL;//分配失败
f0101334:	b8 00 00 00 00       	mov    $0x0,%eax
f0101339:	eb d1                	jmp    f010130c <pgdir_walk+0x7c>

f010133b <boot_map_region>:
{
f010133b:	55                   	push   %ebp
f010133c:	89 e5                	mov    %esp,%ebp
f010133e:	57                   	push   %edi
f010133f:	56                   	push   %esi
f0101340:	53                   	push   %ebx
f0101341:	83 ec 1c             	sub    $0x1c,%esp
f0101344:	e8 b0 20 00 00       	call   f01033f9 <__x86.get_pc_thunk.di>
f0101349:	81 c7 d7 bc 08 00    	add    $0x8bcd7,%edi
f010134f:	89 7d d8             	mov    %edi,-0x28(%ebp)
f0101352:	89 c7                	mov    %eax,%edi
f0101354:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101357:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for(i=0; i<size; i+=PGSIZE){
f010135a:	bb 00 00 00 00       	mov    $0x0,%ebx
		*entry = (pa|perm|PTE_P);
f010135f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101362:	83 c8 01             	or     $0x1,%eax
f0101365:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101368:	89 de                	mov    %ebx,%esi
f010136a:	03 75 08             	add    0x8(%ebp),%esi
	for(i=0; i<size; i+=PGSIZE){
f010136d:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0101370:	76 43                	jbe    f01013b5 <boot_map_region+0x7a>
		entry = pgdir_walk(pgdir,(void *)va, 1);
f0101372:	83 ec 04             	sub    $0x4,%esp
f0101375:	6a 01                	push   $0x1
f0101377:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010137a:	01 d8                	add    %ebx,%eax
f010137c:	50                   	push   %eax
f010137d:	57                   	push   %edi
f010137e:	e8 0d ff ff ff       	call   f0101290 <pgdir_walk>
		if(!entry) panic("boot_map_region panic, out of memory");
f0101383:	83 c4 10             	add    $0x10,%esp
f0101386:	85 c0                	test   %eax,%eax
f0101388:	74 0d                	je     f0101397 <boot_map_region+0x5c>
		*entry = (pa|perm|PTE_P);
f010138a:	0b 75 dc             	or     -0x24(%ebp),%esi
f010138d:	89 30                	mov    %esi,(%eax)
	for(i=0; i<size; i+=PGSIZE){
f010138f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101395:	eb d1                	jmp    f0101368 <boot_map_region+0x2d>
		if(!entry) panic("boot_map_region panic, out of memory");
f0101397:	83 ec 04             	sub    $0x4,%esp
f010139a:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f010139d:	8d 83 5c 8a f7 ff    	lea    -0x875a4(%ebx),%eax
f01013a3:	50                   	push   %eax
f01013a4:	68 a5 01 00 00       	push   $0x1a5
f01013a9:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01013af:	50                   	push   %eax
f01013b0:	e8 fc ec ff ff       	call   f01000b1 <_panic>
}
f01013b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01013b8:	5b                   	pop    %ebx
f01013b9:	5e                   	pop    %esi
f01013ba:	5f                   	pop    %edi
f01013bb:	5d                   	pop    %ebp
f01013bc:	c3                   	ret    

f01013bd <page_lookup>:
{
f01013bd:	55                   	push   %ebp
f01013be:	89 e5                	mov    %esp,%ebp
f01013c0:	56                   	push   %esi
f01013c1:	53                   	push   %ebx
f01013c2:	e8 a0 ed ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01013c7:	81 c3 59 bc 08 00    	add    $0x8bc59,%ebx
f01013cd:	8b 75 10             	mov    0x10(%ebp),%esi
	pte_t *entry = pgdir_walk(pgdir, va, 0);
f01013d0:	83 ec 04             	sub    $0x4,%esp
f01013d3:	6a 00                	push   $0x0
f01013d5:	ff 75 0c             	pushl  0xc(%ebp)
f01013d8:	ff 75 08             	pushl  0x8(%ebp)
f01013db:	e8 b0 fe ff ff       	call   f0101290 <pgdir_walk>
	if(!(*entry) &PTE_P) 
f01013e0:	8b 10                	mov    (%eax),%edx
	if(!entry) 
f01013e2:	83 c4 10             	add    $0x10,%esp
f01013e5:	85 c0                	test   %eax,%eax
f01013e7:	74 43                	je     f010142c <page_lookup+0x6f>
f01013e9:	89 c1                	mov    %eax,%ecx
f01013eb:	85 d2                	test   %edx,%edx
f01013ed:	74 3d                	je     f010142c <page_lookup+0x6f>
f01013ef:	c1 ea 0c             	shr    $0xc,%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013f2:	c7 c0 e8 ff 18 f0    	mov    $0xf018ffe8,%eax
f01013f8:	39 10                	cmp    %edx,(%eax)
f01013fa:	76 18                	jbe    f0101414 <page_lookup+0x57>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01013fc:	c7 c0 f0 ff 18 f0    	mov    $0xf018fff0,%eax
f0101402:	8b 00                	mov    (%eax),%eax
f0101404:	8d 04 d0             	lea    (%eax,%edx,8),%eax
	if(pte_store!=NULL)
f0101407:	85 f6                	test   %esi,%esi
f0101409:	74 02                	je     f010140d <page_lookup+0x50>
		*pte_store = entry;
f010140b:	89 0e                	mov    %ecx,(%esi)
}
f010140d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101410:	5b                   	pop    %ebx
f0101411:	5e                   	pop    %esi
f0101412:	5d                   	pop    %ebp
f0101413:	c3                   	ret    
		panic("pa2page called with invalid pa");
f0101414:	83 ec 04             	sub    $0x4,%esp
f0101417:	8d 83 0c 8f f7 ff    	lea    -0x870f4(%ebx),%eax
f010141d:	50                   	push   %eax
f010141e:	6a 4f                	push   $0x4f
f0101420:	8d 83 05 8b f7 ff    	lea    -0x874fb(%ebx),%eax
f0101426:	50                   	push   %eax
f0101427:	e8 85 ec ff ff       	call   f01000b1 <_panic>
		return NULL;
f010142c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101431:	eb da                	jmp    f010140d <page_lookup+0x50>

f0101433 <page_remove>:
{
f0101433:	55                   	push   %ebp
f0101434:	89 e5                	mov    %esp,%ebp
f0101436:	53                   	push   %ebx
f0101437:	83 ec 18             	sub    $0x18,%esp
f010143a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *entry = NULL;
f010143d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo *page = page_lookup(pgdir, va, &entry);
f0101444:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101447:	50                   	push   %eax
f0101448:	53                   	push   %ebx
f0101449:	ff 75 08             	pushl  0x8(%ebp)
f010144c:	e8 6c ff ff ff       	call   f01013bd <page_lookup>
	if(!page|| !(*entry & PTE_P)) return;////page not exist
f0101451:	83 c4 10             	add    $0x10,%esp
f0101454:	85 c0                	test   %eax,%eax
f0101456:	74 08                	je     f0101460 <page_remove+0x2d>
f0101458:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010145b:	f6 02 01             	testb  $0x1,(%edx)
f010145e:	75 05                	jne    f0101465 <page_remove+0x32>
}
f0101460:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101463:	c9                   	leave  
f0101464:	c3                   	ret    
	page_decref(page);
f0101465:	83 ec 0c             	sub    $0xc,%esp
f0101468:	50                   	push   %eax
f0101469:	e8 f9 fd ff ff       	call   f0101267 <page_decref>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010146e:	0f 01 3b             	invlpg (%ebx)
	*entry = 0;
f0101471:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101474:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f010147a:	83 c4 10             	add    $0x10,%esp
f010147d:	eb e1                	jmp    f0101460 <page_remove+0x2d>

f010147f <page_insert>:
{
f010147f:	55                   	push   %ebp
f0101480:	89 e5                	mov    %esp,%ebp
f0101482:	57                   	push   %edi
f0101483:	56                   	push   %esi
f0101484:	53                   	push   %ebx
f0101485:	83 ec 10             	sub    $0x10,%esp
f0101488:	e8 6c 1f 00 00       	call   f01033f9 <__x86.get_pc_thunk.di>
f010148d:	81 c7 93 bb 08 00    	add    $0x8bb93,%edi
f0101493:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *entry = pgdir_walk(pgdir,va, 1);
f0101496:	6a 01                	push   $0x1
f0101498:	ff 75 10             	pushl  0x10(%ebp)
f010149b:	ff 75 08             	pushl  0x8(%ebp)
f010149e:	e8 ed fd ff ff       	call   f0101290 <pgdir_walk>
	if(!entry)
f01014a3:	83 c4 10             	add    $0x10,%esp
f01014a6:	85 c0                	test   %eax,%eax
f01014a8:	74 46                	je     f01014f0 <page_insert+0x71>
f01014aa:	89 c3                	mov    %eax,%ebx
	pp->pp_ref++;
f01014ac:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	if((*entry)&PTE_P){		//If this virtual address is already mapped.
f01014b1:	f6 00 01             	testb  $0x1,(%eax)
f01014b4:	75 27                	jne    f01014dd <page_insert+0x5e>
	return (pp - pages) << PGSHIFT;
f01014b6:	c7 c0 f0 ff 18 f0    	mov    $0xf018fff0,%eax
f01014bc:	2b 30                	sub    (%eax),%esi
f01014be:	89 f0                	mov    %esi,%eax
f01014c0:	c1 f8 03             	sar    $0x3,%eax
f01014c3:	c1 e0 0c             	shl    $0xc,%eax
	*entry = page2pa(pp)|perm|PTE_P;
f01014c6:	8b 55 14             	mov    0x14(%ebp),%edx
f01014c9:	83 ca 01             	or     $0x1,%edx
f01014cc:	09 d0                	or     %edx,%eax
f01014ce:	89 03                	mov    %eax,(%ebx)
	return 0;
f01014d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01014d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014d8:	5b                   	pop    %ebx
f01014d9:	5e                   	pop    %esi
f01014da:	5f                   	pop    %edi
f01014db:	5d                   	pop    %ebp
f01014dc:	c3                   	ret    
		page_remove(pgdir, va);
f01014dd:	83 ec 08             	sub    $0x8,%esp
f01014e0:	ff 75 10             	pushl  0x10(%ebp)
f01014e3:	ff 75 08             	pushl  0x8(%ebp)
f01014e6:	e8 48 ff ff ff       	call   f0101433 <page_remove>
f01014eb:	83 c4 10             	add    $0x10,%esp
f01014ee:	eb c6                	jmp    f01014b6 <page_insert+0x37>
		return -E_NO_MEM;
f01014f0:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01014f5:	eb de                	jmp    f01014d5 <page_insert+0x56>

f01014f7 <mem_init>:
{
f01014f7:	55                   	push   %ebp
f01014f8:	89 e5                	mov    %esp,%ebp
f01014fa:	57                   	push   %edi
f01014fb:	56                   	push   %esi
f01014fc:	53                   	push   %ebx
f01014fd:	83 ec 3c             	sub    $0x3c,%esp
f0101500:	e8 04 f2 ff ff       	call   f0100709 <__x86.get_pc_thunk.ax>
f0101505:	05 1b bb 08 00       	add    $0x8bb1b,%eax
f010150a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	basemem = nvram_read(NVRAM_BASELO);
f010150d:	b8 15 00 00 00       	mov    $0x15,%eax
f0101512:	e8 47 f7 ff ff       	call   f0100c5e <nvram_read>
f0101517:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101519:	b8 17 00 00 00       	mov    $0x17,%eax
f010151e:	e8 3b f7 ff ff       	call   f0100c5e <nvram_read>
f0101523:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101525:	b8 34 00 00 00       	mov    $0x34,%eax
f010152a:	e8 2f f7 ff ff       	call   f0100c5e <nvram_read>
f010152f:	c1 e0 06             	shl    $0x6,%eax
	if (ext16mem)
f0101532:	85 c0                	test   %eax,%eax
f0101534:	0f 85 f3 00 00 00    	jne    f010162d <mem_init+0x136>
		totalmem = 1 * 1024 + extmem;
f010153a:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101540:	85 f6                	test   %esi,%esi
f0101542:	0f 44 c3             	cmove  %ebx,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101545:	89 c1                	mov    %eax,%ecx
f0101547:	c1 e9 02             	shr    $0x2,%ecx
f010154a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010154d:	c7 c2 e8 ff 18 f0    	mov    $0xf018ffe8,%edx
f0101553:	89 0a                	mov    %ecx,(%edx)
	npages_basemem = basemem / (PGSIZE / 1024);
f0101555:	89 da                	mov    %ebx,%edx
f0101557:	c1 ea 02             	shr    $0x2,%edx
f010155a:	89 97 04 23 00 00    	mov    %edx,0x2304(%edi)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101560:	89 c2                	mov    %eax,%edx
f0101562:	29 da                	sub    %ebx,%edx
f0101564:	52                   	push   %edx
f0101565:	53                   	push   %ebx
f0101566:	50                   	push   %eax
f0101567:	8d 87 2c 8f f7 ff    	lea    -0x870d4(%edi),%eax
f010156d:	50                   	push   %eax
f010156e:	89 fb                	mov    %edi,%ebx
f0101570:	e8 a2 26 00 00       	call   f0103c17 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101575:	b8 00 10 00 00       	mov    $0x1000,%eax
f010157a:	e8 46 f6 ff ff       	call   f0100bc5 <boot_alloc>
f010157f:	c7 c6 ec ff 18 f0    	mov    $0xf018ffec,%esi
f0101585:	89 06                	mov    %eax,(%esi)
	memset(kern_pgdir, 0, PGSIZE);
f0101587:	83 c4 0c             	add    $0xc,%esp
f010158a:	68 00 10 00 00       	push   $0x1000
f010158f:	6a 00                	push   $0x0
f0101591:	50                   	push   %eax
f0101592:	e8 b8 3b 00 00       	call   f010514f <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101597:	8b 06                	mov    (%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0101599:	83 c4 10             	add    $0x10,%esp
f010159c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01015a1:	0f 86 90 00 00 00    	jbe    f0101637 <mem_init+0x140>
	return (physaddr_t)kva - KERNBASE;
f01015a7:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01015ad:	83 ca 05             	or     $0x5,%edx
f01015b0:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(npages *sizeof(struct PageInfo));
f01015b6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01015b9:	c7 c3 e8 ff 18 f0    	mov    $0xf018ffe8,%ebx
f01015bf:	8b 03                	mov    (%ebx),%eax
f01015c1:	c1 e0 03             	shl    $0x3,%eax
f01015c4:	e8 fc f5 ff ff       	call   f0100bc5 <boot_alloc>
f01015c9:	c7 c6 f0 ff 18 f0    	mov    $0xf018fff0,%esi
f01015cf:	89 06                	mov    %eax,(%esi)
	memset(pages, 0, npages * sizeof(struct PageInfo));
f01015d1:	83 ec 04             	sub    $0x4,%esp
f01015d4:	8b 13                	mov    (%ebx),%edx
f01015d6:	c1 e2 03             	shl    $0x3,%edx
f01015d9:	52                   	push   %edx
f01015da:	6a 00                	push   $0x0
f01015dc:	50                   	push   %eax
f01015dd:	89 fb                	mov    %edi,%ebx
f01015df:	e8 6b 3b 00 00       	call   f010514f <memset>
	envs = (struct Env*)boot_alloc(NENV*sizeof(struct Env));
f01015e4:	b8 00 80 01 00       	mov    $0x18000,%eax
f01015e9:	e8 d7 f5 ff ff       	call   f0100bc5 <boot_alloc>
f01015ee:	c7 c2 2c f3 18 f0    	mov    $0xf018f32c,%edx
f01015f4:	89 02                	mov    %eax,(%edx)
	memset(envs, 0, NENV * sizeof(struct Env));
f01015f6:	83 c4 0c             	add    $0xc,%esp
f01015f9:	68 00 80 01 00       	push   $0x18000
f01015fe:	6a 00                	push   $0x0
f0101600:	50                   	push   %eax
f0101601:	e8 49 3b 00 00       	call   f010514f <memset>
	page_init();
f0101606:	e8 89 fa ff ff       	call   f0101094 <page_init>
	check_page_free_list(1);
f010160b:	b8 01 00 00 00       	mov    $0x1,%eax
f0101610:	e8 fc f6 ff ff       	call   f0100d11 <check_page_free_list>
	if (!pages)
f0101615:	83 c4 10             	add    $0x10,%esp
f0101618:	83 3e 00             	cmpl   $0x0,(%esi)
f010161b:	74 36                	je     f0101653 <mem_init+0x15c>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010161d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101620:	8b 80 00 23 00 00    	mov    0x2300(%eax),%eax
f0101626:	be 00 00 00 00       	mov    $0x0,%esi
f010162b:	eb 49                	jmp    f0101676 <mem_init+0x17f>
		totalmem = 16 * 1024 + ext16mem;
f010162d:	05 00 40 00 00       	add    $0x4000,%eax
f0101632:	e9 0e ff ff ff       	jmp    f0101545 <mem_init+0x4e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101637:	50                   	push   %eax
f0101638:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010163b:	8d 83 68 8f f7 ff    	lea    -0x87098(%ebx),%eax
f0101641:	50                   	push   %eax
f0101642:	68 95 00 00 00       	push   $0x95
f0101647:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f010164d:	50                   	push   %eax
f010164e:	e8 5e ea ff ff       	call   f01000b1 <_panic>
		panic("'pages' is a null pointer!");
f0101653:	83 ec 04             	sub    $0x4,%esp
f0101656:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101659:	8d 83 d3 8b f7 ff    	lea    -0x8742d(%ebx),%eax
f010165f:	50                   	push   %eax
f0101660:	68 aa 02 00 00       	push   $0x2aa
f0101665:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f010166b:	50                   	push   %eax
f010166c:	e8 40 ea ff ff       	call   f01000b1 <_panic>
		++nfree;
f0101671:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101674:	8b 00                	mov    (%eax),%eax
f0101676:	85 c0                	test   %eax,%eax
f0101678:	75 f7                	jne    f0101671 <mem_init+0x17a>
	assert((pp0 = page_alloc(0)));
f010167a:	83 ec 0c             	sub    $0xc,%esp
f010167d:	6a 00                	push   $0x0
f010167f:	e8 e9 fa ff ff       	call   f010116d <page_alloc>
f0101684:	89 c3                	mov    %eax,%ebx
f0101686:	83 c4 10             	add    $0x10,%esp
f0101689:	85 c0                	test   %eax,%eax
f010168b:	0f 84 3b 02 00 00    	je     f01018cc <mem_init+0x3d5>
	assert((pp1 = page_alloc(0)));
f0101691:	83 ec 0c             	sub    $0xc,%esp
f0101694:	6a 00                	push   $0x0
f0101696:	e8 d2 fa ff ff       	call   f010116d <page_alloc>
f010169b:	89 c7                	mov    %eax,%edi
f010169d:	83 c4 10             	add    $0x10,%esp
f01016a0:	85 c0                	test   %eax,%eax
f01016a2:	0f 84 46 02 00 00    	je     f01018ee <mem_init+0x3f7>
	assert((pp2 = page_alloc(0)));
f01016a8:	83 ec 0c             	sub    $0xc,%esp
f01016ab:	6a 00                	push   $0x0
f01016ad:	e8 bb fa ff ff       	call   f010116d <page_alloc>
f01016b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01016b5:	83 c4 10             	add    $0x10,%esp
f01016b8:	85 c0                	test   %eax,%eax
f01016ba:	0f 84 50 02 00 00    	je     f0101910 <mem_init+0x419>
	assert(pp1 && pp1 != pp0);
f01016c0:	39 fb                	cmp    %edi,%ebx
f01016c2:	0f 84 6a 02 00 00    	je     f0101932 <mem_init+0x43b>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01016cb:	39 c7                	cmp    %eax,%edi
f01016cd:	0f 84 81 02 00 00    	je     f0101954 <mem_init+0x45d>
f01016d3:	39 c3                	cmp    %eax,%ebx
f01016d5:	0f 84 79 02 00 00    	je     f0101954 <mem_init+0x45d>
	return (pp - pages) << PGSHIFT;
f01016db:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01016de:	c7 c0 f0 ff 18 f0    	mov    $0xf018fff0,%eax
f01016e4:	8b 08                	mov    (%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01016e6:	c7 c0 e8 ff 18 f0    	mov    $0xf018ffe8,%eax
f01016ec:	8b 10                	mov    (%eax),%edx
f01016ee:	c1 e2 0c             	shl    $0xc,%edx
f01016f1:	89 d8                	mov    %ebx,%eax
f01016f3:	29 c8                	sub    %ecx,%eax
f01016f5:	c1 f8 03             	sar    $0x3,%eax
f01016f8:	c1 e0 0c             	shl    $0xc,%eax
f01016fb:	39 d0                	cmp    %edx,%eax
f01016fd:	0f 83 73 02 00 00    	jae    f0101976 <mem_init+0x47f>
f0101703:	89 f8                	mov    %edi,%eax
f0101705:	29 c8                	sub    %ecx,%eax
f0101707:	c1 f8 03             	sar    $0x3,%eax
f010170a:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f010170d:	39 c2                	cmp    %eax,%edx
f010170f:	0f 86 83 02 00 00    	jbe    f0101998 <mem_init+0x4a1>
f0101715:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101718:	29 c8                	sub    %ecx,%eax
f010171a:	c1 f8 03             	sar    $0x3,%eax
f010171d:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101720:	39 c2                	cmp    %eax,%edx
f0101722:	0f 86 92 02 00 00    	jbe    f01019ba <mem_init+0x4c3>
	fl = page_free_list;
f0101728:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010172b:	8b 88 00 23 00 00    	mov    0x2300(%eax),%ecx
f0101731:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101734:	c7 80 00 23 00 00 00 	movl   $0x0,0x2300(%eax)
f010173b:	00 00 00 
	assert(!page_alloc(0));
f010173e:	83 ec 0c             	sub    $0xc,%esp
f0101741:	6a 00                	push   $0x0
f0101743:	e8 25 fa ff ff       	call   f010116d <page_alloc>
f0101748:	83 c4 10             	add    $0x10,%esp
f010174b:	85 c0                	test   %eax,%eax
f010174d:	0f 85 89 02 00 00    	jne    f01019dc <mem_init+0x4e5>
	page_free(pp0);
f0101753:	83 ec 0c             	sub    $0xc,%esp
f0101756:	53                   	push   %ebx
f0101757:	e8 99 fa ff ff       	call   f01011f5 <page_free>
	page_free(pp1);
f010175c:	89 3c 24             	mov    %edi,(%esp)
f010175f:	e8 91 fa ff ff       	call   f01011f5 <page_free>
	page_free(pp2);
f0101764:	83 c4 04             	add    $0x4,%esp
f0101767:	ff 75 d0             	pushl  -0x30(%ebp)
f010176a:	e8 86 fa ff ff       	call   f01011f5 <page_free>
	assert((pp0 = page_alloc(0)));
f010176f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101776:	e8 f2 f9 ff ff       	call   f010116d <page_alloc>
f010177b:	89 c7                	mov    %eax,%edi
f010177d:	83 c4 10             	add    $0x10,%esp
f0101780:	85 c0                	test   %eax,%eax
f0101782:	0f 84 76 02 00 00    	je     f01019fe <mem_init+0x507>
	assert((pp1 = page_alloc(0)));
f0101788:	83 ec 0c             	sub    $0xc,%esp
f010178b:	6a 00                	push   $0x0
f010178d:	e8 db f9 ff ff       	call   f010116d <page_alloc>
f0101792:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101795:	83 c4 10             	add    $0x10,%esp
f0101798:	85 c0                	test   %eax,%eax
f010179a:	0f 84 80 02 00 00    	je     f0101a20 <mem_init+0x529>
	assert((pp2 = page_alloc(0)));
f01017a0:	83 ec 0c             	sub    $0xc,%esp
f01017a3:	6a 00                	push   $0x0
f01017a5:	e8 c3 f9 ff ff       	call   f010116d <page_alloc>
f01017aa:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01017ad:	83 c4 10             	add    $0x10,%esp
f01017b0:	85 c0                	test   %eax,%eax
f01017b2:	0f 84 8a 02 00 00    	je     f0101a42 <mem_init+0x54b>
	assert(pp1 && pp1 != pp0);
f01017b8:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f01017bb:	0f 84 a3 02 00 00    	je     f0101a64 <mem_init+0x56d>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017c1:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01017c4:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01017c7:	0f 84 b9 02 00 00    	je     f0101a86 <mem_init+0x58f>
f01017cd:	39 c7                	cmp    %eax,%edi
f01017cf:	0f 84 b1 02 00 00    	je     f0101a86 <mem_init+0x58f>
	assert(!page_alloc(0));
f01017d5:	83 ec 0c             	sub    $0xc,%esp
f01017d8:	6a 00                	push   $0x0
f01017da:	e8 8e f9 ff ff       	call   f010116d <page_alloc>
f01017df:	83 c4 10             	add    $0x10,%esp
f01017e2:	85 c0                	test   %eax,%eax
f01017e4:	0f 85 be 02 00 00    	jne    f0101aa8 <mem_init+0x5b1>
f01017ea:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017ed:	c7 c0 f0 ff 18 f0    	mov    $0xf018fff0,%eax
f01017f3:	89 f9                	mov    %edi,%ecx
f01017f5:	2b 08                	sub    (%eax),%ecx
f01017f7:	89 c8                	mov    %ecx,%eax
f01017f9:	c1 f8 03             	sar    $0x3,%eax
f01017fc:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01017ff:	89 c1                	mov    %eax,%ecx
f0101801:	c1 e9 0c             	shr    $0xc,%ecx
f0101804:	c7 c2 e8 ff 18 f0    	mov    $0xf018ffe8,%edx
f010180a:	3b 0a                	cmp    (%edx),%ecx
f010180c:	0f 83 b8 02 00 00    	jae    f0101aca <mem_init+0x5d3>
	memset(page2kva(pp0), 1, PGSIZE);
f0101812:	83 ec 04             	sub    $0x4,%esp
f0101815:	68 00 10 00 00       	push   $0x1000
f010181a:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f010181c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101821:	50                   	push   %eax
f0101822:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101825:	e8 25 39 00 00       	call   f010514f <memset>
	page_free(pp0);
f010182a:	89 3c 24             	mov    %edi,(%esp)
f010182d:	e8 c3 f9 ff ff       	call   f01011f5 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101832:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101839:	e8 2f f9 ff ff       	call   f010116d <page_alloc>
f010183e:	83 c4 10             	add    $0x10,%esp
f0101841:	85 c0                	test   %eax,%eax
f0101843:	0f 84 97 02 00 00    	je     f0101ae0 <mem_init+0x5e9>
	assert(pp && pp0 == pp);
f0101849:	39 c7                	cmp    %eax,%edi
f010184b:	0f 85 b1 02 00 00    	jne    f0101b02 <mem_init+0x60b>
	return (pp - pages) << PGSHIFT;
f0101851:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101854:	c7 c0 f0 ff 18 f0    	mov    $0xf018fff0,%eax
f010185a:	89 fa                	mov    %edi,%edx
f010185c:	2b 10                	sub    (%eax),%edx
f010185e:	c1 fa 03             	sar    $0x3,%edx
f0101861:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101864:	89 d1                	mov    %edx,%ecx
f0101866:	c1 e9 0c             	shr    $0xc,%ecx
f0101869:	c7 c0 e8 ff 18 f0    	mov    $0xf018ffe8,%eax
f010186f:	3b 08                	cmp    (%eax),%ecx
f0101871:	0f 83 ad 02 00 00    	jae    f0101b24 <mem_init+0x62d>
	return (void *)(pa + KERNBASE);
f0101877:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f010187d:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101883:	80 38 00             	cmpb   $0x0,(%eax)
f0101886:	0f 85 ae 02 00 00    	jne    f0101b3a <mem_init+0x643>
f010188c:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f010188f:	39 d0                	cmp    %edx,%eax
f0101891:	75 f0                	jne    f0101883 <mem_init+0x38c>
	page_free_list = fl;
f0101893:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101896:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101899:	89 8b 00 23 00 00    	mov    %ecx,0x2300(%ebx)
	page_free(pp0);
f010189f:	83 ec 0c             	sub    $0xc,%esp
f01018a2:	57                   	push   %edi
f01018a3:	e8 4d f9 ff ff       	call   f01011f5 <page_free>
	page_free(pp1);
f01018a8:	83 c4 04             	add    $0x4,%esp
f01018ab:	ff 75 d0             	pushl  -0x30(%ebp)
f01018ae:	e8 42 f9 ff ff       	call   f01011f5 <page_free>
	page_free(pp2);
f01018b3:	83 c4 04             	add    $0x4,%esp
f01018b6:	ff 75 cc             	pushl  -0x34(%ebp)
f01018b9:	e8 37 f9 ff ff       	call   f01011f5 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01018be:	8b 83 00 23 00 00    	mov    0x2300(%ebx),%eax
f01018c4:	83 c4 10             	add    $0x10,%esp
f01018c7:	e9 95 02 00 00       	jmp    f0101b61 <mem_init+0x66a>
	assert((pp0 = page_alloc(0)));
f01018cc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018cf:	8d 83 ee 8b f7 ff    	lea    -0x87412(%ebx),%eax
f01018d5:	50                   	push   %eax
f01018d6:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01018dc:	50                   	push   %eax
f01018dd:	68 b2 02 00 00       	push   $0x2b2
f01018e2:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01018e8:	50                   	push   %eax
f01018e9:	e8 c3 e7 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f01018ee:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018f1:	8d 83 04 8c f7 ff    	lea    -0x873fc(%ebx),%eax
f01018f7:	50                   	push   %eax
f01018f8:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01018fe:	50                   	push   %eax
f01018ff:	68 b3 02 00 00       	push   $0x2b3
f0101904:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f010190a:	50                   	push   %eax
f010190b:	e8 a1 e7 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101910:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101913:	8d 83 1a 8c f7 ff    	lea    -0x873e6(%ebx),%eax
f0101919:	50                   	push   %eax
f010191a:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0101920:	50                   	push   %eax
f0101921:	68 b4 02 00 00       	push   $0x2b4
f0101926:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f010192c:	50                   	push   %eax
f010192d:	e8 7f e7 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f0101932:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101935:	8d 83 30 8c f7 ff    	lea    -0x873d0(%ebx),%eax
f010193b:	50                   	push   %eax
f010193c:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0101942:	50                   	push   %eax
f0101943:	68 b7 02 00 00       	push   $0x2b7
f0101948:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f010194e:	50                   	push   %eax
f010194f:	e8 5d e7 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101954:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101957:	8d 83 8c 8f f7 ff    	lea    -0x87074(%ebx),%eax
f010195d:	50                   	push   %eax
f010195e:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0101964:	50                   	push   %eax
f0101965:	68 b8 02 00 00       	push   $0x2b8
f010196a:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0101970:	50                   	push   %eax
f0101971:	e8 3b e7 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101976:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101979:	8d 83 42 8c f7 ff    	lea    -0x873be(%ebx),%eax
f010197f:	50                   	push   %eax
f0101980:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0101986:	50                   	push   %eax
f0101987:	68 b9 02 00 00       	push   $0x2b9
f010198c:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0101992:	50                   	push   %eax
f0101993:	e8 19 e7 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101998:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010199b:	8d 83 5f 8c f7 ff    	lea    -0x873a1(%ebx),%eax
f01019a1:	50                   	push   %eax
f01019a2:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01019a8:	50                   	push   %eax
f01019a9:	68 ba 02 00 00       	push   $0x2ba
f01019ae:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01019b4:	50                   	push   %eax
f01019b5:	e8 f7 e6 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01019ba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01019bd:	8d 83 7c 8c f7 ff    	lea    -0x87384(%ebx),%eax
f01019c3:	50                   	push   %eax
f01019c4:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01019ca:	50                   	push   %eax
f01019cb:	68 bb 02 00 00       	push   $0x2bb
f01019d0:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01019d6:	50                   	push   %eax
f01019d7:	e8 d5 e6 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f01019dc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01019df:	8d 83 99 8c f7 ff    	lea    -0x87367(%ebx),%eax
f01019e5:	50                   	push   %eax
f01019e6:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01019ec:	50                   	push   %eax
f01019ed:	68 c2 02 00 00       	push   $0x2c2
f01019f2:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01019f8:	50                   	push   %eax
f01019f9:	e8 b3 e6 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f01019fe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a01:	8d 83 ee 8b f7 ff    	lea    -0x87412(%ebx),%eax
f0101a07:	50                   	push   %eax
f0101a08:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0101a0e:	50                   	push   %eax
f0101a0f:	68 c9 02 00 00       	push   $0x2c9
f0101a14:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0101a1a:	50                   	push   %eax
f0101a1b:	e8 91 e6 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a20:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a23:	8d 83 04 8c f7 ff    	lea    -0x873fc(%ebx),%eax
f0101a29:	50                   	push   %eax
f0101a2a:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0101a30:	50                   	push   %eax
f0101a31:	68 ca 02 00 00       	push   $0x2ca
f0101a36:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0101a3c:	50                   	push   %eax
f0101a3d:	e8 6f e6 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a42:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a45:	8d 83 1a 8c f7 ff    	lea    -0x873e6(%ebx),%eax
f0101a4b:	50                   	push   %eax
f0101a4c:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0101a52:	50                   	push   %eax
f0101a53:	68 cb 02 00 00       	push   $0x2cb
f0101a58:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0101a5e:	50                   	push   %eax
f0101a5f:	e8 4d e6 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f0101a64:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a67:	8d 83 30 8c f7 ff    	lea    -0x873d0(%ebx),%eax
f0101a6d:	50                   	push   %eax
f0101a6e:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0101a74:	50                   	push   %eax
f0101a75:	68 cd 02 00 00       	push   $0x2cd
f0101a7a:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0101a80:	50                   	push   %eax
f0101a81:	e8 2b e6 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a86:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a89:	8d 83 8c 8f f7 ff    	lea    -0x87074(%ebx),%eax
f0101a8f:	50                   	push   %eax
f0101a90:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0101a96:	50                   	push   %eax
f0101a97:	68 ce 02 00 00       	push   $0x2ce
f0101a9c:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0101aa2:	50                   	push   %eax
f0101aa3:	e8 09 e6 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0101aa8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101aab:	8d 83 99 8c f7 ff    	lea    -0x87367(%ebx),%eax
f0101ab1:	50                   	push   %eax
f0101ab2:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0101ab8:	50                   	push   %eax
f0101ab9:	68 cf 02 00 00       	push   $0x2cf
f0101abe:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0101ac4:	50                   	push   %eax
f0101ac5:	e8 e7 e5 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101aca:	50                   	push   %eax
f0101acb:	8d 83 00 8e f7 ff    	lea    -0x87200(%ebx),%eax
f0101ad1:	50                   	push   %eax
f0101ad2:	6a 56                	push   $0x56
f0101ad4:	8d 83 05 8b f7 ff    	lea    -0x874fb(%ebx),%eax
f0101ada:	50                   	push   %eax
f0101adb:	e8 d1 e5 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101ae0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101ae3:	8d 83 a8 8c f7 ff    	lea    -0x87358(%ebx),%eax
f0101ae9:	50                   	push   %eax
f0101aea:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0101af0:	50                   	push   %eax
f0101af1:	68 d4 02 00 00       	push   $0x2d4
f0101af6:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0101afc:	50                   	push   %eax
f0101afd:	e8 af e5 ff ff       	call   f01000b1 <_panic>
	assert(pp && pp0 == pp);
f0101b02:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101b05:	8d 83 c6 8c f7 ff    	lea    -0x8733a(%ebx),%eax
f0101b0b:	50                   	push   %eax
f0101b0c:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0101b12:	50                   	push   %eax
f0101b13:	68 d5 02 00 00       	push   $0x2d5
f0101b18:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0101b1e:	50                   	push   %eax
f0101b1f:	e8 8d e5 ff ff       	call   f01000b1 <_panic>
f0101b24:	52                   	push   %edx
f0101b25:	8d 83 00 8e f7 ff    	lea    -0x87200(%ebx),%eax
f0101b2b:	50                   	push   %eax
f0101b2c:	6a 56                	push   $0x56
f0101b2e:	8d 83 05 8b f7 ff    	lea    -0x874fb(%ebx),%eax
f0101b34:	50                   	push   %eax
f0101b35:	e8 77 e5 ff ff       	call   f01000b1 <_panic>
		assert(c[i] == 0);
f0101b3a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101b3d:	8d 83 d6 8c f7 ff    	lea    -0x8732a(%ebx),%eax
f0101b43:	50                   	push   %eax
f0101b44:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0101b4a:	50                   	push   %eax
f0101b4b:	68 d8 02 00 00       	push   $0x2d8
f0101b50:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0101b56:	50                   	push   %eax
f0101b57:	e8 55 e5 ff ff       	call   f01000b1 <_panic>
		--nfree;
f0101b5c:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b5f:	8b 00                	mov    (%eax),%eax
f0101b61:	85 c0                	test   %eax,%eax
f0101b63:	75 f7                	jne    f0101b5c <mem_init+0x665>
	assert(nfree == 0);
f0101b65:	85 f6                	test   %esi,%esi
f0101b67:	0f 85 5f 08 00 00    	jne    f01023cc <mem_init+0xed5>
	cprintf("check_page_alloc() succeeded!\n");
f0101b6d:	83 ec 0c             	sub    $0xc,%esp
f0101b70:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101b73:	8d 83 ac 8f f7 ff    	lea    -0x87054(%ebx),%eax
f0101b79:	50                   	push   %eax
f0101b7a:	e8 98 20 00 00       	call   f0103c17 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101b7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b86:	e8 e2 f5 ff ff       	call   f010116d <page_alloc>
f0101b8b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101b8e:	83 c4 10             	add    $0x10,%esp
f0101b91:	85 c0                	test   %eax,%eax
f0101b93:	0f 84 55 08 00 00    	je     f01023ee <mem_init+0xef7>
	assert((pp1 = page_alloc(0)));
f0101b99:	83 ec 0c             	sub    $0xc,%esp
f0101b9c:	6a 00                	push   $0x0
f0101b9e:	e8 ca f5 ff ff       	call   f010116d <page_alloc>
f0101ba3:	89 c7                	mov    %eax,%edi
f0101ba5:	83 c4 10             	add    $0x10,%esp
f0101ba8:	85 c0                	test   %eax,%eax
f0101baa:	0f 84 60 08 00 00    	je     f0102410 <mem_init+0xf19>
	assert((pp2 = page_alloc(0)));
f0101bb0:	83 ec 0c             	sub    $0xc,%esp
f0101bb3:	6a 00                	push   $0x0
f0101bb5:	e8 b3 f5 ff ff       	call   f010116d <page_alloc>
f0101bba:	89 c6                	mov    %eax,%esi
f0101bbc:	83 c4 10             	add    $0x10,%esp
f0101bbf:	85 c0                	test   %eax,%eax
f0101bc1:	0f 84 6b 08 00 00    	je     f0102432 <mem_init+0xf3b>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101bc7:	39 7d d0             	cmp    %edi,-0x30(%ebp)
f0101bca:	0f 84 84 08 00 00    	je     f0102454 <mem_init+0xf5d>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101bd0:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101bd3:	0f 84 9d 08 00 00    	je     f0102476 <mem_init+0xf7f>
f0101bd9:	39 c7                	cmp    %eax,%edi
f0101bdb:	0f 84 95 08 00 00    	je     f0102476 <mem_init+0xf7f>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101be1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101be4:	8b 88 00 23 00 00    	mov    0x2300(%eax),%ecx
f0101bea:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101bed:	c7 80 00 23 00 00 00 	movl   $0x0,0x2300(%eax)
f0101bf4:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101bf7:	83 ec 0c             	sub    $0xc,%esp
f0101bfa:	6a 00                	push   $0x0
f0101bfc:	e8 6c f5 ff ff       	call   f010116d <page_alloc>
f0101c01:	83 c4 10             	add    $0x10,%esp
f0101c04:	85 c0                	test   %eax,%eax
f0101c06:	0f 85 8c 08 00 00    	jne    f0102498 <mem_init+0xfa1>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101c0c:	83 ec 04             	sub    $0x4,%esp
f0101c0f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101c12:	50                   	push   %eax
f0101c13:	6a 00                	push   $0x0
f0101c15:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c18:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f0101c1e:	ff 30                	pushl  (%eax)
f0101c20:	e8 98 f7 ff ff       	call   f01013bd <page_lookup>
f0101c25:	83 c4 10             	add    $0x10,%esp
f0101c28:	85 c0                	test   %eax,%eax
f0101c2a:	0f 85 8a 08 00 00    	jne    f01024ba <mem_init+0xfc3>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101c30:	6a 02                	push   $0x2
f0101c32:	6a 00                	push   $0x0
f0101c34:	57                   	push   %edi
f0101c35:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c38:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f0101c3e:	ff 30                	pushl  (%eax)
f0101c40:	e8 3a f8 ff ff       	call   f010147f <page_insert>
f0101c45:	83 c4 10             	add    $0x10,%esp
f0101c48:	85 c0                	test   %eax,%eax
f0101c4a:	0f 89 8c 08 00 00    	jns    f01024dc <mem_init+0xfe5>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101c50:	83 ec 0c             	sub    $0xc,%esp
f0101c53:	ff 75 d0             	pushl  -0x30(%ebp)
f0101c56:	e8 9a f5 ff ff       	call   f01011f5 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101c5b:	6a 02                	push   $0x2
f0101c5d:	6a 00                	push   $0x0
f0101c5f:	57                   	push   %edi
f0101c60:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c63:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f0101c69:	ff 30                	pushl  (%eax)
f0101c6b:	e8 0f f8 ff ff       	call   f010147f <page_insert>
f0101c70:	83 c4 20             	add    $0x20,%esp
f0101c73:	85 c0                	test   %eax,%eax
f0101c75:	0f 85 83 08 00 00    	jne    f01024fe <mem_init+0x1007>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101c7b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101c7e:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f0101c84:	8b 18                	mov    (%eax),%ebx
	return (pp - pages) << PGSHIFT;
f0101c86:	c7 c0 f0 ff 18 f0    	mov    $0xf018fff0,%eax
f0101c8c:	8b 08                	mov    (%eax),%ecx
f0101c8e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0101c91:	8b 13                	mov    (%ebx),%edx
f0101c93:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101c99:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c9c:	29 c8                	sub    %ecx,%eax
f0101c9e:	c1 f8 03             	sar    $0x3,%eax
f0101ca1:	c1 e0 0c             	shl    $0xc,%eax
f0101ca4:	39 c2                	cmp    %eax,%edx
f0101ca6:	0f 85 74 08 00 00    	jne    f0102520 <mem_init+0x1029>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101cac:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cb1:	89 d8                	mov    %ebx,%eax
f0101cb3:	e8 dc ef ff ff       	call   f0100c94 <check_va2pa>
f0101cb8:	89 fa                	mov    %edi,%edx
f0101cba:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101cbd:	c1 fa 03             	sar    $0x3,%edx
f0101cc0:	c1 e2 0c             	shl    $0xc,%edx
f0101cc3:	39 d0                	cmp    %edx,%eax
f0101cc5:	0f 85 77 08 00 00    	jne    f0102542 <mem_init+0x104b>
	assert(pp1->pp_ref == 1);
f0101ccb:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101cd0:	0f 85 8e 08 00 00    	jne    f0102564 <mem_init+0x106d>
	assert(pp0->pp_ref == 1);
f0101cd6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101cd9:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101cde:	0f 85 a2 08 00 00    	jne    f0102586 <mem_init+0x108f>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ce4:	6a 02                	push   $0x2
f0101ce6:	68 00 10 00 00       	push   $0x1000
f0101ceb:	56                   	push   %esi
f0101cec:	53                   	push   %ebx
f0101ced:	e8 8d f7 ff ff       	call   f010147f <page_insert>
f0101cf2:	83 c4 10             	add    $0x10,%esp
f0101cf5:	85 c0                	test   %eax,%eax
f0101cf7:	0f 85 ab 08 00 00    	jne    f01025a8 <mem_init+0x10b1>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101cfd:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d02:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101d05:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f0101d0b:	8b 00                	mov    (%eax),%eax
f0101d0d:	e8 82 ef ff ff       	call   f0100c94 <check_va2pa>
f0101d12:	c7 c2 f0 ff 18 f0    	mov    $0xf018fff0,%edx
f0101d18:	89 f1                	mov    %esi,%ecx
f0101d1a:	2b 0a                	sub    (%edx),%ecx
f0101d1c:	89 ca                	mov    %ecx,%edx
f0101d1e:	c1 fa 03             	sar    $0x3,%edx
f0101d21:	c1 e2 0c             	shl    $0xc,%edx
f0101d24:	39 d0                	cmp    %edx,%eax
f0101d26:	0f 85 9e 08 00 00    	jne    f01025ca <mem_init+0x10d3>
	assert(pp2->pp_ref == 1);
f0101d2c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d31:	0f 85 b5 08 00 00    	jne    f01025ec <mem_init+0x10f5>

	// should be no free memory
	assert(!page_alloc(0));
f0101d37:	83 ec 0c             	sub    $0xc,%esp
f0101d3a:	6a 00                	push   $0x0
f0101d3c:	e8 2c f4 ff ff       	call   f010116d <page_alloc>
f0101d41:	83 c4 10             	add    $0x10,%esp
f0101d44:	85 c0                	test   %eax,%eax
f0101d46:	0f 85 c2 08 00 00    	jne    f010260e <mem_init+0x1117>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d4c:	6a 02                	push   $0x2
f0101d4e:	68 00 10 00 00       	push   $0x1000
f0101d53:	56                   	push   %esi
f0101d54:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d57:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f0101d5d:	ff 30                	pushl  (%eax)
f0101d5f:	e8 1b f7 ff ff       	call   f010147f <page_insert>
f0101d64:	83 c4 10             	add    $0x10,%esp
f0101d67:	85 c0                	test   %eax,%eax
f0101d69:	0f 85 c1 08 00 00    	jne    f0102630 <mem_init+0x1139>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d6f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d74:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101d77:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f0101d7d:	8b 00                	mov    (%eax),%eax
f0101d7f:	e8 10 ef ff ff       	call   f0100c94 <check_va2pa>
f0101d84:	c7 c2 f0 ff 18 f0    	mov    $0xf018fff0,%edx
f0101d8a:	89 f1                	mov    %esi,%ecx
f0101d8c:	2b 0a                	sub    (%edx),%ecx
f0101d8e:	89 ca                	mov    %ecx,%edx
f0101d90:	c1 fa 03             	sar    $0x3,%edx
f0101d93:	c1 e2 0c             	shl    $0xc,%edx
f0101d96:	39 d0                	cmp    %edx,%eax
f0101d98:	0f 85 b4 08 00 00    	jne    f0102652 <mem_init+0x115b>
	assert(pp2->pp_ref == 1);
f0101d9e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101da3:	0f 85 cb 08 00 00    	jne    f0102674 <mem_init+0x117d>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101da9:	83 ec 0c             	sub    $0xc,%esp
f0101dac:	6a 00                	push   $0x0
f0101dae:	e8 ba f3 ff ff       	call   f010116d <page_alloc>
f0101db3:	83 c4 10             	add    $0x10,%esp
f0101db6:	85 c0                	test   %eax,%eax
f0101db8:	0f 85 d8 08 00 00    	jne    f0102696 <mem_init+0x119f>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101dbe:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101dc1:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f0101dc7:	8b 10                	mov    (%eax),%edx
f0101dc9:	8b 02                	mov    (%edx),%eax
f0101dcb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101dd0:	89 c3                	mov    %eax,%ebx
f0101dd2:	c1 eb 0c             	shr    $0xc,%ebx
f0101dd5:	c7 c1 e8 ff 18 f0    	mov    $0xf018ffe8,%ecx
f0101ddb:	3b 19                	cmp    (%ecx),%ebx
f0101ddd:	0f 83 d5 08 00 00    	jae    f01026b8 <mem_init+0x11c1>
	return (void *)(pa + KERNBASE);
f0101de3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101de8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101deb:	83 ec 04             	sub    $0x4,%esp
f0101dee:	6a 00                	push   $0x0
f0101df0:	68 00 10 00 00       	push   $0x1000
f0101df5:	52                   	push   %edx
f0101df6:	e8 95 f4 ff ff       	call   f0101290 <pgdir_walk>
f0101dfb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101dfe:	8d 51 04             	lea    0x4(%ecx),%edx
f0101e01:	83 c4 10             	add    $0x10,%esp
f0101e04:	39 d0                	cmp    %edx,%eax
f0101e06:	0f 85 c8 08 00 00    	jne    f01026d4 <mem_init+0x11dd>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101e0c:	6a 06                	push   $0x6
f0101e0e:	68 00 10 00 00       	push   $0x1000
f0101e13:	56                   	push   %esi
f0101e14:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e17:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f0101e1d:	ff 30                	pushl  (%eax)
f0101e1f:	e8 5b f6 ff ff       	call   f010147f <page_insert>
f0101e24:	83 c4 10             	add    $0x10,%esp
f0101e27:	85 c0                	test   %eax,%eax
f0101e29:	0f 85 c7 08 00 00    	jne    f01026f6 <mem_init+0x11ff>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e2f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e32:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f0101e38:	8b 18                	mov    (%eax),%ebx
f0101e3a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e3f:	89 d8                	mov    %ebx,%eax
f0101e41:	e8 4e ee ff ff       	call   f0100c94 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101e46:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101e49:	c7 c2 f0 ff 18 f0    	mov    $0xf018fff0,%edx
f0101e4f:	89 f1                	mov    %esi,%ecx
f0101e51:	2b 0a                	sub    (%edx),%ecx
f0101e53:	89 ca                	mov    %ecx,%edx
f0101e55:	c1 fa 03             	sar    $0x3,%edx
f0101e58:	c1 e2 0c             	shl    $0xc,%edx
f0101e5b:	39 d0                	cmp    %edx,%eax
f0101e5d:	0f 85 b5 08 00 00    	jne    f0102718 <mem_init+0x1221>
	assert(pp2->pp_ref == 1);
f0101e63:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e68:	0f 85 cc 08 00 00    	jne    f010273a <mem_init+0x1243>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101e6e:	83 ec 04             	sub    $0x4,%esp
f0101e71:	6a 00                	push   $0x0
f0101e73:	68 00 10 00 00       	push   $0x1000
f0101e78:	53                   	push   %ebx
f0101e79:	e8 12 f4 ff ff       	call   f0101290 <pgdir_walk>
f0101e7e:	83 c4 10             	add    $0x10,%esp
f0101e81:	f6 00 04             	testb  $0x4,(%eax)
f0101e84:	0f 84 d2 08 00 00    	je     f010275c <mem_init+0x1265>
	assert(kern_pgdir[0] & PTE_U);
f0101e8a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e8d:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f0101e93:	8b 00                	mov    (%eax),%eax
f0101e95:	f6 00 04             	testb  $0x4,(%eax)
f0101e98:	0f 84 e0 08 00 00    	je     f010277e <mem_init+0x1287>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e9e:	6a 02                	push   $0x2
f0101ea0:	68 00 10 00 00       	push   $0x1000
f0101ea5:	56                   	push   %esi
f0101ea6:	50                   	push   %eax
f0101ea7:	e8 d3 f5 ff ff       	call   f010147f <page_insert>
f0101eac:	83 c4 10             	add    $0x10,%esp
f0101eaf:	85 c0                	test   %eax,%eax
f0101eb1:	0f 85 e9 08 00 00    	jne    f01027a0 <mem_init+0x12a9>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101eb7:	83 ec 04             	sub    $0x4,%esp
f0101eba:	6a 00                	push   $0x0
f0101ebc:	68 00 10 00 00       	push   $0x1000
f0101ec1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ec4:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f0101eca:	ff 30                	pushl  (%eax)
f0101ecc:	e8 bf f3 ff ff       	call   f0101290 <pgdir_walk>
f0101ed1:	83 c4 10             	add    $0x10,%esp
f0101ed4:	f6 00 02             	testb  $0x2,(%eax)
f0101ed7:	0f 84 e5 08 00 00    	je     f01027c2 <mem_init+0x12cb>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101edd:	83 ec 04             	sub    $0x4,%esp
f0101ee0:	6a 00                	push   $0x0
f0101ee2:	68 00 10 00 00       	push   $0x1000
f0101ee7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101eea:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f0101ef0:	ff 30                	pushl  (%eax)
f0101ef2:	e8 99 f3 ff ff       	call   f0101290 <pgdir_walk>
f0101ef7:	83 c4 10             	add    $0x10,%esp
f0101efa:	f6 00 04             	testb  $0x4,(%eax)
f0101efd:	0f 85 e1 08 00 00    	jne    f01027e4 <mem_init+0x12ed>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f03:	6a 02                	push   $0x2
f0101f05:	68 00 00 40 00       	push   $0x400000
f0101f0a:	ff 75 d0             	pushl  -0x30(%ebp)
f0101f0d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f10:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f0101f16:	ff 30                	pushl  (%eax)
f0101f18:	e8 62 f5 ff ff       	call   f010147f <page_insert>
f0101f1d:	83 c4 10             	add    $0x10,%esp
f0101f20:	85 c0                	test   %eax,%eax
f0101f22:	0f 89 de 08 00 00    	jns    f0102806 <mem_init+0x130f>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f28:	6a 02                	push   $0x2
f0101f2a:	68 00 10 00 00       	push   $0x1000
f0101f2f:	57                   	push   %edi
f0101f30:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f33:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f0101f39:	ff 30                	pushl  (%eax)
f0101f3b:	e8 3f f5 ff ff       	call   f010147f <page_insert>
f0101f40:	83 c4 10             	add    $0x10,%esp
f0101f43:	85 c0                	test   %eax,%eax
f0101f45:	0f 85 dd 08 00 00    	jne    f0102828 <mem_init+0x1331>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f4b:	83 ec 04             	sub    $0x4,%esp
f0101f4e:	6a 00                	push   $0x0
f0101f50:	68 00 10 00 00       	push   $0x1000
f0101f55:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f58:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f0101f5e:	ff 30                	pushl  (%eax)
f0101f60:	e8 2b f3 ff ff       	call   f0101290 <pgdir_walk>
f0101f65:	83 c4 10             	add    $0x10,%esp
f0101f68:	f6 00 04             	testb  $0x4,(%eax)
f0101f6b:	0f 85 d9 08 00 00    	jne    f010284a <mem_init+0x1353>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101f71:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f74:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f0101f7a:	8b 18                	mov    (%eax),%ebx
f0101f7c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f81:	89 d8                	mov    %ebx,%eax
f0101f83:	e8 0c ed ff ff       	call   f0100c94 <check_va2pa>
f0101f88:	89 c2                	mov    %eax,%edx
f0101f8a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101f8d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101f90:	c7 c0 f0 ff 18 f0    	mov    $0xf018fff0,%eax
f0101f96:	89 f9                	mov    %edi,%ecx
f0101f98:	2b 08                	sub    (%eax),%ecx
f0101f9a:	89 c8                	mov    %ecx,%eax
f0101f9c:	c1 f8 03             	sar    $0x3,%eax
f0101f9f:	c1 e0 0c             	shl    $0xc,%eax
f0101fa2:	39 c2                	cmp    %eax,%edx
f0101fa4:	0f 85 c2 08 00 00    	jne    f010286c <mem_init+0x1375>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101faa:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101faf:	89 d8                	mov    %ebx,%eax
f0101fb1:	e8 de ec ff ff       	call   f0100c94 <check_va2pa>
f0101fb6:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101fb9:	0f 85 cf 08 00 00    	jne    f010288e <mem_init+0x1397>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101fbf:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101fc4:	0f 85 e6 08 00 00    	jne    f01028b0 <mem_init+0x13b9>
	assert(pp2->pp_ref == 0);
f0101fca:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101fcf:	0f 85 fd 08 00 00    	jne    f01028d2 <mem_init+0x13db>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101fd5:	83 ec 0c             	sub    $0xc,%esp
f0101fd8:	6a 00                	push   $0x0
f0101fda:	e8 8e f1 ff ff       	call   f010116d <page_alloc>
f0101fdf:	83 c4 10             	add    $0x10,%esp
f0101fe2:	39 c6                	cmp    %eax,%esi
f0101fe4:	0f 85 0a 09 00 00    	jne    f01028f4 <mem_init+0x13fd>
f0101fea:	85 c0                	test   %eax,%eax
f0101fec:	0f 84 02 09 00 00    	je     f01028f4 <mem_init+0x13fd>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101ff2:	83 ec 08             	sub    $0x8,%esp
f0101ff5:	6a 00                	push   $0x0
f0101ff7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ffa:	c7 c3 ec ff 18 f0    	mov    $0xf018ffec,%ebx
f0102000:	ff 33                	pushl  (%ebx)
f0102002:	e8 2c f4 ff ff       	call   f0101433 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102007:	8b 1b                	mov    (%ebx),%ebx
f0102009:	ba 00 00 00 00       	mov    $0x0,%edx
f010200e:	89 d8                	mov    %ebx,%eax
f0102010:	e8 7f ec ff ff       	call   f0100c94 <check_va2pa>
f0102015:	83 c4 10             	add    $0x10,%esp
f0102018:	83 f8 ff             	cmp    $0xffffffff,%eax
f010201b:	0f 85 f5 08 00 00    	jne    f0102916 <mem_init+0x141f>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102021:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102026:	89 d8                	mov    %ebx,%eax
f0102028:	e8 67 ec ff ff       	call   f0100c94 <check_va2pa>
f010202d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102030:	c7 c2 f0 ff 18 f0    	mov    $0xf018fff0,%edx
f0102036:	89 f9                	mov    %edi,%ecx
f0102038:	2b 0a                	sub    (%edx),%ecx
f010203a:	89 ca                	mov    %ecx,%edx
f010203c:	c1 fa 03             	sar    $0x3,%edx
f010203f:	c1 e2 0c             	shl    $0xc,%edx
f0102042:	39 d0                	cmp    %edx,%eax
f0102044:	0f 85 ee 08 00 00    	jne    f0102938 <mem_init+0x1441>
	assert(pp1->pp_ref == 1);
f010204a:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010204f:	0f 85 05 09 00 00    	jne    f010295a <mem_init+0x1463>
	assert(pp2->pp_ref == 0);
f0102055:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010205a:	0f 85 1c 09 00 00    	jne    f010297c <mem_init+0x1485>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102060:	6a 00                	push   $0x0
f0102062:	68 00 10 00 00       	push   $0x1000
f0102067:	57                   	push   %edi
f0102068:	53                   	push   %ebx
f0102069:	e8 11 f4 ff ff       	call   f010147f <page_insert>
f010206e:	83 c4 10             	add    $0x10,%esp
f0102071:	85 c0                	test   %eax,%eax
f0102073:	0f 85 25 09 00 00    	jne    f010299e <mem_init+0x14a7>
	assert(pp1->pp_ref);
f0102079:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010207e:	0f 84 3c 09 00 00    	je     f01029c0 <mem_init+0x14c9>
	assert(pp1->pp_link == NULL);
f0102084:	83 3f 00             	cmpl   $0x0,(%edi)
f0102087:	0f 85 55 09 00 00    	jne    f01029e2 <mem_init+0x14eb>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010208d:	83 ec 08             	sub    $0x8,%esp
f0102090:	68 00 10 00 00       	push   $0x1000
f0102095:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102098:	c7 c3 ec ff 18 f0    	mov    $0xf018ffec,%ebx
f010209e:	ff 33                	pushl  (%ebx)
f01020a0:	e8 8e f3 ff ff       	call   f0101433 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020a5:	8b 1b                	mov    (%ebx),%ebx
f01020a7:	ba 00 00 00 00       	mov    $0x0,%edx
f01020ac:	89 d8                	mov    %ebx,%eax
f01020ae:	e8 e1 eb ff ff       	call   f0100c94 <check_va2pa>
f01020b3:	83 c4 10             	add    $0x10,%esp
f01020b6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020b9:	0f 85 45 09 00 00    	jne    f0102a04 <mem_init+0x150d>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01020bf:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020c4:	89 d8                	mov    %ebx,%eax
f01020c6:	e8 c9 eb ff ff       	call   f0100c94 <check_va2pa>
f01020cb:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020ce:	0f 85 52 09 00 00    	jne    f0102a26 <mem_init+0x152f>
	assert(pp1->pp_ref == 0);
f01020d4:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01020d9:	0f 85 69 09 00 00    	jne    f0102a48 <mem_init+0x1551>
	assert(pp2->pp_ref == 0);
f01020df:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01020e4:	0f 85 80 09 00 00    	jne    f0102a6a <mem_init+0x1573>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01020ea:	83 ec 0c             	sub    $0xc,%esp
f01020ed:	6a 00                	push   $0x0
f01020ef:	e8 79 f0 ff ff       	call   f010116d <page_alloc>
f01020f4:	83 c4 10             	add    $0x10,%esp
f01020f7:	85 c0                	test   %eax,%eax
f01020f9:	0f 84 8d 09 00 00    	je     f0102a8c <mem_init+0x1595>
f01020ff:	39 c7                	cmp    %eax,%edi
f0102101:	0f 85 85 09 00 00    	jne    f0102a8c <mem_init+0x1595>

	// should be no free memory
	assert(!page_alloc(0));
f0102107:	83 ec 0c             	sub    $0xc,%esp
f010210a:	6a 00                	push   $0x0
f010210c:	e8 5c f0 ff ff       	call   f010116d <page_alloc>
f0102111:	83 c4 10             	add    $0x10,%esp
f0102114:	85 c0                	test   %eax,%eax
f0102116:	0f 85 92 09 00 00    	jne    f0102aae <mem_init+0x15b7>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010211c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010211f:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f0102125:	8b 08                	mov    (%eax),%ecx
f0102127:	8b 11                	mov    (%ecx),%edx
f0102129:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010212f:	c7 c0 f0 ff 18 f0    	mov    $0xf018fff0,%eax
f0102135:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102138:	2b 18                	sub    (%eax),%ebx
f010213a:	89 d8                	mov    %ebx,%eax
f010213c:	c1 f8 03             	sar    $0x3,%eax
f010213f:	c1 e0 0c             	shl    $0xc,%eax
f0102142:	39 c2                	cmp    %eax,%edx
f0102144:	0f 85 86 09 00 00    	jne    f0102ad0 <mem_init+0x15d9>
	kern_pgdir[0] = 0;
f010214a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102150:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102153:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102158:	0f 85 94 09 00 00    	jne    f0102af2 <mem_init+0x15fb>
	pp0->pp_ref = 0;
f010215e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102161:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102167:	83 ec 0c             	sub    $0xc,%esp
f010216a:	50                   	push   %eax
f010216b:	e8 85 f0 ff ff       	call   f01011f5 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102170:	83 c4 0c             	add    $0xc,%esp
f0102173:	6a 01                	push   $0x1
f0102175:	68 00 10 40 00       	push   $0x401000
f010217a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010217d:	c7 c3 ec ff 18 f0    	mov    $0xf018ffec,%ebx
f0102183:	ff 33                	pushl  (%ebx)
f0102185:	e8 06 f1 ff ff       	call   f0101290 <pgdir_walk>
f010218a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010218d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102190:	8b 1b                	mov    (%ebx),%ebx
f0102192:	8b 53 04             	mov    0x4(%ebx),%edx
f0102195:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f010219b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010219e:	c7 c1 e8 ff 18 f0    	mov    $0xf018ffe8,%ecx
f01021a4:	8b 09                	mov    (%ecx),%ecx
f01021a6:	89 d0                	mov    %edx,%eax
f01021a8:	c1 e8 0c             	shr    $0xc,%eax
f01021ab:	83 c4 10             	add    $0x10,%esp
f01021ae:	39 c8                	cmp    %ecx,%eax
f01021b0:	0f 83 5e 09 00 00    	jae    f0102b14 <mem_init+0x161d>
	assert(ptep == ptep1 + PTX(va));
f01021b6:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01021bc:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f01021bf:	0f 85 6b 09 00 00    	jne    f0102b30 <mem_init+0x1639>
	kern_pgdir[PDX(va)] = 0;
f01021c5:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	pp0->pp_ref = 0;
f01021cc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01021cf:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	return (pp - pages) << PGSHIFT;
f01021d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021d8:	c7 c0 f0 ff 18 f0    	mov    $0xf018fff0,%eax
f01021de:	2b 18                	sub    (%eax),%ebx
f01021e0:	89 d8                	mov    %ebx,%eax
f01021e2:	c1 f8 03             	sar    $0x3,%eax
f01021e5:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01021e8:	89 c2                	mov    %eax,%edx
f01021ea:	c1 ea 0c             	shr    $0xc,%edx
f01021ed:	39 d1                	cmp    %edx,%ecx
f01021ef:	0f 86 5d 09 00 00    	jbe    f0102b52 <mem_init+0x165b>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01021f5:	83 ec 04             	sub    $0x4,%esp
f01021f8:	68 00 10 00 00       	push   $0x1000
f01021fd:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0102202:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102207:	50                   	push   %eax
f0102208:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010220b:	e8 3f 2f 00 00       	call   f010514f <memset>
	page_free(pp0);
f0102210:	83 c4 04             	add    $0x4,%esp
f0102213:	ff 75 d0             	pushl  -0x30(%ebp)
f0102216:	e8 da ef ff ff       	call   f01011f5 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010221b:	83 c4 0c             	add    $0xc,%esp
f010221e:	6a 01                	push   $0x1
f0102220:	6a 00                	push   $0x0
f0102222:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102225:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f010222b:	ff 30                	pushl  (%eax)
f010222d:	e8 5e f0 ff ff       	call   f0101290 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0102232:	c7 c0 f0 ff 18 f0    	mov    $0xf018fff0,%eax
f0102238:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010223b:	2b 10                	sub    (%eax),%edx
f010223d:	c1 fa 03             	sar    $0x3,%edx
f0102240:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102243:	89 d1                	mov    %edx,%ecx
f0102245:	c1 e9 0c             	shr    $0xc,%ecx
f0102248:	83 c4 10             	add    $0x10,%esp
f010224b:	c7 c0 e8 ff 18 f0    	mov    $0xf018ffe8,%eax
f0102251:	3b 08                	cmp    (%eax),%ecx
f0102253:	0f 83 12 09 00 00    	jae    f0102b6b <mem_init+0x1674>
	return (void *)(pa + KERNBASE);
f0102259:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010225f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102262:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102268:	f6 00 01             	testb  $0x1,(%eax)
f010226b:	0f 85 13 09 00 00    	jne    f0102b84 <mem_init+0x168d>
f0102271:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0102274:	39 d0                	cmp    %edx,%eax
f0102276:	75 f0                	jne    f0102268 <mem_init+0xd71>
	kern_pgdir[0] = 0;
f0102278:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010227b:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f0102281:	8b 00                	mov    (%eax),%eax
f0102283:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102289:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010228c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102292:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102295:	89 93 00 23 00 00    	mov    %edx,0x2300(%ebx)

	// free the pages we took
	page_free(pp0);
f010229b:	83 ec 0c             	sub    $0xc,%esp
f010229e:	50                   	push   %eax
f010229f:	e8 51 ef ff ff       	call   f01011f5 <page_free>
	page_free(pp1);
f01022a4:	89 3c 24             	mov    %edi,(%esp)
f01022a7:	e8 49 ef ff ff       	call   f01011f5 <page_free>
	page_free(pp2);
f01022ac:	89 34 24             	mov    %esi,(%esp)
f01022af:	e8 41 ef ff ff       	call   f01011f5 <page_free>

	cprintf("check_page() succeeded!\n");
f01022b4:	8d 83 b7 8d f7 ff    	lea    -0x87249(%ebx),%eax
f01022ba:	89 04 24             	mov    %eax,(%esp)
f01022bd:	e8 55 19 00 00       	call   f0103c17 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f01022c2:	c7 c0 f0 ff 18 f0    	mov    $0xf018fff0,%eax
f01022c8:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01022ca:	83 c4 10             	add    $0x10,%esp
f01022cd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01022d2:	0f 86 ce 08 00 00    	jbe    f0102ba6 <mem_init+0x16af>
f01022d8:	83 ec 08             	sub    $0x8,%esp
f01022db:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f01022dd:	05 00 00 00 10       	add    $0x10000000,%eax
f01022e2:	50                   	push   %eax
f01022e3:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01022e8:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01022ed:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01022f0:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f01022f6:	8b 00                	mov    (%eax),%eax
f01022f8:	e8 3e f0 ff ff       	call   f010133b <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f01022fd:	c7 c0 2c f3 18 f0    	mov    $0xf018f32c,%eax
f0102303:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102305:	83 c4 10             	add    $0x10,%esp
f0102308:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010230d:	0f 86 af 08 00 00    	jbe    f0102bc2 <mem_init+0x16cb>
f0102313:	83 ec 08             	sub    $0x8,%esp
f0102316:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102318:	05 00 00 00 10       	add    $0x10000000,%eax
f010231d:	50                   	push   %eax
f010231e:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102323:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102328:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010232b:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f0102331:	8b 00                	mov    (%eax),%eax
f0102333:	e8 03 f0 ff ff       	call   f010133b <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0102338:	c7 c0 00 30 11 f0    	mov    $0xf0113000,%eax
f010233e:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102341:	83 c4 10             	add    $0x10,%esp
f0102344:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102349:	0f 86 8f 08 00 00    	jbe    f0102bde <mem_init+0x16e7>
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f010234f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102352:	c7 c3 ec ff 18 f0    	mov    $0xf018ffec,%ebx
f0102358:	83 ec 08             	sub    $0x8,%esp
f010235b:	6a 02                	push   $0x2
	return (physaddr_t)kva - KERNBASE;
f010235d:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102360:	05 00 00 00 10       	add    $0x10000000,%eax
f0102365:	50                   	push   %eax
f0102366:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010236b:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102370:	8b 03                	mov    (%ebx),%eax
f0102372:	e8 c4 ef ff ff       	call   f010133b <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, - KERNBASE, 0, PTE_W);
f0102377:	83 c4 08             	add    $0x8,%esp
f010237a:	6a 02                	push   $0x2
f010237c:	6a 00                	push   $0x0
f010237e:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102383:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102388:	8b 03                	mov    (%ebx),%eax
f010238a:	e8 ac ef ff ff       	call   f010133b <boot_map_region>
	pgdir = kern_pgdir;
f010238f:	8b 33                	mov    (%ebx),%esi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102391:	c7 c0 e8 ff 18 f0    	mov    $0xf018ffe8,%eax
f0102397:	8b 00                	mov    (%eax),%eax
f0102399:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010239c:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01023a3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01023a8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01023ab:	c7 c0 f0 ff 18 f0    	mov    $0xf018fff0,%eax
f01023b1:	8b 00                	mov    (%eax),%eax
f01023b3:	89 45 c0             	mov    %eax,-0x40(%ebp)
	if ((uint32_t)kva < KERNBASE)
f01023b6:	89 45 cc             	mov    %eax,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f01023b9:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f01023bf:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE)
f01023c2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01023c7:	e9 57 08 00 00       	jmp    f0102c23 <mem_init+0x172c>
	assert(nfree == 0);
f01023cc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023cf:	8d 83 e0 8c f7 ff    	lea    -0x87320(%ebx),%eax
f01023d5:	50                   	push   %eax
f01023d6:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01023dc:	50                   	push   %eax
f01023dd:	68 e5 02 00 00       	push   $0x2e5
f01023e2:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01023e8:	50                   	push   %eax
f01023e9:	e8 c3 dc ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f01023ee:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023f1:	8d 83 ee 8b f7 ff    	lea    -0x87412(%ebx),%eax
f01023f7:	50                   	push   %eax
f01023f8:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01023fe:	50                   	push   %eax
f01023ff:	68 43 03 00 00       	push   $0x343
f0102404:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f010240a:	50                   	push   %eax
f010240b:	e8 a1 dc ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0102410:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102413:	8d 83 04 8c f7 ff    	lea    -0x873fc(%ebx),%eax
f0102419:	50                   	push   %eax
f010241a:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102420:	50                   	push   %eax
f0102421:	68 44 03 00 00       	push   $0x344
f0102426:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f010242c:	50                   	push   %eax
f010242d:	e8 7f dc ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0102432:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102435:	8d 83 1a 8c f7 ff    	lea    -0x873e6(%ebx),%eax
f010243b:	50                   	push   %eax
f010243c:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102442:	50                   	push   %eax
f0102443:	68 45 03 00 00       	push   $0x345
f0102448:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f010244e:	50                   	push   %eax
f010244f:	e8 5d dc ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f0102454:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102457:	8d 83 30 8c f7 ff    	lea    -0x873d0(%ebx),%eax
f010245d:	50                   	push   %eax
f010245e:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102464:	50                   	push   %eax
f0102465:	68 48 03 00 00       	push   $0x348
f010246a:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102470:	50                   	push   %eax
f0102471:	e8 3b dc ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102476:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102479:	8d 83 8c 8f f7 ff    	lea    -0x87074(%ebx),%eax
f010247f:	50                   	push   %eax
f0102480:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102486:	50                   	push   %eax
f0102487:	68 49 03 00 00       	push   $0x349
f010248c:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102492:	50                   	push   %eax
f0102493:	e8 19 dc ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102498:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010249b:	8d 83 99 8c f7 ff    	lea    -0x87367(%ebx),%eax
f01024a1:	50                   	push   %eax
f01024a2:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01024a8:	50                   	push   %eax
f01024a9:	68 50 03 00 00       	push   $0x350
f01024ae:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01024b4:	50                   	push   %eax
f01024b5:	e8 f7 db ff ff       	call   f01000b1 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01024ba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024bd:	8d 83 cc 8f f7 ff    	lea    -0x87034(%ebx),%eax
f01024c3:	50                   	push   %eax
f01024c4:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01024ca:	50                   	push   %eax
f01024cb:	68 53 03 00 00       	push   $0x353
f01024d0:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01024d6:	50                   	push   %eax
f01024d7:	e8 d5 db ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01024dc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024df:	8d 83 04 90 f7 ff    	lea    -0x86ffc(%ebx),%eax
f01024e5:	50                   	push   %eax
f01024e6:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01024ec:	50                   	push   %eax
f01024ed:	68 56 03 00 00       	push   $0x356
f01024f2:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01024f8:	50                   	push   %eax
f01024f9:	e8 b3 db ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01024fe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102501:	8d 83 34 90 f7 ff    	lea    -0x86fcc(%ebx),%eax
f0102507:	50                   	push   %eax
f0102508:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f010250e:	50                   	push   %eax
f010250f:	68 5a 03 00 00       	push   $0x35a
f0102514:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f010251a:	50                   	push   %eax
f010251b:	e8 91 db ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102520:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102523:	8d 83 64 90 f7 ff    	lea    -0x86f9c(%ebx),%eax
f0102529:	50                   	push   %eax
f010252a:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102530:	50                   	push   %eax
f0102531:	68 5b 03 00 00       	push   $0x35b
f0102536:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f010253c:	50                   	push   %eax
f010253d:	e8 6f db ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102542:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102545:	8d 83 8c 90 f7 ff    	lea    -0x86f74(%ebx),%eax
f010254b:	50                   	push   %eax
f010254c:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102552:	50                   	push   %eax
f0102553:	68 5c 03 00 00       	push   $0x35c
f0102558:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f010255e:	50                   	push   %eax
f010255f:	e8 4d db ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0102564:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102567:	8d 83 eb 8c f7 ff    	lea    -0x87315(%ebx),%eax
f010256d:	50                   	push   %eax
f010256e:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102574:	50                   	push   %eax
f0102575:	68 5d 03 00 00       	push   $0x35d
f010257a:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102580:	50                   	push   %eax
f0102581:	e8 2b db ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f0102586:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102589:	8d 83 fc 8c f7 ff    	lea    -0x87304(%ebx),%eax
f010258f:	50                   	push   %eax
f0102590:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102596:	50                   	push   %eax
f0102597:	68 5e 03 00 00       	push   $0x35e
f010259c:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01025a2:	50                   	push   %eax
f01025a3:	e8 09 db ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01025a8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025ab:	8d 83 bc 90 f7 ff    	lea    -0x86f44(%ebx),%eax
f01025b1:	50                   	push   %eax
f01025b2:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01025b8:	50                   	push   %eax
f01025b9:	68 61 03 00 00       	push   $0x361
f01025be:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01025c4:	50                   	push   %eax
f01025c5:	e8 e7 da ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01025ca:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025cd:	8d 83 f8 90 f7 ff    	lea    -0x86f08(%ebx),%eax
f01025d3:	50                   	push   %eax
f01025d4:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01025da:	50                   	push   %eax
f01025db:	68 62 03 00 00       	push   $0x362
f01025e0:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01025e6:	50                   	push   %eax
f01025e7:	e8 c5 da ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f01025ec:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025ef:	8d 83 0d 8d f7 ff    	lea    -0x872f3(%ebx),%eax
f01025f5:	50                   	push   %eax
f01025f6:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01025fc:	50                   	push   %eax
f01025fd:	68 63 03 00 00       	push   $0x363
f0102602:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102608:	50                   	push   %eax
f0102609:	e8 a3 da ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f010260e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102611:	8d 83 99 8c f7 ff    	lea    -0x87367(%ebx),%eax
f0102617:	50                   	push   %eax
f0102618:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f010261e:	50                   	push   %eax
f010261f:	68 66 03 00 00       	push   $0x366
f0102624:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f010262a:	50                   	push   %eax
f010262b:	e8 81 da ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102630:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102633:	8d 83 bc 90 f7 ff    	lea    -0x86f44(%ebx),%eax
f0102639:	50                   	push   %eax
f010263a:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102640:	50                   	push   %eax
f0102641:	68 69 03 00 00       	push   $0x369
f0102646:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f010264c:	50                   	push   %eax
f010264d:	e8 5f da ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102652:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102655:	8d 83 f8 90 f7 ff    	lea    -0x86f08(%ebx),%eax
f010265b:	50                   	push   %eax
f010265c:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102662:	50                   	push   %eax
f0102663:	68 6a 03 00 00       	push   $0x36a
f0102668:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f010266e:	50                   	push   %eax
f010266f:	e8 3d da ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102674:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102677:	8d 83 0d 8d f7 ff    	lea    -0x872f3(%ebx),%eax
f010267d:	50                   	push   %eax
f010267e:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102684:	50                   	push   %eax
f0102685:	68 6b 03 00 00       	push   $0x36b
f010268a:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102690:	50                   	push   %eax
f0102691:	e8 1b da ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102696:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102699:	8d 83 99 8c f7 ff    	lea    -0x87367(%ebx),%eax
f010269f:	50                   	push   %eax
f01026a0:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01026a6:	50                   	push   %eax
f01026a7:	68 6f 03 00 00       	push   $0x36f
f01026ac:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01026b2:	50                   	push   %eax
f01026b3:	e8 f9 d9 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026b8:	50                   	push   %eax
f01026b9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026bc:	8d 83 00 8e f7 ff    	lea    -0x87200(%ebx),%eax
f01026c2:	50                   	push   %eax
f01026c3:	68 72 03 00 00       	push   $0x372
f01026c8:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01026ce:	50                   	push   %eax
f01026cf:	e8 dd d9 ff ff       	call   f01000b1 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01026d4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026d7:	8d 83 28 91 f7 ff    	lea    -0x86ed8(%ebx),%eax
f01026dd:	50                   	push   %eax
f01026de:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01026e4:	50                   	push   %eax
f01026e5:	68 73 03 00 00       	push   $0x373
f01026ea:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01026f0:	50                   	push   %eax
f01026f1:	e8 bb d9 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01026f6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026f9:	8d 83 68 91 f7 ff    	lea    -0x86e98(%ebx),%eax
f01026ff:	50                   	push   %eax
f0102700:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102706:	50                   	push   %eax
f0102707:	68 76 03 00 00       	push   $0x376
f010270c:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102712:	50                   	push   %eax
f0102713:	e8 99 d9 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102718:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010271b:	8d 83 f8 90 f7 ff    	lea    -0x86f08(%ebx),%eax
f0102721:	50                   	push   %eax
f0102722:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102728:	50                   	push   %eax
f0102729:	68 77 03 00 00       	push   $0x377
f010272e:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102734:	50                   	push   %eax
f0102735:	e8 77 d9 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f010273a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010273d:	8d 83 0d 8d f7 ff    	lea    -0x872f3(%ebx),%eax
f0102743:	50                   	push   %eax
f0102744:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f010274a:	50                   	push   %eax
f010274b:	68 78 03 00 00       	push   $0x378
f0102750:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102756:	50                   	push   %eax
f0102757:	e8 55 d9 ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010275c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010275f:	8d 83 a8 91 f7 ff    	lea    -0x86e58(%ebx),%eax
f0102765:	50                   	push   %eax
f0102766:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f010276c:	50                   	push   %eax
f010276d:	68 79 03 00 00       	push   $0x379
f0102772:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102778:	50                   	push   %eax
f0102779:	e8 33 d9 ff ff       	call   f01000b1 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010277e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102781:	8d 83 1e 8d f7 ff    	lea    -0x872e2(%ebx),%eax
f0102787:	50                   	push   %eax
f0102788:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f010278e:	50                   	push   %eax
f010278f:	68 7a 03 00 00       	push   $0x37a
f0102794:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f010279a:	50                   	push   %eax
f010279b:	e8 11 d9 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01027a0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027a3:	8d 83 bc 90 f7 ff    	lea    -0x86f44(%ebx),%eax
f01027a9:	50                   	push   %eax
f01027aa:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01027b0:	50                   	push   %eax
f01027b1:	68 7d 03 00 00       	push   $0x37d
f01027b6:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01027bc:	50                   	push   %eax
f01027bd:	e8 ef d8 ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01027c2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027c5:	8d 83 dc 91 f7 ff    	lea    -0x86e24(%ebx),%eax
f01027cb:	50                   	push   %eax
f01027cc:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01027d2:	50                   	push   %eax
f01027d3:	68 7e 03 00 00       	push   $0x37e
f01027d8:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01027de:	50                   	push   %eax
f01027df:	e8 cd d8 ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01027e4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027e7:	8d 83 10 92 f7 ff    	lea    -0x86df0(%ebx),%eax
f01027ed:	50                   	push   %eax
f01027ee:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01027f4:	50                   	push   %eax
f01027f5:	68 7f 03 00 00       	push   $0x37f
f01027fa:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102800:	50                   	push   %eax
f0102801:	e8 ab d8 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102806:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102809:	8d 83 48 92 f7 ff    	lea    -0x86db8(%ebx),%eax
f010280f:	50                   	push   %eax
f0102810:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102816:	50                   	push   %eax
f0102817:	68 82 03 00 00       	push   $0x382
f010281c:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102822:	50                   	push   %eax
f0102823:	e8 89 d8 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102828:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010282b:	8d 83 80 92 f7 ff    	lea    -0x86d80(%ebx),%eax
f0102831:	50                   	push   %eax
f0102832:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102838:	50                   	push   %eax
f0102839:	68 85 03 00 00       	push   $0x385
f010283e:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102844:	50                   	push   %eax
f0102845:	e8 67 d8 ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010284a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010284d:	8d 83 10 92 f7 ff    	lea    -0x86df0(%ebx),%eax
f0102853:	50                   	push   %eax
f0102854:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f010285a:	50                   	push   %eax
f010285b:	68 86 03 00 00       	push   $0x386
f0102860:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102866:	50                   	push   %eax
f0102867:	e8 45 d8 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010286c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010286f:	8d 83 bc 92 f7 ff    	lea    -0x86d44(%ebx),%eax
f0102875:	50                   	push   %eax
f0102876:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f010287c:	50                   	push   %eax
f010287d:	68 89 03 00 00       	push   $0x389
f0102882:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102888:	50                   	push   %eax
f0102889:	e8 23 d8 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010288e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102891:	8d 83 e8 92 f7 ff    	lea    -0x86d18(%ebx),%eax
f0102897:	50                   	push   %eax
f0102898:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f010289e:	50                   	push   %eax
f010289f:	68 8a 03 00 00       	push   $0x38a
f01028a4:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01028aa:	50                   	push   %eax
f01028ab:	e8 01 d8 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 2);
f01028b0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028b3:	8d 83 34 8d f7 ff    	lea    -0x872cc(%ebx),%eax
f01028b9:	50                   	push   %eax
f01028ba:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01028c0:	50                   	push   %eax
f01028c1:	68 8c 03 00 00       	push   $0x38c
f01028c6:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01028cc:	50                   	push   %eax
f01028cd:	e8 df d7 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f01028d2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028d5:	8d 83 45 8d f7 ff    	lea    -0x872bb(%ebx),%eax
f01028db:	50                   	push   %eax
f01028dc:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01028e2:	50                   	push   %eax
f01028e3:	68 8d 03 00 00       	push   $0x38d
f01028e8:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01028ee:	50                   	push   %eax
f01028ef:	e8 bd d7 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01028f4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028f7:	8d 83 18 93 f7 ff    	lea    -0x86ce8(%ebx),%eax
f01028fd:	50                   	push   %eax
f01028fe:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102904:	50                   	push   %eax
f0102905:	68 90 03 00 00       	push   $0x390
f010290a:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102910:	50                   	push   %eax
f0102911:	e8 9b d7 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102916:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102919:	8d 83 3c 93 f7 ff    	lea    -0x86cc4(%ebx),%eax
f010291f:	50                   	push   %eax
f0102920:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102926:	50                   	push   %eax
f0102927:	68 94 03 00 00       	push   $0x394
f010292c:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102932:	50                   	push   %eax
f0102933:	e8 79 d7 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102938:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010293b:	8d 83 e8 92 f7 ff    	lea    -0x86d18(%ebx),%eax
f0102941:	50                   	push   %eax
f0102942:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102948:	50                   	push   %eax
f0102949:	68 95 03 00 00       	push   $0x395
f010294e:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102954:	50                   	push   %eax
f0102955:	e8 57 d7 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f010295a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010295d:	8d 83 eb 8c f7 ff    	lea    -0x87315(%ebx),%eax
f0102963:	50                   	push   %eax
f0102964:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f010296a:	50                   	push   %eax
f010296b:	68 96 03 00 00       	push   $0x396
f0102970:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102976:	50                   	push   %eax
f0102977:	e8 35 d7 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f010297c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010297f:	8d 83 45 8d f7 ff    	lea    -0x872bb(%ebx),%eax
f0102985:	50                   	push   %eax
f0102986:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f010298c:	50                   	push   %eax
f010298d:	68 97 03 00 00       	push   $0x397
f0102992:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102998:	50                   	push   %eax
f0102999:	e8 13 d7 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010299e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029a1:	8d 83 60 93 f7 ff    	lea    -0x86ca0(%ebx),%eax
f01029a7:	50                   	push   %eax
f01029a8:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01029ae:	50                   	push   %eax
f01029af:	68 9a 03 00 00       	push   $0x39a
f01029b4:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01029ba:	50                   	push   %eax
f01029bb:	e8 f1 d6 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref);
f01029c0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029c3:	8d 83 56 8d f7 ff    	lea    -0x872aa(%ebx),%eax
f01029c9:	50                   	push   %eax
f01029ca:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01029d0:	50                   	push   %eax
f01029d1:	68 9b 03 00 00       	push   $0x39b
f01029d6:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01029dc:	50                   	push   %eax
f01029dd:	e8 cf d6 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_link == NULL);
f01029e2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029e5:	8d 83 62 8d f7 ff    	lea    -0x8729e(%ebx),%eax
f01029eb:	50                   	push   %eax
f01029ec:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01029f2:	50                   	push   %eax
f01029f3:	68 9c 03 00 00       	push   $0x39c
f01029f8:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01029fe:	50                   	push   %eax
f01029ff:	e8 ad d6 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102a04:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a07:	8d 83 3c 93 f7 ff    	lea    -0x86cc4(%ebx),%eax
f0102a0d:	50                   	push   %eax
f0102a0e:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102a14:	50                   	push   %eax
f0102a15:	68 a0 03 00 00       	push   $0x3a0
f0102a1a:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102a20:	50                   	push   %eax
f0102a21:	e8 8b d6 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102a26:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a29:	8d 83 98 93 f7 ff    	lea    -0x86c68(%ebx),%eax
f0102a2f:	50                   	push   %eax
f0102a30:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102a36:	50                   	push   %eax
f0102a37:	68 a1 03 00 00       	push   $0x3a1
f0102a3c:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102a42:	50                   	push   %eax
f0102a43:	e8 69 d6 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f0102a48:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a4b:	8d 83 77 8d f7 ff    	lea    -0x87289(%ebx),%eax
f0102a51:	50                   	push   %eax
f0102a52:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102a58:	50                   	push   %eax
f0102a59:	68 a2 03 00 00       	push   $0x3a2
f0102a5e:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102a64:	50                   	push   %eax
f0102a65:	e8 47 d6 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102a6a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a6d:	8d 83 45 8d f7 ff    	lea    -0x872bb(%ebx),%eax
f0102a73:	50                   	push   %eax
f0102a74:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102a7a:	50                   	push   %eax
f0102a7b:	68 a3 03 00 00       	push   $0x3a3
f0102a80:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102a86:	50                   	push   %eax
f0102a87:	e8 25 d6 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102a8c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a8f:	8d 83 c0 93 f7 ff    	lea    -0x86c40(%ebx),%eax
f0102a95:	50                   	push   %eax
f0102a96:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102a9c:	50                   	push   %eax
f0102a9d:	68 a6 03 00 00       	push   $0x3a6
f0102aa2:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102aa8:	50                   	push   %eax
f0102aa9:	e8 03 d6 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102aae:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ab1:	8d 83 99 8c f7 ff    	lea    -0x87367(%ebx),%eax
f0102ab7:	50                   	push   %eax
f0102ab8:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102abe:	50                   	push   %eax
f0102abf:	68 a9 03 00 00       	push   $0x3a9
f0102ac4:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102aca:	50                   	push   %eax
f0102acb:	e8 e1 d5 ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ad0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ad3:	8d 83 64 90 f7 ff    	lea    -0x86f9c(%ebx),%eax
f0102ad9:	50                   	push   %eax
f0102ada:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102ae0:	50                   	push   %eax
f0102ae1:	68 ac 03 00 00       	push   $0x3ac
f0102ae6:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102aec:	50                   	push   %eax
f0102aed:	e8 bf d5 ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f0102af2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102af5:	8d 83 fc 8c f7 ff    	lea    -0x87304(%ebx),%eax
f0102afb:	50                   	push   %eax
f0102afc:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102b02:	50                   	push   %eax
f0102b03:	68 ae 03 00 00       	push   $0x3ae
f0102b08:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102b0e:	50                   	push   %eax
f0102b0f:	e8 9d d5 ff ff       	call   f01000b1 <_panic>
f0102b14:	52                   	push   %edx
f0102b15:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b18:	8d 83 00 8e f7 ff    	lea    -0x87200(%ebx),%eax
f0102b1e:	50                   	push   %eax
f0102b1f:	68 b5 03 00 00       	push   $0x3b5
f0102b24:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102b2a:	50                   	push   %eax
f0102b2b:	e8 81 d5 ff ff       	call   f01000b1 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102b30:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b33:	8d 83 88 8d f7 ff    	lea    -0x87278(%ebx),%eax
f0102b39:	50                   	push   %eax
f0102b3a:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102b40:	50                   	push   %eax
f0102b41:	68 b6 03 00 00       	push   $0x3b6
f0102b46:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102b4c:	50                   	push   %eax
f0102b4d:	e8 5f d5 ff ff       	call   f01000b1 <_panic>
f0102b52:	50                   	push   %eax
f0102b53:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b56:	8d 83 00 8e f7 ff    	lea    -0x87200(%ebx),%eax
f0102b5c:	50                   	push   %eax
f0102b5d:	6a 56                	push   $0x56
f0102b5f:	8d 83 05 8b f7 ff    	lea    -0x874fb(%ebx),%eax
f0102b65:	50                   	push   %eax
f0102b66:	e8 46 d5 ff ff       	call   f01000b1 <_panic>
f0102b6b:	52                   	push   %edx
f0102b6c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b6f:	8d 83 00 8e f7 ff    	lea    -0x87200(%ebx),%eax
f0102b75:	50                   	push   %eax
f0102b76:	6a 56                	push   $0x56
f0102b78:	8d 83 05 8b f7 ff    	lea    -0x874fb(%ebx),%eax
f0102b7e:	50                   	push   %eax
f0102b7f:	e8 2d d5 ff ff       	call   f01000b1 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102b84:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b87:	8d 83 a0 8d f7 ff    	lea    -0x87260(%ebx),%eax
f0102b8d:	50                   	push   %eax
f0102b8e:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102b94:	50                   	push   %eax
f0102b95:	68 c0 03 00 00       	push   $0x3c0
f0102b9a:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102ba0:	50                   	push   %eax
f0102ba1:	e8 0b d5 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ba6:	50                   	push   %eax
f0102ba7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102baa:	8d 83 68 8f f7 ff    	lea    -0x87098(%ebx),%eax
f0102bb0:	50                   	push   %eax
f0102bb1:	68 bc 00 00 00       	push   $0xbc
f0102bb6:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102bbc:	50                   	push   %eax
f0102bbd:	e8 ef d4 ff ff       	call   f01000b1 <_panic>
f0102bc2:	50                   	push   %eax
f0102bc3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bc6:	8d 83 68 8f f7 ff    	lea    -0x87098(%ebx),%eax
f0102bcc:	50                   	push   %eax
f0102bcd:	68 c4 00 00 00       	push   $0xc4
f0102bd2:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102bd8:	50                   	push   %eax
f0102bd9:	e8 d3 d4 ff ff       	call   f01000b1 <_panic>
f0102bde:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102be1:	ff b3 fc ff ff ff    	pushl  -0x4(%ebx)
f0102be7:	8d 83 68 8f f7 ff    	lea    -0x87098(%ebx),%eax
f0102bed:	50                   	push   %eax
f0102bee:	68 d0 00 00 00       	push   $0xd0
f0102bf3:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102bf9:	50                   	push   %eax
f0102bfa:	e8 b2 d4 ff ff       	call   f01000b1 <_panic>
f0102bff:	ff 75 c0             	pushl  -0x40(%ebp)
f0102c02:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c05:	8d 83 68 8f f7 ff    	lea    -0x87098(%ebx),%eax
f0102c0b:	50                   	push   %eax
f0102c0c:	68 fd 02 00 00       	push   $0x2fd
f0102c11:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102c17:	50                   	push   %eax
f0102c18:	e8 94 d4 ff ff       	call   f01000b1 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f0102c1d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102c23:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0102c26:	76 3f                	jbe    f0102c67 <mem_init+0x1770>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102c28:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102c2e:	89 f0                	mov    %esi,%eax
f0102c30:	e8 5f e0 ff ff       	call   f0100c94 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102c35:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102c3c:	76 c1                	jbe    f0102bff <mem_init+0x1708>
f0102c3e:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f0102c41:	39 d0                	cmp    %edx,%eax
f0102c43:	74 d8                	je     f0102c1d <mem_init+0x1726>
f0102c45:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c48:	8d 83 e4 93 f7 ff    	lea    -0x86c1c(%ebx),%eax
f0102c4e:	50                   	push   %eax
f0102c4f:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102c55:	50                   	push   %eax
f0102c56:	68 fd 02 00 00       	push   $0x2fd
f0102c5b:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102c61:	50                   	push   %eax
f0102c62:	e8 4a d4 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102c67:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c6a:	c7 c0 2c f3 18 f0    	mov    $0xf018f32c,%eax
f0102c70:	8b 00                	mov    (%eax),%eax
f0102c72:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102c75:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102c78:	bf 00 00 c0 ee       	mov    $0xeec00000,%edi
f0102c7d:	8d 98 00 00 40 21    	lea    0x21400000(%eax),%ebx
f0102c83:	89 fa                	mov    %edi,%edx
f0102c85:	89 f0                	mov    %esi,%eax
f0102c87:	e8 08 e0 ff ff       	call   f0100c94 <check_va2pa>
f0102c8c:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102c93:	76 3d                	jbe    f0102cd2 <mem_init+0x17db>
f0102c95:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f0102c98:	39 d0                	cmp    %edx,%eax
f0102c9a:	75 54                	jne    f0102cf0 <mem_init+0x17f9>
f0102c9c:	81 c7 00 10 00 00    	add    $0x1000,%edi
	for (i = 0; i < n; i += PGSIZE)
f0102ca2:	81 ff 00 80 c1 ee    	cmp    $0xeec18000,%edi
f0102ca8:	75 d9                	jne    f0102c83 <mem_init+0x178c>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102caa:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0102cad:	c1 e7 0c             	shl    $0xc,%edi
f0102cb0:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102cb5:	39 fb                	cmp    %edi,%ebx
f0102cb7:	73 7b                	jae    f0102d34 <mem_init+0x183d>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102cb9:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102cbf:	89 f0                	mov    %esi,%eax
f0102cc1:	e8 ce df ff ff       	call   f0100c94 <check_va2pa>
f0102cc6:	39 c3                	cmp    %eax,%ebx
f0102cc8:	75 48                	jne    f0102d12 <mem_init+0x181b>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102cca:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102cd0:	eb e3                	jmp    f0102cb5 <mem_init+0x17be>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cd2:	ff 75 cc             	pushl  -0x34(%ebp)
f0102cd5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cd8:	8d 83 68 8f f7 ff    	lea    -0x87098(%ebx),%eax
f0102cde:	50                   	push   %eax
f0102cdf:	68 02 03 00 00       	push   $0x302
f0102ce4:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102cea:	50                   	push   %eax
f0102ceb:	e8 c1 d3 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102cf0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cf3:	8d 83 18 94 f7 ff    	lea    -0x86be8(%ebx),%eax
f0102cf9:	50                   	push   %eax
f0102cfa:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102d00:	50                   	push   %eax
f0102d01:	68 02 03 00 00       	push   $0x302
f0102d06:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102d0c:	50                   	push   %eax
f0102d0d:	e8 9f d3 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102d12:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d15:	8d 83 4c 94 f7 ff    	lea    -0x86bb4(%ebx),%eax
f0102d1b:	50                   	push   %eax
f0102d1c:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102d22:	50                   	push   %eax
f0102d23:	68 06 03 00 00       	push   $0x306
f0102d28:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102d2e:	50                   	push   %eax
f0102d2f:	e8 7d d3 ff ff       	call   f01000b1 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102d34:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102d39:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0102d3c:	81 c7 00 80 00 20    	add    $0x20008000,%edi
f0102d42:	89 da                	mov    %ebx,%edx
f0102d44:	89 f0                	mov    %esi,%eax
f0102d46:	e8 49 df ff ff       	call   f0100c94 <check_va2pa>
f0102d4b:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0102d4e:	39 c2                	cmp    %eax,%edx
f0102d50:	75 26                	jne    f0102d78 <mem_init+0x1881>
f0102d52:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102d58:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102d5e:	75 e2                	jne    f0102d42 <mem_init+0x184b>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102d60:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102d65:	89 f0                	mov    %esi,%eax
f0102d67:	e8 28 df ff ff       	call   f0100c94 <check_va2pa>
f0102d6c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102d6f:	75 29                	jne    f0102d9a <mem_init+0x18a3>
	for (i = 0; i < NPDENTRIES; i++) {
f0102d71:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d76:	eb 6d                	jmp    f0102de5 <mem_init+0x18ee>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102d78:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d7b:	8d 83 74 94 f7 ff    	lea    -0x86b8c(%ebx),%eax
f0102d81:	50                   	push   %eax
f0102d82:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102d88:	50                   	push   %eax
f0102d89:	68 0a 03 00 00       	push   $0x30a
f0102d8e:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102d94:	50                   	push   %eax
f0102d95:	e8 17 d3 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102d9a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d9d:	8d 83 bc 94 f7 ff    	lea    -0x86b44(%ebx),%eax
f0102da3:	50                   	push   %eax
f0102da4:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102daa:	50                   	push   %eax
f0102dab:	68 0b 03 00 00       	push   $0x30b
f0102db0:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102db6:	50                   	push   %eax
f0102db7:	e8 f5 d2 ff ff       	call   f01000b1 <_panic>
			assert(pgdir[i] & PTE_P);
f0102dbc:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0102dc0:	74 52                	je     f0102e14 <mem_init+0x191d>
	for (i = 0; i < NPDENTRIES; i++) {
f0102dc2:	83 c0 01             	add    $0x1,%eax
f0102dc5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102dca:	0f 87 bb 00 00 00    	ja     f0102e8b <mem_init+0x1994>
		switch (i) {
f0102dd0:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102dd5:	72 0e                	jb     f0102de5 <mem_init+0x18ee>
f0102dd7:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102ddc:	76 de                	jbe    f0102dbc <mem_init+0x18c5>
f0102dde:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102de3:	74 d7                	je     f0102dbc <mem_init+0x18c5>
			if (i >= PDX(KERNBASE)) {
f0102de5:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102dea:	77 4a                	ja     f0102e36 <mem_init+0x193f>
				assert(pgdir[i] == 0);
f0102dec:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102df0:	74 d0                	je     f0102dc2 <mem_init+0x18cb>
f0102df2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102df5:	8d 83 f2 8d f7 ff    	lea    -0x8720e(%ebx),%eax
f0102dfb:	50                   	push   %eax
f0102dfc:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102e02:	50                   	push   %eax
f0102e03:	68 1b 03 00 00       	push   $0x31b
f0102e08:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102e0e:	50                   	push   %eax
f0102e0f:	e8 9d d2 ff ff       	call   f01000b1 <_panic>
			assert(pgdir[i] & PTE_P);
f0102e14:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e17:	8d 83 d0 8d f7 ff    	lea    -0x87230(%ebx),%eax
f0102e1d:	50                   	push   %eax
f0102e1e:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102e24:	50                   	push   %eax
f0102e25:	68 14 03 00 00       	push   $0x314
f0102e2a:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102e30:	50                   	push   %eax
f0102e31:	e8 7b d2 ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_P);
f0102e36:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0102e39:	f6 c2 01             	test   $0x1,%dl
f0102e3c:	74 2b                	je     f0102e69 <mem_init+0x1972>
				assert(pgdir[i] & PTE_W);
f0102e3e:	f6 c2 02             	test   $0x2,%dl
f0102e41:	0f 85 7b ff ff ff    	jne    f0102dc2 <mem_init+0x18cb>
f0102e47:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e4a:	8d 83 e1 8d f7 ff    	lea    -0x8721f(%ebx),%eax
f0102e50:	50                   	push   %eax
f0102e51:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102e57:	50                   	push   %eax
f0102e58:	68 19 03 00 00       	push   $0x319
f0102e5d:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102e63:	50                   	push   %eax
f0102e64:	e8 48 d2 ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_P);
f0102e69:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e6c:	8d 83 d0 8d f7 ff    	lea    -0x87230(%ebx),%eax
f0102e72:	50                   	push   %eax
f0102e73:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0102e79:	50                   	push   %eax
f0102e7a:	68 18 03 00 00       	push   $0x318
f0102e7f:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102e85:	50                   	push   %eax
f0102e86:	e8 26 d2 ff ff       	call   f01000b1 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102e8b:	83 ec 0c             	sub    $0xc,%esp
f0102e8e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102e91:	8d 87 ec 94 f7 ff    	lea    -0x86b14(%edi),%eax
f0102e97:	50                   	push   %eax
f0102e98:	89 fb                	mov    %edi,%ebx
f0102e9a:	e8 78 0d 00 00       	call   f0103c17 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102e9f:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f0102ea5:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102ea7:	83 c4 10             	add    $0x10,%esp
f0102eaa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102eaf:	0f 86 44 02 00 00    	jbe    f01030f9 <mem_init+0x1c02>
	return (physaddr_t)kva - KERNBASE;
f0102eb5:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102eba:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102ebd:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ec2:	e8 4a de ff ff       	call   f0100d11 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102ec7:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102eca:	83 e0 f3             	and    $0xfffffff3,%eax
f0102ecd:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102ed2:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102ed5:	83 ec 0c             	sub    $0xc,%esp
f0102ed8:	6a 00                	push   $0x0
f0102eda:	e8 8e e2 ff ff       	call   f010116d <page_alloc>
f0102edf:	89 c6                	mov    %eax,%esi
f0102ee1:	83 c4 10             	add    $0x10,%esp
f0102ee4:	85 c0                	test   %eax,%eax
f0102ee6:	0f 84 29 02 00 00    	je     f0103115 <mem_init+0x1c1e>
	assert((pp1 = page_alloc(0)));
f0102eec:	83 ec 0c             	sub    $0xc,%esp
f0102eef:	6a 00                	push   $0x0
f0102ef1:	e8 77 e2 ff ff       	call   f010116d <page_alloc>
f0102ef6:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102ef9:	83 c4 10             	add    $0x10,%esp
f0102efc:	85 c0                	test   %eax,%eax
f0102efe:	0f 84 33 02 00 00    	je     f0103137 <mem_init+0x1c40>
	assert((pp2 = page_alloc(0)));
f0102f04:	83 ec 0c             	sub    $0xc,%esp
f0102f07:	6a 00                	push   $0x0
f0102f09:	e8 5f e2 ff ff       	call   f010116d <page_alloc>
f0102f0e:	89 c7                	mov    %eax,%edi
f0102f10:	83 c4 10             	add    $0x10,%esp
f0102f13:	85 c0                	test   %eax,%eax
f0102f15:	0f 84 3e 02 00 00    	je     f0103159 <mem_init+0x1c62>
	page_free(pp0);
f0102f1b:	83 ec 0c             	sub    $0xc,%esp
f0102f1e:	56                   	push   %esi
f0102f1f:	e8 d1 e2 ff ff       	call   f01011f5 <page_free>
	return (pp - pages) << PGSHIFT;
f0102f24:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f27:	c7 c0 f0 ff 18 f0    	mov    $0xf018fff0,%eax
f0102f2d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102f30:	2b 08                	sub    (%eax),%ecx
f0102f32:	89 c8                	mov    %ecx,%eax
f0102f34:	c1 f8 03             	sar    $0x3,%eax
f0102f37:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102f3a:	89 c1                	mov    %eax,%ecx
f0102f3c:	c1 e9 0c             	shr    $0xc,%ecx
f0102f3f:	83 c4 10             	add    $0x10,%esp
f0102f42:	c7 c2 e8 ff 18 f0    	mov    $0xf018ffe8,%edx
f0102f48:	3b 0a                	cmp    (%edx),%ecx
f0102f4a:	0f 83 2b 02 00 00    	jae    f010317b <mem_init+0x1c84>
	memset(page2kva(pp1), 1, PGSIZE);
f0102f50:	83 ec 04             	sub    $0x4,%esp
f0102f53:	68 00 10 00 00       	push   $0x1000
f0102f58:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102f5a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102f5f:	50                   	push   %eax
f0102f60:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f63:	e8 e7 21 00 00       	call   f010514f <memset>
	return (pp - pages) << PGSHIFT;
f0102f68:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f6b:	c7 c0 f0 ff 18 f0    	mov    $0xf018fff0,%eax
f0102f71:	89 f9                	mov    %edi,%ecx
f0102f73:	2b 08                	sub    (%eax),%ecx
f0102f75:	89 c8                	mov    %ecx,%eax
f0102f77:	c1 f8 03             	sar    $0x3,%eax
f0102f7a:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102f7d:	89 c1                	mov    %eax,%ecx
f0102f7f:	c1 e9 0c             	shr    $0xc,%ecx
f0102f82:	83 c4 10             	add    $0x10,%esp
f0102f85:	c7 c2 e8 ff 18 f0    	mov    $0xf018ffe8,%edx
f0102f8b:	3b 0a                	cmp    (%edx),%ecx
f0102f8d:	0f 83 fe 01 00 00    	jae    f0103191 <mem_init+0x1c9a>
	memset(page2kva(pp2), 2, PGSIZE);
f0102f93:	83 ec 04             	sub    $0x4,%esp
f0102f96:	68 00 10 00 00       	push   $0x1000
f0102f9b:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102f9d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102fa2:	50                   	push   %eax
f0102fa3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fa6:	e8 a4 21 00 00       	call   f010514f <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102fab:	6a 02                	push   $0x2
f0102fad:	68 00 10 00 00       	push   $0x1000
f0102fb2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102fb5:	53                   	push   %ebx
f0102fb6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102fb9:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f0102fbf:	ff 30                	pushl  (%eax)
f0102fc1:	e8 b9 e4 ff ff       	call   f010147f <page_insert>
	assert(pp1->pp_ref == 1);
f0102fc6:	83 c4 20             	add    $0x20,%esp
f0102fc9:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102fce:	0f 85 d3 01 00 00    	jne    f01031a7 <mem_init+0x1cb0>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102fd4:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102fdb:	01 01 01 
f0102fde:	0f 85 e5 01 00 00    	jne    f01031c9 <mem_init+0x1cd2>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102fe4:	6a 02                	push   $0x2
f0102fe6:	68 00 10 00 00       	push   $0x1000
f0102feb:	57                   	push   %edi
f0102fec:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102fef:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f0102ff5:	ff 30                	pushl  (%eax)
f0102ff7:	e8 83 e4 ff ff       	call   f010147f <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102ffc:	83 c4 10             	add    $0x10,%esp
f0102fff:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103006:	02 02 02 
f0103009:	0f 85 dc 01 00 00    	jne    f01031eb <mem_init+0x1cf4>
	assert(pp2->pp_ref == 1);
f010300f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103014:	0f 85 f3 01 00 00    	jne    f010320d <mem_init+0x1d16>
	assert(pp1->pp_ref == 0);
f010301a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010301d:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0103022:	0f 85 07 02 00 00    	jne    f010322f <mem_init+0x1d38>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103028:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010302f:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0103032:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103035:	c7 c0 f0 ff 18 f0    	mov    $0xf018fff0,%eax
f010303b:	89 f9                	mov    %edi,%ecx
f010303d:	2b 08                	sub    (%eax),%ecx
f010303f:	89 c8                	mov    %ecx,%eax
f0103041:	c1 f8 03             	sar    $0x3,%eax
f0103044:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0103047:	89 c1                	mov    %eax,%ecx
f0103049:	c1 e9 0c             	shr    $0xc,%ecx
f010304c:	c7 c2 e8 ff 18 f0    	mov    $0xf018ffe8,%edx
f0103052:	3b 0a                	cmp    (%edx),%ecx
f0103054:	0f 83 f7 01 00 00    	jae    f0103251 <mem_init+0x1d5a>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010305a:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103061:	03 03 03 
f0103064:	0f 85 fd 01 00 00    	jne    f0103267 <mem_init+0x1d70>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010306a:	83 ec 08             	sub    $0x8,%esp
f010306d:	68 00 10 00 00       	push   $0x1000
f0103072:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103075:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f010307b:	ff 30                	pushl  (%eax)
f010307d:	e8 b1 e3 ff ff       	call   f0101433 <page_remove>
	assert(pp2->pp_ref == 0);
f0103082:	83 c4 10             	add    $0x10,%esp
f0103085:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010308a:	0f 85 f9 01 00 00    	jne    f0103289 <mem_init+0x1d92>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103090:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103093:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f0103099:	8b 08                	mov    (%eax),%ecx
f010309b:	8b 11                	mov    (%ecx),%edx
f010309d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f01030a3:	c7 c0 f0 ff 18 f0    	mov    $0xf018fff0,%eax
f01030a9:	89 f7                	mov    %esi,%edi
f01030ab:	2b 38                	sub    (%eax),%edi
f01030ad:	89 f8                	mov    %edi,%eax
f01030af:	c1 f8 03             	sar    $0x3,%eax
f01030b2:	c1 e0 0c             	shl    $0xc,%eax
f01030b5:	39 c2                	cmp    %eax,%edx
f01030b7:	0f 85 ee 01 00 00    	jne    f01032ab <mem_init+0x1db4>
	kern_pgdir[0] = 0;
f01030bd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01030c3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01030c8:	0f 85 ff 01 00 00    	jne    f01032cd <mem_init+0x1dd6>
	pp0->pp_ref = 0;
f01030ce:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f01030d4:	83 ec 0c             	sub    $0xc,%esp
f01030d7:	56                   	push   %esi
f01030d8:	e8 18 e1 ff ff       	call   f01011f5 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01030dd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030e0:	8d 83 80 95 f7 ff    	lea    -0x86a80(%ebx),%eax
f01030e6:	89 04 24             	mov    %eax,(%esp)
f01030e9:	e8 29 0b 00 00       	call   f0103c17 <cprintf>
}
f01030ee:	83 c4 10             	add    $0x10,%esp
f01030f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01030f4:	5b                   	pop    %ebx
f01030f5:	5e                   	pop    %esi
f01030f6:	5f                   	pop    %edi
f01030f7:	5d                   	pop    %ebp
f01030f8:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030f9:	50                   	push   %eax
f01030fa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030fd:	8d 83 68 8f f7 ff    	lea    -0x87098(%ebx),%eax
f0103103:	50                   	push   %eax
f0103104:	68 e4 00 00 00       	push   $0xe4
f0103109:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f010310f:	50                   	push   %eax
f0103110:	e8 9c cf ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f0103115:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103118:	8d 83 ee 8b f7 ff    	lea    -0x87412(%ebx),%eax
f010311e:	50                   	push   %eax
f010311f:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0103125:	50                   	push   %eax
f0103126:	68 db 03 00 00       	push   $0x3db
f010312b:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0103131:	50                   	push   %eax
f0103132:	e8 7a cf ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0103137:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010313a:	8d 83 04 8c f7 ff    	lea    -0x873fc(%ebx),%eax
f0103140:	50                   	push   %eax
f0103141:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0103147:	50                   	push   %eax
f0103148:	68 dc 03 00 00       	push   $0x3dc
f010314d:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0103153:	50                   	push   %eax
f0103154:	e8 58 cf ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0103159:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010315c:	8d 83 1a 8c f7 ff    	lea    -0x873e6(%ebx),%eax
f0103162:	50                   	push   %eax
f0103163:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0103169:	50                   	push   %eax
f010316a:	68 dd 03 00 00       	push   $0x3dd
f010316f:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0103175:	50                   	push   %eax
f0103176:	e8 36 cf ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010317b:	50                   	push   %eax
f010317c:	8d 83 00 8e f7 ff    	lea    -0x87200(%ebx),%eax
f0103182:	50                   	push   %eax
f0103183:	6a 56                	push   $0x56
f0103185:	8d 83 05 8b f7 ff    	lea    -0x874fb(%ebx),%eax
f010318b:	50                   	push   %eax
f010318c:	e8 20 cf ff ff       	call   f01000b1 <_panic>
f0103191:	50                   	push   %eax
f0103192:	8d 83 00 8e f7 ff    	lea    -0x87200(%ebx),%eax
f0103198:	50                   	push   %eax
f0103199:	6a 56                	push   $0x56
f010319b:	8d 83 05 8b f7 ff    	lea    -0x874fb(%ebx),%eax
f01031a1:	50                   	push   %eax
f01031a2:	e8 0a cf ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f01031a7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01031aa:	8d 83 eb 8c f7 ff    	lea    -0x87315(%ebx),%eax
f01031b0:	50                   	push   %eax
f01031b1:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01031b7:	50                   	push   %eax
f01031b8:	68 e2 03 00 00       	push   $0x3e2
f01031bd:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01031c3:	50                   	push   %eax
f01031c4:	e8 e8 ce ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01031c9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01031cc:	8d 83 0c 95 f7 ff    	lea    -0x86af4(%ebx),%eax
f01031d2:	50                   	push   %eax
f01031d3:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01031d9:	50                   	push   %eax
f01031da:	68 e3 03 00 00       	push   $0x3e3
f01031df:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01031e5:	50                   	push   %eax
f01031e6:	e8 c6 ce ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01031eb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01031ee:	8d 83 30 95 f7 ff    	lea    -0x86ad0(%ebx),%eax
f01031f4:	50                   	push   %eax
f01031f5:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01031fb:	50                   	push   %eax
f01031fc:	68 e5 03 00 00       	push   $0x3e5
f0103201:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0103207:	50                   	push   %eax
f0103208:	e8 a4 ce ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f010320d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103210:	8d 83 0d 8d f7 ff    	lea    -0x872f3(%ebx),%eax
f0103216:	50                   	push   %eax
f0103217:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f010321d:	50                   	push   %eax
f010321e:	68 e6 03 00 00       	push   $0x3e6
f0103223:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0103229:	50                   	push   %eax
f010322a:	e8 82 ce ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f010322f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103232:	8d 83 77 8d f7 ff    	lea    -0x87289(%ebx),%eax
f0103238:	50                   	push   %eax
f0103239:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f010323f:	50                   	push   %eax
f0103240:	68 e7 03 00 00       	push   $0x3e7
f0103245:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f010324b:	50                   	push   %eax
f010324c:	e8 60 ce ff ff       	call   f01000b1 <_panic>
f0103251:	50                   	push   %eax
f0103252:	8d 83 00 8e f7 ff    	lea    -0x87200(%ebx),%eax
f0103258:	50                   	push   %eax
f0103259:	6a 56                	push   $0x56
f010325b:	8d 83 05 8b f7 ff    	lea    -0x874fb(%ebx),%eax
f0103261:	50                   	push   %eax
f0103262:	e8 4a ce ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103267:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010326a:	8d 83 54 95 f7 ff    	lea    -0x86aac(%ebx),%eax
f0103270:	50                   	push   %eax
f0103271:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0103277:	50                   	push   %eax
f0103278:	68 e9 03 00 00       	push   $0x3e9
f010327d:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0103283:	50                   	push   %eax
f0103284:	e8 28 ce ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0103289:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010328c:	8d 83 45 8d f7 ff    	lea    -0x872bb(%ebx),%eax
f0103292:	50                   	push   %eax
f0103293:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0103299:	50                   	push   %eax
f010329a:	68 eb 03 00 00       	push   $0x3eb
f010329f:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01032a5:	50                   	push   %eax
f01032a6:	e8 06 ce ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01032ab:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01032ae:	8d 83 64 90 f7 ff    	lea    -0x86f9c(%ebx),%eax
f01032b4:	50                   	push   %eax
f01032b5:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01032bb:	50                   	push   %eax
f01032bc:	68 ee 03 00 00       	push   $0x3ee
f01032c1:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01032c7:	50                   	push   %eax
f01032c8:	e8 e4 cd ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f01032cd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01032d0:	8d 83 fc 8c f7 ff    	lea    -0x87304(%ebx),%eax
f01032d6:	50                   	push   %eax
f01032d7:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01032dd:	50                   	push   %eax
f01032de:	68 f0 03 00 00       	push   $0x3f0
f01032e3:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f01032e9:	50                   	push   %eax
f01032ea:	e8 c2 cd ff ff       	call   f01000b1 <_panic>

f01032ef <tlb_invalidate>:
{
f01032ef:	55                   	push   %ebp
f01032f0:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01032f2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032f5:	0f 01 38             	invlpg (%eax)
}
f01032f8:	5d                   	pop    %ebp
f01032f9:	c3                   	ret    

f01032fa <user_mem_check>:
{
f01032fa:	55                   	push   %ebp
f01032fb:	89 e5                	mov    %esp,%ebp
f01032fd:	57                   	push   %edi
f01032fe:	56                   	push   %esi
f01032ff:	53                   	push   %ebx
f0103300:	83 ec 1c             	sub    $0x1c,%esp
f0103303:	e8 01 d4 ff ff       	call   f0100709 <__x86.get_pc_thunk.ax>
f0103308:	05 18 9d 08 00       	add    $0x89d18,%eax
f010330d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103310:	8b 75 14             	mov    0x14(%ebp),%esi
	start = ROUNDDOWN((char*)va, PGSIZE);
f0103313:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103316:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010331c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	end = ROUNDUP((char *)(va+len), PGSIZE);
f010331f:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103322:	03 7d 10             	add    0x10(%ebp),%edi
f0103325:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
f010332b:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for(;start<end; start+=PGSIZE){
f0103331:	39 fb                	cmp    %edi,%ebx
f0103333:	73 60                	jae    f0103395 <user_mem_check+0x9b>
		pdir = pgdir_walk(env->env_pgdir, (void *)start, 0);
f0103335:	83 ec 04             	sub    $0x4,%esp
f0103338:	6a 00                	push   $0x0
f010333a:	53                   	push   %ebx
f010333b:	8b 45 08             	mov    0x8(%ebp),%eax
f010333e:	ff 70 5c             	pushl  0x5c(%eax)
f0103341:	e8 4a df ff ff       	call   f0101290 <pgdir_walk>
		if((int)start>ULIM||pdir==NULL||((uint32_t)(*pdir)&perm)!=perm){
f0103346:	89 da                	mov    %ebx,%edx
f0103348:	83 c4 10             	add    $0x10,%esp
f010334b:	81 fb 00 00 80 ef    	cmp    $0xef800000,%ebx
f0103351:	77 14                	ja     f0103367 <user_mem_check+0x6d>
f0103353:	85 c0                	test   %eax,%eax
f0103355:	74 10                	je     f0103367 <user_mem_check+0x6d>
f0103357:	89 f1                	mov    %esi,%ecx
f0103359:	23 08                	and    (%eax),%ecx
f010335b:	39 ce                	cmp    %ecx,%esi
f010335d:	75 08                	jne    f0103367 <user_mem_check+0x6d>
	for(;start<end; start+=PGSIZE){
f010335f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103365:	eb ca                	jmp    f0103331 <user_mem_check+0x37>
			if(start == ROUNDDOWN((char*)va, PGSIZE)){
f0103367:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010336a:	74 16                	je     f0103382 <user_mem_check+0x88>
				user_mem_check_addr = (uint32_t)start;
f010336c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010336f:	89 90 fc 22 00 00    	mov    %edx,0x22fc(%eax)
			return -E_FAULT;
f0103375:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f010337a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010337d:	5b                   	pop    %ebx
f010337e:	5e                   	pop    %esi
f010337f:	5f                   	pop    %edi
f0103380:	5d                   	pop    %ebp
f0103381:	c3                   	ret    
				user_mem_check_addr = (uint32_t)va;
f0103382:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103385:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103388:	89 90 fc 22 00 00    	mov    %edx,0x22fc(%eax)
			return -E_FAULT;
f010338e:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103393:	eb e5                	jmp    f010337a <user_mem_check+0x80>
	return 0;
f0103395:	b8 00 00 00 00       	mov    $0x0,%eax
f010339a:	eb de                	jmp    f010337a <user_mem_check+0x80>

f010339c <user_mem_assert>:
{
f010339c:	55                   	push   %ebp
f010339d:	89 e5                	mov    %esp,%ebp
f010339f:	56                   	push   %esi
f01033a0:	53                   	push   %ebx
f01033a1:	e8 c1 cd ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01033a6:	81 c3 7a 9c 08 00    	add    $0x89c7a,%ebx
f01033ac:	8b 75 08             	mov    0x8(%ebp),%esi
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01033af:	8b 45 14             	mov    0x14(%ebp),%eax
f01033b2:	83 c8 04             	or     $0x4,%eax
f01033b5:	50                   	push   %eax
f01033b6:	ff 75 10             	pushl  0x10(%ebp)
f01033b9:	ff 75 0c             	pushl  0xc(%ebp)
f01033bc:	56                   	push   %esi
f01033bd:	e8 38 ff ff ff       	call   f01032fa <user_mem_check>
f01033c2:	83 c4 10             	add    $0x10,%esp
f01033c5:	85 c0                	test   %eax,%eax
f01033c7:	78 07                	js     f01033d0 <user_mem_assert+0x34>
}
f01033c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01033cc:	5b                   	pop    %ebx
f01033cd:	5e                   	pop    %esi
f01033ce:	5d                   	pop    %ebp
f01033cf:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f01033d0:	83 ec 04             	sub    $0x4,%esp
f01033d3:	ff b3 fc 22 00 00    	pushl  0x22fc(%ebx)
f01033d9:	ff 76 48             	pushl  0x48(%esi)
f01033dc:	8d 83 ac 95 f7 ff    	lea    -0x86a54(%ebx),%eax
f01033e2:	50                   	push   %eax
f01033e3:	e8 2f 08 00 00       	call   f0103c17 <cprintf>
		env_destroy(env);	// may not return
f01033e8:	89 34 24             	mov    %esi,(%esp)
f01033eb:	e8 bd 06 00 00       	call   f0103aad <env_destroy>
f01033f0:	83 c4 10             	add    $0x10,%esp
}
f01033f3:	eb d4                	jmp    f01033c9 <user_mem_assert+0x2d>

f01033f5 <__x86.get_pc_thunk.cx>:
f01033f5:	8b 0c 24             	mov    (%esp),%ecx
f01033f8:	c3                   	ret    

f01033f9 <__x86.get_pc_thunk.di>:
f01033f9:	8b 3c 24             	mov    (%esp),%edi
f01033fc:	c3                   	ret    

f01033fd <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01033fd:	55                   	push   %ebp
f01033fe:	89 e5                	mov    %esp,%ebp
f0103400:	57                   	push   %edi
f0103401:	56                   	push   %esi
f0103402:	53                   	push   %ebx
f0103403:	83 ec 1c             	sub    $0x1c,%esp
f0103406:	e8 5c cd ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010340b:	81 c3 15 9c 08 00    	add    $0x89c15,%ebx
f0103411:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	void* start = (void *)ROUNDDOWN((uint32_t)va, PGSIZE);
f0103413:	89 d6                	mov    %edx,%esi
f0103415:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    	void* end = (void *)ROUNDUP((uint32_t)va+len, PGSIZE);
f010341b:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0103422:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103427:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    	struct PageInfo *p = NULL;
    	void* i;
    	int r;
    	for(i=start; i<end; i+=PGSIZE){
f010342a:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f010342d:	73 62                	jae    f0103491 <region_alloc+0x94>
        	p = page_alloc(0);
f010342f:	83 ec 0c             	sub    $0xc,%esp
f0103432:	6a 00                	push   $0x0
f0103434:	e8 34 dd ff ff       	call   f010116d <page_alloc>
        	if(p == NULL)
f0103439:	83 c4 10             	add    $0x10,%esp
f010343c:	85 c0                	test   %eax,%eax
f010343e:	74 1b                	je     f010345b <region_alloc+0x5e>
            	panic(" region alloc, allocation failed.");

        	r = page_insert(e->env_pgdir, p, i, PTE_W | PTE_U);
f0103440:	6a 06                	push   $0x6
f0103442:	56                   	push   %esi
f0103443:	50                   	push   %eax
f0103444:	ff 77 5c             	pushl  0x5c(%edi)
f0103447:	e8 33 e0 ff ff       	call   f010147f <page_insert>
        	if(r != 0) {
f010344c:	83 c4 10             	add    $0x10,%esp
f010344f:	85 c0                	test   %eax,%eax
f0103451:	75 23                	jne    f0103476 <region_alloc+0x79>
    	for(i=start; i<end; i+=PGSIZE){
f0103453:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103459:	eb cf                	jmp    f010342a <region_alloc+0x2d>
            	panic(" region alloc, allocation failed.");
f010345b:	83 ec 04             	sub    $0x4,%esp
f010345e:	8d 83 e4 95 f7 ff    	lea    -0x86a1c(%ebx),%eax
f0103464:	50                   	push   %eax
f0103465:	68 23 01 00 00       	push   $0x123
f010346a:	8d 83 ce 96 f7 ff    	lea    -0x86932(%ebx),%eax
f0103470:	50                   	push   %eax
f0103471:	e8 3b cc ff ff       	call   f01000b1 <_panic>
            		panic("region alloc error");
f0103476:	83 ec 04             	sub    $0x4,%esp
f0103479:	8d 83 d9 96 f7 ff    	lea    -0x86927(%ebx),%eax
f010347f:	50                   	push   %eax
f0103480:	68 27 01 00 00       	push   $0x127
f0103485:	8d 83 ce 96 f7 ff    	lea    -0x86932(%ebx),%eax
f010348b:	50                   	push   %eax
f010348c:	e8 20 cc ff ff       	call   f01000b1 <_panic>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0103491:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103494:	5b                   	pop    %ebx
f0103495:	5e                   	pop    %esi
f0103496:	5f                   	pop    %edi
f0103497:	5d                   	pop    %ebp
f0103498:	c3                   	ret    

f0103499 <envid2env>:
{
f0103499:	55                   	push   %ebp
f010349a:	89 e5                	mov    %esp,%ebp
f010349c:	53                   	push   %ebx
f010349d:	e8 53 ff ff ff       	call   f01033f5 <__x86.get_pc_thunk.cx>
f01034a2:	81 c1 7e 9b 08 00    	add    $0x89b7e,%ecx
f01034a8:	8b 55 08             	mov    0x8(%ebp),%edx
f01034ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if (envid == 0) {
f01034ae:	85 d2                	test   %edx,%edx
f01034b0:	74 41                	je     f01034f3 <envid2env+0x5a>
	e = &envs[ENVX(envid)];
f01034b2:	89 d0                	mov    %edx,%eax
f01034b4:	25 ff 03 00 00       	and    $0x3ff,%eax
f01034b9:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01034bc:	c1 e0 05             	shl    $0x5,%eax
f01034bf:	03 81 0c 23 00 00    	add    0x230c(%ecx),%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01034c5:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f01034c9:	74 3a                	je     f0103505 <envid2env+0x6c>
f01034cb:	39 50 48             	cmp    %edx,0x48(%eax)
f01034ce:	75 35                	jne    f0103505 <envid2env+0x6c>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01034d0:	84 db                	test   %bl,%bl
f01034d2:	74 12                	je     f01034e6 <envid2env+0x4d>
f01034d4:	8b 91 08 23 00 00    	mov    0x2308(%ecx),%edx
f01034da:	39 c2                	cmp    %eax,%edx
f01034dc:	74 08                	je     f01034e6 <envid2env+0x4d>
f01034de:	8b 5a 48             	mov    0x48(%edx),%ebx
f01034e1:	39 58 4c             	cmp    %ebx,0x4c(%eax)
f01034e4:	75 2f                	jne    f0103515 <envid2env+0x7c>
	*env_store = e;
f01034e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01034e9:	89 03                	mov    %eax,(%ebx)
	return 0;
f01034eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01034f0:	5b                   	pop    %ebx
f01034f1:	5d                   	pop    %ebp
f01034f2:	c3                   	ret    
		*env_store = curenv;
f01034f3:	8b 81 08 23 00 00    	mov    0x2308(%ecx),%eax
f01034f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01034fc:	89 01                	mov    %eax,(%ecx)
		return 0;
f01034fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0103503:	eb eb                	jmp    f01034f0 <envid2env+0x57>
		*env_store = 0;
f0103505:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103508:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010350e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103513:	eb db                	jmp    f01034f0 <envid2env+0x57>
		*env_store = 0;
f0103515:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103518:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010351e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103523:	eb cb                	jmp    f01034f0 <envid2env+0x57>

f0103525 <env_init_percpu>:
{
f0103525:	55                   	push   %ebp
f0103526:	89 e5                	mov    %esp,%ebp
f0103528:	e8 dc d1 ff ff       	call   f0100709 <__x86.get_pc_thunk.ax>
f010352d:	05 f3 9a 08 00       	add    $0x89af3,%eax
	asm volatile("lgdt (%0)" : : "r" (p));
f0103532:	8d 80 e0 1f 00 00    	lea    0x1fe0(%eax),%eax
f0103538:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f010353b:	b8 23 00 00 00       	mov    $0x23,%eax
f0103540:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103542:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103544:	b8 10 00 00 00       	mov    $0x10,%eax
f0103549:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f010354b:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f010354d:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f010354f:	ea 56 35 10 f0 08 00 	ljmp   $0x8,$0xf0103556
	asm volatile("lldt %0" : : "r" (sel));
f0103556:	b8 00 00 00 00       	mov    $0x0,%eax
f010355b:	0f 00 d0             	lldt   %ax
}
f010355e:	5d                   	pop    %ebp
f010355f:	c3                   	ret    

f0103560 <env_init>:
{
f0103560:	55                   	push   %ebp
f0103561:	89 e5                	mov    %esp,%ebp
f0103563:	57                   	push   %edi
f0103564:	56                   	push   %esi
f0103565:	53                   	push   %ebx
f0103566:	e8 8e fe ff ff       	call   f01033f9 <__x86.get_pc_thunk.di>
f010356b:	81 c7 b5 9a 08 00    	add    $0x89ab5,%edi
        envs[i].env_id = 0;
f0103571:	8b b7 0c 23 00 00    	mov    0x230c(%edi),%esi
f0103577:	8d 86 a0 7f 01 00    	lea    0x17fa0(%esi),%eax
f010357d:	8d 5e a0             	lea    -0x60(%esi),%ebx
f0103580:	ba 00 00 00 00       	mov    $0x0,%edx
f0103585:	89 c1                	mov    %eax,%ecx
f0103587:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
        envs[i].env_status = ENV_FREE;
f010358e:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
        envs[i].env_link = env_free_list;
f0103595:	89 50 44             	mov    %edx,0x44(%eax)
f0103598:	83 e8 60             	sub    $0x60,%eax
        env_free_list = &envs[i];
f010359b:	89 ca                	mov    %ecx,%edx
    for(i=NENV-1; i>=0; i--){
f010359d:	39 d8                	cmp    %ebx,%eax
f010359f:	75 e4                	jne    f0103585 <env_init+0x25>
f01035a1:	89 b7 10 23 00 00    	mov    %esi,0x2310(%edi)
    env_init_percpu();
f01035a7:	e8 79 ff ff ff       	call   f0103525 <env_init_percpu>
}
f01035ac:	5b                   	pop    %ebx
f01035ad:	5e                   	pop    %esi
f01035ae:	5f                   	pop    %edi
f01035af:	5d                   	pop    %ebp
f01035b0:	c3                   	ret    

f01035b1 <env_alloc>:
{
f01035b1:	55                   	push   %ebp
f01035b2:	89 e5                	mov    %esp,%ebp
f01035b4:	57                   	push   %edi
f01035b5:	56                   	push   %esi
f01035b6:	53                   	push   %ebx
f01035b7:	83 ec 0c             	sub    $0xc,%esp
f01035ba:	e8 a8 cb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01035bf:	81 c3 61 9a 08 00    	add    $0x89a61,%ebx
	if (!(e = env_free_list))
f01035c5:	8b b3 10 23 00 00    	mov    0x2310(%ebx),%esi
f01035cb:	85 f6                	test   %esi,%esi
f01035cd:	0f 84 81 01 00 00    	je     f0103754 <env_alloc+0x1a3>
	if (!(p = page_alloc(ALLOC_ZERO)))
f01035d3:	83 ec 0c             	sub    $0xc,%esp
f01035d6:	6a 01                	push   $0x1
f01035d8:	e8 90 db ff ff       	call   f010116d <page_alloc>
f01035dd:	83 c4 10             	add    $0x10,%esp
f01035e0:	85 c0                	test   %eax,%eax
f01035e2:	0f 84 73 01 00 00    	je     f010375b <env_alloc+0x1aa>
	return (pp - pages) << PGSHIFT;
f01035e8:	c7 c2 f0 ff 18 f0    	mov    $0xf018fff0,%edx
f01035ee:	89 c7                	mov    %eax,%edi
f01035f0:	2b 3a                	sub    (%edx),%edi
f01035f2:	89 fa                	mov    %edi,%edx
f01035f4:	c1 fa 03             	sar    $0x3,%edx
f01035f7:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01035fa:	89 d7                	mov    %edx,%edi
f01035fc:	c1 ef 0c             	shr    $0xc,%edi
f01035ff:	c7 c1 e8 ff 18 f0    	mov    $0xf018ffe8,%ecx
f0103605:	3b 39                	cmp    (%ecx),%edi
f0103607:	0f 83 18 01 00 00    	jae    f0103725 <env_alloc+0x174>
	return (void *)(pa + KERNBASE);
f010360d:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103613:	89 56 5c             	mov    %edx,0x5c(%esi)
    	p->pp_ref++;
f0103616:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f010361b:	b8 00 00 00 00       	mov    $0x0,%eax
        	e->env_pgdir[i] = 0;        
f0103620:	8b 56 5c             	mov    0x5c(%esi),%edx
f0103623:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f010362a:	83 c0 04             	add    $0x4,%eax
   	 for(i = 0; i < PDX(UTOP); i++) {
f010362d:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103632:	75 ec                	jne    f0103620 <env_alloc+0x6f>
        	e->env_pgdir[i] = kern_pgdir[i];
f0103634:	c7 c7 ec ff 18 f0    	mov    $0xf018ffec,%edi
f010363a:	8b 17                	mov    (%edi),%edx
f010363c:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f010363f:	8b 56 5c             	mov    0x5c(%esi),%edx
f0103642:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0103645:	83 c0 04             	add    $0x4,%eax
   	 for(i = PDX(UTOP); i < NPDENTRIES; i++) {
f0103648:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010364d:	75 eb                	jne    f010363a <env_alloc+0x89>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010364f:	8b 46 5c             	mov    0x5c(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103652:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103657:	0f 86 de 00 00 00    	jbe    f010373b <env_alloc+0x18a>
	return (physaddr_t)kva - KERNBASE;
f010365d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103663:	83 ca 05             	or     $0x5,%edx
f0103666:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010366c:	8b 46 48             	mov    0x48(%esi),%eax
f010366f:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103674:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103679:	ba 00 10 00 00       	mov    $0x1000,%edx
f010367e:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103681:	89 f2                	mov    %esi,%edx
f0103683:	2b 93 0c 23 00 00    	sub    0x230c(%ebx),%edx
f0103689:	c1 fa 05             	sar    $0x5,%edx
f010368c:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0103692:	09 d0                	or     %edx,%eax
f0103694:	89 46 48             	mov    %eax,0x48(%esi)
	e->env_parent_id = parent_id;
f0103697:	8b 45 0c             	mov    0xc(%ebp),%eax
f010369a:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f010369d:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f01036a4:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f01036ab:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01036b2:	83 ec 04             	sub    $0x4,%esp
f01036b5:	6a 44                	push   $0x44
f01036b7:	6a 00                	push   $0x0
f01036b9:	56                   	push   %esi
f01036ba:	e8 90 1a 00 00       	call   f010514f <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f01036bf:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f01036c5:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f01036cb:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f01036d1:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f01036d8:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	env_free_list = e->env_link;
f01036de:	8b 46 44             	mov    0x44(%esi),%eax
f01036e1:	89 83 10 23 00 00    	mov    %eax,0x2310(%ebx)
	*newenv_store = e;
f01036e7:	8b 45 08             	mov    0x8(%ebp),%eax
f01036ea:	89 30                	mov    %esi,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01036ec:	8b 4e 48             	mov    0x48(%esi),%ecx
f01036ef:	8b 83 08 23 00 00    	mov    0x2308(%ebx),%eax
f01036f5:	83 c4 10             	add    $0x10,%esp
f01036f8:	ba 00 00 00 00       	mov    $0x0,%edx
f01036fd:	85 c0                	test   %eax,%eax
f01036ff:	74 03                	je     f0103704 <env_alloc+0x153>
f0103701:	8b 50 48             	mov    0x48(%eax),%edx
f0103704:	83 ec 04             	sub    $0x4,%esp
f0103707:	51                   	push   %ecx
f0103708:	52                   	push   %edx
f0103709:	8d 83 ec 96 f7 ff    	lea    -0x86914(%ebx),%eax
f010370f:	50                   	push   %eax
f0103710:	e8 02 05 00 00       	call   f0103c17 <cprintf>
	return 0;
f0103715:	83 c4 10             	add    $0x10,%esp
f0103718:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010371d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103720:	5b                   	pop    %ebx
f0103721:	5e                   	pop    %esi
f0103722:	5f                   	pop    %edi
f0103723:	5d                   	pop    %ebp
f0103724:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103725:	52                   	push   %edx
f0103726:	8d 83 00 8e f7 ff    	lea    -0x87200(%ebx),%eax
f010372c:	50                   	push   %eax
f010372d:	6a 56                	push   $0x56
f010372f:	8d 83 05 8b f7 ff    	lea    -0x874fb(%ebx),%eax
f0103735:	50                   	push   %eax
f0103736:	e8 76 c9 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010373b:	50                   	push   %eax
f010373c:	8d 83 68 8f f7 ff    	lea    -0x87098(%ebx),%eax
f0103742:	50                   	push   %eax
f0103743:	68 cc 00 00 00       	push   $0xcc
f0103748:	8d 83 ce 96 f7 ff    	lea    -0x86932(%ebx),%eax
f010374e:	50                   	push   %eax
f010374f:	e8 5d c9 ff ff       	call   f01000b1 <_panic>
		return -E_NO_FREE_ENV;
f0103754:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103759:	eb c2                	jmp    f010371d <env_alloc+0x16c>
		return -E_NO_MEM;
f010375b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103760:	eb bb                	jmp    f010371d <env_alloc+0x16c>

f0103762 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103762:	55                   	push   %ebp
f0103763:	89 e5                	mov    %esp,%ebp
f0103765:	57                   	push   %edi
f0103766:	56                   	push   %esi
f0103767:	53                   	push   %ebx
f0103768:	83 ec 34             	sub    $0x34,%esp
f010376b:	e8 f7 c9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103770:	81 c3 b0 98 08 00    	add    $0x898b0,%ebx
	// LAB 3: Your code here.
	struct Env *e;
    	int rc;
    	if((rc = env_alloc(&e, 0)) != 0) {
f0103776:	6a 00                	push   $0x0
f0103778:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010377b:	50                   	push   %eax
f010377c:	e8 30 fe ff ff       	call   f01035b1 <env_alloc>
f0103781:	83 c4 10             	add    $0x10,%esp
f0103784:	85 c0                	test   %eax,%eax
f0103786:	75 46                	jne    f01037ce <env_create+0x6c>
        	panic("env_create failed: env_alloc failed.\n");
    	}

    	load_icode(e, binary);
f0103788:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010378b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    	if(header->e_magic != ELF_MAGIC) {
f010378e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103791:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f0103797:	75 50                	jne    f01037e9 <env_create+0x87>
    	if(header->e_entry == 0){
f0103799:	8b 45 08             	mov    0x8(%ebp),%eax
f010379c:	8b 40 18             	mov    0x18(%eax),%eax
f010379f:	85 c0                	test   %eax,%eax
f01037a1:	74 61                	je     f0103804 <env_create+0xa2>
    	e->env_tf.tf_eip = header->e_entry;
f01037a3:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01037a6:	89 41 30             	mov    %eax,0x30(%ecx)
    	lcr3(PADDR(e->env_pgdir));   //?????
f01037a9:	8b 41 5c             	mov    0x5c(%ecx),%eax
	if ((uint32_t)kva < KERNBASE)
f01037ac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037b1:	76 6c                	jbe    f010381f <env_create+0xbd>
	return (physaddr_t)kva - KERNBASE;
f01037b3:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01037b8:	0f 22 d8             	mov    %eax,%cr3
    	ph = (struct Proghdr* )((uint8_t *)header + header->e_phoff);
f01037bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01037be:	89 c6                	mov    %eax,%esi
f01037c0:	03 70 1c             	add    0x1c(%eax),%esi
    	eph = ph + header->e_phnum;
f01037c3:	0f b7 78 2c          	movzwl 0x2c(%eax),%edi
f01037c7:	c1 e7 05             	shl    $0x5,%edi
f01037ca:	01 f7                	add    %esi,%edi
f01037cc:	eb 6d                	jmp    f010383b <env_create+0xd9>
        	panic("env_create failed: env_alloc failed.\n");
f01037ce:	83 ec 04             	sub    $0x4,%esp
f01037d1:	8d 83 08 96 f7 ff    	lea    -0x869f8(%ebx),%eax
f01037d7:	50                   	push   %eax
f01037d8:	68 98 01 00 00       	push   $0x198
f01037dd:	8d 83 ce 96 f7 ff    	lea    -0x86932(%ebx),%eax
f01037e3:	50                   	push   %eax
f01037e4:	e8 c8 c8 ff ff       	call   f01000b1 <_panic>
        	panic("load_icode failed: The binary we load is not elf.\n");
f01037e9:	83 ec 04             	sub    $0x4,%esp
f01037ec:	8d 83 30 96 f7 ff    	lea    -0x869d0(%ebx),%eax
f01037f2:	50                   	push   %eax
f01037f3:	68 6b 01 00 00       	push   $0x16b
f01037f8:	8d 83 ce 96 f7 ff    	lea    -0x86932(%ebx),%eax
f01037fe:	50                   	push   %eax
f01037ff:	e8 ad c8 ff ff       	call   f01000b1 <_panic>
        	panic("load_icode failed: The elf file can't be excuterd.\n");
f0103804:	83 ec 04             	sub    $0x4,%esp
f0103807:	8d 83 64 96 f7 ff    	lea    -0x8699c(%ebx),%eax
f010380d:	50                   	push   %eax
f010380e:	68 6f 01 00 00       	push   $0x16f
f0103813:	8d 83 ce 96 f7 ff    	lea    -0x86932(%ebx),%eax
f0103819:	50                   	push   %eax
f010381a:	e8 92 c8 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010381f:	50                   	push   %eax
f0103820:	8d 83 68 8f f7 ff    	lea    -0x87098(%ebx),%eax
f0103826:	50                   	push   %eax
f0103827:	68 74 01 00 00       	push   $0x174
f010382c:	8d 83 ce 96 f7 ff    	lea    -0x86932(%ebx),%eax
f0103832:	50                   	push   %eax
f0103833:	e8 79 c8 ff ff       	call   f01000b1 <_panic>
    	for(; ph < eph; ph++) {
f0103838:	83 c6 20             	add    $0x20,%esi
f010383b:	39 f7                	cmp    %esi,%edi
f010383d:	76 44                	jbe    f0103883 <env_create+0x121>
        	if(ph->p_type == ELF_PROG_LOAD) {
f010383f:	83 3e 01             	cmpl   $0x1,(%esi)
f0103842:	75 f4                	jne    f0103838 <env_create+0xd6>
            	region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103844:	8b 4e 14             	mov    0x14(%esi),%ecx
f0103847:	8b 56 08             	mov    0x8(%esi),%edx
f010384a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010384d:	e8 ab fb ff ff       	call   f01033fd <region_alloc>
            	memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103852:	83 ec 04             	sub    $0x4,%esp
f0103855:	ff 76 10             	pushl  0x10(%esi)
f0103858:	8b 45 08             	mov    0x8(%ebp),%eax
f010385b:	03 46 04             	add    0x4(%esi),%eax
f010385e:	50                   	push   %eax
f010385f:	ff 76 08             	pushl  0x8(%esi)
f0103862:	e8 35 19 00 00       	call   f010519c <memmove>
            	memset((void *)(ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f0103867:	8b 46 10             	mov    0x10(%esi),%eax
f010386a:	83 c4 0c             	add    $0xc,%esp
f010386d:	8b 56 14             	mov    0x14(%esi),%edx
f0103870:	29 c2                	sub    %eax,%edx
f0103872:	52                   	push   %edx
f0103873:	6a 00                	push   $0x0
f0103875:	03 46 08             	add    0x8(%esi),%eax
f0103878:	50                   	push   %eax
f0103879:	e8 d1 18 00 00       	call   f010514f <memset>
f010387e:	83 c4 10             	add    $0x10,%esp
f0103881:	eb b5                	jmp    f0103838 <env_create+0xd6>
	region_alloc(e,(void *)(USTACKTOP-PGSIZE), PGSIZE);
f0103883:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103888:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010388d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103890:	e8 68 fb ff ff       	call   f01033fd <region_alloc>
    	e->env_type = type;
f0103895:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103898:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010389b:	89 50 50             	mov    %edx,0x50(%eax)
}
f010389e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01038a1:	5b                   	pop    %ebx
f01038a2:	5e                   	pop    %esi
f01038a3:	5f                   	pop    %edi
f01038a4:	5d                   	pop    %ebp
f01038a5:	c3                   	ret    

f01038a6 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01038a6:	55                   	push   %ebp
f01038a7:	89 e5                	mov    %esp,%ebp
f01038a9:	57                   	push   %edi
f01038aa:	56                   	push   %esi
f01038ab:	53                   	push   %ebx
f01038ac:	83 ec 2c             	sub    $0x2c,%esp
f01038af:	e8 b3 c8 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01038b4:	81 c3 6c 97 08 00    	add    $0x8976c,%ebx
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01038ba:	8b 93 08 23 00 00    	mov    0x2308(%ebx),%edx
f01038c0:	3b 55 08             	cmp    0x8(%ebp),%edx
f01038c3:	75 17                	jne    f01038dc <env_free+0x36>
		lcr3(PADDR(kern_pgdir));
f01038c5:	c7 c0 ec ff 18 f0    	mov    $0xf018ffec,%eax
f01038cb:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01038cd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01038d2:	76 46                	jbe    f010391a <env_free+0x74>
	return (physaddr_t)kva - KERNBASE;
f01038d4:	05 00 00 00 10       	add    $0x10000000,%eax
f01038d9:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01038dc:	8b 45 08             	mov    0x8(%ebp),%eax
f01038df:	8b 48 48             	mov    0x48(%eax),%ecx
f01038e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01038e7:	85 d2                	test   %edx,%edx
f01038e9:	74 03                	je     f01038ee <env_free+0x48>
f01038eb:	8b 42 48             	mov    0x48(%edx),%eax
f01038ee:	83 ec 04             	sub    $0x4,%esp
f01038f1:	51                   	push   %ecx
f01038f2:	50                   	push   %eax
f01038f3:	8d 83 01 97 f7 ff    	lea    -0x868ff(%ebx),%eax
f01038f9:	50                   	push   %eax
f01038fa:	e8 18 03 00 00       	call   f0103c17 <cprintf>
f01038ff:	83 c4 10             	add    $0x10,%esp
f0103902:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	if (PGNUM(pa) >= npages)
f0103909:	c7 c0 e8 ff 18 f0    	mov    $0xf018ffe8,%eax
f010390f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if (PGNUM(pa) >= npages)
f0103912:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103915:	e9 9f 00 00 00       	jmp    f01039b9 <env_free+0x113>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010391a:	50                   	push   %eax
f010391b:	8d 83 68 8f f7 ff    	lea    -0x87098(%ebx),%eax
f0103921:	50                   	push   %eax
f0103922:	68 ad 01 00 00       	push   $0x1ad
f0103927:	8d 83 ce 96 f7 ff    	lea    -0x86932(%ebx),%eax
f010392d:	50                   	push   %eax
f010392e:	e8 7e c7 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103933:	50                   	push   %eax
f0103934:	8d 83 00 8e f7 ff    	lea    -0x87200(%ebx),%eax
f010393a:	50                   	push   %eax
f010393b:	68 bc 01 00 00       	push   $0x1bc
f0103940:	8d 83 ce 96 f7 ff    	lea    -0x86932(%ebx),%eax
f0103946:	50                   	push   %eax
f0103947:	e8 65 c7 ff ff       	call   f01000b1 <_panic>
f010394c:	83 c6 04             	add    $0x4,%esi
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010394f:	39 fe                	cmp    %edi,%esi
f0103951:	74 24                	je     f0103977 <env_free+0xd1>
			if (pt[pteno] & PTE_P)
f0103953:	f6 06 01             	testb  $0x1,(%esi)
f0103956:	74 f4                	je     f010394c <env_free+0xa6>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103958:	83 ec 08             	sub    $0x8,%esp
f010395b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010395e:	01 f0                	add    %esi,%eax
f0103960:	c1 e0 0a             	shl    $0xa,%eax
f0103963:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103966:	50                   	push   %eax
f0103967:	8b 45 08             	mov    0x8(%ebp),%eax
f010396a:	ff 70 5c             	pushl  0x5c(%eax)
f010396d:	e8 c1 da ff ff       	call   f0101433 <page_remove>
f0103972:	83 c4 10             	add    $0x10,%esp
f0103975:	eb d5                	jmp    f010394c <env_free+0xa6>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103977:	8b 45 08             	mov    0x8(%ebp),%eax
f010397a:	8b 40 5c             	mov    0x5c(%eax),%eax
f010397d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103980:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103987:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010398a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010398d:	3b 10                	cmp    (%eax),%edx
f010398f:	73 6f                	jae    f0103a00 <env_free+0x15a>
		page_decref(pa2page(pa));
f0103991:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103994:	c7 c0 f0 ff 18 f0    	mov    $0xf018fff0,%eax
f010399a:	8b 00                	mov    (%eax),%eax
f010399c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010399f:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01039a2:	50                   	push   %eax
f01039a3:	e8 bf d8 ff ff       	call   f0101267 <page_decref>
f01039a8:	83 c4 10             	add    $0x10,%esp
f01039ab:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f01039af:	8b 45 dc             	mov    -0x24(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01039b2:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01039b7:	74 5f                	je     f0103a18 <env_free+0x172>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01039b9:	8b 45 08             	mov    0x8(%ebp),%eax
f01039bc:	8b 40 5c             	mov    0x5c(%eax),%eax
f01039bf:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01039c2:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01039c5:	a8 01                	test   $0x1,%al
f01039c7:	74 e2                	je     f01039ab <env_free+0x105>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01039c9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01039ce:	89 c2                	mov    %eax,%edx
f01039d0:	c1 ea 0c             	shr    $0xc,%edx
f01039d3:	89 55 d8             	mov    %edx,-0x28(%ebp)
f01039d6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01039d9:	39 11                	cmp    %edx,(%ecx)
f01039db:	0f 86 52 ff ff ff    	jbe    f0103933 <env_free+0x8d>
	return (void *)(pa + KERNBASE);
f01039e1:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01039e7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01039ea:	c1 e2 14             	shl    $0x14,%edx
f01039ed:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01039f0:	8d b8 00 10 00 f0    	lea    -0xffff000(%eax),%edi
f01039f6:	f7 d8                	neg    %eax
f01039f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01039fb:	e9 53 ff ff ff       	jmp    f0103953 <env_free+0xad>
		panic("pa2page called with invalid pa");
f0103a00:	83 ec 04             	sub    $0x4,%esp
f0103a03:	8d 83 0c 8f f7 ff    	lea    -0x870f4(%ebx),%eax
f0103a09:	50                   	push   %eax
f0103a0a:	6a 4f                	push   $0x4f
f0103a0c:	8d 83 05 8b f7 ff    	lea    -0x874fb(%ebx),%eax
f0103a12:	50                   	push   %eax
f0103a13:	e8 99 c6 ff ff       	call   f01000b1 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103a18:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a1b:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103a1e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a23:	76 57                	jbe    f0103a7c <env_free+0x1d6>
	e->env_pgdir = 0;
f0103a25:	8b 55 08             	mov    0x8(%ebp),%edx
f0103a28:	c7 42 5c 00 00 00 00 	movl   $0x0,0x5c(%edx)
	return (physaddr_t)kva - KERNBASE;
f0103a2f:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103a34:	c1 e8 0c             	shr    $0xc,%eax
f0103a37:	c7 c2 e8 ff 18 f0    	mov    $0xf018ffe8,%edx
f0103a3d:	3b 02                	cmp    (%edx),%eax
f0103a3f:	73 54                	jae    f0103a95 <env_free+0x1ef>
	page_decref(pa2page(pa));
f0103a41:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103a44:	c7 c2 f0 ff 18 f0    	mov    $0xf018fff0,%edx
f0103a4a:	8b 12                	mov    (%edx),%edx
f0103a4c:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103a4f:	50                   	push   %eax
f0103a50:	e8 12 d8 ff ff       	call   f0101267 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103a55:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a58:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f0103a5f:	8b 83 10 23 00 00    	mov    0x2310(%ebx),%eax
f0103a65:	8b 55 08             	mov    0x8(%ebp),%edx
f0103a68:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f0103a6b:	89 93 10 23 00 00    	mov    %edx,0x2310(%ebx)
}
f0103a71:	83 c4 10             	add    $0x10,%esp
f0103a74:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103a77:	5b                   	pop    %ebx
f0103a78:	5e                   	pop    %esi
f0103a79:	5f                   	pop    %edi
f0103a7a:	5d                   	pop    %ebp
f0103a7b:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a7c:	50                   	push   %eax
f0103a7d:	8d 83 68 8f f7 ff    	lea    -0x87098(%ebx),%eax
f0103a83:	50                   	push   %eax
f0103a84:	68 ca 01 00 00       	push   $0x1ca
f0103a89:	8d 83 ce 96 f7 ff    	lea    -0x86932(%ebx),%eax
f0103a8f:	50                   	push   %eax
f0103a90:	e8 1c c6 ff ff       	call   f01000b1 <_panic>
		panic("pa2page called with invalid pa");
f0103a95:	83 ec 04             	sub    $0x4,%esp
f0103a98:	8d 83 0c 8f f7 ff    	lea    -0x870f4(%ebx),%eax
f0103a9e:	50                   	push   %eax
f0103a9f:	6a 4f                	push   $0x4f
f0103aa1:	8d 83 05 8b f7 ff    	lea    -0x874fb(%ebx),%eax
f0103aa7:	50                   	push   %eax
f0103aa8:	e8 04 c6 ff ff       	call   f01000b1 <_panic>

f0103aad <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0103aad:	55                   	push   %ebp
f0103aae:	89 e5                	mov    %esp,%ebp
f0103ab0:	53                   	push   %ebx
f0103ab1:	83 ec 10             	sub    $0x10,%esp
f0103ab4:	e8 ae c6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103ab9:	81 c3 67 95 08 00    	add    $0x89567,%ebx
	env_free(e);
f0103abf:	ff 75 08             	pushl  0x8(%ebp)
f0103ac2:	e8 df fd ff ff       	call   f01038a6 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0103ac7:	8d 83 98 96 f7 ff    	lea    -0x86968(%ebx),%eax
f0103acd:	89 04 24             	mov    %eax,(%esp)
f0103ad0:	e8 42 01 00 00       	call   f0103c17 <cprintf>
f0103ad5:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0103ad8:	83 ec 0c             	sub    $0xc,%esp
f0103adb:	6a 00                	push   $0x0
f0103add:	e8 6c cf ff ff       	call   f0100a4e <monitor>
f0103ae2:	83 c4 10             	add    $0x10,%esp
f0103ae5:	eb f1                	jmp    f0103ad8 <env_destroy+0x2b>

f0103ae7 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103ae7:	55                   	push   %ebp
f0103ae8:	89 e5                	mov    %esp,%ebp
f0103aea:	53                   	push   %ebx
f0103aeb:	83 ec 08             	sub    $0x8,%esp
f0103aee:	e8 74 c6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103af3:	81 c3 2d 95 08 00    	add    $0x8952d,%ebx
	asm volatile(
f0103af9:	8b 65 08             	mov    0x8(%ebp),%esp
f0103afc:	61                   	popa   
f0103afd:	07                   	pop    %es
f0103afe:	1f                   	pop    %ds
f0103aff:	83 c4 08             	add    $0x8,%esp
f0103b02:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103b03:	8d 83 17 97 f7 ff    	lea    -0x868e9(%ebx),%eax
f0103b09:	50                   	push   %eax
f0103b0a:	68 f3 01 00 00       	push   $0x1f3
f0103b0f:	8d 83 ce 96 f7 ff    	lea    -0x86932(%ebx),%eax
f0103b15:	50                   	push   %eax
f0103b16:	e8 96 c5 ff ff       	call   f01000b1 <_panic>

f0103b1b <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103b1b:	55                   	push   %ebp
f0103b1c:	89 e5                	mov    %esp,%ebp
f0103b1e:	53                   	push   %ebx
f0103b1f:	83 ec 04             	sub    $0x4,%esp
f0103b22:	e8 40 c6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103b27:	81 c3 f9 94 08 00    	add    $0x894f9,%ebx
f0103b2d:	8b 45 08             	mov    0x8(%ebp),%eax

	// Hint: This function loads the new environment's state from
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.
	if(curenv != NULL && curenv->env_status == ENV_RUNNING) {
f0103b30:	8b 93 08 23 00 00    	mov    0x2308(%ebx),%edx
f0103b36:	85 d2                	test   %edx,%edx
f0103b38:	74 06                	je     f0103b40 <env_run+0x25>
f0103b3a:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0103b3e:	74 35                	je     f0103b75 <env_run+0x5a>
        curenv->env_status = ENV_RUNNABLE;
    	}

    	curenv = e;
f0103b40:	89 83 08 23 00 00    	mov    %eax,0x2308(%ebx)
    	curenv->env_status = ENV_RUNNING;
f0103b46:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    	curenv->env_runs++;
f0103b4d:	83 40 58 01          	addl   $0x1,0x58(%eax)
    	lcr3(PADDR(curenv->env_pgdir));
f0103b51:	8b 50 5c             	mov    0x5c(%eax),%edx
	if ((uint32_t)kva < KERNBASE)
f0103b54:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103b5a:	77 22                	ja     f0103b7e <env_run+0x63>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103b5c:	52                   	push   %edx
f0103b5d:	8d 83 68 8f f7 ff    	lea    -0x87098(%ebx),%eax
f0103b63:	50                   	push   %eax
f0103b64:	68 16 02 00 00       	push   $0x216
f0103b69:	8d 83 ce 96 f7 ff    	lea    -0x86932(%ebx),%eax
f0103b6f:	50                   	push   %eax
f0103b70:	e8 3c c5 ff ff       	call   f01000b1 <_panic>
        curenv->env_status = ENV_RUNNABLE;
f0103b75:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
f0103b7c:	eb c2                	jmp    f0103b40 <env_run+0x25>
	return (physaddr_t)kva - KERNBASE;
f0103b7e:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103b84:	0f 22 da             	mov    %edx,%cr3

    	env_pop_tf(&curenv->env_tf);
f0103b87:	83 ec 0c             	sub    $0xc,%esp
f0103b8a:	50                   	push   %eax
f0103b8b:	e8 57 ff ff ff       	call   f0103ae7 <env_pop_tf>

f0103b90 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103b90:	55                   	push   %ebp
f0103b91:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103b93:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b96:	ba 70 00 00 00       	mov    $0x70,%edx
f0103b9b:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103b9c:	ba 71 00 00 00       	mov    $0x71,%edx
f0103ba1:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103ba2:	0f b6 c0             	movzbl %al,%eax
}
f0103ba5:	5d                   	pop    %ebp
f0103ba6:	c3                   	ret    

f0103ba7 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103ba7:	55                   	push   %ebp
f0103ba8:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103baa:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bad:	ba 70 00 00 00       	mov    $0x70,%edx
f0103bb2:	ee                   	out    %al,(%dx)
f0103bb3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103bb6:	ba 71 00 00 00       	mov    $0x71,%edx
f0103bbb:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103bbc:	5d                   	pop    %ebp
f0103bbd:	c3                   	ret    

f0103bbe <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103bbe:	55                   	push   %ebp
f0103bbf:	89 e5                	mov    %esp,%ebp
f0103bc1:	53                   	push   %ebx
f0103bc2:	83 ec 10             	sub    $0x10,%esp
f0103bc5:	e8 9d c5 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103bca:	81 c3 56 94 08 00    	add    $0x89456,%ebx
	cputchar(ch);
f0103bd0:	ff 75 08             	pushl  0x8(%ebp)
f0103bd3:	e8 06 cb ff ff       	call   f01006de <cputchar>
	*cnt++;
}
f0103bd8:	83 c4 10             	add    $0x10,%esp
f0103bdb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103bde:	c9                   	leave  
f0103bdf:	c3                   	ret    

f0103be0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103be0:	55                   	push   %ebp
f0103be1:	89 e5                	mov    %esp,%ebp
f0103be3:	53                   	push   %ebx
f0103be4:	83 ec 14             	sub    $0x14,%esp
f0103be7:	e8 7b c5 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103bec:	81 c3 34 94 08 00    	add    $0x89434,%ebx
	int cnt = 0;
f0103bf2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103bf9:	ff 75 0c             	pushl  0xc(%ebp)
f0103bfc:	ff 75 08             	pushl  0x8(%ebp)
f0103bff:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103c02:	50                   	push   %eax
f0103c03:	8d 83 9e 6b f7 ff    	lea    -0x89462(%ebx),%eax
f0103c09:	50                   	push   %eax
f0103c0a:	e8 bf 0d 00 00       	call   f01049ce <vprintfmt>
	return cnt;
}
f0103c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103c12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103c15:	c9                   	leave  
f0103c16:	c3                   	ret    

f0103c17 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103c17:	55                   	push   %ebp
f0103c18:	89 e5                	mov    %esp,%ebp
f0103c1a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103c1d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103c20:	50                   	push   %eax
f0103c21:	ff 75 08             	pushl  0x8(%ebp)
f0103c24:	e8 b7 ff ff ff       	call   f0103be0 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103c29:	c9                   	leave  
f0103c2a:	c3                   	ret    

f0103c2b <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103c2b:	55                   	push   %ebp
f0103c2c:	89 e5                	mov    %esp,%ebp
f0103c2e:	57                   	push   %edi
f0103c2f:	56                   	push   %esi
f0103c30:	53                   	push   %ebx
f0103c31:	83 ec 04             	sub    $0x4,%esp
f0103c34:	e8 2e c5 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103c39:	81 c3 e7 93 08 00    	add    $0x893e7,%ebx
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103c3f:	c7 83 44 2b 00 00 00 	movl   $0xf0000000,0x2b44(%ebx)
f0103c46:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103c49:	66 c7 83 48 2b 00 00 	movw   $0x10,0x2b48(%ebx)
f0103c50:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f0103c52:	66 c7 83 a6 2b 00 00 	movw   $0x68,0x2ba6(%ebx)
f0103c59:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103c5b:	c7 c0 00 c3 11 f0    	mov    $0xf011c300,%eax
f0103c61:	66 c7 40 28 67 00    	movw   $0x67,0x28(%eax)
f0103c67:	8d b3 40 2b 00 00    	lea    0x2b40(%ebx),%esi
f0103c6d:	66 89 70 2a          	mov    %si,0x2a(%eax)
f0103c71:	89 f2                	mov    %esi,%edx
f0103c73:	c1 ea 10             	shr    $0x10,%edx
f0103c76:	88 50 2c             	mov    %dl,0x2c(%eax)
f0103c79:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
f0103c7d:	83 e2 f0             	and    $0xfffffff0,%edx
f0103c80:	83 ca 09             	or     $0x9,%edx
f0103c83:	83 e2 9f             	and    $0xffffff9f,%edx
f0103c86:	83 ca 80             	or     $0xffffff80,%edx
f0103c89:	88 55 f3             	mov    %dl,-0xd(%ebp)
f0103c8c:	88 50 2d             	mov    %dl,0x2d(%eax)
f0103c8f:	0f b6 48 2e          	movzbl 0x2e(%eax),%ecx
f0103c93:	83 e1 c0             	and    $0xffffffc0,%ecx
f0103c96:	83 c9 40             	or     $0x40,%ecx
f0103c99:	83 e1 7f             	and    $0x7f,%ecx
f0103c9c:	88 48 2e             	mov    %cl,0x2e(%eax)
f0103c9f:	c1 ee 18             	shr    $0x18,%esi
f0103ca2:	89 f1                	mov    %esi,%ecx
f0103ca4:	88 48 2f             	mov    %cl,0x2f(%eax)
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103ca7:	0f b6 55 f3          	movzbl -0xd(%ebp),%edx
f0103cab:	83 e2 ef             	and    $0xffffffef,%edx
f0103cae:	88 50 2d             	mov    %dl,0x2d(%eax)
	asm volatile("ltr %0" : : "r" (sel));
f0103cb1:	b8 28 00 00 00       	mov    $0x28,%eax
f0103cb6:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f0103cb9:	8d 83 e8 1f 00 00    	lea    0x1fe8(%ebx),%eax
f0103cbf:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103cc2:	83 c4 04             	add    $0x4,%esp
f0103cc5:	5b                   	pop    %ebx
f0103cc6:	5e                   	pop    %esi
f0103cc7:	5f                   	pop    %edi
f0103cc8:	5d                   	pop    %ebp
f0103cc9:	c3                   	ret    

f0103cca <trap_init>:
{
f0103cca:	55                   	push   %ebp
f0103ccb:	89 e5                	mov    %esp,%ebp
f0103ccd:	e8 37 ca ff ff       	call   f0100709 <__x86.get_pc_thunk.ax>
f0103cd2:	05 4e 93 08 00       	add    $0x8934e,%eax
	SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f0103cd7:	c7 c2 9a 44 10 f0    	mov    $0xf010449a,%edx
f0103cdd:	66 89 90 20 23 00 00 	mov    %dx,0x2320(%eax)
f0103ce4:	66 c7 80 22 23 00 00 	movw   $0x8,0x2322(%eax)
f0103ceb:	08 00 
f0103ced:	c6 80 24 23 00 00 00 	movb   $0x0,0x2324(%eax)
f0103cf4:	c6 80 25 23 00 00 8e 	movb   $0x8e,0x2325(%eax)
f0103cfb:	c1 ea 10             	shr    $0x10,%edx
f0103cfe:	66 89 90 26 23 00 00 	mov    %dx,0x2326(%eax)
	SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f0103d05:	c7 c2 a0 44 10 f0    	mov    $0xf01044a0,%edx
f0103d0b:	66 89 90 28 23 00 00 	mov    %dx,0x2328(%eax)
f0103d12:	66 c7 80 2a 23 00 00 	movw   $0x8,0x232a(%eax)
f0103d19:	08 00 
f0103d1b:	c6 80 2c 23 00 00 00 	movb   $0x0,0x232c(%eax)
f0103d22:	c6 80 2d 23 00 00 8e 	movb   $0x8e,0x232d(%eax)
f0103d29:	c1 ea 10             	shr    $0x10,%edx
f0103d2c:	66 89 90 2e 23 00 00 	mov    %dx,0x232e(%eax)
	SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f0103d33:	c7 c2 a6 44 10 f0    	mov    $0xf01044a6,%edx
f0103d39:	66 89 90 30 23 00 00 	mov    %dx,0x2330(%eax)
f0103d40:	66 c7 80 32 23 00 00 	movw   $0x8,0x2332(%eax)
f0103d47:	08 00 
f0103d49:	c6 80 34 23 00 00 00 	movb   $0x0,0x2334(%eax)
f0103d50:	c6 80 35 23 00 00 8e 	movb   $0x8e,0x2335(%eax)
f0103d57:	c1 ea 10             	shr    $0x10,%edx
f0103d5a:	66 89 90 36 23 00 00 	mov    %dx,0x2336(%eax)
	SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f0103d61:	c7 c2 ac 44 10 f0    	mov    $0xf01044ac,%edx
f0103d67:	66 89 90 38 23 00 00 	mov    %dx,0x2338(%eax)
f0103d6e:	66 c7 80 3a 23 00 00 	movw   $0x8,0x233a(%eax)
f0103d75:	08 00 
f0103d77:	c6 80 3c 23 00 00 00 	movb   $0x0,0x233c(%eax)
f0103d7e:	c6 80 3d 23 00 00 ee 	movb   $0xee,0x233d(%eax)
f0103d85:	c1 ea 10             	shr    $0x10,%edx
f0103d88:	66 89 90 3e 23 00 00 	mov    %dx,0x233e(%eax)
	SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f0103d8f:	c7 c2 b2 44 10 f0    	mov    $0xf01044b2,%edx
f0103d95:	66 89 90 40 23 00 00 	mov    %dx,0x2340(%eax)
f0103d9c:	66 c7 80 42 23 00 00 	movw   $0x8,0x2342(%eax)
f0103da3:	08 00 
f0103da5:	c6 80 44 23 00 00 00 	movb   $0x0,0x2344(%eax)
f0103dac:	c6 80 45 23 00 00 8e 	movb   $0x8e,0x2345(%eax)
f0103db3:	c1 ea 10             	shr    $0x10,%edx
f0103db6:	66 89 90 46 23 00 00 	mov    %dx,0x2346(%eax)
	SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f0103dbd:	c7 c2 b8 44 10 f0    	mov    $0xf01044b8,%edx
f0103dc3:	66 89 90 48 23 00 00 	mov    %dx,0x2348(%eax)
f0103dca:	66 c7 80 4a 23 00 00 	movw   $0x8,0x234a(%eax)
f0103dd1:	08 00 
f0103dd3:	c6 80 4c 23 00 00 00 	movb   $0x0,0x234c(%eax)
f0103dda:	c6 80 4d 23 00 00 8e 	movb   $0x8e,0x234d(%eax)
f0103de1:	c1 ea 10             	shr    $0x10,%edx
f0103de4:	66 89 90 4e 23 00 00 	mov    %dx,0x234e(%eax)
	SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f0103deb:	c7 c2 be 44 10 f0    	mov    $0xf01044be,%edx
f0103df1:	66 89 90 50 23 00 00 	mov    %dx,0x2350(%eax)
f0103df8:	66 c7 80 52 23 00 00 	movw   $0x8,0x2352(%eax)
f0103dff:	08 00 
f0103e01:	c6 80 54 23 00 00 00 	movb   $0x0,0x2354(%eax)
f0103e08:	c6 80 55 23 00 00 8e 	movb   $0x8e,0x2355(%eax)
f0103e0f:	c1 ea 10             	shr    $0x10,%edx
f0103e12:	66 89 90 56 23 00 00 	mov    %dx,0x2356(%eax)
	SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f0103e19:	c7 c2 c4 44 10 f0    	mov    $0xf01044c4,%edx
f0103e1f:	66 89 90 58 23 00 00 	mov    %dx,0x2358(%eax)
f0103e26:	66 c7 80 5a 23 00 00 	movw   $0x8,0x235a(%eax)
f0103e2d:	08 00 
f0103e2f:	c6 80 5c 23 00 00 00 	movb   $0x0,0x235c(%eax)
f0103e36:	c6 80 5d 23 00 00 8e 	movb   $0x8e,0x235d(%eax)
f0103e3d:	c1 ea 10             	shr    $0x10,%edx
f0103e40:	66 89 90 5e 23 00 00 	mov    %dx,0x235e(%eax)
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f0103e47:	c7 c2 ca 44 10 f0    	mov    $0xf01044ca,%edx
f0103e4d:	66 89 90 60 23 00 00 	mov    %dx,0x2360(%eax)
f0103e54:	66 c7 80 62 23 00 00 	movw   $0x8,0x2362(%eax)
f0103e5b:	08 00 
f0103e5d:	c6 80 64 23 00 00 00 	movb   $0x0,0x2364(%eax)
f0103e64:	c6 80 65 23 00 00 8e 	movb   $0x8e,0x2365(%eax)
f0103e6b:	c1 ea 10             	shr    $0x10,%edx
f0103e6e:	66 89 90 66 23 00 00 	mov    %dx,0x2366(%eax)
	SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f0103e75:	c7 c2 ce 44 10 f0    	mov    $0xf01044ce,%edx
f0103e7b:	66 89 90 70 23 00 00 	mov    %dx,0x2370(%eax)
f0103e82:	66 c7 80 72 23 00 00 	movw   $0x8,0x2372(%eax)
f0103e89:	08 00 
f0103e8b:	c6 80 74 23 00 00 00 	movb   $0x0,0x2374(%eax)
f0103e92:	c6 80 75 23 00 00 8e 	movb   $0x8e,0x2375(%eax)
f0103e99:	c1 ea 10             	shr    $0x10,%edx
f0103e9c:	66 89 90 76 23 00 00 	mov    %dx,0x2376(%eax)
	SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f0103ea3:	c7 c2 d2 44 10 f0    	mov    $0xf01044d2,%edx
f0103ea9:	66 89 90 78 23 00 00 	mov    %dx,0x2378(%eax)
f0103eb0:	66 c7 80 7a 23 00 00 	movw   $0x8,0x237a(%eax)
f0103eb7:	08 00 
f0103eb9:	c6 80 7c 23 00 00 00 	movb   $0x0,0x237c(%eax)
f0103ec0:	c6 80 7d 23 00 00 8e 	movb   $0x8e,0x237d(%eax)
f0103ec7:	c1 ea 10             	shr    $0x10,%edx
f0103eca:	66 89 90 7e 23 00 00 	mov    %dx,0x237e(%eax)
	SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f0103ed1:	c7 c2 d6 44 10 f0    	mov    $0xf01044d6,%edx
f0103ed7:	66 89 90 80 23 00 00 	mov    %dx,0x2380(%eax)
f0103ede:	66 c7 80 82 23 00 00 	movw   $0x8,0x2382(%eax)
f0103ee5:	08 00 
f0103ee7:	c6 80 84 23 00 00 00 	movb   $0x0,0x2384(%eax)
f0103eee:	c6 80 85 23 00 00 8e 	movb   $0x8e,0x2385(%eax)
f0103ef5:	c1 ea 10             	shr    $0x10,%edx
f0103ef8:	66 89 90 86 23 00 00 	mov    %dx,0x2386(%eax)
	SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f0103eff:	c7 c2 da 44 10 f0    	mov    $0xf01044da,%edx
f0103f05:	66 89 90 88 23 00 00 	mov    %dx,0x2388(%eax)
f0103f0c:	66 c7 80 8a 23 00 00 	movw   $0x8,0x238a(%eax)
f0103f13:	08 00 
f0103f15:	c6 80 8c 23 00 00 00 	movb   $0x0,0x238c(%eax)
f0103f1c:	c6 80 8d 23 00 00 8e 	movb   $0x8e,0x238d(%eax)
f0103f23:	c1 ea 10             	shr    $0x10,%edx
f0103f26:	66 89 90 8e 23 00 00 	mov    %dx,0x238e(%eax)
	SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f0103f2d:	c7 c2 de 44 10 f0    	mov    $0xf01044de,%edx
f0103f33:	66 89 90 90 23 00 00 	mov    %dx,0x2390(%eax)
f0103f3a:	66 c7 80 92 23 00 00 	movw   $0x8,0x2392(%eax)
f0103f41:	08 00 
f0103f43:	c6 80 94 23 00 00 00 	movb   $0x0,0x2394(%eax)
f0103f4a:	c6 80 95 23 00 00 8e 	movb   $0x8e,0x2395(%eax)
f0103f51:	c1 ea 10             	shr    $0x10,%edx
f0103f54:	66 89 90 96 23 00 00 	mov    %dx,0x2396(%eax)
	SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f0103f5b:	c7 c2 e2 44 10 f0    	mov    $0xf01044e2,%edx
f0103f61:	66 89 90 a0 23 00 00 	mov    %dx,0x23a0(%eax)
f0103f68:	66 c7 80 a2 23 00 00 	movw   $0x8,0x23a2(%eax)
f0103f6f:	08 00 
f0103f71:	c6 80 a4 23 00 00 00 	movb   $0x0,0x23a4(%eax)
f0103f78:	c6 80 a5 23 00 00 8e 	movb   $0x8e,0x23a5(%eax)
f0103f7f:	c1 ea 10             	shr    $0x10,%edx
f0103f82:	66 89 90 a6 23 00 00 	mov    %dx,0x23a6(%eax)
	SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f0103f89:	c7 c2 e8 44 10 f0    	mov    $0xf01044e8,%edx
f0103f8f:	66 89 90 a8 23 00 00 	mov    %dx,0x23a8(%eax)
f0103f96:	66 c7 80 aa 23 00 00 	movw   $0x8,0x23aa(%eax)
f0103f9d:	08 00 
f0103f9f:	c6 80 ac 23 00 00 00 	movb   $0x0,0x23ac(%eax)
f0103fa6:	c6 80 ad 23 00 00 8e 	movb   $0x8e,0x23ad(%eax)
f0103fad:	c1 ea 10             	shr    $0x10,%edx
f0103fb0:	66 89 90 ae 23 00 00 	mov    %dx,0x23ae(%eax)
	SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0103fb7:	c7 c2 ec 44 10 f0    	mov    $0xf01044ec,%edx
f0103fbd:	66 89 90 b0 23 00 00 	mov    %dx,0x23b0(%eax)
f0103fc4:	66 c7 80 b2 23 00 00 	movw   $0x8,0x23b2(%eax)
f0103fcb:	08 00 
f0103fcd:	c6 80 b4 23 00 00 00 	movb   $0x0,0x23b4(%eax)
f0103fd4:	c6 80 b5 23 00 00 8e 	movb   $0x8e,0x23b5(%eax)
f0103fdb:	c1 ea 10             	shr    $0x10,%edx
f0103fde:	66 89 90 b6 23 00 00 	mov    %dx,0x23b6(%eax)
	SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f0103fe5:	c7 c2 f2 44 10 f0    	mov    $0xf01044f2,%edx
f0103feb:	66 89 90 b8 23 00 00 	mov    %dx,0x23b8(%eax)
f0103ff2:	66 c7 80 ba 23 00 00 	movw   $0x8,0x23ba(%eax)
f0103ff9:	08 00 
f0103ffb:	c6 80 bc 23 00 00 00 	movb   $0x0,0x23bc(%eax)
f0104002:	c6 80 bd 23 00 00 8e 	movb   $0x8e,0x23bd(%eax)
f0104009:	c1 ea 10             	shr    $0x10,%edx
f010400c:	66 89 90 be 23 00 00 	mov    %dx,0x23be(%eax)
	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f0104013:	c7 c2 f8 44 10 f0    	mov    $0xf01044f8,%edx
f0104019:	66 89 90 a0 24 00 00 	mov    %dx,0x24a0(%eax)
f0104020:	66 c7 80 a2 24 00 00 	movw   $0x8,0x24a2(%eax)
f0104027:	08 00 
f0104029:	c6 80 a4 24 00 00 00 	movb   $0x0,0x24a4(%eax)
f0104030:	c6 80 a5 24 00 00 ee 	movb   $0xee,0x24a5(%eax)
f0104037:	c1 ea 10             	shr    $0x10,%edx
f010403a:	66 89 90 a6 24 00 00 	mov    %dx,0x24a6(%eax)
	trap_init_percpu();
f0104041:	e8 e5 fb ff ff       	call   f0103c2b <trap_init_percpu>
}
f0104046:	5d                   	pop    %ebp
f0104047:	c3                   	ret    

f0104048 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104048:	55                   	push   %ebp
f0104049:	89 e5                	mov    %esp,%ebp
f010404b:	56                   	push   %esi
f010404c:	53                   	push   %ebx
f010404d:	e8 15 c1 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104052:	81 c3 ce 8f 08 00    	add    $0x88fce,%ebx
f0104058:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010405b:	83 ec 08             	sub    $0x8,%esp
f010405e:	ff 36                	pushl  (%esi)
f0104060:	8d 83 23 97 f7 ff    	lea    -0x868dd(%ebx),%eax
f0104066:	50                   	push   %eax
f0104067:	e8 ab fb ff ff       	call   f0103c17 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010406c:	83 c4 08             	add    $0x8,%esp
f010406f:	ff 76 04             	pushl  0x4(%esi)
f0104072:	8d 83 32 97 f7 ff    	lea    -0x868ce(%ebx),%eax
f0104078:	50                   	push   %eax
f0104079:	e8 99 fb ff ff       	call   f0103c17 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010407e:	83 c4 08             	add    $0x8,%esp
f0104081:	ff 76 08             	pushl  0x8(%esi)
f0104084:	8d 83 41 97 f7 ff    	lea    -0x868bf(%ebx),%eax
f010408a:	50                   	push   %eax
f010408b:	e8 87 fb ff ff       	call   f0103c17 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104090:	83 c4 08             	add    $0x8,%esp
f0104093:	ff 76 0c             	pushl  0xc(%esi)
f0104096:	8d 83 50 97 f7 ff    	lea    -0x868b0(%ebx),%eax
f010409c:	50                   	push   %eax
f010409d:	e8 75 fb ff ff       	call   f0103c17 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01040a2:	83 c4 08             	add    $0x8,%esp
f01040a5:	ff 76 10             	pushl  0x10(%esi)
f01040a8:	8d 83 5f 97 f7 ff    	lea    -0x868a1(%ebx),%eax
f01040ae:	50                   	push   %eax
f01040af:	e8 63 fb ff ff       	call   f0103c17 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01040b4:	83 c4 08             	add    $0x8,%esp
f01040b7:	ff 76 14             	pushl  0x14(%esi)
f01040ba:	8d 83 6e 97 f7 ff    	lea    -0x86892(%ebx),%eax
f01040c0:	50                   	push   %eax
f01040c1:	e8 51 fb ff ff       	call   f0103c17 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01040c6:	83 c4 08             	add    $0x8,%esp
f01040c9:	ff 76 18             	pushl  0x18(%esi)
f01040cc:	8d 83 7d 97 f7 ff    	lea    -0x86883(%ebx),%eax
f01040d2:	50                   	push   %eax
f01040d3:	e8 3f fb ff ff       	call   f0103c17 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01040d8:	83 c4 08             	add    $0x8,%esp
f01040db:	ff 76 1c             	pushl  0x1c(%esi)
f01040de:	8d 83 8c 97 f7 ff    	lea    -0x86874(%ebx),%eax
f01040e4:	50                   	push   %eax
f01040e5:	e8 2d fb ff ff       	call   f0103c17 <cprintf>
}
f01040ea:	83 c4 10             	add    $0x10,%esp
f01040ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01040f0:	5b                   	pop    %ebx
f01040f1:	5e                   	pop    %esi
f01040f2:	5d                   	pop    %ebp
f01040f3:	c3                   	ret    

f01040f4 <print_trapframe>:
{
f01040f4:	55                   	push   %ebp
f01040f5:	89 e5                	mov    %esp,%ebp
f01040f7:	57                   	push   %edi
f01040f8:	56                   	push   %esi
f01040f9:	53                   	push   %ebx
f01040fa:	83 ec 14             	sub    $0x14,%esp
f01040fd:	e8 65 c0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104102:	81 c3 1e 8f 08 00    	add    $0x88f1e,%ebx
f0104108:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("TRAP frame at %p\n", tf);
f010410b:	56                   	push   %esi
f010410c:	8d 83 c2 98 f7 ff    	lea    -0x8673e(%ebx),%eax
f0104112:	50                   	push   %eax
f0104113:	e8 ff fa ff ff       	call   f0103c17 <cprintf>
	print_regs(&tf->tf_regs);
f0104118:	89 34 24             	mov    %esi,(%esp)
f010411b:	e8 28 ff ff ff       	call   f0104048 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104120:	83 c4 08             	add    $0x8,%esp
f0104123:	0f b7 46 20          	movzwl 0x20(%esi),%eax
f0104127:	50                   	push   %eax
f0104128:	8d 83 dd 97 f7 ff    	lea    -0x86823(%ebx),%eax
f010412e:	50                   	push   %eax
f010412f:	e8 e3 fa ff ff       	call   f0103c17 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104134:	83 c4 08             	add    $0x8,%esp
f0104137:	0f b7 46 24          	movzwl 0x24(%esi),%eax
f010413b:	50                   	push   %eax
f010413c:	8d 83 f0 97 f7 ff    	lea    -0x86810(%ebx),%eax
f0104142:	50                   	push   %eax
f0104143:	e8 cf fa ff ff       	call   f0103c17 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104148:	8b 56 28             	mov    0x28(%esi),%edx
	if (trapno < ARRAY_SIZE(excnames))
f010414b:	83 c4 10             	add    $0x10,%esp
f010414e:	83 fa 13             	cmp    $0x13,%edx
f0104151:	0f 86 e9 00 00 00    	jbe    f0104240 <print_trapframe+0x14c>
	return "(unknown trap)";
f0104157:	83 fa 30             	cmp    $0x30,%edx
f010415a:	8d 83 9b 97 f7 ff    	lea    -0x86865(%ebx),%eax
f0104160:	8d 8b a7 97 f7 ff    	lea    -0x86859(%ebx),%ecx
f0104166:	0f 45 c1             	cmovne %ecx,%eax
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104169:	83 ec 04             	sub    $0x4,%esp
f010416c:	50                   	push   %eax
f010416d:	52                   	push   %edx
f010416e:	8d 83 03 98 f7 ff    	lea    -0x867fd(%ebx),%eax
f0104174:	50                   	push   %eax
f0104175:	e8 9d fa ff ff       	call   f0103c17 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010417a:	83 c4 10             	add    $0x10,%esp
f010417d:	39 b3 20 2b 00 00    	cmp    %esi,0x2b20(%ebx)
f0104183:	0f 84 c3 00 00 00    	je     f010424c <print_trapframe+0x158>
	cprintf("  err  0x%08x", tf->tf_err);
f0104189:	83 ec 08             	sub    $0x8,%esp
f010418c:	ff 76 2c             	pushl  0x2c(%esi)
f010418f:	8d 83 24 98 f7 ff    	lea    -0x867dc(%ebx),%eax
f0104195:	50                   	push   %eax
f0104196:	e8 7c fa ff ff       	call   f0103c17 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f010419b:	83 c4 10             	add    $0x10,%esp
f010419e:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f01041a2:	0f 85 c9 00 00 00    	jne    f0104271 <print_trapframe+0x17d>
			tf->tf_err & 1 ? "protection" : "not-present");
f01041a8:	8b 46 2c             	mov    0x2c(%esi),%eax
		cprintf(" [%s, %s, %s]\n",
f01041ab:	89 c2                	mov    %eax,%edx
f01041ad:	83 e2 01             	and    $0x1,%edx
f01041b0:	8d 8b b6 97 f7 ff    	lea    -0x8684a(%ebx),%ecx
f01041b6:	8d 93 c1 97 f7 ff    	lea    -0x8683f(%ebx),%edx
f01041bc:	0f 44 ca             	cmove  %edx,%ecx
f01041bf:	89 c2                	mov    %eax,%edx
f01041c1:	83 e2 02             	and    $0x2,%edx
f01041c4:	8d 93 cd 97 f7 ff    	lea    -0x86833(%ebx),%edx
f01041ca:	8d bb d3 97 f7 ff    	lea    -0x8682d(%ebx),%edi
f01041d0:	0f 44 d7             	cmove  %edi,%edx
f01041d3:	83 e0 04             	and    $0x4,%eax
f01041d6:	8d 83 d8 97 f7 ff    	lea    -0x86828(%ebx),%eax
f01041dc:	8d bb ed 98 f7 ff    	lea    -0x86713(%ebx),%edi
f01041e2:	0f 44 c7             	cmove  %edi,%eax
f01041e5:	51                   	push   %ecx
f01041e6:	52                   	push   %edx
f01041e7:	50                   	push   %eax
f01041e8:	8d 83 32 98 f7 ff    	lea    -0x867ce(%ebx),%eax
f01041ee:	50                   	push   %eax
f01041ef:	e8 23 fa ff ff       	call   f0103c17 <cprintf>
f01041f4:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01041f7:	83 ec 08             	sub    $0x8,%esp
f01041fa:	ff 76 30             	pushl  0x30(%esi)
f01041fd:	8d 83 41 98 f7 ff    	lea    -0x867bf(%ebx),%eax
f0104203:	50                   	push   %eax
f0104204:	e8 0e fa ff ff       	call   f0103c17 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104209:	83 c4 08             	add    $0x8,%esp
f010420c:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104210:	50                   	push   %eax
f0104211:	8d 83 50 98 f7 ff    	lea    -0x867b0(%ebx),%eax
f0104217:	50                   	push   %eax
f0104218:	e8 fa f9 ff ff       	call   f0103c17 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010421d:	83 c4 08             	add    $0x8,%esp
f0104220:	ff 76 38             	pushl  0x38(%esi)
f0104223:	8d 83 63 98 f7 ff    	lea    -0x8679d(%ebx),%eax
f0104229:	50                   	push   %eax
f010422a:	e8 e8 f9 ff ff       	call   f0103c17 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010422f:	83 c4 10             	add    $0x10,%esp
f0104232:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f0104236:	75 50                	jne    f0104288 <print_trapframe+0x194>
}
f0104238:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010423b:	5b                   	pop    %ebx
f010423c:	5e                   	pop    %esi
f010423d:	5f                   	pop    %edi
f010423e:	5d                   	pop    %ebp
f010423f:	c3                   	ret    
		return excnames[trapno];
f0104240:	8b 84 93 40 20 00 00 	mov    0x2040(%ebx,%edx,4),%eax
f0104247:	e9 1d ff ff ff       	jmp    f0104169 <print_trapframe+0x75>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010424c:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0104250:	0f 85 33 ff ff ff    	jne    f0104189 <print_trapframe+0x95>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0104256:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104259:	83 ec 08             	sub    $0x8,%esp
f010425c:	50                   	push   %eax
f010425d:	8d 83 15 98 f7 ff    	lea    -0x867eb(%ebx),%eax
f0104263:	50                   	push   %eax
f0104264:	e8 ae f9 ff ff       	call   f0103c17 <cprintf>
f0104269:	83 c4 10             	add    $0x10,%esp
f010426c:	e9 18 ff ff ff       	jmp    f0104189 <print_trapframe+0x95>
		cprintf("\n");
f0104271:	83 ec 0c             	sub    $0xc,%esp
f0104274:	8d 83 ce 8d f7 ff    	lea    -0x87232(%ebx),%eax
f010427a:	50                   	push   %eax
f010427b:	e8 97 f9 ff ff       	call   f0103c17 <cprintf>
f0104280:	83 c4 10             	add    $0x10,%esp
f0104283:	e9 6f ff ff ff       	jmp    f01041f7 <print_trapframe+0x103>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104288:	83 ec 08             	sub    $0x8,%esp
f010428b:	ff 76 3c             	pushl  0x3c(%esi)
f010428e:	8d 83 72 98 f7 ff    	lea    -0x8678e(%ebx),%eax
f0104294:	50                   	push   %eax
f0104295:	e8 7d f9 ff ff       	call   f0103c17 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010429a:	83 c4 08             	add    $0x8,%esp
f010429d:	0f b7 46 40          	movzwl 0x40(%esi),%eax
f01042a1:	50                   	push   %eax
f01042a2:	8d 83 81 98 f7 ff    	lea    -0x8677f(%ebx),%eax
f01042a8:	50                   	push   %eax
f01042a9:	e8 69 f9 ff ff       	call   f0103c17 <cprintf>
f01042ae:	83 c4 10             	add    $0x10,%esp
}
f01042b1:	eb 85                	jmp    f0104238 <print_trapframe+0x144>

f01042b3 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01042b3:	55                   	push   %ebp
f01042b4:	89 e5                	mov    %esp,%ebp
f01042b6:	57                   	push   %edi
f01042b7:	56                   	push   %esi
f01042b8:	53                   	push   %ebx
f01042b9:	83 ec 0c             	sub    $0xc,%esp
f01042bc:	e8 a6 be ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01042c1:	81 c3 5f 8d 08 00    	add    $0x88d5f,%ebx
f01042c7:	8b 75 08             	mov    0x8(%ebp),%esi
f01042ca:	0f 20 d0             	mov    %cr2,%eax
	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	// LAB 3: Your code here.
	if((tf->tf_cs & 3) == 0)
f01042cd:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f01042d1:	74 38                	je     f010430b <page_fault_handler+0x58>
		panic("page_fault in kernel mode, fault address %d\n", fault_va);
	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01042d3:	ff 76 30             	pushl  0x30(%esi)
f01042d6:	50                   	push   %eax
f01042d7:	c7 c7 28 f3 18 f0    	mov    $0xf018f328,%edi
f01042dd:	8b 07                	mov    (%edi),%eax
f01042df:	ff 70 48             	pushl  0x48(%eax)
f01042e2:	8d 83 68 9a f7 ff    	lea    -0x86598(%ebx),%eax
f01042e8:	50                   	push   %eax
f01042e9:	e8 29 f9 ff ff       	call   f0103c17 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01042ee:	89 34 24             	mov    %esi,(%esp)
f01042f1:	e8 fe fd ff ff       	call   f01040f4 <print_trapframe>
	env_destroy(curenv);
f01042f6:	83 c4 04             	add    $0x4,%esp
f01042f9:	ff 37                	pushl  (%edi)
f01042fb:	e8 ad f7 ff ff       	call   f0103aad <env_destroy>
}
f0104300:	83 c4 10             	add    $0x10,%esp
f0104303:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104306:	5b                   	pop    %ebx
f0104307:	5e                   	pop    %esi
f0104308:	5f                   	pop    %edi
f0104309:	5d                   	pop    %ebp
f010430a:	c3                   	ret    
		panic("page_fault in kernel mode, fault address %d\n", fault_va);
f010430b:	50                   	push   %eax
f010430c:	8d 83 38 9a f7 ff    	lea    -0x865c8(%ebx),%eax
f0104312:	50                   	push   %eax
f0104313:	68 09 01 00 00       	push   $0x109
f0104318:	8d 83 94 98 f7 ff    	lea    -0x8676c(%ebx),%eax
f010431e:	50                   	push   %eax
f010431f:	e8 8d bd ff ff       	call   f01000b1 <_panic>

f0104324 <trap>:
{
f0104324:	55                   	push   %ebp
f0104325:	89 e5                	mov    %esp,%ebp
f0104327:	57                   	push   %edi
f0104328:	56                   	push   %esi
f0104329:	53                   	push   %ebx
f010432a:	83 ec 0c             	sub    $0xc,%esp
f010432d:	e8 35 be ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104332:	81 c3 ee 8c 08 00    	add    $0x88cee,%ebx
f0104338:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f010433b:	fc                   	cld    
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f010433c:	9c                   	pushf  
f010433d:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f010433e:	f6 c4 02             	test   $0x2,%ah
f0104341:	74 1f                	je     f0104362 <trap+0x3e>
f0104343:	8d 83 a0 98 f7 ff    	lea    -0x86760(%ebx),%eax
f0104349:	50                   	push   %eax
f010434a:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0104350:	50                   	push   %eax
f0104351:	68 e1 00 00 00       	push   $0xe1
f0104356:	8d 83 94 98 f7 ff    	lea    -0x8676c(%ebx),%eax
f010435c:	50                   	push   %eax
f010435d:	e8 4f bd ff ff       	call   f01000b1 <_panic>
	cprintf("Incoming TRAP frame at %p\n", tf);
f0104362:	83 ec 08             	sub    $0x8,%esp
f0104365:	56                   	push   %esi
f0104366:	8d 83 b9 98 f7 ff    	lea    -0x86747(%ebx),%eax
f010436c:	50                   	push   %eax
f010436d:	e8 a5 f8 ff ff       	call   f0103c17 <cprintf>
	if ((tf->tf_cs & 3) == 3) {
f0104372:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104376:	83 e0 03             	and    $0x3,%eax
f0104379:	83 c4 10             	add    $0x10,%esp
f010437c:	66 83 f8 03          	cmp    $0x3,%ax
f0104380:	75 1d                	jne    f010439f <trap+0x7b>
		assert(curenv);
f0104382:	c7 c0 28 f3 18 f0    	mov    $0xf018f328,%eax
f0104388:	8b 00                	mov    (%eax),%eax
f010438a:	85 c0                	test   %eax,%eax
f010438c:	74 5d                	je     f01043eb <trap+0xc7>
		curenv->env_tf = *tf;
f010438e:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104393:	89 c7                	mov    %eax,%edi
f0104395:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0104397:	c7 c0 28 f3 18 f0    	mov    $0xf018f328,%eax
f010439d:	8b 30                	mov    (%eax),%esi
	last_tf = tf;
f010439f:	89 b3 20 2b 00 00    	mov    %esi,0x2b20(%ebx)
	switch(tf->tf_trapno){
f01043a5:	8b 46 28             	mov    0x28(%esi),%eax
f01043a8:	83 f8 0e             	cmp    $0xe,%eax
f01043ab:	74 5d                	je     f010440a <trap+0xe6>
f01043ad:	83 f8 30             	cmp    $0x30,%eax
f01043b0:	0f 84 9f 00 00 00    	je     f0104455 <trap+0x131>
f01043b6:	83 f8 03             	cmp    $0x3,%eax
f01043b9:	0f 84 88 00 00 00    	je     f0104447 <trap+0x123>
			print_trapframe(tf);
f01043bf:	83 ec 0c             	sub    $0xc,%esp
f01043c2:	56                   	push   %esi
f01043c3:	e8 2c fd ff ff       	call   f01040f4 <print_trapframe>
			if (tf->tf_cs == GD_KT)
f01043c8:	83 c4 10             	add    $0x10,%esp
f01043cb:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01043d0:	0f 84 a0 00 00 00    	je     f0104476 <trap+0x152>
				env_destroy(curenv);
f01043d6:	83 ec 0c             	sub    $0xc,%esp
f01043d9:	c7 c0 28 f3 18 f0    	mov    $0xf018f328,%eax
f01043df:	ff 30                	pushl  (%eax)
f01043e1:	e8 c7 f6 ff ff       	call   f0103aad <env_destroy>
f01043e6:	83 c4 10             	add    $0x10,%esp
f01043e9:	eb 2b                	jmp    f0104416 <trap+0xf2>
		assert(curenv);
f01043eb:	8d 83 d4 98 f7 ff    	lea    -0x8672c(%ebx),%eax
f01043f1:	50                   	push   %eax
f01043f2:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f01043f8:	50                   	push   %eax
f01043f9:	68 e7 00 00 00       	push   $0xe7
f01043fe:	8d 83 94 98 f7 ff    	lea    -0x8676c(%ebx),%eax
f0104404:	50                   	push   %eax
f0104405:	e8 a7 bc ff ff       	call   f01000b1 <_panic>
			page_fault_handler(tf);
f010440a:	83 ec 0c             	sub    $0xc,%esp
f010440d:	56                   	push   %esi
f010440e:	e8 a0 fe ff ff       	call   f01042b3 <page_fault_handler>
f0104413:	83 c4 10             	add    $0x10,%esp
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0104416:	c7 c0 28 f3 18 f0    	mov    $0xf018f328,%eax
f010441c:	8b 00                	mov    (%eax),%eax
f010441e:	85 c0                	test   %eax,%eax
f0104420:	74 06                	je     f0104428 <trap+0x104>
f0104422:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104426:	74 69                	je     f0104491 <trap+0x16d>
f0104428:	8d 83 8c 9a f7 ff    	lea    -0x86574(%ebx),%eax
f010442e:	50                   	push   %eax
f010442f:	8d 83 1f 8b f7 ff    	lea    -0x874e1(%ebx),%eax
f0104435:	50                   	push   %eax
f0104436:	68 f9 00 00 00       	push   $0xf9
f010443b:	8d 83 94 98 f7 ff    	lea    -0x8676c(%ebx),%eax
f0104441:	50                   	push   %eax
f0104442:	e8 6a bc ff ff       	call   f01000b1 <_panic>
			monitor(tf);
f0104447:	83 ec 0c             	sub    $0xc,%esp
f010444a:	56                   	push   %esi
f010444b:	e8 fe c5 ff ff       	call   f0100a4e <monitor>
f0104450:	83 c4 10             	add    $0x10,%esp
f0104453:	eb c1                	jmp    f0104416 <trap+0xf2>
			ret_code = syscall(
f0104455:	83 ec 08             	sub    $0x8,%esp
f0104458:	ff 76 04             	pushl  0x4(%esi)
f010445b:	ff 36                	pushl  (%esi)
f010445d:	ff 76 10             	pushl  0x10(%esi)
f0104460:	ff 76 18             	pushl  0x18(%esi)
f0104463:	ff 76 14             	pushl  0x14(%esi)
f0104466:	ff 76 1c             	pushl  0x1c(%esi)
f0104469:	e8 a2 00 00 00       	call   f0104510 <syscall>
			tf->tf_regs.reg_eax = ret_code;
f010446e:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104471:	83 c4 20             	add    $0x20,%esp
f0104474:	eb a0                	jmp    f0104416 <trap+0xf2>
				panic("unhandled trap in kernel");
f0104476:	83 ec 04             	sub    $0x4,%esp
f0104479:	8d 83 db 98 f7 ff    	lea    -0x86725(%ebx),%eax
f010447f:	50                   	push   %eax
f0104480:	68 cf 00 00 00       	push   $0xcf
f0104485:	8d 83 94 98 f7 ff    	lea    -0x8676c(%ebx),%eax
f010448b:	50                   	push   %eax
f010448c:	e8 20 bc ff ff       	call   f01000b1 <_panic>
	env_run(curenv);
f0104491:	83 ec 0c             	sub    $0xc,%esp
f0104494:	50                   	push   %eax
f0104495:	e8 81 f6 ff ff       	call   f0103b1b <env_run>

f010449a <t_divide>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(t_divide, T_DIVIDE)
f010449a:	6a 00                	push   $0x0
f010449c:	6a 00                	push   $0x0
f010449e:	eb 5e                	jmp    f01044fe <_alltraps>

f01044a0 <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG)
f01044a0:	6a 00                	push   $0x0
f01044a2:	6a 01                	push   $0x1
f01044a4:	eb 58                	jmp    f01044fe <_alltraps>

f01044a6 <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI)
f01044a6:	6a 00                	push   $0x0
f01044a8:	6a 02                	push   $0x2
f01044aa:	eb 52                	jmp    f01044fe <_alltraps>

f01044ac <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)
f01044ac:	6a 00                	push   $0x0
f01044ae:	6a 03                	push   $0x3
f01044b0:	eb 4c                	jmp    f01044fe <_alltraps>

f01044b2 <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW)
f01044b2:	6a 00                	push   $0x0
f01044b4:	6a 04                	push   $0x4
f01044b6:	eb 46                	jmp    f01044fe <_alltraps>

f01044b8 <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)
f01044b8:	6a 00                	push   $0x0
f01044ba:	6a 05                	push   $0x5
f01044bc:	eb 40                	jmp    f01044fe <_alltraps>

f01044be <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)
f01044be:	6a 00                	push   $0x0
f01044c0:	6a 06                	push   $0x6
f01044c2:	eb 3a                	jmp    f01044fe <_alltraps>

f01044c4 <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)
f01044c4:	6a 00                	push   $0x0
f01044c6:	6a 07                	push   $0x7
f01044c8:	eb 34                	jmp    f01044fe <_alltraps>

f01044ca <t_dblflt>:
TRAPHANDLER(t_dblflt, T_DBLFLT)
f01044ca:	6a 08                	push   $0x8
f01044cc:	eb 30                	jmp    f01044fe <_alltraps>

f01044ce <t_tss>:
TRAPHANDLER(t_tss, T_TSS)
f01044ce:	6a 0a                	push   $0xa
f01044d0:	eb 2c                	jmp    f01044fe <_alltraps>

f01044d2 <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP)
f01044d2:	6a 0b                	push   $0xb
f01044d4:	eb 28                	jmp    f01044fe <_alltraps>

f01044d6 <t_stack>:
TRAPHANDLER(t_stack, T_STACK)
f01044d6:	6a 0c                	push   $0xc
f01044d8:	eb 24                	jmp    f01044fe <_alltraps>

f01044da <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)
f01044da:	6a 0d                	push   $0xd
f01044dc:	eb 20                	jmp    f01044fe <_alltraps>

f01044de <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT)
f01044de:	6a 0e                	push   $0xe
f01044e0:	eb 1c                	jmp    f01044fe <_alltraps>

f01044e2 <t_fperr>:
TRAPHANDLER_NOEC(t_fperr, T_FPERR)
f01044e2:	6a 00                	push   $0x0
f01044e4:	6a 10                	push   $0x10
f01044e6:	eb 16                	jmp    f01044fe <_alltraps>

f01044e8 <t_align>:
TRAPHANDLER(t_align, T_ALIGN)
f01044e8:	6a 11                	push   $0x11
f01044ea:	eb 12                	jmp    f01044fe <_alltraps>

f01044ec <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK)
f01044ec:	6a 00                	push   $0x0
f01044ee:	6a 12                	push   $0x12
f01044f0:	eb 0c                	jmp    f01044fe <_alltraps>

f01044f2 <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)
f01044f2:	6a 00                	push   $0x0
f01044f4:	6a 13                	push   $0x13
f01044f6:	eb 06                	jmp    f01044fe <_alltraps>

f01044f8 <t_syscall>:

TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f01044f8:	6a 00                	push   $0x0
f01044fa:	6a 30                	push   $0x30
f01044fc:	eb 00                	jmp    f01044fe <_alltraps>

f01044fe <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f01044fe:	1e                   	push   %ds
	pushl %es
f01044ff:	06                   	push   %es
	pushal 
f0104500:	60                   	pusha  

	movl $GD_KD, %eax
f0104501:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f0104506:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104508:	8e c0                	mov    %eax,%es

	push %esp
f010450a:	54                   	push   %esp
	call trap	
f010450b:	e8 14 fe ff ff       	call   f0104324 <trap>

f0104510 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104510:	55                   	push   %ebp
f0104511:	89 e5                	mov    %esp,%ebp
f0104513:	53                   	push   %ebx
f0104514:	83 ec 14             	sub    $0x14,%esp
f0104517:	e8 4b bc ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010451c:	81 c3 04 8b 08 00    	add    $0x88b04,%ebx
f0104522:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch(syscallno){
f0104525:	83 f8 01             	cmp    $0x1,%eax
f0104528:	74 4d                	je     f0104577 <syscall+0x67>
f010452a:	83 f8 01             	cmp    $0x1,%eax
f010452d:	72 11                	jb     f0104540 <syscall+0x30>
f010452f:	83 f8 02             	cmp    $0x2,%eax
f0104532:	74 4a                	je     f010457e <syscall+0x6e>
f0104534:	83 f8 03             	cmp    $0x3,%eax
f0104537:	74 52                	je     f010458b <syscall+0x7b>
		case(SYS_getenvid):
			return sys_getenvid();
		case(SYS_env_destroy):
			return sys_env_destroy(a1);
	default:
		return -E_INVAL;
f0104539:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010453e:	eb 32                	jmp    f0104572 <syscall+0x62>
	user_mem_assert(curenv, s, len, 0);
f0104540:	6a 00                	push   $0x0
f0104542:	ff 75 10             	pushl  0x10(%ebp)
f0104545:	ff 75 0c             	pushl  0xc(%ebp)
f0104548:	c7 c0 28 f3 18 f0    	mov    $0xf018f328,%eax
f010454e:	ff 30                	pushl  (%eax)
f0104550:	e8 47 ee ff ff       	call   f010339c <user_mem_assert>
	cprintf("%.*s", len, s);
f0104555:	83 c4 0c             	add    $0xc,%esp
f0104558:	ff 75 0c             	pushl  0xc(%ebp)
f010455b:	ff 75 10             	pushl  0x10(%ebp)
f010455e:	8d 83 b8 9a f7 ff    	lea    -0x86548(%ebx),%eax
f0104564:	50                   	push   %eax
f0104565:	e8 ad f6 ff ff       	call   f0103c17 <cprintf>
f010456a:	83 c4 10             	add    $0x10,%esp
			return 0;
f010456d:	b8 00 00 00 00       	mov    $0x0,%eax
	}

}
f0104572:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104575:	c9                   	leave  
f0104576:	c3                   	ret    
	return cons_getc();
f0104577:	e8 e6 bf ff ff       	call   f0100562 <cons_getc>
			return sys_cgetc();
f010457c:	eb f4                	jmp    f0104572 <syscall+0x62>
	return curenv->env_id;
f010457e:	c7 c0 28 f3 18 f0    	mov    $0xf018f328,%eax
f0104584:	8b 00                	mov    (%eax),%eax
f0104586:	8b 40 48             	mov    0x48(%eax),%eax
			return sys_getenvid();
f0104589:	eb e7                	jmp    f0104572 <syscall+0x62>
	if ((r = envid2env(envid, &e, 1)) < 0)
f010458b:	83 ec 04             	sub    $0x4,%esp
f010458e:	6a 01                	push   $0x1
f0104590:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104593:	50                   	push   %eax
f0104594:	ff 75 0c             	pushl  0xc(%ebp)
f0104597:	e8 fd ee ff ff       	call   f0103499 <envid2env>
f010459c:	83 c4 10             	add    $0x10,%esp
f010459f:	85 c0                	test   %eax,%eax
f01045a1:	78 cf                	js     f0104572 <syscall+0x62>
	if (e == curenv)
f01045a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01045a6:	c7 c0 28 f3 18 f0    	mov    $0xf018f328,%eax
f01045ac:	8b 00                	mov    (%eax),%eax
f01045ae:	39 c2                	cmp    %eax,%edx
f01045b0:	74 2d                	je     f01045df <syscall+0xcf>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01045b2:	83 ec 04             	sub    $0x4,%esp
f01045b5:	ff 72 48             	pushl  0x48(%edx)
f01045b8:	ff 70 48             	pushl  0x48(%eax)
f01045bb:	8d 83 d8 9a f7 ff    	lea    -0x86528(%ebx),%eax
f01045c1:	50                   	push   %eax
f01045c2:	e8 50 f6 ff ff       	call   f0103c17 <cprintf>
f01045c7:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01045ca:	83 ec 0c             	sub    $0xc,%esp
f01045cd:	ff 75 f4             	pushl  -0xc(%ebp)
f01045d0:	e8 d8 f4 ff ff       	call   f0103aad <env_destroy>
f01045d5:	83 c4 10             	add    $0x10,%esp
	return 0;
f01045d8:	b8 00 00 00 00       	mov    $0x0,%eax
			return sys_env_destroy(a1);
f01045dd:	eb 93                	jmp    f0104572 <syscall+0x62>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01045df:	83 ec 08             	sub    $0x8,%esp
f01045e2:	ff 70 48             	pushl  0x48(%eax)
f01045e5:	8d 83 bd 9a f7 ff    	lea    -0x86543(%ebx),%eax
f01045eb:	50                   	push   %eax
f01045ec:	e8 26 f6 ff ff       	call   f0103c17 <cprintf>
f01045f1:	83 c4 10             	add    $0x10,%esp
f01045f4:	eb d4                	jmp    f01045ca <syscall+0xba>

f01045f6 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01045f6:	55                   	push   %ebp
f01045f7:	89 e5                	mov    %esp,%ebp
f01045f9:	57                   	push   %edi
f01045fa:	56                   	push   %esi
f01045fb:	53                   	push   %ebx
f01045fc:	83 ec 14             	sub    $0x14,%esp
f01045ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104602:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104605:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104608:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f010460b:	8b 32                	mov    (%edx),%esi
f010460d:	8b 01                	mov    (%ecx),%eax
f010460f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104612:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104619:	eb 2f                	jmp    f010464a <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f010461b:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f010461e:	39 c6                	cmp    %eax,%esi
f0104620:	7f 49                	jg     f010466b <stab_binsearch+0x75>
f0104622:	0f b6 0a             	movzbl (%edx),%ecx
f0104625:	83 ea 0c             	sub    $0xc,%edx
f0104628:	39 f9                	cmp    %edi,%ecx
f010462a:	75 ef                	jne    f010461b <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010462c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010462f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104632:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104636:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104639:	73 35                	jae    f0104670 <stab_binsearch+0x7a>
			*region_left = m;
f010463b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010463e:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0104640:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0104643:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f010464a:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f010464d:	7f 4e                	jg     f010469d <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f010464f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104652:	01 f0                	add    %esi,%eax
f0104654:	89 c3                	mov    %eax,%ebx
f0104656:	c1 eb 1f             	shr    $0x1f,%ebx
f0104659:	01 c3                	add    %eax,%ebx
f010465b:	d1 fb                	sar    %ebx
f010465d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104660:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104663:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104667:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0104669:	eb b3                	jmp    f010461e <stab_binsearch+0x28>
			l = true_m + 1;
f010466b:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f010466e:	eb da                	jmp    f010464a <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0104670:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104673:	76 14                	jbe    f0104689 <stab_binsearch+0x93>
			*region_right = m - 1;
f0104675:	83 e8 01             	sub    $0x1,%eax
f0104678:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010467b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010467e:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0104680:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104687:	eb c1                	jmp    f010464a <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104689:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010468c:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f010468e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104692:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0104694:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010469b:	eb ad                	jmp    f010464a <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f010469d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01046a1:	74 16                	je     f01046b9 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01046a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01046a6:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01046a8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01046ab:	8b 0e                	mov    (%esi),%ecx
f01046ad:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01046b0:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01046b3:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f01046b7:	eb 12                	jmp    f01046cb <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f01046b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046bc:	8b 00                	mov    (%eax),%eax
f01046be:	83 e8 01             	sub    $0x1,%eax
f01046c1:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01046c4:	89 07                	mov    %eax,(%edi)
f01046c6:	eb 16                	jmp    f01046de <stab_binsearch+0xe8>
		     l--)
f01046c8:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f01046cb:	39 c1                	cmp    %eax,%ecx
f01046cd:	7d 0a                	jge    f01046d9 <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f01046cf:	0f b6 1a             	movzbl (%edx),%ebx
f01046d2:	83 ea 0c             	sub    $0xc,%edx
f01046d5:	39 fb                	cmp    %edi,%ebx
f01046d7:	75 ef                	jne    f01046c8 <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f01046d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01046dc:	89 07                	mov    %eax,(%edi)
	}
}
f01046de:	83 c4 14             	add    $0x14,%esp
f01046e1:	5b                   	pop    %ebx
f01046e2:	5e                   	pop    %esi
f01046e3:	5f                   	pop    %edi
f01046e4:	5d                   	pop    %ebp
f01046e5:	c3                   	ret    

f01046e6 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01046e6:	55                   	push   %ebp
f01046e7:	89 e5                	mov    %esp,%ebp
f01046e9:	57                   	push   %edi
f01046ea:	56                   	push   %esi
f01046eb:	53                   	push   %ebx
f01046ec:	83 ec 2c             	sub    $0x2c,%esp
f01046ef:	e8 73 ba ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01046f4:	81 c3 2c 89 08 00    	add    $0x8892c,%ebx
f01046fa:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01046fd:	8d 83 f0 9a f7 ff    	lea    -0x86510(%ebx),%eax
f0104703:	89 07                	mov    %eax,(%edi)
	info->eip_line = 0;
f0104705:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f010470c:	89 47 08             	mov    %eax,0x8(%edi)
	info->eip_fn_namelen = 9;
f010470f:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0104716:	8b 45 08             	mov    0x8(%ebp),%eax
f0104719:	89 47 10             	mov    %eax,0x10(%edi)
	info->eip_fn_narg = 0;
f010471c:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104723:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0104728:	77 21                	ja     f010474b <debuginfo_eip+0x65>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f010472a:	a1 00 00 20 00       	mov    0x200000,%eax
f010472f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f0104732:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104737:	8b 35 08 00 20 00    	mov    0x200008,%esi
f010473d:	89 75 cc             	mov    %esi,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f0104740:	8b 35 0c 00 20 00    	mov    0x20000c,%esi
f0104746:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0104749:	eb 21                	jmp    f010476c <debuginfo_eip+0x86>
		stabstr_end = __STABSTR_END__;
f010474b:	c7 c0 e2 24 11 f0    	mov    $0xf01124e2,%eax
f0104751:	89 45 d0             	mov    %eax,-0x30(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104754:	c7 c0 71 f9 10 f0    	mov    $0xf010f971,%eax
f010475a:	89 45 cc             	mov    %eax,-0x34(%ebp)
		stab_end = __STAB_END__;
f010475d:	c7 c0 70 f9 10 f0    	mov    $0xf010f970,%eax
		stabs = __STAB_BEGIN__;
f0104763:	c7 c6 0c 6d 10 f0    	mov    $0xf0106d0c,%esi
f0104769:	89 75 d4             	mov    %esi,-0x2c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010476c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010476f:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f0104772:	0f 83 30 01 00 00    	jae    f01048a8 <debuginfo_eip+0x1c2>
f0104778:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f010477c:	0f 85 2d 01 00 00    	jne    f01048af <debuginfo_eip+0x1c9>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104782:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104789:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010478c:	29 f0                	sub    %esi,%eax
f010478e:	c1 f8 02             	sar    $0x2,%eax
f0104791:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104797:	83 e8 01             	sub    $0x1,%eax
f010479a:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010479d:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01047a0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01047a3:	ff 75 08             	pushl  0x8(%ebp)
f01047a6:	6a 64                	push   $0x64
f01047a8:	89 f0                	mov    %esi,%eax
f01047aa:	e8 47 fe ff ff       	call   f01045f6 <stab_binsearch>
	if (lfile == 0)
f01047af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047b2:	83 c4 08             	add    $0x8,%esp
f01047b5:	85 c0                	test   %eax,%eax
f01047b7:	0f 84 f9 00 00 00    	je     f01048b6 <debuginfo_eip+0x1d0>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01047bd:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01047c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01047c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01047c6:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01047c9:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01047cc:	ff 75 08             	pushl  0x8(%ebp)
f01047cf:	6a 24                	push   $0x24
f01047d1:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01047d4:	89 f0                	mov    %esi,%eax
f01047d6:	e8 1b fe ff ff       	call   f01045f6 <stab_binsearch>

	if (lfun <= rfun) {
f01047db:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01047de:	83 c4 08             	add    $0x8,%esp
f01047e1:	3b 75 d8             	cmp    -0x28(%ebp),%esi
f01047e4:	7f 46                	jg     f010482c <debuginfo_eip+0x146>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01047e6:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01047e9:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01047ec:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01047ef:	8b 02                	mov    (%edx),%eax
f01047f1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01047f4:	2b 4d cc             	sub    -0x34(%ebp),%ecx
f01047f7:	39 c8                	cmp    %ecx,%eax
f01047f9:	73 06                	jae    f0104801 <debuginfo_eip+0x11b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01047fb:	03 45 cc             	add    -0x34(%ebp),%eax
f01047fe:	89 47 08             	mov    %eax,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104801:	8b 42 08             	mov    0x8(%edx),%eax
f0104804:	89 47 10             	mov    %eax,0x10(%edi)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104807:	83 ec 08             	sub    $0x8,%esp
f010480a:	6a 3a                	push   $0x3a
f010480c:	ff 77 08             	pushl  0x8(%edi)
f010480f:	e8 1f 09 00 00       	call   f0105133 <strfind>
f0104814:	2b 47 08             	sub    0x8(%edi),%eax
f0104817:	89 47 0c             	mov    %eax,0xc(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010481a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010481d:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104820:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104823:	8d 44 81 04          	lea    0x4(%ecx,%eax,4),%eax
f0104827:	83 c4 10             	add    $0x10,%esp
f010482a:	eb 11                	jmp    f010483d <debuginfo_eip+0x157>
		info->eip_fn_addr = addr;
f010482c:	8b 45 08             	mov    0x8(%ebp),%eax
f010482f:	89 47 10             	mov    %eax,0x10(%edi)
		lline = lfile;
f0104832:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104835:	eb d0                	jmp    f0104807 <debuginfo_eip+0x121>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104837:	83 ee 01             	sub    $0x1,%esi
f010483a:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f010483d:	39 f3                	cmp    %esi,%ebx
f010483f:	7f 2e                	jg     f010486f <debuginfo_eip+0x189>
	       && stabs[lline].n_type != N_SOL
f0104841:	0f b6 10             	movzbl (%eax),%edx
f0104844:	80 fa 84             	cmp    $0x84,%dl
f0104847:	74 0b                	je     f0104854 <debuginfo_eip+0x16e>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104849:	80 fa 64             	cmp    $0x64,%dl
f010484c:	75 e9                	jne    f0104837 <debuginfo_eip+0x151>
f010484e:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0104852:	74 e3                	je     f0104837 <debuginfo_eip+0x151>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104854:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104857:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010485a:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f010485d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104860:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0104863:	29 d8                	sub    %ebx,%eax
f0104865:	39 c2                	cmp    %eax,%edx
f0104867:	73 06                	jae    f010486f <debuginfo_eip+0x189>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104869:	89 d8                	mov    %ebx,%eax
f010486b:	01 d0                	add    %edx,%eax
f010486d:	89 07                	mov    %eax,(%edi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010486f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104872:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104875:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f010487a:	39 cb                	cmp    %ecx,%ebx
f010487c:	7d 44                	jge    f01048c2 <debuginfo_eip+0x1dc>
		for (lline = lfun + 1;
f010487e:	8d 53 01             	lea    0x1(%ebx),%edx
f0104881:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104884:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104887:	8d 44 83 10          	lea    0x10(%ebx,%eax,4),%eax
f010488b:	eb 07                	jmp    f0104894 <debuginfo_eip+0x1ae>
			info->eip_fn_narg++;
f010488d:	83 47 14 01          	addl   $0x1,0x14(%edi)
		     lline++)
f0104891:	83 c2 01             	add    $0x1,%edx
		for (lline = lfun + 1;
f0104894:	39 d1                	cmp    %edx,%ecx
f0104896:	74 25                	je     f01048bd <debuginfo_eip+0x1d7>
f0104898:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010489b:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f010489f:	74 ec                	je     f010488d <debuginfo_eip+0x1a7>
	return 0;
f01048a1:	b8 00 00 00 00       	mov    $0x0,%eax
f01048a6:	eb 1a                	jmp    f01048c2 <debuginfo_eip+0x1dc>
		return -1;
f01048a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01048ad:	eb 13                	jmp    f01048c2 <debuginfo_eip+0x1dc>
f01048af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01048b4:	eb 0c                	jmp    f01048c2 <debuginfo_eip+0x1dc>
		return -1;
f01048b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01048bb:	eb 05                	jmp    f01048c2 <debuginfo_eip+0x1dc>
	return 0;
f01048bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01048c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01048c5:	5b                   	pop    %ebx
f01048c6:	5e                   	pop    %esi
f01048c7:	5f                   	pop    %edi
f01048c8:	5d                   	pop    %ebp
f01048c9:	c3                   	ret    

f01048ca <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01048ca:	55                   	push   %ebp
f01048cb:	89 e5                	mov    %esp,%ebp
f01048cd:	57                   	push   %edi
f01048ce:	56                   	push   %esi
f01048cf:	53                   	push   %ebx
f01048d0:	83 ec 2c             	sub    $0x2c,%esp
f01048d3:	e8 1d eb ff ff       	call   f01033f5 <__x86.get_pc_thunk.cx>
f01048d8:	81 c1 48 87 08 00    	add    $0x88748,%ecx
f01048de:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01048e1:	89 c7                	mov    %eax,%edi
f01048e3:	89 d6                	mov    %edx,%esi
f01048e5:	8b 45 08             	mov    0x8(%ebp),%eax
f01048e8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01048eb:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01048ee:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01048f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01048f4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01048f9:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f01048fc:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f01048ff:	39 d3                	cmp    %edx,%ebx
f0104901:	72 09                	jb     f010490c <printnum+0x42>
f0104903:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104906:	0f 87 83 00 00 00    	ja     f010498f <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010490c:	83 ec 0c             	sub    $0xc,%esp
f010490f:	ff 75 18             	pushl  0x18(%ebp)
f0104912:	8b 45 14             	mov    0x14(%ebp),%eax
f0104915:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104918:	53                   	push   %ebx
f0104919:	ff 75 10             	pushl  0x10(%ebp)
f010491c:	83 ec 08             	sub    $0x8,%esp
f010491f:	ff 75 dc             	pushl  -0x24(%ebp)
f0104922:	ff 75 d8             	pushl  -0x28(%ebp)
f0104925:	ff 75 d4             	pushl  -0x2c(%ebp)
f0104928:	ff 75 d0             	pushl  -0x30(%ebp)
f010492b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010492e:	e8 1d 0a 00 00       	call   f0105350 <__udivdi3>
f0104933:	83 c4 18             	add    $0x18,%esp
f0104936:	52                   	push   %edx
f0104937:	50                   	push   %eax
f0104938:	89 f2                	mov    %esi,%edx
f010493a:	89 f8                	mov    %edi,%eax
f010493c:	e8 89 ff ff ff       	call   f01048ca <printnum>
f0104941:	83 c4 20             	add    $0x20,%esp
f0104944:	eb 13                	jmp    f0104959 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104946:	83 ec 08             	sub    $0x8,%esp
f0104949:	56                   	push   %esi
f010494a:	ff 75 18             	pushl  0x18(%ebp)
f010494d:	ff d7                	call   *%edi
f010494f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0104952:	83 eb 01             	sub    $0x1,%ebx
f0104955:	85 db                	test   %ebx,%ebx
f0104957:	7f ed                	jg     f0104946 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104959:	83 ec 08             	sub    $0x8,%esp
f010495c:	56                   	push   %esi
f010495d:	83 ec 04             	sub    $0x4,%esp
f0104960:	ff 75 dc             	pushl  -0x24(%ebp)
f0104963:	ff 75 d8             	pushl  -0x28(%ebp)
f0104966:	ff 75 d4             	pushl  -0x2c(%ebp)
f0104969:	ff 75 d0             	pushl  -0x30(%ebp)
f010496c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010496f:	89 f3                	mov    %esi,%ebx
f0104971:	e8 fa 0a 00 00       	call   f0105470 <__umoddi3>
f0104976:	83 c4 14             	add    $0x14,%esp
f0104979:	0f be 84 06 fa 9a f7 	movsbl -0x86506(%esi,%eax,1),%eax
f0104980:	ff 
f0104981:	50                   	push   %eax
f0104982:	ff d7                	call   *%edi
}
f0104984:	83 c4 10             	add    $0x10,%esp
f0104987:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010498a:	5b                   	pop    %ebx
f010498b:	5e                   	pop    %esi
f010498c:	5f                   	pop    %edi
f010498d:	5d                   	pop    %ebp
f010498e:	c3                   	ret    
f010498f:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104992:	eb be                	jmp    f0104952 <printnum+0x88>

f0104994 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104994:	55                   	push   %ebp
f0104995:	89 e5                	mov    %esp,%ebp
f0104997:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010499a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010499e:	8b 10                	mov    (%eax),%edx
f01049a0:	3b 50 04             	cmp    0x4(%eax),%edx
f01049a3:	73 0a                	jae    f01049af <sprintputch+0x1b>
		*b->buf++ = ch;
f01049a5:	8d 4a 01             	lea    0x1(%edx),%ecx
f01049a8:	89 08                	mov    %ecx,(%eax)
f01049aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01049ad:	88 02                	mov    %al,(%edx)
}
f01049af:	5d                   	pop    %ebp
f01049b0:	c3                   	ret    

f01049b1 <printfmt>:
{
f01049b1:	55                   	push   %ebp
f01049b2:	89 e5                	mov    %esp,%ebp
f01049b4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01049b7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01049ba:	50                   	push   %eax
f01049bb:	ff 75 10             	pushl  0x10(%ebp)
f01049be:	ff 75 0c             	pushl  0xc(%ebp)
f01049c1:	ff 75 08             	pushl  0x8(%ebp)
f01049c4:	e8 05 00 00 00       	call   f01049ce <vprintfmt>
}
f01049c9:	83 c4 10             	add    $0x10,%esp
f01049cc:	c9                   	leave  
f01049cd:	c3                   	ret    

f01049ce <vprintfmt>:
{
f01049ce:	55                   	push   %ebp
f01049cf:	89 e5                	mov    %esp,%ebp
f01049d1:	57                   	push   %edi
f01049d2:	56                   	push   %esi
f01049d3:	53                   	push   %ebx
f01049d4:	83 ec 2c             	sub    $0x2c,%esp
f01049d7:	e8 8b b7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01049dc:	81 c3 44 86 08 00    	add    $0x88644,%ebx
f01049e2:	8b 75 0c             	mov    0xc(%ebp),%esi
f01049e5:	8b 7d 10             	mov    0x10(%ebp),%edi
f01049e8:	e9 c3 03 00 00       	jmp    f0104db0 <.L35+0x48>
		padc = ' ';
f01049ed:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f01049f1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f01049f8:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f01049ff:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0104a06:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104a0b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104a0e:	8d 47 01             	lea    0x1(%edi),%eax
f0104a11:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104a14:	0f b6 17             	movzbl (%edi),%edx
f0104a17:	8d 42 dd             	lea    -0x23(%edx),%eax
f0104a1a:	3c 55                	cmp    $0x55,%al
f0104a1c:	0f 87 16 04 00 00    	ja     f0104e38 <.L22>
f0104a22:	0f b6 c0             	movzbl %al,%eax
f0104a25:	89 d9                	mov    %ebx,%ecx
f0104a27:	03 8c 83 84 9b f7 ff 	add    -0x8647c(%ebx,%eax,4),%ecx
f0104a2e:	ff e1                	jmp    *%ecx

f0104a30 <.L69>:
f0104a30:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0104a33:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0104a37:	eb d5                	jmp    f0104a0e <vprintfmt+0x40>

f0104a39 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
f0104a39:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0104a3c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104a40:	eb cc                	jmp    f0104a0e <vprintfmt+0x40>

f0104a42 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
f0104a42:	0f b6 d2             	movzbl %dl,%edx
f0104a45:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0104a48:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
f0104a4d:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104a50:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0104a54:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0104a57:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0104a5a:	83 f9 09             	cmp    $0x9,%ecx
f0104a5d:	77 55                	ja     f0104ab4 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
f0104a5f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0104a62:	eb e9                	jmp    f0104a4d <.L29+0xb>

f0104a64 <.L26>:
			precision = va_arg(ap, int);
f0104a64:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a67:	8b 00                	mov    (%eax),%eax
f0104a69:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0104a6c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a6f:	8d 40 04             	lea    0x4(%eax),%eax
f0104a72:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104a75:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0104a78:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104a7c:	79 90                	jns    f0104a0e <vprintfmt+0x40>
				width = precision, precision = -1;
f0104a7e:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104a81:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104a84:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0104a8b:	eb 81                	jmp    f0104a0e <vprintfmt+0x40>

f0104a8d <.L27>:
f0104a8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a90:	85 c0                	test   %eax,%eax
f0104a92:	ba 00 00 00 00       	mov    $0x0,%edx
f0104a97:	0f 49 d0             	cmovns %eax,%edx
f0104a9a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104a9d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104aa0:	e9 69 ff ff ff       	jmp    f0104a0e <vprintfmt+0x40>

f0104aa5 <.L23>:
f0104aa5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0104aa8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104aaf:	e9 5a ff ff ff       	jmp    f0104a0e <vprintfmt+0x40>
f0104ab4:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0104ab7:	eb bf                	jmp    f0104a78 <.L26+0x14>

f0104ab9 <.L33>:
			lflag++;
f0104ab9:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104abd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0104ac0:	e9 49 ff ff ff       	jmp    f0104a0e <vprintfmt+0x40>

f0104ac5 <.L30>:
			putch(va_arg(ap, int), putdat);
f0104ac5:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ac8:	8d 78 04             	lea    0x4(%eax),%edi
f0104acb:	83 ec 08             	sub    $0x8,%esp
f0104ace:	56                   	push   %esi
f0104acf:	ff 30                	pushl  (%eax)
f0104ad1:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104ad4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0104ad7:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0104ada:	e9 ce 02 00 00       	jmp    f0104dad <.L35+0x45>

f0104adf <.L32>:
			err = va_arg(ap, int);
f0104adf:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ae2:	8d 78 04             	lea    0x4(%eax),%edi
f0104ae5:	8b 00                	mov    (%eax),%eax
f0104ae7:	99                   	cltd   
f0104ae8:	31 d0                	xor    %edx,%eax
f0104aea:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104aec:	83 f8 06             	cmp    $0x6,%eax
f0104aef:	7f 27                	jg     f0104b18 <.L32+0x39>
f0104af1:	8b 94 83 90 20 00 00 	mov    0x2090(%ebx,%eax,4),%edx
f0104af8:	85 d2                	test   %edx,%edx
f0104afa:	74 1c                	je     f0104b18 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
f0104afc:	52                   	push   %edx
f0104afd:	8d 83 31 8b f7 ff    	lea    -0x874cf(%ebx),%eax
f0104b03:	50                   	push   %eax
f0104b04:	56                   	push   %esi
f0104b05:	ff 75 08             	pushl  0x8(%ebp)
f0104b08:	e8 a4 fe ff ff       	call   f01049b1 <printfmt>
f0104b0d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104b10:	89 7d 14             	mov    %edi,0x14(%ebp)
f0104b13:	e9 95 02 00 00       	jmp    f0104dad <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
f0104b18:	50                   	push   %eax
f0104b19:	8d 83 12 9b f7 ff    	lea    -0x864ee(%ebx),%eax
f0104b1f:	50                   	push   %eax
f0104b20:	56                   	push   %esi
f0104b21:	ff 75 08             	pushl  0x8(%ebp)
f0104b24:	e8 88 fe ff ff       	call   f01049b1 <printfmt>
f0104b29:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104b2c:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0104b2f:	e9 79 02 00 00       	jmp    f0104dad <.L35+0x45>

f0104b34 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
f0104b34:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b37:	83 c0 04             	add    $0x4,%eax
f0104b3a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104b3d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b40:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0104b42:	85 ff                	test   %edi,%edi
f0104b44:	8d 83 0b 9b f7 ff    	lea    -0x864f5(%ebx),%eax
f0104b4a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0104b4d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104b51:	0f 8e b5 00 00 00    	jle    f0104c0c <.L36+0xd8>
f0104b57:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104b5b:	75 08                	jne    f0104b65 <.L36+0x31>
f0104b5d:	89 75 0c             	mov    %esi,0xc(%ebp)
f0104b60:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0104b63:	eb 6d                	jmp    f0104bd2 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104b65:	83 ec 08             	sub    $0x8,%esp
f0104b68:	ff 75 cc             	pushl  -0x34(%ebp)
f0104b6b:	57                   	push   %edi
f0104b6c:	e8 7e 04 00 00       	call   f0104fef <strnlen>
f0104b71:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104b74:	29 c2                	sub    %eax,%edx
f0104b76:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0104b79:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104b7c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104b80:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104b83:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104b86:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0104b88:	eb 10                	jmp    f0104b9a <.L36+0x66>
					putch(padc, putdat);
f0104b8a:	83 ec 08             	sub    $0x8,%esp
f0104b8d:	56                   	push   %esi
f0104b8e:	ff 75 e0             	pushl  -0x20(%ebp)
f0104b91:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0104b94:	83 ef 01             	sub    $0x1,%edi
f0104b97:	83 c4 10             	add    $0x10,%esp
f0104b9a:	85 ff                	test   %edi,%edi
f0104b9c:	7f ec                	jg     f0104b8a <.L36+0x56>
f0104b9e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104ba1:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0104ba4:	85 d2                	test   %edx,%edx
f0104ba6:	b8 00 00 00 00       	mov    $0x0,%eax
f0104bab:	0f 49 c2             	cmovns %edx,%eax
f0104bae:	29 c2                	sub    %eax,%edx
f0104bb0:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0104bb3:	89 75 0c             	mov    %esi,0xc(%ebp)
f0104bb6:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0104bb9:	eb 17                	jmp    f0104bd2 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
f0104bbb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104bbf:	75 30                	jne    f0104bf1 <.L36+0xbd>
					putch(ch, putdat);
f0104bc1:	83 ec 08             	sub    $0x8,%esp
f0104bc4:	ff 75 0c             	pushl  0xc(%ebp)
f0104bc7:	50                   	push   %eax
f0104bc8:	ff 55 08             	call   *0x8(%ebp)
f0104bcb:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104bce:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f0104bd2:	83 c7 01             	add    $0x1,%edi
f0104bd5:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0104bd9:	0f be c2             	movsbl %dl,%eax
f0104bdc:	85 c0                	test   %eax,%eax
f0104bde:	74 52                	je     f0104c32 <.L36+0xfe>
f0104be0:	85 f6                	test   %esi,%esi
f0104be2:	78 d7                	js     f0104bbb <.L36+0x87>
f0104be4:	83 ee 01             	sub    $0x1,%esi
f0104be7:	79 d2                	jns    f0104bbb <.L36+0x87>
f0104be9:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104bec:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104bef:	eb 32                	jmp    f0104c23 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
f0104bf1:	0f be d2             	movsbl %dl,%edx
f0104bf4:	83 ea 20             	sub    $0x20,%edx
f0104bf7:	83 fa 5e             	cmp    $0x5e,%edx
f0104bfa:	76 c5                	jbe    f0104bc1 <.L36+0x8d>
					putch('?', putdat);
f0104bfc:	83 ec 08             	sub    $0x8,%esp
f0104bff:	ff 75 0c             	pushl  0xc(%ebp)
f0104c02:	6a 3f                	push   $0x3f
f0104c04:	ff 55 08             	call   *0x8(%ebp)
f0104c07:	83 c4 10             	add    $0x10,%esp
f0104c0a:	eb c2                	jmp    f0104bce <.L36+0x9a>
f0104c0c:	89 75 0c             	mov    %esi,0xc(%ebp)
f0104c0f:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0104c12:	eb be                	jmp    f0104bd2 <.L36+0x9e>
				putch(' ', putdat);
f0104c14:	83 ec 08             	sub    $0x8,%esp
f0104c17:	56                   	push   %esi
f0104c18:	6a 20                	push   $0x20
f0104c1a:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f0104c1d:	83 ef 01             	sub    $0x1,%edi
f0104c20:	83 c4 10             	add    $0x10,%esp
f0104c23:	85 ff                	test   %edi,%edi
f0104c25:	7f ed                	jg     f0104c14 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
f0104c27:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104c2a:	89 45 14             	mov    %eax,0x14(%ebp)
f0104c2d:	e9 7b 01 00 00       	jmp    f0104dad <.L35+0x45>
f0104c32:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104c35:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104c38:	eb e9                	jmp    f0104c23 <.L36+0xef>

f0104c3a <.L31>:
f0104c3a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0104c3d:	83 f9 01             	cmp    $0x1,%ecx
f0104c40:	7e 40                	jle    f0104c82 <.L31+0x48>
		return va_arg(*ap, long long);
f0104c42:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c45:	8b 50 04             	mov    0x4(%eax),%edx
f0104c48:	8b 00                	mov    (%eax),%eax
f0104c4a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104c4d:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104c50:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c53:	8d 40 08             	lea    0x8(%eax),%eax
f0104c56:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0104c59:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104c5d:	79 55                	jns    f0104cb4 <.L31+0x7a>
				putch('-', putdat);
f0104c5f:	83 ec 08             	sub    $0x8,%esp
f0104c62:	56                   	push   %esi
f0104c63:	6a 2d                	push   $0x2d
f0104c65:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0104c68:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104c6b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104c6e:	f7 da                	neg    %edx
f0104c70:	83 d1 00             	adc    $0x0,%ecx
f0104c73:	f7 d9                	neg    %ecx
f0104c75:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0104c78:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104c7d:	e9 10 01 00 00       	jmp    f0104d92 <.L35+0x2a>
	else if (lflag)
f0104c82:	85 c9                	test   %ecx,%ecx
f0104c84:	75 17                	jne    f0104c9d <.L31+0x63>
		return va_arg(*ap, int);
f0104c86:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c89:	8b 00                	mov    (%eax),%eax
f0104c8b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104c8e:	99                   	cltd   
f0104c8f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104c92:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c95:	8d 40 04             	lea    0x4(%eax),%eax
f0104c98:	89 45 14             	mov    %eax,0x14(%ebp)
f0104c9b:	eb bc                	jmp    f0104c59 <.L31+0x1f>
		return va_arg(*ap, long);
f0104c9d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ca0:	8b 00                	mov    (%eax),%eax
f0104ca2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104ca5:	99                   	cltd   
f0104ca6:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104ca9:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cac:	8d 40 04             	lea    0x4(%eax),%eax
f0104caf:	89 45 14             	mov    %eax,0x14(%ebp)
f0104cb2:	eb a5                	jmp    f0104c59 <.L31+0x1f>
			num = getint(&ap, lflag);
f0104cb4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104cb7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0104cba:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104cbf:	e9 ce 00 00 00       	jmp    f0104d92 <.L35+0x2a>

f0104cc4 <.L37>:
f0104cc4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0104cc7:	83 f9 01             	cmp    $0x1,%ecx
f0104cca:	7e 18                	jle    f0104ce4 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
f0104ccc:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ccf:	8b 10                	mov    (%eax),%edx
f0104cd1:	8b 48 04             	mov    0x4(%eax),%ecx
f0104cd4:	8d 40 08             	lea    0x8(%eax),%eax
f0104cd7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104cda:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104cdf:	e9 ae 00 00 00       	jmp    f0104d92 <.L35+0x2a>
	else if (lflag)
f0104ce4:	85 c9                	test   %ecx,%ecx
f0104ce6:	75 1a                	jne    f0104d02 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
f0104ce8:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ceb:	8b 10                	mov    (%eax),%edx
f0104ced:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104cf2:	8d 40 04             	lea    0x4(%eax),%eax
f0104cf5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104cf8:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104cfd:	e9 90 00 00 00       	jmp    f0104d92 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f0104d02:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d05:	8b 10                	mov    (%eax),%edx
f0104d07:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104d0c:	8d 40 04             	lea    0x4(%eax),%eax
f0104d0f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104d12:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104d17:	eb 79                	jmp    f0104d92 <.L35+0x2a>

f0104d19 <.L34>:
f0104d19:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0104d1c:	83 f9 01             	cmp    $0x1,%ecx
f0104d1f:	7e 15                	jle    f0104d36 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
f0104d21:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d24:	8b 10                	mov    (%eax),%edx
f0104d26:	8b 48 04             	mov    0x4(%eax),%ecx
f0104d29:	8d 40 08             	lea    0x8(%eax),%eax
f0104d2c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104d2f:	b8 08 00 00 00       	mov    $0x8,%eax
f0104d34:	eb 5c                	jmp    f0104d92 <.L35+0x2a>
	else if (lflag)
f0104d36:	85 c9                	test   %ecx,%ecx
f0104d38:	75 17                	jne    f0104d51 <.L34+0x38>
		return va_arg(*ap, unsigned int);
f0104d3a:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d3d:	8b 10                	mov    (%eax),%edx
f0104d3f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104d44:	8d 40 04             	lea    0x4(%eax),%eax
f0104d47:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104d4a:	b8 08 00 00 00       	mov    $0x8,%eax
f0104d4f:	eb 41                	jmp    f0104d92 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f0104d51:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d54:	8b 10                	mov    (%eax),%edx
f0104d56:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104d5b:	8d 40 04             	lea    0x4(%eax),%eax
f0104d5e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104d61:	b8 08 00 00 00       	mov    $0x8,%eax
f0104d66:	eb 2a                	jmp    f0104d92 <.L35+0x2a>

f0104d68 <.L35>:
			putch('0', putdat);
f0104d68:	83 ec 08             	sub    $0x8,%esp
f0104d6b:	56                   	push   %esi
f0104d6c:	6a 30                	push   $0x30
f0104d6e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0104d71:	83 c4 08             	add    $0x8,%esp
f0104d74:	56                   	push   %esi
f0104d75:	6a 78                	push   $0x78
f0104d77:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f0104d7a:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d7d:	8b 10                	mov    (%eax),%edx
f0104d7f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0104d84:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0104d87:	8d 40 04             	lea    0x4(%eax),%eax
f0104d8a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104d8d:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0104d92:	83 ec 0c             	sub    $0xc,%esp
f0104d95:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0104d99:	57                   	push   %edi
f0104d9a:	ff 75 e0             	pushl  -0x20(%ebp)
f0104d9d:	50                   	push   %eax
f0104d9e:	51                   	push   %ecx
f0104d9f:	52                   	push   %edx
f0104da0:	89 f2                	mov    %esi,%edx
f0104da2:	8b 45 08             	mov    0x8(%ebp),%eax
f0104da5:	e8 20 fb ff ff       	call   f01048ca <printnum>
			break;
f0104daa:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0104dad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104db0:	83 c7 01             	add    $0x1,%edi
f0104db3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104db7:	83 f8 25             	cmp    $0x25,%eax
f0104dba:	0f 84 2d fc ff ff    	je     f01049ed <vprintfmt+0x1f>
			if (ch == '\0')
f0104dc0:	85 c0                	test   %eax,%eax
f0104dc2:	0f 84 91 00 00 00    	je     f0104e59 <.L22+0x21>
			putch(ch, putdat);
f0104dc8:	83 ec 08             	sub    $0x8,%esp
f0104dcb:	56                   	push   %esi
f0104dcc:	50                   	push   %eax
f0104dcd:	ff 55 08             	call   *0x8(%ebp)
f0104dd0:	83 c4 10             	add    $0x10,%esp
f0104dd3:	eb db                	jmp    f0104db0 <.L35+0x48>

f0104dd5 <.L38>:
f0104dd5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0104dd8:	83 f9 01             	cmp    $0x1,%ecx
f0104ddb:	7e 15                	jle    f0104df2 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
f0104ddd:	8b 45 14             	mov    0x14(%ebp),%eax
f0104de0:	8b 10                	mov    (%eax),%edx
f0104de2:	8b 48 04             	mov    0x4(%eax),%ecx
f0104de5:	8d 40 08             	lea    0x8(%eax),%eax
f0104de8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104deb:	b8 10 00 00 00       	mov    $0x10,%eax
f0104df0:	eb a0                	jmp    f0104d92 <.L35+0x2a>
	else if (lflag)
f0104df2:	85 c9                	test   %ecx,%ecx
f0104df4:	75 17                	jne    f0104e0d <.L38+0x38>
		return va_arg(*ap, unsigned int);
f0104df6:	8b 45 14             	mov    0x14(%ebp),%eax
f0104df9:	8b 10                	mov    (%eax),%edx
f0104dfb:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104e00:	8d 40 04             	lea    0x4(%eax),%eax
f0104e03:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104e06:	b8 10 00 00 00       	mov    $0x10,%eax
f0104e0b:	eb 85                	jmp    f0104d92 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f0104e0d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e10:	8b 10                	mov    (%eax),%edx
f0104e12:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104e17:	8d 40 04             	lea    0x4(%eax),%eax
f0104e1a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104e1d:	b8 10 00 00 00       	mov    $0x10,%eax
f0104e22:	e9 6b ff ff ff       	jmp    f0104d92 <.L35+0x2a>

f0104e27 <.L25>:
			putch(ch, putdat);
f0104e27:	83 ec 08             	sub    $0x8,%esp
f0104e2a:	56                   	push   %esi
f0104e2b:	6a 25                	push   $0x25
f0104e2d:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104e30:	83 c4 10             	add    $0x10,%esp
f0104e33:	e9 75 ff ff ff       	jmp    f0104dad <.L35+0x45>

f0104e38 <.L22>:
			putch('%', putdat);
f0104e38:	83 ec 08             	sub    $0x8,%esp
f0104e3b:	56                   	push   %esi
f0104e3c:	6a 25                	push   $0x25
f0104e3e:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104e41:	83 c4 10             	add    $0x10,%esp
f0104e44:	89 f8                	mov    %edi,%eax
f0104e46:	eb 03                	jmp    f0104e4b <.L22+0x13>
f0104e48:	83 e8 01             	sub    $0x1,%eax
f0104e4b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0104e4f:	75 f7                	jne    f0104e48 <.L22+0x10>
f0104e51:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104e54:	e9 54 ff ff ff       	jmp    f0104dad <.L35+0x45>
}
f0104e59:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104e5c:	5b                   	pop    %ebx
f0104e5d:	5e                   	pop    %esi
f0104e5e:	5f                   	pop    %edi
f0104e5f:	5d                   	pop    %ebp
f0104e60:	c3                   	ret    

f0104e61 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104e61:	55                   	push   %ebp
f0104e62:	89 e5                	mov    %esp,%ebp
f0104e64:	53                   	push   %ebx
f0104e65:	83 ec 14             	sub    $0x14,%esp
f0104e68:	e8 fa b2 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104e6d:	81 c3 b3 81 08 00    	add    $0x881b3,%ebx
f0104e73:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e76:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104e79:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104e7c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104e80:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104e83:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104e8a:	85 c0                	test   %eax,%eax
f0104e8c:	74 2b                	je     f0104eb9 <vsnprintf+0x58>
f0104e8e:	85 d2                	test   %edx,%edx
f0104e90:	7e 27                	jle    f0104eb9 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104e92:	ff 75 14             	pushl  0x14(%ebp)
f0104e95:	ff 75 10             	pushl  0x10(%ebp)
f0104e98:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104e9b:	50                   	push   %eax
f0104e9c:	8d 83 74 79 f7 ff    	lea    -0x8868c(%ebx),%eax
f0104ea2:	50                   	push   %eax
f0104ea3:	e8 26 fb ff ff       	call   f01049ce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104ea8:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104eab:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104eb1:	83 c4 10             	add    $0x10,%esp
}
f0104eb4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104eb7:	c9                   	leave  
f0104eb8:	c3                   	ret    
		return -E_INVAL;
f0104eb9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104ebe:	eb f4                	jmp    f0104eb4 <vsnprintf+0x53>

f0104ec0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104ec0:	55                   	push   %ebp
f0104ec1:	89 e5                	mov    %esp,%ebp
f0104ec3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104ec6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104ec9:	50                   	push   %eax
f0104eca:	ff 75 10             	pushl  0x10(%ebp)
f0104ecd:	ff 75 0c             	pushl  0xc(%ebp)
f0104ed0:	ff 75 08             	pushl  0x8(%ebp)
f0104ed3:	e8 89 ff ff ff       	call   f0104e61 <vsnprintf>
	va_end(ap);

	return rc;
}
f0104ed8:	c9                   	leave  
f0104ed9:	c3                   	ret    

f0104eda <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104eda:	55                   	push   %ebp
f0104edb:	89 e5                	mov    %esp,%ebp
f0104edd:	57                   	push   %edi
f0104ede:	56                   	push   %esi
f0104edf:	53                   	push   %ebx
f0104ee0:	83 ec 1c             	sub    $0x1c,%esp
f0104ee3:	e8 7f b2 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104ee8:	81 c3 38 81 08 00    	add    $0x88138,%ebx
f0104eee:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104ef1:	85 c0                	test   %eax,%eax
f0104ef3:	74 13                	je     f0104f08 <readline+0x2e>
		cprintf("%s", prompt);
f0104ef5:	83 ec 08             	sub    $0x8,%esp
f0104ef8:	50                   	push   %eax
f0104ef9:	8d 83 31 8b f7 ff    	lea    -0x874cf(%ebx),%eax
f0104eff:	50                   	push   %eax
f0104f00:	e8 12 ed ff ff       	call   f0103c17 <cprintf>
f0104f05:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104f08:	83 ec 0c             	sub    $0xc,%esp
f0104f0b:	6a 00                	push   $0x0
f0104f0d:	e8 ed b7 ff ff       	call   f01006ff <iscons>
f0104f12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104f15:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0104f18:	bf 00 00 00 00       	mov    $0x0,%edi
f0104f1d:	eb 46                	jmp    f0104f65 <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0104f1f:	83 ec 08             	sub    $0x8,%esp
f0104f22:	50                   	push   %eax
f0104f23:	8d 83 dc 9c f7 ff    	lea    -0x86324(%ebx),%eax
f0104f29:	50                   	push   %eax
f0104f2a:	e8 e8 ec ff ff       	call   f0103c17 <cprintf>
			return NULL;
f0104f2f:	83 c4 10             	add    $0x10,%esp
f0104f32:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0104f37:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f3a:	5b                   	pop    %ebx
f0104f3b:	5e                   	pop    %esi
f0104f3c:	5f                   	pop    %edi
f0104f3d:	5d                   	pop    %ebp
f0104f3e:	c3                   	ret    
			if (echoing)
f0104f3f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104f43:	75 05                	jne    f0104f4a <readline+0x70>
			i--;
f0104f45:	83 ef 01             	sub    $0x1,%edi
f0104f48:	eb 1b                	jmp    f0104f65 <readline+0x8b>
				cputchar('\b');
f0104f4a:	83 ec 0c             	sub    $0xc,%esp
f0104f4d:	6a 08                	push   $0x8
f0104f4f:	e8 8a b7 ff ff       	call   f01006de <cputchar>
f0104f54:	83 c4 10             	add    $0x10,%esp
f0104f57:	eb ec                	jmp    f0104f45 <readline+0x6b>
			buf[i++] = c;
f0104f59:	89 f0                	mov    %esi,%eax
f0104f5b:	88 84 3b c0 2b 00 00 	mov    %al,0x2bc0(%ebx,%edi,1)
f0104f62:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0104f65:	e8 84 b7 ff ff       	call   f01006ee <getchar>
f0104f6a:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0104f6c:	85 c0                	test   %eax,%eax
f0104f6e:	78 af                	js     f0104f1f <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104f70:	83 f8 08             	cmp    $0x8,%eax
f0104f73:	0f 94 c2             	sete   %dl
f0104f76:	83 f8 7f             	cmp    $0x7f,%eax
f0104f79:	0f 94 c0             	sete   %al
f0104f7c:	08 c2                	or     %al,%dl
f0104f7e:	74 04                	je     f0104f84 <readline+0xaa>
f0104f80:	85 ff                	test   %edi,%edi
f0104f82:	7f bb                	jg     f0104f3f <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104f84:	83 fe 1f             	cmp    $0x1f,%esi
f0104f87:	7e 1c                	jle    f0104fa5 <readline+0xcb>
f0104f89:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0104f8f:	7f 14                	jg     f0104fa5 <readline+0xcb>
			if (echoing)
f0104f91:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104f95:	74 c2                	je     f0104f59 <readline+0x7f>
				cputchar(c);
f0104f97:	83 ec 0c             	sub    $0xc,%esp
f0104f9a:	56                   	push   %esi
f0104f9b:	e8 3e b7 ff ff       	call   f01006de <cputchar>
f0104fa0:	83 c4 10             	add    $0x10,%esp
f0104fa3:	eb b4                	jmp    f0104f59 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f0104fa5:	83 fe 0a             	cmp    $0xa,%esi
f0104fa8:	74 05                	je     f0104faf <readline+0xd5>
f0104faa:	83 fe 0d             	cmp    $0xd,%esi
f0104fad:	75 b6                	jne    f0104f65 <readline+0x8b>
			if (echoing)
f0104faf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104fb3:	75 13                	jne    f0104fc8 <readline+0xee>
			buf[i] = 0;
f0104fb5:	c6 84 3b c0 2b 00 00 	movb   $0x0,0x2bc0(%ebx,%edi,1)
f0104fbc:	00 
			return buf;
f0104fbd:	8d 83 c0 2b 00 00    	lea    0x2bc0(%ebx),%eax
f0104fc3:	e9 6f ff ff ff       	jmp    f0104f37 <readline+0x5d>
				cputchar('\n');
f0104fc8:	83 ec 0c             	sub    $0xc,%esp
f0104fcb:	6a 0a                	push   $0xa
f0104fcd:	e8 0c b7 ff ff       	call   f01006de <cputchar>
f0104fd2:	83 c4 10             	add    $0x10,%esp
f0104fd5:	eb de                	jmp    f0104fb5 <readline+0xdb>

f0104fd7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104fd7:	55                   	push   %ebp
f0104fd8:	89 e5                	mov    %esp,%ebp
f0104fda:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104fdd:	b8 00 00 00 00       	mov    $0x0,%eax
f0104fe2:	eb 03                	jmp    f0104fe7 <strlen+0x10>
		n++;
f0104fe4:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0104fe7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104feb:	75 f7                	jne    f0104fe4 <strlen+0xd>
	return n;
}
f0104fed:	5d                   	pop    %ebp
f0104fee:	c3                   	ret    

f0104fef <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104fef:	55                   	push   %ebp
f0104ff0:	89 e5                	mov    %esp,%ebp
f0104ff2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104ff5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104ff8:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ffd:	eb 03                	jmp    f0105002 <strnlen+0x13>
		n++;
f0104fff:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105002:	39 d0                	cmp    %edx,%eax
f0105004:	74 06                	je     f010500c <strnlen+0x1d>
f0105006:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010500a:	75 f3                	jne    f0104fff <strnlen+0x10>
	return n;
}
f010500c:	5d                   	pop    %ebp
f010500d:	c3                   	ret    

f010500e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010500e:	55                   	push   %ebp
f010500f:	89 e5                	mov    %esp,%ebp
f0105011:	53                   	push   %ebx
f0105012:	8b 45 08             	mov    0x8(%ebp),%eax
f0105015:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105018:	89 c2                	mov    %eax,%edx
f010501a:	83 c1 01             	add    $0x1,%ecx
f010501d:	83 c2 01             	add    $0x1,%edx
f0105020:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105024:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105027:	84 db                	test   %bl,%bl
f0105029:	75 ef                	jne    f010501a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010502b:	5b                   	pop    %ebx
f010502c:	5d                   	pop    %ebp
f010502d:	c3                   	ret    

f010502e <strcat>:

char *
strcat(char *dst, const char *src)
{
f010502e:	55                   	push   %ebp
f010502f:	89 e5                	mov    %esp,%ebp
f0105031:	53                   	push   %ebx
f0105032:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105035:	53                   	push   %ebx
f0105036:	e8 9c ff ff ff       	call   f0104fd7 <strlen>
f010503b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010503e:	ff 75 0c             	pushl  0xc(%ebp)
f0105041:	01 d8                	add    %ebx,%eax
f0105043:	50                   	push   %eax
f0105044:	e8 c5 ff ff ff       	call   f010500e <strcpy>
	return dst;
}
f0105049:	89 d8                	mov    %ebx,%eax
f010504b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010504e:	c9                   	leave  
f010504f:	c3                   	ret    

f0105050 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105050:	55                   	push   %ebp
f0105051:	89 e5                	mov    %esp,%ebp
f0105053:	56                   	push   %esi
f0105054:	53                   	push   %ebx
f0105055:	8b 75 08             	mov    0x8(%ebp),%esi
f0105058:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010505b:	89 f3                	mov    %esi,%ebx
f010505d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105060:	89 f2                	mov    %esi,%edx
f0105062:	eb 0f                	jmp    f0105073 <strncpy+0x23>
		*dst++ = *src;
f0105064:	83 c2 01             	add    $0x1,%edx
f0105067:	0f b6 01             	movzbl (%ecx),%eax
f010506a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010506d:	80 39 01             	cmpb   $0x1,(%ecx)
f0105070:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0105073:	39 da                	cmp    %ebx,%edx
f0105075:	75 ed                	jne    f0105064 <strncpy+0x14>
	}
	return ret;
}
f0105077:	89 f0                	mov    %esi,%eax
f0105079:	5b                   	pop    %ebx
f010507a:	5e                   	pop    %esi
f010507b:	5d                   	pop    %ebp
f010507c:	c3                   	ret    

f010507d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010507d:	55                   	push   %ebp
f010507e:	89 e5                	mov    %esp,%ebp
f0105080:	56                   	push   %esi
f0105081:	53                   	push   %ebx
f0105082:	8b 75 08             	mov    0x8(%ebp),%esi
f0105085:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105088:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010508b:	89 f0                	mov    %esi,%eax
f010508d:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105091:	85 c9                	test   %ecx,%ecx
f0105093:	75 0b                	jne    f01050a0 <strlcpy+0x23>
f0105095:	eb 17                	jmp    f01050ae <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105097:	83 c2 01             	add    $0x1,%edx
f010509a:	83 c0 01             	add    $0x1,%eax
f010509d:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f01050a0:	39 d8                	cmp    %ebx,%eax
f01050a2:	74 07                	je     f01050ab <strlcpy+0x2e>
f01050a4:	0f b6 0a             	movzbl (%edx),%ecx
f01050a7:	84 c9                	test   %cl,%cl
f01050a9:	75 ec                	jne    f0105097 <strlcpy+0x1a>
		*dst = '\0';
f01050ab:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01050ae:	29 f0                	sub    %esi,%eax
}
f01050b0:	5b                   	pop    %ebx
f01050b1:	5e                   	pop    %esi
f01050b2:	5d                   	pop    %ebp
f01050b3:	c3                   	ret    

f01050b4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01050b4:	55                   	push   %ebp
f01050b5:	89 e5                	mov    %esp,%ebp
f01050b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01050ba:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01050bd:	eb 06                	jmp    f01050c5 <strcmp+0x11>
		p++, q++;
f01050bf:	83 c1 01             	add    $0x1,%ecx
f01050c2:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01050c5:	0f b6 01             	movzbl (%ecx),%eax
f01050c8:	84 c0                	test   %al,%al
f01050ca:	74 04                	je     f01050d0 <strcmp+0x1c>
f01050cc:	3a 02                	cmp    (%edx),%al
f01050ce:	74 ef                	je     f01050bf <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01050d0:	0f b6 c0             	movzbl %al,%eax
f01050d3:	0f b6 12             	movzbl (%edx),%edx
f01050d6:	29 d0                	sub    %edx,%eax
}
f01050d8:	5d                   	pop    %ebp
f01050d9:	c3                   	ret    

f01050da <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01050da:	55                   	push   %ebp
f01050db:	89 e5                	mov    %esp,%ebp
f01050dd:	53                   	push   %ebx
f01050de:	8b 45 08             	mov    0x8(%ebp),%eax
f01050e1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01050e4:	89 c3                	mov    %eax,%ebx
f01050e6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01050e9:	eb 06                	jmp    f01050f1 <strncmp+0x17>
		n--, p++, q++;
f01050eb:	83 c0 01             	add    $0x1,%eax
f01050ee:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01050f1:	39 d8                	cmp    %ebx,%eax
f01050f3:	74 16                	je     f010510b <strncmp+0x31>
f01050f5:	0f b6 08             	movzbl (%eax),%ecx
f01050f8:	84 c9                	test   %cl,%cl
f01050fa:	74 04                	je     f0105100 <strncmp+0x26>
f01050fc:	3a 0a                	cmp    (%edx),%cl
f01050fe:	74 eb                	je     f01050eb <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105100:	0f b6 00             	movzbl (%eax),%eax
f0105103:	0f b6 12             	movzbl (%edx),%edx
f0105106:	29 d0                	sub    %edx,%eax
}
f0105108:	5b                   	pop    %ebx
f0105109:	5d                   	pop    %ebp
f010510a:	c3                   	ret    
		return 0;
f010510b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105110:	eb f6                	jmp    f0105108 <strncmp+0x2e>

f0105112 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105112:	55                   	push   %ebp
f0105113:	89 e5                	mov    %esp,%ebp
f0105115:	8b 45 08             	mov    0x8(%ebp),%eax
f0105118:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010511c:	0f b6 10             	movzbl (%eax),%edx
f010511f:	84 d2                	test   %dl,%dl
f0105121:	74 09                	je     f010512c <strchr+0x1a>
		if (*s == c)
f0105123:	38 ca                	cmp    %cl,%dl
f0105125:	74 0a                	je     f0105131 <strchr+0x1f>
	for (; *s; s++)
f0105127:	83 c0 01             	add    $0x1,%eax
f010512a:	eb f0                	jmp    f010511c <strchr+0xa>
			return (char *) s;
	return 0;
f010512c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105131:	5d                   	pop    %ebp
f0105132:	c3                   	ret    

f0105133 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105133:	55                   	push   %ebp
f0105134:	89 e5                	mov    %esp,%ebp
f0105136:	8b 45 08             	mov    0x8(%ebp),%eax
f0105139:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010513d:	eb 03                	jmp    f0105142 <strfind+0xf>
f010513f:	83 c0 01             	add    $0x1,%eax
f0105142:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105145:	38 ca                	cmp    %cl,%dl
f0105147:	74 04                	je     f010514d <strfind+0x1a>
f0105149:	84 d2                	test   %dl,%dl
f010514b:	75 f2                	jne    f010513f <strfind+0xc>
			break;
	return (char *) s;
}
f010514d:	5d                   	pop    %ebp
f010514e:	c3                   	ret    

f010514f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010514f:	55                   	push   %ebp
f0105150:	89 e5                	mov    %esp,%ebp
f0105152:	57                   	push   %edi
f0105153:	56                   	push   %esi
f0105154:	53                   	push   %ebx
f0105155:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105158:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010515b:	85 c9                	test   %ecx,%ecx
f010515d:	74 13                	je     f0105172 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010515f:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105165:	75 05                	jne    f010516c <memset+0x1d>
f0105167:	f6 c1 03             	test   $0x3,%cl
f010516a:	74 0d                	je     f0105179 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010516c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010516f:	fc                   	cld    
f0105170:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105172:	89 f8                	mov    %edi,%eax
f0105174:	5b                   	pop    %ebx
f0105175:	5e                   	pop    %esi
f0105176:	5f                   	pop    %edi
f0105177:	5d                   	pop    %ebp
f0105178:	c3                   	ret    
		c &= 0xFF;
f0105179:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010517d:	89 d3                	mov    %edx,%ebx
f010517f:	c1 e3 08             	shl    $0x8,%ebx
f0105182:	89 d0                	mov    %edx,%eax
f0105184:	c1 e0 18             	shl    $0x18,%eax
f0105187:	89 d6                	mov    %edx,%esi
f0105189:	c1 e6 10             	shl    $0x10,%esi
f010518c:	09 f0                	or     %esi,%eax
f010518e:	09 c2                	or     %eax,%edx
f0105190:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0105192:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0105195:	89 d0                	mov    %edx,%eax
f0105197:	fc                   	cld    
f0105198:	f3 ab                	rep stos %eax,%es:(%edi)
f010519a:	eb d6                	jmp    f0105172 <memset+0x23>

f010519c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010519c:	55                   	push   %ebp
f010519d:	89 e5                	mov    %esp,%ebp
f010519f:	57                   	push   %edi
f01051a0:	56                   	push   %esi
f01051a1:	8b 45 08             	mov    0x8(%ebp),%eax
f01051a4:	8b 75 0c             	mov    0xc(%ebp),%esi
f01051a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01051aa:	39 c6                	cmp    %eax,%esi
f01051ac:	73 35                	jae    f01051e3 <memmove+0x47>
f01051ae:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01051b1:	39 c2                	cmp    %eax,%edx
f01051b3:	76 2e                	jbe    f01051e3 <memmove+0x47>
		s += n;
		d += n;
f01051b5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01051b8:	89 d6                	mov    %edx,%esi
f01051ba:	09 fe                	or     %edi,%esi
f01051bc:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01051c2:	74 0c                	je     f01051d0 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01051c4:	83 ef 01             	sub    $0x1,%edi
f01051c7:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01051ca:	fd                   	std    
f01051cb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01051cd:	fc                   	cld    
f01051ce:	eb 21                	jmp    f01051f1 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01051d0:	f6 c1 03             	test   $0x3,%cl
f01051d3:	75 ef                	jne    f01051c4 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01051d5:	83 ef 04             	sub    $0x4,%edi
f01051d8:	8d 72 fc             	lea    -0x4(%edx),%esi
f01051db:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01051de:	fd                   	std    
f01051df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01051e1:	eb ea                	jmp    f01051cd <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01051e3:	89 f2                	mov    %esi,%edx
f01051e5:	09 c2                	or     %eax,%edx
f01051e7:	f6 c2 03             	test   $0x3,%dl
f01051ea:	74 09                	je     f01051f5 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01051ec:	89 c7                	mov    %eax,%edi
f01051ee:	fc                   	cld    
f01051ef:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01051f1:	5e                   	pop    %esi
f01051f2:	5f                   	pop    %edi
f01051f3:	5d                   	pop    %ebp
f01051f4:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01051f5:	f6 c1 03             	test   $0x3,%cl
f01051f8:	75 f2                	jne    f01051ec <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01051fa:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01051fd:	89 c7                	mov    %eax,%edi
f01051ff:	fc                   	cld    
f0105200:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105202:	eb ed                	jmp    f01051f1 <memmove+0x55>

f0105204 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105204:	55                   	push   %ebp
f0105205:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105207:	ff 75 10             	pushl  0x10(%ebp)
f010520a:	ff 75 0c             	pushl  0xc(%ebp)
f010520d:	ff 75 08             	pushl  0x8(%ebp)
f0105210:	e8 87 ff ff ff       	call   f010519c <memmove>
}
f0105215:	c9                   	leave  
f0105216:	c3                   	ret    

f0105217 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105217:	55                   	push   %ebp
f0105218:	89 e5                	mov    %esp,%ebp
f010521a:	56                   	push   %esi
f010521b:	53                   	push   %ebx
f010521c:	8b 45 08             	mov    0x8(%ebp),%eax
f010521f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105222:	89 c6                	mov    %eax,%esi
f0105224:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105227:	39 f0                	cmp    %esi,%eax
f0105229:	74 1c                	je     f0105247 <memcmp+0x30>
		if (*s1 != *s2)
f010522b:	0f b6 08             	movzbl (%eax),%ecx
f010522e:	0f b6 1a             	movzbl (%edx),%ebx
f0105231:	38 d9                	cmp    %bl,%cl
f0105233:	75 08                	jne    f010523d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0105235:	83 c0 01             	add    $0x1,%eax
f0105238:	83 c2 01             	add    $0x1,%edx
f010523b:	eb ea                	jmp    f0105227 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f010523d:	0f b6 c1             	movzbl %cl,%eax
f0105240:	0f b6 db             	movzbl %bl,%ebx
f0105243:	29 d8                	sub    %ebx,%eax
f0105245:	eb 05                	jmp    f010524c <memcmp+0x35>
	}

	return 0;
f0105247:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010524c:	5b                   	pop    %ebx
f010524d:	5e                   	pop    %esi
f010524e:	5d                   	pop    %ebp
f010524f:	c3                   	ret    

f0105250 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105250:	55                   	push   %ebp
f0105251:	89 e5                	mov    %esp,%ebp
f0105253:	8b 45 08             	mov    0x8(%ebp),%eax
f0105256:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105259:	89 c2                	mov    %eax,%edx
f010525b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010525e:	39 d0                	cmp    %edx,%eax
f0105260:	73 09                	jae    f010526b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105262:	38 08                	cmp    %cl,(%eax)
f0105264:	74 05                	je     f010526b <memfind+0x1b>
	for (; s < ends; s++)
f0105266:	83 c0 01             	add    $0x1,%eax
f0105269:	eb f3                	jmp    f010525e <memfind+0xe>
			break;
	return (void *) s;
}
f010526b:	5d                   	pop    %ebp
f010526c:	c3                   	ret    

f010526d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010526d:	55                   	push   %ebp
f010526e:	89 e5                	mov    %esp,%ebp
f0105270:	57                   	push   %edi
f0105271:	56                   	push   %esi
f0105272:	53                   	push   %ebx
f0105273:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105276:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105279:	eb 03                	jmp    f010527e <strtol+0x11>
		s++;
f010527b:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f010527e:	0f b6 01             	movzbl (%ecx),%eax
f0105281:	3c 20                	cmp    $0x20,%al
f0105283:	74 f6                	je     f010527b <strtol+0xe>
f0105285:	3c 09                	cmp    $0x9,%al
f0105287:	74 f2                	je     f010527b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0105289:	3c 2b                	cmp    $0x2b,%al
f010528b:	74 2e                	je     f01052bb <strtol+0x4e>
	int neg = 0;
f010528d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105292:	3c 2d                	cmp    $0x2d,%al
f0105294:	74 2f                	je     f01052c5 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105296:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010529c:	75 05                	jne    f01052a3 <strtol+0x36>
f010529e:	80 39 30             	cmpb   $0x30,(%ecx)
f01052a1:	74 2c                	je     f01052cf <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01052a3:	85 db                	test   %ebx,%ebx
f01052a5:	75 0a                	jne    f01052b1 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01052a7:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f01052ac:	80 39 30             	cmpb   $0x30,(%ecx)
f01052af:	74 28                	je     f01052d9 <strtol+0x6c>
		base = 10;
f01052b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01052b6:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01052b9:	eb 50                	jmp    f010530b <strtol+0x9e>
		s++;
f01052bb:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01052be:	bf 00 00 00 00       	mov    $0x0,%edi
f01052c3:	eb d1                	jmp    f0105296 <strtol+0x29>
		s++, neg = 1;
f01052c5:	83 c1 01             	add    $0x1,%ecx
f01052c8:	bf 01 00 00 00       	mov    $0x1,%edi
f01052cd:	eb c7                	jmp    f0105296 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01052cf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01052d3:	74 0e                	je     f01052e3 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01052d5:	85 db                	test   %ebx,%ebx
f01052d7:	75 d8                	jne    f01052b1 <strtol+0x44>
		s++, base = 8;
f01052d9:	83 c1 01             	add    $0x1,%ecx
f01052dc:	bb 08 00 00 00       	mov    $0x8,%ebx
f01052e1:	eb ce                	jmp    f01052b1 <strtol+0x44>
		s += 2, base = 16;
f01052e3:	83 c1 02             	add    $0x2,%ecx
f01052e6:	bb 10 00 00 00       	mov    $0x10,%ebx
f01052eb:	eb c4                	jmp    f01052b1 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01052ed:	8d 72 9f             	lea    -0x61(%edx),%esi
f01052f0:	89 f3                	mov    %esi,%ebx
f01052f2:	80 fb 19             	cmp    $0x19,%bl
f01052f5:	77 29                	ja     f0105320 <strtol+0xb3>
			dig = *s - 'a' + 10;
f01052f7:	0f be d2             	movsbl %dl,%edx
f01052fa:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01052fd:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105300:	7d 30                	jge    f0105332 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0105302:	83 c1 01             	add    $0x1,%ecx
f0105305:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105309:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f010530b:	0f b6 11             	movzbl (%ecx),%edx
f010530e:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105311:	89 f3                	mov    %esi,%ebx
f0105313:	80 fb 09             	cmp    $0x9,%bl
f0105316:	77 d5                	ja     f01052ed <strtol+0x80>
			dig = *s - '0';
f0105318:	0f be d2             	movsbl %dl,%edx
f010531b:	83 ea 30             	sub    $0x30,%edx
f010531e:	eb dd                	jmp    f01052fd <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f0105320:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105323:	89 f3                	mov    %esi,%ebx
f0105325:	80 fb 19             	cmp    $0x19,%bl
f0105328:	77 08                	ja     f0105332 <strtol+0xc5>
			dig = *s - 'A' + 10;
f010532a:	0f be d2             	movsbl %dl,%edx
f010532d:	83 ea 37             	sub    $0x37,%edx
f0105330:	eb cb                	jmp    f01052fd <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105332:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105336:	74 05                	je     f010533d <strtol+0xd0>
		*endptr = (char *) s;
f0105338:	8b 75 0c             	mov    0xc(%ebp),%esi
f010533b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f010533d:	89 c2                	mov    %eax,%edx
f010533f:	f7 da                	neg    %edx
f0105341:	85 ff                	test   %edi,%edi
f0105343:	0f 45 c2             	cmovne %edx,%eax
}
f0105346:	5b                   	pop    %ebx
f0105347:	5e                   	pop    %esi
f0105348:	5f                   	pop    %edi
f0105349:	5d                   	pop    %ebp
f010534a:	c3                   	ret    
f010534b:	66 90                	xchg   %ax,%ax
f010534d:	66 90                	xchg   %ax,%ax
f010534f:	90                   	nop

f0105350 <__udivdi3>:
f0105350:	55                   	push   %ebp
f0105351:	57                   	push   %edi
f0105352:	56                   	push   %esi
f0105353:	53                   	push   %ebx
f0105354:	83 ec 1c             	sub    $0x1c,%esp
f0105357:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010535b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010535f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105363:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0105367:	85 d2                	test   %edx,%edx
f0105369:	75 35                	jne    f01053a0 <__udivdi3+0x50>
f010536b:	39 f3                	cmp    %esi,%ebx
f010536d:	0f 87 bd 00 00 00    	ja     f0105430 <__udivdi3+0xe0>
f0105373:	85 db                	test   %ebx,%ebx
f0105375:	89 d9                	mov    %ebx,%ecx
f0105377:	75 0b                	jne    f0105384 <__udivdi3+0x34>
f0105379:	b8 01 00 00 00       	mov    $0x1,%eax
f010537e:	31 d2                	xor    %edx,%edx
f0105380:	f7 f3                	div    %ebx
f0105382:	89 c1                	mov    %eax,%ecx
f0105384:	31 d2                	xor    %edx,%edx
f0105386:	89 f0                	mov    %esi,%eax
f0105388:	f7 f1                	div    %ecx
f010538a:	89 c6                	mov    %eax,%esi
f010538c:	89 e8                	mov    %ebp,%eax
f010538e:	89 f7                	mov    %esi,%edi
f0105390:	f7 f1                	div    %ecx
f0105392:	89 fa                	mov    %edi,%edx
f0105394:	83 c4 1c             	add    $0x1c,%esp
f0105397:	5b                   	pop    %ebx
f0105398:	5e                   	pop    %esi
f0105399:	5f                   	pop    %edi
f010539a:	5d                   	pop    %ebp
f010539b:	c3                   	ret    
f010539c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01053a0:	39 f2                	cmp    %esi,%edx
f01053a2:	77 7c                	ja     f0105420 <__udivdi3+0xd0>
f01053a4:	0f bd fa             	bsr    %edx,%edi
f01053a7:	83 f7 1f             	xor    $0x1f,%edi
f01053aa:	0f 84 98 00 00 00    	je     f0105448 <__udivdi3+0xf8>
f01053b0:	89 f9                	mov    %edi,%ecx
f01053b2:	b8 20 00 00 00       	mov    $0x20,%eax
f01053b7:	29 f8                	sub    %edi,%eax
f01053b9:	d3 e2                	shl    %cl,%edx
f01053bb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01053bf:	89 c1                	mov    %eax,%ecx
f01053c1:	89 da                	mov    %ebx,%edx
f01053c3:	d3 ea                	shr    %cl,%edx
f01053c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01053c9:	09 d1                	or     %edx,%ecx
f01053cb:	89 f2                	mov    %esi,%edx
f01053cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01053d1:	89 f9                	mov    %edi,%ecx
f01053d3:	d3 e3                	shl    %cl,%ebx
f01053d5:	89 c1                	mov    %eax,%ecx
f01053d7:	d3 ea                	shr    %cl,%edx
f01053d9:	89 f9                	mov    %edi,%ecx
f01053db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01053df:	d3 e6                	shl    %cl,%esi
f01053e1:	89 eb                	mov    %ebp,%ebx
f01053e3:	89 c1                	mov    %eax,%ecx
f01053e5:	d3 eb                	shr    %cl,%ebx
f01053e7:	09 de                	or     %ebx,%esi
f01053e9:	89 f0                	mov    %esi,%eax
f01053eb:	f7 74 24 08          	divl   0x8(%esp)
f01053ef:	89 d6                	mov    %edx,%esi
f01053f1:	89 c3                	mov    %eax,%ebx
f01053f3:	f7 64 24 0c          	mull   0xc(%esp)
f01053f7:	39 d6                	cmp    %edx,%esi
f01053f9:	72 0c                	jb     f0105407 <__udivdi3+0xb7>
f01053fb:	89 f9                	mov    %edi,%ecx
f01053fd:	d3 e5                	shl    %cl,%ebp
f01053ff:	39 c5                	cmp    %eax,%ebp
f0105401:	73 5d                	jae    f0105460 <__udivdi3+0x110>
f0105403:	39 d6                	cmp    %edx,%esi
f0105405:	75 59                	jne    f0105460 <__udivdi3+0x110>
f0105407:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010540a:	31 ff                	xor    %edi,%edi
f010540c:	89 fa                	mov    %edi,%edx
f010540e:	83 c4 1c             	add    $0x1c,%esp
f0105411:	5b                   	pop    %ebx
f0105412:	5e                   	pop    %esi
f0105413:	5f                   	pop    %edi
f0105414:	5d                   	pop    %ebp
f0105415:	c3                   	ret    
f0105416:	8d 76 00             	lea    0x0(%esi),%esi
f0105419:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0105420:	31 ff                	xor    %edi,%edi
f0105422:	31 c0                	xor    %eax,%eax
f0105424:	89 fa                	mov    %edi,%edx
f0105426:	83 c4 1c             	add    $0x1c,%esp
f0105429:	5b                   	pop    %ebx
f010542a:	5e                   	pop    %esi
f010542b:	5f                   	pop    %edi
f010542c:	5d                   	pop    %ebp
f010542d:	c3                   	ret    
f010542e:	66 90                	xchg   %ax,%ax
f0105430:	31 ff                	xor    %edi,%edi
f0105432:	89 e8                	mov    %ebp,%eax
f0105434:	89 f2                	mov    %esi,%edx
f0105436:	f7 f3                	div    %ebx
f0105438:	89 fa                	mov    %edi,%edx
f010543a:	83 c4 1c             	add    $0x1c,%esp
f010543d:	5b                   	pop    %ebx
f010543e:	5e                   	pop    %esi
f010543f:	5f                   	pop    %edi
f0105440:	5d                   	pop    %ebp
f0105441:	c3                   	ret    
f0105442:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105448:	39 f2                	cmp    %esi,%edx
f010544a:	72 06                	jb     f0105452 <__udivdi3+0x102>
f010544c:	31 c0                	xor    %eax,%eax
f010544e:	39 eb                	cmp    %ebp,%ebx
f0105450:	77 d2                	ja     f0105424 <__udivdi3+0xd4>
f0105452:	b8 01 00 00 00       	mov    $0x1,%eax
f0105457:	eb cb                	jmp    f0105424 <__udivdi3+0xd4>
f0105459:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105460:	89 d8                	mov    %ebx,%eax
f0105462:	31 ff                	xor    %edi,%edi
f0105464:	eb be                	jmp    f0105424 <__udivdi3+0xd4>
f0105466:	66 90                	xchg   %ax,%ax
f0105468:	66 90                	xchg   %ax,%ax
f010546a:	66 90                	xchg   %ax,%ax
f010546c:	66 90                	xchg   %ax,%ax
f010546e:	66 90                	xchg   %ax,%ax

f0105470 <__umoddi3>:
f0105470:	55                   	push   %ebp
f0105471:	57                   	push   %edi
f0105472:	56                   	push   %esi
f0105473:	53                   	push   %ebx
f0105474:	83 ec 1c             	sub    $0x1c,%esp
f0105477:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f010547b:	8b 74 24 30          	mov    0x30(%esp),%esi
f010547f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0105483:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105487:	85 ed                	test   %ebp,%ebp
f0105489:	89 f0                	mov    %esi,%eax
f010548b:	89 da                	mov    %ebx,%edx
f010548d:	75 19                	jne    f01054a8 <__umoddi3+0x38>
f010548f:	39 df                	cmp    %ebx,%edi
f0105491:	0f 86 b1 00 00 00    	jbe    f0105548 <__umoddi3+0xd8>
f0105497:	f7 f7                	div    %edi
f0105499:	89 d0                	mov    %edx,%eax
f010549b:	31 d2                	xor    %edx,%edx
f010549d:	83 c4 1c             	add    $0x1c,%esp
f01054a0:	5b                   	pop    %ebx
f01054a1:	5e                   	pop    %esi
f01054a2:	5f                   	pop    %edi
f01054a3:	5d                   	pop    %ebp
f01054a4:	c3                   	ret    
f01054a5:	8d 76 00             	lea    0x0(%esi),%esi
f01054a8:	39 dd                	cmp    %ebx,%ebp
f01054aa:	77 f1                	ja     f010549d <__umoddi3+0x2d>
f01054ac:	0f bd cd             	bsr    %ebp,%ecx
f01054af:	83 f1 1f             	xor    $0x1f,%ecx
f01054b2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01054b6:	0f 84 b4 00 00 00    	je     f0105570 <__umoddi3+0x100>
f01054bc:	b8 20 00 00 00       	mov    $0x20,%eax
f01054c1:	89 c2                	mov    %eax,%edx
f01054c3:	8b 44 24 04          	mov    0x4(%esp),%eax
f01054c7:	29 c2                	sub    %eax,%edx
f01054c9:	89 c1                	mov    %eax,%ecx
f01054cb:	89 f8                	mov    %edi,%eax
f01054cd:	d3 e5                	shl    %cl,%ebp
f01054cf:	89 d1                	mov    %edx,%ecx
f01054d1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01054d5:	d3 e8                	shr    %cl,%eax
f01054d7:	09 c5                	or     %eax,%ebp
f01054d9:	8b 44 24 04          	mov    0x4(%esp),%eax
f01054dd:	89 c1                	mov    %eax,%ecx
f01054df:	d3 e7                	shl    %cl,%edi
f01054e1:	89 d1                	mov    %edx,%ecx
f01054e3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01054e7:	89 df                	mov    %ebx,%edi
f01054e9:	d3 ef                	shr    %cl,%edi
f01054eb:	89 c1                	mov    %eax,%ecx
f01054ed:	89 f0                	mov    %esi,%eax
f01054ef:	d3 e3                	shl    %cl,%ebx
f01054f1:	89 d1                	mov    %edx,%ecx
f01054f3:	89 fa                	mov    %edi,%edx
f01054f5:	d3 e8                	shr    %cl,%eax
f01054f7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01054fc:	09 d8                	or     %ebx,%eax
f01054fe:	f7 f5                	div    %ebp
f0105500:	d3 e6                	shl    %cl,%esi
f0105502:	89 d1                	mov    %edx,%ecx
f0105504:	f7 64 24 08          	mull   0x8(%esp)
f0105508:	39 d1                	cmp    %edx,%ecx
f010550a:	89 c3                	mov    %eax,%ebx
f010550c:	89 d7                	mov    %edx,%edi
f010550e:	72 06                	jb     f0105516 <__umoddi3+0xa6>
f0105510:	75 0e                	jne    f0105520 <__umoddi3+0xb0>
f0105512:	39 c6                	cmp    %eax,%esi
f0105514:	73 0a                	jae    f0105520 <__umoddi3+0xb0>
f0105516:	2b 44 24 08          	sub    0x8(%esp),%eax
f010551a:	19 ea                	sbb    %ebp,%edx
f010551c:	89 d7                	mov    %edx,%edi
f010551e:	89 c3                	mov    %eax,%ebx
f0105520:	89 ca                	mov    %ecx,%edx
f0105522:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0105527:	29 de                	sub    %ebx,%esi
f0105529:	19 fa                	sbb    %edi,%edx
f010552b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f010552f:	89 d0                	mov    %edx,%eax
f0105531:	d3 e0                	shl    %cl,%eax
f0105533:	89 d9                	mov    %ebx,%ecx
f0105535:	d3 ee                	shr    %cl,%esi
f0105537:	d3 ea                	shr    %cl,%edx
f0105539:	09 f0                	or     %esi,%eax
f010553b:	83 c4 1c             	add    $0x1c,%esp
f010553e:	5b                   	pop    %ebx
f010553f:	5e                   	pop    %esi
f0105540:	5f                   	pop    %edi
f0105541:	5d                   	pop    %ebp
f0105542:	c3                   	ret    
f0105543:	90                   	nop
f0105544:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105548:	85 ff                	test   %edi,%edi
f010554a:	89 f9                	mov    %edi,%ecx
f010554c:	75 0b                	jne    f0105559 <__umoddi3+0xe9>
f010554e:	b8 01 00 00 00       	mov    $0x1,%eax
f0105553:	31 d2                	xor    %edx,%edx
f0105555:	f7 f7                	div    %edi
f0105557:	89 c1                	mov    %eax,%ecx
f0105559:	89 d8                	mov    %ebx,%eax
f010555b:	31 d2                	xor    %edx,%edx
f010555d:	f7 f1                	div    %ecx
f010555f:	89 f0                	mov    %esi,%eax
f0105561:	f7 f1                	div    %ecx
f0105563:	e9 31 ff ff ff       	jmp    f0105499 <__umoddi3+0x29>
f0105568:	90                   	nop
f0105569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105570:	39 dd                	cmp    %ebx,%ebp
f0105572:	72 08                	jb     f010557c <__umoddi3+0x10c>
f0105574:	39 f7                	cmp    %esi,%edi
f0105576:	0f 87 21 ff ff ff    	ja     f010549d <__umoddi3+0x2d>
f010557c:	89 da                	mov    %ebx,%edx
f010557e:	89 f0                	mov    %esi,%eax
f0105580:	29 f8                	sub    %edi,%eax
f0105582:	19 ea                	sbb    %ebp,%edx
f0105584:	e9 14 ff ff ff       	jmp    f010549d <__umoddi3+0x2d>
