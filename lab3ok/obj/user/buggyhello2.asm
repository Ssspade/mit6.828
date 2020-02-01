
obj/user/buggyhello2：     文件格式 elf32-i386


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
  80002c:	e8 30 00 00 00       	call   800061 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 1e 00 00 00       	call   80005d <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	sys_cputs(hello, 1024*1024);
  800045:	68 00 00 10 00       	push   $0x100000
  80004a:	ff b3 0c 00 00 00    	pushl  0xc(%ebx)
  800050:	e8 8b 00 00 00       	call   8000e0 <sys_cputs>
}
  800055:	83 c4 10             	add    $0x10,%esp
  800058:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80005b:	c9                   	leave  
  80005c:	c3                   	ret    

0080005d <__x86.get_pc_thunk.bx>:
  80005d:	8b 1c 24             	mov    (%esp),%ebx
  800060:	c3                   	ret    

00800061 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	57                   	push   %edi
  800065:	56                   	push   %esi
  800066:	53                   	push   %ebx
  800067:	83 ec 0c             	sub    $0xc,%esp
  80006a:	e8 ee ff ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  80006f:	81 c3 91 1f 00 00    	add    $0x1f91,%ebx
  800075:	8b 75 08             	mov    0x8(%ebp),%esi
  800078:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80007b:	e8 f2 00 00 00       	call   800172 <sys_getenvid>
  800080:	25 ff 03 00 00       	and    $0x3ff,%eax
  800085:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800088:	c1 e0 05             	shl    $0x5,%eax
  80008b:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800091:	c7 c2 30 20 80 00    	mov    $0x802030,%edx
  800097:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800099:	85 f6                	test   %esi,%esi
  80009b:	7e 08                	jle    8000a5 <libmain+0x44>
		binaryname = argv[0];
  80009d:	8b 07                	mov    (%edi),%eax
  80009f:	89 83 10 00 00 00    	mov    %eax,0x10(%ebx)

	// call user main routine
	umain(argc, argv);
  8000a5:	83 ec 08             	sub    $0x8,%esp
  8000a8:	57                   	push   %edi
  8000a9:	56                   	push   %esi
  8000aa:	e8 84 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000af:	e8 0b 00 00 00       	call   8000bf <exit>
}
  8000b4:	83 c4 10             	add    $0x10,%esp
  8000b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ba:	5b                   	pop    %ebx
  8000bb:	5e                   	pop    %esi
  8000bc:	5f                   	pop    %edi
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    

008000bf <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	53                   	push   %ebx
  8000c3:	83 ec 10             	sub    $0x10,%esp
  8000c6:	e8 92 ff ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8000cb:	81 c3 35 1f 00 00    	add    $0x1f35,%ebx
	sys_env_destroy(0);
  8000d1:	6a 00                	push   $0x0
  8000d3:	e8 45 00 00 00       	call   80011d <sys_env_destroy>
}
  8000d8:	83 c4 10             	add    $0x10,%esp
  8000db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	57                   	push   %edi
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000f1:	89 c3                	mov    %eax,%ebx
  8000f3:	89 c7                	mov    %eax,%edi
  8000f5:	89 c6                	mov    %eax,%esi
  8000f7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <sys_cgetc>:

int
sys_cgetc(void)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	57                   	push   %edi
  800102:	56                   	push   %esi
  800103:	53                   	push   %ebx
	asm volatile("int %1\n"
  800104:	ba 00 00 00 00       	mov    $0x0,%edx
  800109:	b8 01 00 00 00       	mov    $0x1,%eax
  80010e:	89 d1                	mov    %edx,%ecx
  800110:	89 d3                	mov    %edx,%ebx
  800112:	89 d7                	mov    %edx,%edi
  800114:	89 d6                	mov    %edx,%esi
  800116:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800118:	5b                   	pop    %ebx
  800119:	5e                   	pop    %esi
  80011a:	5f                   	pop    %edi
  80011b:	5d                   	pop    %ebp
  80011c:	c3                   	ret    

0080011d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	57                   	push   %edi
  800121:	56                   	push   %esi
  800122:	53                   	push   %ebx
  800123:	83 ec 1c             	sub    $0x1c,%esp
  800126:	e8 66 00 00 00       	call   800191 <__x86.get_pc_thunk.ax>
  80012b:	05 d5 1e 00 00       	add    $0x1ed5,%eax
  800130:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800133:	b9 00 00 00 00       	mov    $0x0,%ecx
  800138:	8b 55 08             	mov    0x8(%ebp),%edx
  80013b:	b8 03 00 00 00       	mov    $0x3,%eax
  800140:	89 cb                	mov    %ecx,%ebx
  800142:	89 cf                	mov    %ecx,%edi
  800144:	89 ce                	mov    %ecx,%esi
  800146:	cd 30                	int    $0x30
	if(check && ret > 0)
  800148:	85 c0                	test   %eax,%eax
  80014a:	7f 08                	jg     800154 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80014c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80014f:	5b                   	pop    %ebx
  800150:	5e                   	pop    %esi
  800151:	5f                   	pop    %edi
  800152:	5d                   	pop    %ebp
  800153:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800154:	83 ec 0c             	sub    $0xc,%esp
  800157:	50                   	push   %eax
  800158:	6a 03                	push   $0x3
  80015a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80015d:	8d 83 94 ee ff ff    	lea    -0x116c(%ebx),%eax
  800163:	50                   	push   %eax
  800164:	6a 23                	push   $0x23
  800166:	8d 83 b1 ee ff ff    	lea    -0x114f(%ebx),%eax
  80016c:	50                   	push   %eax
  80016d:	e8 23 00 00 00       	call   800195 <_panic>

00800172 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	57                   	push   %edi
  800176:	56                   	push   %esi
  800177:	53                   	push   %ebx
	asm volatile("int %1\n"
  800178:	ba 00 00 00 00       	mov    $0x0,%edx
  80017d:	b8 02 00 00 00       	mov    $0x2,%eax
  800182:	89 d1                	mov    %edx,%ecx
  800184:	89 d3                	mov    %edx,%ebx
  800186:	89 d7                	mov    %edx,%edi
  800188:	89 d6                	mov    %edx,%esi
  80018a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80018c:	5b                   	pop    %ebx
  80018d:	5e                   	pop    %esi
  80018e:	5f                   	pop    %edi
  80018f:	5d                   	pop    %ebp
  800190:	c3                   	ret    

00800191 <__x86.get_pc_thunk.ax>:
  800191:	8b 04 24             	mov    (%esp),%eax
  800194:	c3                   	ret    

00800195 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	57                   	push   %edi
  800199:	56                   	push   %esi
  80019a:	53                   	push   %ebx
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	e8 ba fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8001a3:	81 c3 5d 1e 00 00    	add    $0x1e5d,%ebx
	va_list ap;

	va_start(ap, fmt);
  8001a9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001ac:	c7 c0 10 20 80 00    	mov    $0x802010,%eax
  8001b2:	8b 38                	mov    (%eax),%edi
  8001b4:	e8 b9 ff ff ff       	call   800172 <sys_getenvid>
  8001b9:	83 ec 0c             	sub    $0xc,%esp
  8001bc:	ff 75 0c             	pushl  0xc(%ebp)
  8001bf:	ff 75 08             	pushl  0x8(%ebp)
  8001c2:	57                   	push   %edi
  8001c3:	50                   	push   %eax
  8001c4:	8d 83 c0 ee ff ff    	lea    -0x1140(%ebx),%eax
  8001ca:	50                   	push   %eax
  8001cb:	e8 d1 00 00 00       	call   8002a1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001d0:	83 c4 18             	add    $0x18,%esp
  8001d3:	56                   	push   %esi
  8001d4:	ff 75 10             	pushl  0x10(%ebp)
  8001d7:	e8 63 00 00 00       	call   80023f <vcprintf>
	cprintf("\n");
  8001dc:	8d 83 88 ee ff ff    	lea    -0x1178(%ebx),%eax
  8001e2:	89 04 24             	mov    %eax,(%esp)
  8001e5:	e8 b7 00 00 00       	call   8002a1 <cprintf>
  8001ea:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ed:	cc                   	int3   
  8001ee:	eb fd                	jmp    8001ed <_panic+0x58>

008001f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	e8 63 fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8001fa:	81 c3 06 1e 00 00    	add    $0x1e06,%ebx
  800200:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  800203:	8b 16                	mov    (%esi),%edx
  800205:	8d 42 01             	lea    0x1(%edx),%eax
  800208:	89 06                	mov    %eax,(%esi)
  80020a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020d:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800211:	3d ff 00 00 00       	cmp    $0xff,%eax
  800216:	74 0b                	je     800223 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800218:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80021c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80021f:	5b                   	pop    %ebx
  800220:	5e                   	pop    %esi
  800221:	5d                   	pop    %ebp
  800222:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	68 ff 00 00 00       	push   $0xff
  80022b:	8d 46 08             	lea    0x8(%esi),%eax
  80022e:	50                   	push   %eax
  80022f:	e8 ac fe ff ff       	call   8000e0 <sys_cputs>
		b->idx = 0;
  800234:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80023a:	83 c4 10             	add    $0x10,%esp
  80023d:	eb d9                	jmp    800218 <putch+0x28>

0080023f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	53                   	push   %ebx
  800243:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800249:	e8 0f fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  80024e:	81 c3 b2 1d 00 00    	add    $0x1db2,%ebx
	struct printbuf b;

	b.idx = 0;
  800254:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80025b:	00 00 00 
	b.cnt = 0;
  80025e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800265:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800268:	ff 75 0c             	pushl  0xc(%ebp)
  80026b:	ff 75 08             	pushl  0x8(%ebp)
  80026e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800274:	50                   	push   %eax
  800275:	8d 83 f0 e1 ff ff    	lea    -0x1e10(%ebx),%eax
  80027b:	50                   	push   %eax
  80027c:	e8 38 01 00 00       	call   8003b9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800281:	83 c4 08             	add    $0x8,%esp
  800284:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80028a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800290:	50                   	push   %eax
  800291:	e8 4a fe ff ff       	call   8000e0 <sys_cputs>

	return b.cnt;
}
  800296:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80029c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029f:	c9                   	leave  
  8002a0:	c3                   	ret    

008002a1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002a7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002aa:	50                   	push   %eax
  8002ab:	ff 75 08             	pushl  0x8(%ebp)
  8002ae:	e8 8c ff ff ff       	call   80023f <vcprintf>
	va_end(ap);

	return cnt;
}
  8002b3:	c9                   	leave  
  8002b4:	c3                   	ret    

008002b5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	56                   	push   %esi
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 2c             	sub    $0x2c,%esp
  8002be:	e8 02 06 00 00       	call   8008c5 <__x86.get_pc_thunk.cx>
  8002c3:	81 c1 3d 1d 00 00    	add    $0x1d3d,%ecx
  8002c9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002cc:	89 c7                	mov    %eax,%edi
  8002ce:	89 d6                	mov    %edx,%esi
  8002d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002d9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e4:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002e7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002ea:	39 d3                	cmp    %edx,%ebx
  8002ec:	72 09                	jb     8002f7 <printnum+0x42>
  8002ee:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f1:	0f 87 83 00 00 00    	ja     80037a <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f7:	83 ec 0c             	sub    $0xc,%esp
  8002fa:	ff 75 18             	pushl  0x18(%ebp)
  8002fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800300:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800303:	53                   	push   %ebx
  800304:	ff 75 10             	pushl  0x10(%ebp)
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	ff 75 dc             	pushl  -0x24(%ebp)
  80030d:	ff 75 d8             	pushl  -0x28(%ebp)
  800310:	ff 75 d4             	pushl  -0x2c(%ebp)
  800313:	ff 75 d0             	pushl  -0x30(%ebp)
  800316:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800319:	e8 22 09 00 00       	call   800c40 <__udivdi3>
  80031e:	83 c4 18             	add    $0x18,%esp
  800321:	52                   	push   %edx
  800322:	50                   	push   %eax
  800323:	89 f2                	mov    %esi,%edx
  800325:	89 f8                	mov    %edi,%eax
  800327:	e8 89 ff ff ff       	call   8002b5 <printnum>
  80032c:	83 c4 20             	add    $0x20,%esp
  80032f:	eb 13                	jmp    800344 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800331:	83 ec 08             	sub    $0x8,%esp
  800334:	56                   	push   %esi
  800335:	ff 75 18             	pushl  0x18(%ebp)
  800338:	ff d7                	call   *%edi
  80033a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80033d:	83 eb 01             	sub    $0x1,%ebx
  800340:	85 db                	test   %ebx,%ebx
  800342:	7f ed                	jg     800331 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800344:	83 ec 08             	sub    $0x8,%esp
  800347:	56                   	push   %esi
  800348:	83 ec 04             	sub    $0x4,%esp
  80034b:	ff 75 dc             	pushl  -0x24(%ebp)
  80034e:	ff 75 d8             	pushl  -0x28(%ebp)
  800351:	ff 75 d4             	pushl  -0x2c(%ebp)
  800354:	ff 75 d0             	pushl  -0x30(%ebp)
  800357:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80035a:	89 f3                	mov    %esi,%ebx
  80035c:	e8 ff 09 00 00       	call   800d60 <__umoddi3>
  800361:	83 c4 14             	add    $0x14,%esp
  800364:	0f be 84 06 e4 ee ff 	movsbl -0x111c(%esi,%eax,1),%eax
  80036b:	ff 
  80036c:	50                   	push   %eax
  80036d:	ff d7                	call   *%edi
}
  80036f:	83 c4 10             	add    $0x10,%esp
  800372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    
  80037a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80037d:	eb be                	jmp    80033d <printnum+0x88>

