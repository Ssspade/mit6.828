
obj/user/evilhello：     文件格式 elf32-i386


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
  80002c:	e8 2c 00 00 00       	call   80005d <libmain>
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
  80003a:	e8 1a 00 00 00       	call   800059 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800045:	6a 64                	push   $0x64
  800047:	68 0c 00 10 f0       	push   $0xf010000c
  80004c:	e8 8b 00 00 00       	call   8000dc <sys_cputs>
}
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800057:	c9                   	leave  
  800058:	c3                   	ret    

00800059 <__x86.get_pc_thunk.bx>:
  800059:	8b 1c 24             	mov    (%esp),%ebx
  80005c:	c3                   	ret    

0080005d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005d:	55                   	push   %ebp
  80005e:	89 e5                	mov    %esp,%ebp
  800060:	57                   	push   %edi
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	e8 ee ff ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  80006b:	81 c3 95 1f 00 00    	add    $0x1f95,%ebx
  800071:	8b 75 08             	mov    0x8(%ebp),%esi
  800074:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800077:	e8 f2 00 00 00       	call   80016e <sys_getenvid>
  80007c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800081:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800084:	c1 e0 05             	shl    $0x5,%eax
  800087:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  80008d:	c7 c2 2c 20 80 00    	mov    $0x80202c,%edx
  800093:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800095:	85 f6                	test   %esi,%esi
  800097:	7e 08                	jle    8000a1 <libmain+0x44>
		binaryname = argv[0];
  800099:	8b 07                	mov    (%edi),%eax
  80009b:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000a1:	83 ec 08             	sub    $0x8,%esp
  8000a4:	57                   	push   %edi
  8000a5:	56                   	push   %esi
  8000a6:	e8 88 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ab:	e8 0b 00 00 00       	call   8000bb <exit>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b6:	5b                   	pop    %ebx
  8000b7:	5e                   	pop    %esi
  8000b8:	5f                   	pop    %edi
  8000b9:	5d                   	pop    %ebp
  8000ba:	c3                   	ret    

008000bb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bb:	55                   	push   %ebp
  8000bc:	89 e5                	mov    %esp,%ebp
  8000be:	53                   	push   %ebx
  8000bf:	83 ec 10             	sub    $0x10,%esp
  8000c2:	e8 92 ff ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  8000c7:	81 c3 39 1f 00 00    	add    $0x1f39,%ebx
	sys_env_destroy(0);
  8000cd:	6a 00                	push   $0x0
  8000cf:	e8 45 00 00 00       	call   800119 <sys_env_destroy>
}
  8000d4:	83 c4 10             	add    $0x10,%esp
  8000d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000da:	c9                   	leave  
  8000db:	c3                   	ret    

008000dc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	57                   	push   %edi
  8000e0:	56                   	push   %esi
  8000e1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ed:	89 c3                	mov    %eax,%ebx
  8000ef:	89 c7                	mov    %eax,%edi
  8000f1:	89 c6                	mov    %eax,%esi
  8000f3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000f5:	5b                   	pop    %ebx
  8000f6:	5e                   	pop    %esi
  8000f7:	5f                   	pop    %edi
  8000f8:	5d                   	pop    %ebp
  8000f9:	c3                   	ret    

008000fa <sys_cgetc>:

