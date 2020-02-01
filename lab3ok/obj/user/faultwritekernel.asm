
obj/user/faultwritekernel：     文件格式 elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	57                   	push   %edi
  800046:	56                   	push   %esi
  800047:	53                   	push   %ebx
  800048:	83 ec 0c             	sub    $0xc,%esp
  80004b:	e8 50 00 00 00       	call   8000a0 <__x86.get_pc_thunk.bx>
  800050:	81 c3 b0 1f 00 00    	add    $0x1fb0,%ebx
  800056:	8b 75 08             	mov    0x8(%ebp),%esi
  800059:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80005c:	e8 f6 00 00 00       	call   800157 <sys_getenvid>
  800061:	25 ff 03 00 00       	and    $0x3ff,%eax
  800066:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800069:	c1 e0 05             	shl    $0x5,%eax
  80006c:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800072:	c7 c2 2c 20 80 00    	mov    $0x80202c,%edx
  800078:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007a:	85 f6                	test   %esi,%esi
  80007c:	7e 08                	jle    800086 <libmain+0x44>
		binaryname = argv[0];
  80007e:	8b 07                	mov    (%edi),%eax
  800080:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800086:	83 ec 08             	sub    $0x8,%esp
  800089:	57                   	push   %edi
  80008a:	56                   	push   %esi
  80008b:	e8 a3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800090:	e8 0f 00 00 00       	call   8000a4 <exit>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80009b:	5b                   	pop    %ebx
  80009c:	5e                   	pop    %esi
  80009d:	5f                   	pop    %edi
  80009e:	5d                   	pop    %ebp
  80009f:	c3                   	ret    

008000a0 <__x86.get_pc_thunk.bx>:
  8000a0:	8b 1c 24             	mov    (%esp),%ebx
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	53                   	push   %ebx
  8000a8:	83 ec 10             	sub    $0x10,%esp
  8000ab:	e8 f0 ff ff ff       	call   8000a0 <__x86.get_pc_thunk.bx>
  8000b0:	81 c3 50 1f 00 00    	add    $0x1f50,%ebx
	sys_env_destroy(0);
  8000b6:	6a 00                	push   $0x0
  8000b8:	e8 45 00 00 00       	call   800102 <sys_env_destroy>
}
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d6:	89 c3                	mov    %eax,%ebx
  8000d8:	89 c7                	mov    %eax,%edi
  8000da:	89 c6                	mov    %eax,%esi
  8000dc:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f3:	89 d1                	mov    %edx,%ecx
  8000f5:	89 d3                	mov    %edx,%ebx
  8000f7:	89 d7                	mov    %edx,%edi
  8000f9:	89 d6                	mov    %edx,%esi
  8000fb:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	57                   	push   %edi
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	83 ec 1c             	sub    $0x1c,%esp
  80010b:	e8 66 00 00 00       	call   800176 <__x86.get_pc_thunk.ax>
  800110:	05 f0 1e 00 00       	add    $0x1ef0,%eax
  800115:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800118:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011d:	8b 55 08             	mov    0x8(%ebp),%edx
  800120:	b8 03 00 00 00       	mov    $0x3,%eax
  800125:	89 cb                	mov    %ecx,%ebx
  800127:	89 cf                	mov    %ecx,%edi
  800129:	89 ce                	mov    %ecx,%esi
  80012b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80012d:	85 c0                	test   %eax,%eax
  80012f:	7f 08                	jg     800139 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800131:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800134:	5b                   	pop    %ebx
  800135:	5e                   	pop    %esi
  800136:	5f                   	pop    %edi
  800137:	5d                   	pop    %ebp
  800138:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800139:	83 ec 0c             	sub    $0xc,%esp
  80013c:	50                   	push   %eax
  80013d:	6a 03                	push   $0x3
  80013f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800142:	8d 83 76 ee ff ff    	lea    -0x118a(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	6a 23                	push   $0x23
  80014b:	8d 83 93 ee ff ff    	lea    -0x116d(%ebx),%eax
  800151:	50                   	push   %eax
  800152:	e8 23 00 00 00       	call   80017a <_panic>

00800157 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	57                   	push   %edi
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80015d:	ba 00 00 00 00       	mov    $0x0,%edx
  800162:	b8 02 00 00 00       	mov    $0x2,%eax
  800167:	89 d1                	mov    %edx,%ecx
  800169:	89 d3                	mov    %edx,%ebx
  80016b:	89 d7                	mov    %edx,%edi
  80016d:	89 d6                	mov    %edx,%esi
  80016f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800171:	5b                   	pop    %ebx
  800172:	5e                   	pop    %esi
  800173:	5f                   	pop    %edi
  800174:	5d                   	pop    %ebp
  800175:	c3                   	ret    

00800176 <__x86.get_pc_thunk.ax>:
  800176:	8b 04 24             	mov    (%esp),%eax
  800179:	c3                   	ret    

0080017a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	57                   	push   %edi
  80017e:	56                   	push   %esi
  80017f:	53                   	push   %ebx
  800180:	83 ec 0c             	sub    $0xc,%esp
  800183:	e8 18 ff ff ff       	call   8000a0 <__x86.get_pc_thunk.bx>
  800188:	81 c3 78 1e 00 00    	add    $0x1e78,%ebx
	va_list ap;

	va_start(ap, fmt);
  80018e:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800191:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800197:	8b 38                	mov    (%eax),%edi
  800199:	e8 b9 ff ff ff       	call   800157 <sys_getenvid>
  80019e:	83 ec 0c             	sub    $0xc,%esp
  8001a1:	ff 75 0c             	pushl  0xc(%ebp)
  8001a4:	ff 75 08             	pushl  0x8(%ebp)
  8001a7:	57                   	push   %edi
  8001a8:	50                   	push   %eax
  8001a9:	8d 83 a4 ee ff ff    	lea    -0x115c(%ebx),%eax
  8001af:	50                   	push   %eax
  8001b0:	e8 d1 00 00 00       	call   800286 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b5:	83 c4 18             	add    $0x18,%esp
  8001b8:	56                   	push   %esi
  8001b9:	ff 75 10             	pushl  0x10(%ebp)
  8001bc:	e8 63 00 00 00       	call   800224 <vcprintf>
	cprintf("\n");
  8001c1:	8d 83 c8 ee ff ff    	lea    -0x1138(%ebx),%eax
  8001c7:	89 04 24             	mov    %eax,(%esp)
  8001ca:	e8 b7 00 00 00       	call   800286 <cprintf>
  8001cf:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d2:	cc                   	int3   
  8001d3:	eb fd                	jmp    8001d2 <_panic+0x58>

008001d5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	56                   	push   %esi
  8001d9:	53                   	push   %ebx
  8001da:	e8 c1 fe ff ff       	call   8000a0 <__x86.get_pc_thunk.bx>
  8001df:	81 c3 21 1e 00 00    	add    $0x1e21,%ebx
  8001e5:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001e8:	8b 16                	mov    (%esi),%edx
  8001ea:	8d 42 01             	lea    0x1(%edx),%eax
  8001ed:	89 06                	mov    %eax,(%esi)
  8001ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f2:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001fb:	74 0b                	je     800208 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001fd:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800201:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800204:	5b                   	pop    %ebx
  800205:	5e                   	pop    %esi
  800206:	5d                   	pop    %ebp
  800207:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	68 ff 00 00 00       	push   $0xff
  800210:	8d 46 08             	lea    0x8(%esi),%eax
  800213:	50                   	push   %eax
  800214:	e8 ac fe ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  800219:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80021f:	83 c4 10             	add    $0x10,%esp
  800222:	eb d9                	jmp    8001fd <putch+0x28>

00800224 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	53                   	push   %ebx
  800228:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80022e:	e8 6d fe ff ff       	call   8000a0 <__x86.get_pc_thunk.bx>
  800233:	81 c3 cd 1d 00 00    	add    $0x1dcd,%ebx
	struct printbuf b;

	b.idx = 0;
  800239:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800240:	00 00 00 
	b.cnt = 0;
  800243:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80024a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80024d:	ff 75 0c             	pushl  0xc(%ebp)
  800250:	ff 75 08             	pushl  0x8(%ebp)
  800253:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800259:	50                   	push   %eax
  80025a:	8d 83 d5 e1 ff ff    	lea    -0x1e2b(%ebx),%eax
  800260:	50                   	push   %eax
  800261:	e8 38 01 00 00       	call   80039e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800266:	83 c4 08             	add    $0x8,%esp
  800269:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80026f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800275:	50                   	push   %eax
  800276:	e8 4a fe ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  80027b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800281:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800284:	c9                   	leave  
  800285:	c3                   	ret    

00800286 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80028f:	50                   	push   %eax
  800290:	ff 75 08             	pushl  0x8(%ebp)
  800293:	e8 8c ff ff ff       	call   800224 <vcprintf>
	va_end(ap);

	return cnt;
}
  800298:	c9                   	leave  
  800299:	c3                   	ret    

