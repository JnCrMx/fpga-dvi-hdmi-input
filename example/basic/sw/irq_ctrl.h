#ifndef IRQ_CTRL_H
#define IRQ_CTRL_H

#include "registers.h"

#define IRQ_CTRL_IRQ_MAX 32

static inline void irq_ctrl_enable_interrupts() {
    REG32(IRQ_CTRL_ALL_EN(0)) = 0x1;
}
static inline void irq_ctrl_disable_interrupts() {
    REG32(IRQ_CTRL_ALL_EN(0)) = 0x0;
}
static inline void irq_ctrl_set_all_interrupts(uint8_t enable) {
    REG32(IRQ_CTRL_ALL_EN(0)) = enable & IRQ_CTRL_ALL_EN_MASK;
}

static inline void irq_ctrl_set_mask(uint32_t mask) {
    REG32(IRQ_CTRL_MASK(0)) = mask & IRQ_CTRL_MASK_MASK;
}
static inline uint32_t irq_ctrl_get_mask() {
    return REG32(IRQ_CTRL_MASK(0));
}
static inline void irq_ctrl_allow_interrupt(uint32_t num) {
    REG32(IRQ_CTRL_MASK_SET(0)) = num;
}
static inline void irq_ctrl_suspend_interrupt(uint32_t num) {
    REG32(IRQ_CTRL_MASK_CLR(0)) = num;
}

static inline uint32_t irq_ctrl_get_status() {
    return REG32(IRQ_CTRL_STATUS(0));
}
static inline uint32_t irq_ctrl_get_irq_no() {
    return REG32(IRQ_CTRL_IRQ_NO(0));
}

static inline void irq_ctrl_enable_test() {
    REG32(IRQ_CTRL_TEST(0)) = 0x1;
}
static inline void irq_ctrl_disable_test() {
    REG32(IRQ_CTRL_TEST(0)) = 0x1;
}
static inline uint8_t irq_ctrl_test_enabled() {
    return REG32(IRQ_CTRL_TEST(0));
}

static inline void irq_ctrl_set_test_data(uint32_t mask) {
    REG32(IRQ_CTRL_TEST_IRQ(0)) = mask;
}

void irq_ctrl_top_handler();

void* irq_ctrl_get(uint32_t);

void irq_ctrl_set(uint32_t, void*);

void irq_init_jump_table();

#endif