int
sys_cgetc(void)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	57                   	push   %edi
  8000fe:	56                   	push   %esi
  8000ff:	53                   	push   %ebx
	asm volatile("int %1\n"
  800100:	ba 00 00 00 00       	mov    $0x0,%edx
  800105:	b8 01 00 00 00       	mov    $0x1,%eax
  80010a:	89 d1                	mov    %edx,%ecx
  80010c:	89 d3                	mov    %edx,%ebx
  80010e:	89 d7                	mov    %edx,%edi
  800110:	89 d6                	mov    %edx,%esi
  800112:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800114:	5b                   	pop    %ebx
  800115:	5e                   	pop    %esi
  800116:	5f                   	pop    %edi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    

00800119 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	57                   	push   %edi
  80011d:	56                   	push   %esi
  80011e:	53                   	push   %ebx
  80011f:	83 ec 1c             	sub    $0x1c,%esp
  800122:	e8 66 00 00 00       	call   80018d <__x86.get_pc_thunk.ax>
  800127:	05 d9 1e 00 00       	add    $0x1ed9,%eax
  80012c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80012f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800134:	8b 55 08             	mov    0x8(%ebp),%edx
  800137:	b8 03 00 00 00       	mov    $0x3,%eax
  80013c:	89 cb                	mov    %ecx,%ebx
  80013e:	89 cf                	mov    %ecx,%edi
  800140:	89 ce                	mov    %ecx,%esi
  800142:	cd 30                	int    $0x30
	if(check && ret > 0)
  800144:	85 c0                	test   %eax,%eax
  800146:	7f 08                	jg     800150 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800148:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80014b:	5b                   	pop    %ebx
  80014c:	5e                   	pop    %esi
  80014d:	5f                   	pop    %edi
  80014e:	5d                   	pop    %ebp
  80014f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800150:	83 ec 0c             	sub    $0xc,%esp
  800153:	50                   	push   %eax
  800154:	6a 03                	push   $0x3
  800156:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800159:	8d 83 86 ee ff ff    	lea    -0x117a(%ebx),%eax
  80015f:	50                   	push   %eax
  800160:	6a 23                	push   $0x23
  800162:	8d 83 a3 ee ff ff    	lea    -0x115d(%ebx),%eax
  800168:	50                   	push   %eax
  800169:	e8 23 00 00 00       	call   800191 <_panic>

0080016e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016e:	55                   	push   %ebp
  80016f:	89 e5                	mov    %esp,%ebp
  800171:	57                   	push   %edi
  800172:	56                   	push   %esi
  800173:	53                   	push   %ebx
	asm volatile("int %1\n"
  800174:	ba 00 00 00 00       	mov    $0x0,%edx
  800179:	b8 02 00 00 00       	mov    $0x2,%eax
  80017e:	89 d1                	mov    %edx,%ecx
  800180:	89 d3                	mov    %edx,%ebx
  800182:	89 d7                	mov    %edx,%edi
  800184:	89 d6                	mov    %edx,%esi
  800186:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800188:	5b                   	pop    %ebx
  800189:	5e                   	pop    %esi
  80018a:	5f                   	pop    %edi
  80018b:	5d                   	pop    %ebp
  80018c:	c3                   	ret    

0080018d <__x86.get_pc_thunk.ax>:
  80018d:	8b 04 24             	mov    (%esp),%eax
  800190:	c3                   	ret    

00800191 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	57                   	push   %edi
  800195:	56                   	push   %esi
  800196:	53                   	push   %ebx
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	e8 ba fe ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  80019f:	81 c3 61 1e 00 00    	add    $0x1e61,%ebx
	va_list ap;

	va_start(ap, fmt);
  8001a5:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001a8:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  8001ae:	8b 38                	mov    (%eax),%edi
  8001b0:	e8 b9 ff ff ff       	call   80016e <sys_getenvid>
  8001b5:	83 ec 0c             	sub    $0xc,%esp
  8001b8:	ff 75 0c             	pushl  0xc(%ebp)
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	57                   	push   %edi
  8001bf:	50                   	push   %eax
  8001c0:	8d 83 b4 ee ff ff    	lea    -0x114c(%ebx),%eax
  8001c6:	50                   	push   %eax
  8001c7:	e8 d1 00 00 00       	call   80029d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001cc:	83 c4 18             	add    $0x18,%esp
  8001cf:	56                   	push   %esi
  8001d0:	ff 75 10             	pushl  0x10(%ebp)
  8001d3:	e8 63 00 00 00       	call   80023b <vcprintf>
	cprintf("\n");
  8001d8:	8d 83 d8 ee ff ff    	lea    -0x1128(%ebx),%eax
  8001de:	89 04 24             	mov    %eax,(%esp)
  8001e1:	e8 b7 00 00 00       	call   80029d <cprintf>
  8001e6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e9:	cc                   	int3   
  8001ea:	eb fd                	jmp    8001e9 <_panic+0x58>

008001ec <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	e8 63 fe ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  8001f6:	81 c3 0a 1e 00 00    	add    $0x1e0a,%ebx
  8001fc:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001ff:	8b 16                	mov    (%esi),%edx
  800201:	8d 42 01             	lea    0x1(%edx),%eax
  800204:	89 06                	mov    %eax,(%esi)
  800206:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800209:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  80020d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800212:	74 0b                	je     80021f <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800214:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800218:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80021b:	5b                   	pop    %ebx
  80021c:	5e                   	pop    %esi
  80021d:	5d                   	pop    %ebp
  80021e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80021f:	83 ec 08             	sub    $0x8,%esp
  800222:	68 ff 00 00 00       	push   $0xff
  800227:	8d 46 08             	lea    0x8(%esi),%eax
  80022a:	50                   	push   %eax
  80022b:	e8 ac fe ff ff       	call   8000dc <sys_cputs>
		b->idx = 0;
  800230:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800236:	83 c4 10             	add    $0x10,%esp
  800239:	eb d9                	jmp    800214 <putch+0x28>

0080023b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	53                   	push   %ebx
  80023f:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800245:	e8 0f fe ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  80024a:	81 c3 b6 1d 00 00    	add    $0x1db6,%ebx
	struct printbuf b;

	b.idx = 0;
  800250:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800257:	00 00 00 
	b.cnt = 0;
  80025a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800261:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800264:	ff 75 0c             	pushl  0xc(%ebp)
  800267:	ff 75 08             	pushl  0x8(%ebp)
  80026a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800270:	50                   	push   %eax
  800271:	8d 83 ec e1 ff ff    	lea    -0x1e14(%ebx),%eax
  800277:	50                   	push   %eax
  800278:	e8 38 01 00 00       	call   8003b5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80027d:	83 c4 08             	add    $0x8,%esp
  800280:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800286:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80028c:	50                   	push   %eax
  80028d:	e8 4a fe ff ff       	call   8000dc <sys_cputs>

	return b.cnt;
}
  800292:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800298:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029b:	c9                   	leave  
  80029c:	c3                   	ret    

0080029d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002a3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002a6:	50                   	push   %eax
  8002a7:	ff 75 08             	pushl  0x8(%ebp)
  8002aa:	e8 8c ff ff ff       	call   80023b <vcprintf>
	va_end(ap);

	return cnt;
}
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    

008002b1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 2c             	sub    $0x2c,%esp
  8002ba:	e8 02 06 00 00       	call   8008c1 <__x86.get_pc_thunk.cx>
  8002bf:	81 c1 41 1d 00 00    	add    $0x1d41,%ecx
  8002c5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002c8:	89 c7                	mov    %eax,%edi
  8002ca:	89 d6                	mov    %edx,%esi
  8002cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002d5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002e3:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002e6:	39 d3                	cmp    %edx,%ebx
  8002e8:	72 09                	jb     8002f3 <printnum+0x42>
  8002ea:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ed:	0f 87 83 00 00 00    	ja     800376 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f3:	83 ec 0c             	sub    $0xc,%esp
  8002f6:	ff 75 18             	pushl  0x18(%ebp)
  8002f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fc:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002ff:	53                   	push   %ebx
  800300:	ff 75 10             	pushl  0x10(%ebp)
  800303:	83 ec 08             	sub    $0x8,%esp
  800306:	ff 75 dc             	pushl  -0x24(%ebp)
  800309:	ff 75 d8             	pushl  -0x28(%ebp)
  80030c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80030f:	ff 75 d0             	pushl  -0x30(%ebp)
  800312:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800315:	e8 26 09 00 00       	call   800c40 <__udivdi3>
  80031a:	83 c4 18             	add    $0x18,%esp
  80031d:	52                   	push   %edx
  80031e:	50                   	push   %eax
  80031f:	89 f2                	mov    %esi,%edx
  800321:	89 f8                	mov    %edi,%eax
  800323:	e8 89 ff ff ff       	call   8002b1 <printnum>
  800328:	83 c4 20             	add    $0x20,%esp
  80032b:	eb 13                	jmp    800340 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032d:	83 ec 08             	sub    $0x8,%esp
  800330:	56                   	push   %esi
  800331:	ff 75 18             	pushl  0x18(%ebp)
  800334:	ff d7                	call   *%edi
  800336:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800339:	83 eb 01             	sub    $0x1,%ebx
  80033c:	85 db                	test   %ebx,%ebx
  80033e:	7f ed                	jg     80032d <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800340:	83 ec 08             	sub    $0x8,%esp
  800343:	56                   	push   %esi
  800344:	83 ec 04             	sub    $0x4,%esp
  800347:	ff 75 dc             	pushl  -0x24(%ebp)
  80034a:	ff 75 d8             	pushl  -0x28(%ebp)
  80034d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800350:	ff 75 d0             	pushl  -0x30(%ebp)
  800353:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800356:	89 f3                	mov    %esi,%ebx
  800358:	e8 03 0a 00 00       	call   800d60 <__umoddi3>
  80035d:	83 c4 14             	add    $0x14,%esp
  800360:	0f be 84 06 da ee ff 	movsbl -0x1126(%esi,%eax,1),%eax
  800367:	ff 
  800368:	50                   	push   %eax
  800369:	ff d7                	call   *%edi
}
  80036b:	83 c4 10             	add    $0x10,%esp
  80036e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800371:	5b                   	pop    %ebx
  800372:	5e                   	pop    %esi
  800373:	5f                   	pop    %edi
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    
  800376:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800379:	eb be                	jmp    800339 <printnum+0x88>