0080029a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	57                   	push   %edi
  80029e:	56                   	push   %esi
  80029f:	53                   	push   %ebx
  8002a0:	83 ec 2c             	sub    $0x2c,%esp
  8002a3:	e8 02 06 00 00       	call   8008aa <__x86.get_pc_thunk.cx>
  8002a8:	81 c1 58 1d 00 00    	add    $0x1d58,%ecx
  8002ae:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002b1:	89 c7                	mov    %eax,%edi
  8002b3:	89 d6                	mov    %edx,%esi
  8002b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002be:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002cc:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002cf:	39 d3                	cmp    %edx,%ebx
  8002d1:	72 09                	jb     8002dc <printnum+0x42>
  8002d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d6:	0f 87 83 00 00 00    	ja     80035f <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002dc:	83 ec 0c             	sub    $0xc,%esp
  8002df:	ff 75 18             	pushl  0x18(%ebp)
  8002e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002e8:	53                   	push   %ebx
  8002e9:	ff 75 10             	pushl  0x10(%ebp)
  8002ec:	83 ec 08             	sub    $0x8,%esp
  8002ef:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f2:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002f8:	ff 75 d0             	pushl  -0x30(%ebp)
  8002fb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002fe:	e8 2d 09 00 00       	call   800c30 <__udivdi3>
  800303:	83 c4 18             	add    $0x18,%esp
  800306:	52                   	push   %edx
  800307:	50                   	push   %eax
  800308:	89 f2                	mov    %esi,%edx
  80030a:	89 f8                	mov    %edi,%eax
  80030c:	e8 89 ff ff ff       	call   80029a <printnum>
  800311:	83 c4 20             	add    $0x20,%esp
  800314:	eb 13                	jmp    800329 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800316:	83 ec 08             	sub    $0x8,%esp
  800319:	56                   	push   %esi
  80031a:	ff 75 18             	pushl  0x18(%ebp)
  80031d:	ff d7                	call   *%edi
  80031f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800322:	83 eb 01             	sub    $0x1,%ebx
  800325:	85 db                	test   %ebx,%ebx
  800327:	7f ed                	jg     800316 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800329:	83 ec 08             	sub    $0x8,%esp
  80032c:	56                   	push   %esi
  80032d:	83 ec 04             	sub    $0x4,%esp
  800330:	ff 75 dc             	pushl  -0x24(%ebp)
  800333:	ff 75 d8             	pushl  -0x28(%ebp)
  800336:	ff 75 d4             	pushl  -0x2c(%ebp)
  800339:	ff 75 d0             	pushl  -0x30(%ebp)
  80033c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80033f:	89 f3                	mov    %esi,%ebx
  800341:	e8 0a 0a 00 00       	call   800d50 <__umoddi3>
  800346:	83 c4 14             	add    $0x14,%esp
  800349:	0f be 84 06 ca ee ff 	movsbl -0x1136(%esi,%eax,1),%eax
  800350:	ff 
  800351:	50                   	push   %eax
  800352:	ff d7                	call   *%edi
}
  800354:	83 c4 10             	add    $0x10,%esp
  800357:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035a:	5b                   	pop    %ebx
  80035b:	5e                   	pop    %esi
  80035c:	5f                   	pop    %edi
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    
  80035f:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800362:	eb be                	jmp    800322 <printnum+0x88>

00800364 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80036e:	8b 10                	mov    (%eax),%edx
  800370:	3b 50 04             	cmp    0x4(%eax),%edx
  800373:	73 0a                	jae    80037f <sprintputch+0x1b>
		*b->buf++ = ch;
  800375:	8d 4a 01             	lea    0x1(%edx),%ecx
  800378:	89 08                	mov    %ecx,(%eax)
  80037a:	8b 45 08             	mov    0x8(%ebp),%eax
  80037d:	88 02                	mov    %al,(%edx)
}
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    

00800381 <printfmt>:
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
  800384:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800387:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038a:	50                   	push   %eax
  80038b:	ff 75 10             	pushl  0x10(%ebp)
  80038e:	ff 75 0c             	pushl  0xc(%ebp)
  800391:	ff 75 08             	pushl  0x8(%ebp)
  800394:	e8 05 00 00 00       	call   80039e <vprintfmt>
}
  800399:	83 c4 10             	add    $0x10,%esp
  80039c:	c9                   	leave  
  80039d:	c3                   	ret    

0080039e <vprintfmt>:
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	57                   	push   %edi
  8003a2:	56                   	push   %esi
  8003a3:	53                   	push   %ebx
  8003a4:	83 ec 2c             	sub    $0x2c,%esp
  8003a7:	e8 f4 fc ff ff       	call   8000a0 <__x86.get_pc_thunk.bx>
  8003ac:	81 c3 54 1c 00 00    	add    $0x1c54,%ebx
  8003b2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003b5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b8:	e9 c3 03 00 00       	jmp    800780 <.L35+0x48>
		padc = ' ';
  8003bd:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003c1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003c8:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003cf:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003db:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8d 47 01             	lea    0x1(%edi),%eax
  8003e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e4:	0f b6 17             	movzbl (%edi),%edx
  8003e7:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003ea:	3c 55                	cmp    $0x55,%al
  8003ec:	0f 87 16 04 00 00    	ja     800808 <.L22>
  8003f2:	0f b6 c0             	movzbl %al,%eax
  8003f5:	89 d9                	mov    %ebx,%ecx
  8003f7:	03 8c 83 58 ef ff ff 	add    -0x10a8(%ebx,%eax,4),%ecx
  8003fe:	ff e1                	jmp    *%ecx

00800400 <.L69>:
  800400:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800403:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800407:	eb d5                	jmp    8003de <vprintfmt+0x40>

00800409 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80040c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800410:	eb cc                	jmp    8003de <vprintfmt+0x40>

00800412 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  800412:	0f b6 d2             	movzbl %dl,%edx
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800418:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  80041d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800420:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800424:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800427:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80042a:	83 f9 09             	cmp    $0x9,%ecx
  80042d:	77 55                	ja     800484 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  80042f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800432:	eb e9                	jmp    80041d <.L29+0xb>

