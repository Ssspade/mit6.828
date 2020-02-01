
obj/user/testbss：     文件格式 elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 d7 00 00 00       	call   800108 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
  80003a:	e8 c5 00 00 00       	call   800104 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	int i;

	cprintf("Making sure bss works right...\n");
  800045:	8d 83 2c ef ff ff    	lea    -0x10d4(%ebx),%eax
  80004b:	50                   	push   %eax
  80004c:	e8 42 02 00 00       	call   800293 <cprintf>
  800051:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800054:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  800059:	c7 c2 40 20 80 00    	mov    $0x802040,%edx
  80005f:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
  800063:	75 73                	jne    8000d8 <umain+0xa5>
	for (i = 0; i < ARRAYSIZE; i++)
  800065:	83 c0 01             	add    $0x1,%eax
  800068:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006d:	75 f0                	jne    80005f <umain+0x2c>
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80006f:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
  800074:	c7 c2 40 20 80 00    	mov    $0x802040,%edx
  80007a:	89 04 82             	mov    %eax,(%edx,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  80007d:	83 c0 01             	add    $0x1,%eax
  800080:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800085:	75 f3                	jne    80007a <umain+0x47>
	for (i = 0; i < ARRAYSIZE; i++)
  800087:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  80008c:	c7 c2 40 20 80 00    	mov    $0x802040,%edx
  800092:	39 04 82             	cmp    %eax,(%edx,%eax,4)
  800095:	75 57                	jne    8000ee <umain+0xbb>
	for (i = 0; i < ARRAYSIZE; i++)
  800097:	83 c0 01             	add    $0x1,%eax
  80009a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80009f:	75 f1                	jne    800092 <umain+0x5f>
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000a1:	83 ec 0c             	sub    $0xc,%esp
  8000a4:	8d 83 74 ef ff ff    	lea    -0x108c(%ebx),%eax
  8000aa:	50                   	push   %eax
  8000ab:	e8 e3 01 00 00       	call   800293 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000b0:	c7 c0 40 20 80 00    	mov    $0x802040,%eax
  8000b6:	c7 80 00 10 40 00 00 	movl   $0x0,0x401000(%eax)
  8000bd:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c0:	83 c4 0c             	add    $0xc,%esp
  8000c3:	8d 83 d3 ef ff ff    	lea    -0x102d(%ebx),%eax
  8000c9:	50                   	push   %eax
  8000ca:	6a 1a                	push   $0x1a
  8000cc:	8d 83 c4 ef ff ff    	lea    -0x103c(%ebx),%eax
  8000d2:	50                   	push   %eax
  8000d3:	e8 af 00 00 00       	call   800187 <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000d8:	50                   	push   %eax
  8000d9:	8d 83 a7 ef ff ff    	lea    -0x1059(%ebx),%eax
  8000df:	50                   	push   %eax
  8000e0:	6a 11                	push   $0x11
  8000e2:	8d 83 c4 ef ff ff    	lea    -0x103c(%ebx),%eax
  8000e8:	50                   	push   %eax
  8000e9:	e8 99 00 00 00       	call   800187 <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000ee:	50                   	push   %eax
  8000ef:	8d 83 4c ef ff ff    	lea    -0x10b4(%ebx),%eax
  8000f5:	50                   	push   %eax
  8000f6:	6a 16                	push   $0x16
  8000f8:	8d 83 c4 ef ff ff    	lea    -0x103c(%ebx),%eax
  8000fe:	50                   	push   %eax
  8000ff:	e8 83 00 00 00       	call   800187 <_panic>

00800104 <__x86.get_pc_thunk.bx>:
  800104:	8b 1c 24             	mov    (%esp),%ebx
  800107:	c3                   	ret    

00800108 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	57                   	push   %edi
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	e8 ee ff ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  800116:	81 c3 ea 1e 00 00    	add    $0x1eea,%ebx
  80011c:	8b 75 08             	mov    0x8(%ebp),%esi
  80011f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800122:	e8 9a 0b 00 00       	call   800cc1 <sys_getenvid>
  800127:	25 ff 03 00 00       	and    $0x3ff,%eax
  80012c:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80012f:	c1 e0 05             	shl    $0x5,%eax
  800132:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800138:	c7 c2 40 20 c0 00    	mov    $0xc02040,%edx
  80013e:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800140:	85 f6                	test   %esi,%esi
  800142:	7e 08                	jle    80014c <libmain+0x44>
		binaryname = argv[0];
  800144:	8b 07                	mov    (%edi),%eax
  800146:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80014c:	83 ec 08             	sub    $0x8,%esp
  80014f:	57                   	push   %edi
  800150:	56                   	push   %esi
  800151:	e8 dd fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800156:	e8 0b 00 00 00       	call   800166 <exit>
}
  80015b:	83 c4 10             	add    $0x10,%esp
  80015e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	53                   	push   %ebx
  80016a:	83 ec 10             	sub    $0x10,%esp
  80016d:	e8 92 ff ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  800172:	81 c3 8e 1e 00 00    	add    $0x1e8e,%ebx
	sys_env_destroy(0);
  800178:	6a 00                	push   $0x0
  80017a:	e8 ed 0a 00 00       	call   800c6c <sys_env_destroy>
}
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 0c             	sub    $0xc,%esp
  800190:	e8 6f ff ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  800195:	81 c3 6b 1e 00 00    	add    $0x1e6b,%ebx
	va_list ap;

	va_start(ap, fmt);
  80019b:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019e:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  8001a4:	8b 38                	mov    (%eax),%edi
  8001a6:	e8 16 0b 00 00       	call   800cc1 <sys_getenvid>
  8001ab:	83 ec 0c             	sub    $0xc,%esp
  8001ae:	ff 75 0c             	pushl  0xc(%ebp)
  8001b1:	ff 75 08             	pushl  0x8(%ebp)
  8001b4:	57                   	push   %edi
  8001b5:	50                   	push   %eax
  8001b6:	8d 83 f4 ef ff ff    	lea    -0x100c(%ebx),%eax
  8001bc:	50                   	push   %eax
  8001bd:	e8 d1 00 00 00       	call   800293 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c2:	83 c4 18             	add    $0x18,%esp
  8001c5:	56                   	push   %esi
  8001c6:	ff 75 10             	pushl  0x10(%ebp)
  8001c9:	e8 63 00 00 00       	call   800231 <vcprintf>
	cprintf("\n");
  8001ce:	8d 83 c2 ef ff ff    	lea    -0x103e(%ebx),%eax
  8001d4:	89 04 24             	mov    %eax,(%esp)
  8001d7:	e8 b7 00 00 00       	call   800293 <cprintf>
  8001dc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001df:	cc                   	int3   
  8001e0:	eb fd                	jmp    8001df <_panic+0x58>

008001e2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	56                   	push   %esi
  8001e6:	53                   	push   %ebx
  8001e7:	e8 18 ff ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  8001ec:	81 c3 14 1e 00 00    	add    $0x1e14,%ebx
  8001f2:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001f5:	8b 16                	mov    (%esi),%edx
  8001f7:	8d 42 01             	lea    0x1(%edx),%eax
  8001fa:	89 06                	mov    %eax,(%esi)
  8001fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ff:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800203:	3d ff 00 00 00       	cmp    $0xff,%eax
  800208:	74 0b                	je     800215 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80020a:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80020e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800211:	5b                   	pop    %ebx
  800212:	5e                   	pop    %esi
  800213:	5d                   	pop    %ebp
  800214:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800215:	83 ec 08             	sub    $0x8,%esp
  800218:	68 ff 00 00 00       	push   $0xff
  80021d:	8d 46 08             	lea    0x8(%esi),%eax
  800220:	50                   	push   %eax
  800221:	e8 09 0a 00 00       	call   800c2f <sys_cputs>
		b->idx = 0;
  800226:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	eb d9                	jmp    80020a <putch+0x28>