0080037b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800381:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800385:	8b 10                	mov    (%eax),%edx
  800387:	3b 50 04             	cmp    0x4(%eax),%edx
  80038a:	73 0a                	jae    800396 <sprintputch+0x1b>
		*b->buf++ = ch;
  80038c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80038f:	89 08                	mov    %ecx,(%eax)
  800391:	8b 45 08             	mov    0x8(%ebp),%eax
  800394:	88 02                	mov    %al,(%edx)
}
  800396:	5d                   	pop    %ebp
  800397:	c3                   	ret    

00800398 <printfmt>:
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80039e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a1:	50                   	push   %eax
  8003a2:	ff 75 10             	pushl  0x10(%ebp)
  8003a5:	ff 75 0c             	pushl  0xc(%ebp)
  8003a8:	ff 75 08             	pushl  0x8(%ebp)
  8003ab:	e8 05 00 00 00       	call   8003b5 <vprintfmt>
}
  8003b0:	83 c4 10             	add    $0x10,%esp
  8003b3:	c9                   	leave  
  8003b4:	c3                   	ret    

008003b5 <vprintfmt>:
{
  8003b5:	55                   	push   %ebp
  8003b6:	89 e5                	mov    %esp,%ebp
  8003b8:	57                   	push   %edi
  8003b9:	56                   	push   %esi
  8003ba:	53                   	push   %ebx
  8003bb:	83 ec 2c             	sub    $0x2c,%esp
  8003be:	e8 96 fc ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  8003c3:	81 c3 3d 1c 00 00    	add    $0x1c3d,%ebx
  8003c9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003cc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003cf:	e9 c3 03 00 00       	jmp    800797 <.L35+0x48>
		padc = ' ';
  8003d4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003d8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003df:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003e6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f2:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8d 47 01             	lea    0x1(%edi),%eax
  8003f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003fb:	0f b6 17             	movzbl (%edi),%edx
  8003fe:	8d 42 dd             	lea    -0x23(%edx),%eax
  800401:	3c 55                	cmp    $0x55,%al
  800403:	0f 87 16 04 00 00    	ja     80081f <.L22>
  800409:	0f b6 c0             	movzbl %al,%eax
  80040c:	89 d9                	mov    %ebx,%ecx
  80040e:	03 8c 83 68 ef ff ff 	add    -0x1098(%ebx,%eax,4),%ecx
  800415:	ff e1                	jmp    *%ecx

00800417 <.L69>:
  800417:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80041a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80041e:	eb d5                	jmp    8003f5 <vprintfmt+0x40>

00800420 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800423:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800427:	eb cc                	jmp    8003f5 <vprintfmt+0x40>

00800429 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  800429:	0f b6 d2             	movzbl %dl,%edx
  80042c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80042f:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800434:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800437:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80043b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80043e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800441:	83 f9 09             	cmp    $0x9,%ecx
  800444:	77 55                	ja     80049b <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  800446:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800449:	eb e9                	jmp    800434 <.L29+0xb>

0080044b <.L26>:
			precision = va_arg(ap, int);
  80044b:	8b 45 14             	mov    0x14(%ebp),%eax
  80044e:	8b 00                	mov    (%eax),%eax
  800450:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800453:	8b 45 14             	mov    0x14(%ebp),%eax
  800456:	8d 40 04             	lea    0x4(%eax),%eax
  800459:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80045c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80045f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800463:	79 90                	jns    8003f5 <vprintfmt+0x40>
				width = precision, precision = -1;
  800465:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800468:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80046b:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800472:	eb 81                	jmp    8003f5 <vprintfmt+0x40>

00800474 <.L27>:
  800474:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800477:	85 c0                	test   %eax,%eax
  800479:	ba 00 00 00 00       	mov    $0x0,%edx
  80047e:	0f 49 d0             	cmovns %eax,%edx
  800481:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800487:	e9 69 ff ff ff       	jmp    8003f5 <vprintfmt+0x40>

0080048c <.L23>:
  80048c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80048f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800496:	e9 5a ff ff ff       	jmp    8003f5 <vprintfmt+0x40>
  80049b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80049e:	eb bf                	jmp    80045f <.L26+0x14>

008004a0 <.L33>:
			lflag++;
  8004a0:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004a7:	e9 49 ff ff ff       	jmp    8003f5 <vprintfmt+0x40>

008004ac <.L30>:
			putch(va_arg(ap, int), putdat);
  8004ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8004af:	8d 78 04             	lea    0x4(%eax),%edi
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	56                   	push   %esi
  8004b6:	ff 30                	pushl  (%eax)
  8004b8:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004bb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004be:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004c1:	e9 ce 02 00 00       	jmp    800794 <.L35+0x45>

008004c6 <.L32>:
			err = va_arg(ap, int);
  8004c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c9:	8d 78 04             	lea    0x4(%eax),%edi
  8004cc:	8b 00                	mov    (%eax),%eax
  8004ce:	99                   	cltd   
  8004cf:	31 d0                	xor    %edx,%eax
  8004d1:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d3:	83 f8 06             	cmp    $0x6,%eax
  8004d6:	7f 27                	jg     8004ff <.L32+0x39>
  8004d8:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8004df:	85 d2                	test   %edx,%edx
  8004e1:	74 1c                	je     8004ff <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004e3:	52                   	push   %edx
  8004e4:	8d 83 fb ee ff ff    	lea    -0x1105(%ebx),%eax
  8004ea:	50                   	push   %eax
  8004eb:	56                   	push   %esi
  8004ec:	ff 75 08             	pushl  0x8(%ebp)
  8004ef:	e8 a4 fe ff ff       	call   800398 <printfmt>
  8004f4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004f7:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004fa:	e9 95 02 00 00       	jmp    800794 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004ff:	50                   	push   %eax
  800500:	8d 83 f2 ee ff ff    	lea    -0x110e(%ebx),%eax
  800506:	50                   	push   %eax
  800507:	56                   	push   %esi
  800508:	ff 75 08             	pushl  0x8(%ebp)
  80050b:	e8 88 fe ff ff       	call   800398 <printfmt>
  800510:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800513:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800516:	e9 79 02 00 00       	jmp    800794 <.L35+0x45>

0080051b <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	83 c0 04             	add    $0x4,%eax
  800521:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800529:	85 ff                	test   %edi,%edi
  80052b:	8d 83 eb ee ff ff    	lea    -0x1115(%ebx),%eax
  800531:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800534:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800538:	0f 8e b5 00 00 00    	jle    8005f3 <.L36+0xd8>
  80053e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800542:	75 08                	jne    80054c <.L36+0x31>
  800544:	89 75 0c             	mov    %esi,0xc(%ebp)
  800547:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80054a:	eb 6d                	jmp    8005b9 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	ff 75 cc             	pushl  -0x34(%ebp)
  800552:	57                   	push   %edi
  800553:	e8 85 03 00 00       	call   8008dd <strnlen>
  800558:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80055b:	29 c2                	sub    %eax,%edx
  80055d:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800560:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800563:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800567:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80056a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80056d:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80056f:	eb 10                	jmp    800581 <.L36+0x66>
					putch(padc, putdat);
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	56                   	push   %esi
  800575:	ff 75 e0             	pushl  -0x20(%ebp)
  800578:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80057b:	83 ef 01             	sub    $0x1,%edi
  80057e:	83 c4 10             	add    $0x10,%esp
  800581:	85 ff                	test   %edi,%edi
  800583:	7f ec                	jg     800571 <.L36+0x56>
  800585:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800588:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80058b:	85 d2                	test   %edx,%edx
  80058d:	b8 00 00 00 00       	mov    $0x0,%eax
  800592:	0f 49 c2             	cmovns %edx,%eax
  800595:	29 c2                	sub    %eax,%edx
  800597:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80059a:	89 75 0c             	mov    %esi,0xc(%ebp)
  80059d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005a0:	eb 17                	jmp    8005b9 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  8005a2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a6:	75 30                	jne    8005d8 <.L36+0xbd>
					putch(ch, putdat);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	ff 75 0c             	pushl  0xc(%ebp)
  8005ae:	50                   	push   %eax
  8005af:	ff 55 08             	call   *0x8(%ebp)
  8005b2:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b5:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005b9:	83 c7 01             	add    $0x1,%edi
  8005bc:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005c0:	0f be c2             	movsbl %dl,%eax
  8005c3:	85 c0                	test   %eax,%eax
  8005c5:	74 52                	je     800619 <.L36+0xfe>
  8005c7:	85 f6                	test   %esi,%esi
  8005c9:	78 d7                	js     8005a2 <.L36+0x87>
  8005cb:	83 ee 01             	sub    $0x1,%esi
  8005ce:	79 d2                	jns    8005a2 <.L36+0x87>
  8005d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005d3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005d6:	eb 32                	jmp    80060a <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005d8:	0f be d2             	movsbl %dl,%edx
  8005db:	83 ea 20             	sub    $0x20,%edx
  8005de:	83 fa 5e             	cmp    $0x5e,%edx
  8005e1:	76 c5                	jbe    8005a8 <.L36+0x8d>
					putch('?', putdat);
  8005e3:	83 ec 08             	sub    $0x8,%esp
  8005e6:	ff 75 0c             	pushl  0xc(%ebp)
  8005e9:	6a 3f                	push   $0x3f
  8005eb:	ff 55 08             	call   *0x8(%ebp)
  8005ee:	83 c4 10             	add    $0x10,%esp
  8005f1:	eb c2                	jmp    8005b5 <.L36+0x9a>
  8005f3:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005f6:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005f9:	eb be                	jmp    8005b9 <.L36+0x9e>
				putch(' ', putdat);
  8005fb:	83 ec 08             	sub    $0x8,%esp
  8005fe:	56                   	push   %esi
  8005ff:	6a 20                	push   $0x20
  800601:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800604:	83 ef 01             	sub    $0x1,%edi
  800607:	83 c4 10             	add    $0x10,%esp
  80060a:	85 ff                	test   %edi,%edi
  80060c:	7f ed                	jg     8005fb <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  80060e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800611:	89 45 14             	mov    %eax,0x14(%ebp)
  800614:	e9 7b 01 00 00       	jmp    800794 <.L35+0x45>
  800619:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80061c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80061f:	eb e9                	jmp    80060a <.L36+0xef>

00800621 <.L31>:
  800621:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800624:	83 f9 01             	cmp    $0x1,%ecx
  800627:	7e 40                	jle    800669 <.L31+0x48>
		return va_arg(*ap, long long);
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8b 50 04             	mov    0x4(%eax),%edx
  80062f:	8b 00                	mov    (%eax),%eax
  800631:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800634:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800637:	8b 45 14             	mov    0x14(%ebp),%eax
  80063a:	8d 40 08             	lea    0x8(%eax),%eax
  80063d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800640:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800644:	79 55                	jns    80069b <.L31+0x7a>
				putch('-', putdat);
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	56                   	push   %esi
  80064a:	6a 2d                	push   $0x2d
  80064c:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80064f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800652:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800655:	f7 da                	neg    %edx
  800657:	83 d1 00             	adc    $0x0,%ecx
  80065a:	f7 d9                	neg    %ecx
  80065c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80065f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800664:	e9 10 01 00 00       	jmp    800779 <.L35+0x2a>
	else if (lflag)
  800669:	85 c9                	test   %ecx,%ecx
  80066b:	75 17                	jne    800684 <.L31+0x63>
		return va_arg(*ap, int);
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8b 00                	mov    (%eax),%eax
  800672:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800675:	99                   	cltd   
  800676:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800679:	8b 45 14             	mov    0x14(%ebp),%eax
  80067c:	8d 40 04             	lea    0x4(%eax),%eax
  80067f:	89 45 14             	mov    %eax,0x14(%ebp)
  800682:	eb bc                	jmp    800640 <.L31+0x1f>
		return va_arg(*ap, long);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8b 00                	mov    (%eax),%eax
  800689:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068c:	99                   	cltd   
  80068d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8d 40 04             	lea    0x4(%eax),%eax
  800696:	89 45 14             	mov    %eax,0x14(%ebp)
  800699:	eb a5                	jmp    800640 <.L31+0x1f>
			num = getint(&ap, lflag);
  80069b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80069e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006a1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a6:	e9 ce 00 00 00       	jmp    800779 <.L35+0x2a>

008006ab <.L37>:
  8006ab:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006ae:	83 f9 01             	cmp    $0x1,%ecx
  8006b1:	7e 18                	jle    8006cb <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8b 10                	mov    (%eax),%edx
  8006b8:	8b 48 04             	mov    0x4(%eax),%ecx
  8006bb:	8d 40 08             	lea    0x8(%eax),%eax
  8006be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c6:	e9 ae 00 00 00       	jmp    800779 <.L35+0x2a>
	else if (lflag)
  8006cb:	85 c9                	test   %ecx,%ecx
  8006cd:	75 1a                	jne    8006e9 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8b 10                	mov    (%eax),%edx
  8006d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d9:	8d 40 04             	lea    0x4(%eax),%eax
  8006dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006df:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e4:	e9 90 00 00 00       	jmp    800779 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ec:	8b 10                	mov    (%eax),%edx
  8006ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f3:	8d 40 04             	lea    0x4(%eax),%eax
  8006f6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006f9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006fe:	eb 79                	jmp    800779 <.L35+0x2a>

00800700 <.L34>:
  800700:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800703:	83 f9 01             	cmp    $0x1,%ecx
  800706:	7e 15                	jle    80071d <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  800708:	8b 45 14             	mov    0x14(%ebp),%eax
  80070b:	8b 10                	mov    (%eax),%edx
  80070d:	8b 48 04             	mov    0x4(%eax),%ecx
  800710:	8d 40 08             	lea    0x8(%eax),%eax
  800713:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800716:	b8 08 00 00 00       	mov    $0x8,%eax
  80071b:	eb 5c                	jmp    800779 <.L35+0x2a>
	else if (lflag)
  80071d:	85 c9                	test   %ecx,%ecx
  80071f:	75 17                	jne    800738 <.L34+0x38>
		return va_arg(*ap, unsigned int);
  800721:	8b 45 14             	mov    0x14(%ebp),%eax
  800724:	8b 10                	mov    (%eax),%edx
  800726:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072b:	8d 40 04             	lea    0x4(%eax),%eax
  80072e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800731:	b8 08 00 00 00       	mov    $0x8,%eax
  800736:	eb 41                	jmp    800779 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800738:	8b 45 14             	mov    0x14(%ebp),%eax
  80073b:	8b 10                	mov    (%eax),%edx
  80073d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800742:	8d 40 04             	lea    0x4(%eax),%eax
  800745:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800748:	b8 08 00 00 00       	mov    $0x8,%eax
  80074d:	eb 2a                	jmp    800779 <.L35+0x2a>

0080074f <.L35>:
			putch('0', putdat);
  80074f:	83 ec 08             	sub    $0x8,%esp
  800752:	56                   	push   %esi
  800753:	6a 30                	push   $0x30
  800755:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800758:	83 c4 08             	add    $0x8,%esp
  80075b:	56                   	push   %esi
  80075c:	6a 78                	push   $0x78
  80075e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800761:	8b 45 14             	mov    0x14(%ebp),%eax
  800764:	8b 10                	mov    (%eax),%edx
  800766:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80076b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80076e:	8d 40 04             	lea    0x4(%eax),%eax
  800771:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800774:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800779:	83 ec 0c             	sub    $0xc,%esp
  80077c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800780:	57                   	push   %edi
  800781:	ff 75 e0             	pushl  -0x20(%ebp)
  800784:	50                   	push   %eax
  800785:	51                   	push   %ecx
  800786:	52                   	push   %edx
  800787:	89 f2                	mov    %esi,%edx
  800789:	8b 45 08             	mov    0x8(%ebp),%eax
  80078c:	e8 20 fb ff ff       	call   8002b1 <printnum>
			break;
  800791:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800794:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800797:	83 c7 01             	add    $0x1,%edi
  80079a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80079e:	83 f8 25             	cmp    $0x25,%eax
  8007a1:	0f 84 2d fc ff ff    	je     8003d4 <vprintfmt+0x1f>
			if (ch == '\0')
  8007a7:	85 c0                	test   %eax,%eax
  8007a9:	0f 84 91 00 00 00    	je     800840 <.L22+0x21>
			putch(ch, putdat);
  8007af:	83 ec 08             	sub    $0x8,%esp
  8007b2:	56                   	push   %esi
  8007b3:	50                   	push   %eax
  8007b4:	ff 55 08             	call   *0x8(%ebp)
  8007b7:	83 c4 10             	add    $0x10,%esp
  8007ba:	eb db                	jmp    800797 <.L35+0x48>

008007bc <.L38>:
  8007bc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8007bf:	83 f9 01             	cmp    $0x1,%ecx
  8007c2:	7e 15                	jle    8007d9 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8007c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c7:	8b 10                	mov    (%eax),%edx
  8007c9:	8b 48 04             	mov    0x4(%eax),%ecx
  8007cc:	8d 40 08             	lea    0x8(%eax),%eax
  8007cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d2:	b8 10 00 00 00       	mov    $0x10,%eax
  8007d7:	eb a0                	jmp    800779 <.L35+0x2a>
	else if (lflag)
  8007d9:	85 c9                	test   %ecx,%ecx
  8007db:	75 17                	jne    8007f4 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8b 10                	mov    (%eax),%edx
  8007e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007e7:	8d 40 04             	lea    0x4(%eax),%eax
  8007ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ed:	b8 10 00 00 00       	mov    $0x10,%eax
  8007f2:	eb 85                	jmp    800779 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f7:	8b 10                	mov    (%eax),%edx
  8007f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007fe:	8d 40 04             	lea    0x4(%eax),%eax
  800801:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800804:	b8 10 00 00 00       	mov    $0x10,%eax
  800809:	e9 6b ff ff ff       	jmp    800779 <.L35+0x2a>

0080080e <.L25>:
			putch(ch, putdat);
  80080e:	83 ec 08             	sub    $0x8,%esp
  800811:	56                   	push   %esi
  800812:	6a 25                	push   $0x25
  800814:	ff 55 08             	call   *0x8(%ebp)
			break;
  800817:	83 c4 10             	add    $0x10,%esp
  80081a:	e9 75 ff ff ff       	jmp    800794 <.L35+0x45>

0080081f <.L22>:
			putch('%', putdat);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	56                   	push   %esi
  800823:	6a 25                	push   $0x25
  800825:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800828:	83 c4 10             	add    $0x10,%esp
  80082b:	89 f8                	mov    %edi,%eax
  80082d:	eb 03                	jmp    800832 <.L22+0x13>
  80082f:	83 e8 01             	sub    $0x1,%eax
  800832:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800836:	75 f7                	jne    80082f <.L22+0x10>
  800838:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80083b:	e9 54 ff ff ff       	jmp    800794 <.L35+0x45>
}
  800840:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800843:	5b                   	pop    %ebx
  800844:	5e                   	pop    %esi
  800845:	5f                   	pop    %edi
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	53                   	push   %ebx
  80084c:	83 ec 14             	sub    $0x14,%esp
  80084f:	e8 05 f8 ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  800854:	81 c3 ac 17 00 00    	add    $0x17ac,%ebx
  80085a:	8b 45 08             	mov    0x8(%ebp),%eax
  80085d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800860:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800863:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800867:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80086a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800871:	85 c0                	test   %eax,%eax
  800873:	74 2b                	je     8008a0 <vsnprintf+0x58>
  800875:	85 d2                	test   %edx,%edx
  800877:	7e 27                	jle    8008a0 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800879:	ff 75 14             	pushl  0x14(%ebp)
  80087c:	ff 75 10             	pushl  0x10(%ebp)
  80087f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800882:	50                   	push   %eax
  800883:	8d 83 7b e3 ff ff    	lea    -0x1c85(%ebx),%eax
  800889:	50                   	push   %eax
  80088a:	e8 26 fb ff ff       	call   8003b5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80088f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800892:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800895:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800898:	83 c4 10             	add    $0x10,%esp
}
  80089b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80089e:	c9                   	leave  
  80089f:	c3                   	ret    
		return -E_INVAL;
  8008a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008a5:	eb f4                	jmp    80089b <vsnprintf+0x53>

