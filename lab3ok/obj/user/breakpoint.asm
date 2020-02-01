
obj/user/breakpoint：     文件格式 elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	57                   	push   %edi
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	83 ec 0c             	sub    $0xc,%esp
  800042:	e8 50 00 00 00       	call   800097 <__x86.get_pc_thunk.bx>
  800047:	81 c3 b9 1f 00 00    	add    $0x1fb9,%ebx
  80004d:	8b 75 08             	mov    0x8(%ebp),%esi
  800050:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800053:	e8 f6 00 00 00       	call   80014e <sys_getenvid>
  800058:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005d:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800060:	c1 e0 05             	shl    $0x5,%eax
  800063:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800069:	c7 c2 2c 20 80 00    	mov    $0x80202c,%edx
  80006f:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800071:	85 f6                	test   %esi,%esi
  800073:	7e 08                	jle    80007d <libmain+0x44>
		binaryname = argv[0];
  800075:	8b 07                	mov    (%edi),%eax
  800077:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80007d:	83 ec 08             	sub    $0x8,%esp
  800080:	57                   	push   %edi
  800081:	56                   	push   %esi
  800082:	e8 ac ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800087:	e8 0f 00 00 00       	call   80009b <exit>
}
  80008c:	83 c4 10             	add    $0x10,%esp
  80008f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800092:	5b                   	pop    %ebx
  800093:	5e                   	pop    %esi
  800094:	5f                   	pop    %edi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    

00800097 <__x86.get_pc_thunk.bx>:
  800097:	8b 1c 24             	mov    (%esp),%ebx
  80009a:	c3                   	ret    

0080009b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009b:	55                   	push   %ebp
  80009c:	89 e5                	mov    %esp,%ebp
  80009e:	53                   	push   %ebx
  80009f:	83 ec 10             	sub    $0x10,%esp
  8000a2:	e8 f0 ff ff ff       	call   800097 <__x86.get_pc_thunk.bx>
  8000a7:	81 c3 59 1f 00 00    	add    $0x1f59,%ebx
	sys_env_destroy(0);
  8000ad:	6a 00                	push   $0x0
  8000af:	e8 45 00 00 00       	call   8000f9 <sys_env_destroy>
}
  8000b4:	83 c4 10             	add    $0x10,%esp
  8000b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000ba:	c9                   	leave  
  8000bb:	c3                   	ret    

008000bc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cd:	89 c3                	mov    %eax,%ebx
  8000cf:	89 c7                	mov    %eax,%edi
  8000d1:	89 c6                	mov    %eax,%esi
  8000d3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d5:	5b                   	pop    %ebx
  8000d6:	5e                   	pop    %esi
  8000d7:	5f                   	pop    %edi
  8000d8:	5d                   	pop    %ebp
  8000d9:	c3                   	ret    

008000da <sys_cgetc>:

