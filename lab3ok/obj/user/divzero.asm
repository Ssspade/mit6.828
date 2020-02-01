
obj/user/divzero：     文件格式 elf32-i386


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
  80002c:	e8 46 00 00 00       	call   800077 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 34 00 00 00       	call   800073 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	zero = 0;
  800045:	c7 c0 2c 20 80 00    	mov    $0x80202c,%eax
  80004b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	cprintf("1/0 is %08x!\n", 1/zero);
  800051:	b8 01 00 00 00       	mov    $0x1,%eax
  800056:	b9 00 00 00 00       	mov    $0x0,%ecx
  80005b:	99                   	cltd   
  80005c:	f7 f9                	idiv   %ecx
  80005e:	50                   	push   %eax
  80005f:	8d 83 9c ee ff ff    	lea    -0x1164(%ebx),%eax
  800065:	50                   	push   %eax
  800066:	e8 3c 01 00 00       	call   8001a7 <cprintf>
}
  80006b:	83 c4 10             	add    $0x10,%esp
  80006e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800071:	c9                   	leave  
  800072:	c3                   	ret    

00800073 <__x86.get_pc_thunk.bx>:
  800073:	8b 1c 24             	mov    (%esp),%ebx
  800076:	c3                   	ret    

00800077 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800077:	55                   	push   %ebp
  800078:	89 e5                	mov    %esp,%ebp
  80007a:	57                   	push   %edi
  80007b:	56                   	push   %esi
  80007c:	53                   	push   %ebx
  80007d:	83 ec 0c             	sub    $0xc,%esp
  800080:	e8 ee ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  800085:	81 c3 7b 1f 00 00    	add    $0x1f7b,%ebx
  80008b:	8b 75 08             	mov    0x8(%ebp),%esi
  80008e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800091:	e8 3f 0b 00 00       	call   800bd5 <sys_getenvid>
  800096:	25 ff 03 00 00       	and    $0x3ff,%eax
  80009b:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80009e:	c1 e0 05             	shl    $0x5,%eax
  8000a1:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  8000a7:	c7 c2 30 20 80 00    	mov    $0x802030,%edx
  8000ad:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000af:	85 f6                	test   %esi,%esi
  8000b1:	7e 08                	jle    8000bb <libmain+0x44>
		binaryname = argv[0];
  8000b3:	8b 07                	mov    (%edi),%eax
  8000b5:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000bb:	83 ec 08             	sub    $0x8,%esp
  8000be:	57                   	push   %edi
  8000bf:	56                   	push   %esi
  8000c0:	e8 6e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000c5:	e8 0b 00 00 00       	call   8000d5 <exit>
}
  8000ca:	83 c4 10             	add    $0x10,%esp
  8000cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d0:	5b                   	pop    %ebx
  8000d1:	5e                   	pop    %esi
  8000d2:	5f                   	pop    %edi
  8000d3:	5d                   	pop    %ebp
  8000d4:	c3                   	ret    

008000d5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d5:	55                   	push   %ebp
  8000d6:	89 e5                	mov    %esp,%ebp
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 10             	sub    $0x10,%esp
  8000dc:	e8 92 ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  8000e1:	81 c3 1f 1f 00 00    	add    $0x1f1f,%ebx
	sys_env_destroy(0);
  8000e7:	6a 00                	push   $0x0
  8000e9:	e8 92 0a 00 00       	call   800b80 <sys_env_destroy>
}
  8000ee:	83 c4 10             	add    $0x10,%esp
  8000f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f4:	c9                   	leave  
  8000f5:	c3                   	ret    

008000f6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f6:	55                   	push   %ebp
  8000f7:	89 e5                	mov    %esp,%ebp
  8000f9:	56                   	push   %esi
  8000fa:	53                   	push   %ebx
  8000fb:	e8 73 ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  800100:	81 c3 00 1f 00 00    	add    $0x1f00,%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  800109:	8b 16                	mov    (%esi),%edx
  80010b:	8d 42 01             	lea    0x1(%edx),%eax
  80010e:	89 06                	mov    %eax,(%esi)
  800110:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800113:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800117:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011c:	74 0b                	je     800129 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80011e:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800122:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5d                   	pop    %ebp
  800128:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800129:	83 ec 08             	sub    $0x8,%esp
  80012c:	68 ff 00 00 00       	push   $0xff
  800131:	8d 46 08             	lea    0x8(%esi),%eax
  800134:	50                   	push   %eax
  800135:	e8 09 0a 00 00       	call   800b43 <sys_cputs>
		b->idx = 0;
  80013a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800140:	83 c4 10             	add    $0x10,%esp
  800143:	eb d9                	jmp    80011e <putch+0x28>

