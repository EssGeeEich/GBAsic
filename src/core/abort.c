#include <gba_systemcalls.h>

void abort(void) {
    Halt();
    for(;;);
}