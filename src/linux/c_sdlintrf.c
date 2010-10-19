#include <stdio.h>
#include <string.h>

#include "../asm_call.h"
#include "../c_intrf.h"
#include "../c_vcache.h"
#include "../cfg.h"
#include "../cpu/dspproc.h"
#include "../cpu/execute.h"
#include "../intrf.h"
#include "../link.h"
#include "../macros.h"
#include "../ui.h"
#include "../vcache.h"
#include "../video/c_2xsaiw.h"
#include "../video/newgfx16.h"
#include "sdlintrf.h"

#ifdef __OPENGL__
#	include "../video/procvidc.h"
#endif


void StartUp(void) {}


void SystemInit(void)
{
	// Be sure to set SBHDMA to a value other than 0 if 16bit sound exists
	SBHDMA = 1;
}


void PrintChar(char const c)
{
	putchar(c);
}


void PrintStr(char const* const s)
{
	fputs(s, stdout);
}


char WaitForKey(void)
{
	return getchar();
}


u1 Check_Key(void)
{
	return CurKeyPos != CurKeyReadPos ? 0xFF : 0;
}


char Get_Key(void)
{
	u4 const pos = CurKeyReadPos;
	while (CurKeyPos == pos) {} // XXX busy waiting
	if (KeyBuffer[pos] & 0x100)
	{
		KeyBuffer[pos] -= 0x100;
		return 0;
	}
	else
	{
		CurKeyReadPos = (pos + 1) % lengthof(KeyBuffer);
		return KeyBuffer[pos];
	}
}


void delay(u4 const n) { (void)n; /* Stub please fix */ }


void InitPreGame(void)
{
	pressed[1] = 2;
	Start60HZ();
	initwinvideo();

	if (V8Mode != GrayscaleMode) V8Mode ^= 1;

	asm_call(AdjustFrequency);

	memset(vidbufferofsb, 0, 288 * 128 * 4);

	clearwin();
}


void SetupPreGame(void)
{
	pressed[1] = 2;
}


void DeInitPostGame(void)
{
	Stop60HZ();
}


void GUIInit(void)
{
	Start36HZ();
}


void GUIDeInit(void)
{
	Stop36HZ();
}


static void InitializeGfxStuff(void)
{
	static u1 const BitPosR  = 11;
	static u1 const BitPosG  =  5;
	static u1 const BitPosB  =  0;
	static u1 const BitSizeR =  5;
	static u1 const BitSizeG =  6;
	static u1 const BitSizeB =  5;

	{ // Process Red Stuff
		u1 al = BitPosR;
		u2 bx = 1U << al;
		if (BitSizeR == 6)
		{
			vesa2_usbit = bx;
			++al;
		}
		vesa2_clbit |= bx;
		vesa2_rpos   = al;
		--al;
		vesa2_rfull = al != 0xFF ? 0x1FU << al : 0x1FU >> 1;
		bx = 1U << (al + 5);
		vesa2_rtrcl  =  bx;
		vesa2_rtrcla = ~bx;
	}

	{ // Process Green Stuff
		u1 al = BitPosG;
		u2 bx = 1U << al;
		if (BitSizeG == 6)
		{
			vesa2_usbit = bx;
			++al;
		}
		vesa2_clbit |= bx;
		vesa2_gpos   = al;
		--al;
		vesa2_gfull = al != 0xFF ? 0x1FU << al : 0x1FU >> 1;
		bx = 1U << (al + 5);
		vesa2_gtrcl  =  bx;
		vesa2_gtrcla = ~bx;
	}

	{ // Process Blue Stuff
		u1 al = BitPosB;
		u2 bx = 1U << al;
		if (BitSizeB == 6)
		{
			vesa2_usbit = bx;
			++al;
		}
		vesa2_clbit |= bx;
		vesa2_bpos   = al;
		--al;
		vesa2_bfull = al != 0xFF ? 0x1FU << al : 0x1FU >> 1;
		bx = 1U << (al + 5);
		vesa2_btrcl  =  bx;
		vesa2_btrcla = ~bx;
	}

	vesa2_clbit ^= 0xFFFF;
	genfulladdtab();
	Init_2xSaIMMX(converta != 1 ? 565 : 555);
}


void initvideo(void)
{
	static u4 firstvideo = 1;

	res640            =   1;
	res480            =   1;
	cbitmode          =   1;
	vesa2_x           = 512;
	vesa2_y           = 480;
	vesa2_bits        =  16;
	vesa2_rpos        =  11;
	vesa2_gpos        =   5;
	vesa2_bpos        =   0;
	vesa2red10        =   0;
	vesa2_rposng      =  11;
	vesa2_gposng      =   5;
	vesa2_bposng      =   0;
	vesa2_clbitng     = 0x0000F7DE;
	vesa2_clbitng2[0] = 0xF7DEF7DE;
	vesa2_clbitng2[1] = 0xF7DEF7DE;
	vesa2_clbitng3    = 0x00007BEF;

	initwinvideo();

	if (GUIWFVID[cvidmode] != 0)
		PrevFSMode = cvidmode;
	else
		PrevWinMode = cvidmode;

	if (firstvideo != 1)
		InitializeGfxStuff();
	firstvideo = 0;

	InitializeGfxStuff();
}


void deinitvideo(void) {}


void DrawScreen(void)
{
	if (converta == 1)
	{
		UnusedBit[0]    = 0x80008000;
		HalfTrans[0]    = 0x7BDE7BDE;
		UnusedBitXor[0] = 0x7FFF7FFF;
		UnusedBit[1]    = 0x80008000;
		HalfTrans[1]    = 0x7BDE7BDE;
		UnusedBitXor[1] = 0x7FFF7FFF;
		HalfTransB[0]   = 0x04210421;
		HalfTransB[1]   = 0x04210421;
		HalfTransC[0]   = 0x7BDE7BDE;
		HalfTransC[1]   = 0x7BDE7BDE;
		ngrposng        = 10;
		nggposng        =  5;
		ngbposng        =  0;
		asm_call(ConvertToAFormat);
	}
	drawscreenwin();
#ifdef __OPENGL__
	if (blinit == 1)
	{
		initwinvideo();
		Clear2xSaIBuffer();
		blinit = 0;
	}
#endif
}


void UpdateDevices(void) { /* Stub please fix */ }