00800145 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	53                   	push   %ebx
  800149:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80014f:	e8 1f ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  800154:	81 c3 ac 1e 00 00    	add    $0x1eac,%ebx
	struct printbuf b;

	b.idx = 0;
  80015a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800161:	00 00 00 
	b.cnt = 0;
  800164:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80017a:	50                   	push   %eax
  80017b:	8d 83 f6 e0 ff ff    	lea    -0x1f0a(%ebx),%eax
  800181:	50                   	push   %eax
  800182:	e8 38 01 00 00       	call   8002bf <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800187:	83 c4 08             	add    $0x8,%esp
  80018a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800190:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800196:	50                   	push   %eax
  800197:	e8 a7 09 00 00       	call   800b43 <sys_cputs>

	return b.cnt;
}
  80019c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ad:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b0:	50                   	push   %eax
  8001b1:	ff 75 08             	pushl  0x8(%ebp)
  8001b4:	e8 8c ff ff ff       	call   800145 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	57                   	push   %edi
  8001bf:	56                   	push   %esi
  8001c0:	53                   	push   %ebx
  8001c1:	83 ec 2c             	sub    $0x2c,%esp
  8001c4:	e8 02 06 00 00       	call   8007cb <__x86.get_pc_thunk.cx>
  8001c9:	81 c1 37 1e 00 00    	add    $0x1e37,%ecx
  8001cf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001d2:	89 c7                	mov    %eax,%edi
  8001d4:	89 d6                	mov    %edx,%esi
  8001d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001dc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001df:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ea:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8001ed:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8001f0:	39 d3                	cmp    %edx,%ebx
  8001f2:	72 09                	jb     8001fd <printnum+0x42>
  8001f4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f7:	0f 87 83 00 00 00    	ja     800280 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fd:	83 ec 0c             	sub    $0xc,%esp
  800200:	ff 75 18             	pushl  0x18(%ebp)
  800203:	8b 45 14             	mov    0x14(%ebp),%eax
  800206:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800209:	53                   	push   %ebx
  80020a:	ff 75 10             	pushl  0x10(%ebp)
  80020d:	83 ec 08             	sub    $0x8,%esp
  800210:	ff 75 dc             	pushl  -0x24(%ebp)
  800213:	ff 75 d8             	pushl  -0x28(%ebp)
  800216:	ff 75 d4             	pushl  -0x2c(%ebp)
  800219:	ff 75 d0             	pushl  -0x30(%ebp)
  80021c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80021f:	e8 3c 0a 00 00       	call   800c60 <__udivdi3>
  800224:	83 c4 18             	add    $0x18,%esp
  800227:	52                   	push   %edx
  800228:	50                   	push   %eax
  800229:	89 f2                	mov    %esi,%edx
  80022b:	89 f8                	mov    %edi,%eax
  80022d:	e8 89 ff ff ff       	call   8001bb <printnum>
  800232:	83 c4 20             	add    $0x20,%esp
  800235:	eb 13                	jmp    80024a <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800237:	83 ec 08             	sub    $0x8,%esp
  80023a:	56                   	push   %esi
  80023b:	ff 75 18             	pushl  0x18(%ebp)
  80023e:	ff d7                	call   *%edi
  800240:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800243:	83 eb 01             	sub    $0x1,%ebx
  800246:	85 db                	test   %ebx,%ebx
  800248:	7f ed                	jg     800237 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024a:	83 ec 08             	sub    $0x8,%esp
  80024d:	56                   	push   %esi
  80024e:	83 ec 04             	sub    $0x4,%esp
  800251:	ff 75 dc             	pushl  -0x24(%ebp)
  800254:	ff 75 d8             	pushl  -0x28(%ebp)
  800257:	ff 75 d4             	pushl  -0x2c(%ebp)
  80025a:	ff 75 d0             	pushl  -0x30(%ebp)
  80025d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800260:	89 f3                	mov    %esi,%ebx
  800262:	e8 19 0b 00 00       	call   800d80 <__umoddi3>
  800267:	83 c4 14             	add    $0x14,%esp
  80026a:	0f be 84 06 b4 ee ff 	movsbl -0x114c(%esi,%eax,1),%eax
  800271:	ff 
  800272:	50                   	push   %eax
  800273:	ff d7                	call   *%edi
}
  800275:	83 c4 10             	add    $0x10,%esp
  800278:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027b:	5b                   	pop    %ebx
  80027c:	5e                   	pop    %esi
  80027d:	5f                   	pop    %edi
  80027e:	5d                   	pop    %ebp
  80027f:	c3                   	ret    
  800280:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800283:	eb be                	jmp    800243 <printnum+0x88>

00800285 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
  800288:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80028f:	8b 10                	mov    (%eax),%edx
  800291:	3b 50 04             	cmp    0x4(%eax),%edx
  800294:	73 0a                	jae    8002a0 <sprintputch+0x1b>
		*b->buf++ = ch;
  800296:	8d 4a 01             	lea    0x1(%edx),%ecx
  800299:	89 08                	mov    %ecx,(%eax)
  80029b:	8b 45 08             	mov    0x8(%ebp),%eax
  80029e:	88 02                	mov    %al,(%edx)
}
  8002a0:	5d                   	pop    %ebp
  8002a1:	c3                   	ret    

008002a2 <printfmt>:
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002a8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ab:	50                   	push   %eax
  8002ac:	ff 75 10             	pushl  0x10(%ebp)
  8002af:	ff 75 0c             	pushl  0xc(%ebp)
  8002b2:	ff 75 08             	pushl  0x8(%ebp)
  8002b5:	e8 05 00 00 00       	call   8002bf <vprintfmt>
}
  8002ba:	83 c4 10             	add    $0x10,%esp
  8002bd:	c9                   	leave  
  8002be:	c3                   	ret    

008002bf <vprintfmt>:
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	57                   	push   %edi
  8002c3:	56                   	push   %esi
  8002c4:	53                   	push   %ebx
  8002c5:	83 ec 2c             	sub    $0x2c,%esp
  8002c8:	e8 a6 fd ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  8002cd:	81 c3 33 1d 00 00    	add    $0x1d33,%ebx
  8002d3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002d6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d9:	e9 c3 03 00 00       	jmp    8006a1 <.L35+0x48>
		padc = ' ';
  8002de:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002e2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002e9:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8002f0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002fc:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002ff:	8d 47 01             	lea    0x1(%edi),%eax
  800302:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800305:	0f b6 17             	movzbl (%edi),%edx
  800308:	8d 42 dd             	lea    -0x23(%edx),%eax
  80030b:	3c 55                	cmp    $0x55,%al
  80030d:	0f 87 16 04 00 00    	ja     800729 <.L22>
  800313:	0f b6 c0             	movzbl %al,%eax
  800316:	89 d9                	mov    %ebx,%ecx
  800318:	03 8c 83 44 ef ff ff 	add    -0x10bc(%ebx,%eax,4),%ecx
  80031f:	ff e1                	jmp    *%ecx

00800321 <.L69>:
  800321:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800324:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800328:	eb d5                	jmp    8002ff <vprintfmt+0x40>

0080032a <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80032d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800331:	eb cc                	jmp    8002ff <vprintfmt+0x40>

00800333 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  800333:	0f b6 d2             	movzbl %dl,%edx
  800336:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800339:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  80033e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800341:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800345:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800348:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80034b:	83 f9 09             	cmp    $0x9,%ecx
  80034e:	77 55                	ja     8003a5 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  800350:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800353:	eb e9                	jmp    80033e <.L29+0xb>

00800355 <.L26>:
			precision = va_arg(ap, int);
  800355:	8b 45 14             	mov    0x14(%ebp),%eax
  800358:	8b 00                	mov    (%eax),%eax
  80035a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80035d:	8b 45 14             	mov    0x14(%ebp),%eax
  800360:	8d 40 04             	lea    0x4(%eax),%eax
  800363:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800369:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80036d:	79 90                	jns    8002ff <vprintfmt+0x40>
				width = precision, precision = -1;
  80036f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800372:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800375:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80037c:	eb 81                	jmp    8002ff <vprintfmt+0x40>