00800434 <.L26>:
			precision = va_arg(ap, int);
  800434:	8b 45 14             	mov    0x14(%ebp),%eax
  800437:	8b 00                	mov    (%eax),%eax
  800439:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80043c:	8b 45 14             	mov    0x14(%ebp),%eax
  80043f:	8d 40 04             	lea    0x4(%eax),%eax
  800442:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800445:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800448:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044c:	79 90                	jns    8003de <vprintfmt+0x40>
				width = precision, precision = -1;
  80044e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800451:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800454:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80045b:	eb 81                	jmp    8003de <vprintfmt+0x40>

0080045d <.L27>:
  80045d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800460:	85 c0                	test   %eax,%eax
  800462:	ba 00 00 00 00       	mov    $0x0,%edx
  800467:	0f 49 d0             	cmovns %eax,%edx
  80046a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800470:	e9 69 ff ff ff       	jmp    8003de <vprintfmt+0x40>

00800475 <.L23>:
  800475:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800478:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80047f:	e9 5a ff ff ff       	jmp    8003de <vprintfmt+0x40>
  800484:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800487:	eb bf                	jmp    800448 <.L26+0x14>

00800489 <.L33>:
			lflag++;
  800489:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80048d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800490:	e9 49 ff ff ff       	jmp    8003de <vprintfmt+0x40>

00800495 <.L30>:
			putch(va_arg(ap, int), putdat);
  800495:	8b 45 14             	mov    0x14(%ebp),%eax
  800498:	8d 78 04             	lea    0x4(%eax),%edi
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	56                   	push   %esi
  80049f:	ff 30                	pushl  (%eax)
  8004a1:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004a4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004a7:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004aa:	e9 ce 02 00 00       	jmp    80077d <.L35+0x45>

008004af <.L32>:
			err = va_arg(ap, int);
  8004af:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b2:	8d 78 04             	lea    0x4(%eax),%edi
  8004b5:	8b 00                	mov    (%eax),%eax
  8004b7:	99                   	cltd   
  8004b8:	31 d0                	xor    %edx,%eax
  8004ba:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004bc:	83 f8 06             	cmp    $0x6,%eax
  8004bf:	7f 27                	jg     8004e8 <.L32+0x39>
  8004c1:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8004c8:	85 d2                	test   %edx,%edx
  8004ca:	74 1c                	je     8004e8 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004cc:	52                   	push   %edx
  8004cd:	8d 83 eb ee ff ff    	lea    -0x1115(%ebx),%eax
  8004d3:	50                   	push   %eax
  8004d4:	56                   	push   %esi
  8004d5:	ff 75 08             	pushl  0x8(%ebp)
  8004d8:	e8 a4 fe ff ff       	call   800381 <printfmt>
  8004dd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004e0:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004e3:	e9 95 02 00 00       	jmp    80077d <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004e8:	50                   	push   %eax
  8004e9:	8d 83 e2 ee ff ff    	lea    -0x111e(%ebx),%eax
  8004ef:	50                   	push   %eax
  8004f0:	56                   	push   %esi
  8004f1:	ff 75 08             	pushl  0x8(%ebp)
  8004f4:	e8 88 fe ff ff       	call   800381 <printfmt>
  8004f9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004fc:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004ff:	e9 79 02 00 00       	jmp    80077d <.L35+0x45>

00800504 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800504:	8b 45 14             	mov    0x14(%ebp),%eax
  800507:	83 c0 04             	add    $0x4,%eax
  80050a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800512:	85 ff                	test   %edi,%edi
  800514:	8d 83 db ee ff ff    	lea    -0x1125(%ebx),%eax
  80051a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80051d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800521:	0f 8e b5 00 00 00    	jle    8005dc <.L36+0xd8>
  800527:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80052b:	75 08                	jne    800535 <.L36+0x31>
  80052d:	89 75 0c             	mov    %esi,0xc(%ebp)
  800530:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800533:	eb 6d                	jmp    8005a2 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	ff 75 cc             	pushl  -0x34(%ebp)
  80053b:	57                   	push   %edi
  80053c:	e8 85 03 00 00       	call   8008c6 <strnlen>
  800541:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800544:	29 c2                	sub    %eax,%edx
  800546:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800549:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80054c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800550:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800553:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800556:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800558:	eb 10                	jmp    80056a <.L36+0x66>
					putch(padc, putdat);
  80055a:	83 ec 08             	sub    $0x8,%esp
  80055d:	56                   	push   %esi
  80055e:	ff 75 e0             	pushl  -0x20(%ebp)
  800561:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800564:	83 ef 01             	sub    $0x1,%edi
  800567:	83 c4 10             	add    $0x10,%esp
  80056a:	85 ff                	test   %edi,%edi
  80056c:	7f ec                	jg     80055a <.L36+0x56>
  80056e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800571:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800574:	85 d2                	test   %edx,%edx
  800576:	b8 00 00 00 00       	mov    $0x0,%eax
  80057b:	0f 49 c2             	cmovns %edx,%eax
  80057e:	29 c2                	sub    %eax,%edx
  800580:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800583:	89 75 0c             	mov    %esi,0xc(%ebp)
  800586:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800589:	eb 17                	jmp    8005a2 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  80058b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80058f:	75 30                	jne    8005c1 <.L36+0xbd>
					putch(ch, putdat);
  800591:	83 ec 08             	sub    $0x8,%esp
  800594:	ff 75 0c             	pushl  0xc(%ebp)
  800597:	50                   	push   %eax
  800598:	ff 55 08             	call   *0x8(%ebp)
  80059b:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059e:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005a2:	83 c7 01             	add    $0x1,%edi
  8005a5:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005a9:	0f be c2             	movsbl %dl,%eax
  8005ac:	85 c0                	test   %eax,%eax
  8005ae:	74 52                	je     800602 <.L36+0xfe>
  8005b0:	85 f6                	test   %esi,%esi
  8005b2:	78 d7                	js     80058b <.L36+0x87>
  8005b4:	83 ee 01             	sub    $0x1,%esi
  8005b7:	79 d2                	jns    80058b <.L36+0x87>
  8005b9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005bc:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005bf:	eb 32                	jmp    8005f3 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005c1:	0f be d2             	movsbl %dl,%edx
  8005c4:	83 ea 20             	sub    $0x20,%edx
  8005c7:	83 fa 5e             	cmp    $0x5e,%edx
  8005ca:	76 c5                	jbe    800591 <.L36+0x8d>
					putch('?', putdat);
  8005cc:	83 ec 08             	sub    $0x8,%esp
  8005cf:	ff 75 0c             	pushl  0xc(%ebp)
  8005d2:	6a 3f                	push   $0x3f
  8005d4:	ff 55 08             	call   *0x8(%ebp)
  8005d7:	83 c4 10             	add    $0x10,%esp
  8005da:	eb c2                	jmp    80059e <.L36+0x9a>
  8005dc:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005df:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005e2:	eb be                	jmp    8005a2 <.L36+0x9e>
				putch(' ', putdat);
  8005e4:	83 ec 08             	sub    $0x8,%esp
  8005e7:	56                   	push   %esi
  8005e8:	6a 20                	push   $0x20
  8005ea:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  8005ed:	83 ef 01             	sub    $0x1,%edi
  8005f0:	83 c4 10             	add    $0x10,%esp
  8005f3:	85 ff                	test   %edi,%edi
  8005f5:	7f ed                	jg     8005e4 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  8005f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005fa:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fd:	e9 7b 01 00 00       	jmp    80077d <.L35+0x45>
  800602:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800605:	8b 75 0c             	mov    0xc(%ebp),%esi
  800608:	eb e9                	jmp    8005f3 <.L36+0xef>

