
obj/user/faultreadkernel：     文件格式 elf32-i386


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
  80002c:	e8 32 00 00 00       	call   800063 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 20 00 00 00       	call   80005f <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800045:	ff 35 00 00 10 f0    	pushl  0xf0100000
  80004b:	8d 83 7c ee ff ff    	lea    -0x1184(%ebx),%eax
  800051:	50                   	push   %eax
  800052:	e8 3c 01 00 00       	call   800193 <cprintf>
}
  800057:	83 c4 10             	add    $0x10,%esp
  80005a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80005d:	c9                   	leave  
  80005e:	c3                   	ret    

0080005f <__x86.get_pc_thunk.bx>:
  80005f:	8b 1c 24             	mov    (%esp),%ebx
  800062:	c3                   	ret    

00800063 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800063:	55                   	push   %ebp
  800064:	89 e5                	mov    %esp,%ebp
  800066:	57                   	push   %edi
  800067:	56                   	push   %esi
  800068:	53                   	push   %ebx
  800069:	83 ec 0c             	sub    $0xc,%esp
  80006c:	e8 ee ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800071:	81 c3 8f 1f 00 00    	add    $0x1f8f,%ebx
  800077:	8b 75 08             	mov    0x8(%ebp),%esi
  80007a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80007d:	e8 3f 0b 00 00       	call   800bc1 <sys_getenvid>
  800082:	25 ff 03 00 00       	and    $0x3ff,%eax
  800087:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80008a:	c1 e0 05             	shl    $0x5,%eax
  80008d:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800093:	c7 c2 2c 20 80 00    	mov    $0x80202c,%edx
  800099:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009b:	85 f6                	test   %esi,%esi
  80009d:	7e 08                	jle    8000a7 <libmain+0x44>
		binaryname = argv[0];
  80009f:	8b 07                	mov    (%edi),%eax
  8000a1:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000a7:	83 ec 08             	sub    $0x8,%esp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	e8 82 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b1:	e8 0b 00 00 00       	call   8000c1 <exit>
}
  8000b6:	83 c4 10             	add    $0x10,%esp
  8000b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000bc:	5b                   	pop    %ebx
  8000bd:	5e                   	pop    %esi
  8000be:	5f                   	pop    %edi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	53                   	push   %ebx
  8000c5:	83 ec 10             	sub    $0x10,%esp
  8000c8:	e8 92 ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8000cd:	81 c3 33 1f 00 00    	add    $0x1f33,%ebx
	sys_env_destroy(0);
  8000d3:	6a 00                	push   $0x0
  8000d5:	e8 92 0a 00 00       	call   800b6c <sys_env_destroy>
}
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e0:	c9                   	leave  
  8000e1:	c3                   	ret    

008000e2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 73 ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8000ec:	81 c3 14 1f 00 00    	add    $0x1f14,%ebx
  8000f2:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8000f5:	8b 16                	mov    (%esi),%edx
  8000f7:	8d 42 01             	lea    0x1(%edx),%eax
  8000fa:	89 06                	mov    %eax,(%esi)
  8000fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ff:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800103:	3d ff 00 00 00       	cmp    $0xff,%eax
  800108:	74 0b                	je     800115 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80010a:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80010e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800111:	5b                   	pop    %ebx
  800112:	5e                   	pop    %esi
  800113:	5d                   	pop    %ebp
  800114:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800115:	83 ec 08             	sub    $0x8,%esp
  800118:	68 ff 00 00 00       	push   $0xff
  80011d:	8d 46 08             	lea    0x8(%esi),%eax
  800120:	50                   	push   %eax
  800121:	e8 09 0a 00 00       	call   800b2f <sys_cputs>
		b->idx = 0;
  800126:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80012c:	83 c4 10             	add    $0x10,%esp
  80012f:	eb d9                	jmp    80010a <putch+0x28>

00800131 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800131:	55                   	push   %ebp
  800132:	89 e5                	mov    %esp,%ebp
  800134:	53                   	push   %ebx
  800135:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80013b:	e8 1f ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800140:	81 c3 c0 1e 00 00    	add    $0x1ec0,%ebx
	struct printbuf b;

	b.idx = 0;
  800146:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014d:	00 00 00 
	b.cnt = 0;
  800150:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800157:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015a:	ff 75 0c             	pushl  0xc(%ebp)
  80015d:	ff 75 08             	pushl  0x8(%ebp)
  800160:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800166:	50                   	push   %eax
  800167:	8d 83 e2 e0 ff ff    	lea    -0x1f1e(%ebx),%eax
  80016d:	50                   	push   %eax
  80016e:	e8 38 01 00 00       	call   8002ab <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800173:	83 c4 08             	add    $0x8,%esp
  800176:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80017c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800182:	50                   	push   %eax
  800183:	e8 a7 09 00 00       	call   800b2f <sys_cputs>

	return b.cnt;
}
  800188:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800199:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019c:	50                   	push   %eax
  80019d:	ff 75 08             	pushl  0x8(%ebp)
  8001a0:	e8 8c ff ff ff       	call   800131 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	57                   	push   %edi
  8001ab:	56                   	push   %esi
  8001ac:	53                   	push   %ebx
  8001ad:	83 ec 2c             	sub    $0x2c,%esp
  8001b0:	e8 02 06 00 00       	call   8007b7 <__x86.get_pc_thunk.cx>
  8001b5:	81 c1 4b 1e 00 00    	add    $0x1e4b,%ecx
  8001bb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001be:	89 c7                	mov    %eax,%edi
  8001c0:	89 d6                	mov    %edx,%esi
  8001c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001cb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d6:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8001d9:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8001dc:	39 d3                	cmp    %edx,%ebx
  8001de:	72 09                	jb     8001e9 <printnum+0x42>
  8001e0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001e3:	0f 87 83 00 00 00    	ja     80026c <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	ff 75 18             	pushl  0x18(%ebp)
  8001ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f5:	53                   	push   %ebx
  8001f6:	ff 75 10             	pushl  0x10(%ebp)
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ff:	ff 75 d8             	pushl  -0x28(%ebp)
  800202:	ff 75 d4             	pushl  -0x2c(%ebp)
  800205:	ff 75 d0             	pushl  -0x30(%ebp)
  800208:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80020b:	e8 30 0a 00 00       	call   800c40 <__udivdi3>
  800210:	83 c4 18             	add    $0x18,%esp
  800213:	52                   	push   %edx
  800214:	50                   	push   %eax
  800215:	89 f2                	mov    %esi,%edx
  800217:	89 f8                	mov    %edi,%eax
  800219:	e8 89 ff ff ff       	call   8001a7 <printnum>
  80021e:	83 c4 20             	add    $0x20,%esp
  800221:	eb 13                	jmp    800236 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	56                   	push   %esi
  800227:	ff 75 18             	pushl  0x18(%ebp)
  80022a:	ff d7                	call   *%edi
  80022c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80022f:	83 eb 01             	sub    $0x1,%ebx
  800232:	85 db                	test   %ebx,%ebx
  800234:	7f ed                	jg     800223 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800236:	83 ec 08             	sub    $0x8,%esp
  800239:	56                   	push   %esi
  80023a:	83 ec 04             	sub    $0x4,%esp
  80023d:	ff 75 dc             	pushl  -0x24(%ebp)
  800240:	ff 75 d8             	pushl  -0x28(%ebp)
  800243:	ff 75 d4             	pushl  -0x2c(%ebp)
  800246:	ff 75 d0             	pushl  -0x30(%ebp)
  800249:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80024c:	89 f3                	mov    %esi,%ebx
  80024e:	e8 0d 0b 00 00       	call   800d60 <__umoddi3>
  800253:	83 c4 14             	add    $0x14,%esp
  800256:	0f be 84 06 ad ee ff 	movsbl -0x1153(%esi,%eax,1),%eax
  80025d:	ff 
  80025e:	50                   	push   %eax
  80025f:	ff d7                	call   *%edi
}
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    
  80026c:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80026f:	eb be                	jmp    80022f <printnum+0x88>