0080037e <.L27>:
  80037e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800381:	85 c0                	test   %eax,%eax
  800383:	ba 00 00 00 00       	mov    $0x0,%edx
  800388:	0f 49 d0             	cmovns %eax,%edx
  80038b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800391:	e9 69 ff ff ff       	jmp    8002ff <vprintfmt+0x40>

00800396 <.L23>:
  800396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800399:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a0:	e9 5a ff ff ff       	jmp    8002ff <vprintfmt+0x40>
  8003a5:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003a8:	eb bf                	jmp    800369 <.L26+0x14>

008003aa <.L33>:
			lflag++;
  8003aa:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003b1:	e9 49 ff ff ff       	jmp    8002ff <vprintfmt+0x40>

008003b6 <.L30>:
			putch(va_arg(ap, int), putdat);
  8003b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b9:	8d 78 04             	lea    0x4(%eax),%edi
  8003bc:	83 ec 08             	sub    $0x8,%esp
  8003bf:	56                   	push   %esi
  8003c0:	ff 30                	pushl  (%eax)
  8003c2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003c5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003c8:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003cb:	e9 ce 02 00 00       	jmp    80069e <.L35+0x45>

008003d0 <.L32>:
			err = va_arg(ap, int);
  8003d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d3:	8d 78 04             	lea    0x4(%eax),%edi
  8003d6:	8b 00                	mov    (%eax),%eax
  8003d8:	99                   	cltd   
  8003d9:	31 d0                	xor    %edx,%eax
  8003db:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003dd:	83 f8 06             	cmp    $0x6,%eax
  8003e0:	7f 27                	jg     800409 <.L32+0x39>
  8003e2:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8003e9:	85 d2                	test   %edx,%edx
  8003eb:	74 1c                	je     800409 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8003ed:	52                   	push   %edx
  8003ee:	8d 83 d5 ee ff ff    	lea    -0x112b(%ebx),%eax
  8003f4:	50                   	push   %eax
  8003f5:	56                   	push   %esi
  8003f6:	ff 75 08             	pushl  0x8(%ebp)
  8003f9:	e8 a4 fe ff ff       	call   8002a2 <printfmt>
  8003fe:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800401:	89 7d 14             	mov    %edi,0x14(%ebp)
  800404:	e9 95 02 00 00       	jmp    80069e <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  800409:	50                   	push   %eax
  80040a:	8d 83 cc ee ff ff    	lea    -0x1134(%ebx),%eax
  800410:	50                   	push   %eax
  800411:	56                   	push   %esi
  800412:	ff 75 08             	pushl  0x8(%ebp)
  800415:	e8 88 fe ff ff       	call   8002a2 <printfmt>
  80041a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80041d:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800420:	e9 79 02 00 00       	jmp    80069e <.L35+0x45>

00800425 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800425:	8b 45 14             	mov    0x14(%ebp),%eax
  800428:	83 c0 04             	add    $0x4,%eax
  80042b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800433:	85 ff                	test   %edi,%edi
  800435:	8d 83 c5 ee ff ff    	lea    -0x113b(%ebx),%eax
  80043b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80043e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800442:	0f 8e b5 00 00 00    	jle    8004fd <.L36+0xd8>
  800448:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80044c:	75 08                	jne    800456 <.L36+0x31>
  80044e:	89 75 0c             	mov    %esi,0xc(%ebp)
  800451:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800454:	eb 6d                	jmp    8004c3 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800456:	83 ec 08             	sub    $0x8,%esp
  800459:	ff 75 cc             	pushl  -0x34(%ebp)
  80045c:	57                   	push   %edi
  80045d:	e8 85 03 00 00       	call   8007e7 <strnlen>
  800462:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800465:	29 c2                	sub    %eax,%edx
  800467:	89 55 c8             	mov    %edx,-0x38(%ebp)
  80046a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80046d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800471:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800474:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800477:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800479:	eb 10                	jmp    80048b <.L36+0x66>
					putch(padc, putdat);
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	56                   	push   %esi
  80047f:	ff 75 e0             	pushl  -0x20(%ebp)
  800482:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800485:	83 ef 01             	sub    $0x1,%edi
  800488:	83 c4 10             	add    $0x10,%esp
  80048b:	85 ff                	test   %edi,%edi
  80048d:	7f ec                	jg     80047b <.L36+0x56>
  80048f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800492:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800495:	85 d2                	test   %edx,%edx
  800497:	b8 00 00 00 00       	mov    $0x0,%eax
  80049c:	0f 49 c2             	cmovns %edx,%eax
  80049f:	29 c2                	sub    %eax,%edx
  8004a1:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004a4:	89 75 0c             	mov    %esi,0xc(%ebp)
  8004a7:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004aa:	eb 17                	jmp    8004c3 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ac:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b0:	75 30                	jne    8004e2 <.L36+0xbd>
					putch(ch, putdat);
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	ff 75 0c             	pushl  0xc(%ebp)
  8004b8:	50                   	push   %eax
  8004b9:	ff 55 08             	call   *0x8(%ebp)
  8004bc:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004bf:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8004c3:	83 c7 01             	add    $0x1,%edi
  8004c6:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004ca:	0f be c2             	movsbl %dl,%eax
  8004cd:	85 c0                	test   %eax,%eax
  8004cf:	74 52                	je     800523 <.L36+0xfe>
  8004d1:	85 f6                	test   %esi,%esi
  8004d3:	78 d7                	js     8004ac <.L36+0x87>
  8004d5:	83 ee 01             	sub    $0x1,%esi
  8004d8:	79 d2                	jns    8004ac <.L36+0x87>
  8004da:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004dd:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004e0:	eb 32                	jmp    800514 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8004e2:	0f be d2             	movsbl %dl,%edx
  8004e5:	83 ea 20             	sub    $0x20,%edx
  8004e8:	83 fa 5e             	cmp    $0x5e,%edx
  8004eb:	76 c5                	jbe    8004b2 <.L36+0x8d>
					putch('?', putdat);
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	ff 75 0c             	pushl  0xc(%ebp)
  8004f3:	6a 3f                	push   $0x3f
  8004f5:	ff 55 08             	call   *0x8(%ebp)
  8004f8:	83 c4 10             	add    $0x10,%esp
  8004fb:	eb c2                	jmp    8004bf <.L36+0x9a>
  8004fd:	89 75 0c             	mov    %esi,0xc(%ebp)
  800500:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800503:	eb be                	jmp    8004c3 <.L36+0x9e>
				putch(' ', putdat);
  800505:	83 ec 08             	sub    $0x8,%esp
  800508:	56                   	push   %esi
  800509:	6a 20                	push   $0x20
  80050b:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  80050e:	83 ef 01             	sub    $0x1,%edi
  800511:	83 c4 10             	add    $0x10,%esp
  800514:	85 ff                	test   %edi,%edi
  800516:	7f ed                	jg     800505 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  800518:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80051b:	89 45 14             	mov    %eax,0x14(%ebp)
  80051e:	e9 7b 01 00 00       	jmp    80069e <.L35+0x45>
  800523:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800526:	8b 75 0c             	mov    0xc(%ebp),%esi
  800529:	eb e9                	jmp    800514 <.L36+0xef>