008008a7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ad:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008b0:	50                   	push   %eax
  8008b1:	ff 75 10             	pushl  0x10(%ebp)
  8008b4:	ff 75 0c             	pushl  0xc(%ebp)
  8008b7:	ff 75 08             	pushl  0x8(%ebp)
  8008ba:	e8 89 ff ff ff       	call   800848 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008bf:	c9                   	leave  
  8008c0:	c3                   	ret    

008008c1 <__x86.get_pc_thunk.cx>:
  8008c1:	8b 0c 24             	mov    (%esp),%ecx
  8008c4:	c3                   	ret    

008008c5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d0:	eb 03                	jmp    8008d5 <strlen+0x10>
		n++;
  8008d2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008d5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d9:	75 f7                	jne    8008d2 <strlen+0xd>
	return n;
}
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008eb:	eb 03                	jmp    8008f0 <strnlen+0x13>
		n++;
  8008ed:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f0:	39 d0                	cmp    %edx,%eax
  8008f2:	74 06                	je     8008fa <strnlen+0x1d>
  8008f4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008f8:	75 f3                	jne    8008ed <strnlen+0x10>
	return n;
}
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	53                   	push   %ebx
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800906:	89 c2                	mov    %eax,%edx
  800908:	83 c1 01             	add    $0x1,%ecx
  80090b:	83 c2 01             	add    $0x1,%edx
  80090e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800912:	88 5a ff             	mov    %bl,-0x1(%edx)
  800915:	84 db                	test   %bl,%bl
  800917:	75 ef                	jne    800908 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800919:	5b                   	pop    %ebx
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	53                   	push   %ebx
  800920:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800923:	53                   	push   %ebx
  800924:	e8 9c ff ff ff       	call   8008c5 <strlen>
  800929:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80092c:	ff 75 0c             	pushl  0xc(%ebp)
  80092f:	01 d8                	add    %ebx,%eax
  800931:	50                   	push   %eax
  800932:	e8 c5 ff ff ff       	call   8008fc <strcpy>
	return dst;
}
  800937:	89 d8                	mov    %ebx,%eax
  800939:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80093c:	c9                   	leave  
  80093d:	c3                   	ret    

