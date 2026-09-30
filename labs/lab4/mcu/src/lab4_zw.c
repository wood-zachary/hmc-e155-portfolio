// lab4_zw.c
// Digital Audio, E155 Lab 4

#include "STM32L432KC_FLASH.h"
#include "STM32L432KC_GPIO.h"
#include "STM32L432KC_RCC.h"
#include "STM32L432KC_TIMER.h"

#define SPEAKER_PIN 3

#define RCC_AHB2ENR_GPIOBEN (1U << 1)
#define RCC_APB1ENR1_TIM6EN (1U << 4)
#define RCC_APB1ENR1_TIM7EN (1U << 5)

#define TIMER_CLK_HZ 80000000UL
#define TICK_HZ      1000000UL
#define TIMER_PSC    (TIMER_CLK_HZ / TICK_HZ - 1)
#define TICKS_PER_MS (TICK_HZ / 1000)
#define MAX_TICKS    65536UL

// Fur Elise
// Pitch in Hz, duration in ms
const int notes[][2] = {
{659,	125},
{623,	125},
{659,	125},
{623,	125},
{659,	125},
{494,	125},
{587,	125},
{523,	125},
{440,	250},
{  0,	125},
{262,	125},
{330,	125},
{440,	125},
{494,	250},
{  0,	125},
{330,	125},
{416,	125},
{494,	125},
{523,	250},
{  0,	125},
{330,	125},
{659,	125},
{623,	125},
{659,	125},
{623,	125},
{659,	125},
{494,	125},
{587,	125},
{523,	125},
{440,	250},
{  0,	125},
{262,	125},
{330,	125},
{440,	125},
{494,	250},
{  0,	125},
{330,	125},
{523,	125},
{494,	125},
{440,	250},
{  0,	125},
{494,	125},
{523,	125},
{587,	125},
{659,	375},
{392,	125},
{699,	125},
{659,	125},
{587,	375},
{349,	125},
{659,	125},
{587,	125},
{523,	375},
{330,	125},
{587,	125},
{523,	125},
{494,	250},
{  0,	125},
{330,	125},
{659,	125},
{  0,	250},
{659,	125},
{1319,	125},
{  0,	250},
{623,	125},
{659,	125},
{  0,	250},
{623,	125},
{659,	125},
{623,	125},
{659,	125},
{623,	125},
{659,	125},
{494,	125},
{587,	125},
{523,	125},
{440,	250},
{  0,	125},
{262,	125},
{330,	125},
{440,	125},
{494,	250},
{  0,	125},
{330,	125},
{416,	125},
{494,	125},
{523,	250},
{  0,	125},
{330,	125},
{659,	125},
{623,	125},
{659,	125},
{623,	125},
{659,	125},
{494,	125},
{587,	125},
{523,	125},
{440,	250},
{  0,	125},
{262,	125},
{330,	125},
{440,	125},
{494,	250},
{  0,	125},
{330,	125},
{523,	125},
{494,	125},
{440,	500},
{  0,	0}};

// Returns 0 for a rest or for a pitch outside the timer's range
static uint32_t halfPeriodTicks(int freq) {
    if (freq <= 0) {
        return 0;
    }

    uint32_t ticks = (TICK_HZ + (uint32_t) freq) / (2 * (uint32_t) freq);

    return (ticks <= MAX_TICKS) ? ticks : 0;
}

static void playNote(int freq, int ms) {
    uint32_t halfPeriod = halfPeriodTicks(freq);
    int elapsed = 0;

    if (halfPeriod != 0) {
        startTimer(TIM6, halfPeriod);
    }
    startTimer(TIM7, TICKS_PER_MS);

    while (elapsed < ms) {
        if (checkUpdateFlag(TIM7)) {
            clearUpdateFlag(TIM7);
            elapsed++;
        }
        if (halfPeriod != 0 && checkUpdateFlag(TIM6)) {
            clearUpdateFlag(TIM6);
            togglePin(SPEAKER_PIN);
        }
    }

    stopTimer(TIM6);
    stopTimer(TIM7);
    digitalWrite(SPEAKER_PIN, GPIO_LOW);
}

static void playSong(const int song[][2]) {
    for (int i = 0; song[i][1] != 0; i++) {
        playNote(song[i][0], song[i][1]);
    }
}

int main(void) {
    configureFlash();
    configureClock();

    RCC->AHB2ENR |= RCC_AHB2ENR_GPIOBEN;
    RCC->APB1ENR1 |= RCC_APB1ENR1_TIM6EN | RCC_APB1ENR1_TIM7EN;

    pinMode(SPEAKER_PIN, GPIO_OUTPUT);
    digitalWrite(SPEAKER_PIN, GPIO_LOW);

    initTimer(TIM6, TIMER_PSC);
    initTimer(TIM7, TIMER_PSC);

    playSong(notes);

    while (1) {
    }
}