00800271 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800277:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027b:	8b 10                	mov    (%eax),%edx
  80027d:	3b 50 04             	cmp    0x4(%eax),%edx
  800280:	73 0a                	jae    80028c <sprintputch+0x1b>
		*b->buf++ = ch;
  800282:	8d 4a 01             	lea    0x1(%edx),%ecx
  800285:	89 08                	mov    %ecx,(%eax)
  800287:	8b 45 08             	mov    0x8(%ebp),%eax
  80028a:	88 02                	mov    %al,(%edx)
}
  80028c:	5d                   	pop    %ebp
  80028d:	c3                   	ret    

0080028e <printfmt>:
{
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
  800291:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800294:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800297:	50                   	push   %eax
  800298:	ff 75 10             	pushl  0x10(%ebp)
  80029b:	ff 75 0c             	pushl  0xc(%ebp)
  80029e:	ff 75 08             	pushl  0x8(%ebp)
  8002a1:	e8 05 00 00 00       	call   8002ab <vprintfmt>
}
  8002a6:	83 c4 10             	add    $0x10,%esp
  8002a9:	c9                   	leave  
  8002aa:	c3                   	ret    

008002ab <vprintfmt>:
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	57                   	push   %edi
  8002af:	56                   	push   %esi
  8002b0:	53                   	push   %ebx
  8002b1:	83 ec 2c             	sub    $0x2c,%esp
  8002b4:	e8 a6 fd ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8002b9:	81 c3 47 1d 00 00    	add    $0x1d47,%ebx
  8002bf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002c2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c5:	e9 c3 03 00 00       	jmp    80068d <.L35+0x48>
		padc = ' ';
  8002ca:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002ce:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002d5:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8002dc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e8:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002eb:	8d 47 01             	lea    0x1(%edi),%eax
  8002ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f1:	0f b6 17             	movzbl (%edi),%edx
  8002f4:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002f7:	3c 55                	cmp    $0x55,%al
  8002f9:	0f 87 16 04 00 00    	ja     800715 <.L22>
  8002ff:	0f b6 c0             	movzbl %al,%eax
  800302:	89 d9                	mov    %ebx,%ecx
  800304:	03 8c 83 3c ef ff ff 	add    -0x10c4(%ebx,%eax,4),%ecx
  80030b:	ff e1                	jmp    *%ecx

0080030d <.L69>:
  80030d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800310:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800314:	eb d5                	jmp    8002eb <vprintfmt+0x40>

00800316 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800316:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800319:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80031d:	eb cc                	jmp    8002eb <vprintfmt+0x40>

0080031f <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  80031f:	0f b6 d2             	movzbl %dl,%edx
  800322:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800325:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  80032a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80032d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800331:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800334:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800337:	83 f9 09             	cmp    $0x9,%ecx
  80033a:	77 55                	ja     800391 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  80033c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80033f:	eb e9                	jmp    80032a <.L29+0xb>

00800341 <.L26>:
			precision = va_arg(ap, int);
  800341:	8b 45 14             	mov    0x14(%ebp),%eax
  800344:	8b 00                	mov    (%eax),%eax
  800346:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800349:	8b 45 14             	mov    0x14(%ebp),%eax
  80034c:	8d 40 04             	lea    0x4(%eax),%eax
  80034f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800352:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800355:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800359:	79 90                	jns    8002eb <vprintfmt+0x40>
				width = precision, precision = -1;
  80035b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80035e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800361:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800368:	eb 81                	jmp    8002eb <vprintfmt+0x40>

0080036a <.L27>:
  80036a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80036d:	85 c0                	test   %eax,%eax
  80036f:	ba 00 00 00 00       	mov    $0x0,%edx
  800374:	0f 49 d0             	cmovns %eax,%edx
  800377:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80037d:	e9 69 ff ff ff       	jmp    8002eb <vprintfmt+0x40>

00800382 <.L23>:
  800382:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800385:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80038c:	e9 5a ff ff ff       	jmp    8002eb <vprintfmt+0x40>
  800391:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800394:	eb bf                	jmp    800355 <.L26+0x14>

00800396 <.L33>:
			lflag++;
  800396:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80039d:	e9 49 ff ff ff       	jmp    8002eb <vprintfmt+0x40>

008003a2 <.L30>:
			putch(va_arg(ap, int), putdat);
  8003a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a5:	8d 78 04             	lea    0x4(%eax),%edi
  8003a8:	83 ec 08             	sub    $0x8,%esp
  8003ab:	56                   	push   %esi
  8003ac:	ff 30                	pushl  (%eax)
  8003ae:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003b1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003b4:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003b7:	e9 ce 02 00 00       	jmp    80068a <.L35+0x45>

008003bc <.L32>:
			err = va_arg(ap, int);
  8003bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bf:	8d 78 04             	lea    0x4(%eax),%edi
  8003c2:	8b 00                	mov    (%eax),%eax
  8003c4:	99                   	cltd   
  8003c5:	31 d0                	xor    %edx,%eax
  8003c7:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c9:	83 f8 06             	cmp    $0x6,%eax
  8003cc:	7f 27                	jg     8003f5 <.L32+0x39>
  8003ce:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8003d5:	85 d2                	test   %edx,%edx
  8003d7:	74 1c                	je     8003f5 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8003d9:	52                   	push   %edx
  8003da:	8d 83 ce ee ff ff    	lea    -0x1132(%ebx),%eax
  8003e0:	50                   	push   %eax
  8003e1:	56                   	push   %esi
  8003e2:	ff 75 08             	pushl  0x8(%ebp)
  8003e5:	e8 a4 fe ff ff       	call   80028e <printfmt>
  8003ea:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ed:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003f0:	e9 95 02 00 00       	jmp    80068a <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8003f5:	50                   	push   %eax
  8003f6:	8d 83 c5 ee ff ff    	lea    -0x113b(%ebx),%eax
  8003fc:	50                   	push   %eax
  8003fd:	56                   	push   %esi
  8003fe:	ff 75 08             	pushl  0x8(%ebp)
  800401:	e8 88 fe ff ff       	call   80028e <printfmt>
  800406:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800409:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80040c:	e9 79 02 00 00       	jmp    80068a <.L35+0x45>

