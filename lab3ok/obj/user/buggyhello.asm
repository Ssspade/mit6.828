
obj/user/buggyhello：     文件格式 elf32-i386


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
  80002c:	e8 29 00 00 00       	call   80005a <libmain>
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
  80003a:	e8 17 00 00 00       	call   800056 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	sys_cputs((char*)1, 1);
  800045:	6a 01                	push   $0x1
  800047:	6a 01                	push   $0x1
  800049:	e8 8b 00 00 00       	call   8000d9 <sys_cputs>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800054:	c9                   	leave  
  800055:	c3                   	ret    

00800056 <__x86.get_pc_thunk.bx>:
  800056:	8b 1c 24             	mov    (%esp),%ebx
  800059:	c3                   	ret    

0080005a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005a:	55                   	push   %ebp
  80005b:	89 e5                	mov    %esp,%ebp
  80005d:	57                   	push   %edi
  80005e:	56                   	push   %esi
  80005f:	53                   	push   %ebx
  800060:	83 ec 0c             	sub    $0xc,%esp
  800063:	e8 ee ff ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800068:	81 c3 98 1f 00 00    	add    $0x1f98,%ebx
  80006e:	8b 75 08             	mov    0x8(%ebp),%esi
  800071:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800074:	e8 f2 00 00 00       	call   80016b <sys_getenvid>
  800079:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007e:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800081:	c1 e0 05             	shl    $0x5,%eax
  800084:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  80008a:	c7 c2 2c 20 80 00    	mov    $0x80202c,%edx
  800090:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800092:	85 f6                	test   %esi,%esi
  800094:	7e 08                	jle    80009e <libmain+0x44>
		binaryname = argv[0];
  800096:	8b 07                	mov    (%edi),%eax
  800098:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80009e:	83 ec 08             	sub    $0x8,%esp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	e8 8b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a8:	e8 0b 00 00 00       	call   8000b8 <exit>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	53                   	push   %ebx
  8000bc:	83 ec 10             	sub    $0x10,%esp
  8000bf:	e8 92 ff ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  8000c4:	81 c3 3c 1f 00 00    	add    $0x1f3c,%ebx
	sys_env_destroy(0);
  8000ca:	6a 00                	push   $0x0
  8000cc:	e8 45 00 00 00       	call   800116 <sys_env_destroy>
}
  8000d1:	83 c4 10             	add    $0x10,%esp
  8000d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000d7:	c9                   	leave  
  8000d8:	c3                   	ret    

008000d9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000d9:	55                   	push   %ebp
  8000da:	89 e5                	mov    %esp,%ebp
  8000dc:	57                   	push   %edi
  8000dd:	56                   	push   %esi
  8000de:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000df:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ea:	89 c3                	mov    %eax,%ebx
  8000ec:	89 c7                	mov    %eax,%edi
  8000ee:	89 c6                	mov    %eax,%esi
  8000f0:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000f2:	5b                   	pop    %ebx
  8000f3:	5e                   	pop    %esi
  8000f4:	5f                   	pop    %edi
  8000f5:	5d                   	pop    %ebp
  8000f6:	c3                   	ret    

008000f7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	57                   	push   %edi
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800102:	b8 01 00 00 00       	mov    $0x1,%eax
  800107:	89 d1                	mov    %edx,%ecx
  800109:	89 d3                	mov    %edx,%ebx
  80010b:	89 d7                	mov    %edx,%edi
  80010d:	89 d6                	mov    %edx,%esi
  80010f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800111:	5b                   	pop    %ebx
  800112:	5e                   	pop    %esi
  800113:	5f                   	pop    %edi
  800114:	5d                   	pop    %ebp
  800115:	c3                   	ret    

00800116 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	57                   	push   %edi
  80011a:	56                   	push   %esi
  80011b:	53                   	push   %ebx
  80011c:	83 ec 1c             	sub    $0x1c,%esp
  80011f:	e8 66 00 00 00       	call   80018a <__x86.get_pc_thunk.ax>
  800124:	05 dc 1e 00 00       	add    $0x1edc,%eax
  800129:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80012c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800131:	8b 55 08             	mov    0x8(%ebp),%edx
  800134:	b8 03 00 00 00       	mov    $0x3,%eax
  800139:	89 cb                	mov    %ecx,%ebx
  80013b:	89 cf                	mov    %ecx,%edi
  80013d:	89 ce                	mov    %ecx,%esi
  80013f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800141:	85 c0                	test   %eax,%eax
  800143:	7f 08                	jg     80014d <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800145:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800148:	5b                   	pop    %ebx
  800149:	5e                   	pop    %esi
  80014a:	5f                   	pop    %edi
  80014b:	5d                   	pop    %ebp
  80014c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80014d:	83 ec 0c             	sub    $0xc,%esp
  800150:	50                   	push   %eax
  800151:	6a 03                	push   $0x3
  800153:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800156:	8d 83 86 ee ff ff    	lea    -0x117a(%ebx),%eax
  80015c:	50                   	push   %eax
  80015d:	6a 23                	push   $0x23
  80015f:	8d 83 a3 ee ff ff    	lea    -0x115d(%ebx),%eax
  800165:	50                   	push   %eax
  800166:	e8 23 00 00 00       	call   80018e <_panic>