00800231 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	53                   	push   %ebx
  800235:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80023b:	e8 c4 fe ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  800240:	81 c3 c0 1d 00 00    	add    $0x1dc0,%ebx
	struct printbuf b;

	b.idx = 0;
  800246:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024d:	00 00 00 
	b.cnt = 0;
  800250:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800257:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80025a:	ff 75 0c             	pushl  0xc(%ebp)
  80025d:	ff 75 08             	pushl  0x8(%ebp)
  800260:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800266:	50                   	push   %eax
  800267:	8d 83 e2 e1 ff ff    	lea    -0x1e1e(%ebx),%eax
  80026d:	50                   	push   %eax
  80026e:	e8 38 01 00 00       	call   8003ab <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800273:	83 c4 08             	add    $0x8,%esp
  800276:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80027c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800282:	50                   	push   %eax
  800283:	e8 a7 09 00 00       	call   800c2f <sys_cputs>

	return b.cnt;
}
  800288:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800291:	c9                   	leave  
  800292:	c3                   	ret    

00800293 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800299:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80029c:	50                   	push   %eax
  80029d:	ff 75 08             	pushl  0x8(%ebp)
  8002a0:	e8 8c ff ff ff       	call   800231 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a5:	c9                   	leave  
  8002a6:	c3                   	ret    

008002a7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	57                   	push   %edi
  8002ab:	56                   	push   %esi
  8002ac:	53                   	push   %ebx
  8002ad:	83 ec 2c             	sub    $0x2c,%esp
  8002b0:	e8 02 06 00 00       	call   8008b7 <__x86.get_pc_thunk.cx>
  8002b5:	81 c1 4b 1d 00 00    	add    $0x1d4b,%ecx
  8002bb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002be:	89 c7                	mov    %eax,%edi
  8002c0:	89 d6                	mov    %edx,%esi
  8002c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002cb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d6:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002d9:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002dc:	39 d3                	cmp    %edx,%ebx
  8002de:	72 09                	jb     8002e9 <printnum+0x42>
  8002e0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002e3:	0f 87 83 00 00 00    	ja     80036c <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002e9:	83 ec 0c             	sub    $0xc,%esp
  8002ec:	ff 75 18             	pushl  0x18(%ebp)
  8002ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002f5:	53                   	push   %ebx
  8002f6:	ff 75 10             	pushl  0x10(%ebp)
  8002f9:	83 ec 08             	sub    $0x8,%esp
  8002fc:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ff:	ff 75 d8             	pushl  -0x28(%ebp)
  800302:	ff 75 d4             	pushl  -0x2c(%ebp)
  800305:	ff 75 d0             	pushl  -0x30(%ebp)
  800308:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80030b:	e8 e0 09 00 00       	call   800cf0 <__udivdi3>
  800310:	83 c4 18             	add    $0x18,%esp
  800313:	52                   	push   %edx
  800314:	50                   	push   %eax
  800315:	89 f2                	mov    %esi,%edx
  800317:	89 f8                	mov    %edi,%eax
  800319:	e8 89 ff ff ff       	call   8002a7 <printnum>
  80031e:	83 c4 20             	add    $0x20,%esp
  800321:	eb 13                	jmp    800336 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800323:	83 ec 08             	sub    $0x8,%esp
  800326:	56                   	push   %esi
  800327:	ff 75 18             	pushl  0x18(%ebp)
  80032a:	ff d7                	call   *%edi
  80032c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80032f:	83 eb 01             	sub    $0x1,%ebx
  800332:	85 db                	test   %ebx,%ebx
  800334:	7f ed                	jg     800323 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800336:	83 ec 08             	sub    $0x8,%esp
  800339:	56                   	push   %esi
  80033a:	83 ec 04             	sub    $0x4,%esp
  80033d:	ff 75 dc             	pushl  -0x24(%ebp)
  800340:	ff 75 d8             	pushl  -0x28(%ebp)
  800343:	ff 75 d4             	pushl  -0x2c(%ebp)
  800346:	ff 75 d0             	pushl  -0x30(%ebp)
  800349:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80034c:	89 f3                	mov    %esi,%ebx
  80034e:	e8 bd 0a 00 00       	call   800e10 <__umoddi3>
  800353:	83 c4 14             	add    $0x14,%esp
  800356:	0f be 84 06 18 f0 ff 	movsbl -0xfe8(%esi,%eax,1),%eax
  80035d:	ff 
  80035e:	50                   	push   %eax
  80035f:	ff d7                	call   *%edi
}
  800361:	83 c4 10             	add    $0x10,%esp
  800364:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800367:	5b                   	pop    %ebx
  800368:	5e                   	pop    %esi
  800369:	5f                   	pop    %edi
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    
  80036c:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80036f:	eb be                	jmp    80032f <printnum+0x88>

00800371 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800377:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80037b:	8b 10                	mov    (%eax),%edx
  80037d:	3b 50 04             	cmp    0x4(%eax),%edx
  800380:	73 0a                	jae    80038c <sprintputch+0x1b>
		*b->buf++ = ch;
  800382:	8d 4a 01             	lea    0x1(%edx),%ecx
  800385:	89 08                	mov    %ecx,(%eax)
  800387:	8b 45 08             	mov    0x8(%ebp),%eax
  80038a:	88 02                	mov    %al,(%edx)
}
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <printfmt>:
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800394:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800397:	50                   	push   %eax
  800398:	ff 75 10             	pushl  0x10(%ebp)
  80039b:	ff 75 0c             	pushl  0xc(%ebp)
  80039e:	ff 75 08             	pushl  0x8(%ebp)
  8003a1:	e8 05 00 00 00       	call   8003ab <vprintfmt>
}
  8003a6:	83 c4 10             	add    $0x10,%esp
  8003a9:	c9                   	leave  
  8003aa:	c3                   	ret    