0080060a <.L31>:
  80060a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80060d:	83 f9 01             	cmp    $0x1,%ecx
  800610:	7e 40                	jle    800652 <.L31+0x48>
		return va_arg(*ap, long long);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8b 50 04             	mov    0x4(%eax),%edx
  800618:	8b 00                	mov    (%eax),%eax
  80061a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 40 08             	lea    0x8(%eax),%eax
  800626:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800629:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062d:	79 55                	jns    800684 <.L31+0x7a>
				putch('-', putdat);
  80062f:	83 ec 08             	sub    $0x8,%esp
  800632:	56                   	push   %esi
  800633:	6a 2d                	push   $0x2d
  800635:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800638:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80063b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80063e:	f7 da                	neg    %edx
  800640:	83 d1 00             	adc    $0x0,%ecx
  800643:	f7 d9                	neg    %ecx
  800645:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800648:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064d:	e9 10 01 00 00       	jmp    800762 <.L35+0x2a>
	else if (lflag)
  800652:	85 c9                	test   %ecx,%ecx
  800654:	75 17                	jne    80066d <.L31+0x63>
		return va_arg(*ap, int);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8b 00                	mov    (%eax),%eax
  80065b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065e:	99                   	cltd   
  80065f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8d 40 04             	lea    0x4(%eax),%eax
  800668:	89 45 14             	mov    %eax,0x14(%ebp)
  80066b:	eb bc                	jmp    800629 <.L31+0x1f>
		return va_arg(*ap, long);
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8b 00                	mov    (%eax),%eax
  800672:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800675:	99                   	cltd   
  800676:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800679:	8b 45 14             	mov    0x14(%ebp),%eax
  80067c:	8d 40 04             	lea    0x4(%eax),%eax
  80067f:	89 45 14             	mov    %eax,0x14(%ebp)
  800682:	eb a5                	jmp    800629 <.L31+0x1f>
			num = getint(&ap, lflag);
  800684:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800687:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80068a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80068f:	e9 ce 00 00 00       	jmp    800762 <.L35+0x2a>

00800694 <.L37>:
  800694:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800697:	83 f9 01             	cmp    $0x1,%ecx
  80069a:	7e 18                	jle    8006b4 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8b 10                	mov    (%eax),%edx
  8006a1:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a4:	8d 40 08             	lea    0x8(%eax),%eax
  8006a7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006aa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006af:	e9 ae 00 00 00       	jmp    800762 <.L35+0x2a>
	else if (lflag)
  8006b4:	85 c9                	test   %ecx,%ecx
  8006b6:	75 1a                	jne    8006d2 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8b 10                	mov    (%eax),%edx
  8006bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c2:	8d 40 04             	lea    0x4(%eax),%eax
  8006c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006cd:	e9 90 00 00 00       	jmp    800762 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8b 10                	mov    (%eax),%edx
  8006d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006dc:	8d 40 04             	lea    0x4(%eax),%eax
  8006df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006e2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e7:	eb 79                	jmp    800762 <.L35+0x2a>

008006e9 <.L34>:
  8006e9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006ec:	83 f9 01             	cmp    $0x1,%ecx
  8006ef:	7e 15                	jle    800706 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  8006f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f4:	8b 10                	mov    (%eax),%edx
  8006f6:	8b 48 04             	mov    0x4(%eax),%ecx
  8006f9:	8d 40 08             	lea    0x8(%eax),%eax
  8006fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006ff:	b8 08 00 00 00       	mov    $0x8,%eax
  800704:	eb 5c                	jmp    800762 <.L35+0x2a>
	else if (lflag)
  800706:	85 c9                	test   %ecx,%ecx
  800708:	75 17                	jne    800721 <.L34+0x38>
		return va_arg(*ap, unsigned int);
  80070a:	8b 45 14             	mov    0x14(%ebp),%eax
  80070d:	8b 10                	mov    (%eax),%edx
  80070f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800714:	8d 40 04             	lea    0x4(%eax),%eax
  800717:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80071a:	b8 08 00 00 00       	mov    $0x8,%eax
  80071f:	eb 41                	jmp    800762 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800721:	8b 45 14             	mov    0x14(%ebp),%eax
  800724:	8b 10                	mov    (%eax),%edx
  800726:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072b:	8d 40 04             	lea    0x4(%eax),%eax
  80072e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800731:	b8 08 00 00 00       	mov    $0x8,%eax
  800736:	eb 2a                	jmp    800762 <.L35+0x2a>

00800738 <.L35>:
			putch('0', putdat);
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	56                   	push   %esi
  80073c:	6a 30                	push   $0x30
  80073e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800741:	83 c4 08             	add    $0x8,%esp
  800744:	56                   	push   %esi
  800745:	6a 78                	push   $0x78
  800747:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  80074a:	8b 45 14             	mov    0x14(%ebp),%eax
  80074d:	8b 10                	mov    (%eax),%edx
  80074f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800754:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800757:	8d 40 04             	lea    0x4(%eax),%eax
  80075a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80075d:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800762:	83 ec 0c             	sub    $0xc,%esp
  800765:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800769:	57                   	push   %edi
  80076a:	ff 75 e0             	pushl  -0x20(%ebp)
  80076d:	50                   	push   %eax
  80076e:	51                   	push   %ecx
  80076f:	52                   	push   %edx
  800770:	89 f2                	mov    %esi,%edx
  800772:	8b 45 08             	mov    0x8(%ebp),%eax
  800775:	e8 20 fb ff ff       	call   80029a <printnum>
			break;
  80077a:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80077d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800780:	83 c7 01             	add    $0x1,%edi
  800783:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800787:	83 f8 25             	cmp    $0x25,%eax
  80078a:	0f 84 2d fc ff ff    	je     8003bd <vprintfmt+0x1f>
			if (ch == '\0')
  800790:	85 c0                	test   %eax,%eax
  800792:	0f 84 91 00 00 00    	je     800829 <.L22+0x21>
			putch(ch, putdat);
  800798:	83 ec 08             	sub    $0x8,%esp
  80079b:	56                   	push   %esi
  80079c:	50                   	push   %eax
  80079d:	ff 55 08             	call   *0x8(%ebp)
  8007a0:	83 c4 10             	add    $0x10,%esp
  8007a3:	eb db                	jmp    800780 <.L35+0x48>

008007a5 <.L38>:
  8007a5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8007a8:	83 f9 01             	cmp    $0x1,%ecx
  8007ab:	7e 15                	jle    8007c2 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8007ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b0:	8b 10                	mov    (%eax),%edx
  8007b2:	8b 48 04             	mov    0x4(%eax),%ecx
  8007b5:	8d 40 08             	lea    0x8(%eax),%eax
  8007b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007bb:	b8 10 00 00 00       	mov    $0x10,%eax
  8007c0:	eb a0                	jmp    800762 <.L35+0x2a>
	else if (lflag)
  8007c2:	85 c9                	test   %ecx,%ecx
  8007c4:	75 17                	jne    8007dd <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8007c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c9:	8b 10                	mov    (%eax),%edx
  8007cb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d0:	8d 40 04             	lea    0x4(%eax),%eax
  8007d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d6:	b8 10 00 00 00       	mov    $0x10,%eax
  8007db:	eb 85                	jmp    800762 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8b 10                	mov    (%eax),%edx
  8007e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007e7:	8d 40 04             	lea    0x4(%eax),%eax
  8007ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ed:	b8 10 00 00 00       	mov    $0x10,%eax
  8007f2:	e9 6b ff ff ff       	jmp    800762 <.L35+0x2a>

