// See COPYRIGHT for copyright information.

#ifndef JOS_INC_FS_H
#define JOS_INC_FS_H

#include <inc/types.h>
#include <inc/mmu.h>

// 块大小
#define BLKSIZE		PGSIZE
#define BLKBITSIZE	(BLKSIZE * 8)

// 文件名的最大长度
// x4
#define MAXNAMELEN	128

// 路径的最大长度
#define MAXPATHLEN	1024

// 直接块
#define NDIRECT		10
// 间接块
#define NINDIRECT	(BLKSIZE / 4)

#define MAXFILESIZE	((NDIRECT + NINDIRECT) * BLKSIZE)
//既可以表示普通文件也可以表示目录
struct File {
	char f_name[MAXNAMELEN];	// 文件名
	off_t f_size;			// 文件大小
	uint32_t f_type;		// 文件类型

	// 块  允许文件最多1034块
	uint32_t f_direct[NDIRECT];	// 直接块 10*4096b=40kb
	uint32_t f_indirect;		// 间接块 4096/4 = 1024个块号

	// Pad out to 256 bytes; must do arithmetic in case we're compiling
	// fsformat on a 64-bit machine.
	uint8_t f_pad[256 - MAXNAMELEN - 8 - 4*NDIRECT - 4];
} __attribute__((packed));	// required only on some 64-bit machines

// An inode block contains exactly BLKFILES 'struct File's
#define BLKFILES	(BLKSIZE / sizeof(struct File))

// 文件类型
#define FTYPE_REG	0	// 普通文件
#define FTYPE_DIR	1	// 目录


// super-block 

#define FS_MAGIC	0x4A0530AE	// related vaguely to 'J\0S!'

struct Super {
	uint32_t s_magic;		// Magic number: FS_MAGIC
	uint32_t s_nblocks;		// 块数目
	struct File s_root;		// 保存文件系统根目录的元数据
};

// 客户端对文件系统的请求的定义
enum {
	FSREQ_OPEN = 1,
	FSREQ_SET_SIZE,
	// Read在请求页面上返回Fsret_read
	FSREQ_READ,
	FSREQ_WRITE,
	// Stat在请求页面上返回Fsret_stat
	FSREQ_STAT,
	FSREQ_FLUSH,
	FSREQ_REMOVE,
	FSREQ_SYNC
};

// 文件系统ipc设计
union Fsipc {
	struct Fsreq_open {
		char req_path[MAXPATHLEN];
		int req_omode;
	} open;
	struct Fsreq_set_size {
		int req_fileid;
		off_t req_size;
	} set_size;
	struct Fsreq_read {
		int req_fileid;
		size_t req_n;
	} read;
	struct Fsret_read {
		char ret_buf[PGSIZE];
	} readRet;
	struct Fsreq_write {
		int req_fileid;
		size_t req_n;
		char req_buf[PGSIZE - (sizeof(int) + sizeof(size_t))];
	} write;
	struct Fsreq_stat {
		int req_fileid;
	} stat;
	struct Fsret_stat {
		char ret_name[MAXNAMELEN];
		off_t ret_size;
		int ret_isdir;
	} statRet;
	struct Fsreq_flush {
		int req_fileid;
	} flush;
	struct Fsreq_remove {
		char req_path[MAXPATHLEN];
	} remove;

	// Ensure Fsipc is one page
	char _pad[PGSIZE];
};

#endif /* !JOS_INC_FS_H */