0080016b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	57                   	push   %edi
  80016f:	56                   	push   %esi
  800170:	53                   	push   %ebx
	asm volatile("int %1\n"
  800171:	ba 00 00 00 00       	mov    $0x0,%edx
  800176:	b8 02 00 00 00       	mov    $0x2,%eax
  80017b:	89 d1                	mov    %edx,%ecx
  80017d:	89 d3                	mov    %edx,%ebx
  80017f:	89 d7                	mov    %edx,%edi
  800181:	89 d6                	mov    %edx,%esi
  800183:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800185:	5b                   	pop    %ebx
  800186:	5e                   	pop    %esi
  800187:	5f                   	pop    %edi
  800188:	5d                   	pop    %ebp
  800189:	c3                   	ret    

0080018a <__x86.get_pc_thunk.ax>:
  80018a:	8b 04 24             	mov    (%esp),%eax
  80018d:	c3                   	ret    

0080018e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	57                   	push   %edi
  800192:	56                   	push   %esi
  800193:	53                   	push   %ebx
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	e8 ba fe ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  80019c:	81 c3 64 1e 00 00    	add    $0x1e64,%ebx
	va_list ap;

	va_start(ap, fmt);
  8001a2:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001a5:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  8001ab:	8b 38                	mov    (%eax),%edi
  8001ad:	e8 b9 ff ff ff       	call   80016b <sys_getenvid>
  8001b2:	83 ec 0c             	sub    $0xc,%esp
  8001b5:	ff 75 0c             	pushl  0xc(%ebp)
  8001b8:	ff 75 08             	pushl  0x8(%ebp)
  8001bb:	57                   	push   %edi
  8001bc:	50                   	push   %eax
  8001bd:	8d 83 b4 ee ff ff    	lea    -0x114c(%ebx),%eax
  8001c3:	50                   	push   %eax
  8001c4:	e8 d1 00 00 00       	call   80029a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c9:	83 c4 18             	add    $0x18,%esp
  8001cc:	56                   	push   %esi
  8001cd:	ff 75 10             	pushl  0x10(%ebp)
  8001d0:	e8 63 00 00 00       	call   800238 <vcprintf>
	cprintf("\n");
  8001d5:	8d 83 d8 ee ff ff    	lea    -0x1128(%ebx),%eax
  8001db:	89 04 24             	mov    %eax,(%esp)
  8001de:	e8 b7 00 00 00       	call   80029a <cprintf>
  8001e3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e6:	cc                   	int3   
  8001e7:	eb fd                	jmp    8001e6 <_panic+0x58>

008001e9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	e8 63 fe ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  8001f3:	81 c3 0d 1e 00 00    	add    $0x1e0d,%ebx
  8001f9:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001fc:	8b 16                	mov    (%esi),%edx
  8001fe:	8d 42 01             	lea    0x1(%edx),%eax
  800201:	89 06                	mov    %eax,(%esi)
  800203:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800206:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  80020a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80020f:	74 0b                	je     80021c <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800211:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800215:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80021c:	83 ec 08             	sub    $0x8,%esp
  80021f:	68 ff 00 00 00       	push   $0xff
  800224:	8d 46 08             	lea    0x8(%esi),%eax
  800227:	50                   	push   %eax
  800228:	e8 ac fe ff ff       	call   8000d9 <sys_cputs>
		b->idx = 0;
  80022d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800233:	83 c4 10             	add    $0x10,%esp
  800236:	eb d9                	jmp    800211 <putch+0x28>

00800238 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	53                   	push   %ebx
  80023c:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800242:	e8 0f fe ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800247:	81 c3 b9 1d 00 00    	add    $0x1db9,%ebx
	struct printbuf b;

	b.idx = 0;
  80024d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800254:	00 00 00 
	b.cnt = 0;
  800257:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80025e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800261:	ff 75 0c             	pushl  0xc(%ebp)
  800264:	ff 75 08             	pushl  0x8(%ebp)
  800267:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80026d:	50                   	push   %eax
  80026e:	8d 83 e9 e1 ff ff    	lea    -0x1e17(%ebx),%eax
  800274:	50                   	push   %eax
  800275:	e8 38 01 00 00       	call   8003b2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80027a:	83 c4 08             	add    $0x8,%esp
  80027d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800283:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800289:	50                   	push   %eax
  80028a:	e8 4a fe ff ff       	call   8000d9 <sys_cputs>

	return b.cnt;
}
  80028f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800295:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800298:	c9                   	leave  
  800299:	c3                   	ret    

0080029a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002a0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002a3:	50                   	push   %eax
  8002a4:	ff 75 08             	pushl  0x8(%ebp)
  8002a7:	e8 8c ff ff ff       	call   800238 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002ac:	c9                   	leave  
  8002ad:	c3                   	ret    

008002ae <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 2c             	sub    $0x2c,%esp
  8002b7:	e8 02 06 00 00       	call   8008be <__x86.get_pc_thunk.cx>
  8002bc:	81 c1 44 1d 00 00    	add    $0x1d44,%ecx
  8002c2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002c5:	89 c7                	mov    %eax,%edi
  8002c7:	89 d6                	mov    %edx,%esi
  8002c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002d2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002dd:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002e0:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002e3:	39 d3                	cmp    %edx,%ebx
  8002e5:	72 09                	jb     8002f0 <printnum+0x42>
  8002e7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ea:	0f 87 83 00 00 00    	ja     800373 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f0:	83 ec 0c             	sub    $0xc,%esp
  8002f3:	ff 75 18             	pushl  0x18(%ebp)
  8002f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002fc:	53                   	push   %ebx
  8002fd:	ff 75 10             	pushl  0x10(%ebp)
  800300:	83 ec 08             	sub    $0x8,%esp
  800303:	ff 75 dc             	pushl  -0x24(%ebp)
  800306:	ff 75 d8             	pushl  -0x28(%ebp)
  800309:	ff 75 d4             	pushl  -0x2c(%ebp)
  80030c:	ff 75 d0             	pushl  -0x30(%ebp)
  80030f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800312:	e8 29 09 00 00       	call   800c40 <__udivdi3>
  800317:	83 c4 18             	add    $0x18,%esp
  80031a:	52                   	push   %edx
  80031b:	50                   	push   %eax
  80031c:	89 f2                	mov    %esi,%edx
  80031e:	89 f8                	mov    %edi,%eax
  800320:	e8 89 ff ff ff       	call   8002ae <printnum>
  800325:	83 c4 20             	add    $0x20,%esp
  800328:	eb 13                	jmp    80033d <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032a:	83 ec 08             	sub    $0x8,%esp
  80032d:	56                   	push   %esi
  80032e:	ff 75 18             	pushl  0x18(%ebp)
  800331:	ff d7                	call   *%edi
  800333:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800336:	83 eb 01             	sub    $0x1,%ebx
  800339:	85 db                	test   %ebx,%ebx
  80033b:	7f ed                	jg     80032a <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80033d:	83 ec 08             	sub    $0x8,%esp
  800340:	56                   	push   %esi
  800341:	83 ec 04             	sub    $0x4,%esp
  800344:	ff 75 dc             	pushl  -0x24(%ebp)
  800347:	ff 75 d8             	pushl  -0x28(%ebp)
  80034a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80034d:	ff 75 d0             	pushl  -0x30(%ebp)
  800350:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800353:	89 f3                	mov    %esi,%ebx
  800355:	e8 06 0a 00 00       	call   800d60 <__umoddi3>
  80035a:	83 c4 14             	add    $0x14,%esp
  80035d:	0f be 84 06 da ee ff 	movsbl -0x1126(%esi,%eax,1),%eax
  800364:	ff 
  800365:	50                   	push   %eax
  800366:	ff d7                	call   *%edi
}
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036e:	5b                   	pop    %ebx
  80036f:	5e                   	pop    %esi
  800370:	5f                   	pop    %edi
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    
  800373:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800376:	eb be                	jmp    800336 <printnum+0x88>

