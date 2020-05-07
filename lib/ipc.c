// User-level IPC library routines

#include <inc/lib.h>

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
	int r;
	if(pg!=NULL)
		r = sys_ipc_recv(pg);//映射页面
	else
		r = sys_ipc_recv((void*)UTOP);//传递数据
	if(from_env_store !=NULL){
		*from_env_store = thisenv->env_ipc_from;
	}
	if(perm_store !=NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	if(r){
		*from_env_store = 0;
		*perm_store = 0;
		return r;
	}
	
	return thisenv->env_ipc_value;
}

void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	int r;
	while(1){
		if(pg){
			r = sys_ipc_try_send(to_env, val, pg, perm);	
		}else{
			r = sys_ipc_try_send(to_env, val, (void*)UTOP, perm);
		}
		if(r){
			if(r!=-E_IPC_NOT_RECV)
				panic("ipc send fault");
			else
				sys_yield();
		}else
			return;
	}
}

// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
