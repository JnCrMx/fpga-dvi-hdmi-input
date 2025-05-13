#ifndef REGACCESS_H
#define REGACCESS_H

#include <stdint.h>

#define REG8(addr) *((volatile uint8_t *)(addr))
#define REG16(addr) *((volatile uint16_t *)(addr))
#define REG32(addr) *((volatile uint32_t *)(addr))

inline void irq_enable(int mask) {
	asm volatile ("csrs mie, %0":: "r" (mask));
}

inline void irq_disable(int mask) {
	asm volatile ("csrc mie, %0":: "r" (mask));
}

#endif // REGACCESS_H
