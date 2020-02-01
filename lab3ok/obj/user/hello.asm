
obj/user/hello：     文件格式 elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
  80003a:	e8 35 00 00 00       	call   800074 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	cprintf("hello, world\n");
  800045:	8d 83 9c ee ff ff    	lea    -0x1164(%ebx),%eax
  80004b:	50                   	push   %eax
  80004c:	e8 57 01 00 00       	call   8001a8 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800051:	c7 c0 2c 20 80 00    	mov    $0x80202c,%eax
  800057:	8b 00                	mov    (%eax),%eax
  800059:	8b 40 48             	mov    0x48(%eax),%eax
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	50                   	push   %eax
  800060:	8d 83 aa ee ff ff    	lea    -0x1156(%ebx),%eax
  800066:	50                   	push   %eax
  800067:	e8 3c 01 00 00       	call   8001a8 <cprintf>
}
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800072:	c9                   	leave  
  800073:	c3                   	ret    

00800074 <__x86.get_pc_thunk.bx>:
  800074:	8b 1c 24             	mov    (%esp),%ebx
  800077:	c3                   	ret    

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	57                   	push   %edi
  80007c:	56                   	push   %esi
  80007d:	53                   	push   %ebx
  80007e:	83 ec 0c             	sub    $0xc,%esp
  800081:	e8 ee ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800086:	81 c3 7a 1f 00 00    	add    $0x1f7a,%ebx
  80008c:	8b 75 08             	mov    0x8(%ebp),%esi
  80008f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800092:	e8 3f 0b 00 00       	call   800bd6 <sys_getenvid>
  800097:	25 ff 03 00 00       	and    $0x3ff,%eax
  80009c:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80009f:	c1 e0 05             	shl    $0x5,%eax
  8000a2:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  8000a8:	c7 c2 2c 20 80 00    	mov    $0x80202c,%edx
  8000ae:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b0:	85 f6                	test   %esi,%esi
  8000b2:	7e 08                	jle    8000bc <libmain+0x44>
		binaryname = argv[0];
  8000b4:	8b 07                	mov    (%edi),%eax
  8000b6:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000bc:	83 ec 08             	sub    $0x8,%esp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	e8 6d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000c6:	e8 0b 00 00 00       	call   8000d6 <exit>
}
  8000cb:	83 c4 10             	add    $0x10,%esp
  8000ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	53                   	push   %ebx
  8000da:	83 ec 10             	sub    $0x10,%esp
  8000dd:	e8 92 ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  8000e2:	81 c3 1e 1f 00 00    	add    $0x1f1e,%ebx
	sys_env_destroy(0);
  8000e8:	6a 00                	push   $0x0
  8000ea:	e8 92 0a 00 00       	call   800b81 <sys_env_destroy>
}
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f5:	c9                   	leave  
  8000f6:	c3                   	ret    

008000f7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 73 ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800101:	81 c3 ff 1e 00 00    	add    $0x1eff,%ebx
  800107:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  80010a:	8b 16                	mov    (%esi),%edx
  80010c:	8d 42 01             	lea    0x1(%edx),%eax
  80010f:	89 06                	mov    %eax,(%esi)
  800111:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800114:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800118:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011d:	74 0b                	je     80012a <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80011f:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800123:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800126:	5b                   	pop    %ebx
  800127:	5e                   	pop    %esi
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80012a:	83 ec 08             	sub    $0x8,%esp
  80012d:	68 ff 00 00 00       	push   $0xff
  800132:	8d 46 08             	lea    0x8(%esi),%eax
  800135:	50                   	push   %eax
  800136:	e8 09 0a 00 00       	call   800b44 <sys_cputs>
		b->idx = 0;
  80013b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800141:	83 c4 10             	add    $0x10,%esp
  800144:	eb d9                	jmp    80011f <putch+0x28>

00800146 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	53                   	push   %ebx
  80014a:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800150:	e8 1f ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800155:	81 c3 ab 1e 00 00    	add    $0x1eab,%ebx
	struct printbuf b;

	b.idx = 0;
  80015b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800162:	00 00 00 
	b.cnt = 0;
  800165:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016f:	ff 75 0c             	pushl  0xc(%ebp)
  800172:	ff 75 08             	pushl  0x8(%ebp)
  800175:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80017b:	50                   	push   %eax
  80017c:	8d 83 f7 e0 ff ff    	lea    -0x1f09(%ebx),%eax
  800182:	50                   	push   %eax
  800183:	e8 38 01 00 00       	call   8002c0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800188:	83 c4 08             	add    $0x8,%esp
  80018b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800191:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800197:	50                   	push   %eax
  800198:	e8 a7 09 00 00       	call   800b44 <sys_cputs>

	return b.cnt;
}
  80019d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b1:	50                   	push   %eax
  8001b2:	ff 75 08             	pushl  0x8(%ebp)
  8001b5:	e8 8c ff ff ff       	call   800146 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 2c             	sub    $0x2c,%esp
  8001c5:	e8 02 06 00 00       	call   8007cc <__x86.get_pc_thunk.cx>
  8001ca:	81 c1 36 1e 00 00    	add    $0x1e36,%ecx
  8001d0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001d3:	89 c7                	mov    %eax,%edi
  8001d5:	89 d6                	mov    %edx,%esi
  8001d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001dd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001e0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001eb:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8001ee:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8001f1:	39 d3                	cmp    %edx,%ebx
  8001f3:	72 09                	jb     8001fe <printnum+0x42>
  8001f5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f8:	0f 87 83 00 00 00    	ja     800281 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	ff 75 18             	pushl  0x18(%ebp)
  800204:	8b 45 14             	mov    0x14(%ebp),%eax
  800207:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80020a:	53                   	push   %ebx
  80020b:	ff 75 10             	pushl  0x10(%ebp)
  80020e:	83 ec 08             	sub    $0x8,%esp
  800211:	ff 75 dc             	pushl  -0x24(%ebp)
  800214:	ff 75 d8             	pushl  -0x28(%ebp)
  800217:	ff 75 d4             	pushl  -0x2c(%ebp)
  80021a:	ff 75 d0             	pushl  -0x30(%ebp)
  80021d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800220:	e8 3b 0a 00 00       	call   800c60 <__udivdi3>
  800225:	83 c4 18             	add    $0x18,%esp
  800228:	52                   	push   %edx
  800229:	50                   	push   %eax
  80022a:	89 f2                	mov    %esi,%edx
  80022c:	89 f8                	mov    %edi,%eax
  80022e:	e8 89 ff ff ff       	call   8001bc <printnum>
  800233:	83 c4 20             	add    $0x20,%esp
  800236:	eb 13                	jmp    80024b <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800238:	83 ec 08             	sub    $0x8,%esp
  80023b:	56                   	push   %esi
  80023c:	ff 75 18             	pushl  0x18(%ebp)
  80023f:	ff d7                	call   *%edi
  800241:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800244:	83 eb 01             	sub    $0x1,%ebx
  800247:	85 db                	test   %ebx,%ebx
  800249:	7f ed                	jg     800238 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024b:	83 ec 08             	sub    $0x8,%esp
  80024e:	56                   	push   %esi
  80024f:	83 ec 04             	sub    $0x4,%esp
  800252:	ff 75 dc             	pushl  -0x24(%ebp)
  800255:	ff 75 d8             	pushl  -0x28(%ebp)
  800258:	ff 75 d4             	pushl  -0x2c(%ebp)
  80025b:	ff 75 d0             	pushl  -0x30(%ebp)
  80025e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800261:	89 f3                	mov    %esi,%ebx
  800263:	e8 18 0b 00 00       	call   800d80 <__umoddi3>
  800268:	83 c4 14             	add    $0x14,%esp
  80026b:	0f be 84 06 cb ee ff 	movsbl -0x1135(%esi,%eax,1),%eax
  800272:	ff 
  800273:	50                   	push   %eax
  800274:	ff d7                	call   *%edi
}
  800276:	83 c4 10             	add    $0x10,%esp
  800279:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027c:	5b                   	pop    %ebx
  80027d:	5e                   	pop    %esi
  80027e:	5f                   	pop    %edi
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    
  800281:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800284:	eb be                	jmp    800244 <printnum+0x88>