0080093e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	56                   	push   %esi
  800942:	53                   	push   %ebx
  800943:	8b 75 08             	mov    0x8(%ebp),%esi
  800946:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800949:	89 f3                	mov    %esi,%ebx
  80094b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80094e:	89 f2                	mov    %esi,%edx
  800950:	eb 0f                	jmp    800961 <strncpy+0x23>
		*dst++ = *src;
  800952:	83 c2 01             	add    $0x1,%edx
  800955:	0f b6 01             	movzbl (%ecx),%eax
  800958:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80095b:	80 39 01             	cmpb   $0x1,(%ecx)
  80095e:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800961:	39 da                	cmp    %ebx,%edx
  800963:	75 ed                	jne    800952 <strncpy+0x14>
	}
	return ret;
}
  800965:	89 f0                	mov    %esi,%eax
  800967:	5b                   	pop    %ebx
  800968:	5e                   	pop    %esi
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	56                   	push   %esi
  80096f:	53                   	push   %ebx
  800970:	8b 75 08             	mov    0x8(%ebp),%esi
  800973:	8b 55 0c             	mov    0xc(%ebp),%edx
  800976:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800979:	89 f0                	mov    %esi,%eax
  80097b:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80097f:	85 c9                	test   %ecx,%ecx
  800981:	75 0b                	jne    80098e <strlcpy+0x23>
  800983:	eb 17                	jmp    80099c <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800985:	83 c2 01             	add    $0x1,%edx
  800988:	83 c0 01             	add    $0x1,%eax
  80098b:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80098e:	39 d8                	cmp    %ebx,%eax
  800990:	74 07                	je     800999 <strlcpy+0x2e>
  800992:	0f b6 0a             	movzbl (%edx),%ecx
  800995:	84 c9                	test   %cl,%cl
  800997:	75 ec                	jne    800985 <strlcpy+0x1a>
		*dst = '\0';
  800999:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80099c:	29 f0                	sub    %esi,%eax
}
  80099e:	5b                   	pop    %ebx
  80099f:	5e                   	pop    %esi
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ab:	eb 06                	jmp    8009b3 <strcmp+0x11>
		p++, q++;
  8009ad:	83 c1 01             	add    $0x1,%ecx
  8009b0:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009b3:	0f b6 01             	movzbl (%ecx),%eax
  8009b6:	84 c0                	test   %al,%al
  8009b8:	74 04                	je     8009be <strcmp+0x1c>
  8009ba:	3a 02                	cmp    (%edx),%al
  8009bc:	74 ef                	je     8009ad <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009be:	0f b6 c0             	movzbl %al,%eax
  8009c1:	0f b6 12             	movzbl (%edx),%edx
  8009c4:	29 d0                	sub    %edx,%eax
}
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	53                   	push   %ebx
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d2:	89 c3                	mov    %eax,%ebx
  8009d4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009d7:	eb 06                	jmp    8009df <strncmp+0x17>
		n--, p++, q++;
  8009d9:	83 c0 01             	add    $0x1,%eax
  8009dc:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009df:	39 d8                	cmp    %ebx,%eax
  8009e1:	74 16                	je     8009f9 <strncmp+0x31>
  8009e3:	0f b6 08             	movzbl (%eax),%ecx
  8009e6:	84 c9                	test   %cl,%cl
  8009e8:	74 04                	je     8009ee <strncmp+0x26>
  8009ea:	3a 0a                	cmp    (%edx),%cl
  8009ec:	74 eb                	je     8009d9 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ee:	0f b6 00             	movzbl (%eax),%eax
  8009f1:	0f b6 12             	movzbl (%edx),%edx
  8009f4:	29 d0                	sub    %edx,%eax
}
  8009f6:	5b                   	pop    %ebx
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    
		return 0;
  8009f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fe:	eb f6                	jmp    8009f6 <strncmp+0x2e>

