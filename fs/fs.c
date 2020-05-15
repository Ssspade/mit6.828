#include <inc/string.h>
#include <inc/partition.h>

#include "fs.h"

// --------------------------------------------------------------
// Super block
// --------------------------------------------------------------

// 检查superblock
void
check_super(void)
{
	if (super->s_magic != FS_MAGIC)
		panic("bad file system magic number");

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
		panic("file system is too large");

	cprintf("superblock is good\n");
}

// --------------------------------------------------------------
// 空闲的块位图
// --------------------------------------------------------------

// 检查块位图是否指示块“blockno”空闲
// 返回1为空闲
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}

//在位图中标记空闲块
void
free_block(uint32_t blockno)
{
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
		panic("attempt to free zero block");
	bitmap[blockno/32] |= 1<<(blockno%32);
}

// 分配一个磁盘块，返回磁盘块号，并标记位图
int
alloc_block(void)
{
	uint32_t blockno;
	//是2还是3。。。。。。。。。。
	for(blockno=2; blockno<super->s_nblocks; blockno++){
		if(block_is_free(blockno)==1){
			bitmap[blockno/32] &= ~(1<<(blockno%32)); //将该空闲块设为used，0=used
			flush_block(diskaddr(blockno));	//将bitmap对应块刷新回磁盘
			return blockno;
		}
	}
	return -E_NO_DISK;
}

// // 验证文件系统位图。
//
void
check_bitmap(void)
{
	uint32_t i;

	// 确保所有位图块都标记为使用
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
		assert(!block_is_free(2+i));

	// 确保保留块和根块已标记为使用中。
	assert(!block_is_free(0));
	assert(!block_is_free(1));

	cprintf("bitmap is good\n");
}

// --------------------------------------------------------------
// File system structures
// --------------------------------------------------------------



// 初始化文件系统
void
fs_init(void)
{
	static_assert(sizeof(struct File) == 256);

	// 使用第二个IDE磁盘（编号1）（如果有）
	if (ide_probe_disk1())
		ide_set_disk(1);
	else
		ide_set_disk(0);
	bc_init();

	// Set "super" to point to the super block.
	super = diskaddr(1);
	check_super();

	// 将“位图”设置为第一个位图块的开头。
	bitmap = diskaddr(2);
	check_bitmap();
	
}

// // 文件结构f的第filebno个块指向的磁盘块号放入ppdiskbno中
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{

    if (filebno > NDIRECT + NINDIRECT)//文件所在的磁盘块不能超过总共的块
		return -E_INVAL;
	if (filebno < NDIRECT) {
		*ppdiskbno = &f->f_direct[filebno];//直接为第n个块
		return 0;
	}
	if (f->f_indirect == 0 && !alloc)
		return -E_NOT_FOUND;

	if (f->f_indirect == 0) {//没有间接块
		int blockno = alloc_block();
		if (blockno < 0) return blockno;
		f->f_indirect = blockno;//	间接磁盘块
		memset(diskaddr(f->f_indirect), 0, BLKSIZE);
	}

	uint32_t *addr = (uint32_t *)diskaddr(f->f_indirect);
	*ppdiskbno = &addr[filebno - NDIRECT];//在间接块中对应的磁盘号
	return 0;
}

// // 从磁盘读取一个块，并映射到对应的服务器进程空间
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
    // LAB 5: Your code here.
	uint32_t *pdiskbno;
	int r;

    if (filebno > NDIRECT + NINDIRECT)
		return -E_INVAL;
	if ((r = file_block_walk(f, filebno, &pdiskbno, true)) < 0)
		return r; // -E_NO_DISK
	//ppdiskbno是f的第filebno块的块号所在的槽的地址
	//blk要的是这个块映射到内存里的地址
	if (*pdiskbno == 0) {
		if ((r = alloc_block()) < 0)
			return r; // -E_NO_DISK
		*pdiskbno = r;
	}
	*blk = (char *)diskaddr(*pdiskbno);
	return 0;
}

// 在dir中找到为name的文件，并放入*file中
static int
dir_lookup(struct File *dir, const char *name, struct File **file)
{
	int r;
	uint32_t i, j, nblock;
	char *blk;
	struct File *f;

	// 搜索目录名
	// 目录文件的大小始终是文件系统块大小的倍数是不变的。
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
				*file = &f[j];
				return 0;
			}
	}
	return -E_NOT_FOUND;
}

//// 在指定目录dir下分配一个file，用于添加文件的操作
static int
dir_alloc_file(struct File *dir, struct File **file)
{
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
	if ((r = file_get_block(dir, i, &blk)) < 0)
		return r;
	f = (struct File*) blk;
	*file = &f[0];
	return 0;
}

// 跳过斜线。
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
	return p;
}

// // 根据路径遍历文件系统，有要找的文件*pf，将其所在的目录赋值给**pdir，没有则把剩下的路径复制在lastelem中
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
	const char *p;
	char name[MAXNAMELEN];
	struct File *dir, *f;
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
				if (pdir)
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
		}
	}

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}

// --------------------------------------------------------------
// 文件操作
// --------------------------------------------------------------

// 建立一个path文件
int
file_create(const char *path, struct File **pf)
{
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
	*pf = f;
	file_flush(dir);
	return 0;
}

// // 打开一个文件
int
file_open(const char *path, struct File **pf)
{
	return walk_path(path, 0, pf, 0);
}

// 从查找位置偏移量开始，将f的计数字节读取到buf中。
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
}


// Write count bytes from buf into f, starting at seek position
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
	int r, bn;
	off_t pos;
	char *blk;

	// 写入的内容超过文件的大小就扩展
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
}

// 释放一个文件中的第filebno个磁盘块（file_truncate_blocks）
static int
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
		return r;
	if (*ptr) {
		free_block(*ptr);
		*ptr = 0;
	}
	return 0;
}

// 将文件设置为缩小后新大小，清空那些被释放的物理块
static void
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
		free_block(f->f_indirect);
		f->f_indirect = 0;
	}
}

// 设置文件f的大小
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
	flush_block(f);
	return 0;
}

// 将文件的内容同步到磁盘上
void
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
	if (f->f_indirect)
		flush_block(diskaddr(f->f_indirect));
}


// 同步磁盘上所有数据
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
		flush_block(diskaddr(i));
}