008003ab <vprintfmt>:
{
  8003ab:	55                   	push   %ebp
  8003ac:	89 e5                	mov    %esp,%ebp
  8003ae:	57                   	push   %edi
  8003af:	56                   	push   %esi
  8003b0:	53                   	push   %ebx
  8003b1:	83 ec 2c             	sub    $0x2c,%esp
  8003b4:	e8 4b fd ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  8003b9:	81 c3 47 1c 00 00    	add    $0x1c47,%ebx
  8003bf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003c2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003c5:	e9 c3 03 00 00       	jmp    80078d <.L35+0x48>
		padc = ' ';
  8003ca:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003ce:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003d5:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003dc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e8:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8d 47 01             	lea    0x1(%edi),%eax
  8003ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f1:	0f b6 17             	movzbl (%edi),%edx
  8003f4:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003f7:	3c 55                	cmp    $0x55,%al
  8003f9:	0f 87 16 04 00 00    	ja     800815 <.L22>
  8003ff:	0f b6 c0             	movzbl %al,%eax
  800402:	89 d9                	mov    %ebx,%ecx
  800404:	03 8c 83 a8 f0 ff ff 	add    -0xf58(%ebx,%eax,4),%ecx
  80040b:	ff e1                	jmp    *%ecx

0080040d <.L69>:
  80040d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800410:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800414:	eb d5                	jmp    8003eb <vprintfmt+0x40>

00800416 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800419:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80041d:	eb cc                	jmp    8003eb <vprintfmt+0x40>

0080041f <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	0f b6 d2             	movzbl %dl,%edx
  800422:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800425:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  80042a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80042d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800431:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800434:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800437:	83 f9 09             	cmp    $0x9,%ecx
  80043a:	77 55                	ja     800491 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  80043c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80043f:	eb e9                	jmp    80042a <.L29+0xb>

00800441 <.L26>:
			precision = va_arg(ap, int);
  800441:	8b 45 14             	mov    0x14(%ebp),%eax
  800444:	8b 00                	mov    (%eax),%eax
  800446:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
  80044c:	8d 40 04             	lea    0x4(%eax),%eax
  80044f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800452:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800455:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800459:	79 90                	jns    8003eb <vprintfmt+0x40>
				width = precision, precision = -1;
  80045b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80045e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800461:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800468:	eb 81                	jmp    8003eb <vprintfmt+0x40>

0080046a <.L27>:
  80046a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80046d:	85 c0                	test   %eax,%eax
  80046f:	ba 00 00 00 00       	mov    $0x0,%edx
  800474:	0f 49 d0             	cmovns %eax,%edx
  800477:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047d:	e9 69 ff ff ff       	jmp    8003eb <vprintfmt+0x40>

00800482 <.L23>:
  800482:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800485:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80048c:	e9 5a ff ff ff       	jmp    8003eb <vprintfmt+0x40>
  800491:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800494:	eb bf                	jmp    800455 <.L26+0x14>

00800496 <.L33>:
			lflag++;
  800496:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80049d:	e9 49 ff ff ff       	jmp    8003eb <vprintfmt+0x40>

008004a2 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a5:	8d 78 04             	lea    0x4(%eax),%edi
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	56                   	push   %esi
  8004ac:	ff 30                	pushl  (%eax)
  8004ae:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004b1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004b4:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004b7:	e9 ce 02 00 00       	jmp    80078a <.L35+0x45>

008004bc <.L32>:
			err = va_arg(ap, int);
  8004bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bf:	8d 78 04             	lea    0x4(%eax),%edi
  8004c2:	8b 00                	mov    (%eax),%eax
  8004c4:	99                   	cltd   
  8004c5:	31 d0                	xor    %edx,%eax
  8004c7:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c9:	83 f8 06             	cmp    $0x6,%eax
  8004cc:	7f 27                	jg     8004f5 <.L32+0x39>
  8004ce:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8004d5:	85 d2                	test   %edx,%edx
  8004d7:	74 1c                	je     8004f5 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004d9:	52                   	push   %edx
  8004da:	8d 83 39 f0 ff ff    	lea    -0xfc7(%ebx),%eax
  8004e0:	50                   	push   %eax
  8004e1:	56                   	push   %esi
  8004e2:	ff 75 08             	pushl  0x8(%ebp)
  8004e5:	e8 a4 fe ff ff       	call   80038e <printfmt>
  8004ea:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004ed:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004f0:	e9 95 02 00 00       	jmp    80078a <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004f5:	50                   	push   %eax
  8004f6:	8d 83 30 f0 ff ff    	lea    -0xfd0(%ebx),%eax
  8004fc:	50                   	push   %eax
  8004fd:	56                   	push   %esi
  8004fe:	ff 75 08             	pushl  0x8(%ebp)
  800501:	e8 88 fe ff ff       	call   80038e <printfmt>
  800506:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800509:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80050c:	e9 79 02 00 00       	jmp    80078a <.L35+0x45>

00800511 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	83 c0 04             	add    $0x4,%eax
  800517:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80051f:	85 ff                	test   %edi,%edi
  800521:	8d 83 29 f0 ff ff    	lea    -0xfd7(%ebx),%eax
  800527:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80052a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052e:	0f 8e b5 00 00 00    	jle    8005e9 <.L36+0xd8>
  800534:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800538:	75 08                	jne    800542 <.L36+0x31>
  80053a:	89 75 0c             	mov    %esi,0xc(%ebp)
  80053d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800540:	eb 6d                	jmp    8005af <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	ff 75 cc             	pushl  -0x34(%ebp)
  800548:	57                   	push   %edi
  800549:	e8 85 03 00 00       	call   8008d3 <strnlen>
  80054e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800551:	29 c2                	sub    %eax,%edx
  800553:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800556:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800559:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80055d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800560:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800563:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800565:	eb 10                	jmp    800577 <.L36+0x66>
					putch(padc, putdat);
  800567:	83 ec 08             	sub    $0x8,%esp
  80056a:	56                   	push   %esi
  80056b:	ff 75 e0             	pushl  -0x20(%ebp)
  80056e:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800571:	83 ef 01             	sub    $0x1,%edi
  800574:	83 c4 10             	add    $0x10,%esp
  800577:	85 ff                	test   %edi,%edi
  800579:	7f ec                	jg     800567 <.L36+0x56>
  80057b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80057e:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800581:	85 d2                	test   %edx,%edx
  800583:	b8 00 00 00 00       	mov    $0x0,%eax
  800588:	0f 49 c2             	cmovns %edx,%eax
  80058b:	29 c2                	sub    %eax,%edx
  80058d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800590:	89 75 0c             	mov    %esi,0xc(%ebp)
  800593:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800596:	eb 17                	jmp    8005af <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  800598:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80059c:	75 30                	jne    8005ce <.L36+0xbd>
					putch(ch, putdat);
  80059e:	83 ec 08             	sub    $0x8,%esp
  8005a1:	ff 75 0c             	pushl  0xc(%ebp)
  8005a4:	50                   	push   %eax
  8005a5:	ff 55 08             	call   *0x8(%ebp)
  8005a8:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ab:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005af:	83 c7 01             	add    $0x1,%edi
  8005b2:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005b6:	0f be c2             	movsbl %dl,%eax
  8005b9:	85 c0                	test   %eax,%eax
  8005bb:	74 52                	je     80060f <.L36+0xfe>
  8005bd:	85 f6                	test   %esi,%esi
  8005bf:	78 d7                	js     800598 <.L36+0x87>
  8005c1:	83 ee 01             	sub    $0x1,%esi
  8005c4:	79 d2                	jns    800598 <.L36+0x87>
  8005c6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005c9:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005cc:	eb 32                	jmp    800600 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005ce:	0f be d2             	movsbl %dl,%edx
  8005d1:	83 ea 20             	sub    $0x20,%edx
  8005d4:	83 fa 5e             	cmp    $0x5e,%edx
  8005d7:	76 c5                	jbe    80059e <.L36+0x8d>
					putch('?', putdat);
  8005d9:	83 ec 08             	sub    $0x8,%esp
  8005dc:	ff 75 0c             	pushl  0xc(%ebp)
  8005df:	6a 3f                	push   $0x3f
  8005e1:	ff 55 08             	call   *0x8(%ebp)
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	eb c2                	jmp    8005ab <.L36+0x9a>
  8005e9:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005ec:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005ef:	eb be                	jmp    8005af <.L36+0x9e>
				putch(' ', putdat);
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	56                   	push   %esi
  8005f5:	6a 20                	push   $0x20
  8005f7:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  8005fa:	83 ef 01             	sub    $0x1,%edi
  8005fd:	83 c4 10             	add    $0x10,%esp
  800600:	85 ff                	test   %edi,%edi
  800602:	7f ed                	jg     8005f1 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  800604:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800607:	89 45 14             	mov    %eax,0x14(%ebp)
  80060a:	e9 7b 01 00 00       	jmp    80078a <.L35+0x45>
  80060f:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800612:	8b 75 0c             	mov    0xc(%ebp),%esi
  800615:	eb e9                	jmp    800600 <.L36+0xef>

00800617 <.L31>:
  800617:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80061a:	83 f9 01             	cmp    $0x1,%ecx
  80061d:	7e 40                	jle    80065f <.L31+0x48>
		return va_arg(*ap, long long);
  80061f:	8b 45 14             	mov    0x14(%ebp),%eax
  800622:	8b 50 04             	mov    0x4(%eax),%edx
  800625:	8b 00                	mov    (%eax),%eax
  800627:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8d 40 08             	lea    0x8(%eax),%eax
  800633:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800636:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80063a:	79 55                	jns    800691 <.L31+0x7a>
				putch('-', putdat);
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	56                   	push   %esi
  800640:	6a 2d                	push   $0x2d
  800642:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800645:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800648:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80064b:	f7 da                	neg    %edx
  80064d:	83 d1 00             	adc    $0x0,%ecx
  800650:	f7 d9                	neg    %ecx
  800652:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800655:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065a:	e9 10 01 00 00       	jmp    80076f <.L35+0x2a>
	else if (lflag)
  80065f:	85 c9                	test   %ecx,%ecx
  800661:	75 17                	jne    80067a <.L31+0x63>
		return va_arg(*ap, int);
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8b 00                	mov    (%eax),%eax
  800668:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066b:	99                   	cltd   
  80066c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8d 40 04             	lea    0x4(%eax),%eax
  800675:	89 45 14             	mov    %eax,0x14(%ebp)
  800678:	eb bc                	jmp    800636 <.L31+0x1f>
		return va_arg(*ap, long);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8b 00                	mov    (%eax),%eax
  80067f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800682:	99                   	cltd   
  800683:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8d 40 04             	lea    0x4(%eax),%eax
  80068c:	89 45 14             	mov    %eax,0x14(%ebp)
  80068f:	eb a5                	jmp    800636 <.L31+0x1f>
			num = getint(&ap, lflag);
  800691:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800694:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800697:	b8 0a 00 00 00       	mov    $0xa,%eax
  80069c:	e9 ce 00 00 00       	jmp    80076f <.L35+0x2a>

008006a1 <.L37>:
  8006a1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006a4:	83 f9 01             	cmp    $0x1,%ecx
  8006a7:	7e 18                	jle    8006c1 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8006a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ac:	8b 10                	mov    (%eax),%edx
  8006ae:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b1:	8d 40 08             	lea    0x8(%eax),%eax
  8006b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006bc:	e9 ae 00 00 00       	jmp    80076f <.L35+0x2a>
	else if (lflag)
  8006c1:	85 c9                	test   %ecx,%ecx
  8006c3:	75 1a                	jne    8006df <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8b 10                	mov    (%eax),%edx
  8006ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006cf:	8d 40 04             	lea    0x4(%eax),%eax
  8006d2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006da:	e9 90 00 00 00       	jmp    80076f <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	8b 10                	mov    (%eax),%edx
  8006e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e9:	8d 40 04             	lea    0x4(%eax),%eax
  8006ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006ef:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006f4:	eb 79                	jmp    80076f <.L35+0x2a>

008006f6 <.L34>:
  8006f6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006f9:	83 f9 01             	cmp    $0x1,%ecx
  8006fc:	7e 15                	jle    800713 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  8006fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800701:	8b 10                	mov    (%eax),%edx
  800703:	8b 48 04             	mov    0x4(%eax),%ecx
  800706:	8d 40 08             	lea    0x8(%eax),%eax
  800709:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80070c:	b8 08 00 00 00       	mov    $0x8,%eax
  800711:	eb 5c                	jmp    80076f <.L35+0x2a>
	else if (lflag)
  800713:	85 c9                	test   %ecx,%ecx
  800715:	75 17                	jne    80072e <.L34+0x38>
		return va_arg(*ap, unsigned int);
  800717:	8b 45 14             	mov    0x14(%ebp),%eax
  80071a:	8b 10                	mov    (%eax),%edx
  80071c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800721:	8d 40 04             	lea    0x4(%eax),%eax
  800724:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800727:	b8 08 00 00 00       	mov    $0x8,%eax
  80072c:	eb 41                	jmp    80076f <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  80072e:	8b 45 14             	mov    0x14(%ebp),%eax
  800731:	8b 10                	mov    (%eax),%edx
  800733:	b9 00 00 00 00       	mov    $0x0,%ecx
  800738:	8d 40 04             	lea    0x4(%eax),%eax
  80073b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80073e:	b8 08 00 00 00       	mov    $0x8,%eax
  800743:	eb 2a                	jmp    80076f <.L35+0x2a>

00800745 <.L35>:
			putch('0', putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	56                   	push   %esi
  800749:	6a 30                	push   $0x30
  80074b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80074e:	83 c4 08             	add    $0x8,%esp
  800751:	56                   	push   %esi
  800752:	6a 78                	push   $0x78
  800754:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	8b 10                	mov    (%eax),%edx
  80075c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800761:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800764:	8d 40 04             	lea    0x4(%eax),%eax
  800767:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80076a:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80076f:	83 ec 0c             	sub    $0xc,%esp
  800772:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800776:	57                   	push   %edi
  800777:	ff 75 e0             	pushl  -0x20(%ebp)
  80077a:	50                   	push   %eax
  80077b:	51                   	push   %ecx
  80077c:	52                   	push   %edx
  80077d:	89 f2                	mov    %esi,%edx
  80077f:	8b 45 08             	mov    0x8(%ebp),%eax
  800782:	e8 20 fb ff ff       	call   8002a7 <printnum>
			break;
  800787:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80078a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80078d:	83 c7 01             	add    $0x1,%edi
  800790:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800794:	83 f8 25             	cmp    $0x25,%eax
  800797:	0f 84 2d fc ff ff    	je     8003ca <vprintfmt+0x1f>
			if (ch == '\0')
  80079d:	85 c0                	test   %eax,%eax
  80079f:	0f 84 91 00 00 00    	je     800836 <.L22+0x21>
			putch(ch, putdat);
  8007a5:	83 ec 08             	sub    $0x8,%esp
  8007a8:	56                   	push   %esi
  8007a9:	50                   	push   %eax
  8007aa:	ff 55 08             	call   *0x8(%ebp)
  8007ad:	83 c4 10             	add    $0x10,%esp
  8007b0:	eb db                	jmp    80078d <.L35+0x48>

008007b2 <.L38>:
  8007b2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8007b5:	83 f9 01             	cmp    $0x1,%ecx
  8007b8:	7e 15                	jle    8007cf <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8007ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bd:	8b 10                	mov    (%eax),%edx
  8007bf:	8b 48 04             	mov    0x4(%eax),%ecx
  8007c2:	8d 40 08             	lea    0x8(%eax),%eax
  8007c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c8:	b8 10 00 00 00       	mov    $0x10,%eax
  8007cd:	eb a0                	jmp    80076f <.L35+0x2a>
	else if (lflag)
  8007cf:	85 c9                	test   %ecx,%ecx
  8007d1:	75 17                	jne    8007ea <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8007d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d6:	8b 10                	mov    (%eax),%edx
  8007d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007dd:	8d 40 04             	lea    0x4(%eax),%eax
  8007e0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007e3:	b8 10 00 00 00       	mov    $0x10,%eax
  8007e8:	eb 85                	jmp    80076f <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ed:	8b 10                	mov    (%eax),%edx
  8007ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f4:	8d 40 04             	lea    0x4(%eax),%eax
  8007f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007fa:	b8 10 00 00 00       	mov    $0x10,%eax
  8007ff:	e9 6b ff ff ff       	jmp    80076f <.L35+0x2a>

00800804 <.L25>:
			putch(ch, putdat);
  800804:	83 ec 08             	sub    $0x8,%esp
  800807:	56                   	push   %esi
  800808:	6a 25                	push   $0x25
  80080a:	ff 55 08             	call   *0x8(%ebp)
			break;
  80080d:	83 c4 10             	add    $0x10,%esp
  800810:	e9 75 ff ff ff       	jmp    80078a <.L35+0x45>

00800815 <.L22>:
			putch('%', putdat);
  800815:	83 ec 08             	sub    $0x8,%esp
  800818:	56                   	push   %esi
  800819:	6a 25                	push   $0x25
  80081b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80081e:	83 c4 10             	add    $0x10,%esp
  800821:	89 f8                	mov    %edi,%eax
  800823:	eb 03                	jmp    800828 <.L22+0x13>
  800825:	83 e8 01             	sub    $0x1,%eax
  800828:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80082c:	75 f7                	jne    800825 <.L22+0x10>
  80082e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800831:	e9 54 ff ff ff       	jmp    80078a <.L35+0x45>
}
  800836:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800839:	5b                   	pop    %ebx
  80083a:	5e                   	pop    %esi
  80083b:	5f                   	pop    %edi
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	53                   	push   %ebx
  800842:	83 ec 14             	sub    $0x14,%esp
  800845:	e8 ba f8 ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  80084a:	81 c3 b6 17 00 00    	add    $0x17b6,%ebx
  800850:	8b 45 08             	mov    0x8(%ebp),%eax
  800853:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800856:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800859:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80085d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800860:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800867:	85 c0                	test   %eax,%eax
  800869:	74 2b                	je     800896 <vsnprintf+0x58>
  80086b:	85 d2                	test   %edx,%edx
  80086d:	7e 27                	jle    800896 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80086f:	ff 75 14             	pushl  0x14(%ebp)
  800872:	ff 75 10             	pushl  0x10(%ebp)
  800875:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800878:	50                   	push   %eax
  800879:	8d 83 71 e3 ff ff    	lea    -0x1c8f(%ebx),%eax
  80087f:	50                   	push   %eax
  800880:	e8 26 fb ff ff       	call   8003ab <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800885:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800888:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80088b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80088e:	83 c4 10             	add    $0x10,%esp
}
  800891:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800894:	c9                   	leave  
  800895:	c3                   	ret    
		return -E_INVAL;
  800896:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80089b:	eb f4                	jmp    800891 <vsnprintf+0x53>

