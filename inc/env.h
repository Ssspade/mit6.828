/* See COPYRIGHT for copyright information. */

#ifndef JOS_INC_ENV_H
#define JOS_INC_ENV_H

#include <inc/types.h>
#include <inc/trap.h>
#include <inc/memlayout.h>

typedef int32_t envid_t;

// An environment ID 'envid_t' has three parts:
//进程ID由三部分组成
// +1+---------------21-----------------+--------10--------+
// |0|          Uniqueifier             |   Environment    |
// | |                                  |      Index       |
// +------------------------------------+------------------+
//                                       \--- ENVX(eid) --/
//ENVX(eid） = envs[]
// The environment index ENVX(eid) equals the environment's index in the
// 'envs[]' array.  The uniqueifier distinguishes environments that were
// created at different times, but share the same environment index.
//Uniqueifier区分在不同时间创建但共享相同环境索引的环境。
// All real environments are greater than 0 (so the sign bit is zero).
//所有实际环境都大于0（因此符号位为零）。
// envid_ts less than 0 signify errors.  The envid_t == 0 is special, and
// stands for the current environment.

#define LOG2NENV		10
#define NENV			(1 << LOG2NENV)
#define ENVX(envid)		((envid) & (NENV - 1))

// Values of env_status in struct Env
enum {
	ENV_FREE = 0,
	ENV_DYING,	//死亡进程
	ENV_RUNNABLE,	//可允许
	ENV_RUNNING,	//运行中
	ENV_NOT_RUNNABLE	//不可运行
};

// Special environment types
enum EnvType {
	ENV_TYPE_USER = 0,
};

struct Env {
	struct Trapframe env_tf;	// Saved registers保存寄存器
	struct Env *env_link;		// Next free Env下一个可允许的进程
	envid_t env_id;			// Unique environment identifier
	envid_t env_parent_id;		// env_id of this env's parent父进程ID
	enum EnvType env_type;		// Indicates special system environments表示特殊的系统环境
	unsigned env_status;		// Status of the environment
	uint32_t env_runs;		// Number of times environment has run

	// Address space
	pde_t *env_pgdir;		// Kernel virtual address of page dir页面目录的内核虚拟地址
};

#endif // !JOS_INC_ENV_H