0080037f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80037f:	55                   	push   %ebp
  800380:	89 e5                	mov    %esp,%ebp
  800382:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800385:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	3b 50 04             	cmp    0x4(%eax),%edx
  80038e:	73 0a                	jae    80039a <sprintputch+0x1b>
		*b->buf++ = ch;
  800390:	8d 4a 01             	lea    0x1(%edx),%ecx
  800393:	89 08                	mov    %ecx,(%eax)
  800395:	8b 45 08             	mov    0x8(%ebp),%eax
  800398:	88 02                	mov    %al,(%edx)
}
  80039a:	5d                   	pop    %ebp
  80039b:	c3                   	ret    

0080039c <printfmt>:
{
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
  80039f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003a2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a5:	50                   	push   %eax
  8003a6:	ff 75 10             	pushl  0x10(%ebp)
  8003a9:	ff 75 0c             	pushl  0xc(%ebp)
  8003ac:	ff 75 08             	pushl  0x8(%ebp)
  8003af:	e8 05 00 00 00       	call   8003b9 <vprintfmt>
}
  8003b4:	83 c4 10             	add    $0x10,%esp
  8003b7:	c9                   	leave  
  8003b8:	c3                   	ret    

008003b9 <vprintfmt>:
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	57                   	push   %edi
  8003bd:	56                   	push   %esi
  8003be:	53                   	push   %ebx
  8003bf:	83 ec 2c             	sub    $0x2c,%esp
  8003c2:	e8 96 fc ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8003c7:	81 c3 39 1c 00 00    	add    $0x1c39,%ebx
  8003cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003d0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003d3:	e9 c3 03 00 00       	jmp    80079b <.L35+0x48>
		padc = ' ';
  8003d8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003dc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003e3:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003ea:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8d 47 01             	lea    0x1(%edi),%eax
  8003fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ff:	0f b6 17             	movzbl (%edi),%edx
  800402:	8d 42 dd             	lea    -0x23(%edx),%eax
  800405:	3c 55                	cmp    $0x55,%al
  800407:	0f 87 16 04 00 00    	ja     800823 <.L22>
  80040d:	0f b6 c0             	movzbl %al,%eax
  800410:	89 d9                	mov    %ebx,%ecx
  800412:	03 8c 83 74 ef ff ff 	add    -0x108c(%ebx,%eax,4),%ecx
  800419:	ff e1                	jmp    *%ecx

0080041b <.L69>:
  80041b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80041e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800422:	eb d5                	jmp    8003f9 <vprintfmt+0x40>

00800424 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800424:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800427:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80042b:	eb cc                	jmp    8003f9 <vprintfmt+0x40>