00800378 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80037e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800382:	8b 10                	mov    (%eax),%edx
  800384:	3b 50 04             	cmp    0x4(%eax),%edx
  800387:	73 0a                	jae    800393 <sprintputch+0x1b>
		*b->buf++ = ch;
  800389:	8d 4a 01             	lea    0x1(%edx),%ecx
  80038c:	89 08                	mov    %ecx,(%eax)
  80038e:	8b 45 08             	mov    0x8(%ebp),%eax
  800391:	88 02                	mov    %al,(%edx)
}
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <printfmt>:
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80039b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80039e:	50                   	push   %eax
  80039f:	ff 75 10             	pushl  0x10(%ebp)
  8003a2:	ff 75 0c             	pushl  0xc(%ebp)
  8003a5:	ff 75 08             	pushl  0x8(%ebp)
  8003a8:	e8 05 00 00 00       	call   8003b2 <vprintfmt>
}
  8003ad:	83 c4 10             	add    $0x10,%esp
  8003b0:	c9                   	leave  
  8003b1:	c3                   	ret    

008003b2 <vprintfmt>:
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
  8003b5:	57                   	push   %edi
  8003b6:	56                   	push   %esi
  8003b7:	53                   	push   %ebx
  8003b8:	83 ec 2c             	sub    $0x2c,%esp
  8003bb:	e8 96 fc ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  8003c0:	81 c3 40 1c 00 00    	add    $0x1c40,%ebx
  8003c6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003c9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003cc:	e9 c3 03 00 00       	jmp    800794 <.L35+0x48>
		padc = ' ';
  8003d1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003d5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003dc:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003e3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ef:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8d 47 01             	lea    0x1(%edi),%eax
  8003f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f8:	0f b6 17             	movzbl (%edi),%edx
  8003fb:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003fe:	3c 55                	cmp    $0x55,%al
  800400:	0f 87 16 04 00 00    	ja     80081c <.L22>
  800406:	0f b6 c0             	movzbl %al,%eax
  800409:	89 d9                	mov    %ebx,%ecx
  80040b:	03 8c 83 68 ef ff ff 	add    -0x1098(%ebx,%eax,4),%ecx
  800412:	ff e1                	jmp    *%ecx

00800414 <.L69>:
  800414:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800417:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80041b:	eb d5                	jmp    8003f2 <vprintfmt+0x40>

0080041d <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800420:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800424:	eb cc                	jmp    8003f2 <vprintfmt+0x40>

00800426 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	0f b6 d2             	movzbl %dl,%edx
  800429:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80042c:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800431:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800434:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800438:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80043b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80043e:	83 f9 09             	cmp    $0x9,%ecx
  800441:	77 55                	ja     800498 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  800443:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800446:	eb e9                	jmp    800431 <.L29+0xb>

00800448 <.L26>:
			precision = va_arg(ap, int);
  800448:	8b 45 14             	mov    0x14(%ebp),%eax
  80044b:	8b 00                	mov    (%eax),%eax
  80044d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8d 40 04             	lea    0x4(%eax),%eax
  800456:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800459:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80045c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800460:	79 90                	jns    8003f2 <vprintfmt+0x40>
				width = precision, precision = -1;
  800462:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800465:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800468:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80046f:	eb 81                	jmp    8003f2 <vprintfmt+0x40>

00800471 <.L27>:
  800471:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800474:	85 c0                	test   %eax,%eax
  800476:	ba 00 00 00 00       	mov    $0x0,%edx
  80047b:	0f 49 d0             	cmovns %eax,%edx
  80047e:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800484:	e9 69 ff ff ff       	jmp    8003f2 <vprintfmt+0x40>

00800489 <.L23>:
  800489:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80048c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800493:	e9 5a ff ff ff       	jmp    8003f2 <vprintfmt+0x40>
  800498:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80049b:	eb bf                	jmp    80045c <.L26+0x14>

0080049d <.L33>:
			lflag++;
  80049d:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004a4:	e9 49 ff ff ff       	jmp    8003f2 <vprintfmt+0x40>

008004a9 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 78 04             	lea    0x4(%eax),%edi
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	56                   	push   %esi
  8004b3:	ff 30                	pushl  (%eax)
  8004b5:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004b8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004bb:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004be:	e9 ce 02 00 00       	jmp    800791 <.L35+0x45>

008004c3 <.L32>:
			err = va_arg(ap, int);
  8004c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c6:	8d 78 04             	lea    0x4(%eax),%edi
  8004c9:	8b 00                	mov    (%eax),%eax
  8004cb:	99                   	cltd   
  8004cc:	31 d0                	xor    %edx,%eax
  8004ce:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d0:	83 f8 06             	cmp    $0x6,%eax
  8004d3:	7f 27                	jg     8004fc <.L32+0x39>
  8004d5:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8004dc:	85 d2                	test   %edx,%edx
  8004de:	74 1c                	je     8004fc <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004e0:	52                   	push   %edx
  8004e1:	8d 83 fb ee ff ff    	lea    -0x1105(%ebx),%eax
  8004e7:	50                   	push   %eax
  8004e8:	56                   	push   %esi
  8004e9:	ff 75 08             	pushl  0x8(%ebp)
  8004ec:	e8 a4 fe ff ff       	call   800395 <printfmt>
  8004f1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004f4:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004f7:	e9 95 02 00 00       	jmp    800791 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004fc:	50                   	push   %eax
  8004fd:	8d 83 f2 ee ff ff    	lea    -0x110e(%ebx),%eax
  800503:	50                   	push   %eax
  800504:	56                   	push   %esi
  800505:	ff 75 08             	pushl  0x8(%ebp)
  800508:	e8 88 fe ff ff       	call   800395 <printfmt>
  80050d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800510:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800513:	e9 79 02 00 00       	jmp    800791 <.L35+0x45>