0080089d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008a3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008a6:	50                   	push   %eax
  8008a7:	ff 75 10             	pushl  0x10(%ebp)
  8008aa:	ff 75 0c             	pushl  0xc(%ebp)
  8008ad:	ff 75 08             	pushl  0x8(%ebp)
  8008b0:	e8 89 ff ff ff       	call   80083e <vsnprintf>
	va_end(ap);

	return rc;
}
  8008b5:	c9                   	leave  
  8008b6:	c3                   	ret    

008008b7 <__x86.get_pc_thunk.cx>:
  8008b7:	8b 0c 24             	mov    (%esp),%ecx
  8008ba:	c3                   	ret    

008008bb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c6:	eb 03                	jmp    8008cb <strlen+0x10>
		n++;
  8008c8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008cb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008cf:	75 f7                	jne    8008c8 <strlen+0xd>
	return n;
}
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    

008008d3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d9:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e1:	eb 03                	jmp    8008e6 <strnlen+0x13>
		n++;
  8008e3:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e6:	39 d0                	cmp    %edx,%eax
  8008e8:	74 06                	je     8008f0 <strnlen+0x1d>
  8008ea:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008ee:	75 f3                	jne    8008e3 <strnlen+0x10>
	return n;
}
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	53                   	push   %ebx
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008fc:	89 c2                	mov    %eax,%edx
  8008fe:	83 c1 01             	add    $0x1,%ecx
  800901:	83 c2 01             	add    $0x1,%edx
  800904:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800908:	88 5a ff             	mov    %bl,-0x1(%edx)
  80090b:	84 db                	test   %bl,%bl
  80090d:	75 ef                	jne    8008fe <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80090f:	5b                   	pop    %ebx
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	53                   	push   %ebx
  800916:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800919:	53                   	push   %ebx
  80091a:	e8 9c ff ff ff       	call   8008bb <strlen>
  80091f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800922:	ff 75 0c             	pushl  0xc(%ebp)
  800925:	01 d8                	add    %ebx,%eax
  800927:	50                   	push   %eax
  800928:	e8 c5 ff ff ff       	call   8008f2 <strcpy>
	return dst;
}
  80092d:	89 d8                	mov    %ebx,%eax
  80092f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800932:	c9                   	leave  
  800933:	c3                   	ret    