0080042d <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	0f b6 d2             	movzbl %dl,%edx
  800430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800433:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800438:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80043b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80043f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800442:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800445:	83 f9 09             	cmp    $0x9,%ecx
  800448:	77 55                	ja     80049f <.L23+0xf>
			for (precision = 0; ; ++fmt) {
  80044a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80044d:	eb e9                	jmp    800438 <.L29+0xb>

0080044f <.L26>:
			precision = va_arg(ap, int);
  80044f:	8b 45 14             	mov    0x14(%ebp),%eax
  800452:	8b 00                	mov    (%eax),%eax
  800454:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800457:	8b 45 14             	mov    0x14(%ebp),%eax
  80045a:	8d 40 04             	lea    0x4(%eax),%eax
  80045d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800460:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800463:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800467:	79 90                	jns    8003f9 <vprintfmt+0x40>
				width = precision, precision = -1;
  800469:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80046c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80046f:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800476:	eb 81                	jmp    8003f9 <vprintfmt+0x40>

00800478 <.L27>:
  800478:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80047b:	85 c0                	test   %eax,%eax
  80047d:	ba 00 00 00 00       	mov    $0x0,%edx
  800482:	0f 49 d0             	cmovns %eax,%edx
  800485:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800488:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80048b:	e9 69 ff ff ff       	jmp    8003f9 <vprintfmt+0x40>

00800490 <.L23>:
  800490:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800493:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80049a:	e9 5a ff ff ff       	jmp    8003f9 <vprintfmt+0x40>
  80049f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004a2:	eb bf                	jmp    800463 <.L26+0x14>

008004a4 <.L33>:
			lflag++;
  8004a4:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004ab:	e9 49 ff ff ff       	jmp    8003f9 <vprintfmt+0x40>

008004b0 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b3:	8d 78 04             	lea    0x4(%eax),%edi
  8004b6:	83 ec 08             	sub    $0x8,%esp
  8004b9:	56                   	push   %esi
  8004ba:	ff 30                	pushl  (%eax)
  8004bc:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004bf:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004c2:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004c5:	e9 ce 02 00 00       	jmp    800798 <.L35+0x45>

008004ca <.L32>:
			err = va_arg(ap, int);
  8004ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cd:	8d 78 04             	lea    0x4(%eax),%edi
  8004d0:	8b 00                	mov    (%eax),%eax
  8004d2:	99                   	cltd   
  8004d3:	31 d0                	xor    %edx,%eax
  8004d5:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d7:	83 f8 06             	cmp    $0x6,%eax
  8004da:	7f 27                	jg     800503 <.L32+0x39>
  8004dc:	8b 94 83 14 00 00 00 	mov    0x14(%ebx,%eax,4),%edx
  8004e3:	85 d2                	test   %edx,%edx
  8004e5:	74 1c                	je     800503 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004e7:	52                   	push   %edx
  8004e8:	8d 83 05 ef ff ff    	lea    -0x10fb(%ebx),%eax
  8004ee:	50                   	push   %eax
  8004ef:	56                   	push   %esi
  8004f0:	ff 75 08             	pushl  0x8(%ebp)
  8004f3:	e8 a4 fe ff ff       	call   80039c <printfmt>
  8004f8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004fb:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004fe:	e9 95 02 00 00       	jmp    800798 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  800503:	50                   	push   %eax
  800504:	8d 83 fc ee ff ff    	lea    -0x1104(%ebx),%eax
  80050a:	50                   	push   %eax
  80050b:	56                   	push   %esi
  80050c:	ff 75 08             	pushl  0x8(%ebp)
  80050f:	e8 88 fe ff ff       	call   80039c <printfmt>
  800514:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800517:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80051a:	e9 79 02 00 00       	jmp    800798 <.L35+0x45>

0080051f <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  80051f:	8b 45 14             	mov    0x14(%ebp),%eax
  800522:	83 c0 04             	add    $0x4,%eax
  800525:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80052d:	85 ff                	test   %edi,%edi
  80052f:	8d 83 f5 ee ff ff    	lea    -0x110b(%ebx),%eax
  800535:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800538:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80053c:	0f 8e b5 00 00 00    	jle    8005f7 <.L36+0xd8>
  800542:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800546:	75 08                	jne    800550 <.L36+0x31>
  800548:	89 75 0c             	mov    %esi,0xc(%ebp)
  80054b:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80054e:	eb 6d                	jmp    8005bd <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	ff 75 cc             	pushl  -0x34(%ebp)
  800556:	57                   	push   %edi
  800557:	e8 85 03 00 00       	call   8008e1 <strnlen>
  80055c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80055f:	29 c2                	sub    %eax,%edx
  800561:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800564:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800567:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80056b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80056e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800571:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800573:	eb 10                	jmp    800585 <.L36+0x66>
					putch(padc, putdat);
  800575:	83 ec 08             	sub    $0x8,%esp
  800578:	56                   	push   %esi
  800579:	ff 75 e0             	pushl  -0x20(%ebp)
  80057c:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80057f:	83 ef 01             	sub    $0x1,%edi
  800582:	83 c4 10             	add    $0x10,%esp
  800585:	85 ff                	test   %edi,%edi
  800587:	7f ec                	jg     800575 <.L36+0x56>
  800589:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80058c:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80058f:	85 d2                	test   %edx,%edx
  800591:	b8 00 00 00 00       	mov    $0x0,%eax
  800596:	0f 49 c2             	cmovns %edx,%eax
  800599:	29 c2                	sub    %eax,%edx
  80059b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80059e:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005a1:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005a4:	eb 17                	jmp    8005bd <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  8005a6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005aa:	75 30                	jne    8005dc <.L36+0xbd>
					putch(ch, putdat);
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	ff 75 0c             	pushl  0xc(%ebp)
  8005b2:	50                   	push   %eax
  8005b3:	ff 55 08             	call   *0x8(%ebp)
  8005b6:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b9:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005bd:	83 c7 01             	add    $0x1,%edi
  8005c0:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005c4:	0f be c2             	movsbl %dl,%eax
  8005c7:	85 c0                	test   %eax,%eax
  8005c9:	74 52                	je     80061d <.L36+0xfe>
  8005cb:	85 f6                	test   %esi,%esi
  8005cd:	78 d7                	js     8005a6 <.L36+0x87>
  8005cf:	83 ee 01             	sub    $0x1,%esi
  8005d2:	79 d2                	jns    8005a6 <.L36+0x87>
  8005d4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005d7:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005da:	eb 32                	jmp    80060e <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005dc:	0f be d2             	movsbl %dl,%edx
  8005df:	83 ea 20             	sub    $0x20,%edx
  8005e2:	83 fa 5e             	cmp    $0x5e,%edx
  8005e5:	76 c5                	jbe    8005ac <.L36+0x8d>
					putch('?', putdat);
  8005e7:	83 ec 08             	sub    $0x8,%esp
  8005ea:	ff 75 0c             	pushl  0xc(%ebp)
  8005ed:	6a 3f                	push   $0x3f
  8005ef:	ff 55 08             	call   *0x8(%ebp)
  8005f2:	83 c4 10             	add    $0x10,%esp
  8005f5:	eb c2                	jmp    8005b9 <.L36+0x9a>
  8005f7:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005fa:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005fd:	eb be                	jmp    8005bd <.L36+0x9e>
				putch(' ', putdat);
  8005ff:	83 ec 08             	sub    $0x8,%esp
  800602:	56                   	push   %esi
  800603:	6a 20                	push   $0x20
  800605:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800608:	83 ef 01             	sub    $0x1,%edi
  80060b:	83 c4 10             	add    $0x10,%esp
  80060e:	85 ff                	test   %edi,%edi
  800610:	7f ed                	jg     8005ff <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  800612:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800615:	89 45 14             	mov    %eax,0x14(%ebp)
  800618:	e9 7b 01 00 00       	jmp    800798 <.L35+0x45>
  80061d:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800620:	8b 75 0c             	mov    0xc(%ebp),%esi
  800623:	eb e9                	jmp    80060e <.L36+0xef>

00800625 <.L31>:
  800625:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800628:	83 f9 01             	cmp    $0x1,%ecx
  80062b:	7e 40                	jle    80066d <.L31+0x48>
		return va_arg(*ap, long long);
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8b 50 04             	mov    0x4(%eax),%edx
  800633:	8b 00                	mov    (%eax),%eax
  800635:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800638:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8d 40 08             	lea    0x8(%eax),%eax
  800641:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800644:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800648:	79 55                	jns    80069f <.L31+0x7a>
				putch('-', putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	56                   	push   %esi
  80064e:	6a 2d                	push   $0x2d
  800650:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800653:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800656:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800659:	f7 da                	neg    %edx
  80065b:	83 d1 00             	adc    $0x0,%ecx
  80065e:	f7 d9                	neg    %ecx
  800660:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800663:	b8 0a 00 00 00       	mov    $0xa,%eax
  800668:	e9 10 01 00 00       	jmp    80077d <.L35+0x2a>
	else if (lflag)
  80066d:	85 c9                	test   %ecx,%ecx
  80066f:	75 17                	jne    800688 <.L31+0x63>
		return va_arg(*ap, int);
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8b 00                	mov    (%eax),%eax
  800676:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800679:	99                   	cltd   
  80067a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8d 40 04             	lea    0x4(%eax),%eax
  800683:	89 45 14             	mov    %eax,0x14(%ebp)
  800686:	eb bc                	jmp    800644 <.L31+0x1f>
		return va_arg(*ap, long);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8b 00                	mov    (%eax),%eax
  80068d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800690:	99                   	cltd   
  800691:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 40 04             	lea    0x4(%eax),%eax
  80069a:	89 45 14             	mov    %eax,0x14(%ebp)
  80069d:	eb a5                	jmp    800644 <.L31+0x1f>
			num = getint(&ap, lflag);
  80069f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006a2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006aa:	e9 ce 00 00 00       	jmp    80077d <.L35+0x2a>

008006af <.L37>:
  8006af:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006b2:	83 f9 01             	cmp    $0x1,%ecx
  8006b5:	7e 18                	jle    8006cf <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8006b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ba:	8b 10                	mov    (%eax),%edx
  8006bc:	8b 48 04             	mov    0x4(%eax),%ecx
  8006bf:	8d 40 08             	lea    0x8(%eax),%eax
  8006c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ca:	e9 ae 00 00 00       	jmp    80077d <.L35+0x2a>
	else if (lflag)
  8006cf:	85 c9                	test   %ecx,%ecx
  8006d1:	75 1a                	jne    8006ed <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8b 10                	mov    (%eax),%edx
  8006d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006dd:	8d 40 04             	lea    0x4(%eax),%eax
  8006e0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006e3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e8:	e9 90 00 00 00       	jmp    80077d <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f0:	8b 10                	mov    (%eax),%edx
  8006f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f7:	8d 40 04             	lea    0x4(%eax),%eax
  8006fa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006fd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800702:	eb 79                	jmp    80077d <.L35+0x2a>

00800704 <.L34>:
  800704:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800707:	83 f9 01             	cmp    $0x1,%ecx
  80070a:	7e 15                	jle    800721 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  80070c:	8b 45 14             	mov    0x14(%ebp),%eax
  80070f:	8b 10                	mov    (%eax),%edx
  800711:	8b 48 04             	mov    0x4(%eax),%ecx
  800714:	8d 40 08             	lea    0x8(%eax),%eax
  800717:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80071a:	b8 08 00 00 00       	mov    $0x8,%eax
  80071f:	eb 5c                	jmp    80077d <.L35+0x2a>
	else if (lflag)
  800721:	85 c9                	test   %ecx,%ecx
  800723:	75 17                	jne    80073c <.L34+0x38>
		return va_arg(*ap, unsigned int);
  800725:	8b 45 14             	mov    0x14(%ebp),%eax
  800728:	8b 10                	mov    (%eax),%edx
  80072a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072f:	8d 40 04             	lea    0x4(%eax),%eax
  800732:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800735:	b8 08 00 00 00       	mov    $0x8,%eax
  80073a:	eb 41                	jmp    80077d <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  80073c:	8b 45 14             	mov    0x14(%ebp),%eax
  80073f:	8b 10                	mov    (%eax),%edx
  800741:	b9 00 00 00 00       	mov    $0x0,%ecx
  800746:	8d 40 04             	lea    0x4(%eax),%eax
  800749:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80074c:	b8 08 00 00 00       	mov    $0x8,%eax
  800751:	eb 2a                	jmp    80077d <.L35+0x2a>

00800753 <.L35>:
			putch('0', putdat);
  800753:	83 ec 08             	sub    $0x8,%esp
  800756:	56                   	push   %esi
  800757:	6a 30                	push   $0x30
  800759:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80075c:	83 c4 08             	add    $0x8,%esp
  80075f:	56                   	push   %esi
  800760:	6a 78                	push   $0x78
  800762:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800765:	8b 45 14             	mov    0x14(%ebp),%eax
  800768:	8b 10                	mov    (%eax),%edx
  80076a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80076f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800772:	8d 40 04             	lea    0x4(%eax),%eax
  800775:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800778:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80077d:	83 ec 0c             	sub    $0xc,%esp
  800780:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800784:	57                   	push   %edi
  800785:	ff 75 e0             	pushl  -0x20(%ebp)
  800788:	50                   	push   %eax
  800789:	51                   	push   %ecx
  80078a:	52                   	push   %edx
  80078b:	89 f2                	mov    %esi,%edx
  80078d:	8b 45 08             	mov    0x8(%ebp),%eax
  800790:	e8 20 fb ff ff       	call   8002b5 <printnum>
			break;
  800795:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800798:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80079b:	83 c7 01             	add    $0x1,%edi
  80079e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007a2:	83 f8 25             	cmp    $0x25,%eax
  8007a5:	0f 84 2d fc ff ff    	je     8003d8 <vprintfmt+0x1f>
			if (ch == '\0')
  8007ab:	85 c0                	test   %eax,%eax
  8007ad:	0f 84 91 00 00 00    	je     800844 <.L22+0x21>
			putch(ch, putdat);
  8007b3:	83 ec 08             	sub    $0x8,%esp
  8007b6:	56                   	push   %esi
  8007b7:	50                   	push   %eax
  8007b8:	ff 55 08             	call   *0x8(%ebp)
  8007bb:	83 c4 10             	add    $0x10,%esp
  8007be:	eb db                	jmp    80079b <.L35+0x48>

008007c0 <.L38>:
  8007c0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8007c3:	83 f9 01             	cmp    $0x1,%ecx
  8007c6:	7e 15                	jle    8007dd <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8007c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cb:	8b 10                	mov    (%eax),%edx
  8007cd:	8b 48 04             	mov    0x4(%eax),%ecx
  8007d0:	8d 40 08             	lea    0x8(%eax),%eax
  8007d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d6:	b8 10 00 00 00       	mov    $0x10,%eax
  8007db:	eb a0                	jmp    80077d <.L35+0x2a>
	else if (lflag)
  8007dd:	85 c9                	test   %ecx,%ecx
  8007df:	75 17                	jne    8007f8 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8007e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e4:	8b 10                	mov    (%eax),%edx
  8007e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007eb:	8d 40 04             	lea    0x4(%eax),%eax
  8007ee:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f1:	b8 10 00 00 00       	mov    $0x10,%eax
  8007f6:	eb 85                	jmp    80077d <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fb:	8b 10                	mov    (%eax),%edx
  8007fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800802:	8d 40 04             	lea    0x4(%eax),%eax
  800805:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800808:	b8 10 00 00 00       	mov    $0x10,%eax
  80080d:	e9 6b ff ff ff       	jmp    80077d <.L35+0x2a>

00800812 <.L25>:
			putch(ch, putdat);
  800812:	83 ec 08             	sub    $0x8,%esp
  800815:	56                   	push   %esi
  800816:	6a 25                	push   $0x25
  800818:	ff 55 08             	call   *0x8(%ebp)
			break;
  80081b:	83 c4 10             	add    $0x10,%esp
  80081e:	e9 75 ff ff ff       	jmp    800798 <.L35+0x45>

00800823 <.L22>:
			putch('%', putdat);
  800823:	83 ec 08             	sub    $0x8,%esp
  800826:	56                   	push   %esi
  800827:	6a 25                	push   $0x25
  800829:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80082c:	83 c4 10             	add    $0x10,%esp
  80082f:	89 f8                	mov    %edi,%eax
  800831:	eb 03                	jmp    800836 <.L22+0x13>
  800833:	83 e8 01             	sub    $0x1,%eax
  800836:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80083a:	75 f7                	jne    800833 <.L22+0x10>
  80083c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80083f:	e9 54 ff ff ff       	jmp    800798 <.L35+0x45>
}
  800844:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800847:	5b                   	pop    %ebx
  800848:	5e                   	pop    %esi
  800849:	5f                   	pop    %edi
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	53                   	push   %ebx
  800850:	83 ec 14             	sub    $0x14,%esp
  800853:	e8 05 f8 ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  800858:	81 c3 a8 17 00 00    	add    $0x17a8,%ebx
  80085e:	8b 45 08             	mov    0x8(%ebp),%eax
  800861:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800864:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800867:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80086b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80086e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800875:	85 c0                	test   %eax,%eax
  800877:	74 2b                	je     8008a4 <vsnprintf+0x58>
  800879:	85 d2                	test   %edx,%edx
  80087b:	7e 27                	jle    8008a4 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80087d:	ff 75 14             	pushl  0x14(%ebp)
  800880:	ff 75 10             	pushl  0x10(%ebp)
  800883:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800886:	50                   	push   %eax
  800887:	8d 83 7f e3 ff ff    	lea    -0x1c81(%ebx),%eax
  80088d:	50                   	push   %eax
  80088e:	e8 26 fb ff ff       	call   8003b9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800893:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800896:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800899:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80089c:	83 c4 10             	add    $0x10,%esp
}
  80089f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a2:	c9                   	leave  
  8008a3:	c3                   	ret    
		return -E_INVAL;
  8008a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008a9:	eb f4                	jmp    80089f <vsnprintf+0x53>