int
sys_cgetc(void)
{
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	57                   	push   %edi
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ea:	89 d1                	mov    %edx,%ecx
  8000ec:	89 d3                	mov    %edx,%ebx
  8000ee:	89 d7                	mov    %edx,%edi
  8000f0:	89 d6                	mov    %edx,%esi
  8000f2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f4:	5b                   	pop    %ebx
  8000f5:	5e                   	pop    %esi
  8000f6:	5f                   	pop    %edi
  8000f7:	5d                   	pop    %ebp
  8000f8:	c3                   	ret    

008000f9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	57                   	push   %edi
  8000fd:	56                   	push   %esi
  8000fe:	53                   	push   %ebx
  8000ff:	83 ec 1c             	sub    $0x1c,%esp
  800102:	e8 66 00 00 00       	call   80016d <__x86.get_pc_thunk.ax>
  800107:	05 f9 1e 00 00       	add    $0x1ef9,%eax
  80010c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80010f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800114:	8b 55 08             	mov    0x8(%ebp),%edx
  800117:	b8 03 00 00 00       	mov    $0x3,%eax
  80011c:	89 cb                	mov    %ecx,%ebx
  80011e:	89 cf                	mov    %ecx,%edi
  800120:	89 ce                	mov    %ecx,%esi
  800122:	cd 30                	int    $0x30
	if(check && ret > 0)
  800124:	85 c0                	test   %eax,%eax
  800126:	7f 08                	jg     800130 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800128:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012b:	5b                   	pop    %ebx
  80012c:	5e                   	pop    %esi
  80012d:	5f                   	pop    %edi
  80012e:	5d                   	pop    %ebp
  80012f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800130:	83 ec 0c             	sub    $0xc,%esp
  800133:	50                   	push   %eax
  800134:	6a 03                	push   $0x3
  800136:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800139:	8d 83 66 ee ff ff    	lea    -0x119a(%ebx),%eax
  80013f:	50                   	push   %eax
  800140:	6a 23                	push   $0x23
  800142:	8d 83 83 ee ff ff    	lea    -0x117d(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 23 00 00 00       	call   800171 <_panic>

0080014e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	57                   	push   %edi
  800152:	56                   	push   %esi
  800153:	53                   	push   %ebx
	asm volatile("int %1\n"
  800154:	ba 00 00 00 00       	mov    $0x0,%edx
  800159:	b8 02 00 00 00       	mov    $0x2,%eax
  80015e:	89 d1                	mov    %edx,%ecx
  800160:	89 d3                	mov    %edx,%ebx
  800162:	89 d7                	mov    %edx,%edi
  800164:	89 d6                	mov    %edx,%esi
  800166:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800168:	5b                   	pop    %ebx
  800169:	5e                   	pop    %esi
  80016a:	5f                   	pop    %edi
  80016b:	5d                   	pop    %ebp
  80016c:	c3                   	ret    

0080016d <__x86.get_pc_thunk.ax>:
  80016d:	8b 04 24             	mov    (%esp),%eax
  800170:	c3                   	ret    

00800171 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800171:	55                   	push   %ebp
  800172:	89 e5                	mov    %esp,%ebp
  800174:	57                   	push   %edi
  800175:	56                   	push   %esi
  800176:	53                   	push   %ebx
  800177:	83 ec 0c             	sub    $0xc,%esp
  80017a:	e8 18 ff ff ff       	call   800097 <__x86.get_pc_thunk.bx>
  80017f:	81 c3 81 1e 00 00    	add    $0x1e81,%ebx
	va_list ap;

	va_start(ap, fmt);
  800185:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800188:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  80018e:	8b 38                	mov    (%eax),%edi
  800190:	e8 b9 ff ff ff       	call   80014e <sys_getenvid>
  800195:	83 ec 0c             	sub    $0xc,%esp
  800198:	ff 75 0c             	pushl  0xc(%ebp)
  80019b:	ff 75 08             	pushl  0x8(%ebp)
  80019e:	57                   	push   %edi
  80019f:	50                   	push   %eax
  8001a0:	8d 83 94 ee ff ff    	lea    -0x116c(%ebx),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 d1 00 00 00       	call   80027d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001ac:	83 c4 18             	add    $0x18,%esp
  8001af:	56                   	push   %esi
  8001b0:	ff 75 10             	pushl  0x10(%ebp)
  8001b3:	e8 63 00 00 00       	call   80021b <vcprintf>
	cprintf("\n");
  8001b8:	8d 83 b8 ee ff ff    	lea    -0x1148(%ebx),%eax
  8001be:	89 04 24             	mov    %eax,(%esp)
  8001c1:	e8 b7 00 00 00       	call   80027d <cprintf>
  8001c6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c9:	cc                   	int3   
  8001ca:	eb fd                	jmp    8001c9 <_panic+0x58>

008001cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	56                   	push   %esi
  8001d0:	53                   	push   %ebx
  8001d1:	e8 c1 fe ff ff       	call   800097 <__x86.get_pc_thunk.bx>
  8001d6:	81 c3 2a 1e 00 00    	add    $0x1e2a,%ebx
  8001dc:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001df:	8b 16                	mov    (%esi),%edx
  8001e1:	8d 42 01             	lea    0x1(%edx),%eax
  8001e4:	89 06                	mov    %eax,(%esi)
  8001e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e9:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001ed:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f2:	74 0b                	je     8001ff <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001f4:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fb:	5b                   	pop    %ebx
  8001fc:	5e                   	pop    %esi
  8001fd:	5d                   	pop    %ebp
  8001fe:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001ff:	83 ec 08             	sub    $0x8,%esp
  800202:	68 ff 00 00 00       	push   $0xff
  800207:	8d 46 08             	lea    0x8(%esi),%eax
  80020a:	50                   	push   %eax
  80020b:	e8 ac fe ff ff       	call   8000bc <sys_cputs>
		b->idx = 0;
  800210:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800216:	83 c4 10             	add    $0x10,%esp
  800219:	eb d9                	jmp    8001f4 <putch+0x28>

0080021b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	53                   	push   %ebx
  80021f:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800225:	e8 6d fe ff ff       	call   800097 <__x86.get_pc_thunk.bx>
  80022a:	81 c3 d6 1d 00 00    	add    $0x1dd6,%ebx
	struct printbuf b;

	b.idx = 0;
  800230:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800237:	00 00 00 
	b.cnt = 0;
  80023a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800241:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800244:	ff 75 0c             	pushl  0xc(%ebp)
  800247:	ff 75 08             	pushl  0x8(%ebp)
  80024a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800250:	50                   	push   %eax
  800251:	8d 83 cc e1 ff ff    	lea    -0x1e34(%ebx),%eax
  800257:	50                   	push   %eax
  800258:	e8 38 01 00 00       	call   800395 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80025d:	83 c4 08             	add    $0x8,%esp
  800260:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800266:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80026c:	50                   	push   %eax
  80026d:	e8 4a fe ff ff       	call   8000bc <sys_cputs>

	return b.cnt;
}
  800272:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800278:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80027b:	c9                   	leave  
  80027c:	c3                   	ret    

0080027d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80027d:	55                   	push   %ebp
  80027e:	89 e5                	mov    %esp,%ebp
  800280:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800283:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800286:	50                   	push   %eax
  800287:	ff 75 08             	pushl  0x8(%ebp)
  80028a:	e8 8c ff ff ff       	call   80021b <vcprintf>
	va_end(ap);

	return cnt;
}
  80028f:	c9                   	leave  
  800290:	c3                   	ret    

00800291 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	57                   	push   %edi
  800295:	56                   	push   %esi
  800296:	53                   	push   %ebx
  800297:	83 ec 2c             	sub    $0x2c,%esp
  80029a:	e8 02 06 00 00       	call   8008a1 <__x86.get_pc_thunk.cx>
  80029f:	81 c1 61 1d 00 00    	add    $0x1d61,%ecx
  8002a5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002a8:	89 c7                	mov    %eax,%edi
  8002aa:	89 d6                	mov    %edx,%esi
  8002ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8002af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002b5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002c3:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002c6:	39 d3                	cmp    %edx,%ebx
  8002c8:	72 09                	jb     8002d3 <printnum+0x42>
  8002ca:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002cd:	0f 87 83 00 00 00    	ja     800356 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d3:	83 ec 0c             	sub    $0xc,%esp
  8002d6:	ff 75 18             	pushl  0x18(%ebp)
  8002d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8002dc:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002df:	53                   	push   %ebx
  8002e0:	ff 75 10             	pushl  0x10(%ebp)
  8002e3:	83 ec 08             	sub    $0x8,%esp
  8002e6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ec:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ef:	ff 75 d0             	pushl  -0x30(%ebp)
  8002f2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002f5:	e8 26 09 00 00       	call   800c20 <__udivdi3>
  8002fa:	83 c4 18             	add    $0x18,%esp
  8002fd:	52                   	push   %edx
  8002fe:	50                   	push   %eax
  8002ff:	89 f2                	mov    %esi,%edx
  800301:	89 f8                	mov    %edi,%eax
  800303:	e8 89 ff ff ff       	call   800291 <printnum>
  800308:	83 c4 20             	add    $0x20,%esp
  80030b:	eb 13                	jmp    800320 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030d:	83 ec 08             	sub    $0x8,%esp
  800310:	56                   	push   %esi
  800311:	ff 75 18             	pushl  0x18(%ebp)
  800314:	ff d7                	call   *%edi
  800316:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800319:	83 eb 01             	sub    $0x1,%ebx
  80031c:	85 db                	test   %ebx,%ebx
  80031e:	7f ed                	jg     80030d <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800320:	83 ec 08             	sub    $0x8,%esp
  800323:	56                   	push   %esi
  800324:	83 ec 04             	sub    $0x4,%esp
  800327:	ff 75 dc             	pushl  -0x24(%ebp)
  80032a:	ff 75 d8             	pushl  -0x28(%ebp)
  80032d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800330:	ff 75 d0             	pushl  -0x30(%ebp)
  800333:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800336:	89 f3                	mov    %esi,%ebx
  800338:	e8 03 0a 00 00       	call   800d40 <__umoddi3>
  80033d:	83 c4 14             	add    $0x14,%esp
  800340:	0f be 84 06 ba ee ff 	movsbl -0x1146(%esi,%eax,1),%eax
  800347:	ff 
  800348:	50                   	push   %eax
  800349:	ff d7                	call   *%edi
}
  80034b:	83 c4 10             	add    $0x10,%esp
  80034e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800351:	5b                   	pop    %ebx
  800352:	5e                   	pop    %esi
  800353:	5f                   	pop    %edi
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    
  800356:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800359:	eb be                	jmp    800319 <printnum+0x88>

0080035b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800361:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800365:	8b 10                	mov    (%eax),%edx
  800367:	3b 50 04             	cmp    0x4(%eax),%edx
  80036a:	73 0a                	jae    800376 <sprintputch+0x1b>
		*b->buf++ = ch;
  80036c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80036f:	89 08                	mov    %ecx,(%eax)
  800371:	8b 45 08             	mov    0x8(%ebp),%eax
  800374:	88 02                	mov    %al,(%edx)
}
  800376:	5d                   	pop    %ebp
  800377:	c3                   	ret    

00800378 <printfmt>:
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80037e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800381:	50                   	push   %eax
  800382:	ff 75 10             	pushl  0x10(%ebp)
  800385:	ff 75 0c             	pushl  0xc(%ebp)
  800388:	ff 75 08             	pushl  0x8(%ebp)
  80038b:	e8 05 00 00 00       	call   800395 <vprintfmt>
}
  800390:	83 c4 10             	add    $0x10,%esp
  800393:	c9                   	leave  
  800394:	c3                   	ret    

00800395 <vprintfmt>:
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	57                   	push   %edi
  800399:	56                   	push   %esi
  80039a:	53                   	push   %ebx
  80039b:	83 ec 2c             	sub    $0x2c,%esp
  80039e:	e8 f4 fc ff ff       	call   800097 <__x86.get_pc_thunk.bx>
  8003a3:	81 c3 5d 1c 00 00    	add    $0x1c5d,%ebx
  8003a9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003ac:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003af:	e9 c3 03 00 00       	jmp    800777 <.L35+0x48>
		padc = ' ';
  8003b4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003b8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003bf:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003c6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d2:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d5:	8d 47 01             	lea    0x1(%edi),%eax
  8003d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003db:	0f b6 17             	movzbl (%edi),%edx
  8003de:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003e1:	3c 55                	cmp    $0x55,%al
  8003e3:	0f 87 16 04 00 00    	ja     8007ff <.L22>
  8003e9:	0f b6 c0             	movzbl %al,%eax
  8003ec:	89 d9                	mov    %ebx,%ecx
  8003ee:	03 8c 83 48 ef ff ff 	add    -0x10b8(%ebx,%eax,4),%ecx
  8003f5:	ff e1                	jmp    *%ecx