00800a00 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	8b 45 08             	mov    0x8(%ebp),%eax
  800a06:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a0a:	0f b6 10             	movzbl (%eax),%edx
  800a0d:	84 d2                	test   %dl,%dl
  800a0f:	74 09                	je     800a1a <strchr+0x1a>
		if (*s == c)
  800a11:	38 ca                	cmp    %cl,%dl
  800a13:	74 0a                	je     800a1f <strchr+0x1f>
	for (; *s; s++)
  800a15:	83 c0 01             	add    $0x1,%eax
  800a18:	eb f0                	jmp    800a0a <strchr+0xa>
			return (char *) s;
	return 0;
  800a1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	8b 45 08             	mov    0x8(%ebp),%eax
  800a27:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a2b:	eb 03                	jmp    800a30 <strfind+0xf>
  800a2d:	83 c0 01             	add    $0x1,%eax
  800a30:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a33:	38 ca                	cmp    %cl,%dl
  800a35:	74 04                	je     800a3b <strfind+0x1a>
  800a37:	84 d2                	test   %dl,%dl
  800a39:	75 f2                	jne    800a2d <strfind+0xc>
			break;
	return (char *) s;
}
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	57                   	push   %edi
  800a41:	56                   	push   %esi
  800a42:	53                   	push   %ebx
  800a43:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a46:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a49:	85 c9                	test   %ecx,%ecx
  800a4b:	74 13                	je     800a60 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a53:	75 05                	jne    800a5a <memset+0x1d>
  800a55:	f6 c1 03             	test   $0x3,%cl
  800a58:	74 0d                	je     800a67 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5d:	fc                   	cld    
  800a5e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a60:	89 f8                	mov    %edi,%eax
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5f                   	pop    %edi
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    
		c &= 0xFF;
  800a67:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a6b:	89 d3                	mov    %edx,%ebx
  800a6d:	c1 e3 08             	shl    $0x8,%ebx
  800a70:	89 d0                	mov    %edx,%eax
  800a72:	c1 e0 18             	shl    $0x18,%eax
  800a75:	89 d6                	mov    %edx,%esi
  800a77:	c1 e6 10             	shl    $0x10,%esi
  800a7a:	09 f0                	or     %esi,%eax
  800a7c:	09 c2                	or     %eax,%edx
  800a7e:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a80:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a83:	89 d0                	mov    %edx,%eax
  800a85:	fc                   	cld    
  800a86:	f3 ab                	rep stos %eax,%es:(%edi)
  800a88:	eb d6                	jmp    800a60 <memset+0x23>