0080052b <.L31>:
  80052b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80052e:	83 f9 01             	cmp    $0x1,%ecx
  800531:	7e 40                	jle    800573 <.L31+0x48>
		return va_arg(*ap, long long);
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8b 50 04             	mov    0x4(%eax),%edx
  800539:	8b 00                	mov    (%eax),%eax
  80053b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800541:	8b 45 14             	mov    0x14(%ebp),%eax
  800544:	8d 40 08             	lea    0x8(%eax),%eax
  800547:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80054a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80054e:	79 55                	jns    8005a5 <.L31+0x7a>
				putch('-', putdat);
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	56                   	push   %esi
  800554:	6a 2d                	push   $0x2d
  800556:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800559:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80055c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80055f:	f7 da                	neg    %edx
  800561:	83 d1 00             	adc    $0x0,%ecx
  800564:	f7 d9                	neg    %ecx
  800566:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800569:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056e:	e9 10 01 00 00       	jmp    800683 <.L35+0x2a>
	else if (lflag)
  800573:	85 c9                	test   %ecx,%ecx
  800575:	75 17                	jne    80058e <.L31+0x63>
		return va_arg(*ap, int);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057f:	99                   	cltd   
  800580:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8d 40 04             	lea    0x4(%eax),%eax
  800589:	89 45 14             	mov    %eax,0x14(%ebp)
  80058c:	eb bc                	jmp    80054a <.L31+0x1f>
		return va_arg(*ap, long);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8b 00                	mov    (%eax),%eax
  800593:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800596:	99                   	cltd   
  800597:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 40 04             	lea    0x4(%eax),%eax
  8005a0:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a3:	eb a5                	jmp    80054a <.L31+0x1f>
			num = getint(&ap, lflag);
  8005a5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005ab:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b0:	e9 ce 00 00 00       	jmp    800683 <.L35+0x2a>

008005b5 <.L37>:
  8005b5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8005b8:	83 f9 01             	cmp    $0x1,%ecx
  8005bb:	7e 18                	jle    8005d5 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8b 10                	mov    (%eax),%edx
  8005c2:	8b 48 04             	mov    0x4(%eax),%ecx
  8005c5:	8d 40 08             	lea    0x8(%eax),%eax
  8005c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005cb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d0:	e9 ae 00 00 00       	jmp    800683 <.L35+0x2a>
	else if (lflag)
  8005d5:	85 c9                	test   %ecx,%ecx
  8005d7:	75 1a                	jne    8005f3 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8b 10                	mov    (%eax),%edx
  8005de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e3:	8d 40 04             	lea    0x4(%eax),%eax
  8005e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ee:	e9 90 00 00 00       	jmp    800683 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8b 10                	mov    (%eax),%edx
  8005f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fd:	8d 40 04             	lea    0x4(%eax),%eax
  800600:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800603:	b8 0a 00 00 00       	mov    $0xa,%eax
  800608:	eb 79                	jmp    800683 <.L35+0x2a>

0080060a <.L34>:
  80060a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80060d:	83 f9 01             	cmp    $0x1,%ecx
  800610:	7e 15                	jle    800627 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8b 10                	mov    (%eax),%edx
  800617:	8b 48 04             	mov    0x4(%eax),%ecx
  80061a:	8d 40 08             	lea    0x8(%eax),%eax
  80061d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800620:	b8 08 00 00 00       	mov    $0x8,%eax
  800625:	eb 5c                	jmp    800683 <.L35+0x2a>
	else if (lflag)
  800627:	85 c9                	test   %ecx,%ecx
  800629:	75 17                	jne    800642 <.L34+0x38>
		return va_arg(*ap, unsigned int);
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8b 10                	mov    (%eax),%edx
  800630:	b9 00 00 00 00       	mov    $0x0,%ecx
  800635:	8d 40 04             	lea    0x4(%eax),%eax
  800638:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80063b:	b8 08 00 00 00       	mov    $0x8,%eax
  800640:	eb 41                	jmp    800683 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8b 10                	mov    (%eax),%edx
  800647:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064c:	8d 40 04             	lea    0x4(%eax),%eax
  80064f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800652:	b8 08 00 00 00       	mov    $0x8,%eax
  800657:	eb 2a                	jmp    800683 <.L35+0x2a>

00800659 <.L35>:
			putch('0', putdat);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	56                   	push   %esi
  80065d:	6a 30                	push   $0x30
  80065f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800662:	83 c4 08             	add    $0x8,%esp
  800665:	56                   	push   %esi
  800666:	6a 78                	push   $0x78
  800668:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8b 10                	mov    (%eax),%edx
  800670:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800675:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800678:	8d 40 04             	lea    0x4(%eax),%eax
  80067b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80067e:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800683:	83 ec 0c             	sub    $0xc,%esp
  800686:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80068a:	57                   	push   %edi
  80068b:	ff 75 e0             	pushl  -0x20(%ebp)
  80068e:	50                   	push   %eax
  80068f:	51                   	push   %ecx
  800690:	52                   	push   %edx
  800691:	89 f2                	mov    %esi,%edx
  800693:	8b 45 08             	mov    0x8(%ebp),%eax
  800696:	e8 20 fb ff ff       	call   8001bb <printnum>
			break;
  80069b:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80069e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006a1:	83 c7 01             	add    $0x1,%edi
  8006a4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006a8:	83 f8 25             	cmp    $0x25,%eax
  8006ab:	0f 84 2d fc ff ff    	je     8002de <vprintfmt+0x1f>
			if (ch == '\0')
  8006b1:	85 c0                	test   %eax,%eax
  8006b3:	0f 84 91 00 00 00    	je     80074a <.L22+0x21>
			putch(ch, putdat);
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	56                   	push   %esi
  8006bd:	50                   	push   %eax
  8006be:	ff 55 08             	call   *0x8(%ebp)
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	eb db                	jmp    8006a1 <.L35+0x48>