00800934 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	56                   	push   %esi
  800938:	53                   	push   %ebx
  800939:	8b 75 08             	mov    0x8(%ebp),%esi
  80093c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093f:	89 f3                	mov    %esi,%ebx
  800941:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800944:	89 f2                	mov    %esi,%edx
  800946:	eb 0f                	jmp    800957 <strncpy+0x23>
		*dst++ = *src;
  800948:	83 c2 01             	add    $0x1,%edx
  80094b:	0f b6 01             	movzbl (%ecx),%eax
  80094e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800951:	80 39 01             	cmpb   $0x1,(%ecx)
  800954:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800957:	39 da                	cmp    %ebx,%edx
  800959:	75 ed                	jne    800948 <strncpy+0x14>
	}
	return ret;
}
  80095b:	89 f0                	mov    %esi,%eax
  80095d:	5b                   	pop    %ebx
  80095e:	5e                   	pop    %esi
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	56                   	push   %esi
  800965:	53                   	push   %ebx
  800966:	8b 75 08             	mov    0x8(%ebp),%esi
  800969:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80096f:	89 f0                	mov    %esi,%eax
  800971:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800975:	85 c9                	test   %ecx,%ecx
  800977:	75 0b                	jne    800984 <strlcpy+0x23>
  800979:	eb 17                	jmp    800992 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80097b:	83 c2 01             	add    $0x1,%edx
  80097e:	83 c0 01             	add    $0x1,%eax
  800981:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800984:	39 d8                	cmp    %ebx,%eax
  800986:	74 07                	je     80098f <strlcpy+0x2e>
  800988:	0f b6 0a             	movzbl (%edx),%ecx
  80098b:	84 c9                	test   %cl,%cl
  80098d:	75 ec                	jne    80097b <strlcpy+0x1a>
		*dst = '\0';
  80098f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800992:	29 f0                	sub    %esi,%eax
}
  800994:	5b                   	pop    %ebx
  800995:	5e                   	pop    %esi
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a1:	eb 06                	jmp    8009a9 <strcmp+0x11>
		p++, q++;
  8009a3:	83 c1 01             	add    $0x1,%ecx
  8009a6:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009a9:	0f b6 01             	movzbl (%ecx),%eax
  8009ac:	84 c0                	test   %al,%al
  8009ae:	74 04                	je     8009b4 <strcmp+0x1c>
  8009b0:	3a 02                	cmp    (%edx),%al
  8009b2:	74 ef                	je     8009a3 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b4:	0f b6 c0             	movzbl %al,%eax
  8009b7:	0f b6 12             	movzbl (%edx),%edx
  8009ba:	29 d0                	sub    %edx,%eax
}
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	53                   	push   %ebx
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c8:	89 c3                	mov    %eax,%ebx
  8009ca:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009cd:	eb 06                	jmp    8009d5 <strncmp+0x17>
		n--, p++, q++;
  8009cf:	83 c0 01             	add    $0x1,%eax
  8009d2:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009d5:	39 d8                	cmp    %ebx,%eax
  8009d7:	74 16                	je     8009ef <strncmp+0x31>
  8009d9:	0f b6 08             	movzbl (%eax),%ecx
  8009dc:	84 c9                	test   %cl,%cl
  8009de:	74 04                	je     8009e4 <strncmp+0x26>
  8009e0:	3a 0a                	cmp    (%edx),%cl
  8009e2:	74 eb                	je     8009cf <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e4:	0f b6 00             	movzbl (%eax),%eax
  8009e7:	0f b6 12             	movzbl (%edx),%edx
  8009ea:	29 d0                	sub    %edx,%eax
}
  8009ec:	5b                   	pop    %ebx
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    
		return 0;
  8009ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f4:	eb f6                	jmp    8009ec <strncmp+0x2e>

008009f6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a00:	0f b6 10             	movzbl (%eax),%edx
  800a03:	84 d2                	test   %dl,%dl
  800a05:	74 09                	je     800a10 <strchr+0x1a>
		if (*s == c)
  800a07:	38 ca                	cmp    %cl,%dl
  800a09:	74 0a                	je     800a15 <strchr+0x1f>
	for (; *s; s++)
  800a0b:	83 c0 01             	add    $0x1,%eax
  800a0e:	eb f0                	jmp    800a00 <strchr+0xa>
			return (char *) s;
	return 0;
  800a10:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a21:	eb 03                	jmp    800a26 <strfind+0xf>
  800a23:	83 c0 01             	add    $0x1,%eax
  800a26:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a29:	38 ca                	cmp    %cl,%dl
  800a2b:	74 04                	je     800a31 <strfind+0x1a>
  800a2d:	84 d2                	test   %dl,%dl
  800a2f:	75 f2                	jne    800a23 <strfind+0xc>
			break;
	return (char *) s;
}
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	57                   	push   %edi
  800a37:	56                   	push   %esi
  800a38:	53                   	push   %ebx
  800a39:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a3c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a3f:	85 c9                	test   %ecx,%ecx
  800a41:	74 13                	je     800a56 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a43:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a49:	75 05                	jne    800a50 <memset+0x1d>
  800a4b:	f6 c1 03             	test   $0x3,%cl
  800a4e:	74 0d                	je     800a5d <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a50:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a53:	fc                   	cld    
  800a54:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a56:	89 f8                	mov    %edi,%eax
  800a58:	5b                   	pop    %ebx
  800a59:	5e                   	pop    %esi
  800a5a:	5f                   	pop    %edi
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    
		c &= 0xFF;
  800a5d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a61:	89 d3                	mov    %edx,%ebx
  800a63:	c1 e3 08             	shl    $0x8,%ebx
  800a66:	89 d0                	mov    %edx,%eax
  800a68:	c1 e0 18             	shl    $0x18,%eax
  800a6b:	89 d6                	mov    %edx,%esi
  800a6d:	c1 e6 10             	shl    $0x10,%esi
  800a70:	09 f0                	or     %esi,%eax
  800a72:	09 c2                	or     %eax,%edx
  800a74:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a76:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a79:	89 d0                	mov    %edx,%eax
  800a7b:	fc                   	cld    
  800a7c:	f3 ab                	rep stos %eax,%es:(%edi)
  800a7e:	eb d6                	jmp    800a56 <memset+0x23>