00800518 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	83 c0 04             	add    $0x4,%eax
  80051e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800526:	85 ff                	test   %edi,%edi
  800528:	8d 83 eb ee ff ff    	lea    -0x1115(%ebx),%eax
  80052e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800531:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800535:	0f 8e b5 00 00 00    	jle    8005f0 <.L36+0xd8>
  80053b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80053f:	75 08                	jne    800549 <.L36+0x31>
  800541:	89 75 0c             	mov    %esi,0xc(%ebp)
  800544:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800547:	eb 6d                	jmp    8005b6 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	ff 75 cc             	pushl  -0x34(%ebp)
  80054f:	57                   	push   %edi
  800550:	e8 85 03 00 00       	call   8008da <strnlen>
  800555:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800558:	29 c2                	sub    %eax,%edx
  80055a:	89 55 c8             	mov    %edx,-0x38(%ebp)
  80055d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800560:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800564:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800567:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80056a:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80056c:	eb 10                	jmp    80057e <.L36+0x66>
					putch(padc, putdat);
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	56                   	push   %esi
  800572:	ff 75 e0             	pushl  -0x20(%ebp)
  800575:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800578:	83 ef 01             	sub    $0x1,%edi
  80057b:	83 c4 10             	add    $0x10,%esp
  80057e:	85 ff                	test   %edi,%edi
  800580:	7f ec                	jg     80056e <.L36+0x56>
  800582:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800585:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800588:	85 d2                	test   %edx,%edx
  80058a:	b8 00 00 00 00       	mov    $0x0,%eax
  80058f:	0f 49 c2             	cmovns %edx,%eax
  800592:	29 c2                	sub    %eax,%edx
  800594:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800597:	89 75 0c             	mov    %esi,0xc(%ebp)
  80059a:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80059d:	eb 17                	jmp    8005b6 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  80059f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a3:	75 30                	jne    8005d5 <.L36+0xbd>
					putch(ch, putdat);
  8005a5:	83 ec 08             	sub    $0x8,%esp
  8005a8:	ff 75 0c             	pushl  0xc(%ebp)
  8005ab:	50                   	push   %eax
  8005ac:	ff 55 08             	call   *0x8(%ebp)
  8005af:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b2:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005b6:	83 c7 01             	add    $0x1,%edi
  8005b9:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005bd:	0f be c2             	movsbl %dl,%eax
  8005c0:	85 c0                	test   %eax,%eax
  8005c2:	74 52                	je     800616 <.L36+0xfe>
  8005c4:	85 f6                	test   %esi,%esi
  8005c6:	78 d7                	js     80059f <.L36+0x87>
  8005c8:	83 ee 01             	sub    $0x1,%esi
  8005cb:	79 d2                	jns    80059f <.L36+0x87>
  8005cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005d0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005d3:	eb 32                	jmp    800607 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005d5:	0f be d2             	movsbl %dl,%edx
  8005d8:	83 ea 20             	sub    $0x20,%edx
  8005db:	83 fa 5e             	cmp    $0x5e,%edx
  8005de:	76 c5                	jbe    8005a5 <.L36+0x8d>
					putch('?', putdat);
  8005e0:	83 ec 08             	sub    $0x8,%esp
  8005e3:	ff 75 0c             	pushl  0xc(%ebp)
  8005e6:	6a 3f                	push   $0x3f
  8005e8:	ff 55 08             	call   *0x8(%ebp)
  8005eb:	83 c4 10             	add    $0x10,%esp
  8005ee:	eb c2                	jmp    8005b2 <.L36+0x9a>
  8005f0:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005f3:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005f6:	eb be                	jmp    8005b6 <.L36+0x9e>
				putch(' ', putdat);
  8005f8:	83 ec 08             	sub    $0x8,%esp
  8005fb:	56                   	push   %esi
  8005fc:	6a 20                	push   $0x20
  8005fe:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800601:	83 ef 01             	sub    $0x1,%edi
  800604:	83 c4 10             	add    $0x10,%esp
  800607:	85 ff                	test   %edi,%edi
  800609:	7f ed                	jg     8005f8 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  80060b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80060e:	89 45 14             	mov    %eax,0x14(%ebp)
  800611:	e9 7b 01 00 00       	jmp    800791 <.L35+0x45>
  800616:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800619:	8b 75 0c             	mov    0xc(%ebp),%esi
  80061c:	eb e9                	jmp    800607 <.L36+0xef>

0080061e <.L31>:
  80061e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800621:	83 f9 01             	cmp    $0x1,%ecx
  800624:	7e 40                	jle    800666 <.L31+0x48>
		return va_arg(*ap, long long);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8b 50 04             	mov    0x4(%eax),%edx
  80062c:	8b 00                	mov    (%eax),%eax
  80062e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800631:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 40 08             	lea    0x8(%eax),%eax
  80063a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80063d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800641:	79 55                	jns    800698 <.L31+0x7a>
				putch('-', putdat);
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	56                   	push   %esi
  800647:	6a 2d                	push   $0x2d
  800649:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80064c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80064f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800652:	f7 da                	neg    %edx
  800654:	83 d1 00             	adc    $0x0,%ecx
  800657:	f7 d9                	neg    %ecx
  800659:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80065c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800661:	e9 10 01 00 00       	jmp    800776 <.L35+0x2a>
	else if (lflag)
  800666:	85 c9                	test   %ecx,%ecx
  800668:	75 17                	jne    800681 <.L31+0x63>
		return va_arg(*ap, int);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8b 00                	mov    (%eax),%eax
  80066f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800672:	99                   	cltd   
  800673:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800676:	8b 45 14             	mov    0x14(%ebp),%eax
  800679:	8d 40 04             	lea    0x4(%eax),%eax
  80067c:	89 45 14             	mov    %eax,0x14(%ebp)
  80067f:	eb bc                	jmp    80063d <.L31+0x1f>
		return va_arg(*ap, long);
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8b 00                	mov    (%eax),%eax
  800686:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800689:	99                   	cltd   
  80068a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8d 40 04             	lea    0x4(%eax),%eax
  800693:	89 45 14             	mov    %eax,0x14(%ebp)
  800696:	eb a5                	jmp    80063d <.L31+0x1f>
			num = getint(&ap, lflag);
  800698:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80069b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80069e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a3:	e9 ce 00 00 00       	jmp    800776 <.L35+0x2a>