008006c6 <.L38>:
  8006c6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006c9:	83 f9 01             	cmp    $0x1,%ecx
  8006cc:	7e 15                	jle    8006e3 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8b 10                	mov    (%eax),%edx
  8006d3:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d6:	8d 40 08             	lea    0x8(%eax),%eax
  8006d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006dc:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e1:	eb a0                	jmp    800683 <.L35+0x2a>
	else if (lflag)
  8006e3:	85 c9                	test   %ecx,%ecx
  8006e5:	75 17                	jne    8006fe <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8b 10                	mov    (%eax),%edx
  8006ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f1:	8d 40 04             	lea    0x4(%eax),%eax
  8006f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f7:	b8 10 00 00 00       	mov    $0x10,%eax
  8006fc:	eb 85                	jmp    800683 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800701:	8b 10                	mov    (%eax),%edx
  800703:	b9 00 00 00 00       	mov    $0x0,%ecx
  800708:	8d 40 04             	lea    0x4(%eax),%eax
  80070b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070e:	b8 10 00 00 00       	mov    $0x10,%eax
  800713:	e9 6b ff ff ff       	jmp    800683 <.L35+0x2a>

00800718 <.L25>:
			putch(ch, putdat);
  800718:	83 ec 08             	sub    $0x8,%esp
  80071b:	56                   	push   %esi
  80071c:	6a 25                	push   $0x25
  80071e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800721:	83 c4 10             	add    $0x10,%esp
  800724:	e9 75 ff ff ff       	jmp    80069e <.L35+0x45>

00800729 <.L22>:
			putch('%', putdat);
  800729:	83 ec 08             	sub    $0x8,%esp
  80072c:	56                   	push   %esi
  80072d:	6a 25                	push   $0x25
  80072f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800732:	83 c4 10             	add    $0x10,%esp
  800735:	89 f8                	mov    %edi,%eax
  800737:	eb 03                	jmp    80073c <.L22+0x13>
  800739:	83 e8 01             	sub    $0x1,%eax
  80073c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800740:	75 f7                	jne    800739 <.L22+0x10>
  800742:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800745:	e9 54 ff ff ff       	jmp    80069e <.L35+0x45>
}
  80074a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074d:	5b                   	pop    %ebx
  80074e:	5e                   	pop    %esi
  80074f:	5f                   	pop    %edi
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	53                   	push   %ebx
  800756:	83 ec 14             	sub    $0x14,%esp
  800759:	e8 15 f9 ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  80075e:	81 c3 a2 18 00 00    	add    $0x18a2,%ebx
  800764:	8b 45 08             	mov    0x8(%ebp),%eax
  800767:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80076a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800771:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800774:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80077b:	85 c0                	test   %eax,%eax
  80077d:	74 2b                	je     8007aa <vsnprintf+0x58>
  80077f:	85 d2                	test   %edx,%edx
  800781:	7e 27                	jle    8007aa <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800783:	ff 75 14             	pushl  0x14(%ebp)
  800786:	ff 75 10             	pushl  0x10(%ebp)
  800789:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80078c:	50                   	push   %eax
  80078d:	8d 83 85 e2 ff ff    	lea    -0x1d7b(%ebx),%eax
  800793:	50                   	push   %eax
  800794:	e8 26 fb ff ff       	call   8002bf <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800799:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a2:	83 c4 10             	add    $0x10,%esp
}
  8007a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a8:	c9                   	leave  
  8007a9:	c3                   	ret    
		return -E_INVAL;
  8007aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007af:	eb f4                	jmp    8007a5 <vsnprintf+0x53>

008007b1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ba:	50                   	push   %eax
  8007bb:	ff 75 10             	pushl  0x10(%ebp)
  8007be:	ff 75 0c             	pushl  0xc(%ebp)
  8007c1:	ff 75 08             	pushl  0x8(%ebp)
  8007c4:	e8 89 ff ff ff       	call   800752 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c9:	c9                   	leave  
  8007ca:	c3                   	ret    

008007cb <__x86.get_pc_thunk.cx>:
  8007cb:	8b 0c 24             	mov    (%esp),%ecx
  8007ce:	c3                   	ret    

008007cf <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007da:	eb 03                	jmp    8007df <strlen+0x10>
		n++;
  8007dc:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007df:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e3:	75 f7                	jne    8007dc <strlen+0xd>
	return n;
}
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ed:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f5:	eb 03                	jmp    8007fa <strnlen+0x13>
		n++;
  8007f7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fa:	39 d0                	cmp    %edx,%eax
  8007fc:	74 06                	je     800804 <strnlen+0x1d>
  8007fe:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800802:	75 f3                	jne    8007f7 <strnlen+0x10>
	return n;
}
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	53                   	push   %ebx
  80080a:	8b 45 08             	mov    0x8(%ebp),%eax
  80080d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800810:	89 c2                	mov    %eax,%edx
  800812:	83 c1 01             	add    $0x1,%ecx
  800815:	83 c2 01             	add    $0x1,%edx
  800818:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80081c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80081f:	84 db                	test   %bl,%bl
  800821:	75 ef                	jne    800812 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800823:	5b                   	pop    %ebx
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	53                   	push   %ebx
  80082a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80082d:	53                   	push   %ebx
  80082e:	e8 9c ff ff ff       	call   8007cf <strlen>
  800833:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800836:	ff 75 0c             	pushl  0xc(%ebp)
  800839:	01 d8                	add    %ebx,%eax
  80083b:	50                   	push   %eax
  80083c:	e8 c5 ff ff ff       	call   800806 <strcpy>
	return dst;
}
  800841:	89 d8                	mov    %ebx,%eax
  800843:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800846:	c9                   	leave  
  800847:	c3                   	ret    