008003f7 <.L69>:
  8003f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003fa:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003fe:	eb d5                	jmp    8003d5 <vprintfmt+0x40>

00800400 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800403:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800407:	eb cc                	jmp    8003d5 <vprintfmt+0x40>

00800409 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	0f b6 d2             	movzbl %dl,%edx
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80040f:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800414:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800417:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80041b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80041e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800421:	83 f9 09             	cmp    $0x9,%ecx
  800424:	77 55                	ja     80047b <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  800426:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800429:	eb e9                	jmp    800414 <.L29+0xb>

0080042b <.L26>:
			precision = va_arg(ap, int);
  80042b:	8b 45 14             	mov    0x14(%ebp),%eax
  80042e:	8b 00                	mov    (%eax),%eax
  800430:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800433:	8b 45 14             	mov    0x14(%ebp),%eax
  800436:	8d 40 04             	lea    0x4(%eax),%eax
  800439:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80043f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800443:	79 90                	jns    8003d5 <vprintfmt+0x40>
				width = precision, precision = -1;
  800445:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800448:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044b:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800452:	eb 81                	jmp    8003d5 <vprintfmt+0x40>

00800454 <.L27>:
  800454:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800457:	85 c0                	test   %eax,%eax
  800459:	ba 00 00 00 00       	mov    $0x0,%edx
  80045e:	0f 49 d0             	cmovns %eax,%edx
  800461:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800467:	e9 69 ff ff ff       	jmp    8003d5 <vprintfmt+0x40>

0080046c <.L23>:
  80046c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80046f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800476:	e9 5a ff ff ff       	jmp    8003d5 <vprintfmt+0x40>
  80047b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80047e:	eb bf                	jmp    80043f <.L26+0x14>

00800480 <.L33>:
			lflag++;
  800480:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800487:	e9 49 ff ff ff       	jmp    8003d5 <vprintfmt+0x40>

0080048c <.L30>:
			putch(va_arg(ap, int), putdat);
  80048c:	8b 45 14             	mov    0x14(%ebp),%eax
  80048f:	8d 78 04             	lea    0x4(%eax),%edi
  800492:	83 ec 08             	sub    $0x8,%esp
  800495:	56                   	push   %esi
  800496:	ff 30                	pushl  (%eax)
  800498:	ff 55 08             	call   *0x8(%ebp)
			break;
  80049b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80049e:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004a1:	e9 ce 02 00 00       	jmp    800774 <.L35+0x45>

008004a6 <.L32>:
			err = va_arg(ap, int);
  8004a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a9:	8d 78 04             	lea    0x4(%eax),%edi
  8004ac:	8b 00                	mov    (%eax),%eax
  8004ae:	99                   	cltd   
  8004af:	31 d0                	xor    %edx,%eax
  8004b1:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b3:	83 f8 06             	cmp    $0x6,%eax
  8004b6:	7f 27                	jg     8004df <.L32+0x39>
  8004b8:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8004bf:	85 d2                	test   %edx,%edx
  8004c1:	74 1c                	je     8004df <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004c3:	52                   	push   %edx
  8004c4:	8d 83 db ee ff ff    	lea    -0x1125(%ebx),%eax
  8004ca:	50                   	push   %eax
  8004cb:	56                   	push   %esi
  8004cc:	ff 75 08             	pushl  0x8(%ebp)
  8004cf:	e8 a4 fe ff ff       	call   800378 <printfmt>
  8004d4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004d7:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004da:	e9 95 02 00 00       	jmp    800774 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004df:	50                   	push   %eax
  8004e0:	8d 83 d2 ee ff ff    	lea    -0x112e(%ebx),%eax
  8004e6:	50                   	push   %eax
  8004e7:	56                   	push   %esi
  8004e8:	ff 75 08             	pushl  0x8(%ebp)
  8004eb:	e8 88 fe ff ff       	call   800378 <printfmt>
  8004f0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004f3:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004f6:	e9 79 02 00 00       	jmp    800774 <.L35+0x45>

008004fb <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  8004fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fe:	83 c0 04             	add    $0x4,%eax
  800501:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800504:	8b 45 14             	mov    0x14(%ebp),%eax
  800507:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800509:	85 ff                	test   %edi,%edi
  80050b:	8d 83 cb ee ff ff    	lea    -0x1135(%ebx),%eax
  800511:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800514:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800518:	0f 8e b5 00 00 00    	jle    8005d3 <.L36+0xd8>
  80051e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800522:	75 08                	jne    80052c <.L36+0x31>
  800524:	89 75 0c             	mov    %esi,0xc(%ebp)
  800527:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80052a:	eb 6d                	jmp    800599 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	ff 75 cc             	pushl  -0x34(%ebp)
  800532:	57                   	push   %edi
  800533:	e8 85 03 00 00       	call   8008bd <strnlen>
  800538:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80053b:	29 c2                	sub    %eax,%edx
  80053d:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800540:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800543:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800547:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80054a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80054d:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80054f:	eb 10                	jmp    800561 <.L36+0x66>
					putch(padc, putdat);
  800551:	83 ec 08             	sub    $0x8,%esp
  800554:	56                   	push   %esi
  800555:	ff 75 e0             	pushl  -0x20(%ebp)
  800558:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80055b:	83 ef 01             	sub    $0x1,%edi
  80055e:	83 c4 10             	add    $0x10,%esp
  800561:	85 ff                	test   %edi,%edi
  800563:	7f ec                	jg     800551 <.L36+0x56>
  800565:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800568:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80056b:	85 d2                	test   %edx,%edx
  80056d:	b8 00 00 00 00       	mov    $0x0,%eax
  800572:	0f 49 c2             	cmovns %edx,%eax
  800575:	29 c2                	sub    %eax,%edx
  800577:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80057a:	89 75 0c             	mov    %esi,0xc(%ebp)
  80057d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800580:	eb 17                	jmp    800599 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  800582:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800586:	75 30                	jne    8005b8 <.L36+0xbd>
					putch(ch, putdat);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	ff 75 0c             	pushl  0xc(%ebp)
  80058e:	50                   	push   %eax
  80058f:	ff 55 08             	call   *0x8(%ebp)
  800592:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800595:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800599:	83 c7 01             	add    $0x1,%edi
  80059c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005a0:	0f be c2             	movsbl %dl,%eax
  8005a3:	85 c0                	test   %eax,%eax
  8005a5:	74 52                	je     8005f9 <.L36+0xfe>
  8005a7:	85 f6                	test   %esi,%esi
  8005a9:	78 d7                	js     800582 <.L36+0x87>
  8005ab:	83 ee 01             	sub    $0x1,%esi
  8005ae:	79 d2                	jns    800582 <.L36+0x87>
  8005b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005b3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005b6:	eb 32                	jmp    8005ea <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005b8:	0f be d2             	movsbl %dl,%edx
  8005bb:	83 ea 20             	sub    $0x20,%edx
  8005be:	83 fa 5e             	cmp    $0x5e,%edx
  8005c1:	76 c5                	jbe    800588 <.L36+0x8d>
					putch('?', putdat);
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	ff 75 0c             	pushl  0xc(%ebp)
  8005c9:	6a 3f                	push   $0x3f
  8005cb:	ff 55 08             	call   *0x8(%ebp)
  8005ce:	83 c4 10             	add    $0x10,%esp
  8005d1:	eb c2                	jmp    800595 <.L36+0x9a>
  8005d3:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005d6:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005d9:	eb be                	jmp    800599 <.L36+0x9e>
				putch(' ', putdat);
  8005db:	83 ec 08             	sub    $0x8,%esp
  8005de:	56                   	push   %esi
  8005df:	6a 20                	push   $0x20
  8005e1:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  8005e4:	83 ef 01             	sub    $0x1,%edi
  8005e7:	83 c4 10             	add    $0x10,%esp
  8005ea:	85 ff                	test   %edi,%edi
  8005ec:	7f ed                	jg     8005db <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  8005ee:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005f1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f4:	e9 7b 01 00 00       	jmp    800774 <.L35+0x45>
  8005f9:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005ff:	eb e9                	jmp    8005ea <.L36+0xef>