00800411 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800411:	8b 45 14             	mov    0x14(%ebp),%eax
  800414:	83 c0 04             	add    $0x4,%eax
  800417:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80041a:	8b 45 14             	mov    0x14(%ebp),%eax
  80041d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80041f:	85 ff                	test   %edi,%edi
  800421:	8d 83 be ee ff ff    	lea    -0x1142(%ebx),%eax
  800427:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80042a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042e:	0f 8e b5 00 00 00    	jle    8004e9 <.L36+0xd8>
  800434:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800438:	75 08                	jne    800442 <.L36+0x31>
  80043a:	89 75 0c             	mov    %esi,0xc(%ebp)
  80043d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800440:	eb 6d                	jmp    8004af <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800442:	83 ec 08             	sub    $0x8,%esp
  800445:	ff 75 cc             	pushl  -0x34(%ebp)
  800448:	57                   	push   %edi
  800449:	e8 85 03 00 00       	call   8007d3 <strnlen>
  80044e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800451:	29 c2                	sub    %eax,%edx
  800453:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800456:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800459:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80045d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800460:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800463:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800465:	eb 10                	jmp    800477 <.L36+0x66>
					putch(padc, putdat);
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	56                   	push   %esi
  80046b:	ff 75 e0             	pushl  -0x20(%ebp)
  80046e:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800471:	83 ef 01             	sub    $0x1,%edi
  800474:	83 c4 10             	add    $0x10,%esp
  800477:	85 ff                	test   %edi,%edi
  800479:	7f ec                	jg     800467 <.L36+0x56>
  80047b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80047e:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800481:	85 d2                	test   %edx,%edx
  800483:	b8 00 00 00 00       	mov    $0x0,%eax
  800488:	0f 49 c2             	cmovns %edx,%eax
  80048b:	29 c2                	sub    %eax,%edx
  80048d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800490:	89 75 0c             	mov    %esi,0xc(%ebp)
  800493:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800496:	eb 17                	jmp    8004af <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  800498:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80049c:	75 30                	jne    8004ce <.L36+0xbd>
					putch(ch, putdat);
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	ff 75 0c             	pushl  0xc(%ebp)
  8004a4:	50                   	push   %eax
  8004a5:	ff 55 08             	call   *0x8(%ebp)
  8004a8:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ab:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8004af:	83 c7 01             	add    $0x1,%edi
  8004b2:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004b6:	0f be c2             	movsbl %dl,%eax
  8004b9:	85 c0                	test   %eax,%eax
  8004bb:	74 52                	je     80050f <.L36+0xfe>
  8004bd:	85 f6                	test   %esi,%esi
  8004bf:	78 d7                	js     800498 <.L36+0x87>
  8004c1:	83 ee 01             	sub    $0x1,%esi
  8004c4:	79 d2                	jns    800498 <.L36+0x87>
  8004c6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004c9:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004cc:	eb 32                	jmp    800500 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ce:	0f be d2             	movsbl %dl,%edx
  8004d1:	83 ea 20             	sub    $0x20,%edx
  8004d4:	83 fa 5e             	cmp    $0x5e,%edx
  8004d7:	76 c5                	jbe    80049e <.L36+0x8d>
					putch('?', putdat);
  8004d9:	83 ec 08             	sub    $0x8,%esp
  8004dc:	ff 75 0c             	pushl  0xc(%ebp)
  8004df:	6a 3f                	push   $0x3f
  8004e1:	ff 55 08             	call   *0x8(%ebp)
  8004e4:	83 c4 10             	add    $0x10,%esp
  8004e7:	eb c2                	jmp    8004ab <.L36+0x9a>
  8004e9:	89 75 0c             	mov    %esi,0xc(%ebp)
  8004ec:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004ef:	eb be                	jmp    8004af <.L36+0x9e>
				putch(' ', putdat);
  8004f1:	83 ec 08             	sub    $0x8,%esp
  8004f4:	56                   	push   %esi
  8004f5:	6a 20                	push   $0x20
  8004f7:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  8004fa:	83 ef 01             	sub    $0x1,%edi
  8004fd:	83 c4 10             	add    $0x10,%esp
  800500:	85 ff                	test   %edi,%edi
  800502:	7f ed                	jg     8004f1 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  800504:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800507:	89 45 14             	mov    %eax,0x14(%ebp)
  80050a:	e9 7b 01 00 00       	jmp    80068a <.L35+0x45>
  80050f:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800512:	8b 75 0c             	mov    0xc(%ebp),%esi
  800515:	eb e9                	jmp    800500 <.L36+0xef>

00800517 <.L31>:
  800517:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80051a:	83 f9 01             	cmp    $0x1,%ecx
  80051d:	7e 40                	jle    80055f <.L31+0x48>
		return va_arg(*ap, long long);
  80051f:	8b 45 14             	mov    0x14(%ebp),%eax
  800522:	8b 50 04             	mov    0x4(%eax),%edx
  800525:	8b 00                	mov    (%eax),%eax
  800527:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80052d:	8b 45 14             	mov    0x14(%ebp),%eax
  800530:	8d 40 08             	lea    0x8(%eax),%eax
  800533:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800536:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80053a:	79 55                	jns    800591 <.L31+0x7a>
				putch('-', putdat);
  80053c:	83 ec 08             	sub    $0x8,%esp
  80053f:	56                   	push   %esi
  800540:	6a 2d                	push   $0x2d
  800542:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800545:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800548:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80054b:	f7 da                	neg    %edx
  80054d:	83 d1 00             	adc    $0x0,%ecx
  800550:	f7 d9                	neg    %ecx
  800552:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800555:	b8 0a 00 00 00       	mov    $0xa,%eax
  80055a:	e9 10 01 00 00       	jmp    80066f <.L35+0x2a>
	else if (lflag)
  80055f:	85 c9                	test   %ecx,%ecx
  800561:	75 17                	jne    80057a <.L31+0x63>
		return va_arg(*ap, int);
  800563:	8b 45 14             	mov    0x14(%ebp),%eax
  800566:	8b 00                	mov    (%eax),%eax
  800568:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056b:	99                   	cltd   
  80056c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8d 40 04             	lea    0x4(%eax),%eax
  800575:	89 45 14             	mov    %eax,0x14(%ebp)
  800578:	eb bc                	jmp    800536 <.L31+0x1f>
		return va_arg(*ap, long);
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8b 00                	mov    (%eax),%eax
  80057f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800582:	99                   	cltd   
  800583:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8d 40 04             	lea    0x4(%eax),%eax
  80058c:	89 45 14             	mov    %eax,0x14(%ebp)
  80058f:	eb a5                	jmp    800536 <.L31+0x1f>
			num = getint(&ap, lflag);
  800591:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800594:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800597:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059c:	e9 ce 00 00 00       	jmp    80066f <.L35+0x2a>

008005a1 <.L37>:
  8005a1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8005a4:	83 f9 01             	cmp    $0x1,%ecx
  8005a7:	7e 18                	jle    8005c1 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8b 10                	mov    (%eax),%edx
  8005ae:	8b 48 04             	mov    0x4(%eax),%ecx
  8005b1:	8d 40 08             	lea    0x8(%eax),%eax
  8005b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005bc:	e9 ae 00 00 00       	jmp    80066f <.L35+0x2a>
	else if (lflag)
  8005c1:	85 c9                	test   %ecx,%ecx
  8005c3:	75 1a                	jne    8005df <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8b 10                	mov    (%eax),%edx
  8005ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005cf:	8d 40 04             	lea    0x4(%eax),%eax
  8005d2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005da:	e9 90 00 00 00       	jmp    80066f <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8b 10                	mov    (%eax),%edx
  8005e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e9:	8d 40 04             	lea    0x4(%eax),%eax
  8005ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ef:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f4:	eb 79                	jmp    80066f <.L35+0x2a>

008005f6 <.L34>:
  8005f6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8005f9:	83 f9 01             	cmp    $0x1,%ecx
  8005fc:	7e 15                	jle    800613 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8b 10                	mov    (%eax),%edx
  800603:	8b 48 04             	mov    0x4(%eax),%ecx
  800606:	8d 40 08             	lea    0x8(%eax),%eax
  800609:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80060c:	b8 08 00 00 00       	mov    $0x8,%eax
  800611:	eb 5c                	jmp    80066f <.L35+0x2a>
	else if (lflag)
  800613:	85 c9                	test   %ecx,%ecx
  800615:	75 17                	jne    80062e <.L34+0x38>
		return va_arg(*ap, unsigned int);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8b 10                	mov    (%eax),%edx
  80061c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800621:	8d 40 04             	lea    0x4(%eax),%eax
  800624:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800627:	b8 08 00 00 00       	mov    $0x8,%eax
  80062c:	eb 41                	jmp    80066f <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8b 10                	mov    (%eax),%edx
  800633:	b9 00 00 00 00       	mov    $0x0,%ecx
  800638:	8d 40 04             	lea    0x4(%eax),%eax
  80063b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80063e:	b8 08 00 00 00       	mov    $0x8,%eax
  800643:	eb 2a                	jmp    80066f <.L35+0x2a>

