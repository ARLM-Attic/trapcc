display bx_cpu.gen_reg[4].dword.erx
display bx_mem.blocks[0][8]
display bx_mem.blocks[0][0x1008]
display bx_mem.blocks[0][0x2008]
display /x bx_cpu.tr.selector.value
break BX_CPU_C::task_switch

