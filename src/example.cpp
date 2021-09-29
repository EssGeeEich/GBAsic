#include <stdint.h>
#include <gba_systemcalls.h>
#include <gba_interrupt.h>
#include <gba_video.h>
#include "binary_file.h"

uint16_t *fb = reinterpret_cast<uint16_t*>(0x6000000);
const int xsz = 240;
const int ysz = 160;

int main() {
	irqInit();
	irqEnable(IRQ_VBLANK);

	
	REG_DISPCNT = MODE_3 | BG2_ENABLE;
	REG_DISPCNT &= ~BACKBUFFER;

	for(int x = 0; x < xsz; ++x) {
		for(int y = 0; y < ysz; ++y) {
			MODE3_FB[y][x] = 0;
		}
	}

	int x = 0;
	int y = 0;

	const int xchk = 32;
	const int ychk = 8;

	for(int f = 0;;++f) {
		f %= binary_file_size;

		while(binary_file[f] == '\n'
			|| binary_file[f] == '\r')
		{
			++f;
			f %= binary_file_size;
		}
		
		uint16_t col = static_cast<uint16_t>(binary_file[f]);
		col = col | (col << 8);

		if((x+xchk) >= xsz) {
			x = 0;
			y += ychk;
		}

		if((y+ychk) >= ysz) {
			y = 0;
		}
		
		for(int xoff = 0; xoff < xchk; ++xoff) {
			for(int yoff = 0; yoff < ychk; ++yoff) {
				MODE3_FB[y+yoff][x+xoff] = col;
			}
		}
		x += xchk;

		// ~20 FPS optimal case
		for(int i = 0; i < 3; ++i)
			VBlankIntrWait();
	}
	return 0;
}
