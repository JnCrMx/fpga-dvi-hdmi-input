#ifndef BASE_H
#define BASE_H

#define IRQ_TIMER 7
#define IRQ_EXTERNAL 11

#define DDR3_BASE_ADDR 0x80000000
#define DDR3_SIZE      0x20000000

#include "regaccess.h"

#include "reggen/irq_ctrl.h"
#define IRQ_CTRL0_BASE_ADDR 0x10000000

#include "reggen/dvi_in.h"
#define DVI_IN0_BASE_ADDR 0x10300000
#define DVI_IN0_EDID_ADDR 0x10400000
#define DVI_IN0_FB_ADDR   0x20000000

#endif // BASE_H