008006a8 <.L37>:
  8006a8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006ab:	83 f9 01             	cmp    $0x1,%ecx
  8006ae:	7e 18                	jle    8006c8 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	8b 10                	mov    (%eax),%edx
  8006b5:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b8:	8d 40 08             	lea    0x8(%eax),%eax
  8006bb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006be:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c3:	e9 ae 00 00 00       	jmp    800776 <.L35+0x2a>
	else if (lflag)
  8006c8:	85 c9                	test   %ecx,%ecx
  8006ca:	75 1a                	jne    8006e6 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8b 10                	mov    (%eax),%edx
  8006d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d6:	8d 40 04             	lea    0x4(%eax),%eax
  8006d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006dc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e1:	e9 90 00 00 00       	jmp    800776 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e9:	8b 10                	mov    (%eax),%edx
  8006eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f0:	8d 40 04             	lea    0x4(%eax),%eax
  8006f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006f6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006fb:	eb 79                	jmp    800776 <.L35+0x2a>

008006fd <.L34>:
  8006fd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800700:	83 f9 01             	cmp    $0x1,%ecx
  800703:	7e 15                	jle    80071a <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  800705:	8b 45 14             	mov    0x14(%ebp),%eax
  800708:	8b 10                	mov    (%eax),%edx
  80070a:	8b 48 04             	mov    0x4(%eax),%ecx
  80070d:	8d 40 08             	lea    0x8(%eax),%eax
  800710:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800713:	b8 08 00 00 00       	mov    $0x8,%eax
  800718:	eb 5c                	jmp    800776 <.L35+0x2a>
	else if (lflag)
  80071a:	85 c9                	test   %ecx,%ecx
  80071c:	75 17                	jne    800735 <.L34+0x38>
		return va_arg(*ap, unsigned int);
  80071e:	8b 45 14             	mov    0x14(%ebp),%eax
  800721:	8b 10                	mov    (%eax),%edx
  800723:	b9 00 00 00 00       	mov    $0x0,%ecx
  800728:	8d 40 04             	lea    0x4(%eax),%eax
  80072b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80072e:	b8 08 00 00 00       	mov    $0x8,%eax
  800733:	eb 41                	jmp    800776 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800735:	8b 45 14             	mov    0x14(%ebp),%eax
  800738:	8b 10                	mov    (%eax),%edx
  80073a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073f:	8d 40 04             	lea    0x4(%eax),%eax
  800742:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800745:	b8 08 00 00 00       	mov    $0x8,%eax
  80074a:	eb 2a                	jmp    800776 <.L35+0x2a>

0080074c <.L35>:
			putch('0', putdat);
  80074c:	83 ec 08             	sub    $0x8,%esp
  80074f:	56                   	push   %esi
  800750:	6a 30                	push   $0x30
  800752:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800755:	83 c4 08             	add    $0x8,%esp
  800758:	56                   	push   %esi
  800759:	6a 78                	push   $0x78
  80075b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  80075e:	8b 45 14             	mov    0x14(%ebp),%eax
  800761:	8b 10                	mov    (%eax),%edx
  800763:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800768:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80076b:	8d 40 04             	lea    0x4(%eax),%eax
  80076e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800771:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800776:	83 ec 0c             	sub    $0xc,%esp
  800779:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80077d:	57                   	push   %edi
  80077e:	ff 75 e0             	pushl  -0x20(%ebp)
  800781:	50                   	push   %eax
  800782:	51                   	push   %ecx
  800783:	52                   	push   %edx
  800784:	89 f2                	mov    %esi,%edx
  800786:	8b 45 08             	mov    0x8(%ebp),%eax
  800789:	e8 20 fb ff ff       	call   8002ae <printnum>
			break;
  80078e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800791:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800794:	83 c7 01             	add    $0x1,%edi
  800797:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80079b:	83 f8 25             	cmp    $0x25,%eax
  80079e:	0f 84 2d fc ff ff    	je     8003d1 <vprintfmt+0x1f>
			if (ch == '\0')
  8007a4:	85 c0                	test   %eax,%eax
  8007a6:	0f 84 91 00 00 00    	je     80083d <.L22+0x21>
			putch(ch, putdat);
  8007ac:	83 ec 08             	sub    $0x8,%esp
  8007af:	56                   	push   %esi
  8007b0:	50                   	push   %eax
  8007b1:	ff 55 08             	call   *0x8(%ebp)
  8007b4:	83 c4 10             	add    $0x10,%esp
  8007b7:	eb db                	jmp    800794 <.L35+0x48>

008007b9 <.L38>:
  8007b9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8007bc:	83 f9 01             	cmp    $0x1,%ecx
  8007bf:	7e 15                	jle    8007d6 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8007c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c4:	8b 10                	mov    (%eax),%edx
  8007c6:	8b 48 04             	mov    0x4(%eax),%ecx
  8007c9:	8d 40 08             	lea    0x8(%eax),%eax
  8007cc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007cf:	b8 10 00 00 00       	mov    $0x10,%eax
  8007d4:	eb a0                	jmp    800776 <.L35+0x2a>
	else if (lflag)
  8007d6:	85 c9                	test   %ecx,%ecx
  8007d8:	75 17                	jne    8007f1 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8007da:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dd:	8b 10                	mov    (%eax),%edx
  8007df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007e4:	8d 40 04             	lea    0x4(%eax),%eax
  8007e7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ea:	b8 10 00 00 00       	mov    $0x10,%eax
  8007ef:	eb 85                	jmp    800776 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f4:	8b 10                	mov    (%eax),%edx
  8007f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007fb:	8d 40 04             	lea    0x4(%eax),%eax
  8007fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800801:	b8 10 00 00 00       	mov    $0x10,%eax
  800806:	e9 6b ff ff ff       	jmp    800776 <.L35+0x2a>