00800645 <.L35>:
			putch('0', putdat);
  800645:	83 ec 08             	sub    $0x8,%esp
  800648:	56                   	push   %esi
  800649:	6a 30                	push   $0x30
  80064b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80064e:	83 c4 08             	add    $0x8,%esp
  800651:	56                   	push   %esi
  800652:	6a 78                	push   $0x78
  800654:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8b 10                	mov    (%eax),%edx
  80065c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800661:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800664:	8d 40 04             	lea    0x4(%eax),%eax
  800667:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80066a:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80066f:	83 ec 0c             	sub    $0xc,%esp
  800672:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800676:	57                   	push   %edi
  800677:	ff 75 e0             	pushl  -0x20(%ebp)
  80067a:	50                   	push   %eax
  80067b:	51                   	push   %ecx
  80067c:	52                   	push   %edx
  80067d:	89 f2                	mov    %esi,%edx
  80067f:	8b 45 08             	mov    0x8(%ebp),%eax
  800682:	e8 20 fb ff ff       	call   8001a7 <printnum>
			break;
  800687:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80068a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80068d:	83 c7 01             	add    $0x1,%edi
  800690:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800694:	83 f8 25             	cmp    $0x25,%eax
  800697:	0f 84 2d fc ff ff    	je     8002ca <vprintfmt+0x1f>
			if (ch == '\0')
  80069d:	85 c0                	test   %eax,%eax
  80069f:	0f 84 91 00 00 00    	je     800736 <.L22+0x21>
			putch(ch, putdat);
  8006a5:	83 ec 08             	sub    $0x8,%esp
  8006a8:	56                   	push   %esi
  8006a9:	50                   	push   %eax
  8006aa:	ff 55 08             	call   *0x8(%ebp)
  8006ad:	83 c4 10             	add    $0x10,%esp
  8006b0:	eb db                	jmp    80068d <.L35+0x48>

008006b2 <.L38>:
  8006b2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006b5:	83 f9 01             	cmp    $0x1,%ecx
  8006b8:	7e 15                	jle    8006cf <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8b 10                	mov    (%eax),%edx
  8006bf:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c2:	8d 40 08             	lea    0x8(%eax),%eax
  8006c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c8:	b8 10 00 00 00       	mov    $0x10,%eax
  8006cd:	eb a0                	jmp    80066f <.L35+0x2a>
	else if (lflag)
  8006cf:	85 c9                	test   %ecx,%ecx
  8006d1:	75 17                	jne    8006ea <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8b 10                	mov    (%eax),%edx
  8006d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006dd:	8d 40 04             	lea    0x4(%eax),%eax
  8006e0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e3:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e8:	eb 85                	jmp    80066f <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ed:	8b 10                	mov    (%eax),%edx
  8006ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f4:	8d 40 04             	lea    0x4(%eax),%eax
  8006f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006fa:	b8 10 00 00 00       	mov    $0x10,%eax
  8006ff:	e9 6b ff ff ff       	jmp    80066f <.L35+0x2a>

00800704 <.L25>:
			putch(ch, putdat);
  800704:	83 ec 08             	sub    $0x8,%esp
  800707:	56                   	push   %esi
  800708:	6a 25                	push   $0x25
  80070a:	ff 55 08             	call   *0x8(%ebp)
			break;
  80070d:	83 c4 10             	add    $0x10,%esp
  800710:	e9 75 ff ff ff       	jmp    80068a <.L35+0x45>

00800715 <.L22>:
			putch('%', putdat);
  800715:	83 ec 08             	sub    $0x8,%esp
  800718:	56                   	push   %esi
  800719:	6a 25                	push   $0x25
  80071b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071e:	83 c4 10             	add    $0x10,%esp
  800721:	89 f8                	mov    %edi,%eax
  800723:	eb 03                	jmp    800728 <.L22+0x13>
  800725:	83 e8 01             	sub    $0x1,%eax
  800728:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80072c:	75 f7                	jne    800725 <.L22+0x10>
  80072e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800731:	e9 54 ff ff ff       	jmp    80068a <.L35+0x45>
}
  800736:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800739:	5b                   	pop    %ebx
  80073a:	5e                   	pop    %esi
  80073b:	5f                   	pop    %edi
  80073c:	5d                   	pop    %ebp
  80073d:	c3                   	ret    

0080073e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	53                   	push   %ebx
  800742:	83 ec 14             	sub    $0x14,%esp
  800745:	e8 15 f9 ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  80074a:	81 c3 b6 18 00 00    	add    $0x18b6,%ebx
  800750:	8b 45 08             	mov    0x8(%ebp),%eax
  800753:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800756:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800759:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80075d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800760:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800767:	85 c0                	test   %eax,%eax
  800769:	74 2b                	je     800796 <vsnprintf+0x58>
  80076b:	85 d2                	test   %edx,%edx
  80076d:	7e 27                	jle    800796 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80076f:	ff 75 14             	pushl  0x14(%ebp)
  800772:	ff 75 10             	pushl  0x10(%ebp)
  800775:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800778:	50                   	push   %eax
  800779:	8d 83 71 e2 ff ff    	lea    -0x1d8f(%ebx),%eax
  80077f:	50                   	push   %eax
  800780:	e8 26 fb ff ff       	call   8002ab <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800785:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800788:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078e:	83 c4 10             	add    $0x10,%esp
}
  800791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800794:	c9                   	leave  
  800795:	c3                   	ret    
		return -E_INVAL;
  800796:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80079b:	eb f4                	jmp    800791 <vsnprintf+0x53>

0080079d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a6:	50                   	push   %eax
  8007a7:	ff 75 10             	pushl  0x10(%ebp)
  8007aa:	ff 75 0c             	pushl  0xc(%ebp)
  8007ad:	ff 75 08             	pushl  0x8(%ebp)
  8007b0:	e8 89 ff ff ff       	call   80073e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    

008007b7 <__x86.get_pc_thunk.cx>:
  8007b7:	8b 0c 24             	mov    (%esp),%ecx
  8007ba:	c3                   	ret    

008007bb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c6:	eb 03                	jmp    8007cb <strlen+0x10>
		n++;
  8007c8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007cb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007cf:	75 f7                	jne    8007c8 <strlen+0xd>
	return n;
}
  8007d1:	5d                   	pop    %ebp
  8007d2:	c3                   	ret    