008007f7 <.L25>:
			putch(ch, putdat);
  8007f7:	83 ec 08             	sub    $0x8,%esp
  8007fa:	56                   	push   %esi
  8007fb:	6a 25                	push   $0x25
  8007fd:	ff 55 08             	call   *0x8(%ebp)
			break;
  800800:	83 c4 10             	add    $0x10,%esp
  800803:	e9 75 ff ff ff       	jmp    80077d <.L35+0x45>

00800808 <.L22>:
			putch('%', putdat);
  800808:	83 ec 08             	sub    $0x8,%esp
  80080b:	56                   	push   %esi
  80080c:	6a 25                	push   $0x25
  80080e:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800811:	83 c4 10             	add    $0x10,%esp
  800814:	89 f8                	mov    %edi,%eax
  800816:	eb 03                	jmp    80081b <.L22+0x13>
  800818:	83 e8 01             	sub    $0x1,%eax
  80081b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80081f:	75 f7                	jne    800818 <.L22+0x10>
  800821:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800824:	e9 54 ff ff ff       	jmp    80077d <.L35+0x45>
}
  800829:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80082c:	5b                   	pop    %ebx
  80082d:	5e                   	pop    %esi
  80082e:	5f                   	pop    %edi
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	53                   	push   %ebx
  800835:	83 ec 14             	sub    $0x14,%esp
  800838:	e8 63 f8 ff ff       	call   8000a0 <__x86.get_pc_thunk.bx>
  80083d:	81 c3 c3 17 00 00    	add    $0x17c3,%ebx
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
  800846:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800849:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80084c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800850:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800853:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80085a:	85 c0                	test   %eax,%eax
  80085c:	74 2b                	je     800889 <vsnprintf+0x58>
  80085e:	85 d2                	test   %edx,%edx
  800860:	7e 27                	jle    800889 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800862:	ff 75 14             	pushl  0x14(%ebp)
  800865:	ff 75 10             	pushl  0x10(%ebp)
  800868:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80086b:	50                   	push   %eax
  80086c:	8d 83 64 e3 ff ff    	lea    -0x1c9c(%ebx),%eax
  800872:	50                   	push   %eax
  800873:	e8 26 fb ff ff       	call   80039e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800878:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80087b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80087e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800881:	83 c4 10             	add    $0x10,%esp
}
  800884:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800887:	c9                   	leave  
  800888:	c3                   	ret    
		return -E_INVAL;
  800889:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088e:	eb f4                	jmp    800884 <vsnprintf+0x53>

00800890 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800896:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800899:	50                   	push   %eax
  80089a:	ff 75 10             	pushl  0x10(%ebp)
  80089d:	ff 75 0c             	pushl  0xc(%ebp)
  8008a0:	ff 75 08             	pushl  0x8(%ebp)
  8008a3:	e8 89 ff ff ff       	call   800831 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a8:	c9                   	leave  
  8008a9:	c3                   	ret    

008008aa <__x86.get_pc_thunk.cx>:
  8008aa:	8b 0c 24             	mov    (%esp),%ecx
  8008ad:	c3                   	ret    

008008ae <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b9:	eb 03                	jmp    8008be <strlen+0x10>
		n++;
  8008bb:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008be:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c2:	75 f7                	jne    8008bb <strlen+0xd>
	return n;
}
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d4:	eb 03                	jmp    8008d9 <strnlen+0x13>
		n++;
  8008d6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d9:	39 d0                	cmp    %edx,%eax
  8008db:	74 06                	je     8008e3 <strnlen+0x1d>
  8008dd:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008e1:	75 f3                	jne    8008d6 <strnlen+0x10>
	return n;
}
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	53                   	push   %ebx
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ef:	89 c2                	mov    %eax,%edx
  8008f1:	83 c1 01             	add    $0x1,%ecx
  8008f4:	83 c2 01             	add    $0x1,%edx
  8008f7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008fb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008fe:	84 db                	test   %bl,%bl
  800900:	75 ef                	jne    8008f1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800902:	5b                   	pop    %ebx
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	53                   	push   %ebx
  800909:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80090c:	53                   	push   %ebx
  80090d:	e8 9c ff ff ff       	call   8008ae <strlen>
  800912:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800915:	ff 75 0c             	pushl  0xc(%ebp)
  800918:	01 d8                	add    %ebx,%eax
  80091a:	50                   	push   %eax
  80091b:	e8 c5 ff ff ff       	call   8008e5 <strcpy>
	return dst;
}
  800920:	89 d8                	mov    %ebx,%eax
  800922:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800925:	c9                   	leave  
  800926:	c3                   	ret    

00800927 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	56                   	push   %esi
  80092b:	53                   	push   %ebx
  80092c:	8b 75 08             	mov    0x8(%ebp),%esi
  80092f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800932:	89 f3                	mov    %esi,%ebx
  800934:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800937:	89 f2                	mov    %esi,%edx
  800939:	eb 0f                	jmp    80094a <strncpy+0x23>
		*dst++ = *src;
  80093b:	83 c2 01             	add    $0x1,%edx
  80093e:	0f b6 01             	movzbl (%ecx),%eax
  800941:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800944:	80 39 01             	cmpb   $0x1,(%ecx)
  800947:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80094a:	39 da                	cmp    %ebx,%edx
  80094c:	75 ed                	jne    80093b <strncpy+0x14>
	}
	return ret;
}
  80094e:	89 f0                	mov    %esi,%eax
  800950:	5b                   	pop    %ebx
  800951:	5e                   	pop    %esi
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	56                   	push   %esi
  800958:	53                   	push   %ebx
  800959:	8b 75 08             	mov    0x8(%ebp),%esi
  80095c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800962:	89 f0                	mov    %esi,%eax
  800964:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800968:	85 c9                	test   %ecx,%ecx
  80096a:	75 0b                	jne    800977 <strlcpy+0x23>
  80096c:	eb 17                	jmp    800985 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80096e:	83 c2 01             	add    $0x1,%edx
  800971:	83 c0 01             	add    $0x1,%eax
  800974:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800977:	39 d8                	cmp    %ebx,%eax
  800979:	74 07                	je     800982 <strlcpy+0x2e>
  80097b:	0f b6 0a             	movzbl (%edx),%ecx
  80097e:	84 c9                	test   %cl,%cl
  800980:	75 ec                	jne    80096e <strlcpy+0x1a>
		*dst = '\0';
  800982:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800985:	29 f0                	sub    %esi,%eax
}
  800987:	5b                   	pop    %ebx
  800988:	5e                   	pop    %esi
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800991:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800994:	eb 06                	jmp    80099c <strcmp+0x11>
		p++, q++;
  800996:	83 c1 01             	add    $0x1,%ecx
  800999:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80099c:	0f b6 01             	movzbl (%ecx),%eax
  80099f:	84 c0                	test   %al,%al
  8009a1:	74 04                	je     8009a7 <strcmp+0x1c>
  8009a3:	3a 02                	cmp    (%edx),%al
  8009a5:	74 ef                	je     800996 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a7:	0f b6 c0             	movzbl %al,%eax
  8009aa:	0f b6 12             	movzbl (%edx),%edx
  8009ad:	29 d0                	sub    %edx,%eax
}
  8009af:	5d                   	pop    %ebp
  8009b0:	c3                   	ret    

