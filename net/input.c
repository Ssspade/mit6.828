#include "ns.h"
#include "inc/lib.h"
#include "kern/e1000.h"
extern union Nsipc nsipcbuf;
//延时,第二种方法，挂起调用环境，但是我又不知道怎么才能在驱动程序中接受中断，所以为了避免注释里说的情况(在network server读取前接收另一个包，导致内容被覆盖)，

//实现从网卡读取数据包并发送给core network server进程
void
input(envid_t ns_envid)
{
	binaryname = "ns_input";

	// LAB 6: Your code here:
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
	char my_buf[2048];
        size_t length;
        while(1){
                while(sys_pkt_recv(my_buf, &length)<0)
                        sys_yield();
                nsipcbuf.pkt.jp_len=length;
                memcpy(nsipcbuf.pkt.jp_data, my_buf, length);
                ipc_send(ns_envid, NSREQ_INPUT, &nsipcbuf, PTE_U | PTE_P);
                for(int i=0; i<50000; i++)
                        if(i%1000==0)
                                sys_yield();
        }

}