00800286 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800290:	8b 10                	mov    (%eax),%edx
  800292:	3b 50 04             	cmp    0x4(%eax),%edx
  800295:	73 0a                	jae    8002a1 <sprintputch+0x1b>
		*b->buf++ = ch;
  800297:	8d 4a 01             	lea    0x1(%edx),%ecx
  80029a:	89 08                	mov    %ecx,(%eax)
  80029c:	8b 45 08             	mov    0x8(%ebp),%eax
  80029f:	88 02                	mov    %al,(%edx)
}
  8002a1:	5d                   	pop    %ebp
  8002a2:	c3                   	ret    

008002a3 <printfmt>:
{
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
  8002a6:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002a9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ac:	50                   	push   %eax
  8002ad:	ff 75 10             	pushl  0x10(%ebp)
  8002b0:	ff 75 0c             	pushl  0xc(%ebp)
  8002b3:	ff 75 08             	pushl  0x8(%ebp)
  8002b6:	e8 05 00 00 00       	call   8002c0 <vprintfmt>
}
  8002bb:	83 c4 10             	add    $0x10,%esp
  8002be:	c9                   	leave  
  8002bf:	c3                   	ret    

008002c0 <vprintfmt>:
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 2c             	sub    $0x2c,%esp
  8002c9:	e8 a6 fd ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  8002ce:	81 c3 32 1d 00 00    	add    $0x1d32,%ebx
  8002d4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002d7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002da:	e9 c3 03 00 00       	jmp    8006a2 <.L35+0x48>
		padc = ' ';
  8002df:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002e3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002ea:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8002f1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002fd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800300:	8d 47 01             	lea    0x1(%edi),%eax
  800303:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800306:	0f b6 17             	movzbl (%edi),%edx
  800309:	8d 42 dd             	lea    -0x23(%edx),%eax
  80030c:	3c 55                	cmp    $0x55,%al
  80030e:	0f 87 16 04 00 00    	ja     80072a <.L22>
  800314:	0f b6 c0             	movzbl %al,%eax
  800317:	89 d9                	mov    %ebx,%ecx
  800319:	03 8c 83 58 ef ff ff 	add    -0x10a8(%ebx,%eax,4),%ecx
  800320:	ff e1                	jmp    *%ecx

00800322 <.L69>:
  800322:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800325:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800329:	eb d5                	jmp    800300 <vprintfmt+0x40>

0080032b <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  80032b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80032e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800332:	eb cc                	jmp    800300 <vprintfmt+0x40>

00800334 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  800334:	0f b6 d2             	movzbl %dl,%edx
  800337:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80033a:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  80033f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800342:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800346:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800349:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80034c:	83 f9 09             	cmp    $0x9,%ecx
  80034f:	77 55                	ja     8003a6 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  800351:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800354:	eb e9                	jmp    80033f <.L29+0xb>

00800356 <.L26>:
			precision = va_arg(ap, int);
  800356:	8b 45 14             	mov    0x14(%ebp),%eax
  800359:	8b 00                	mov    (%eax),%eax
  80035b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80035e:	8b 45 14             	mov    0x14(%ebp),%eax
  800361:	8d 40 04             	lea    0x4(%eax),%eax
  800364:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80036a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80036e:	79 90                	jns    800300 <vprintfmt+0x40>
				width = precision, precision = -1;
  800370:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800373:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800376:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80037d:	eb 81                	jmp    800300 <vprintfmt+0x40>

0080037f <.L27>:
  80037f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800382:	85 c0                	test   %eax,%eax
  800384:	ba 00 00 00 00       	mov    $0x0,%edx
  800389:	0f 49 d0             	cmovns %eax,%edx
  80038c:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800392:	e9 69 ff ff ff       	jmp    800300 <vprintfmt+0x40>

00800397 <.L23>:
  800397:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80039a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a1:	e9 5a ff ff ff       	jmp    800300 <vprintfmt+0x40>
  8003a6:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003a9:	eb bf                	jmp    80036a <.L26+0x14>

008003ab <.L33>:
			lflag++;
  8003ab:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003b2:	e9 49 ff ff ff       	jmp    800300 <vprintfmt+0x40>

008003b7 <.L30>:
			putch(va_arg(ap, int), putdat);
  8003b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ba:	8d 78 04             	lea    0x4(%eax),%edi
  8003bd:	83 ec 08             	sub    $0x8,%esp
  8003c0:	56                   	push   %esi
  8003c1:	ff 30                	pushl  (%eax)
  8003c3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003c6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003c9:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003cc:	e9 ce 02 00 00       	jmp    80069f <.L35+0x45>

008003d1 <.L32>:
			err = va_arg(ap, int);
  8003d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d4:	8d 78 04             	lea    0x4(%eax),%edi
  8003d7:	8b 00                	mov    (%eax),%eax
  8003d9:	99                   	cltd   
  8003da:	31 d0                	xor    %edx,%eax
  8003dc:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003de:	83 f8 06             	cmp    $0x6,%eax
  8003e1:	7f 27                	jg     80040a <.L32+0x39>
  8003e3:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8003ea:	85 d2                	test   %edx,%edx
  8003ec:	74 1c                	je     80040a <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8003ee:	52                   	push   %edx
  8003ef:	8d 83 ec ee ff ff    	lea    -0x1114(%ebx),%eax
  8003f5:	50                   	push   %eax
  8003f6:	56                   	push   %esi
  8003f7:	ff 75 08             	pushl  0x8(%ebp)
  8003fa:	e8 a4 fe ff ff       	call   8002a3 <printfmt>
  8003ff:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800402:	89 7d 14             	mov    %edi,0x14(%ebp)
  800405:	e9 95 02 00 00       	jmp    80069f <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  80040a:	50                   	push   %eax
  80040b:	8d 83 e3 ee ff ff    	lea    -0x111d(%ebx),%eax
  800411:	50                   	push   %eax
  800412:	56                   	push   %esi
  800413:	ff 75 08             	pushl  0x8(%ebp)
  800416:	e8 88 fe ff ff       	call   8002a3 <printfmt>
  80041b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80041e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800421:	e9 79 02 00 00       	jmp    80069f <.L35+0x45>