008008ab <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008b1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008b4:	50                   	push   %eax
  8008b5:	ff 75 10             	pushl  0x10(%ebp)
  8008b8:	ff 75 0c             	pushl  0xc(%ebp)
  8008bb:	ff 75 08             	pushl  0x8(%ebp)
  8008be:	e8 89 ff ff ff       	call   80084c <vsnprintf>
	va_end(ap);

	return rc;
}
  8008c3:	c9                   	leave  
  8008c4:	c3                   	ret    

008008c5 <__x86.get_pc_thunk.cx>:
  8008c5:	8b 0c 24             	mov    (%esp),%ecx
  8008c8:	c3                   	ret    

008008c9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d4:	eb 03                	jmp    8008d9 <strlen+0x10>
		n++;
  8008d6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008d9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008dd:	75 f7                	jne    8008d6 <strlen+0xd>
	return n;
}
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ef:	eb 03                	jmp    8008f4 <strnlen+0x13>
		n++;
  8008f1:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f4:	39 d0                	cmp    %edx,%eax
  8008f6:	74 06                	je     8008fe <strnlen+0x1d>
  8008f8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008fc:	75 f3                	jne    8008f1 <strnlen+0x10>
	return n;
}
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	53                   	push   %ebx
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80090a:	89 c2                	mov    %eax,%edx
  80090c:	83 c1 01             	add    $0x1,%ecx
  80090f:	83 c2 01             	add    $0x1,%edx
  800912:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800916:	88 5a ff             	mov    %bl,-0x1(%edx)
  800919:	84 db                	test   %bl,%bl
  80091b:	75 ef                	jne    80090c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80091d:	5b                   	pop    %ebx
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	53                   	push   %ebx
  800924:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800927:	53                   	push   %ebx
  800928:	e8 9c ff ff ff       	call   8008c9 <strlen>
  80092d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800930:	ff 75 0c             	pushl  0xc(%ebp)
  800933:	01 d8                	add    %ebx,%eax
  800935:	50                   	push   %eax
  800936:	e8 c5 ff ff ff       	call   800900 <strcpy>
	return dst;
}
  80093b:	89 d8                	mov    %ebx,%eax
  80093d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800940:	c9                   	leave  
  800941:	c3                   	ret    