008007d3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d9:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e1:	eb 03                	jmp    8007e6 <strnlen+0x13>
		n++;
  8007e3:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e6:	39 d0                	cmp    %edx,%eax
  8007e8:	74 06                	je     8007f0 <strnlen+0x1d>
  8007ea:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ee:	75 f3                	jne    8007e3 <strnlen+0x10>
	return n;
}
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	53                   	push   %ebx
  8007f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fc:	89 c2                	mov    %eax,%edx
  8007fe:	83 c1 01             	add    $0x1,%ecx
  800801:	83 c2 01             	add    $0x1,%edx
  800804:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800808:	88 5a ff             	mov    %bl,-0x1(%edx)
  80080b:	84 db                	test   %bl,%bl
  80080d:	75 ef                	jne    8007fe <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80080f:	5b                   	pop    %ebx
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	53                   	push   %ebx
  800816:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800819:	53                   	push   %ebx
  80081a:	e8 9c ff ff ff       	call   8007bb <strlen>
  80081f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800822:	ff 75 0c             	pushl  0xc(%ebp)
  800825:	01 d8                	add    %ebx,%eax
  800827:	50                   	push   %eax
  800828:	e8 c5 ff ff ff       	call   8007f2 <strcpy>
	return dst;
}
  80082d:	89 d8                	mov    %ebx,%eax
  80082f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800832:	c9                   	leave  
  800833:	c3                   	ret    

00800834 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	56                   	push   %esi
  800838:	53                   	push   %ebx
  800839:	8b 75 08             	mov    0x8(%ebp),%esi
  80083c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083f:	89 f3                	mov    %esi,%ebx
  800841:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800844:	89 f2                	mov    %esi,%edx
  800846:	eb 0f                	jmp    800857 <strncpy+0x23>
		*dst++ = *src;
  800848:	83 c2 01             	add    $0x1,%edx
  80084b:	0f b6 01             	movzbl (%ecx),%eax
  80084e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800851:	80 39 01             	cmpb   $0x1,(%ecx)
  800854:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800857:	39 da                	cmp    %ebx,%edx
  800859:	75 ed                	jne    800848 <strncpy+0x14>
	}
	return ret;
}
  80085b:	89 f0                	mov    %esi,%eax
  80085d:	5b                   	pop    %ebx
  80085e:	5e                   	pop    %esi
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	56                   	push   %esi
  800865:	53                   	push   %ebx
  800866:	8b 75 08             	mov    0x8(%ebp),%esi
  800869:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80086f:	89 f0                	mov    %esi,%eax
  800871:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800875:	85 c9                	test   %ecx,%ecx
  800877:	75 0b                	jne    800884 <strlcpy+0x23>
  800879:	eb 17                	jmp    800892 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087b:	83 c2 01             	add    $0x1,%edx
  80087e:	83 c0 01             	add    $0x1,%eax
  800881:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800884:	39 d8                	cmp    %ebx,%eax
  800886:	74 07                	je     80088f <strlcpy+0x2e>
  800888:	0f b6 0a             	movzbl (%edx),%ecx
  80088b:	84 c9                	test   %cl,%cl
  80088d:	75 ec                	jne    80087b <strlcpy+0x1a>
		*dst = '\0';
  80088f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800892:	29 f0                	sub    %esi,%eax
}
  800894:	5b                   	pop    %ebx
  800895:	5e                   	pop    %esi
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    

00800898 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a1:	eb 06                	jmp    8008a9 <strcmp+0x11>
		p++, q++;
  8008a3:	83 c1 01             	add    $0x1,%ecx
  8008a6:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008a9:	0f b6 01             	movzbl (%ecx),%eax
  8008ac:	84 c0                	test   %al,%al
  8008ae:	74 04                	je     8008b4 <strcmp+0x1c>
  8008b0:	3a 02                	cmp    (%edx),%al
  8008b2:	74 ef                	je     8008a3 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b4:	0f b6 c0             	movzbl %al,%eax
  8008b7:	0f b6 12             	movzbl (%edx),%edx
  8008ba:	29 d0                	sub    %edx,%eax
}
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	53                   	push   %ebx
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c8:	89 c3                	mov    %eax,%ebx
  8008ca:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008cd:	eb 06                	jmp    8008d5 <strncmp+0x17>
		n--, p++, q++;
  8008cf:	83 c0 01             	add    $0x1,%eax
  8008d2:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008d5:	39 d8                	cmp    %ebx,%eax
  8008d7:	74 16                	je     8008ef <strncmp+0x31>
  8008d9:	0f b6 08             	movzbl (%eax),%ecx
  8008dc:	84 c9                	test   %cl,%cl
  8008de:	74 04                	je     8008e4 <strncmp+0x26>
  8008e0:	3a 0a                	cmp    (%edx),%cl
  8008e2:	74 eb                	je     8008cf <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e4:	0f b6 00             	movzbl (%eax),%eax
  8008e7:	0f b6 12             	movzbl (%edx),%edx
  8008ea:	29 d0                	sub    %edx,%eax
}
  8008ec:	5b                   	pop    %ebx
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    
		return 0;
  8008ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f4:	eb f6                	jmp    8008ec <strncmp+0x2e>

008008f6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800900:	0f b6 10             	movzbl (%eax),%edx
  800903:	84 d2                	test   %dl,%dl
  800905:	74 09                	je     800910 <strchr+0x1a>
		if (*s == c)
  800907:	38 ca                	cmp    %cl,%dl
  800909:	74 0a                	je     800915 <strchr+0x1f>
	for (; *s; s++)
  80090b:	83 c0 01             	add    $0x1,%eax
  80090e:	eb f0                	jmp    800900 <strchr+0xa>
			return (char *) s;
	return 0;
  800910:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	8b 45 08             	mov    0x8(%ebp),%eax
  80091d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800921:	eb 03                	jmp    800926 <strfind+0xf>
  800923:	83 c0 01             	add    $0x1,%eax
  800926:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800929:	38 ca                	cmp    %cl,%dl
  80092b:	74 04                	je     800931 <strfind+0x1a>
  80092d:	84 d2                	test   %dl,%dl
  80092f:	75 f2                	jne    800923 <strfind+0xc>
			break;
	return (char *) s;
}
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	57                   	push   %edi
  800937:	56                   	push   %esi
  800938:	53                   	push   %ebx
  800939:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80093f:	85 c9                	test   %ecx,%ecx
  800941:	74 13                	je     800956 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800943:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800949:	75 05                	jne    800950 <memset+0x1d>
  80094b:	f6 c1 03             	test   $0x3,%cl
  80094e:	74 0d                	je     80095d <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800950:	8b 45 0c             	mov    0xc(%ebp),%eax
  800953:	fc                   	cld    
  800954:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800956:	89 f8                	mov    %edi,%eax
  800958:	5b                   	pop    %ebx
  800959:	5e                   	pop    %esi
  80095a:	5f                   	pop    %edi
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    
		c &= 0xFF;
  80095d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800961:	89 d3                	mov    %edx,%ebx
  800963:	c1 e3 08             	shl    $0x8,%ebx
  800966:	89 d0                	mov    %edx,%eax
  800968:	c1 e0 18             	shl    $0x18,%eax
  80096b:	89 d6                	mov    %edx,%esi
  80096d:	c1 e6 10             	shl    $0x10,%esi
  800970:	09 f0                	or     %esi,%eax
  800972:	09 c2                	or     %eax,%edx
  800974:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800976:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800979:	89 d0                	mov    %edx,%eax
  80097b:	fc                   	cld    
  80097c:	f3 ab                	rep stos %eax,%es:(%edi)
  80097e:	eb d6                	jmp    800956 <memset+0x23>