00800a8a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	57                   	push   %edi
  800a8e:	56                   	push   %esi
  800a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a92:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a95:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a98:	39 c6                	cmp    %eax,%esi
  800a9a:	73 35                	jae    800ad1 <memmove+0x47>
  800a9c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a9f:	39 c2                	cmp    %eax,%edx
  800aa1:	76 2e                	jbe    800ad1 <memmove+0x47>
		s += n;
		d += n;
  800aa3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa6:	89 d6                	mov    %edx,%esi
  800aa8:	09 fe                	or     %edi,%esi
  800aaa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ab0:	74 0c                	je     800abe <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ab2:	83 ef 01             	sub    $0x1,%edi
  800ab5:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ab8:	fd                   	std    
  800ab9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800abb:	fc                   	cld    
  800abc:	eb 21                	jmp    800adf <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800abe:	f6 c1 03             	test   $0x3,%cl
  800ac1:	75 ef                	jne    800ab2 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ac3:	83 ef 04             	sub    $0x4,%edi
  800ac6:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ac9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800acc:	fd                   	std    
  800acd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800acf:	eb ea                	jmp    800abb <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad1:	89 f2                	mov    %esi,%edx
  800ad3:	09 c2                	or     %eax,%edx
  800ad5:	f6 c2 03             	test   $0x3,%dl
  800ad8:	74 09                	je     800ae3 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ada:	89 c7                	mov    %eax,%edi
  800adc:	fc                   	cld    
  800add:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800adf:	5e                   	pop    %esi
  800ae0:	5f                   	pop    %edi
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae3:	f6 c1 03             	test   $0x3,%cl
  800ae6:	75 f2                	jne    800ada <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ae8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800aeb:	89 c7                	mov    %eax,%edi
  800aed:	fc                   	cld    
  800aee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af0:	eb ed                	jmp    800adf <memmove+0x55>

