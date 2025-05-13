#include "irq_ctrl.h"
#include <stdio.h>

typedef void (*function) ();
function jump_table[IRQ_CTRL_IRQ_MAX];

void irq_ctrl_top_handler() {
    uint32_t irq_no = irq_ctrl_get_irq_no();
    irq_ctrl_set_test_data(0x00);
    if (irq_no >= IRQ_CTRL_IRQ_MAX) {
        printf("irq_no is out of bounds\n");
        return;
    }
    jump_table[irq_no]();
}

 void* irq_ctrl_get(uint32_t index) {
    if (index >= IRQ_CTRL_IRQ_MAX) {
        printf("Error in irq_ctrl_get: Requested index %d is out of bounds\n", index);
        return NULL;
    }
    return (void*)jump_table[index];
 }

 void irq_ctrl_set(uint32_t index, void* new_entry) {
    if (index >= IRQ_CTRL_IRQ_MAX) {
        printf("Error in irq_ctrl_set: Requested index %d is out of bounds\n", index);
        return;
    }
    jump_table[index] = (function)new_entry;
 }

 static void dummy_function() {
    uint32_t irq_no = irq_ctrl_get_irq_no();
    printf("Interrupt %d\n", irq_no);
 }

 void irq_init_jump_table() {
    for (uint32_t i = 0; i < IRQ_CTRL_IRQ_MAX; i++) {
        jump_table[i] = &dummy_function;
    }
 }