00800a80 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	57                   	push   %edi
  800a84:	56                   	push   %esi
  800a85:	8b 45 08             	mov    0x8(%ebp),%eax
  800a88:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a8e:	39 c6                	cmp    %eax,%esi
  800a90:	73 35                	jae    800ac7 <memmove+0x47>
  800a92:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a95:	39 c2                	cmp    %eax,%edx
  800a97:	76 2e                	jbe    800ac7 <memmove+0x47>
		s += n;
		d += n;
  800a99:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9c:	89 d6                	mov    %edx,%esi
  800a9e:	09 fe                	or     %edi,%esi
  800aa0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aa6:	74 0c                	je     800ab4 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aa8:	83 ef 01             	sub    $0x1,%edi
  800aab:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aae:	fd                   	std    
  800aaf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ab1:	fc                   	cld    
  800ab2:	eb 21                	jmp    800ad5 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab4:	f6 c1 03             	test   $0x3,%cl
  800ab7:	75 ef                	jne    800aa8 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ab9:	83 ef 04             	sub    $0x4,%edi
  800abc:	8d 72 fc             	lea    -0x4(%edx),%esi
  800abf:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ac2:	fd                   	std    
  800ac3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac5:	eb ea                	jmp    800ab1 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac7:	89 f2                	mov    %esi,%edx
  800ac9:	09 c2                	or     %eax,%edx
  800acb:	f6 c2 03             	test   $0x3,%dl
  800ace:	74 09                	je     800ad9 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ad0:	89 c7                	mov    %eax,%edi
  800ad2:	fc                   	cld    
  800ad3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad5:	5e                   	pop    %esi
  800ad6:	5f                   	pop    %edi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad9:	f6 c1 03             	test   $0x3,%cl
  800adc:	75 f2                	jne    800ad0 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ade:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ae1:	89 c7                	mov    %eax,%edi
  800ae3:	fc                   	cld    
  800ae4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae6:	eb ed                	jmp    800ad5 <memmove+0x55>

00800ae8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800aeb:	ff 75 10             	pushl  0x10(%ebp)
  800aee:	ff 75 0c             	pushl  0xc(%ebp)
  800af1:	ff 75 08             	pushl  0x8(%ebp)
  800af4:	e8 87 ff ff ff       	call   800a80 <memmove>
}
  800af9:	c9                   	leave  
  800afa:	c3                   	ret    

00800afb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b06:	89 c6                	mov    %eax,%esi
  800b08:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b0b:	39 f0                	cmp    %esi,%eax
  800b0d:	74 1c                	je     800b2b <memcmp+0x30>
		if (*s1 != *s2)
  800b0f:	0f b6 08             	movzbl (%eax),%ecx
  800b12:	0f b6 1a             	movzbl (%edx),%ebx
  800b15:	38 d9                	cmp    %bl,%cl
  800b17:	75 08                	jne    800b21 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b19:	83 c0 01             	add    $0x1,%eax
  800b1c:	83 c2 01             	add    $0x1,%edx
  800b1f:	eb ea                	jmp    800b0b <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b21:	0f b6 c1             	movzbl %cl,%eax
  800b24:	0f b6 db             	movzbl %bl,%ebx
  800b27:	29 d8                	sub    %ebx,%eax
  800b29:	eb 05                	jmp    800b30 <memcmp+0x35>
	}

	return 0;
  800b2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b3d:	89 c2                	mov    %eax,%edx
  800b3f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b42:	39 d0                	cmp    %edx,%eax
  800b44:	73 09                	jae    800b4f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b46:	38 08                	cmp    %cl,(%eax)
  800b48:	74 05                	je     800b4f <memfind+0x1b>
	for (; s < ends; s++)
  800b4a:	83 c0 01             	add    $0x1,%eax
  800b4d:	eb f3                	jmp    800b42 <memfind+0xe>
			break;
	return (void *) s;
}
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	57                   	push   %edi
  800b55:	56                   	push   %esi
  800b56:	53                   	push   %ebx
  800b57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b5d:	eb 03                	jmp    800b62 <strtol+0x11>
		s++;
  800b5f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b62:	0f b6 01             	movzbl (%ecx),%eax
  800b65:	3c 20                	cmp    $0x20,%al
  800b67:	74 f6                	je     800b5f <strtol+0xe>
  800b69:	3c 09                	cmp    $0x9,%al
  800b6b:	74 f2                	je     800b5f <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b6d:	3c 2b                	cmp    $0x2b,%al
  800b6f:	74 2e                	je     800b9f <strtol+0x4e>
	int neg = 0;
  800b71:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b76:	3c 2d                	cmp    $0x2d,%al
  800b78:	74 2f                	je     800ba9 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b7a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b80:	75 05                	jne    800b87 <strtol+0x36>
  800b82:	80 39 30             	cmpb   $0x30,(%ecx)
  800b85:	74 2c                	je     800bb3 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b87:	85 db                	test   %ebx,%ebx
  800b89:	75 0a                	jne    800b95 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b8b:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b90:	80 39 30             	cmpb   $0x30,(%ecx)
  800b93:	74 28                	je     800bbd <strtol+0x6c>
		base = 10;
  800b95:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b9d:	eb 50                	jmp    800bef <strtol+0x9e>
		s++;
  800b9f:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ba2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba7:	eb d1                	jmp    800b7a <strtol+0x29>
		s++, neg = 1;
  800ba9:	83 c1 01             	add    $0x1,%ecx
  800bac:	bf 01 00 00 00       	mov    $0x1,%edi
  800bb1:	eb c7                	jmp    800b7a <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bb7:	74 0e                	je     800bc7 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bb9:	85 db                	test   %ebx,%ebx
  800bbb:	75 d8                	jne    800b95 <strtol+0x44>
		s++, base = 8;
  800bbd:	83 c1 01             	add    $0x1,%ecx
  800bc0:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bc5:	eb ce                	jmp    800b95 <strtol+0x44>
		s += 2, base = 16;
  800bc7:	83 c1 02             	add    $0x2,%ecx
  800bca:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bcf:	eb c4                	jmp    800b95 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bd1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bd4:	89 f3                	mov    %esi,%ebx
  800bd6:	80 fb 19             	cmp    $0x19,%bl
  800bd9:	77 29                	ja     800c04 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bdb:	0f be d2             	movsbl %dl,%edx
  800bde:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800be1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800be4:	7d 30                	jge    800c16 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800be6:	83 c1 01             	add    $0x1,%ecx
  800be9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bed:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bef:	0f b6 11             	movzbl (%ecx),%edx
  800bf2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bf5:	89 f3                	mov    %esi,%ebx
  800bf7:	80 fb 09             	cmp    $0x9,%bl
  800bfa:	77 d5                	ja     800bd1 <strtol+0x80>
			dig = *s - '0';
  800bfc:	0f be d2             	movsbl %dl,%edx
  800bff:	83 ea 30             	sub    $0x30,%edx
  800c02:	eb dd                	jmp    800be1 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c04:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c07:	89 f3                	mov    %esi,%ebx
  800c09:	80 fb 19             	cmp    $0x19,%bl
  800c0c:	77 08                	ja     800c16 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c0e:	0f be d2             	movsbl %dl,%edx
  800c11:	83 ea 37             	sub    $0x37,%edx
  800c14:	eb cb                	jmp    800be1 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c16:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c1a:	74 05                	je     800c21 <strtol+0xd0>
		*endptr = (char *) s;
  800c1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c1f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c21:	89 c2                	mov    %eax,%edx
  800c23:	f7 da                	neg    %edx
  800c25:	85 ff                	test   %edi,%edi
  800c27:	0f 45 c2             	cmovne %edx,%eax
}
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5f                   	pop    %edi
  800c2d:	5d                   	pop    %ebp
  800c2e:	c3                   	ret    