0080080b <.L25>:
			putch(ch, putdat);
  80080b:	83 ec 08             	sub    $0x8,%esp
  80080e:	56                   	push   %esi
  80080f:	6a 25                	push   $0x25
  800811:	ff 55 08             	call   *0x8(%ebp)
			break;
  800814:	83 c4 10             	add    $0x10,%esp
  800817:	e9 75 ff ff ff       	jmp    800791 <.L35+0x45>

0080081c <.L22>:
			putch('%', putdat);
  80081c:	83 ec 08             	sub    $0x8,%esp
  80081f:	56                   	push   %esi
  800820:	6a 25                	push   $0x25
  800822:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800825:	83 c4 10             	add    $0x10,%esp
  800828:	89 f8                	mov    %edi,%eax
  80082a:	eb 03                	jmp    80082f <.L22+0x13>
  80082c:	83 e8 01             	sub    $0x1,%eax
  80082f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800833:	75 f7                	jne    80082c <.L22+0x10>
  800835:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800838:	e9 54 ff ff ff       	jmp    800791 <.L35+0x45>
}
  80083d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800840:	5b                   	pop    %ebx
  800841:	5e                   	pop    %esi
  800842:	5f                   	pop    %edi
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	53                   	push   %ebx
  800849:	83 ec 14             	sub    $0x14,%esp
  80084c:	e8 05 f8 ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800851:	81 c3 af 17 00 00    	add    $0x17af,%ebx
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80085d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800860:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800864:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800867:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80086e:	85 c0                	test   %eax,%eax
  800870:	74 2b                	je     80089d <vsnprintf+0x58>
  800872:	85 d2                	test   %edx,%edx
  800874:	7e 27                	jle    80089d <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800876:	ff 75 14             	pushl  0x14(%ebp)
  800879:	ff 75 10             	pushl  0x10(%ebp)
  80087c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80087f:	50                   	push   %eax
  800880:	8d 83 78 e3 ff ff    	lea    -0x1c88(%ebx),%eax
  800886:	50                   	push   %eax
  800887:	e8 26 fb ff ff       	call   8003b2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80088c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80088f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800892:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800895:	83 c4 10             	add    $0x10,%esp
}
  800898:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80089b:	c9                   	leave  
  80089c:	c3                   	ret    
		return -E_INVAL;
  80089d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008a2:	eb f4                	jmp    800898 <vsnprintf+0x53>

008008a4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008aa:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ad:	50                   	push   %eax
  8008ae:	ff 75 10             	pushl  0x10(%ebp)
  8008b1:	ff 75 0c             	pushl  0xc(%ebp)
  8008b4:	ff 75 08             	pushl  0x8(%ebp)
  8008b7:	e8 89 ff ff ff       	call   800845 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008bc:	c9                   	leave  
  8008bd:	c3                   	ret    

008008be <__x86.get_pc_thunk.cx>:
  8008be:	8b 0c 24             	mov    (%esp),%ecx
  8008c1:	c3                   	ret    

008008c2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cd:	eb 03                	jmp    8008d2 <strlen+0x10>
		n++;
  8008cf:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008d2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d6:	75 f7                	jne    8008cf <strlen+0xd>
	return n;
}
  8008d8:	5d                   	pop    %ebp
  8008d9:	c3                   	ret    

008008da <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e8:	eb 03                	jmp    8008ed <strnlen+0x13>
		n++;
  8008ea:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ed:	39 d0                	cmp    %edx,%eax
  8008ef:	74 06                	je     8008f7 <strnlen+0x1d>
  8008f1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008f5:	75 f3                	jne    8008ea <strnlen+0x10>
	return n;
}
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	53                   	push   %ebx
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800903:	89 c2                	mov    %eax,%edx
  800905:	83 c1 01             	add    $0x1,%ecx
  800908:	83 c2 01             	add    $0x1,%edx
  80090b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80090f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800912:	84 db                	test   %bl,%bl
  800914:	75 ef                	jne    800905 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800916:	5b                   	pop    %ebx
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	53                   	push   %ebx
  80091d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800920:	53                   	push   %ebx
  800921:	e8 9c ff ff ff       	call   8008c2 <strlen>
  800926:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800929:	ff 75 0c             	pushl  0xc(%ebp)
  80092c:	01 d8                	add    %ebx,%eax
  80092e:	50                   	push   %eax
  80092f:	e8 c5 ff ff ff       	call   8008f9 <strcpy>
	return dst;
}
  800934:	89 d8                	mov    %ebx,%eax
  800936:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800939:	c9                   	leave  
  80093a:	c3                   	ret    