00800426 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800426:	8b 45 14             	mov    0x14(%ebp),%eax
  800429:	83 c0 04             	add    $0x4,%eax
  80042c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80042f:	8b 45 14             	mov    0x14(%ebp),%eax
  800432:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800434:	85 ff                	test   %edi,%edi
  800436:	8d 83 dc ee ff ff    	lea    -0x1124(%ebx),%eax
  80043c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80043f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800443:	0f 8e b5 00 00 00    	jle    8004fe <.L36+0xd8>
  800449:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80044d:	75 08                	jne    800457 <.L36+0x31>
  80044f:	89 75 0c             	mov    %esi,0xc(%ebp)
  800452:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800455:	eb 6d                	jmp    8004c4 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	ff 75 cc             	pushl  -0x34(%ebp)
  80045d:	57                   	push   %edi
  80045e:	e8 85 03 00 00       	call   8007e8 <strnlen>
  800463:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800466:	29 c2                	sub    %eax,%edx
  800468:	89 55 c8             	mov    %edx,-0x38(%ebp)
  80046b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80046e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800472:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800475:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800478:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80047a:	eb 10                	jmp    80048c <.L36+0x66>
					putch(padc, putdat);
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	56                   	push   %esi
  800480:	ff 75 e0             	pushl  -0x20(%ebp)
  800483:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800486:	83 ef 01             	sub    $0x1,%edi
  800489:	83 c4 10             	add    $0x10,%esp
  80048c:	85 ff                	test   %edi,%edi
  80048e:	7f ec                	jg     80047c <.L36+0x56>
  800490:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800493:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800496:	85 d2                	test   %edx,%edx
  800498:	b8 00 00 00 00       	mov    $0x0,%eax
  80049d:	0f 49 c2             	cmovns %edx,%eax
  8004a0:	29 c2                	sub    %eax,%edx
  8004a2:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004a5:	89 75 0c             	mov    %esi,0xc(%ebp)
  8004a8:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004ab:	eb 17                	jmp    8004c4 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ad:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b1:	75 30                	jne    8004e3 <.L36+0xbd>
					putch(ch, putdat);
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	ff 75 0c             	pushl  0xc(%ebp)
  8004b9:	50                   	push   %eax
  8004ba:	ff 55 08             	call   *0x8(%ebp)
  8004bd:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c0:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8004c4:	83 c7 01             	add    $0x1,%edi
  8004c7:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004cb:	0f be c2             	movsbl %dl,%eax
  8004ce:	85 c0                	test   %eax,%eax
  8004d0:	74 52                	je     800524 <.L36+0xfe>
  8004d2:	85 f6                	test   %esi,%esi
  8004d4:	78 d7                	js     8004ad <.L36+0x87>
  8004d6:	83 ee 01             	sub    $0x1,%esi
  8004d9:	79 d2                	jns    8004ad <.L36+0x87>
  8004db:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004de:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004e1:	eb 32                	jmp    800515 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8004e3:	0f be d2             	movsbl %dl,%edx
  8004e6:	83 ea 20             	sub    $0x20,%edx
  8004e9:	83 fa 5e             	cmp    $0x5e,%edx
  8004ec:	76 c5                	jbe    8004b3 <.L36+0x8d>
					putch('?', putdat);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	ff 75 0c             	pushl  0xc(%ebp)
  8004f4:	6a 3f                	push   $0x3f
  8004f6:	ff 55 08             	call   *0x8(%ebp)
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	eb c2                	jmp    8004c0 <.L36+0x9a>
  8004fe:	89 75 0c             	mov    %esi,0xc(%ebp)
  800501:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800504:	eb be                	jmp    8004c4 <.L36+0x9e>
				putch(' ', putdat);
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	56                   	push   %esi
  80050a:	6a 20                	push   $0x20
  80050c:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  80050f:	83 ef 01             	sub    $0x1,%edi
  800512:	83 c4 10             	add    $0x10,%esp
  800515:	85 ff                	test   %edi,%edi
  800517:	7f ed                	jg     800506 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  800519:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80051c:	89 45 14             	mov    %eax,0x14(%ebp)
  80051f:	e9 7b 01 00 00       	jmp    80069f <.L35+0x45>
  800524:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800527:	8b 75 0c             	mov    0xc(%ebp),%esi
  80052a:	eb e9                	jmp    800515 <.L36+0xef>

0080052c <.L31>:
  80052c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80052f:	83 f9 01             	cmp    $0x1,%ecx
  800532:	7e 40                	jle    800574 <.L31+0x48>
		return va_arg(*ap, long long);
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8b 50 04             	mov    0x4(%eax),%edx
  80053a:	8b 00                	mov    (%eax),%eax
  80053c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8d 40 08             	lea    0x8(%eax),%eax
  800548:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80054b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80054f:	79 55                	jns    8005a6 <.L31+0x7a>
				putch('-', putdat);
  800551:	83 ec 08             	sub    $0x8,%esp
  800554:	56                   	push   %esi
  800555:	6a 2d                	push   $0x2d
  800557:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80055a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80055d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800560:	f7 da                	neg    %edx
  800562:	83 d1 00             	adc    $0x0,%ecx
  800565:	f7 d9                	neg    %ecx
  800567:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80056a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056f:	e9 10 01 00 00       	jmp    800684 <.L35+0x2a>
	else if (lflag)
  800574:	85 c9                	test   %ecx,%ecx
  800576:	75 17                	jne    80058f <.L31+0x63>
		return va_arg(*ap, int);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8b 00                	mov    (%eax),%eax
  80057d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800580:	99                   	cltd   
  800581:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8d 40 04             	lea    0x4(%eax),%eax
  80058a:	89 45 14             	mov    %eax,0x14(%ebp)
  80058d:	eb bc                	jmp    80054b <.L31+0x1f>
		return va_arg(*ap, long);
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8b 00                	mov    (%eax),%eax
  800594:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800597:	99                   	cltd   
  800598:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8d 40 04             	lea    0x4(%eax),%eax
  8005a1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a4:	eb a5                	jmp    80054b <.L31+0x1f>
			num = getint(&ap, lflag);
  8005a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005ac:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b1:	e9 ce 00 00 00       	jmp    800684 <.L35+0x2a>

008005b6 <.L37>:
  8005b6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8005b9:	83 f9 01             	cmp    $0x1,%ecx
  8005bc:	7e 18                	jle    8005d6 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8b 10                	mov    (%eax),%edx
  8005c3:	8b 48 04             	mov    0x4(%eax),%ecx
  8005c6:	8d 40 08             	lea    0x8(%eax),%eax
  8005c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005cc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d1:	e9 ae 00 00 00       	jmp    800684 <.L35+0x2a>
	else if (lflag)
  8005d6:	85 c9                	test   %ecx,%ecx
  8005d8:	75 1a                	jne    8005f4 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8b 10                	mov    (%eax),%edx
  8005df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e4:	8d 40 04             	lea    0x4(%eax),%eax
  8005e7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ea:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ef:	e9 90 00 00 00       	jmp    800684 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8b 10                	mov    (%eax),%edx
  8005f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fe:	8d 40 04             	lea    0x4(%eax),%eax
  800601:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800604:	b8 0a 00 00 00       	mov    $0xa,%eax
  800609:	eb 79                	jmp    800684 <.L35+0x2a>

0080060b <.L34>:
  80060b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80060e:	83 f9 01             	cmp    $0x1,%ecx
  800611:	7e 15                	jle    800628 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  800613:	8b 45 14             	mov    0x14(%ebp),%eax
  800616:	8b 10                	mov    (%eax),%edx
  800618:	8b 48 04             	mov    0x4(%eax),%ecx
  80061b:	8d 40 08             	lea    0x8(%eax),%eax
  80061e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800621:	b8 08 00 00 00       	mov    $0x8,%eax
  800626:	eb 5c                	jmp    800684 <.L35+0x2a>
	else if (lflag)
  800628:	85 c9                	test   %ecx,%ecx
  80062a:	75 17                	jne    800643 <.L34+0x38>
		return va_arg(*ap, unsigned int);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8b 10                	mov    (%eax),%edx
  800631:	b9 00 00 00 00       	mov    $0x0,%ecx
  800636:	8d 40 04             	lea    0x4(%eax),%eax
  800639:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80063c:	b8 08 00 00 00       	mov    $0x8,%eax
  800641:	eb 41                	jmp    800684 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8b 10                	mov    (%eax),%edx
  800648:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064d:	8d 40 04             	lea    0x4(%eax),%eax
  800650:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800653:	b8 08 00 00 00       	mov    $0x8,%eax
  800658:	eb 2a                	jmp    800684 <.L35+0x2a>