00800601 <.L31>:
  800601:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800604:	83 f9 01             	cmp    $0x1,%ecx
  800607:	7e 40                	jle    800649 <.L31+0x48>
		return va_arg(*ap, long long);
  800609:	8b 45 14             	mov    0x14(%ebp),%eax
  80060c:	8b 50 04             	mov    0x4(%eax),%edx
  80060f:	8b 00                	mov    (%eax),%eax
  800611:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800614:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8d 40 08             	lea    0x8(%eax),%eax
  80061d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800620:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800624:	79 55                	jns    80067b <.L31+0x7a>
				putch('-', putdat);
  800626:	83 ec 08             	sub    $0x8,%esp
  800629:	56                   	push   %esi
  80062a:	6a 2d                	push   $0x2d
  80062c:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80062f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800632:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800635:	f7 da                	neg    %edx
  800637:	83 d1 00             	adc    $0x0,%ecx
  80063a:	f7 d9                	neg    %ecx
  80063c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80063f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800644:	e9 10 01 00 00       	jmp    800759 <.L35+0x2a>
	else if (lflag)
  800649:	85 c9                	test   %ecx,%ecx
  80064b:	75 17                	jne    800664 <.L31+0x63>
		return va_arg(*ap, int);
  80064d:	8b 45 14             	mov    0x14(%ebp),%eax
  800650:	8b 00                	mov    (%eax),%eax
  800652:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800655:	99                   	cltd   
  800656:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8d 40 04             	lea    0x4(%eax),%eax
  80065f:	89 45 14             	mov    %eax,0x14(%ebp)
  800662:	eb bc                	jmp    800620 <.L31+0x1f>
		return va_arg(*ap, long);
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8b 00                	mov    (%eax),%eax
  800669:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066c:	99                   	cltd   
  80066d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8d 40 04             	lea    0x4(%eax),%eax
  800676:	89 45 14             	mov    %eax,0x14(%ebp)
  800679:	eb a5                	jmp    800620 <.L31+0x1f>
			num = getint(&ap, lflag);
  80067b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80067e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800681:	b8 0a 00 00 00       	mov    $0xa,%eax
  800686:	e9 ce 00 00 00       	jmp    800759 <.L35+0x2a>

0080068b <.L37>:
  80068b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80068e:	83 f9 01             	cmp    $0x1,%ecx
  800691:	7e 18                	jle    8006ab <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	8b 10                	mov    (%eax),%edx
  800698:	8b 48 04             	mov    0x4(%eax),%ecx
  80069b:	8d 40 08             	lea    0x8(%eax),%eax
  80069e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006a1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a6:	e9 ae 00 00 00       	jmp    800759 <.L35+0x2a>
	else if (lflag)
  8006ab:	85 c9                	test   %ecx,%ecx
  8006ad:	75 1a                	jne    8006c9 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8b 10                	mov    (%eax),%edx
  8006b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b9:	8d 40 04             	lea    0x4(%eax),%eax
  8006bc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c4:	e9 90 00 00 00       	jmp    800759 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8b 10                	mov    (%eax),%edx
  8006ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d3:	8d 40 04             	lea    0x4(%eax),%eax
  8006d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006de:	eb 79                	jmp    800759 <.L35+0x2a>

008006e0 <.L34>:
  8006e0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006e3:	83 f9 01             	cmp    $0x1,%ecx
  8006e6:	7e 15                	jle    8006fd <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8b 10                	mov    (%eax),%edx
  8006ed:	8b 48 04             	mov    0x4(%eax),%ecx
  8006f0:	8d 40 08             	lea    0x8(%eax),%eax
  8006f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006f6:	b8 08 00 00 00       	mov    $0x8,%eax
  8006fb:	eb 5c                	jmp    800759 <.L35+0x2a>
	else if (lflag)
  8006fd:	85 c9                	test   %ecx,%ecx
  8006ff:	75 17                	jne    800718 <.L34+0x38>
		return va_arg(*ap, unsigned int);
  800701:	8b 45 14             	mov    0x14(%ebp),%eax
  800704:	8b 10                	mov    (%eax),%edx
  800706:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070b:	8d 40 04             	lea    0x4(%eax),%eax
  80070e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800711:	b8 08 00 00 00       	mov    $0x8,%eax
  800716:	eb 41                	jmp    800759 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800718:	8b 45 14             	mov    0x14(%ebp),%eax
  80071b:	8b 10                	mov    (%eax),%edx
  80071d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800722:	8d 40 04             	lea    0x4(%eax),%eax
  800725:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800728:	b8 08 00 00 00       	mov    $0x8,%eax
  80072d:	eb 2a                	jmp    800759 <.L35+0x2a>

0080072f <.L35>:
			putch('0', putdat);
  80072f:	83 ec 08             	sub    $0x8,%esp
  800732:	56                   	push   %esi
  800733:	6a 30                	push   $0x30
  800735:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800738:	83 c4 08             	add    $0x8,%esp
  80073b:	56                   	push   %esi
  80073c:	6a 78                	push   $0x78
  80073e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800741:	8b 45 14             	mov    0x14(%ebp),%eax
  800744:	8b 10                	mov    (%eax),%edx
  800746:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80074b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80074e:	8d 40 04             	lea    0x4(%eax),%eax
  800751:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800754:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800759:	83 ec 0c             	sub    $0xc,%esp
  80075c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800760:	57                   	push   %edi
  800761:	ff 75 e0             	pushl  -0x20(%ebp)
  800764:	50                   	push   %eax
  800765:	51                   	push   %ecx
  800766:	52                   	push   %edx
  800767:	89 f2                	mov    %esi,%edx
  800769:	8b 45 08             	mov    0x8(%ebp),%eax
  80076c:	e8 20 fb ff ff       	call   800291 <printnum>
			break;
  800771:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800774:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800777:	83 c7 01             	add    $0x1,%edi
  80077a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80077e:	83 f8 25             	cmp    $0x25,%eax
  800781:	0f 84 2d fc ff ff    	je     8003b4 <vprintfmt+0x1f>
			if (ch == '\0')
  800787:	85 c0                	test   %eax,%eax
  800789:	0f 84 91 00 00 00    	je     800820 <.L22+0x21>
			putch(ch, putdat);
  80078f:	83 ec 08             	sub    $0x8,%esp
  800792:	56                   	push   %esi
  800793:	50                   	push   %eax
  800794:	ff 55 08             	call   *0x8(%ebp)
  800797:	83 c4 10             	add    $0x10,%esp
  80079a:	eb db                	jmp    800777 <.L35+0x48>

0080079c <.L38>:
  80079c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80079f:	83 f9 01             	cmp    $0x1,%ecx
  8007a2:	7e 15                	jle    8007b9 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8007a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a7:	8b 10                	mov    (%eax),%edx
  8007a9:	8b 48 04             	mov    0x4(%eax),%ecx
  8007ac:	8d 40 08             	lea    0x8(%eax),%eax
  8007af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b2:	b8 10 00 00 00       	mov    $0x10,%eax
  8007b7:	eb a0                	jmp    800759 <.L35+0x2a>
	else if (lflag)
  8007b9:	85 c9                	test   %ecx,%ecx
  8007bb:	75 17                	jne    8007d4 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8007bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c0:	8b 10                	mov    (%eax),%edx
  8007c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007c7:	8d 40 04             	lea    0x4(%eax),%eax
  8007ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007cd:	b8 10 00 00 00       	mov    $0x10,%eax
  8007d2:	eb 85                	jmp    800759 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d7:	8b 10                	mov    (%eax),%edx
  8007d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007de:	8d 40 04             	lea    0x4(%eax),%eax
  8007e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007e4:	b8 10 00 00 00       	mov    $0x10,%eax
  8007e9:	e9 6b ff ff ff       	jmp    800759 <.L35+0x2a>