00800942 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	56                   	push   %esi
  800946:	53                   	push   %ebx
  800947:	8b 75 08             	mov    0x8(%ebp),%esi
  80094a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80094d:	89 f3                	mov    %esi,%ebx
  80094f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800952:	89 f2                	mov    %esi,%edx
  800954:	eb 0f                	jmp    800965 <strncpy+0x23>
		*dst++ = *src;
  800956:	83 c2 01             	add    $0x1,%edx
  800959:	0f b6 01             	movzbl (%ecx),%eax
  80095c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80095f:	80 39 01             	cmpb   $0x1,(%ecx)
  800962:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800965:	39 da                	cmp    %ebx,%edx
  800967:	75 ed                	jne    800956 <strncpy+0x14>
	}
	return ret;
}
  800969:	89 f0                	mov    %esi,%eax
  80096b:	5b                   	pop    %ebx
  80096c:	5e                   	pop    %esi
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	56                   	push   %esi
  800973:	53                   	push   %ebx
  800974:	8b 75 08             	mov    0x8(%ebp),%esi
  800977:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80097d:	89 f0                	mov    %esi,%eax
  80097f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800983:	85 c9                	test   %ecx,%ecx
  800985:	75 0b                	jne    800992 <strlcpy+0x23>
  800987:	eb 17                	jmp    8009a0 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800989:	83 c2 01             	add    $0x1,%edx
  80098c:	83 c0 01             	add    $0x1,%eax
  80098f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800992:	39 d8                	cmp    %ebx,%eax
  800994:	74 07                	je     80099d <strlcpy+0x2e>
  800996:	0f b6 0a             	movzbl (%edx),%ecx
  800999:	84 c9                	test   %cl,%cl
  80099b:	75 ec                	jne    800989 <strlcpy+0x1a>
		*dst = '\0';
  80099d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009a0:	29 f0                	sub    %esi,%eax
}
  8009a2:	5b                   	pop    %ebx
  8009a3:	5e                   	pop    %esi
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ac:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009af:	eb 06                	jmp    8009b7 <strcmp+0x11>
		p++, q++;
  8009b1:	83 c1 01             	add    $0x1,%ecx
  8009b4:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009b7:	0f b6 01             	movzbl (%ecx),%eax
  8009ba:	84 c0                	test   %al,%al
  8009bc:	74 04                	je     8009c2 <strcmp+0x1c>
  8009be:	3a 02                	cmp    (%edx),%al
  8009c0:	74 ef                	je     8009b1 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c2:	0f b6 c0             	movzbl %al,%eax
  8009c5:	0f b6 12             	movzbl (%edx),%edx
  8009c8:	29 d0                	sub    %edx,%eax
}
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	53                   	push   %ebx
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d6:	89 c3                	mov    %eax,%ebx
  8009d8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009db:	eb 06                	jmp    8009e3 <strncmp+0x17>
		n--, p++, q++;
  8009dd:	83 c0 01             	add    $0x1,%eax
  8009e0:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009e3:	39 d8                	cmp    %ebx,%eax
  8009e5:	74 16                	je     8009fd <strncmp+0x31>
  8009e7:	0f b6 08             	movzbl (%eax),%ecx
  8009ea:	84 c9                	test   %cl,%cl
  8009ec:	74 04                	je     8009f2 <strncmp+0x26>
  8009ee:	3a 0a                	cmp    (%edx),%cl
  8009f0:	74 eb                	je     8009dd <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f2:	0f b6 00             	movzbl (%eax),%eax
  8009f5:	0f b6 12             	movzbl (%edx),%edx
  8009f8:	29 d0                	sub    %edx,%eax
}
  8009fa:	5b                   	pop    %ebx
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    
		return 0;
  8009fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800a02:	eb f6                	jmp    8009fa <strncmp+0x2e>