00800980 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	57                   	push   %edi
  800984:	56                   	push   %esi
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80098e:	39 c6                	cmp    %eax,%esi
  800990:	73 35                	jae    8009c7 <memmove+0x47>
  800992:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800995:	39 c2                	cmp    %eax,%edx
  800997:	76 2e                	jbe    8009c7 <memmove+0x47>
		s += n;
		d += n;
  800999:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099c:	89 d6                	mov    %edx,%esi
  80099e:	09 fe                	or     %edi,%esi
  8009a0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a6:	74 0c                	je     8009b4 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009a8:	83 ef 01             	sub    $0x1,%edi
  8009ab:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009ae:	fd                   	std    
  8009af:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b1:	fc                   	cld    
  8009b2:	eb 21                	jmp    8009d5 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b4:	f6 c1 03             	test   $0x3,%cl
  8009b7:	75 ef                	jne    8009a8 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b9:	83 ef 04             	sub    $0x4,%edi
  8009bc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009bf:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009c2:	fd                   	std    
  8009c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c5:	eb ea                	jmp    8009b1 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c7:	89 f2                	mov    %esi,%edx
  8009c9:	09 c2                	or     %eax,%edx
  8009cb:	f6 c2 03             	test   $0x3,%dl
  8009ce:	74 09                	je     8009d9 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d0:	89 c7                	mov    %eax,%edi
  8009d2:	fc                   	cld    
  8009d3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d5:	5e                   	pop    %esi
  8009d6:	5f                   	pop    %edi
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d9:	f6 c1 03             	test   $0x3,%cl
  8009dc:	75 f2                	jne    8009d0 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009de:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009e1:	89 c7                	mov    %eax,%edi
  8009e3:	fc                   	cld    
  8009e4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e6:	eb ed                	jmp    8009d5 <memmove+0x55>

008009e8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009eb:	ff 75 10             	pushl  0x10(%ebp)
  8009ee:	ff 75 0c             	pushl  0xc(%ebp)
  8009f1:	ff 75 08             	pushl  0x8(%ebp)
  8009f4:	e8 87 ff ff ff       	call   800980 <memmove>
}
  8009f9:	c9                   	leave  
  8009fa:	c3                   	ret    

008009fb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	56                   	push   %esi
  8009ff:	53                   	push   %ebx
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a06:	89 c6                	mov    %eax,%esi
  800a08:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0b:	39 f0                	cmp    %esi,%eax
  800a0d:	74 1c                	je     800a2b <memcmp+0x30>
		if (*s1 != *s2)
  800a0f:	0f b6 08             	movzbl (%eax),%ecx
  800a12:	0f b6 1a             	movzbl (%edx),%ebx
  800a15:	38 d9                	cmp    %bl,%cl
  800a17:	75 08                	jne    800a21 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a19:	83 c0 01             	add    $0x1,%eax
  800a1c:	83 c2 01             	add    $0x1,%edx
  800a1f:	eb ea                	jmp    800a0b <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a21:	0f b6 c1             	movzbl %cl,%eax
  800a24:	0f b6 db             	movzbl %bl,%ebx
  800a27:	29 d8                	sub    %ebx,%eax
  800a29:	eb 05                	jmp    800a30 <memcmp+0x35>
	}

	return 0;
  800a2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a30:	5b                   	pop    %ebx
  800a31:	5e                   	pop    %esi
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a3d:	89 c2                	mov    %eax,%edx
  800a3f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a42:	39 d0                	cmp    %edx,%eax
  800a44:	73 09                	jae    800a4f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a46:	38 08                	cmp    %cl,(%eax)
  800a48:	74 05                	je     800a4f <memfind+0x1b>
	for (; s < ends; s++)
  800a4a:	83 c0 01             	add    $0x1,%eax
  800a4d:	eb f3                	jmp    800a42 <memfind+0xe>
			break;
	return (void *) s;
}
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	57                   	push   %edi
  800a55:	56                   	push   %esi
  800a56:	53                   	push   %ebx
  800a57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5d:	eb 03                	jmp    800a62 <strtol+0x11>
		s++;
  800a5f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a62:	0f b6 01             	movzbl (%ecx),%eax
  800a65:	3c 20                	cmp    $0x20,%al
  800a67:	74 f6                	je     800a5f <strtol+0xe>
  800a69:	3c 09                	cmp    $0x9,%al
  800a6b:	74 f2                	je     800a5f <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a6d:	3c 2b                	cmp    $0x2b,%al
  800a6f:	74 2e                	je     800a9f <strtol+0x4e>
	int neg = 0;
  800a71:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a76:	3c 2d                	cmp    $0x2d,%al
  800a78:	74 2f                	je     800aa9 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a80:	75 05                	jne    800a87 <strtol+0x36>
  800a82:	80 39 30             	cmpb   $0x30,(%ecx)
  800a85:	74 2c                	je     800ab3 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a87:	85 db                	test   %ebx,%ebx
  800a89:	75 0a                	jne    800a95 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a8b:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a90:	80 39 30             	cmpb   $0x30,(%ecx)
  800a93:	74 28                	je     800abd <strtol+0x6c>
		base = 10;
  800a95:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a9d:	eb 50                	jmp    800aef <strtol+0x9e>
		s++;
  800a9f:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800aa2:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa7:	eb d1                	jmp    800a7a <strtol+0x29>
		s++, neg = 1;
  800aa9:	83 c1 01             	add    $0x1,%ecx
  800aac:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab1:	eb c7                	jmp    800a7a <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ab7:	74 0e                	je     800ac7 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ab9:	85 db                	test   %ebx,%ebx
  800abb:	75 d8                	jne    800a95 <strtol+0x44>
		s++, base = 8;
  800abd:	83 c1 01             	add    $0x1,%ecx
  800ac0:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ac5:	eb ce                	jmp    800a95 <strtol+0x44>
		s += 2, base = 16;
  800ac7:	83 c1 02             	add    $0x2,%ecx
  800aca:	bb 10 00 00 00       	mov    $0x10,%ebx
  800acf:	eb c4                	jmp    800a95 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ad1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ad4:	89 f3                	mov    %esi,%ebx
  800ad6:	80 fb 19             	cmp    $0x19,%bl
  800ad9:	77 29                	ja     800b04 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800adb:	0f be d2             	movsbl %dl,%edx
  800ade:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ae1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ae4:	7d 30                	jge    800b16 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ae6:	83 c1 01             	add    $0x1,%ecx
  800ae9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aed:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800aef:	0f b6 11             	movzbl (%ecx),%edx
  800af2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800af5:	89 f3                	mov    %esi,%ebx
  800af7:	80 fb 09             	cmp    $0x9,%bl
  800afa:	77 d5                	ja     800ad1 <strtol+0x80>
			dig = *s - '0';
  800afc:	0f be d2             	movsbl %dl,%edx
  800aff:	83 ea 30             	sub    $0x30,%edx
  800b02:	eb dd                	jmp    800ae1 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b04:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b07:	89 f3                	mov    %esi,%ebx
  800b09:	80 fb 19             	cmp    $0x19,%bl
  800b0c:	77 08                	ja     800b16 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b0e:	0f be d2             	movsbl %dl,%edx
  800b11:	83 ea 37             	sub    $0x37,%edx
  800b14:	eb cb                	jmp    800ae1 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b16:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1a:	74 05                	je     800b21 <strtol+0xd0>
		*endptr = (char *) s;
  800b1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b21:	89 c2                	mov    %eax,%edx
  800b23:	f7 da                	neg    %edx
  800b25:	85 ff                	test   %edi,%edi
  800b27:	0f 45 c2             	cmovne %edx,%eax
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b35:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b40:	89 c3                	mov    %eax,%ebx
  800b42:	89 c7                	mov    %eax,%edi
  800b44:	89 c6                	mov    %eax,%esi
  800b46:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <sys_cgetc>:

int
sys_cgetc(void)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b53:	ba 00 00 00 00       	mov    $0x0,%edx
  800b58:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5d:	89 d1                	mov    %edx,%ecx
  800b5f:	89 d3                	mov    %edx,%ebx
  800b61:	89 d7                	mov    %edx,%edi
  800b63:	89 d6                	mov    %edx,%esi
  800b65:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b67:	5b                   	pop    %ebx
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
  800b72:	83 ec 1c             	sub    $0x1c,%esp
  800b75:	e8 66 00 00 00       	call   800be0 <__x86.get_pc_thunk.ax>
  800b7a:	05 86 14 00 00       	add    $0x1486,%eax
  800b7f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800b82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b87:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b8f:	89 cb                	mov    %ecx,%ebx
  800b91:	89 cf                	mov    %ecx,%edi
  800b93:	89 ce                	mov    %ecx,%esi
  800b95:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b97:	85 c0                	test   %eax,%eax
  800b99:	7f 08                	jg     800ba3 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	50                   	push   %eax
  800ba7:	6a 03                	push   $0x3
  800ba9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800bac:	8d 83 94 f0 ff ff    	lea    -0xf6c(%ebx),%eax
  800bb2:	50                   	push   %eax
  800bb3:	6a 23                	push   $0x23
  800bb5:	8d 83 b1 f0 ff ff    	lea    -0xf4f(%ebx),%eax
  800bbb:	50                   	push   %eax
  800bbc:	e8 23 00 00 00       	call   800be4 <_panic>

00800bc1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	57                   	push   %edi
  800bc5:	56                   	push   %esi
  800bc6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcc:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd1:	89 d1                	mov    %edx,%ecx
  800bd3:	89 d3                	mov    %edx,%ebx
  800bd5:	89 d7                	mov    %edx,%edi
  800bd7:	89 d6                	mov    %edx,%esi
  800bd9:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <__x86.get_pc_thunk.ax>:
  800be0:	8b 04 24             	mov    (%esp),%eax
  800be3:	c3                   	ret    

00800be4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
  800bea:	83 ec 0c             	sub    $0xc,%esp
  800bed:	e8 6d f4 ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800bf2:	81 c3 0e 14 00 00    	add    $0x140e,%ebx
	va_list ap;

	va_start(ap, fmt);
  800bf8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800bfb:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800c01:	8b 38                	mov    (%eax),%edi
  800c03:	e8 b9 ff ff ff       	call   800bc1 <sys_getenvid>
  800c08:	83 ec 0c             	sub    $0xc,%esp
  800c0b:	ff 75 0c             	pushl  0xc(%ebp)
  800c0e:	ff 75 08             	pushl  0x8(%ebp)
  800c11:	57                   	push   %edi
  800c12:	50                   	push   %eax
  800c13:	8d 83 c0 f0 ff ff    	lea    -0xf40(%ebx),%eax
  800c19:	50                   	push   %eax
  800c1a:	e8 74 f5 ff ff       	call   800193 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c1f:	83 c4 18             	add    $0x18,%esp
  800c22:	56                   	push   %esi
  800c23:	ff 75 10             	pushl  0x10(%ebp)
  800c26:	e8 06 f5 ff ff       	call   800131 <vcprintf>
	cprintf("\n");
  800c2b:	8d 83 e4 f0 ff ff    	lea    -0xf1c(%ebx),%eax
  800c31:	89 04 24             	mov    %eax,(%esp)
  800c34:	e8 5a f5 ff ff       	call   800193 <cprintf>
  800c39:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c3c:	cc                   	int3   
  800c3d:	eb fd                	jmp    800c3c <_panic+0x58>
  800c3f:	90                   	nop

00800c40 <__udivdi3>:
  800c40:	55                   	push   %ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 1c             	sub    $0x1c,%esp
  800c47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c4b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c53:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c57:	85 d2                	test   %edx,%edx
  800c59:	75 35                	jne    800c90 <__udivdi3+0x50>
  800c5b:	39 f3                	cmp    %esi,%ebx
  800c5d:	0f 87 bd 00 00 00    	ja     800d20 <__udivdi3+0xe0>
  800c63:	85 db                	test   %ebx,%ebx
  800c65:	89 d9                	mov    %ebx,%ecx
  800c67:	75 0b                	jne    800c74 <__udivdi3+0x34>
  800c69:	b8 01 00 00 00       	mov    $0x1,%eax
  800c6e:	31 d2                	xor    %edx,%edx
  800c70:	f7 f3                	div    %ebx
  800c72:	89 c1                	mov    %eax,%ecx
  800c74:	31 d2                	xor    %edx,%edx
  800c76:	89 f0                	mov    %esi,%eax
  800c78:	f7 f1                	div    %ecx
  800c7a:	89 c6                	mov    %eax,%esi
  800c7c:	89 e8                	mov    %ebp,%eax
  800c7e:	89 f7                	mov    %esi,%edi
  800c80:	f7 f1                	div    %ecx
  800c82:	89 fa                	mov    %edi,%edx
  800c84:	83 c4 1c             	add    $0x1c,%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    
  800c8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c90:	39 f2                	cmp    %esi,%edx
  800c92:	77 7c                	ja     800d10 <__udivdi3+0xd0>
  800c94:	0f bd fa             	bsr    %edx,%edi
  800c97:	83 f7 1f             	xor    $0x1f,%edi
  800c9a:	0f 84 98 00 00 00    	je     800d38 <__udivdi3+0xf8>
  800ca0:	89 f9                	mov    %edi,%ecx
  800ca2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ca7:	29 f8                	sub    %edi,%eax
  800ca9:	d3 e2                	shl    %cl,%edx
  800cab:	89 54 24 08          	mov    %edx,0x8(%esp)
  800caf:	89 c1                	mov    %eax,%ecx
  800cb1:	89 da                	mov    %ebx,%edx
  800cb3:	d3 ea                	shr    %cl,%edx
  800cb5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800cb9:	09 d1                	or     %edx,%ecx
  800cbb:	89 f2                	mov    %esi,%edx
  800cbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cc1:	89 f9                	mov    %edi,%ecx
  800cc3:	d3 e3                	shl    %cl,%ebx
  800cc5:	89 c1                	mov    %eax,%ecx
  800cc7:	d3 ea                	shr    %cl,%edx
  800cc9:	89 f9                	mov    %edi,%ecx
  800ccb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ccf:	d3 e6                	shl    %cl,%esi
  800cd1:	89 eb                	mov    %ebp,%ebx
  800cd3:	89 c1                	mov    %eax,%ecx
  800cd5:	d3 eb                	shr    %cl,%ebx
  800cd7:	09 de                	or     %ebx,%esi
  800cd9:	89 f0                	mov    %esi,%eax
  800cdb:	f7 74 24 08          	divl   0x8(%esp)
  800cdf:	89 d6                	mov    %edx,%esi
  800ce1:	89 c3                	mov    %eax,%ebx
  800ce3:	f7 64 24 0c          	mull   0xc(%esp)
  800ce7:	39 d6                	cmp    %edx,%esi
  800ce9:	72 0c                	jb     800cf7 <__udivdi3+0xb7>
  800ceb:	89 f9                	mov    %edi,%ecx
  800ced:	d3 e5                	shl    %cl,%ebp
  800cef:	39 c5                	cmp    %eax,%ebp
  800cf1:	73 5d                	jae    800d50 <__udivdi3+0x110>
  800cf3:	39 d6                	cmp    %edx,%esi
  800cf5:	75 59                	jne    800d50 <__udivdi3+0x110>
  800cf7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cfa:	31 ff                	xor    %edi,%edi
  800cfc:	89 fa                	mov    %edi,%edx
  800cfe:	83 c4 1c             	add    $0x1c,%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    
  800d06:	8d 76 00             	lea    0x0(%esi),%esi
  800d09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d10:	31 ff                	xor    %edi,%edi
  800d12:	31 c0                	xor    %eax,%eax
  800d14:	89 fa                	mov    %edi,%edx
  800d16:	83 c4 1c             	add    $0x1c,%esp
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    
  800d1e:	66 90                	xchg   %ax,%ax
  800d20:	31 ff                	xor    %edi,%edi
  800d22:	89 e8                	mov    %ebp,%eax
  800d24:	89 f2                	mov    %esi,%edx
  800d26:	f7 f3                	div    %ebx
  800d28:	89 fa                	mov    %edi,%edx
  800d2a:	83 c4 1c             	add    $0x1c,%esp
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    
  800d32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d38:	39 f2                	cmp    %esi,%edx
  800d3a:	72 06                	jb     800d42 <__udivdi3+0x102>
  800d3c:	31 c0                	xor    %eax,%eax
  800d3e:	39 eb                	cmp    %ebp,%ebx
  800d40:	77 d2                	ja     800d14 <__udivdi3+0xd4>
  800d42:	b8 01 00 00 00       	mov    $0x1,%eax
  800d47:	eb cb                	jmp    800d14 <__udivdi3+0xd4>
  800d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d50:	89 d8                	mov    %ebx,%eax
  800d52:	31 ff                	xor    %edi,%edi
  800d54:	eb be                	jmp    800d14 <__udivdi3+0xd4>
  800d56:	66 90                	xchg   %ax,%ax
  800d58:	66 90                	xchg   %ax,%ax
  800d5a:	66 90                	xchg   %ax,%ax
  800d5c:	66 90                	xchg   %ax,%ax
  800d5e:	66 90                	xchg   %ax,%ax