00800c2f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	57                   	push   %edi
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c35:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c40:	89 c3                	mov    %eax,%ebx
  800c42:	89 c7                	mov    %eax,%edi
  800c44:	89 c6                	mov    %eax,%esi
  800c46:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <sys_cgetc>:

int
sys_cgetc(void)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	57                   	push   %edi
  800c51:	56                   	push   %esi
  800c52:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c53:	ba 00 00 00 00       	mov    $0x0,%edx
  800c58:	b8 01 00 00 00       	mov    $0x1,%eax
  800c5d:	89 d1                	mov    %edx,%ecx
  800c5f:	89 d3                	mov    %edx,%ebx
  800c61:	89 d7                	mov    %edx,%edi
  800c63:	89 d6                	mov    %edx,%esi
  800c65:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c67:	5b                   	pop    %ebx
  800c68:	5e                   	pop    %esi
  800c69:	5f                   	pop    %edi
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    

00800c6c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	53                   	push   %ebx
  800c72:	83 ec 1c             	sub    $0x1c,%esp
  800c75:	e8 66 00 00 00       	call   800ce0 <__x86.get_pc_thunk.ax>
  800c7a:	05 86 13 00 00       	add    $0x1386,%eax
  800c7f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800c82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c87:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8a:	b8 03 00 00 00       	mov    $0x3,%eax
  800c8f:	89 cb                	mov    %ecx,%ebx
  800c91:	89 cf                	mov    %ecx,%edi
  800c93:	89 ce                	mov    %ecx,%esi
  800c95:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c97:	85 c0                	test   %eax,%eax
  800c99:	7f 08                	jg     800ca3 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	50                   	push   %eax
  800ca7:	6a 03                	push   $0x3
  800ca9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800cac:	8d 83 00 f2 ff ff    	lea    -0xe00(%ebx),%eax
  800cb2:	50                   	push   %eax
  800cb3:	6a 23                	push   $0x23
  800cb5:	8d 83 1d f2 ff ff    	lea    -0xde3(%ebx),%eax
  800cbb:	50                   	push   %eax
  800cbc:	e8 c6 f4 ff ff       	call   800187 <_panic>

00800cc1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cc7:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccc:	b8 02 00 00 00       	mov    $0x2,%eax
  800cd1:	89 d1                	mov    %edx,%ecx
  800cd3:	89 d3                	mov    %edx,%ebx
  800cd5:	89 d7                	mov    %edx,%edi
  800cd7:	89 d6                	mov    %edx,%esi
  800cd9:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <__x86.get_pc_thunk.ax>:
  800ce0:	8b 04 24             	mov    (%esp),%eax
  800ce3:	c3                   	ret    
  800ce4:	66 90                	xchg   %ax,%ax
  800ce6:	66 90                	xchg   %ax,%ax
  800ce8:	66 90                	xchg   %ax,%ax
  800cea:	66 90                	xchg   %ax,%ax
  800cec:	66 90                	xchg   %ax,%ax
  800cee:	66 90                	xchg   %ax,%ax

00800cf0 <__udivdi3>:
  800cf0:	55                   	push   %ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	83 ec 1c             	sub    $0x1c,%esp
  800cf7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800cfb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800cff:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d03:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d07:	85 d2                	test   %edx,%edx
  800d09:	75 35                	jne    800d40 <__udivdi3+0x50>
  800d0b:	39 f3                	cmp    %esi,%ebx
  800d0d:	0f 87 bd 00 00 00    	ja     800dd0 <__udivdi3+0xe0>
  800d13:	85 db                	test   %ebx,%ebx
  800d15:	89 d9                	mov    %ebx,%ecx
  800d17:	75 0b                	jne    800d24 <__udivdi3+0x34>
  800d19:	b8 01 00 00 00       	mov    $0x1,%eax
  800d1e:	31 d2                	xor    %edx,%edx
  800d20:	f7 f3                	div    %ebx
  800d22:	89 c1                	mov    %eax,%ecx
  800d24:	31 d2                	xor    %edx,%edx
  800d26:	89 f0                	mov    %esi,%eax
  800d28:	f7 f1                	div    %ecx
  800d2a:	89 c6                	mov    %eax,%esi
  800d2c:	89 e8                	mov    %ebp,%eax
  800d2e:	89 f7                	mov    %esi,%edi
  800d30:	f7 f1                	div    %ecx
  800d32:	89 fa                	mov    %edi,%edx
  800d34:	83 c4 1c             	add    $0x1c,%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    
  800d3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d40:	39 f2                	cmp    %esi,%edx
  800d42:	77 7c                	ja     800dc0 <__udivdi3+0xd0>
  800d44:	0f bd fa             	bsr    %edx,%edi
  800d47:	83 f7 1f             	xor    $0x1f,%edi
  800d4a:	0f 84 98 00 00 00    	je     800de8 <__udivdi3+0xf8>
  800d50:	89 f9                	mov    %edi,%ecx
  800d52:	b8 20 00 00 00       	mov    $0x20,%eax
  800d57:	29 f8                	sub    %edi,%eax
  800d59:	d3 e2                	shl    %cl,%edx
  800d5b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d5f:	89 c1                	mov    %eax,%ecx
  800d61:	89 da                	mov    %ebx,%edx
  800d63:	d3 ea                	shr    %cl,%edx
  800d65:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d69:	09 d1                	or     %edx,%ecx
  800d6b:	89 f2                	mov    %esi,%edx
  800d6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d71:	89 f9                	mov    %edi,%ecx
  800d73:	d3 e3                	shl    %cl,%ebx
  800d75:	89 c1                	mov    %eax,%ecx
  800d77:	d3 ea                	shr    %cl,%edx
  800d79:	89 f9                	mov    %edi,%ecx
  800d7b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d7f:	d3 e6                	shl    %cl,%esi
  800d81:	89 eb                	mov    %ebp,%ebx
  800d83:	89 c1                	mov    %eax,%ecx
  800d85:	d3 eb                	shr    %cl,%ebx
  800d87:	09 de                	or     %ebx,%esi
  800d89:	89 f0                	mov    %esi,%eax
  800d8b:	f7 74 24 08          	divl   0x8(%esp)
  800d8f:	89 d6                	mov    %edx,%esi
  800d91:	89 c3                	mov    %eax,%ebx
  800d93:	f7 64 24 0c          	mull   0xc(%esp)
  800d97:	39 d6                	cmp    %edx,%esi
  800d99:	72 0c                	jb     800da7 <__udivdi3+0xb7>
  800d9b:	89 f9                	mov    %edi,%ecx
  800d9d:	d3 e5                	shl    %cl,%ebp
  800d9f:	39 c5                	cmp    %eax,%ebp
  800da1:	73 5d                	jae    800e00 <__udivdi3+0x110>
  800da3:	39 d6                	cmp    %edx,%esi
  800da5:	75 59                	jne    800e00 <__udivdi3+0x110>
  800da7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800daa:	31 ff                	xor    %edi,%edi
  800dac:	89 fa                	mov    %edi,%edx
  800dae:	83 c4 1c             	add    $0x1c,%esp
  800db1:	5b                   	pop    %ebx
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    
  800db6:	8d 76 00             	lea    0x0(%esi),%esi
  800db9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800dc0:	31 ff                	xor    %edi,%edi
  800dc2:	31 c0                	xor    %eax,%eax
  800dc4:	89 fa                	mov    %edi,%edx
  800dc6:	83 c4 1c             	add    $0x1c,%esp
  800dc9:	5b                   	pop    %ebx
  800dca:	5e                   	pop    %esi
  800dcb:	5f                   	pop    %edi
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    
  800dce:	66 90                	xchg   %ax,%ax
  800dd0:	31 ff                	xor    %edi,%edi
  800dd2:	89 e8                	mov    %ebp,%eax
  800dd4:	89 f2                	mov    %esi,%edx
  800dd6:	f7 f3                	div    %ebx
  800dd8:	89 fa                	mov    %edi,%edx
  800dda:	83 c4 1c             	add    $0x1c,%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    
  800de2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800de8:	39 f2                	cmp    %esi,%edx
  800dea:	72 06                	jb     800df2 <__udivdi3+0x102>
  800dec:	31 c0                	xor    %eax,%eax
  800dee:	39 eb                	cmp    %ebp,%ebx
  800df0:	77 d2                	ja     800dc4 <__udivdi3+0xd4>
  800df2:	b8 01 00 00 00       	mov    $0x1,%eax
  800df7:	eb cb                	jmp    800dc4 <__udivdi3+0xd4>
  800df9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e00:	89 d8                	mov    %ebx,%eax
  800e02:	31 ff                	xor    %edi,%edi
  800e04:	eb be                	jmp    800dc4 <__udivdi3+0xd4>
  800e06:	66 90                	xchg   %ax,%ax
  800e08:	66 90                	xchg   %ax,%ax
  800e0a:	66 90                	xchg   %ax,%ax
  800e0c:	66 90                	xchg   %ax,%ax
  800e0e:	66 90                	xchg   %ax,%ax