00800a04 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a0e:	0f b6 10             	movzbl (%eax),%edx
  800a11:	84 d2                	test   %dl,%dl
  800a13:	74 09                	je     800a1e <strchr+0x1a>
		if (*s == c)
  800a15:	38 ca                	cmp    %cl,%dl
  800a17:	74 0a                	je     800a23 <strchr+0x1f>
	for (; *s; s++)
  800a19:	83 c0 01             	add    $0x1,%eax
  800a1c:	eb f0                	jmp    800a0e <strchr+0xa>
			return (char *) s;
	return 0;
  800a1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a2f:	eb 03                	jmp    800a34 <strfind+0xf>
  800a31:	83 c0 01             	add    $0x1,%eax
  800a34:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a37:	38 ca                	cmp    %cl,%dl
  800a39:	74 04                	je     800a3f <strfind+0x1a>
  800a3b:	84 d2                	test   %dl,%dl
  800a3d:	75 f2                	jne    800a31 <strfind+0xc>
			break;
	return (char *) s;
}
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	57                   	push   %edi
  800a45:	56                   	push   %esi
  800a46:	53                   	push   %ebx
  800a47:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a4a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a4d:	85 c9                	test   %ecx,%ecx
  800a4f:	74 13                	je     800a64 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a51:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a57:	75 05                	jne    800a5e <memset+0x1d>
  800a59:	f6 c1 03             	test   $0x3,%cl
  800a5c:	74 0d                	je     800a6b <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a61:	fc                   	cld    
  800a62:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a64:	89 f8                	mov    %edi,%eax
  800a66:	5b                   	pop    %ebx
  800a67:	5e                   	pop    %esi
  800a68:	5f                   	pop    %edi
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    
		c &= 0xFF;
  800a6b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a6f:	89 d3                	mov    %edx,%ebx
  800a71:	c1 e3 08             	shl    $0x8,%ebx
  800a74:	89 d0                	mov    %edx,%eax
  800a76:	c1 e0 18             	shl    $0x18,%eax
  800a79:	89 d6                	mov    %edx,%esi
  800a7b:	c1 e6 10             	shl    $0x10,%esi
  800a7e:	09 f0                	or     %esi,%eax
  800a80:	09 c2                	or     %eax,%edx
  800a82:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a84:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a87:	89 d0                	mov    %edx,%eax
  800a89:	fc                   	cld    
  800a8a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a8c:	eb d6                	jmp    800a64 <memset+0x23>

00800a8e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	57                   	push   %edi
  800a92:	56                   	push   %esi
  800a93:	8b 45 08             	mov    0x8(%ebp),%eax
  800a96:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a99:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a9c:	39 c6                	cmp    %eax,%esi
  800a9e:	73 35                	jae    800ad5 <memmove+0x47>
  800aa0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aa3:	39 c2                	cmp    %eax,%edx
  800aa5:	76 2e                	jbe    800ad5 <memmove+0x47>
		s += n;
		d += n;
  800aa7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aaa:	89 d6                	mov    %edx,%esi
  800aac:	09 fe                	or     %edi,%esi
  800aae:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ab4:	74 0c                	je     800ac2 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ab6:	83 ef 01             	sub    $0x1,%edi
  800ab9:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800abc:	fd                   	std    
  800abd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800abf:	fc                   	cld    
  800ac0:	eb 21                	jmp    800ae3 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac2:	f6 c1 03             	test   $0x3,%cl
  800ac5:	75 ef                	jne    800ab6 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ac7:	83 ef 04             	sub    $0x4,%edi
  800aca:	8d 72 fc             	lea    -0x4(%edx),%esi
  800acd:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ad0:	fd                   	std    
  800ad1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad3:	eb ea                	jmp    800abf <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad5:	89 f2                	mov    %esi,%edx
  800ad7:	09 c2                	or     %eax,%edx
  800ad9:	f6 c2 03             	test   $0x3,%dl
  800adc:	74 09                	je     800ae7 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ade:	89 c7                	mov    %eax,%edi
  800ae0:	fc                   	cld    
  800ae1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ae3:	5e                   	pop    %esi
  800ae4:	5f                   	pop    %edi
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae7:	f6 c1 03             	test   $0x3,%cl
  800aea:	75 f2                	jne    800ade <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aec:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800aef:	89 c7                	mov    %eax,%edi
  800af1:	fc                   	cld    
  800af2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af4:	eb ed                	jmp    800ae3 <memmove+0x55>