00800848 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	56                   	push   %esi
  80084c:	53                   	push   %ebx
  80084d:	8b 75 08             	mov    0x8(%ebp),%esi
  800850:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800853:	89 f3                	mov    %esi,%ebx
  800855:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800858:	89 f2                	mov    %esi,%edx
  80085a:	eb 0f                	jmp    80086b <strncpy+0x23>
		*dst++ = *src;
  80085c:	83 c2 01             	add    $0x1,%edx
  80085f:	0f b6 01             	movzbl (%ecx),%eax
  800862:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800865:	80 39 01             	cmpb   $0x1,(%ecx)
  800868:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80086b:	39 da                	cmp    %ebx,%edx
  80086d:	75 ed                	jne    80085c <strncpy+0x14>
	}
	return ret;
}
  80086f:	89 f0                	mov    %esi,%eax
  800871:	5b                   	pop    %ebx
  800872:	5e                   	pop    %esi
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	56                   	push   %esi
  800879:	53                   	push   %ebx
  80087a:	8b 75 08             	mov    0x8(%ebp),%esi
  80087d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800880:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800883:	89 f0                	mov    %esi,%eax
  800885:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800889:	85 c9                	test   %ecx,%ecx
  80088b:	75 0b                	jne    800898 <strlcpy+0x23>
  80088d:	eb 17                	jmp    8008a6 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80088f:	83 c2 01             	add    $0x1,%edx
  800892:	83 c0 01             	add    $0x1,%eax
  800895:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800898:	39 d8                	cmp    %ebx,%eax
  80089a:	74 07                	je     8008a3 <strlcpy+0x2e>
  80089c:	0f b6 0a             	movzbl (%edx),%ecx
  80089f:	84 c9                	test   %cl,%cl
  8008a1:	75 ec                	jne    80088f <strlcpy+0x1a>
		*dst = '\0';
  8008a3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008a6:	29 f0                	sub    %esi,%eax
}
  8008a8:	5b                   	pop    %ebx
  8008a9:	5e                   	pop    %esi
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b5:	eb 06                	jmp    8008bd <strcmp+0x11>
		p++, q++;
  8008b7:	83 c1 01             	add    $0x1,%ecx
  8008ba:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008bd:	0f b6 01             	movzbl (%ecx),%eax
  8008c0:	84 c0                	test   %al,%al
  8008c2:	74 04                	je     8008c8 <strcmp+0x1c>
  8008c4:	3a 02                	cmp    (%edx),%al
  8008c6:	74 ef                	je     8008b7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c8:	0f b6 c0             	movzbl %al,%eax
  8008cb:	0f b6 12             	movzbl (%edx),%edx
  8008ce:	29 d0                	sub    %edx,%eax
}
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	53                   	push   %ebx
  8008d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008dc:	89 c3                	mov    %eax,%ebx
  8008de:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008e1:	eb 06                	jmp    8008e9 <strncmp+0x17>
		n--, p++, q++;
  8008e3:	83 c0 01             	add    $0x1,%eax
  8008e6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008e9:	39 d8                	cmp    %ebx,%eax
  8008eb:	74 16                	je     800903 <strncmp+0x31>
  8008ed:	0f b6 08             	movzbl (%eax),%ecx
  8008f0:	84 c9                	test   %cl,%cl
  8008f2:	74 04                	je     8008f8 <strncmp+0x26>
  8008f4:	3a 0a                	cmp    (%edx),%cl
  8008f6:	74 eb                	je     8008e3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f8:	0f b6 00             	movzbl (%eax),%eax
  8008fb:	0f b6 12             	movzbl (%edx),%edx
  8008fe:	29 d0                	sub    %edx,%eax
}
  800900:	5b                   	pop    %ebx
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    
		return 0;
  800903:	b8 00 00 00 00       	mov    $0x0,%eax
  800908:	eb f6                	jmp    800900 <strncmp+0x2e>

0080090a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	8b 45 08             	mov    0x8(%ebp),%eax
  800910:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800914:	0f b6 10             	movzbl (%eax),%edx
  800917:	84 d2                	test   %dl,%dl
  800919:	74 09                	je     800924 <strchr+0x1a>
		if (*s == c)
  80091b:	38 ca                	cmp    %cl,%dl
  80091d:	74 0a                	je     800929 <strchr+0x1f>
	for (; *s; s++)
  80091f:	83 c0 01             	add    $0x1,%eax
  800922:	eb f0                	jmp    800914 <strchr+0xa>
			return (char *) s;
	return 0;
  800924:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800935:	eb 03                	jmp    80093a <strfind+0xf>
  800937:	83 c0 01             	add    $0x1,%eax
  80093a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80093d:	38 ca                	cmp    %cl,%dl
  80093f:	74 04                	je     800945 <strfind+0x1a>
  800941:	84 d2                	test   %dl,%dl
  800943:	75 f2                	jne    800937 <strfind+0xc>
			break;
	return (char *) s;
}
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	57                   	push   %edi
  80094b:	56                   	push   %esi
  80094c:	53                   	push   %ebx
  80094d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800950:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800953:	85 c9                	test   %ecx,%ecx
  800955:	74 13                	je     80096a <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800957:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095d:	75 05                	jne    800964 <memset+0x1d>
  80095f:	f6 c1 03             	test   $0x3,%cl
  800962:	74 0d                	je     800971 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800964:	8b 45 0c             	mov    0xc(%ebp),%eax
  800967:	fc                   	cld    
  800968:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096a:	89 f8                	mov    %edi,%eax
  80096c:	5b                   	pop    %ebx
  80096d:	5e                   	pop    %esi
  80096e:	5f                   	pop    %edi
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    
		c &= 0xFF;
  800971:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800975:	89 d3                	mov    %edx,%ebx
  800977:	c1 e3 08             	shl    $0x8,%ebx
  80097a:	89 d0                	mov    %edx,%eax
  80097c:	c1 e0 18             	shl    $0x18,%eax
  80097f:	89 d6                	mov    %edx,%esi
  800981:	c1 e6 10             	shl    $0x10,%esi
  800984:	09 f0                	or     %esi,%eax
  800986:	09 c2                	or     %eax,%edx
  800988:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  80098a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80098d:	89 d0                	mov    %edx,%eax
  80098f:	fc                   	cld    
  800990:	f3 ab                	rep stos %eax,%es:(%edi)
  800992:	eb d6                	jmp    80096a <memset+0x23>