008007ee <.L25>:
			putch(ch, putdat);
  8007ee:	83 ec 08             	sub    $0x8,%esp
  8007f1:	56                   	push   %esi
  8007f2:	6a 25                	push   $0x25
  8007f4:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007f7:	83 c4 10             	add    $0x10,%esp
  8007fa:	e9 75 ff ff ff       	jmp    800774 <.L35+0x45>

008007ff <.L22>:
			putch('%', putdat);
  8007ff:	83 ec 08             	sub    $0x8,%esp
  800802:	56                   	push   %esi
  800803:	6a 25                	push   $0x25
  800805:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800808:	83 c4 10             	add    $0x10,%esp
  80080b:	89 f8                	mov    %edi,%eax
  80080d:	eb 03                	jmp    800812 <.L22+0x13>
  80080f:	83 e8 01             	sub    $0x1,%eax
  800812:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800816:	75 f7                	jne    80080f <.L22+0x10>
  800818:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80081b:	e9 54 ff ff ff       	jmp    800774 <.L35+0x45>
}
  800820:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800823:	5b                   	pop    %ebx
  800824:	5e                   	pop    %esi
  800825:	5f                   	pop    %edi
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	53                   	push   %ebx
  80082c:	83 ec 14             	sub    $0x14,%esp
  80082f:	e8 63 f8 ff ff       	call   800097 <__x86.get_pc_thunk.bx>
  800834:	81 c3 cc 17 00 00    	add    $0x17cc,%ebx
  80083a:	8b 45 08             	mov    0x8(%ebp),%eax
  80083d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800840:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800843:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800847:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80084a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800851:	85 c0                	test   %eax,%eax
  800853:	74 2b                	je     800880 <vsnprintf+0x58>
  800855:	85 d2                	test   %edx,%edx
  800857:	7e 27                	jle    800880 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800859:	ff 75 14             	pushl  0x14(%ebp)
  80085c:	ff 75 10             	pushl  0x10(%ebp)
  80085f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800862:	50                   	push   %eax
  800863:	8d 83 5b e3 ff ff    	lea    -0x1ca5(%ebx),%eax
  800869:	50                   	push   %eax
  80086a:	e8 26 fb ff ff       	call   800395 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80086f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800872:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800875:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800878:	83 c4 10             	add    $0x10,%esp
}
  80087b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80087e:	c9                   	leave  
  80087f:	c3                   	ret    
		return -E_INVAL;
  800880:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800885:	eb f4                	jmp    80087b <vsnprintf+0x53>

00800887 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80088d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800890:	50                   	push   %eax
  800891:	ff 75 10             	pushl  0x10(%ebp)
  800894:	ff 75 0c             	pushl  0xc(%ebp)
  800897:	ff 75 08             	pushl  0x8(%ebp)
  80089a:	e8 89 ff ff ff       	call   800828 <vsnprintf>
	va_end(ap);

	return rc;
}
  80089f:	c9                   	leave  
  8008a0:	c3                   	ret    

008008a1 <__x86.get_pc_thunk.cx>:
  8008a1:	8b 0c 24             	mov    (%esp),%ecx
  8008a4:	c3                   	ret    

008008a5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b0:	eb 03                	jmp    8008b5 <strlen+0x10>
		n++;
  8008b2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008b5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b9:	75 f7                	jne    8008b2 <strlen+0xd>
	return n;
}
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cb:	eb 03                	jmp    8008d0 <strnlen+0x13>
		n++;
  8008cd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d0:	39 d0                	cmp    %edx,%eax
  8008d2:	74 06                	je     8008da <strnlen+0x1d>
  8008d4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008d8:	75 f3                	jne    8008cd <strnlen+0x10>
	return n;
}
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	53                   	push   %ebx
  8008e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e6:	89 c2                	mov    %eax,%edx
  8008e8:	83 c1 01             	add    $0x1,%ecx
  8008eb:	83 c2 01             	add    $0x1,%edx
  8008ee:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008f2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008f5:	84 db                	test   %bl,%bl
  8008f7:	75 ef                	jne    8008e8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008f9:	5b                   	pop    %ebx
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	53                   	push   %ebx
  800900:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800903:	53                   	push   %ebx
  800904:	e8 9c ff ff ff       	call   8008a5 <strlen>
  800909:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80090c:	ff 75 0c             	pushl  0xc(%ebp)
  80090f:	01 d8                	add    %ebx,%eax
  800911:	50                   	push   %eax
  800912:	e8 c5 ff ff ff       	call   8008dc <strcpy>
	return dst;
}
  800917:	89 d8                	mov    %ebx,%eax
  800919:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80091c:	c9                   	leave  
  80091d:	c3                   	ret    

0080091e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	56                   	push   %esi
  800922:	53                   	push   %ebx
  800923:	8b 75 08             	mov    0x8(%ebp),%esi
  800926:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800929:	89 f3                	mov    %esi,%ebx
  80092b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80092e:	89 f2                	mov    %esi,%edx
  800930:	eb 0f                	jmp    800941 <strncpy+0x23>
		*dst++ = *src;
  800932:	83 c2 01             	add    $0x1,%edx
  800935:	0f b6 01             	movzbl (%ecx),%eax
  800938:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80093b:	80 39 01             	cmpb   $0x1,(%ecx)
  80093e:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800941:	39 da                	cmp    %ebx,%edx
  800943:	75 ed                	jne    800932 <strncpy+0x14>
	}
	return ret;
}
  800945:	89 f0                	mov    %esi,%eax
  800947:	5b                   	pop    %ebx
  800948:	5e                   	pop    %esi
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	56                   	push   %esi
  80094f:	53                   	push   %ebx
  800950:	8b 75 08             	mov    0x8(%ebp),%esi
  800953:	8b 55 0c             	mov    0xc(%ebp),%edx
  800956:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800959:	89 f0                	mov    %esi,%eax
  80095b:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80095f:	85 c9                	test   %ecx,%ecx
  800961:	75 0b                	jne    80096e <strlcpy+0x23>
  800963:	eb 17                	jmp    80097c <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800965:	83 c2 01             	add    $0x1,%edx
  800968:	83 c0 01             	add    $0x1,%eax
  80096b:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80096e:	39 d8                	cmp    %ebx,%eax
  800970:	74 07                	je     800979 <strlcpy+0x2e>
  800972:	0f b6 0a             	movzbl (%edx),%ecx
  800975:	84 c9                	test   %cl,%cl
  800977:	75 ec                	jne    800965 <strlcpy+0x1a>
		*dst = '\0';
  800979:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80097c:	29 f0                	sub    %esi,%eax
}
  80097e:	5b                   	pop    %ebx
  80097f:	5e                   	pop    %esi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800988:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80098b:	eb 06                	jmp    800993 <strcmp+0x11>
		p++, q++;
  80098d:	83 c1 01             	add    $0x1,%ecx
  800990:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800993:	0f b6 01             	movzbl (%ecx),%eax
  800996:	84 c0                	test   %al,%al
  800998:	74 04                	je     80099e <strcmp+0x1c>
  80099a:	3a 02                	cmp    (%edx),%al
  80099c:	74 ef                	je     80098d <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80099e:	0f b6 c0             	movzbl %al,%eax
  8009a1:	0f b6 12             	movzbl (%edx),%edx
  8009a4:	29 d0                	sub    %edx,%eax
}
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    