0080065a <.L35>:
			putch('0', putdat);
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	56                   	push   %esi
  80065e:	6a 30                	push   $0x30
  800660:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800663:	83 c4 08             	add    $0x8,%esp
  800666:	56                   	push   %esi
  800667:	6a 78                	push   $0x78
  800669:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8b 10                	mov    (%eax),%edx
  800671:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800676:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800679:	8d 40 04             	lea    0x4(%eax),%eax
  80067c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80067f:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800684:	83 ec 0c             	sub    $0xc,%esp
  800687:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80068b:	57                   	push   %edi
  80068c:	ff 75 e0             	pushl  -0x20(%ebp)
  80068f:	50                   	push   %eax
  800690:	51                   	push   %ecx
  800691:	52                   	push   %edx
  800692:	89 f2                	mov    %esi,%edx
  800694:	8b 45 08             	mov    0x8(%ebp),%eax
  800697:	e8 20 fb ff ff       	call   8001bc <printnum>
			break;
  80069c:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80069f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006a2:	83 c7 01             	add    $0x1,%edi
  8006a5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006a9:	83 f8 25             	cmp    $0x25,%eax
  8006ac:	0f 84 2d fc ff ff    	je     8002df <vprintfmt+0x1f>
			if (ch == '\0')
  8006b2:	85 c0                	test   %eax,%eax
  8006b4:	0f 84 91 00 00 00    	je     80074b <.L22+0x21>
			putch(ch, putdat);
  8006ba:	83 ec 08             	sub    $0x8,%esp
  8006bd:	56                   	push   %esi
  8006be:	50                   	push   %eax
  8006bf:	ff 55 08             	call   *0x8(%ebp)
  8006c2:	83 c4 10             	add    $0x10,%esp
  8006c5:	eb db                	jmp    8006a2 <.L35+0x48>

008006c7 <.L38>:
  8006c7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006ca:	83 f9 01             	cmp    $0x1,%ecx
  8006cd:	7e 15                	jle    8006e4 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8b 10                	mov    (%eax),%edx
  8006d4:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d7:	8d 40 08             	lea    0x8(%eax),%eax
  8006da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006dd:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e2:	eb a0                	jmp    800684 <.L35+0x2a>
	else if (lflag)
  8006e4:	85 c9                	test   %ecx,%ecx
  8006e6:	75 17                	jne    8006ff <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8b 10                	mov    (%eax),%edx
  8006ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f2:	8d 40 04             	lea    0x4(%eax),%eax
  8006f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f8:	b8 10 00 00 00       	mov    $0x10,%eax
  8006fd:	eb 85                	jmp    800684 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800702:	8b 10                	mov    (%eax),%edx
  800704:	b9 00 00 00 00       	mov    $0x0,%ecx
  800709:	8d 40 04             	lea    0x4(%eax),%eax
  80070c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070f:	b8 10 00 00 00       	mov    $0x10,%eax
  800714:	e9 6b ff ff ff       	jmp    800684 <.L35+0x2a>

00800719 <.L25>:
			putch(ch, putdat);
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	56                   	push   %esi
  80071d:	6a 25                	push   $0x25
  80071f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800722:	83 c4 10             	add    $0x10,%esp
  800725:	e9 75 ff ff ff       	jmp    80069f <.L35+0x45>

0080072a <.L22>:
			putch('%', putdat);
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	56                   	push   %esi
  80072e:	6a 25                	push   $0x25
  800730:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800733:	83 c4 10             	add    $0x10,%esp
  800736:	89 f8                	mov    %edi,%eax
  800738:	eb 03                	jmp    80073d <.L22+0x13>
  80073a:	83 e8 01             	sub    $0x1,%eax
  80073d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800741:	75 f7                	jne    80073a <.L22+0x10>
  800743:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800746:	e9 54 ff ff ff       	jmp    80069f <.L35+0x45>
}
  80074b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074e:	5b                   	pop    %ebx
  80074f:	5e                   	pop    %esi
  800750:	5f                   	pop    %edi
  800751:	5d                   	pop    %ebp
  800752:	c3                   	ret    

00800753 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	53                   	push   %ebx
  800757:	83 ec 14             	sub    $0x14,%esp
  80075a:	e8 15 f9 ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  80075f:	81 c3 a1 18 00 00    	add    $0x18a1,%ebx
  800765:	8b 45 08             	mov    0x8(%ebp),%eax
  800768:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80076b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800772:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800775:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80077c:	85 c0                	test   %eax,%eax
  80077e:	74 2b                	je     8007ab <vsnprintf+0x58>
  800780:	85 d2                	test   %edx,%edx
  800782:	7e 27                	jle    8007ab <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800784:	ff 75 14             	pushl  0x14(%ebp)
  800787:	ff 75 10             	pushl  0x10(%ebp)
  80078a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80078d:	50                   	push   %eax
  80078e:	8d 83 86 e2 ff ff    	lea    -0x1d7a(%ebx),%eax
  800794:	50                   	push   %eax
  800795:	e8 26 fb ff ff       	call   8002c0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80079a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a3:	83 c4 10             	add    $0x10,%esp
}
  8007a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a9:	c9                   	leave  
  8007aa:	c3                   	ret    
		return -E_INVAL;
  8007ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b0:	eb f4                	jmp    8007a6 <vsnprintf+0x53>

008007b2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007bb:	50                   	push   %eax
  8007bc:	ff 75 10             	pushl  0x10(%ebp)
  8007bf:	ff 75 0c             	pushl  0xc(%ebp)
  8007c2:	ff 75 08             	pushl  0x8(%ebp)
  8007c5:	e8 89 ff ff ff       	call   800753 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ca:	c9                   	leave  
  8007cb:	c3                   	ret    

008007cc <__x86.get_pc_thunk.cx>:
  8007cc:	8b 0c 24             	mov    (%esp),%ecx
  8007cf:	c3                   	ret    

008007d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007db:	eb 03                	jmp    8007e0 <strlen+0x10>
		n++;
  8007dd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007e0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e4:	75 f7                	jne    8007dd <strlen+0xd>
	return n;
}
  8007e6:	5d                   	pop    %ebp
  8007e7:	c3                   	ret    

008007e8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f6:	eb 03                	jmp    8007fb <strnlen+0x13>
		n++;
  8007f8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fb:	39 d0                	cmp    %edx,%eax
  8007fd:	74 06                	je     800805 <strnlen+0x1d>
  8007ff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800803:	75 f3                	jne    8007f8 <strnlen+0x10>
	return n;
}
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800811:	89 c2                	mov    %eax,%edx
  800813:	83 c1 01             	add    $0x1,%ecx
  800816:	83 c2 01             	add    $0x1,%edx
  800819:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80081d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800820:	84 db                	test   %bl,%bl
  800822:	75 ef                	jne    800813 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800824:	5b                   	pop    %ebx
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80082e:	53                   	push   %ebx
  80082f:	e8 9c ff ff ff       	call   8007d0 <strlen>
  800834:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800837:	ff 75 0c             	pushl  0xc(%ebp)
  80083a:	01 d8                	add    %ebx,%eax
  80083c:	50                   	push   %eax
  80083d:	e8 c5 ff ff ff       	call   800807 <strcpy>
	return dst;
}
  800842:	89 d8                	mov    %ebx,%eax
  800844:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800847:	c9                   	leave  
  800848:	c3                   	ret    