008009b1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	53                   	push   %ebx
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bb:	89 c3                	mov    %eax,%ebx
  8009bd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009c0:	eb 06                	jmp    8009c8 <strncmp+0x17>
		n--, p++, q++;
  8009c2:	83 c0 01             	add    $0x1,%eax
  8009c5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009c8:	39 d8                	cmp    %ebx,%eax
  8009ca:	74 16                	je     8009e2 <strncmp+0x31>
  8009cc:	0f b6 08             	movzbl (%eax),%ecx
  8009cf:	84 c9                	test   %cl,%cl
  8009d1:	74 04                	je     8009d7 <strncmp+0x26>
  8009d3:	3a 0a                	cmp    (%edx),%cl
  8009d5:	74 eb                	je     8009c2 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d7:	0f b6 00             	movzbl (%eax),%eax
  8009da:	0f b6 12             	movzbl (%edx),%edx
  8009dd:	29 d0                	sub    %edx,%eax
}
  8009df:	5b                   	pop    %ebx
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    
		return 0;
  8009e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e7:	eb f6                	jmp    8009df <strncmp+0x2e>

008009e9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f3:	0f b6 10             	movzbl (%eax),%edx
  8009f6:	84 d2                	test   %dl,%dl
  8009f8:	74 09                	je     800a03 <strchr+0x1a>
		if (*s == c)
  8009fa:	38 ca                	cmp    %cl,%dl
  8009fc:	74 0a                	je     800a08 <strchr+0x1f>
	for (; *s; s++)
  8009fe:	83 c0 01             	add    $0x1,%eax
  800a01:	eb f0                	jmp    8009f3 <strchr+0xa>
			return (char *) s;
	return 0;
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a14:	eb 03                	jmp    800a19 <strfind+0xf>
  800a16:	83 c0 01             	add    $0x1,%eax
  800a19:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a1c:	38 ca                	cmp    %cl,%dl
  800a1e:	74 04                	je     800a24 <strfind+0x1a>
  800a20:	84 d2                	test   %dl,%dl
  800a22:	75 f2                	jne    800a16 <strfind+0xc>
			break;
	return (char *) s;
}
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	57                   	push   %edi
  800a2a:	56                   	push   %esi
  800a2b:	53                   	push   %ebx
  800a2c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a32:	85 c9                	test   %ecx,%ecx
  800a34:	74 13                	je     800a49 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a36:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a3c:	75 05                	jne    800a43 <memset+0x1d>
  800a3e:	f6 c1 03             	test   $0x3,%cl
  800a41:	74 0d                	je     800a50 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a46:	fc                   	cld    
  800a47:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a49:	89 f8                	mov    %edi,%eax
  800a4b:	5b                   	pop    %ebx
  800a4c:	5e                   	pop    %esi
  800a4d:	5f                   	pop    %edi
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    
		c &= 0xFF;
  800a50:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a54:	89 d3                	mov    %edx,%ebx
  800a56:	c1 e3 08             	shl    $0x8,%ebx
  800a59:	89 d0                	mov    %edx,%eax
  800a5b:	c1 e0 18             	shl    $0x18,%eax
  800a5e:	89 d6                	mov    %edx,%esi
  800a60:	c1 e6 10             	shl    $0x10,%esi
  800a63:	09 f0                	or     %esi,%eax
  800a65:	09 c2                	or     %eax,%edx
  800a67:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a69:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a6c:	89 d0                	mov    %edx,%eax
  800a6e:	fc                   	cld    
  800a6f:	f3 ab                	rep stos %eax,%es:(%edi)
  800a71:	eb d6                	jmp    800a49 <memset+0x23>

00800a73 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	57                   	push   %edi
  800a77:	56                   	push   %esi
  800a78:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a81:	39 c6                	cmp    %eax,%esi
  800a83:	73 35                	jae    800aba <memmove+0x47>
  800a85:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a88:	39 c2                	cmp    %eax,%edx
  800a8a:	76 2e                	jbe    800aba <memmove+0x47>
		s += n;
		d += n;
  800a8c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8f:	89 d6                	mov    %edx,%esi
  800a91:	09 fe                	or     %edi,%esi
  800a93:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a99:	74 0c                	je     800aa7 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a9b:	83 ef 01             	sub    $0x1,%edi
  800a9e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aa1:	fd                   	std    
  800aa2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aa4:	fc                   	cld    
  800aa5:	eb 21                	jmp    800ac8 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa7:	f6 c1 03             	test   $0x3,%cl
  800aaa:	75 ef                	jne    800a9b <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aac:	83 ef 04             	sub    $0x4,%edi
  800aaf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ab2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ab5:	fd                   	std    
  800ab6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab8:	eb ea                	jmp    800aa4 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aba:	89 f2                	mov    %esi,%edx
  800abc:	09 c2                	or     %eax,%edx
  800abe:	f6 c2 03             	test   $0x3,%dl
  800ac1:	74 09                	je     800acc <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ac3:	89 c7                	mov    %eax,%edi
  800ac5:	fc                   	cld    
  800ac6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac8:	5e                   	pop    %esi
  800ac9:	5f                   	pop    %edi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800acc:	f6 c1 03             	test   $0x3,%cl
  800acf:	75 f2                	jne    800ac3 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ad1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ad4:	89 c7                	mov    %eax,%edi
  800ad6:	fc                   	cld    
  800ad7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad9:	eb ed                	jmp    800ac8 <memmove+0x55>

00800adb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ade:	ff 75 10             	pushl  0x10(%ebp)
  800ae1:	ff 75 0c             	pushl  0xc(%ebp)
  800ae4:	ff 75 08             	pushl  0x8(%ebp)
  800ae7:	e8 87 ff ff ff       	call   800a73 <memmove>
}
  800aec:	c9                   	leave  
  800aed:	c3                   	ret    