008009a8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	53                   	push   %ebx
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b2:	89 c3                	mov    %eax,%ebx
  8009b4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009b7:	eb 06                	jmp    8009bf <strncmp+0x17>
		n--, p++, q++;
  8009b9:	83 c0 01             	add    $0x1,%eax
  8009bc:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009bf:	39 d8                	cmp    %ebx,%eax
  8009c1:	74 16                	je     8009d9 <strncmp+0x31>
  8009c3:	0f b6 08             	movzbl (%eax),%ecx
  8009c6:	84 c9                	test   %cl,%cl
  8009c8:	74 04                	je     8009ce <strncmp+0x26>
  8009ca:	3a 0a                	cmp    (%edx),%cl
  8009cc:	74 eb                	je     8009b9 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ce:	0f b6 00             	movzbl (%eax),%eax
  8009d1:	0f b6 12             	movzbl (%edx),%edx
  8009d4:	29 d0                	sub    %edx,%eax
}
  8009d6:	5b                   	pop    %ebx
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    
		return 0;
  8009d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009de:	eb f6                	jmp    8009d6 <strncmp+0x2e>

008009e0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ea:	0f b6 10             	movzbl (%eax),%edx
  8009ed:	84 d2                	test   %dl,%dl
  8009ef:	74 09                	je     8009fa <strchr+0x1a>
		if (*s == c)
  8009f1:	38 ca                	cmp    %cl,%dl
  8009f3:	74 0a                	je     8009ff <strchr+0x1f>
	for (; *s; s++)
  8009f5:	83 c0 01             	add    $0x1,%eax
  8009f8:	eb f0                	jmp    8009ea <strchr+0xa>
			return (char *) s;
	return 0;
  8009fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	8b 45 08             	mov    0x8(%ebp),%eax
  800a07:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a0b:	eb 03                	jmp    800a10 <strfind+0xf>
  800a0d:	83 c0 01             	add    $0x1,%eax
  800a10:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a13:	38 ca                	cmp    %cl,%dl
  800a15:	74 04                	je     800a1b <strfind+0x1a>
  800a17:	84 d2                	test   %dl,%dl
  800a19:	75 f2                	jne    800a0d <strfind+0xc>
			break;
	return (char *) s;
}
  800a1b:	5d                   	pop    %ebp
  800a1c:	c3                   	ret    

00800a1d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	57                   	push   %edi
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
  800a23:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a26:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a29:	85 c9                	test   %ecx,%ecx
  800a2b:	74 13                	je     800a40 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a2d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a33:	75 05                	jne    800a3a <memset+0x1d>
  800a35:	f6 c1 03             	test   $0x3,%cl
  800a38:	74 0d                	je     800a47 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3d:	fc                   	cld    
  800a3e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a40:	89 f8                	mov    %edi,%eax
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5f                   	pop    %edi
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    
		c &= 0xFF;
  800a47:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a4b:	89 d3                	mov    %edx,%ebx
  800a4d:	c1 e3 08             	shl    $0x8,%ebx
  800a50:	89 d0                	mov    %edx,%eax
  800a52:	c1 e0 18             	shl    $0x18,%eax
  800a55:	89 d6                	mov    %edx,%esi
  800a57:	c1 e6 10             	shl    $0x10,%esi
  800a5a:	09 f0                	or     %esi,%eax
  800a5c:	09 c2                	or     %eax,%edx
  800a5e:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a60:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a63:	89 d0                	mov    %edx,%eax
  800a65:	fc                   	cld    
  800a66:	f3 ab                	rep stos %eax,%es:(%edi)
  800a68:	eb d6                	jmp    800a40 <memset+0x23>

00800a6a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	57                   	push   %edi
  800a6e:	56                   	push   %esi
  800a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a72:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a75:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a78:	39 c6                	cmp    %eax,%esi
  800a7a:	73 35                	jae    800ab1 <memmove+0x47>
  800a7c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a7f:	39 c2                	cmp    %eax,%edx
  800a81:	76 2e                	jbe    800ab1 <memmove+0x47>
		s += n;
		d += n;
  800a83:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a86:	89 d6                	mov    %edx,%esi
  800a88:	09 fe                	or     %edi,%esi
  800a8a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a90:	74 0c                	je     800a9e <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a92:	83 ef 01             	sub    $0x1,%edi
  800a95:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a98:	fd                   	std    
  800a99:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a9b:	fc                   	cld    
  800a9c:	eb 21                	jmp    800abf <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9e:	f6 c1 03             	test   $0x3,%cl
  800aa1:	75 ef                	jne    800a92 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aa3:	83 ef 04             	sub    $0x4,%edi
  800aa6:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aa9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800aac:	fd                   	std    
  800aad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aaf:	eb ea                	jmp    800a9b <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab1:	89 f2                	mov    %esi,%edx
  800ab3:	09 c2                	or     %eax,%edx
  800ab5:	f6 c2 03             	test   $0x3,%dl
  800ab8:	74 09                	je     800ac3 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aba:	89 c7                	mov    %eax,%edi
  800abc:	fc                   	cld    
  800abd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800abf:	5e                   	pop    %esi
  800ac0:	5f                   	pop    %edi
  800ac1:	5d                   	pop    %ebp
  800ac2:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac3:	f6 c1 03             	test   $0x3,%cl
  800ac6:	75 f2                	jne    800aba <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ac8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800acb:	89 c7                	mov    %eax,%edi
  800acd:	fc                   	cld    
  800ace:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad0:	eb ed                	jmp    800abf <memmove+0x55>

00800ad2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ad5:	ff 75 10             	pushl  0x10(%ebp)
  800ad8:	ff 75 0c             	pushl  0xc(%ebp)
  800adb:	ff 75 08             	pushl  0x8(%ebp)
  800ade:	e8 87 ff ff ff       	call   800a6a <memmove>
}
  800ae3:	c9                   	leave  
  800ae4:	c3                   	ret    