00800849 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	56                   	push   %esi
  80084d:	53                   	push   %ebx
  80084e:	8b 75 08             	mov    0x8(%ebp),%esi
  800851:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800854:	89 f3                	mov    %esi,%ebx
  800856:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800859:	89 f2                	mov    %esi,%edx
  80085b:	eb 0f                	jmp    80086c <strncpy+0x23>
		*dst++ = *src;
  80085d:	83 c2 01             	add    $0x1,%edx
  800860:	0f b6 01             	movzbl (%ecx),%eax
  800863:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800866:	80 39 01             	cmpb   $0x1,(%ecx)
  800869:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80086c:	39 da                	cmp    %ebx,%edx
  80086e:	75 ed                	jne    80085d <strncpy+0x14>
	}
	return ret;
}
  800870:	89 f0                	mov    %esi,%eax
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	56                   	push   %esi
  80087a:	53                   	push   %ebx
  80087b:	8b 75 08             	mov    0x8(%ebp),%esi
  80087e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800881:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800884:	89 f0                	mov    %esi,%eax
  800886:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088a:	85 c9                	test   %ecx,%ecx
  80088c:	75 0b                	jne    800899 <strlcpy+0x23>
  80088e:	eb 17                	jmp    8008a7 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800890:	83 c2 01             	add    $0x1,%edx
  800893:	83 c0 01             	add    $0x1,%eax
  800896:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800899:	39 d8                	cmp    %ebx,%eax
  80089b:	74 07                	je     8008a4 <strlcpy+0x2e>
  80089d:	0f b6 0a             	movzbl (%edx),%ecx
  8008a0:	84 c9                	test   %cl,%cl
  8008a2:	75 ec                	jne    800890 <strlcpy+0x1a>
		*dst = '\0';
  8008a4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008a7:	29 f0                	sub    %esi,%eax
}
  8008a9:	5b                   	pop    %ebx
  8008aa:	5e                   	pop    %esi
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    

008008ad <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b6:	eb 06                	jmp    8008be <strcmp+0x11>
		p++, q++;
  8008b8:	83 c1 01             	add    $0x1,%ecx
  8008bb:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008be:	0f b6 01             	movzbl (%ecx),%eax
  8008c1:	84 c0                	test   %al,%al
  8008c3:	74 04                	je     8008c9 <strcmp+0x1c>
  8008c5:	3a 02                	cmp    (%edx),%al
  8008c7:	74 ef                	je     8008b8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c9:	0f b6 c0             	movzbl %al,%eax
  8008cc:	0f b6 12             	movzbl (%edx),%edx
  8008cf:	29 d0                	sub    %edx,%eax
}
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    

008008d3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	53                   	push   %ebx
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008dd:	89 c3                	mov    %eax,%ebx
  8008df:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008e2:	eb 06                	jmp    8008ea <strncmp+0x17>
		n--, p++, q++;
  8008e4:	83 c0 01             	add    $0x1,%eax
  8008e7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008ea:	39 d8                	cmp    %ebx,%eax
  8008ec:	74 16                	je     800904 <strncmp+0x31>
  8008ee:	0f b6 08             	movzbl (%eax),%ecx
  8008f1:	84 c9                	test   %cl,%cl
  8008f3:	74 04                	je     8008f9 <strncmp+0x26>
  8008f5:	3a 0a                	cmp    (%edx),%cl
  8008f7:	74 eb                	je     8008e4 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f9:	0f b6 00             	movzbl (%eax),%eax
  8008fc:	0f b6 12             	movzbl (%edx),%edx
  8008ff:	29 d0                	sub    %edx,%eax
}
  800901:	5b                   	pop    %ebx
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    
		return 0;
  800904:	b8 00 00 00 00       	mov    $0x0,%eax
  800909:	eb f6                	jmp    800901 <strncmp+0x2e>

0080090b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800915:	0f b6 10             	movzbl (%eax),%edx
  800918:	84 d2                	test   %dl,%dl
  80091a:	74 09                	je     800925 <strchr+0x1a>
		if (*s == c)
  80091c:	38 ca                	cmp    %cl,%dl
  80091e:	74 0a                	je     80092a <strchr+0x1f>
	for (; *s; s++)
  800920:	83 c0 01             	add    $0x1,%eax
  800923:	eb f0                	jmp    800915 <strchr+0xa>
			return (char *) s;
	return 0;
  800925:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800936:	eb 03                	jmp    80093b <strfind+0xf>
  800938:	83 c0 01             	add    $0x1,%eax
  80093b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80093e:	38 ca                	cmp    %cl,%dl
  800940:	74 04                	je     800946 <strfind+0x1a>
  800942:	84 d2                	test   %dl,%dl
  800944:	75 f2                	jne    800938 <strfind+0xc>
			break;
	return (char *) s;
}
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	57                   	push   %edi
  80094c:	56                   	push   %esi
  80094d:	53                   	push   %ebx
  80094e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800951:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800954:	85 c9                	test   %ecx,%ecx
  800956:	74 13                	je     80096b <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800958:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095e:	75 05                	jne    800965 <memset+0x1d>
  800960:	f6 c1 03             	test   $0x3,%cl
  800963:	74 0d                	je     800972 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800965:	8b 45 0c             	mov    0xc(%ebp),%eax
  800968:	fc                   	cld    
  800969:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096b:	89 f8                	mov    %edi,%eax
  80096d:	5b                   	pop    %ebx
  80096e:	5e                   	pop    %esi
  80096f:	5f                   	pop    %edi
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    
		c &= 0xFF;
  800972:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800976:	89 d3                	mov    %edx,%ebx
  800978:	c1 e3 08             	shl    $0x8,%ebx
  80097b:	89 d0                	mov    %edx,%eax
  80097d:	c1 e0 18             	shl    $0x18,%eax
  800980:	89 d6                	mov    %edx,%esi
  800982:	c1 e6 10             	shl    $0x10,%esi
  800985:	09 f0                	or     %esi,%eax
  800987:	09 c2                	or     %eax,%edx
  800989:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  80098b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80098e:	89 d0                	mov    %edx,%eax
  800990:	fc                   	cld    
  800991:	f3 ab                	rep stos %eax,%es:(%edi)
  800993:	eb d6                	jmp    80096b <memset+0x23>

00800995 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	57                   	push   %edi
  800999:	56                   	push   %esi
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a3:	39 c6                	cmp    %eax,%esi
  8009a5:	73 35                	jae    8009dc <memmove+0x47>
  8009a7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009aa:	39 c2                	cmp    %eax,%edx
  8009ac:	76 2e                	jbe    8009dc <memmove+0x47>
		s += n;
		d += n;
  8009ae:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b1:	89 d6                	mov    %edx,%esi
  8009b3:	09 fe                	or     %edi,%esi
  8009b5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009bb:	74 0c                	je     8009c9 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009bd:	83 ef 01             	sub    $0x1,%edi
  8009c0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009c3:	fd                   	std    
  8009c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c6:	fc                   	cld    
  8009c7:	eb 21                	jmp    8009ea <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c9:	f6 c1 03             	test   $0x3,%cl
  8009cc:	75 ef                	jne    8009bd <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ce:	83 ef 04             	sub    $0x4,%edi
  8009d1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009d7:	fd                   	std    
  8009d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009da:	eb ea                	jmp    8009c6 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009dc:	89 f2                	mov    %esi,%edx
  8009de:	09 c2                	or     %eax,%edx
  8009e0:	f6 c2 03             	test   $0x3,%dl
  8009e3:	74 09                	je     8009ee <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e5:	89 c7                	mov    %eax,%edi
  8009e7:	fc                   	cld    
  8009e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ea:	5e                   	pop    %esi
  8009eb:	5f                   	pop    %edi
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ee:	f6 c1 03             	test   $0x3,%cl
  8009f1:	75 f2                	jne    8009e5 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009f3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009f6:	89 c7                	mov    %eax,%edi
  8009f8:	fc                   	cld    
  8009f9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fb:	eb ed                	jmp    8009ea <memmove+0x55>