00800aee <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
  800af3:	8b 45 08             	mov    0x8(%ebp),%eax
  800af6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af9:	89 c6                	mov    %eax,%esi
  800afb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afe:	39 f0                	cmp    %esi,%eax
  800b00:	74 1c                	je     800b1e <memcmp+0x30>
		if (*s1 != *s2)
  800b02:	0f b6 08             	movzbl (%eax),%ecx
  800b05:	0f b6 1a             	movzbl (%edx),%ebx
  800b08:	38 d9                	cmp    %bl,%cl
  800b0a:	75 08                	jne    800b14 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b0c:	83 c0 01             	add    $0x1,%eax
  800b0f:	83 c2 01             	add    $0x1,%edx
  800b12:	eb ea                	jmp    800afe <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b14:	0f b6 c1             	movzbl %cl,%eax
  800b17:	0f b6 db             	movzbl %bl,%ebx
  800b1a:	29 d8                	sub    %ebx,%eax
  800b1c:	eb 05                	jmp    800b23 <memcmp+0x35>
	}

	return 0;
  800b1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b23:	5b                   	pop    %ebx
  800b24:	5e                   	pop    %esi
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b30:	89 c2                	mov    %eax,%edx
  800b32:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b35:	39 d0                	cmp    %edx,%eax
  800b37:	73 09                	jae    800b42 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b39:	38 08                	cmp    %cl,(%eax)
  800b3b:	74 05                	je     800b42 <memfind+0x1b>
	for (; s < ends; s++)
  800b3d:	83 c0 01             	add    $0x1,%eax
  800b40:	eb f3                	jmp    800b35 <memfind+0xe>
			break;
	return (void *) s;
}
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
  800b4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b50:	eb 03                	jmp    800b55 <strtol+0x11>
		s++;
  800b52:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b55:	0f b6 01             	movzbl (%ecx),%eax
  800b58:	3c 20                	cmp    $0x20,%al
  800b5a:	74 f6                	je     800b52 <strtol+0xe>
  800b5c:	3c 09                	cmp    $0x9,%al
  800b5e:	74 f2                	je     800b52 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b60:	3c 2b                	cmp    $0x2b,%al
  800b62:	74 2e                	je     800b92 <strtol+0x4e>
	int neg = 0;
  800b64:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b69:	3c 2d                	cmp    $0x2d,%al
  800b6b:	74 2f                	je     800b9c <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b6d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b73:	75 05                	jne    800b7a <strtol+0x36>
  800b75:	80 39 30             	cmpb   $0x30,(%ecx)
  800b78:	74 2c                	je     800ba6 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b7a:	85 db                	test   %ebx,%ebx
  800b7c:	75 0a                	jne    800b88 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b7e:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b83:	80 39 30             	cmpb   $0x30,(%ecx)
  800b86:	74 28                	je     800bb0 <strtol+0x6c>
		base = 10;
  800b88:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b90:	eb 50                	jmp    800be2 <strtol+0x9e>
		s++;
  800b92:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b95:	bf 00 00 00 00       	mov    $0x0,%edi
  800b9a:	eb d1                	jmp    800b6d <strtol+0x29>
		s++, neg = 1;
  800b9c:	83 c1 01             	add    $0x1,%ecx
  800b9f:	bf 01 00 00 00       	mov    $0x1,%edi
  800ba4:	eb c7                	jmp    800b6d <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800baa:	74 0e                	je     800bba <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bac:	85 db                	test   %ebx,%ebx
  800bae:	75 d8                	jne    800b88 <strtol+0x44>
		s++, base = 8;
  800bb0:	83 c1 01             	add    $0x1,%ecx
  800bb3:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bb8:	eb ce                	jmp    800b88 <strtol+0x44>
		s += 2, base = 16;
  800bba:	83 c1 02             	add    $0x2,%ecx
  800bbd:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bc2:	eb c4                	jmp    800b88 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bc4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bc7:	89 f3                	mov    %esi,%ebx
  800bc9:	80 fb 19             	cmp    $0x19,%bl
  800bcc:	77 29                	ja     800bf7 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bce:	0f be d2             	movsbl %dl,%edx
  800bd1:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bd4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bd7:	7d 30                	jge    800c09 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bd9:	83 c1 01             	add    $0x1,%ecx
  800bdc:	0f af 45 10          	imul   0x10(%ebp),%eax
  800be0:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800be2:	0f b6 11             	movzbl (%ecx),%edx
  800be5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800be8:	89 f3                	mov    %esi,%ebx
  800bea:	80 fb 09             	cmp    $0x9,%bl
  800bed:	77 d5                	ja     800bc4 <strtol+0x80>
			dig = *s - '0';
  800bef:	0f be d2             	movsbl %dl,%edx
  800bf2:	83 ea 30             	sub    $0x30,%edx
  800bf5:	eb dd                	jmp    800bd4 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bf7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bfa:	89 f3                	mov    %esi,%ebx
  800bfc:	80 fb 19             	cmp    $0x19,%bl
  800bff:	77 08                	ja     800c09 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c01:	0f be d2             	movsbl %dl,%edx
  800c04:	83 ea 37             	sub    $0x37,%edx
  800c07:	eb cb                	jmp    800bd4 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c09:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c0d:	74 05                	je     800c14 <strtol+0xd0>
		*endptr = (char *) s;
  800c0f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c12:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c14:	89 c2                	mov    %eax,%edx
  800c16:	f7 da                	neg    %edx
  800c18:	85 ff                	test   %edi,%edi
  800c1a:	0f 45 c2             	cmovne %edx,%eax
}
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    
  800c22:	66 90                	xchg   %ax,%ax
  800c24:	66 90                	xchg   %ax,%ax
  800c26:	66 90                	xchg   %ax,%ax
  800c28:	66 90                	xchg   %ax,%ax
  800c2a:	66 90                	xchg   %ax,%ax
  800c2c:	66 90                	xchg   %ax,%ax
  800c2e:	66 90                	xchg   %ax,%ax

00800c30 <__udivdi3>:
  800c30:	55                   	push   %ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
  800c34:	83 ec 1c             	sub    $0x1c,%esp
  800c37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c3b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c43:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c47:	85 d2                	test   %edx,%edx
  800c49:	75 35                	jne    800c80 <__udivdi3+0x50>
  800c4b:	39 f3                	cmp    %esi,%ebx
  800c4d:	0f 87 bd 00 00 00    	ja     800d10 <__udivdi3+0xe0>
  800c53:	85 db                	test   %ebx,%ebx
  800c55:	89 d9                	mov    %ebx,%ecx
  800c57:	75 0b                	jne    800c64 <__udivdi3+0x34>
  800c59:	b8 01 00 00 00       	mov    $0x1,%eax
  800c5e:	31 d2                	xor    %edx,%edx
  800c60:	f7 f3                	div    %ebx
  800c62:	89 c1                	mov    %eax,%ecx
  800c64:	31 d2                	xor    %edx,%edx
  800c66:	89 f0                	mov    %esi,%eax
  800c68:	f7 f1                	div    %ecx
  800c6a:	89 c6                	mov    %eax,%esi
  800c6c:	89 e8                	mov    %ebp,%eax
  800c6e:	89 f7                	mov    %esi,%edi
  800c70:	f7 f1                	div    %ecx
  800c72:	89 fa                	mov    %edi,%edx
  800c74:	83 c4 1c             	add    $0x1c,%esp
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    
  800c7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c80:	39 f2                	cmp    %esi,%edx
  800c82:	77 7c                	ja     800d00 <__udivdi3+0xd0>
  800c84:	0f bd fa             	bsr    %edx,%edi
  800c87:	83 f7 1f             	xor    $0x1f,%edi
  800c8a:	0f 84 98 00 00 00    	je     800d28 <__udivdi3+0xf8>
  800c90:	89 f9                	mov    %edi,%ecx
  800c92:	b8 20 00 00 00       	mov    $0x20,%eax
  800c97:	29 f8                	sub    %edi,%eax
  800c99:	d3 e2                	shl    %cl,%edx
  800c9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c9f:	89 c1                	mov    %eax,%ecx
  800ca1:	89 da                	mov    %ebx,%edx
  800ca3:	d3 ea                	shr    %cl,%edx
  800ca5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ca9:	09 d1                	or     %edx,%ecx
  800cab:	89 f2                	mov    %esi,%edx
  800cad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cb1:	89 f9                	mov    %edi,%ecx
  800cb3:	d3 e3                	shl    %cl,%ebx
  800cb5:	89 c1                	mov    %eax,%ecx
  800cb7:	d3 ea                	shr    %cl,%edx
  800cb9:	89 f9                	mov    %edi,%ecx
  800cbb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800cbf:	d3 e6                	shl    %cl,%esi
  800cc1:	89 eb                	mov    %ebp,%ebx
  800cc3:	89 c1                	mov    %eax,%ecx
  800cc5:	d3 eb                	shr    %cl,%ebx
  800cc7:	09 de                	or     %ebx,%esi
  800cc9:	89 f0                	mov    %esi,%eax
  800ccb:	f7 74 24 08          	divl   0x8(%esp)
  800ccf:	89 d6                	mov    %edx,%esi
  800cd1:	89 c3                	mov    %eax,%ebx
  800cd3:	f7 64 24 0c          	mull   0xc(%esp)
  800cd7:	39 d6                	cmp    %edx,%esi
  800cd9:	72 0c                	jb     800ce7 <__udivdi3+0xb7>
  800cdb:	89 f9                	mov    %edi,%ecx
  800cdd:	d3 e5                	shl    %cl,%ebp
  800cdf:	39 c5                	cmp    %eax,%ebp
  800ce1:	73 5d                	jae    800d40 <__udivdi3+0x110>
  800ce3:	39 d6                	cmp    %edx,%esi
  800ce5:	75 59                	jne    800d40 <__udivdi3+0x110>
  800ce7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cea:	31 ff                	xor    %edi,%edi
  800cec:	89 fa                	mov    %edi,%edx
  800cee:	83 c4 1c             	add    $0x1c,%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    
  800cf6:	8d 76 00             	lea    0x0(%esi),%esi
  800cf9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d00:	31 ff                	xor    %edi,%edi
  800d02:	31 c0                	xor    %eax,%eax
  800d04:	89 fa                	mov    %edi,%edx
  800d06:	83 c4 1c             	add    $0x1c,%esp
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    
  800d0e:	66 90                	xchg   %ax,%ax
  800d10:	31 ff                	xor    %edi,%edi
  800d12:	89 e8                	mov    %ebp,%eax
  800d14:	89 f2                	mov    %esi,%edx
  800d16:	f7 f3                	div    %ebx
  800d18:	89 fa                	mov    %edi,%edx
  800d1a:	83 c4 1c             	add    $0x1c,%esp
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    
  800d22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d28:	39 f2                	cmp    %esi,%edx
  800d2a:	72 06                	jb     800d32 <__udivdi3+0x102>
  800d2c:	31 c0                	xor    %eax,%eax
  800d2e:	39 eb                	cmp    %ebp,%ebx
  800d30:	77 d2                	ja     800d04 <__udivdi3+0xd4>
  800d32:	b8 01 00 00 00       	mov    $0x1,%eax
  800d37:	eb cb                	jmp    800d04 <__udivdi3+0xd4>
  800d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d40:	89 d8                	mov    %ebx,%eax
  800d42:	31 ff                	xor    %edi,%edi
  800d44:	eb be                	jmp    800d04 <__udivdi3+0xd4>
  800d46:	66 90                	xchg   %ax,%ax
  800d48:	66 90                	xchg   %ax,%ax
  800d4a:	66 90                	xchg   %ax,%ax
  800d4c:	66 90                	xchg   %ax,%ax
  800d4e:	66 90                	xchg   %ax,%ax