00800d60 <__umoddi3>:
  800d60:	55                   	push   %ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 1c             	sub    $0x1c,%esp
  800d67:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800d6b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d6f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d77:	85 ed                	test   %ebp,%ebp
  800d79:	89 f0                	mov    %esi,%eax
  800d7b:	89 da                	mov    %ebx,%edx
  800d7d:	75 19                	jne    800d98 <__umoddi3+0x38>
  800d7f:	39 df                	cmp    %ebx,%edi
  800d81:	0f 86 b1 00 00 00    	jbe    800e38 <__umoddi3+0xd8>
  800d87:	f7 f7                	div    %edi
  800d89:	89 d0                	mov    %edx,%eax
  800d8b:	31 d2                	xor    %edx,%edx
  800d8d:	83 c4 1c             	add    $0x1c,%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    
  800d95:	8d 76 00             	lea    0x0(%esi),%esi
  800d98:	39 dd                	cmp    %ebx,%ebp
  800d9a:	77 f1                	ja     800d8d <__umoddi3+0x2d>
  800d9c:	0f bd cd             	bsr    %ebp,%ecx
  800d9f:	83 f1 1f             	xor    $0x1f,%ecx
  800da2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800da6:	0f 84 b4 00 00 00    	je     800e60 <__umoddi3+0x100>
  800dac:	b8 20 00 00 00       	mov    $0x20,%eax
  800db1:	89 c2                	mov    %eax,%edx
  800db3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800db7:	29 c2                	sub    %eax,%edx
  800db9:	89 c1                	mov    %eax,%ecx
  800dbb:	89 f8                	mov    %edi,%eax
  800dbd:	d3 e5                	shl    %cl,%ebp
  800dbf:	89 d1                	mov    %edx,%ecx
  800dc1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800dc5:	d3 e8                	shr    %cl,%eax
  800dc7:	09 c5                	or     %eax,%ebp
  800dc9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dcd:	89 c1                	mov    %eax,%ecx
  800dcf:	d3 e7                	shl    %cl,%edi
  800dd1:	89 d1                	mov    %edx,%ecx
  800dd3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800dd7:	89 df                	mov    %ebx,%edi
  800dd9:	d3 ef                	shr    %cl,%edi
  800ddb:	89 c1                	mov    %eax,%ecx
  800ddd:	89 f0                	mov    %esi,%eax
  800ddf:	d3 e3                	shl    %cl,%ebx
  800de1:	89 d1                	mov    %edx,%ecx
  800de3:	89 fa                	mov    %edi,%edx
  800de5:	d3 e8                	shr    %cl,%eax
  800de7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800dec:	09 d8                	or     %ebx,%eax
  800dee:	f7 f5                	div    %ebp
  800df0:	d3 e6                	shl    %cl,%esi
  800df2:	89 d1                	mov    %edx,%ecx
  800df4:	f7 64 24 08          	mull   0x8(%esp)
  800df8:	39 d1                	cmp    %edx,%ecx
  800dfa:	89 c3                	mov    %eax,%ebx
  800dfc:	89 d7                	mov    %edx,%edi
  800dfe:	72 06                	jb     800e06 <__umoddi3+0xa6>
  800e00:	75 0e                	jne    800e10 <__umoddi3+0xb0>
  800e02:	39 c6                	cmp    %eax,%esi
  800e04:	73 0a                	jae    800e10 <__umoddi3+0xb0>
  800e06:	2b 44 24 08          	sub    0x8(%esp),%eax
  800e0a:	19 ea                	sbb    %ebp,%edx
  800e0c:	89 d7                	mov    %edx,%edi
  800e0e:	89 c3                	mov    %eax,%ebx
  800e10:	89 ca                	mov    %ecx,%edx
  800e12:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e17:	29 de                	sub    %ebx,%esi
  800e19:	19 fa                	sbb    %edi,%edx
  800e1b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800e1f:	89 d0                	mov    %edx,%eax
  800e21:	d3 e0                	shl    %cl,%eax
  800e23:	89 d9                	mov    %ebx,%ecx
  800e25:	d3 ee                	shr    %cl,%esi
  800e27:	d3 ea                	shr    %cl,%edx
  800e29:	09 f0                	or     %esi,%eax
  800e2b:	83 c4 1c             	add    $0x1c,%esp
  800e2e:	5b                   	pop    %ebx
  800e2f:	5e                   	pop    %esi
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    
  800e33:	90                   	nop
  800e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e38:	85 ff                	test   %edi,%edi
  800e3a:	89 f9                	mov    %edi,%ecx
  800e3c:	75 0b                	jne    800e49 <__umoddi3+0xe9>
  800e3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e43:	31 d2                	xor    %edx,%edx
  800e45:	f7 f7                	div    %edi
  800e47:	89 c1                	mov    %eax,%ecx
  800e49:	89 d8                	mov    %ebx,%eax
  800e4b:	31 d2                	xor    %edx,%edx
  800e4d:	f7 f1                	div    %ecx
  800e4f:	89 f0                	mov    %esi,%eax
  800e51:	f7 f1                	div    %ecx
  800e53:	e9 31 ff ff ff       	jmp    800d89 <__umoddi3+0x29>
  800e58:	90                   	nop
  800e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e60:	39 dd                	cmp    %ebx,%ebp
  800e62:	72 08                	jb     800e6c <__umoddi3+0x10c>
  800e64:	39 f7                	cmp    %esi,%edi
  800e66:	0f 87 21 ff ff ff    	ja     800d8d <__umoddi3+0x2d>
  800e6c:	89 da                	mov    %ebx,%edx
  800e6e:	89 f0                	mov    %esi,%eax
  800e70:	29 f8                	sub    %edi,%eax
  800e72:	19 ea                	sbb    %ebp,%edx
  800e74:	e9 14 ff ff ff       	jmp    800d8d <__umoddi3+0x2d>