008009fd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a00:	ff 75 10             	pushl  0x10(%ebp)
  800a03:	ff 75 0c             	pushl  0xc(%ebp)
  800a06:	ff 75 08             	pushl  0x8(%ebp)
  800a09:	e8 87 ff ff ff       	call   800995 <memmove>
}
  800a0e:	c9                   	leave  
  800a0f:	c3                   	ret    

00800a10 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
  800a15:	8b 45 08             	mov    0x8(%ebp),%eax
  800a18:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1b:	89 c6                	mov    %eax,%esi
  800a1d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a20:	39 f0                	cmp    %esi,%eax
  800a22:	74 1c                	je     800a40 <memcmp+0x30>
		if (*s1 != *s2)
  800a24:	0f b6 08             	movzbl (%eax),%ecx
  800a27:	0f b6 1a             	movzbl (%edx),%ebx
  800a2a:	38 d9                	cmp    %bl,%cl
  800a2c:	75 08                	jne    800a36 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a2e:	83 c0 01             	add    $0x1,%eax
  800a31:	83 c2 01             	add    $0x1,%edx
  800a34:	eb ea                	jmp    800a20 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a36:	0f b6 c1             	movzbl %cl,%eax
  800a39:	0f b6 db             	movzbl %bl,%ebx
  800a3c:	29 d8                	sub    %ebx,%eax
  800a3e:	eb 05                	jmp    800a45 <memcmp+0x35>
	}

	return 0;
  800a40:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a45:	5b                   	pop    %ebx
  800a46:	5e                   	pop    %esi
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a52:	89 c2                	mov    %eax,%edx
  800a54:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a57:	39 d0                	cmp    %edx,%eax
  800a59:	73 09                	jae    800a64 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5b:	38 08                	cmp    %cl,(%eax)
  800a5d:	74 05                	je     800a64 <memfind+0x1b>
	for (; s < ends; s++)
  800a5f:	83 c0 01             	add    $0x1,%eax
  800a62:	eb f3                	jmp    800a57 <memfind+0xe>
			break;
	return (void *) s;
}
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	57                   	push   %edi
  800a6a:	56                   	push   %esi
  800a6b:	53                   	push   %ebx
  800a6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a72:	eb 03                	jmp    800a77 <strtol+0x11>
		s++;
  800a74:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a77:	0f b6 01             	movzbl (%ecx),%eax
  800a7a:	3c 20                	cmp    $0x20,%al
  800a7c:	74 f6                	je     800a74 <strtol+0xe>
  800a7e:	3c 09                	cmp    $0x9,%al
  800a80:	74 f2                	je     800a74 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a82:	3c 2b                	cmp    $0x2b,%al
  800a84:	74 2e                	je     800ab4 <strtol+0x4e>
	int neg = 0;
  800a86:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a8b:	3c 2d                	cmp    $0x2d,%al
  800a8d:	74 2f                	je     800abe <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a95:	75 05                	jne    800a9c <strtol+0x36>
  800a97:	80 39 30             	cmpb   $0x30,(%ecx)
  800a9a:	74 2c                	je     800ac8 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a9c:	85 db                	test   %ebx,%ebx
  800a9e:	75 0a                	jne    800aaa <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa0:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800aa5:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa8:	74 28                	je     800ad2 <strtol+0x6c>
		base = 10;
  800aaa:	b8 00 00 00 00       	mov    $0x0,%eax
  800aaf:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ab2:	eb 50                	jmp    800b04 <strtol+0x9e>
		s++;
  800ab4:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ab7:	bf 00 00 00 00       	mov    $0x0,%edi
  800abc:	eb d1                	jmp    800a8f <strtol+0x29>
		s++, neg = 1;
  800abe:	83 c1 01             	add    $0x1,%ecx
  800ac1:	bf 01 00 00 00       	mov    $0x1,%edi
  800ac6:	eb c7                	jmp    800a8f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800acc:	74 0e                	je     800adc <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ace:	85 db                	test   %ebx,%ebx
  800ad0:	75 d8                	jne    800aaa <strtol+0x44>
		s++, base = 8;
  800ad2:	83 c1 01             	add    $0x1,%ecx
  800ad5:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ada:	eb ce                	jmp    800aaa <strtol+0x44>
		s += 2, base = 16;
  800adc:	83 c1 02             	add    $0x2,%ecx
  800adf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ae4:	eb c4                	jmp    800aaa <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ae6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae9:	89 f3                	mov    %esi,%ebx
  800aeb:	80 fb 19             	cmp    $0x19,%bl
  800aee:	77 29                	ja     800b19 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800af0:	0f be d2             	movsbl %dl,%edx
  800af3:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800af6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800af9:	7d 30                	jge    800b2b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800afb:	83 c1 01             	add    $0x1,%ecx
  800afe:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b02:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b04:	0f b6 11             	movzbl (%ecx),%edx
  800b07:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b0a:	89 f3                	mov    %esi,%ebx
  800b0c:	80 fb 09             	cmp    $0x9,%bl
  800b0f:	77 d5                	ja     800ae6 <strtol+0x80>
			dig = *s - '0';
  800b11:	0f be d2             	movsbl %dl,%edx
  800b14:	83 ea 30             	sub    $0x30,%edx
  800b17:	eb dd                	jmp    800af6 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b19:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b1c:	89 f3                	mov    %esi,%ebx
  800b1e:	80 fb 19             	cmp    $0x19,%bl
  800b21:	77 08                	ja     800b2b <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b23:	0f be d2             	movsbl %dl,%edx
  800b26:	83 ea 37             	sub    $0x37,%edx
  800b29:	eb cb                	jmp    800af6 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b2b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b2f:	74 05                	je     800b36 <strtol+0xd0>
		*endptr = (char *) s;
  800b31:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b34:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b36:	89 c2                	mov    %eax,%edx
  800b38:	f7 da                	neg    %edx
  800b3a:	85 ff                	test   %edi,%edi
  800b3c:	0f 45 c2             	cmovne %edx,%eax
}
  800b3f:	5b                   	pop    %ebx
  800b40:	5e                   	pop    %esi
  800b41:	5f                   	pop    %edi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b55:	89 c3                	mov    %eax,%ebx
  800b57:	89 c7                	mov    %eax,%edi
  800b59:	89 c6                	mov    %eax,%esi
  800b5b:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b68:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b72:	89 d1                	mov    %edx,%ecx
  800b74:	89 d3                	mov    %edx,%ebx
  800b76:	89 d7                	mov    %edx,%edi
  800b78:	89 d6                	mov    %edx,%esi
  800b7a:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	57                   	push   %edi
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
  800b87:	83 ec 1c             	sub    $0x1c,%esp
  800b8a:	e8 66 00 00 00       	call   800bf5 <__x86.get_pc_thunk.ax>
  800b8f:	05 71 14 00 00       	add    $0x1471,%eax
  800b94:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800b97:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9f:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba4:	89 cb                	mov    %ecx,%ebx
  800ba6:	89 cf                	mov    %ecx,%edi
  800ba8:	89 ce                	mov    %ecx,%esi
  800baa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bac:	85 c0                	test   %eax,%eax
  800bae:	7f 08                	jg     800bb8 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb8:	83 ec 0c             	sub    $0xc,%esp
  800bbb:	50                   	push   %eax
  800bbc:	6a 03                	push   $0x3
  800bbe:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800bc1:	8d 83 b0 f0 ff ff    	lea    -0xf50(%ebx),%eax
  800bc7:	50                   	push   %eax
  800bc8:	6a 23                	push   $0x23
  800bca:	8d 83 cd f0 ff ff    	lea    -0xf33(%ebx),%eax
  800bd0:	50                   	push   %eax
  800bd1:	e8 23 00 00 00       	call   800bf9 <_panic>