00800994 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	57                   	push   %edi
  800998:	56                   	push   %esi
  800999:	8b 45 08             	mov    0x8(%ebp),%eax
  80099c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a2:	39 c6                	cmp    %eax,%esi
  8009a4:	73 35                	jae    8009db <memmove+0x47>
  8009a6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a9:	39 c2                	cmp    %eax,%edx
  8009ab:	76 2e                	jbe    8009db <memmove+0x47>
		s += n;
		d += n;
  8009ad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b0:	89 d6                	mov    %edx,%esi
  8009b2:	09 fe                	or     %edi,%esi
  8009b4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ba:	74 0c                	je     8009c8 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009bc:	83 ef 01             	sub    $0x1,%edi
  8009bf:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009c2:	fd                   	std    
  8009c3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c5:	fc                   	cld    
  8009c6:	eb 21                	jmp    8009e9 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c8:	f6 c1 03             	test   $0x3,%cl
  8009cb:	75 ef                	jne    8009bc <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009cd:	83 ef 04             	sub    $0x4,%edi
  8009d0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009d6:	fd                   	std    
  8009d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d9:	eb ea                	jmp    8009c5 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009db:	89 f2                	mov    %esi,%edx
  8009dd:	09 c2                	or     %eax,%edx
  8009df:	f6 c2 03             	test   $0x3,%dl
  8009e2:	74 09                	je     8009ed <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e4:	89 c7                	mov    %eax,%edi
  8009e6:	fc                   	cld    
  8009e7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e9:	5e                   	pop    %esi
  8009ea:	5f                   	pop    %edi
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ed:	f6 c1 03             	test   $0x3,%cl
  8009f0:	75 f2                	jne    8009e4 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009f2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009f5:	89 c7                	mov    %eax,%edi
  8009f7:	fc                   	cld    
  8009f8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fa:	eb ed                	jmp    8009e9 <memmove+0x55>

008009fc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ff:	ff 75 10             	pushl  0x10(%ebp)
  800a02:	ff 75 0c             	pushl  0xc(%ebp)
  800a05:	ff 75 08             	pushl  0x8(%ebp)
  800a08:	e8 87 ff ff ff       	call   800994 <memmove>
}
  800a0d:	c9                   	leave  
  800a0e:	c3                   	ret    

00800a0f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	56                   	push   %esi
  800a13:	53                   	push   %ebx
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1a:	89 c6                	mov    %eax,%esi
  800a1c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1f:	39 f0                	cmp    %esi,%eax
  800a21:	74 1c                	je     800a3f <memcmp+0x30>
		if (*s1 != *s2)
  800a23:	0f b6 08             	movzbl (%eax),%ecx
  800a26:	0f b6 1a             	movzbl (%edx),%ebx
  800a29:	38 d9                	cmp    %bl,%cl
  800a2b:	75 08                	jne    800a35 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a2d:	83 c0 01             	add    $0x1,%eax
  800a30:	83 c2 01             	add    $0x1,%edx
  800a33:	eb ea                	jmp    800a1f <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a35:	0f b6 c1             	movzbl %cl,%eax
  800a38:	0f b6 db             	movzbl %bl,%ebx
  800a3b:	29 d8                	sub    %ebx,%eax
  800a3d:	eb 05                	jmp    800a44 <memcmp+0x35>
	}

	return 0;
  800a3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a44:	5b                   	pop    %ebx
  800a45:	5e                   	pop    %esi
  800a46:	5d                   	pop    %ebp
  800a47:	c3                   	ret    

