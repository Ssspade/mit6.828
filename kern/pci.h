#ifndef JOS_KERN_PCI_H
#define JOS_KERN_PCI_H

#include <inc/types.h>

// PCI subsystem interface
enum { pci_res_bus, pci_res_mem, pci_res_io, pci_res_max };

struct pci_bus;

struct pci_func {
    struct pci_bus *bus;	// Primary bus for bridges

    uint32_t dev;
    uint32_t func;

    uint32_t dev_id;
    uint32_t dev_class;

    uint32_t reg_base[6];//内存映射I/O的基地址
    uint32_t reg_size[6];//对应的reg_base基值的字节大小或I/O端口数量
    uint8_t irq_line;//包含分配给设备用于中断的IRQ lines
};

struct pci_bus {
    struct pci_func *parent_bridge;
    uint32_t busno;
};

int  pci_init(void);
void pci_func_enable(struct pci_func *f);

#endif