00800bd6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800be1:	b8 02 00 00 00       	mov    $0x2,%eax
  800be6:	89 d1                	mov    %edx,%ecx
  800be8:	89 d3                	mov    %edx,%ebx
  800bea:	89 d7                	mov    %edx,%edi
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <__x86.get_pc_thunk.ax>:
  800bf5:	8b 04 24             	mov    (%esp),%eax
  800bf8:	c3                   	ret    

00800bf9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
  800bff:	83 ec 0c             	sub    $0xc,%esp
  800c02:	e8 6d f4 ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800c07:	81 c3 f9 13 00 00    	add    $0x13f9,%ebx
	va_list ap;

	va_start(ap, fmt);
  800c0d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c10:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800c16:	8b 38                	mov    (%eax),%edi
  800c18:	e8 b9 ff ff ff       	call   800bd6 <sys_getenvid>
  800c1d:	83 ec 0c             	sub    $0xc,%esp
  800c20:	ff 75 0c             	pushl  0xc(%ebp)
  800c23:	ff 75 08             	pushl  0x8(%ebp)
  800c26:	57                   	push   %edi
  800c27:	50                   	push   %eax
  800c28:	8d 83 dc f0 ff ff    	lea    -0xf24(%ebx),%eax
  800c2e:	50                   	push   %eax
  800c2f:	e8 74 f5 ff ff       	call   8001a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c34:	83 c4 18             	add    $0x18,%esp
  800c37:	56                   	push   %esi
  800c38:	ff 75 10             	pushl  0x10(%ebp)
  800c3b:	e8 06 f5 ff ff       	call   800146 <vcprintf>
	cprintf("\n");
  800c40:	8d 83 a8 ee ff ff    	lea    -0x1158(%ebx),%eax
  800c46:	89 04 24             	mov    %eax,(%esp)
  800c49:	e8 5a f5 ff ff       	call   8001a8 <cprintf>
  800c4e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c51:	cc                   	int3   
  800c52:	eb fd                	jmp    800c51 <_panic+0x58>
  800c54:	66 90                	xchg   %ax,%ax
  800c56:	66 90                	xchg   %ax,%ax
  800c58:	66 90                	xchg   %ax,%ax
  800c5a:	66 90                	xchg   %ax,%ax
  800c5c:	66 90                	xchg   %ax,%ax
  800c5e:	66 90                	xchg   %ax,%ax

00800c60 <__udivdi3>:
  800c60:	55                   	push   %ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
  800c64:	83 ec 1c             	sub    $0x1c,%esp
  800c67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c6b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c73:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c77:	85 d2                	test   %edx,%edx
  800c79:	75 35                	jne    800cb0 <__udivdi3+0x50>
  800c7b:	39 f3                	cmp    %esi,%ebx
  800c7d:	0f 87 bd 00 00 00    	ja     800d40 <__udivdi3+0xe0>
  800c83:	85 db                	test   %ebx,%ebx
  800c85:	89 d9                	mov    %ebx,%ecx
  800c87:	75 0b                	jne    800c94 <__udivdi3+0x34>
  800c89:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8e:	31 d2                	xor    %edx,%edx
  800c90:	f7 f3                	div    %ebx
  800c92:	89 c1                	mov    %eax,%ecx
  800c94:	31 d2                	xor    %edx,%edx
  800c96:	89 f0                	mov    %esi,%eax
  800c98:	f7 f1                	div    %ecx
  800c9a:	89 c6                	mov    %eax,%esi
  800c9c:	89 e8                	mov    %ebp,%eax
  800c9e:	89 f7                	mov    %esi,%edi
  800ca0:	f7 f1                	div    %ecx
  800ca2:	89 fa                	mov    %edi,%edx
  800ca4:	83 c4 1c             	add    $0x1c,%esp
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    
  800cac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cb0:	39 f2                	cmp    %esi,%edx
  800cb2:	77 7c                	ja     800d30 <__udivdi3+0xd0>
  800cb4:	0f bd fa             	bsr    %edx,%edi
  800cb7:	83 f7 1f             	xor    $0x1f,%edi
  800cba:	0f 84 98 00 00 00    	je     800d58 <__udivdi3+0xf8>
  800cc0:	89 f9                	mov    %edi,%ecx
  800cc2:	b8 20 00 00 00       	mov    $0x20,%eax
  800cc7:	29 f8                	sub    %edi,%eax
  800cc9:	d3 e2                	shl    %cl,%edx
  800ccb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ccf:	89 c1                	mov    %eax,%ecx
  800cd1:	89 da                	mov    %ebx,%edx
  800cd3:	d3 ea                	shr    %cl,%edx
  800cd5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800cd9:	09 d1                	or     %edx,%ecx
  800cdb:	89 f2                	mov    %esi,%edx
  800cdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ce1:	89 f9                	mov    %edi,%ecx
  800ce3:	d3 e3                	shl    %cl,%ebx
  800ce5:	89 c1                	mov    %eax,%ecx
  800ce7:	d3 ea                	shr    %cl,%edx
  800ce9:	89 f9                	mov    %edi,%ecx
  800ceb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800cef:	d3 e6                	shl    %cl,%esi
  800cf1:	89 eb                	mov    %ebp,%ebx
  800cf3:	89 c1                	mov    %eax,%ecx
  800cf5:	d3 eb                	shr    %cl,%ebx
  800cf7:	09 de                	or     %ebx,%esi
  800cf9:	89 f0                	mov    %esi,%eax
  800cfb:	f7 74 24 08          	divl   0x8(%esp)
  800cff:	89 d6                	mov    %edx,%esi
  800d01:	89 c3                	mov    %eax,%ebx
  800d03:	f7 64 24 0c          	mull   0xc(%esp)
  800d07:	39 d6                	cmp    %edx,%esi
  800d09:	72 0c                	jb     800d17 <__udivdi3+0xb7>
  800d0b:	89 f9                	mov    %edi,%ecx
  800d0d:	d3 e5                	shl    %cl,%ebp
  800d0f:	39 c5                	cmp    %eax,%ebp
  800d11:	73 5d                	jae    800d70 <__udivdi3+0x110>
  800d13:	39 d6                	cmp    %edx,%esi
  800d15:	75 59                	jne    800d70 <__udivdi3+0x110>
  800d17:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d1a:	31 ff                	xor    %edi,%edi
  800d1c:	89 fa                	mov    %edi,%edx
  800d1e:	83 c4 1c             	add    $0x1c,%esp
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    
  800d26:	8d 76 00             	lea    0x0(%esi),%esi
  800d29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d30:	31 ff                	xor    %edi,%edi
  800d32:	31 c0                	xor    %eax,%eax
  800d34:	89 fa                	mov    %edi,%edx
  800d36:	83 c4 1c             	add    $0x1c,%esp
  800d39:	5b                   	pop    %ebx
  800d3a:	5e                   	pop    %esi
  800d3b:	5f                   	pop    %edi
  800d3c:	5d                   	pop    %ebp
  800d3d:	c3                   	ret    
  800d3e:	66 90                	xchg   %ax,%ax
  800d40:	31 ff                	xor    %edi,%edi
  800d42:	89 e8                	mov    %ebp,%eax
  800d44:	89 f2                	mov    %esi,%edx
  800d46:	f7 f3                	div    %ebx
  800d48:	89 fa                	mov    %edi,%edx
  800d4a:	83 c4 1c             	add    $0x1c,%esp
  800d4d:	5b                   	pop    %ebx
  800d4e:	5e                   	pop    %esi
  800d4f:	5f                   	pop    %edi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    
  800d52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d58:	39 f2                	cmp    %esi,%edx
  800d5a:	72 06                	jb     800d62 <__udivdi3+0x102>
  800d5c:	31 c0                	xor    %eax,%eax
  800d5e:	39 eb                	cmp    %ebp,%ebx
  800d60:	77 d2                	ja     800d34 <__udivdi3+0xd4>
  800d62:	b8 01 00 00 00       	mov    $0x1,%eax
  800d67:	eb cb                	jmp    800d34 <__udivdi3+0xd4>
  800d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d70:	89 d8                	mov    %ebx,%eax
  800d72:	31 ff                	xor    %edi,%edi
  800d74:	eb be                	jmp    800d34 <__udivdi3+0xd4>
  800d76:	66 90                	xchg   %ax,%ax
  800d78:	66 90                	xchg   %ax,%ax
  800d7a:	66 90                	xchg   %ax,%ax
  800d7c:	66 90                	xchg   %ax,%ax
  800d7e:	66 90                	xchg   %ax,%ax