00800a48 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a51:	89 c2                	mov    %eax,%edx
  800a53:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a56:	39 d0                	cmp    %edx,%eax
  800a58:	73 09                	jae    800a63 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5a:	38 08                	cmp    %cl,(%eax)
  800a5c:	74 05                	je     800a63 <memfind+0x1b>
	for (; s < ends; s++)
  800a5e:	83 c0 01             	add    $0x1,%eax
  800a61:	eb f3                	jmp    800a56 <memfind+0xe>
			break;
	return (void *) s;
}
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	57                   	push   %edi
  800a69:	56                   	push   %esi
  800a6a:	53                   	push   %ebx
  800a6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a71:	eb 03                	jmp    800a76 <strtol+0x11>
		s++;
  800a73:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a76:	0f b6 01             	movzbl (%ecx),%eax
  800a79:	3c 20                	cmp    $0x20,%al
  800a7b:	74 f6                	je     800a73 <strtol+0xe>
  800a7d:	3c 09                	cmp    $0x9,%al
  800a7f:	74 f2                	je     800a73 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a81:	3c 2b                	cmp    $0x2b,%al
  800a83:	74 2e                	je     800ab3 <strtol+0x4e>
	int neg = 0;
  800a85:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a8a:	3c 2d                	cmp    $0x2d,%al
  800a8c:	74 2f                	je     800abd <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a94:	75 05                	jne    800a9b <strtol+0x36>
  800a96:	80 39 30             	cmpb   $0x30,(%ecx)
  800a99:	74 2c                	je     800ac7 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a9b:	85 db                	test   %ebx,%ebx
  800a9d:	75 0a                	jne    800aa9 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a9f:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800aa4:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa7:	74 28                	je     800ad1 <strtol+0x6c>
		base = 10;
  800aa9:	b8 00 00 00 00       	mov    $0x0,%eax
  800aae:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ab1:	eb 50                	jmp    800b03 <strtol+0x9e>
		s++;
  800ab3:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ab6:	bf 00 00 00 00       	mov    $0x0,%edi
  800abb:	eb d1                	jmp    800a8e <strtol+0x29>
		s++, neg = 1;
  800abd:	83 c1 01             	add    $0x1,%ecx
  800ac0:	bf 01 00 00 00       	mov    $0x1,%edi
  800ac5:	eb c7                	jmp    800a8e <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800acb:	74 0e                	je     800adb <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800acd:	85 db                	test   %ebx,%ebx
  800acf:	75 d8                	jne    800aa9 <strtol+0x44>
		s++, base = 8;
  800ad1:	83 c1 01             	add    $0x1,%ecx
  800ad4:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ad9:	eb ce                	jmp    800aa9 <strtol+0x44>
		s += 2, base = 16;
  800adb:	83 c1 02             	add    $0x2,%ecx
  800ade:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ae3:	eb c4                	jmp    800aa9 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ae5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae8:	89 f3                	mov    %esi,%ebx
  800aea:	80 fb 19             	cmp    $0x19,%bl
  800aed:	77 29                	ja     800b18 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800aef:	0f be d2             	movsbl %dl,%edx
  800af2:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800af5:	3b 55 10             	cmp    0x10(%ebp),%edx
  800af8:	7d 30                	jge    800b2a <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800afa:	83 c1 01             	add    $0x1,%ecx
  800afd:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b01:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b03:	0f b6 11             	movzbl (%ecx),%edx
  800b06:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b09:	89 f3                	mov    %esi,%ebx
  800b0b:	80 fb 09             	cmp    $0x9,%bl
  800b0e:	77 d5                	ja     800ae5 <strtol+0x80>
			dig = *s - '0';
  800b10:	0f be d2             	movsbl %dl,%edx
  800b13:	83 ea 30             	sub    $0x30,%edx
  800b16:	eb dd                	jmp    800af5 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b18:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b1b:	89 f3                	mov    %esi,%ebx
  800b1d:	80 fb 19             	cmp    $0x19,%bl
  800b20:	77 08                	ja     800b2a <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b22:	0f be d2             	movsbl %dl,%edx
  800b25:	83 ea 37             	sub    $0x37,%edx
  800b28:	eb cb                	jmp    800af5 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b2a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b2e:	74 05                	je     800b35 <strtol+0xd0>
		*endptr = (char *) s;
  800b30:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b33:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b35:	89 c2                	mov    %eax,%edx
  800b37:	f7 da                	neg    %edx
  800b39:	85 ff                	test   %edi,%edi
  800b3b:	0f 45 c2             	cmovne %edx,%eax
}
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b49:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b54:	89 c3                	mov    %eax,%ebx
  800b56:	89 c7                	mov    %eax,%edi
  800b58:	89 c6                	mov    %eax,%esi
  800b5a:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	57                   	push   %edi
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b67:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b71:	89 d1                	mov    %edx,%ecx
  800b73:	89 d3                	mov    %edx,%ebx
  800b75:	89 d7                	mov    %edx,%edi
  800b77:	89 d6                	mov    %edx,%esi
  800b79:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	83 ec 1c             	sub    $0x1c,%esp
  800b89:	e8 66 00 00 00       	call   800bf4 <__x86.get_pc_thunk.ax>
  800b8e:	05 72 14 00 00       	add    $0x1472,%eax
  800b93:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800b96:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9e:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba3:	89 cb                	mov    %ecx,%ebx
  800ba5:	89 cf                	mov    %ecx,%edi
  800ba7:	89 ce                	mov    %ecx,%esi
  800ba9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bab:	85 c0                	test   %eax,%eax
  800bad:	7f 08                	jg     800bb7 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800baf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb7:	83 ec 0c             	sub    $0xc,%esp
  800bba:	50                   	push   %eax
  800bbb:	6a 03                	push   $0x3
  800bbd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800bc0:	8d 83 9c f0 ff ff    	lea    -0xf64(%ebx),%eax
  800bc6:	50                   	push   %eax
  800bc7:	6a 23                	push   $0x23
  800bc9:	8d 83 b9 f0 ff ff    	lea    -0xf47(%ebx),%eax
  800bcf:	50                   	push   %eax
  800bd0:	e8 23 00 00 00       	call   800bf8 <_panic>

00800bd5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	57                   	push   %edi
  800bd9:	56                   	push   %esi
  800bda:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800be0:	b8 02 00 00 00       	mov    $0x2,%eax
  800be5:	89 d1                	mov    %edx,%ecx
  800be7:	89 d3                	mov    %edx,%ebx
  800be9:	89 d7                	mov    %edx,%edi
  800beb:	89 d6                	mov    %edx,%esi
  800bed:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bef:	5b                   	pop    %ebx
  800bf0:	5e                   	pop    %esi
  800bf1:	5f                   	pop    %edi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <__x86.get_pc_thunk.ax>:
  800bf4:	8b 04 24             	mov    (%esp),%eax
  800bf7:	c3                   	ret    

00800bf8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	57                   	push   %edi
  800bfc:	56                   	push   %esi
  800bfd:	53                   	push   %ebx
  800bfe:	83 ec 0c             	sub    $0xc,%esp
  800c01:	e8 6d f4 ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  800c06:	81 c3 fa 13 00 00    	add    $0x13fa,%ebx
	va_list ap;

	va_start(ap, fmt);
  800c0c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c0f:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800c15:	8b 38                	mov    (%eax),%edi
  800c17:	e8 b9 ff ff ff       	call   800bd5 <sys_getenvid>
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	ff 75 0c             	pushl  0xc(%ebp)
  800c22:	ff 75 08             	pushl  0x8(%ebp)
  800c25:	57                   	push   %edi
  800c26:	50                   	push   %eax
  800c27:	8d 83 c8 f0 ff ff    	lea    -0xf38(%ebx),%eax
  800c2d:	50                   	push   %eax
  800c2e:	e8 74 f5 ff ff       	call   8001a7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c33:	83 c4 18             	add    $0x18,%esp
  800c36:	56                   	push   %esi
  800c37:	ff 75 10             	pushl  0x10(%ebp)
  800c3a:	e8 06 f5 ff ff       	call   800145 <vcprintf>
	cprintf("\n");
  800c3f:	8d 83 a8 ee ff ff    	lea    -0x1158(%ebx),%eax
  800c45:	89 04 24             	mov    %eax,(%esp)
  800c48:	e8 5a f5 ff ff       	call   8001a7 <cprintf>
  800c4d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c50:	cc                   	int3   
  800c51:	eb fd                	jmp    800c50 <_panic+0x58>
  800c53:	66 90                	xchg   %ax,%ax
  800c55:	66 90                	xchg   %ax,%ax
  800c57:	66 90                	xchg   %ax,%ax
  800c59:	66 90                	xchg   %ax,%ax
  800c5b:	66 90                	xchg   %ax,%ax
  800c5d:	66 90                	xchg   %ax,%ax
  800c5f:	90                   	nop

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