00800ae5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	56                   	push   %esi
  800ae9:	53                   	push   %ebx
  800aea:	8b 45 08             	mov    0x8(%ebp),%eax
  800aed:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af0:	89 c6                	mov    %eax,%esi
  800af2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af5:	39 f0                	cmp    %esi,%eax
  800af7:	74 1c                	je     800b15 <memcmp+0x30>
		if (*s1 != *s2)
  800af9:	0f b6 08             	movzbl (%eax),%ecx
  800afc:	0f b6 1a             	movzbl (%edx),%ebx
  800aff:	38 d9                	cmp    %bl,%cl
  800b01:	75 08                	jne    800b0b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b03:	83 c0 01             	add    $0x1,%eax
  800b06:	83 c2 01             	add    $0x1,%edx
  800b09:	eb ea                	jmp    800af5 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b0b:	0f b6 c1             	movzbl %cl,%eax
  800b0e:	0f b6 db             	movzbl %bl,%ebx
  800b11:	29 d8                	sub    %ebx,%eax
  800b13:	eb 05                	jmp    800b1a <memcmp+0x35>
	}

	return 0;
  800b15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	8b 45 08             	mov    0x8(%ebp),%eax
  800b24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b27:	89 c2                	mov    %eax,%edx
  800b29:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b2c:	39 d0                	cmp    %edx,%eax
  800b2e:	73 09                	jae    800b39 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b30:	38 08                	cmp    %cl,(%eax)
  800b32:	74 05                	je     800b39 <memfind+0x1b>
	for (; s < ends; s++)
  800b34:	83 c0 01             	add    $0x1,%eax
  800b37:	eb f3                	jmp    800b2c <memfind+0xe>
			break;
	return (void *) s;
}
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	57                   	push   %edi
  800b3f:	56                   	push   %esi
  800b40:	53                   	push   %ebx
  800b41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b44:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b47:	eb 03                	jmp    800b4c <strtol+0x11>
		s++;
  800b49:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b4c:	0f b6 01             	movzbl (%ecx),%eax
  800b4f:	3c 20                	cmp    $0x20,%al
  800b51:	74 f6                	je     800b49 <strtol+0xe>
  800b53:	3c 09                	cmp    $0x9,%al
  800b55:	74 f2                	je     800b49 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b57:	3c 2b                	cmp    $0x2b,%al
  800b59:	74 2e                	je     800b89 <strtol+0x4e>
	int neg = 0;
  800b5b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b60:	3c 2d                	cmp    $0x2d,%al
  800b62:	74 2f                	je     800b93 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b64:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b6a:	75 05                	jne    800b71 <strtol+0x36>
  800b6c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b6f:	74 2c                	je     800b9d <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b71:	85 db                	test   %ebx,%ebx
  800b73:	75 0a                	jne    800b7f <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b75:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b7a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b7d:	74 28                	je     800ba7 <strtol+0x6c>
		base = 10;
  800b7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b84:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b87:	eb 50                	jmp    800bd9 <strtol+0x9e>
		s++;
  800b89:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b8c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b91:	eb d1                	jmp    800b64 <strtol+0x29>
		s++, neg = 1;
  800b93:	83 c1 01             	add    $0x1,%ecx
  800b96:	bf 01 00 00 00       	mov    $0x1,%edi
  800b9b:	eb c7                	jmp    800b64 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b9d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ba1:	74 0e                	je     800bb1 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ba3:	85 db                	test   %ebx,%ebx
  800ba5:	75 d8                	jne    800b7f <strtol+0x44>
		s++, base = 8;
  800ba7:	83 c1 01             	add    $0x1,%ecx
  800baa:	bb 08 00 00 00       	mov    $0x8,%ebx
  800baf:	eb ce                	jmp    800b7f <strtol+0x44>
		s += 2, base = 16;
  800bb1:	83 c1 02             	add    $0x2,%ecx
  800bb4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bb9:	eb c4                	jmp    800b7f <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bbb:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bbe:	89 f3                	mov    %esi,%ebx
  800bc0:	80 fb 19             	cmp    $0x19,%bl
  800bc3:	77 29                	ja     800bee <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bc5:	0f be d2             	movsbl %dl,%edx
  800bc8:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bcb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bce:	7d 30                	jge    800c00 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bd0:	83 c1 01             	add    $0x1,%ecx
  800bd3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bd7:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bd9:	0f b6 11             	movzbl (%ecx),%edx
  800bdc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bdf:	89 f3                	mov    %esi,%ebx
  800be1:	80 fb 09             	cmp    $0x9,%bl
  800be4:	77 d5                	ja     800bbb <strtol+0x80>
			dig = *s - '0';
  800be6:	0f be d2             	movsbl %dl,%edx
  800be9:	83 ea 30             	sub    $0x30,%edx
  800bec:	eb dd                	jmp    800bcb <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bee:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bf1:	89 f3                	mov    %esi,%ebx
  800bf3:	80 fb 19             	cmp    $0x19,%bl
  800bf6:	77 08                	ja     800c00 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bf8:	0f be d2             	movsbl %dl,%edx
  800bfb:	83 ea 37             	sub    $0x37,%edx
  800bfe:	eb cb                	jmp    800bcb <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c00:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c04:	74 05                	je     800c0b <strtol+0xd0>
		*endptr = (char *) s;
  800c06:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c09:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c0b:	89 c2                	mov    %eax,%edx
  800c0d:	f7 da                	neg    %edx
  800c0f:	85 ff                	test   %edi,%edi
  800c11:	0f 45 c2             	cmovne %edx,%eax
}
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    
  800c19:	66 90                	xchg   %ax,%ax
  800c1b:	66 90                	xchg   %ax,%ax
  800c1d:	66 90                	xchg   %ax,%ax
  800c1f:	90                   	nop

00800c20 <__udivdi3>:
  800c20:	55                   	push   %ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 1c             	sub    $0x1c,%esp
  800c27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c2b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c33:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c37:	85 d2                	test   %edx,%edx
  800c39:	75 35                	jne    800c70 <__udivdi3+0x50>
  800c3b:	39 f3                	cmp    %esi,%ebx
  800c3d:	0f 87 bd 00 00 00    	ja     800d00 <__udivdi3+0xe0>
  800c43:	85 db                	test   %ebx,%ebx
  800c45:	89 d9                	mov    %ebx,%ecx
  800c47:	75 0b                	jne    800c54 <__udivdi3+0x34>
  800c49:	b8 01 00 00 00       	mov    $0x1,%eax
  800c4e:	31 d2                	xor    %edx,%edx
  800c50:	f7 f3                	div    %ebx
  800c52:	89 c1                	mov    %eax,%ecx
  800c54:	31 d2                	xor    %edx,%edx
  800c56:	89 f0                	mov    %esi,%eax
  800c58:	f7 f1                	div    %ecx
  800c5a:	89 c6                	mov    %eax,%esi
  800c5c:	89 e8                	mov    %ebp,%eax
  800c5e:	89 f7                	mov    %esi,%edi
  800c60:	f7 f1                	div    %ecx
  800c62:	89 fa                	mov    %edi,%edx
  800c64:	83 c4 1c             	add    $0x1c,%esp
  800c67:	5b                   	pop    %ebx
  800c68:	5e                   	pop    %esi
  800c69:	5f                   	pop    %edi
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    
  800c6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c70:	39 f2                	cmp    %esi,%edx
  800c72:	77 7c                	ja     800cf0 <__udivdi3+0xd0>
  800c74:	0f bd fa             	bsr    %edx,%edi
  800c77:	83 f7 1f             	xor    $0x1f,%edi
  800c7a:	0f 84 98 00 00 00    	je     800d18 <__udivdi3+0xf8>
  800c80:	89 f9                	mov    %edi,%ecx
  800c82:	b8 20 00 00 00       	mov    $0x20,%eax
  800c87:	29 f8                	sub    %edi,%eax
  800c89:	d3 e2                	shl    %cl,%edx
  800c8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c8f:	89 c1                	mov    %eax,%ecx
  800c91:	89 da                	mov    %ebx,%edx
  800c93:	d3 ea                	shr    %cl,%edx
  800c95:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c99:	09 d1                	or     %edx,%ecx
  800c9b:	89 f2                	mov    %esi,%edx
  800c9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ca1:	89 f9                	mov    %edi,%ecx
  800ca3:	d3 e3                	shl    %cl,%ebx
  800ca5:	89 c1                	mov    %eax,%ecx
  800ca7:	d3 ea                	shr    %cl,%edx
  800ca9:	89 f9                	mov    %edi,%ecx
  800cab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800caf:	d3 e6                	shl    %cl,%esi
  800cb1:	89 eb                	mov    %ebp,%ebx
  800cb3:	89 c1                	mov    %eax,%ecx
  800cb5:	d3 eb                	shr    %cl,%ebx
  800cb7:	09 de                	or     %ebx,%esi
  800cb9:	89 f0                	mov    %esi,%eax
  800cbb:	f7 74 24 08          	divl   0x8(%esp)
  800cbf:	89 d6                	mov    %edx,%esi
  800cc1:	89 c3                	mov    %eax,%ebx
  800cc3:	f7 64 24 0c          	mull   0xc(%esp)
  800cc7:	39 d6                	cmp    %edx,%esi
  800cc9:	72 0c                	jb     800cd7 <__udivdi3+0xb7>
  800ccb:	89 f9                	mov    %edi,%ecx
  800ccd:	d3 e5                	shl    %cl,%ebp
  800ccf:	39 c5                	cmp    %eax,%ebp
  800cd1:	73 5d                	jae    800d30 <__udivdi3+0x110>
  800cd3:	39 d6                	cmp    %edx,%esi
  800cd5:	75 59                	jne    800d30 <__udivdi3+0x110>
  800cd7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cda:	31 ff                	xor    %edi,%edi
  800cdc:	89 fa                	mov    %edi,%edx
  800cde:	83 c4 1c             	add    $0x1c,%esp
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    
  800ce6:	8d 76 00             	lea    0x0(%esi),%esi
  800ce9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800cf0:	31 ff                	xor    %edi,%edi
  800cf2:	31 c0                	xor    %eax,%eax
  800cf4:	89 fa                	mov    %edi,%edx
  800cf6:	83 c4 1c             	add    $0x1c,%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    
  800cfe:	66 90                	xchg   %ax,%ax
  800d00:	31 ff                	xor    %edi,%edi
  800d02:	89 e8                	mov    %ebp,%eax
  800d04:	89 f2                	mov    %esi,%edx
  800d06:	f7 f3                	div    %ebx
  800d08:	89 fa                	mov    %edi,%edx
  800d0a:	83 c4 1c             	add    $0x1c,%esp
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    
  800d12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d18:	39 f2                	cmp    %esi,%edx
  800d1a:	72 06                	jb     800d22 <__udivdi3+0x102>
  800d1c:	31 c0                	xor    %eax,%eax
  800d1e:	39 eb                	cmp    %ebp,%ebx
  800d20:	77 d2                	ja     800cf4 <__udivdi3+0xd4>
  800d22:	b8 01 00 00 00       	mov    $0x1,%eax
  800d27:	eb cb                	jmp    800cf4 <__udivdi3+0xd4>
  800d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d30:	89 d8                	mov    %ebx,%eax
  800d32:	31 ff                	xor    %edi,%edi
  800d34:	eb be                	jmp    800cf4 <__udivdi3+0xd4>
  800d36:	66 90                	xchg   %ax,%ax
  800d38:	66 90                	xchg   %ax,%ax
  800d3a:	66 90                	xchg   %ax,%ax
  800d3c:	66 90                	xchg   %ax,%ax
  800d3e:	66 90                	xchg   %ax,%ax