00800d80 <__umoddi3>:
  800d80:	55                   	push   %ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
  800d84:	83 ec 1c             	sub    $0x1c,%esp
  800d87:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800d8b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d8f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d97:	85 ed                	test   %ebp,%ebp
  800d99:	89 f0                	mov    %esi,%eax
  800d9b:	89 da                	mov    %ebx,%edx
  800d9d:	75 19                	jne    800db8 <__umoddi3+0x38>
  800d9f:	39 df                	cmp    %ebx,%edi
  800da1:	0f 86 b1 00 00 00    	jbe    800e58 <__umoddi3+0xd8>
  800da7:	f7 f7                	div    %edi
  800da9:	89 d0                	mov    %edx,%eax
  800dab:	31 d2                	xor    %edx,%edx
  800dad:	83 c4 1c             	add    $0x1c,%esp
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    
  800db5:	8d 76 00             	lea    0x0(%esi),%esi
  800db8:	39 dd                	cmp    %ebx,%ebp
  800dba:	77 f1                	ja     800dad <__umoddi3+0x2d>
  800dbc:	0f bd cd             	bsr    %ebp,%ecx
  800dbf:	83 f1 1f             	xor    $0x1f,%ecx
  800dc2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800dc6:	0f 84 b4 00 00 00    	je     800e80 <__umoddi3+0x100>
  800dcc:	b8 20 00 00 00       	mov    $0x20,%eax
  800dd1:	89 c2                	mov    %eax,%edx
  800dd3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dd7:	29 c2                	sub    %eax,%edx
  800dd9:	89 c1                	mov    %eax,%ecx
  800ddb:	89 f8                	mov    %edi,%eax
  800ddd:	d3 e5                	shl    %cl,%ebp
  800ddf:	89 d1                	mov    %edx,%ecx
  800de1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800de5:	d3 e8                	shr    %cl,%eax
  800de7:	09 c5                	or     %eax,%ebp
  800de9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ded:	89 c1                	mov    %eax,%ecx
  800def:	d3 e7                	shl    %cl,%edi
  800df1:	89 d1                	mov    %edx,%ecx
  800df3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800df7:	89 df                	mov    %ebx,%edi
  800df9:	d3 ef                	shr    %cl,%edi
  800dfb:	89 c1                	mov    %eax,%ecx
  800dfd:	89 f0                	mov    %esi,%eax
  800dff:	d3 e3                	shl    %cl,%ebx
  800e01:	89 d1                	mov    %edx,%ecx
  800e03:	89 fa                	mov    %edi,%edx
  800e05:	d3 e8                	shr    %cl,%eax
  800e07:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e0c:	09 d8                	or     %ebx,%eax
  800e0e:	f7 f5                	div    %ebp
  800e10:	d3 e6                	shl    %cl,%esi
  800e12:	89 d1                	mov    %edx,%ecx
  800e14:	f7 64 24 08          	mull   0x8(%esp)
  800e18:	39 d1                	cmp    %edx,%ecx
  800e1a:	89 c3                	mov    %eax,%ebx
  800e1c:	89 d7                	mov    %edx,%edi
  800e1e:	72 06                	jb     800e26 <__umoddi3+0xa6>
  800e20:	75 0e                	jne    800e30 <__umoddi3+0xb0>
  800e22:	39 c6                	cmp    %eax,%esi
  800e24:	73 0a                	jae    800e30 <__umoddi3+0xb0>
  800e26:	2b 44 24 08          	sub    0x8(%esp),%eax
  800e2a:	19 ea                	sbb    %ebp,%edx
  800e2c:	89 d7                	mov    %edx,%edi
  800e2e:	89 c3                	mov    %eax,%ebx
  800e30:	89 ca                	mov    %ecx,%edx
  800e32:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e37:	29 de                	sub    %ebx,%esi
  800e39:	19 fa                	sbb    %edi,%edx
  800e3b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800e3f:	89 d0                	mov    %edx,%eax
  800e41:	d3 e0                	shl    %cl,%eax
  800e43:	89 d9                	mov    %ebx,%ecx
  800e45:	d3 ee                	shr    %cl,%esi
  800e47:	d3 ea                	shr    %cl,%edx
  800e49:	09 f0                	or     %esi,%eax
  800e4b:	83 c4 1c             	add    $0x1c,%esp
  800e4e:	5b                   	pop    %ebx
  800e4f:	5e                   	pop    %esi
  800e50:	5f                   	pop    %edi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    
  800e53:	90                   	nop
  800e54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e58:	85 ff                	test   %edi,%edi
  800e5a:	89 f9                	mov    %edi,%ecx
  800e5c:	75 0b                	jne    800e69 <__umoddi3+0xe9>
  800e5e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e63:	31 d2                	xor    %edx,%edx
  800e65:	f7 f7                	div    %edi
  800e67:	89 c1                	mov    %eax,%ecx
  800e69:	89 d8                	mov    %ebx,%eax
  800e6b:	31 d2                	xor    %edx,%edx
  800e6d:	f7 f1                	div    %ecx
  800e6f:	89 f0                	mov    %esi,%eax
  800e71:	f7 f1                	div    %ecx
  800e73:	e9 31 ff ff ff       	jmp    800da9 <__umoddi3+0x29>
  800e78:	90                   	nop
  800e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e80:	39 dd                	cmp    %ebx,%ebp
  800e82:	72 08                	jb     800e8c <__umoddi3+0x10c>
  800e84:	39 f7                	cmp    %esi,%edi
  800e86:	0f 87 21 ff ff ff    	ja     800dad <__umoddi3+0x2d>
  800e8c:	89 da                	mov    %ebx,%edx
  800e8e:	89 f0                	mov    %esi,%eax
  800e90:	29 f8                	sub    %edi,%eax
  800e92:	19 ea                	sbb    %ebp,%edx
  800e94:	e9 14 ff ff ff       	jmp    800dad <__umoddi3+0x2d>