00800d50 <__umoddi3>:
  800d50:	55                   	push   %ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 1c             	sub    $0x1c,%esp
  800d57:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800d5b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d5f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d67:	85 ed                	test   %ebp,%ebp
  800d69:	89 f0                	mov    %esi,%eax
  800d6b:	89 da                	mov    %ebx,%edx
  800d6d:	75 19                	jne    800d88 <__umoddi3+0x38>
  800d6f:	39 df                	cmp    %ebx,%edi
  800d71:	0f 86 b1 00 00 00    	jbe    800e28 <__umoddi3+0xd8>
  800d77:	f7 f7                	div    %edi
  800d79:	89 d0                	mov    %edx,%eax
  800d7b:	31 d2                	xor    %edx,%edx
  800d7d:	83 c4 1c             	add    $0x1c,%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    
  800d85:	8d 76 00             	lea    0x0(%esi),%esi
  800d88:	39 dd                	cmp    %ebx,%ebp
  800d8a:	77 f1                	ja     800d7d <__umoddi3+0x2d>
  800d8c:	0f bd cd             	bsr    %ebp,%ecx
  800d8f:	83 f1 1f             	xor    $0x1f,%ecx
  800d92:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d96:	0f 84 b4 00 00 00    	je     800e50 <__umoddi3+0x100>
  800d9c:	b8 20 00 00 00       	mov    $0x20,%eax
  800da1:	89 c2                	mov    %eax,%edx
  800da3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800da7:	29 c2                	sub    %eax,%edx
  800da9:	89 c1                	mov    %eax,%ecx
  800dab:	89 f8                	mov    %edi,%eax
  800dad:	d3 e5                	shl    %cl,%ebp
  800daf:	89 d1                	mov    %edx,%ecx
  800db1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800db5:	d3 e8                	shr    %cl,%eax
  800db7:	09 c5                	or     %eax,%ebp
  800db9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dbd:	89 c1                	mov    %eax,%ecx
  800dbf:	d3 e7                	shl    %cl,%edi
  800dc1:	89 d1                	mov    %edx,%ecx
  800dc3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800dc7:	89 df                	mov    %ebx,%edi
  800dc9:	d3 ef                	shr    %cl,%edi
  800dcb:	89 c1                	mov    %eax,%ecx
  800dcd:	89 f0                	mov    %esi,%eax
  800dcf:	d3 e3                	shl    %cl,%ebx
  800dd1:	89 d1                	mov    %edx,%ecx
  800dd3:	89 fa                	mov    %edi,%edx
  800dd5:	d3 e8                	shr    %cl,%eax
  800dd7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ddc:	09 d8                	or     %ebx,%eax
  800dde:	f7 f5                	div    %ebp
  800de0:	d3 e6                	shl    %cl,%esi
  800de2:	89 d1                	mov    %edx,%ecx
  800de4:	f7 64 24 08          	mull   0x8(%esp)
  800de8:	39 d1                	cmp    %edx,%ecx
  800dea:	89 c3                	mov    %eax,%ebx
  800dec:	89 d7                	mov    %edx,%edi
  800dee:	72 06                	jb     800df6 <__umoddi3+0xa6>
  800df0:	75 0e                	jne    800e00 <__umoddi3+0xb0>
  800df2:	39 c6                	cmp    %eax,%esi
  800df4:	73 0a                	jae    800e00 <__umoddi3+0xb0>
  800df6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800dfa:	19 ea                	sbb    %ebp,%edx
  800dfc:	89 d7                	mov    %edx,%edi
  800dfe:	89 c3                	mov    %eax,%ebx
  800e00:	89 ca                	mov    %ecx,%edx
  800e02:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e07:	29 de                	sub    %ebx,%esi
  800e09:	19 fa                	sbb    %edi,%edx
  800e0b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800e0f:	89 d0                	mov    %edx,%eax
  800e11:	d3 e0                	shl    %cl,%eax
  800e13:	89 d9                	mov    %ebx,%ecx
  800e15:	d3 ee                	shr    %cl,%esi
  800e17:	d3 ea                	shr    %cl,%edx
  800e19:	09 f0                	or     %esi,%eax
  800e1b:	83 c4 1c             	add    $0x1c,%esp
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    
  800e23:	90                   	nop
  800e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e28:	85 ff                	test   %edi,%edi
  800e2a:	89 f9                	mov    %edi,%ecx
  800e2c:	75 0b                	jne    800e39 <__umoddi3+0xe9>
  800e2e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e33:	31 d2                	xor    %edx,%edx
  800e35:	f7 f7                	div    %edi
  800e37:	89 c1                	mov    %eax,%ecx
  800e39:	89 d8                	mov    %ebx,%eax
  800e3b:	31 d2                	xor    %edx,%edx
  800e3d:	f7 f1                	div    %ecx
  800e3f:	89 f0                	mov    %esi,%eax
  800e41:	f7 f1                	div    %ecx
  800e43:	e9 31 ff ff ff       	jmp    800d79 <__umoddi3+0x29>
  800e48:	90                   	nop
  800e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e50:	39 dd                	cmp    %ebx,%ebp
  800e52:	72 08                	jb     800e5c <__umoddi3+0x10c>
  800e54:	39 f7                	cmp    %esi,%edi
  800e56:	0f 87 21 ff ff ff    	ja     800d7d <__umoddi3+0x2d>
  800e5c:	89 da                	mov    %ebx,%edx
  800e5e:	89 f0                	mov    %esi,%eax
  800e60:	29 f8                	sub    %edi,%eax
  800e62:	19 ea                	sbb    %ebp,%edx
  800e64:	e9 14 ff ff ff       	jmp    800d7d <__umoddi3+0x2d>