00800af6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800af9:	ff 75 10             	pushl  0x10(%ebp)
  800afc:	ff 75 0c             	pushl  0xc(%ebp)
  800aff:	ff 75 08             	pushl  0x8(%ebp)
  800b02:	e8 87 ff ff ff       	call   800a8e <memmove>
}
  800b07:	c9                   	leave  
  800b08:	c3                   	ret    

00800b09 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	56                   	push   %esi
  800b0d:	53                   	push   %ebx
  800b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b11:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b14:	89 c6                	mov    %eax,%esi
  800b16:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b19:	39 f0                	cmp    %esi,%eax
  800b1b:	74 1c                	je     800b39 <memcmp+0x30>
		if (*s1 != *s2)
  800b1d:	0f b6 08             	movzbl (%eax),%ecx
  800b20:	0f b6 1a             	movzbl (%edx),%ebx
  800b23:	38 d9                	cmp    %bl,%cl
  800b25:	75 08                	jne    800b2f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b27:	83 c0 01             	add    $0x1,%eax
  800b2a:	83 c2 01             	add    $0x1,%edx
  800b2d:	eb ea                	jmp    800b19 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b2f:	0f b6 c1             	movzbl %cl,%eax
  800b32:	0f b6 db             	movzbl %bl,%ebx
  800b35:	29 d8                	sub    %ebx,%eax
  800b37:	eb 05                	jmp    800b3e <memcmp+0x35>
	}

	return 0;
  800b39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	8b 45 08             	mov    0x8(%ebp),%eax
  800b48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b4b:	89 c2                	mov    %eax,%edx
  800b4d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b50:	39 d0                	cmp    %edx,%eax
  800b52:	73 09                	jae    800b5d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b54:	38 08                	cmp    %cl,(%eax)
  800b56:	74 05                	je     800b5d <memfind+0x1b>
	for (; s < ends; s++)
  800b58:	83 c0 01             	add    $0x1,%eax
  800b5b:	eb f3                	jmp    800b50 <memfind+0xe>
			break;
	return (void *) s;
}
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6b:	eb 03                	jmp    800b70 <strtol+0x11>
		s++;
  800b6d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b70:	0f b6 01             	movzbl (%ecx),%eax
  800b73:	3c 20                	cmp    $0x20,%al
  800b75:	74 f6                	je     800b6d <strtol+0xe>
  800b77:	3c 09                	cmp    $0x9,%al
  800b79:	74 f2                	je     800b6d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b7b:	3c 2b                	cmp    $0x2b,%al
  800b7d:	74 2e                	je     800bad <strtol+0x4e>
	int neg = 0;
  800b7f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b84:	3c 2d                	cmp    $0x2d,%al
  800b86:	74 2f                	je     800bb7 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b88:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b8e:	75 05                	jne    800b95 <strtol+0x36>
  800b90:	80 39 30             	cmpb   $0x30,(%ecx)
  800b93:	74 2c                	je     800bc1 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b95:	85 db                	test   %ebx,%ebx
  800b97:	75 0a                	jne    800ba3 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b99:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b9e:	80 39 30             	cmpb   $0x30,(%ecx)
  800ba1:	74 28                	je     800bcb <strtol+0x6c>
		base = 10;
  800ba3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba8:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bab:	eb 50                	jmp    800bfd <strtol+0x9e>
		s++;
  800bad:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bb0:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb5:	eb d1                	jmp    800b88 <strtol+0x29>
		s++, neg = 1;
  800bb7:	83 c1 01             	add    $0x1,%ecx
  800bba:	bf 01 00 00 00       	mov    $0x1,%edi
  800bbf:	eb c7                	jmp    800b88 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bc5:	74 0e                	je     800bd5 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bc7:	85 db                	test   %ebx,%ebx
  800bc9:	75 d8                	jne    800ba3 <strtol+0x44>
		s++, base = 8;
  800bcb:	83 c1 01             	add    $0x1,%ecx
  800bce:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bd3:	eb ce                	jmp    800ba3 <strtol+0x44>
		s += 2, base = 16;
  800bd5:	83 c1 02             	add    $0x2,%ecx
  800bd8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bdd:	eb c4                	jmp    800ba3 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bdf:	8d 72 9f             	lea    -0x61(%edx),%esi
  800be2:	89 f3                	mov    %esi,%ebx
  800be4:	80 fb 19             	cmp    $0x19,%bl
  800be7:	77 29                	ja     800c12 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800be9:	0f be d2             	movsbl %dl,%edx
  800bec:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bef:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bf2:	7d 30                	jge    800c24 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bf4:	83 c1 01             	add    $0x1,%ecx
  800bf7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bfb:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bfd:	0f b6 11             	movzbl (%ecx),%edx
  800c00:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c03:	89 f3                	mov    %esi,%ebx
  800c05:	80 fb 09             	cmp    $0x9,%bl
  800c08:	77 d5                	ja     800bdf <strtol+0x80>
			dig = *s - '0';
  800c0a:	0f be d2             	movsbl %dl,%edx
  800c0d:	83 ea 30             	sub    $0x30,%edx
  800c10:	eb dd                	jmp    800bef <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c12:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c15:	89 f3                	mov    %esi,%ebx
  800c17:	80 fb 19             	cmp    $0x19,%bl
  800c1a:	77 08                	ja     800c24 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c1c:	0f be d2             	movsbl %dl,%edx
  800c1f:	83 ea 37             	sub    $0x37,%edx
  800c22:	eb cb                	jmp    800bef <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c24:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c28:	74 05                	je     800c2f <strtol+0xd0>
		*endptr = (char *) s;
  800c2a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c2d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c2f:	89 c2                	mov    %eax,%edx
  800c31:	f7 da                	neg    %edx
  800c33:	85 ff                	test   %edi,%edi
  800c35:	0f 45 c2             	cmovne %edx,%eax
}
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    
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