00800e10 <__umoddi3>:
  800e10:	55                   	push   %ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
  800e14:	83 ec 1c             	sub    $0x1c,%esp
  800e17:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e1b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e1f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e27:	85 ed                	test   %ebp,%ebp
  800e29:	89 f0                	mov    %esi,%eax
  800e2b:	89 da                	mov    %ebx,%edx
  800e2d:	75 19                	jne    800e48 <__umoddi3+0x38>
  800e2f:	39 df                	cmp    %ebx,%edi
  800e31:	0f 86 b1 00 00 00    	jbe    800ee8 <__umoddi3+0xd8>
  800e37:	f7 f7                	div    %edi
  800e39:	89 d0                	mov    %edx,%eax
  800e3b:	31 d2                	xor    %edx,%edx
  800e3d:	83 c4 1c             	add    $0x1c,%esp
  800e40:	5b                   	pop    %ebx
  800e41:	5e                   	pop    %esi
  800e42:	5f                   	pop    %edi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    
  800e45:	8d 76 00             	lea    0x0(%esi),%esi
  800e48:	39 dd                	cmp    %ebx,%ebp
  800e4a:	77 f1                	ja     800e3d <__umoddi3+0x2d>
  800e4c:	0f bd cd             	bsr    %ebp,%ecx
  800e4f:	83 f1 1f             	xor    $0x1f,%ecx
  800e52:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e56:	0f 84 b4 00 00 00    	je     800f10 <__umoddi3+0x100>
  800e5c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e61:	89 c2                	mov    %eax,%edx
  800e63:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e67:	29 c2                	sub    %eax,%edx
  800e69:	89 c1                	mov    %eax,%ecx
  800e6b:	89 f8                	mov    %edi,%eax
  800e6d:	d3 e5                	shl    %cl,%ebp
  800e6f:	89 d1                	mov    %edx,%ecx
  800e71:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e75:	d3 e8                	shr    %cl,%eax
  800e77:	09 c5                	or     %eax,%ebp
  800e79:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e7d:	89 c1                	mov    %eax,%ecx
  800e7f:	d3 e7                	shl    %cl,%edi
  800e81:	89 d1                	mov    %edx,%ecx
  800e83:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e87:	89 df                	mov    %ebx,%edi
  800e89:	d3 ef                	shr    %cl,%edi
  800e8b:	89 c1                	mov    %eax,%ecx
  800e8d:	89 f0                	mov    %esi,%eax
  800e8f:	d3 e3                	shl    %cl,%ebx
  800e91:	89 d1                	mov    %edx,%ecx
  800e93:	89 fa                	mov    %edi,%edx
  800e95:	d3 e8                	shr    %cl,%eax
  800e97:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e9c:	09 d8                	or     %ebx,%eax
  800e9e:	f7 f5                	div    %ebp
  800ea0:	d3 e6                	shl    %cl,%esi
  800ea2:	89 d1                	mov    %edx,%ecx
  800ea4:	f7 64 24 08          	mull   0x8(%esp)
  800ea8:	39 d1                	cmp    %edx,%ecx
  800eaa:	89 c3                	mov    %eax,%ebx
  800eac:	89 d7                	mov    %edx,%edi
  800eae:	72 06                	jb     800eb6 <__umoddi3+0xa6>
  800eb0:	75 0e                	jne    800ec0 <__umoddi3+0xb0>
  800eb2:	39 c6                	cmp    %eax,%esi
  800eb4:	73 0a                	jae    800ec0 <__umoddi3+0xb0>
  800eb6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800eba:	19 ea                	sbb    %ebp,%edx
  800ebc:	89 d7                	mov    %edx,%edi
  800ebe:	89 c3                	mov    %eax,%ebx
  800ec0:	89 ca                	mov    %ecx,%edx
  800ec2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800ec7:	29 de                	sub    %ebx,%esi
  800ec9:	19 fa                	sbb    %edi,%edx
  800ecb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800ecf:	89 d0                	mov    %edx,%eax
  800ed1:	d3 e0                	shl    %cl,%eax
  800ed3:	89 d9                	mov    %ebx,%ecx
  800ed5:	d3 ee                	shr    %cl,%esi
  800ed7:	d3 ea                	shr    %cl,%edx
  800ed9:	09 f0                	or     %esi,%eax
  800edb:	83 c4 1c             	add    $0x1c,%esp
  800ede:	5b                   	pop    %ebx
  800edf:	5e                   	pop    %esi
  800ee0:	5f                   	pop    %edi
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    
  800ee3:	90                   	nop
  800ee4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ee8:	85 ff                	test   %edi,%edi
  800eea:	89 f9                	mov    %edi,%ecx
  800eec:	75 0b                	jne    800ef9 <__umoddi3+0xe9>
  800eee:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef3:	31 d2                	xor    %edx,%edx
  800ef5:	f7 f7                	div    %edi
  800ef7:	89 c1                	mov    %eax,%ecx
  800ef9:	89 d8                	mov    %ebx,%eax
  800efb:	31 d2                	xor    %edx,%edx
  800efd:	f7 f1                	div    %ecx
  800eff:	89 f0                	mov    %esi,%eax
  800f01:	f7 f1                	div    %ecx
  800f03:	e9 31 ff ff ff       	jmp    800e39 <__umoddi3+0x29>
  800f08:	90                   	nop
  800f09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f10:	39 dd                	cmp    %ebx,%ebp
  800f12:	72 08                	jb     800f1c <__umoddi3+0x10c>
  800f14:	39 f7                	cmp    %esi,%edi
  800f16:	0f 87 21 ff ff ff    	ja     800e3d <__umoddi3+0x2d>
  800f1c:	89 da                	mov    %ebx,%edx
  800f1e:	89 f0                	mov    %esi,%eax
  800f20:	29 f8                	sub    %edi,%eax
  800f22:	19 ea                	sbb    %ebp,%edx
  800f24:	e9 14 ff ff ff       	jmp    800e3d <__umoddi3+0x2d>
