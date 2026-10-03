// lab4_zw.c
// Digital Audio, E155 Lab 4

#include "../lib/STM32L432KC_FLASH.h"
#include "../lib/STM32L432KC_GPIO.h"
#include "../lib/STM32L432KC_RCC.h"
#include "../lib/STM32L432KC_TIMER.h"

#define SPEAKER_PIN 3

#define RCC_AHB2ENR_GPIOBEN (1U << 1)
#define RCC_APB1ENR1_TIM6EN (1U << 4)
#define RCC_APB1ENR1_TIM7EN (1U << 5)

#define TIMER_CLK_HZ 80000000UL
#define TICK_HZ      1000000UL
#define TIMER_PSC    (TIMER_CLK_HZ / TICK_HZ - 1)
#define TICKS_PER_MS (TICK_HZ / 1000)
#define MAX_TICKS    65536UL

#define SONG_GAP_MS 1000

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

// Tarleton's Jig, John Dowland
// Melody (up-stemmed notes) derived from https://renaissance-ukukele.blogspot.com/2020/10/dowland-tarletons-jig-or-tarletons-willy.html
// Pitch in Hz, duration in ms (75 ms is a sixteenth note)
// 25 ms rest between repeated notes (previous note shortened to keep 900ms bars)
const int tarletonsJig[][2] = {
// Pickup: A4
{440, 150},

// A section
{523, 300}, {440, 150}, {587, 300}, {440, 150},  // (Am Dm): C5 A4 D5 A4
{523, 225}, {587, 75}, {494, 150}, {440, 225}, {392, 75}, {349, 150},  // (Am E F Dm): C5 D5 B4 A4 G4 F4
{330, 300}, {587, 150}, {659, 300}, {440, 150},  // (C D Am): E4 D5 E5 A4
{523, 225}, {587, 75}, {494, 150}, {440, 275}, {0, 25}, {440, 150},  // (Am E A): C5 D5 B4 A4 A4

// A section repeat
{523, 300}, {440, 150}, {587, 300}, {440, 150},  // (Am Dm): C5 A4 D5 A4
{523, 225}, {587, 75}, {494, 150}, {440, 225}, {392, 75}, {349, 150},  // (Am E F Dm): C5 D5 B4 A4 G4 F4
{330, 300}, {587, 150}, {659, 300}, {440, 150},  // (C D Am): E4 D5 E5 A4
{523, 225}, {587, 75}, {494, 150}, {440, 275}, {0, 25}, {440, 150},  // (Am E A): C5 D5 B4 A4 A4

// B section, first ending
{523, 225}, {494, 75}, {440, 150}, {587, 300}, {784, 150},  // (Am G): C5 B4 A4 D5 G5
{659, 425}, {0, 25}, {659, 300}, {587, 150},  // (C G): E5 E5 D5
{659, 300}, {587, 150}, {659, 300}, {587, 150},  // (C G C G): E5 D5 E5 D5
{659, 450}, {523, 300}, {587, 150},  // (C Am G): E5 C5 D5
{659, 300}, {587, 150}, {659, 450},  // (C G E): E5 D5 E5
{440, 125}, {0, 25}, {440, 150}, {554, 150}, {440, 125}, {0, 25}, {440, 300},  // (A): A4 A4 C#5 A4 A4
{392, 225}, {440, 75}, {494, 75}, {523, 75}, {587, 150}, {494, 150}, {659, 150},  // (G E): G4 A4 B4 C5 D5 B4 E5
{554, 225}, {440, 75}, {494, 150}, {440, 275}, {0, 25}, {440, 150},  // (A E A): C#5 A4 B4 A4 A4

// B section, second ending
{523, 225}, {494, 75}, {440, 150}, {587, 300}, {784, 150},  // (Am G): C5 B4 A4 D5 G5
{659, 425}, {0, 25}, {659, 300}, {587, 150},  // (C G): E5 E5 D5
{659, 300}, {587, 150}, {659, 300}, {587, 150},  // (C G C G): E5 D5 E5 D5
{659, 450}, {523, 300}, {587, 150},  // (C Am G): E5 C5 D5
{659, 300}, {587, 150}, {659, 450},  // (C G E): E5 D5 E5
{440, 125}, {0, 25}, {440, 150}, {554, 150}, {440, 125}, {0, 25}, {440, 300},  // (A): A4 A4 C#5 A4 A4
{392, 225}, {440, 75}, {494, 75}, {523, 75}, {587, 150}, {494, 150}, {659, 150},  // (G E): G4 A4 B4 C5 D5 B4 E5
{554, 225}, {440, 75}, {494, 150}, {440, 450},  // (E A): C#5 A4 B4 A4

{0, 0}};

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
    playNote(0, SONG_GAP_MS);
    playSong(tarletonsJig);

    while (1) {
    }
}