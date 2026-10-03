// STM32L432KC_TIMER.h
// Header for TIMER

#ifndef STM32L4_TIMER_H
#define STM32L4_TIMER_H

#include <stdint.h> // Include stdint header

///////////////////////////////////////////////////////////////////////////////
// Definitions
///////////////////////////////////////////////////////////////////////////////

// Base addresses for TIM6 and TIM7 from RM0394 Section 2.2.2
#define TIM6_BASE (0x40001000UL)
#define TIM7_BASE (0x40001400UL)

// Register bits from RM0394 Section 29.4.9
#define TIM_CR1_CEN (1U << 0)
#define TIM_SR_UIF  (1U << 0)
#define TIM_EGR_UG  (1U << 0)

///////////////////////////////////////////////////////////////////////////////
// Bitfield struct for timers
///////////////////////////////////////////////////////////////////////////////

// TIM6/TIM7 register struct from RM0394 Section 29.4.9
typedef struct {
    volatile uint32_t CR1;          // TIMx Offset 0x00
    volatile uint32_t CR2;          // TIMx Offset 0x04
    uint32_t          RESERVED0;    // TIMx Offset 0x08
    volatile uint32_t DIER;         // TIMx Offset 0x0C
    volatile uint32_t SR;           // TIMx Offset 0x10
    volatile uint32_t EGR;          // TIMx Offset 0x14
    uint32_t          RESERVED1[3]; // TIMx Offset 0x18-0x20
    volatile uint32_t CNT;          // TIMx Offset 0x24
    volatile uint32_t PSC;          // TIMx Offset 0x28
    volatile uint32_t ARR;          // TIMx Offset 0x2C
} TIM_TypeDef;

// Pointers to timer-sized chunks of memory for each peripheral
#define TIM6 ((TIM_TypeDef *) TIM6_BASE)
#define TIM7 ((TIM_TypeDef *) TIM7_BASE)

///////////////////////////////////////////////////////////////////////////////
// Function declarations
///////////////////////////////////////////////////////////////////////////////

void initTimer(TIM_TypeDef *TIMx, uint16_t psc);

void startTimer(TIM_TypeDef *TIMx, uint32_t ticks);

void stopTimer(TIM_TypeDef *TIMx);

int checkUpdateFlag(TIM_TypeDef *TIMx);

void clearUpdateFlag(TIM_TypeDef *TIMx);

#endif
