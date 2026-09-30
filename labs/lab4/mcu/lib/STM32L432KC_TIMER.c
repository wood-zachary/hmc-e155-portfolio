// STM32L432KC_TIMER.c
// Source code for TIMER functions

#include "STM32L432KC_TIMER.h"

// Loads the new PSC and resets CNT; the forced update also sets UIF
static void forceUpdate(TIM_TypeDef *TIMx) {
    TIMx->EGR = TIM_EGR_UG;
    clearUpdateFlag(TIMx);
}

void initTimer(TIM_TypeDef *TIMx, uint16_t psc) {
    TIMx->CR1 &= ~TIM_CR1_CEN;
    TIMx->PSC = psc;
    forceUpdate(TIMx);
}

void startTimer(TIM_TypeDef *TIMx, uint32_t ticks) {
    TIMx->CR1 &= ~TIM_CR1_CEN;
    TIMx->ARR = ticks - 1;
    forceUpdate(TIMx);
    TIMx->CR1 |= TIM_CR1_CEN;
}

void stopTimer(TIM_TypeDef *TIMx) {
    TIMx->CR1 &= ~TIM_CR1_CEN;
}

int checkUpdateFlag(TIM_TypeDef *TIMx) {
    return (TIMx->SR & TIM_SR_UIF) != 0;
}

void clearUpdateFlag(TIM_TypeDef *TIMx) {
    TIMx->SR = ~TIM_SR_UIF;
}