00800af2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800af5:	ff 75 10             	pushl  0x10(%ebp)
  800af8:	ff 75 0c             	pushl  0xc(%ebp)
  800afb:	ff 75 08             	pushl  0x8(%ebp)
  800afe:	e8 87 ff ff ff       	call   800a8a <memmove>
}
  800b03:	c9                   	leave  
  800b04:	c3                   	ret    

00800b05 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
  800b0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b10:	89 c6                	mov    %eax,%esi
  800b12:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b15:	39 f0                	cmp    %esi,%eax
  800b17:	74 1c                	je     800b35 <memcmp+0x30>
		if (*s1 != *s2)
  800b19:	0f b6 08             	movzbl (%eax),%ecx
  800b1c:	0f b6 1a             	movzbl (%edx),%ebx
  800b1f:	38 d9                	cmp    %bl,%cl
  800b21:	75 08                	jne    800b2b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b23:	83 c0 01             	add    $0x1,%eax
  800b26:	83 c2 01             	add    $0x1,%edx
  800b29:	eb ea                	jmp    800b15 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b2b:	0f b6 c1             	movzbl %cl,%eax
  800b2e:	0f b6 db             	movzbl %bl,%ebx
  800b31:	29 d8                	sub    %ebx,%eax
  800b33:	eb 05                	jmp    800b3a <memcmp+0x35>
	}

	return 0;
  800b35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	8b 45 08             	mov    0x8(%ebp),%eax
  800b44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b47:	89 c2                	mov    %eax,%edx
  800b49:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b4c:	39 d0                	cmp    %edx,%eax
  800b4e:	73 09                	jae    800b59 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b50:	38 08                	cmp    %cl,(%eax)
  800b52:	74 05                	je     800b59 <memfind+0x1b>
	for (; s < ends; s++)
  800b54:	83 c0 01             	add    $0x1,%eax
  800b57:	eb f3                	jmp    800b4c <memfind+0xe>
			break;
	return (void *) s;
}
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
  800b61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b64:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b67:	eb 03                	jmp    800b6c <strtol+0x11>
		s++;
  800b69:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b6c:	0f b6 01             	movzbl (%ecx),%eax
  800b6f:	3c 20                	cmp    $0x20,%al
  800b71:	74 f6                	je     800b69 <strtol+0xe>
  800b73:	3c 09                	cmp    $0x9,%al
  800b75:	74 f2                	je     800b69 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b77:	3c 2b                	cmp    $0x2b,%al
  800b79:	74 2e                	je     800ba9 <strtol+0x4e>
	int neg = 0;
  800b7b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b80:	3c 2d                	cmp    $0x2d,%al
  800b82:	74 2f                	je     800bb3 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b84:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b8a:	75 05                	jne    800b91 <strtol+0x36>
  800b8c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b8f:	74 2c                	je     800bbd <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b91:	85 db                	test   %ebx,%ebx
  800b93:	75 0a                	jne    800b9f <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b95:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b9a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b9d:	74 28                	je     800bc7 <strtol+0x6c>
		base = 10;
  800b9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ba7:	eb 50                	jmp    800bf9 <strtol+0x9e>
		s++;
  800ba9:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bac:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb1:	eb d1                	jmp    800b84 <strtol+0x29>
		s++, neg = 1;
  800bb3:	83 c1 01             	add    $0x1,%ecx
  800bb6:	bf 01 00 00 00       	mov    $0x1,%edi
  800bbb:	eb c7                	jmp    800b84 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bbd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bc1:	74 0e                	je     800bd1 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bc3:	85 db                	test   %ebx,%ebx
  800bc5:	75 d8                	jne    800b9f <strtol+0x44>
		s++, base = 8;
  800bc7:	83 c1 01             	add    $0x1,%ecx
  800bca:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bcf:	eb ce                	jmp    800b9f <strtol+0x44>
		s += 2, base = 16;
  800bd1:	83 c1 02             	add    $0x2,%ecx
  800bd4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bd9:	eb c4                	jmp    800b9f <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bdb:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bde:	89 f3                	mov    %esi,%ebx
  800be0:	80 fb 19             	cmp    $0x19,%bl
  800be3:	77 29                	ja     800c0e <strtol+0xb3>
			dig = *s - 'a' + 10;
  800be5:	0f be d2             	movsbl %dl,%edx
  800be8:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800beb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bee:	7d 30                	jge    800c20 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bf0:	83 c1 01             	add    $0x1,%ecx
  800bf3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bf7:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bf9:	0f b6 11             	movzbl (%ecx),%edx
  800bfc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bff:	89 f3                	mov    %esi,%ebx
  800c01:	80 fb 09             	cmp    $0x9,%bl
  800c04:	77 d5                	ja     800bdb <strtol+0x80>
			dig = *s - '0';
  800c06:	0f be d2             	movsbl %dl,%edx
  800c09:	83 ea 30             	sub    $0x30,%edx
  800c0c:	eb dd                	jmp    800beb <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c0e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c11:	89 f3                	mov    %esi,%ebx
  800c13:	80 fb 19             	cmp    $0x19,%bl
  800c16:	77 08                	ja     800c20 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c18:	0f be d2             	movsbl %dl,%edx
  800c1b:	83 ea 37             	sub    $0x37,%edx
  800c1e:	eb cb                	jmp    800beb <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c20:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c24:	74 05                	je     800c2b <strtol+0xd0>
		*endptr = (char *) s;
  800c26:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c29:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c2b:	89 c2                	mov    %eax,%edx
  800c2d:	f7 da                	neg    %edx
  800c2f:	85 ff                	test   %edi,%edi
  800c31:	0f 45 c2             	cmovne %edx,%eax
}
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    
  800c39:	66 90                	xchg   %ax,%ax
  800c3b:	66 90                	xchg   %ax,%ax
  800c3d:	66 90                	xchg   %ax,%ax
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