00800d40 <__umoddi3>:
  800d40:	55                   	push   %ebp
  800d41:	57                   	push   %edi
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
  800d44:	83 ec 1c             	sub    $0x1c,%esp
  800d47:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800d4b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d4f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d57:	85 ed                	test   %ebp,%ebp
  800d59:	89 f0                	mov    %esi,%eax
  800d5b:	89 da                	mov    %ebx,%edx
  800d5d:	75 19                	jne    800d78 <__umoddi3+0x38>
  800d5f:	39 df                	cmp    %ebx,%edi
  800d61:	0f 86 b1 00 00 00    	jbe    800e18 <__umoddi3+0xd8>
  800d67:	f7 f7                	div    %edi
  800d69:	89 d0                	mov    %edx,%eax
  800d6b:	31 d2                	xor    %edx,%edx
  800d6d:	83 c4 1c             	add    $0x1c,%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    
  800d75:	8d 76 00             	lea    0x0(%esi),%esi
  800d78:	39 dd                	cmp    %ebx,%ebp
  800d7a:	77 f1                	ja     800d6d <__umoddi3+0x2d>
  800d7c:	0f bd cd             	bsr    %ebp,%ecx
  800d7f:	83 f1 1f             	xor    $0x1f,%ecx
  800d82:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d86:	0f 84 b4 00 00 00    	je     800e40 <__umoddi3+0x100>
  800d8c:	b8 20 00 00 00       	mov    $0x20,%eax
  800d91:	89 c2                	mov    %eax,%edx
  800d93:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d97:	29 c2                	sub    %eax,%edx
  800d99:	89 c1                	mov    %eax,%ecx
  800d9b:	89 f8                	mov    %edi,%eax
  800d9d:	d3 e5                	shl    %cl,%ebp
  800d9f:	89 d1                	mov    %edx,%ecx
  800da1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800da5:	d3 e8                	shr    %cl,%eax
  800da7:	09 c5                	or     %eax,%ebp
  800da9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dad:	89 c1                	mov    %eax,%ecx
  800daf:	d3 e7                	shl    %cl,%edi
  800db1:	89 d1                	mov    %edx,%ecx
  800db3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800db7:	89 df                	mov    %ebx,%edi
  800db9:	d3 ef                	shr    %cl,%edi
  800dbb:	89 c1                	mov    %eax,%ecx
  800dbd:	89 f0                	mov    %esi,%eax
  800dbf:	d3 e3                	shl    %cl,%ebx
  800dc1:	89 d1                	mov    %edx,%ecx
  800dc3:	89 fa                	mov    %edi,%edx
  800dc5:	d3 e8                	shr    %cl,%eax
  800dc7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800dcc:	09 d8                	or     %ebx,%eax
  800dce:	f7 f5                	div    %ebp
  800dd0:	d3 e6                	shl    %cl,%esi
  800dd2:	89 d1                	mov    %edx,%ecx
  800dd4:	f7 64 24 08          	mull   0x8(%esp)
  800dd8:	39 d1                	cmp    %edx,%ecx
  800dda:	89 c3                	mov    %eax,%ebx
  800ddc:	89 d7                	mov    %edx,%edi
  800dde:	72 06                	jb     800de6 <__umoddi3+0xa6>
  800de0:	75 0e                	jne    800df0 <__umoddi3+0xb0>
  800de2:	39 c6                	cmp    %eax,%esi
  800de4:	73 0a                	jae    800df0 <__umoddi3+0xb0>
  800de6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800dea:	19 ea                	sbb    %ebp,%edx
  800dec:	89 d7                	mov    %edx,%edi
  800dee:	89 c3                	mov    %eax,%ebx
  800df0:	89 ca                	mov    %ecx,%edx
  800df2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800df7:	29 de                	sub    %ebx,%esi
  800df9:	19 fa                	sbb    %edi,%edx
  800dfb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800dff:	89 d0                	mov    %edx,%eax
  800e01:	d3 e0                	shl    %cl,%eax
  800e03:	89 d9                	mov    %ebx,%ecx
  800e05:	d3 ee                	shr    %cl,%esi
  800e07:	d3 ea                	shr    %cl,%edx
  800e09:	09 f0                	or     %esi,%eax
  800e0b:	83 c4 1c             	add    $0x1c,%esp
  800e0e:	5b                   	pop    %ebx
  800e0f:	5e                   	pop    %esi
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    
  800e13:	90                   	nop
  800e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e18:	85 ff                	test   %edi,%edi
  800e1a:	89 f9                	mov    %edi,%ecx
  800e1c:	75 0b                	jne    800e29 <__umoddi3+0xe9>
  800e1e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e23:	31 d2                	xor    %edx,%edx
  800e25:	f7 f7                	div    %edi
  800e27:	89 c1                	mov    %eax,%ecx
  800e29:	89 d8                	mov    %ebx,%eax
  800e2b:	31 d2                	xor    %edx,%edx
  800e2d:	f7 f1                	div    %ecx
  800e2f:	89 f0                	mov    %esi,%eax
  800e31:	f7 f1                	div    %ecx
  800e33:	e9 31 ff ff ff       	jmp    800d69 <__umoddi3+0x29>
  800e38:	90                   	nop
  800e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e40:	39 dd                	cmp    %ebx,%ebp
  800e42:	72 08                	jb     800e4c <__umoddi3+0x10c>
  800e44:	39 f7                	cmp    %esi,%edi
  800e46:	0f 87 21 ff ff ff    	ja     800d6d <__umoddi3+0x2d>
  800e4c:	89 da                	mov    %ebx,%edx
  800e4e:	89 f0                	mov    %esi,%eax
  800e50:	29 f8                	sub    %edi,%eax
  800e52:	19 ea                	sbb    %ebp,%edx
  800e54:	e9 14 ff ff ff       	jmp    800d6d <__umoddi3+0x2d>