0080093b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	56                   	push   %esi
  80093f:	53                   	push   %ebx
  800940:	8b 75 08             	mov    0x8(%ebp),%esi
  800943:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800946:	89 f3                	mov    %esi,%ebx
  800948:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80094b:	89 f2                	mov    %esi,%edx
  80094d:	eb 0f                	jmp    80095e <strncpy+0x23>
		*dst++ = *src;
  80094f:	83 c2 01             	add    $0x1,%edx
  800952:	0f b6 01             	movzbl (%ecx),%eax
  800955:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800958:	80 39 01             	cmpb   $0x1,(%ecx)
  80095b:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80095e:	39 da                	cmp    %ebx,%edx
  800960:	75 ed                	jne    80094f <strncpy+0x14>
	}
	return ret;
}
  800962:	89 f0                	mov    %esi,%eax
  800964:	5b                   	pop    %ebx
  800965:	5e                   	pop    %esi
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	56                   	push   %esi
  80096c:	53                   	push   %ebx
  80096d:	8b 75 08             	mov    0x8(%ebp),%esi
  800970:	8b 55 0c             	mov    0xc(%ebp),%edx
  800973:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800976:	89 f0                	mov    %esi,%eax
  800978:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80097c:	85 c9                	test   %ecx,%ecx
  80097e:	75 0b                	jne    80098b <strlcpy+0x23>
  800980:	eb 17                	jmp    800999 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800982:	83 c2 01             	add    $0x1,%edx
  800985:	83 c0 01             	add    $0x1,%eax
  800988:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80098b:	39 d8                	cmp    %ebx,%eax
  80098d:	74 07                	je     800996 <strlcpy+0x2e>
  80098f:	0f b6 0a             	movzbl (%edx),%ecx
  800992:	84 c9                	test   %cl,%cl
  800994:	75 ec                	jne    800982 <strlcpy+0x1a>
		*dst = '\0';
  800996:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800999:	29 f0                	sub    %esi,%eax
}
  80099b:	5b                   	pop    %ebx
  80099c:	5e                   	pop    %esi
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a8:	eb 06                	jmp    8009b0 <strcmp+0x11>
		p++, q++;
  8009aa:	83 c1 01             	add    $0x1,%ecx
  8009ad:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009b0:	0f b6 01             	movzbl (%ecx),%eax
  8009b3:	84 c0                	test   %al,%al
  8009b5:	74 04                	je     8009bb <strcmp+0x1c>
  8009b7:	3a 02                	cmp    (%edx),%al
  8009b9:	74 ef                	je     8009aa <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009bb:	0f b6 c0             	movzbl %al,%eax
  8009be:	0f b6 12             	movzbl (%edx),%edx
  8009c1:	29 d0                	sub    %edx,%eax
}
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	53                   	push   %ebx
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cf:	89 c3                	mov    %eax,%ebx
  8009d1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009d4:	eb 06                	jmp    8009dc <strncmp+0x17>
		n--, p++, q++;
  8009d6:	83 c0 01             	add    $0x1,%eax
  8009d9:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009dc:	39 d8                	cmp    %ebx,%eax
  8009de:	74 16                	je     8009f6 <strncmp+0x31>
  8009e0:	0f b6 08             	movzbl (%eax),%ecx
  8009e3:	84 c9                	test   %cl,%cl
  8009e5:	74 04                	je     8009eb <strncmp+0x26>
  8009e7:	3a 0a                	cmp    (%edx),%cl
  8009e9:	74 eb                	je     8009d6 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009eb:	0f b6 00             	movzbl (%eax),%eax
  8009ee:	0f b6 12             	movzbl (%edx),%edx
  8009f1:	29 d0                	sub    %edx,%eax
}
  8009f3:	5b                   	pop    %ebx
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    
		return 0;
  8009f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fb:	eb f6                	jmp    8009f3 <strncmp+0x2e>

008009fd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a07:	0f b6 10             	movzbl (%eax),%edx
  800a0a:	84 d2                	test   %dl,%dl
  800a0c:	74 09                	je     800a17 <strchr+0x1a>
		if (*s == c)
  800a0e:	38 ca                	cmp    %cl,%dl
  800a10:	74 0a                	je     800a1c <strchr+0x1f>
	for (; *s; s++)
  800a12:	83 c0 01             	add    $0x1,%eax
  800a15:	eb f0                	jmp    800a07 <strchr+0xa>
			return (char *) s;
	return 0;
  800a17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a28:	eb 03                	jmp    800a2d <strfind+0xf>
  800a2a:	83 c0 01             	add    $0x1,%eax
  800a2d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a30:	38 ca                	cmp    %cl,%dl
  800a32:	74 04                	je     800a38 <strfind+0x1a>
  800a34:	84 d2                	test   %dl,%dl
  800a36:	75 f2                	jne    800a2a <strfind+0xc>
			break;
	return (char *) s;
}
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	57                   	push   %edi
  800a3e:	56                   	push   %esi
  800a3f:	53                   	push   %ebx
  800a40:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a43:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a46:	85 c9                	test   %ecx,%ecx
  800a48:	74 13                	je     800a5d <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a50:	75 05                	jne    800a57 <memset+0x1d>
  800a52:	f6 c1 03             	test   $0x3,%cl
  800a55:	74 0d                	je     800a64 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5a:	fc                   	cld    
  800a5b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a5d:	89 f8                	mov    %edi,%eax
  800a5f:	5b                   	pop    %ebx
  800a60:	5e                   	pop    %esi
  800a61:	5f                   	pop    %edi
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    
		c &= 0xFF;
  800a64:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a68:	89 d3                	mov    %edx,%ebx
  800a6a:	c1 e3 08             	shl    $0x8,%ebx
  800a6d:	89 d0                	mov    %edx,%eax
  800a6f:	c1 e0 18             	shl    $0x18,%eax
  800a72:	89 d6                	mov    %edx,%esi
  800a74:	c1 e6 10             	shl    $0x10,%esi
  800a77:	09 f0                	or     %esi,%eax
  800a79:	09 c2                	or     %eax,%edx
  800a7b:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a7d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a80:	89 d0                	mov    %edx,%eax
  800a82:	fc                   	cld    
  800a83:	f3 ab                	rep stos %eax,%es:(%edi)
  800a85:	eb d6                	jmp    800a5d <memset+0x23>

00800a87 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	57                   	push   %edi
  800a8b:	56                   	push   %esi
  800a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a92:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a95:	39 c6                	cmp    %eax,%esi
  800a97:	73 35                	jae    800ace <memmove+0x47>
  800a99:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a9c:	39 c2                	cmp    %eax,%edx
  800a9e:	76 2e                	jbe    800ace <memmove+0x47>
		s += n;
		d += n;
  800aa0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa3:	89 d6                	mov    %edx,%esi
  800aa5:	09 fe                	or     %edi,%esi
  800aa7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aad:	74 0c                	je     800abb <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aaf:	83 ef 01             	sub    $0x1,%edi
  800ab2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ab5:	fd                   	std    
  800ab6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ab8:	fc                   	cld    
  800ab9:	eb 21                	jmp    800adc <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800abb:	f6 c1 03             	test   $0x3,%cl
  800abe:	75 ef                	jne    800aaf <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ac0:	83 ef 04             	sub    $0x4,%edi
  800ac3:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ac6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ac9:	fd                   	std    
  800aca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800acc:	eb ea                	jmp    800ab8 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ace:	89 f2                	mov    %esi,%edx
  800ad0:	09 c2                	or     %eax,%edx
  800ad2:	f6 c2 03             	test   $0x3,%dl
  800ad5:	74 09                	je     800ae0 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ad7:	89 c7                	mov    %eax,%edi
  800ad9:	fc                   	cld    
  800ada:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800adc:	5e                   	pop    %esi
  800add:	5f                   	pop    %edi
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae0:	f6 c1 03             	test   $0x3,%cl
  800ae3:	75 f2                	jne    800ad7 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ae5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ae8:	89 c7                	mov    %eax,%edi
  800aea:	fc                   	cld    
  800aeb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aed:	eb ed                	jmp    800adc <memmove+0x55>

