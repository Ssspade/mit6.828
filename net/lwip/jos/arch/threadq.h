#ifndef JOS_INC_THREADQ_H
#define JOS_INC_THREADQ_H

#include <arch/thread.h>
#include <arch/setjmp.h>

#define THREAD_NUM_ONHALT 4
enum { name_size = 32 };
enum { stack_size = PGSIZE };

struct thread_context;

struct thread_queue//线程队列
{
    struct thread_context *tq_first;
    struct thread_context *tq_last;
};

struct thread_context {		//线程
    thread_id_t		tc_tid;		//线程id
    void		*tc_stack_bottom;	//线程栈
    char 		tc_name[name_size];	//线程名
    void		(*tc_entry)(uint32_t);	//线程指令地址
    uint32_t		tc_arg;			//参数
    struct jos_jmp_buf	tc_jb;			//cpu快照
    volatile uint32_t	*tc_wait_addr;
    volatile char	tc_wakeup;
    void		(*tc_onhalt[THREAD_NUM_ONHALT])(thread_id_t);
    int			tc_nonhalt;
    struct thread_context *tc_queue_link;
};

static inline void 
threadq_init(struct thread_queue *tq)
{
    tq->tq_first = 0;
    tq->tq_last = 0;
}

static inline void
threadq_push(struct thread_queue *tq, struct thread_context *tc)
{
    tc->tc_queue_link = 0;
    if (!tq->tq_first) {
	tq->tq_first = tc;
	tq->tq_last = tc;
    } else {
	tq->tq_last->tc_queue_link = tc;
	tq->tq_last = tc;
    }
}

static inline struct thread_context *
threadq_pop(struct thread_queue *tq)
{
    if (!tq->tq_first)
	return 0;

    struct thread_context *tc = tq->tq_first;
    tq->tq_first = tc->tc_queue_link;
    tc->tc_queue_link = 0;
    return tc;
}

#endif