00800aef <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800af2:	ff 75 10             	pushl  0x10(%ebp)
  800af5:	ff 75 0c             	pushl  0xc(%ebp)
  800af8:	ff 75 08             	pushl  0x8(%ebp)
  800afb:	e8 87 ff ff ff       	call   800a87 <memmove>
}
  800b00:	c9                   	leave  
  800b01:	c3                   	ret    

00800b02 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0d:	89 c6                	mov    %eax,%esi
  800b0f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b12:	39 f0                	cmp    %esi,%eax
  800b14:	74 1c                	je     800b32 <memcmp+0x30>
		if (*s1 != *s2)
  800b16:	0f b6 08             	movzbl (%eax),%ecx
  800b19:	0f b6 1a             	movzbl (%edx),%ebx
  800b1c:	38 d9                	cmp    %bl,%cl
  800b1e:	75 08                	jne    800b28 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b20:	83 c0 01             	add    $0x1,%eax
  800b23:	83 c2 01             	add    $0x1,%edx
  800b26:	eb ea                	jmp    800b12 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b28:	0f b6 c1             	movzbl %cl,%eax
  800b2b:	0f b6 db             	movzbl %bl,%ebx
  800b2e:	29 d8                	sub    %ebx,%eax
  800b30:	eb 05                	jmp    800b37 <memcmp+0x35>
	}

	return 0;
  800b32:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b44:	89 c2                	mov    %eax,%edx
  800b46:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b49:	39 d0                	cmp    %edx,%eax
  800b4b:	73 09                	jae    800b56 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b4d:	38 08                	cmp    %cl,(%eax)
  800b4f:	74 05                	je     800b56 <memfind+0x1b>
	for (; s < ends; s++)
  800b51:	83 c0 01             	add    $0x1,%eax
  800b54:	eb f3                	jmp    800b49 <memfind+0xe>
			break;
	return (void *) s;
}
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
  800b5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b61:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b64:	eb 03                	jmp    800b69 <strtol+0x11>
		s++;
  800b66:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b69:	0f b6 01             	movzbl (%ecx),%eax
  800b6c:	3c 20                	cmp    $0x20,%al
  800b6e:	74 f6                	je     800b66 <strtol+0xe>
  800b70:	3c 09                	cmp    $0x9,%al
  800b72:	74 f2                	je     800b66 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b74:	3c 2b                	cmp    $0x2b,%al
  800b76:	74 2e                	je     800ba6 <strtol+0x4e>
	int neg = 0;
  800b78:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b7d:	3c 2d                	cmp    $0x2d,%al
  800b7f:	74 2f                	je     800bb0 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b81:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b87:	75 05                	jne    800b8e <strtol+0x36>
  800b89:	80 39 30             	cmpb   $0x30,(%ecx)
  800b8c:	74 2c                	je     800bba <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b8e:	85 db                	test   %ebx,%ebx
  800b90:	75 0a                	jne    800b9c <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b92:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b97:	80 39 30             	cmpb   $0x30,(%ecx)
  800b9a:	74 28                	je     800bc4 <strtol+0x6c>
		base = 10;
  800b9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ba4:	eb 50                	jmp    800bf6 <strtol+0x9e>
		s++;
  800ba6:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ba9:	bf 00 00 00 00       	mov    $0x0,%edi
  800bae:	eb d1                	jmp    800b81 <strtol+0x29>
		s++, neg = 1;
  800bb0:	83 c1 01             	add    $0x1,%ecx
  800bb3:	bf 01 00 00 00       	mov    $0x1,%edi
  800bb8:	eb c7                	jmp    800b81 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bba:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bbe:	74 0e                	je     800bce <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bc0:	85 db                	test   %ebx,%ebx
  800bc2:	75 d8                	jne    800b9c <strtol+0x44>
		s++, base = 8;
  800bc4:	83 c1 01             	add    $0x1,%ecx
  800bc7:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bcc:	eb ce                	jmp    800b9c <strtol+0x44>
		s += 2, base = 16;
  800bce:	83 c1 02             	add    $0x2,%ecx
  800bd1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bd6:	eb c4                	jmp    800b9c <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bd8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bdb:	89 f3                	mov    %esi,%ebx
  800bdd:	80 fb 19             	cmp    $0x19,%bl
  800be0:	77 29                	ja     800c0b <strtol+0xb3>
			dig = *s - 'a' + 10;
  800be2:	0f be d2             	movsbl %dl,%edx
  800be5:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800be8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800beb:	7d 30                	jge    800c1d <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bed:	83 c1 01             	add    $0x1,%ecx
  800bf0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bf4:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bf6:	0f b6 11             	movzbl (%ecx),%edx
  800bf9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bfc:	89 f3                	mov    %esi,%ebx
  800bfe:	80 fb 09             	cmp    $0x9,%bl
  800c01:	77 d5                	ja     800bd8 <strtol+0x80>
			dig = *s - '0';
  800c03:	0f be d2             	movsbl %dl,%edx
  800c06:	83 ea 30             	sub    $0x30,%edx
  800c09:	eb dd                	jmp    800be8 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c0b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c0e:	89 f3                	mov    %esi,%ebx
  800c10:	80 fb 19             	cmp    $0x19,%bl
  800c13:	77 08                	ja     800c1d <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c15:	0f be d2             	movsbl %dl,%edx
  800c18:	83 ea 37             	sub    $0x37,%edx
  800c1b:	eb cb                	jmp    800be8 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c1d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c21:	74 05                	je     800c28 <strtol+0xd0>
		*endptr = (char *) s;
  800c23:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c26:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c28:	89 c2                	mov    %eax,%edx
  800c2a:	f7 da                	neg    %edx
  800c2c:	85 ff                	test   %edi,%edi
  800c2e:	0f 45 c2             	cmovne %edx,%eax
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    
  800c36:	66 90                	xchg   %ax,%ax
  800c38:	66 90                	xchg   %ax,%ax
  800c3a:	66 90                	xchg   %ax,%ax
  800c3c:	66 90                	xchg   %ax,%ax
  800c3e:	66 90                	xchg   %ax,%ax

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
