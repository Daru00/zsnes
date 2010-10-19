#include <string.h>

#include "../cfg.h"
#include "../ui.h"
#include "../video/procvid.h"
#include "c_guitools.h"
#include "gui.h"


static void GUIoutputchar(u1* dst, u1 const glyph)
{
	// XXX better variable names
	// Font Setup (Menus)
	u1      (*font)[5] = newfont == 0 ? GUIFontData : GUIFontData1;
	u1 const* edi      = font[glyph];
	u4        cl       = 5;
	do
	{
		u4 ah = *edi;
		u4 ch = 6;
		do
		{
			if (ah & 0x80) *dst = GUItextcolor[0] - cl - ch + 1;
		}
		while (ah <<= 1, ++dst, --ch != 0);
		dst += 282;
		++edi;
	}
	while (--cl != 0);
}


char const* GUIOutputString(u1* dst, char const* text)
{
	for (;; dst += 6, ++text)
	{
		u1 const c = *text;
		if (c == '\0') return text;
		GUIoutputchar(dst, ASCII2Font[c]);
	}
}


void GUIOuttext(u4 const x, u4 const y, char const* const text, u1 const colour)
{
	GUItextcolor[0] = colour;
	u1* const dst = vidbuffer + y * 288 + x + 16;
	GUIOutputString(dst, text);
}


void GUIDrawBox(u1* dst, u4 const w, u4 h, u1 const colour)
{
	do
	{
		memset(dst, colour, w);
		dst += 288;
	}
	while (--h != 0);
}


void GUIBox(u4 const x1, u4 const y1, u4 const x2, u4 const y2, u1 const colour)
{
	u1* const dst = vidbuffer + x1 + y1 * 288 + 16;
	u4  const w   = x2 - x1 + 1;
	u4  const h   = y2 - y1 + 1;
	GUIDrawBox(dst, w, h, colour);
}


void GUIHLine(s4 x1, s4 x2, s4 const y, u1 const colour)
{
	if (x2 <   0) return;
	if (x1 > 255) return;
	if (x1 <   0) x1 =   0;
	if (x2 > 255) x2 = 255;
	if (y  <   0) return;
	if (y  > 223) return;
	memset(vidbuffer + x1 + 16 + y * 288, colour, x2 - x1 + 1);
}


static void GUIDrawShadow(u1* dst, u4 const w, u4 h)
{
	do
	{
		u1* edi = dst;
		u4  ecx = w;
		do
		{
			u1 px = edi[-3 * 288 - 3];
			if (148 <= px && px <= 167)
			{
				edi[-3 * 288 - 3] = px + 20;
			}
			else if (189 <= px && px <= 220)
			{
				edi[-3 * 288 - 3] = 189 + (px - 189) / 2;
			}
			else
			{
				px = edi[0];
				if (px < 32)
					edi[0] = px + 96;
			}
			++edi;
		}
		while (--ecx != 0);
		dst += 288;
	}
	while (--h != 0);
}


void GUIShadow(u4 const x1, u4 const y1, u4 const x2, u4 const y2)
{
	u1* const dst = vidbuffer + x1 + y1 * 288 + 16;
	u4  const w   = x2 - x1 + 1;
	u4  const h   = y2 - y1 + 1;
	GUIDrawShadow(dst, w, h);
}


void GUIDrawShadow2(u1* buf, u4 const w, u4 h)
{
	do
	{
		u1* b = buf;
		u4  n = w;
		do
		{
			u1 const c = *b;
			if (c < 32) *b = c + 96;
			++b;
		}
		while (--n != 0);
		buf += 288;
	}
	while (--h != 0);
}


static void GUIoutputcharwin(u1* dst, u1 const glyph)
{
	// Font Setup (Windows)
	u1      (*font)[5] = newfont == 0 ? GUIFontData : GUIFontData1;
	u1 const* edi      = font[glyph];
	u4        y        = 5;
	do
	{
		if (vidbuffer <= dst && dst < vidbuffer + 224 * 288) // XXX possible buffer overflow by 4
		{
			u4 ah = *edi;
			u4 x  = 5;
			do
			{
				if (ah & 0x80) *dst = GUItextcolor[0];
				ah <<= 1;
				++dst;
			}
			while (--x != 0);
			dst += 283;
		}
		else
		{
			dst += 288;
		}
		++edi;
	}
	while (--y != 0);
}


void GUIOutputStringwin(s4 x, u1* const dst, char const* text)
{
	for (;; x += 6)
	{
		u1 const c = *text++;
		if (c == '\0') break;
		if (-8 <= x && x <= 255) GUIoutputcharwin(dst + x, ASCII2Font[c]);
	}
}


void GUIOutputStringwinl(s4 x, u1* const dst, char const* text)
{
	u4 n = cloadmaxlen;
	do
	{
		u1 c = *text++;
#ifndef __MSDOS__
		if (c == '%')
		{
			u1       v;
			u1 const c0 = text[0];
			if      ('0' <= c0 && c0 <= '9') v = c0 - '0';
			else if ('A' <= c0 && c0 <= 'F') v = c0 - 'A' + 10;
			else if ('a' <= c0 && c0 <= 'f') v = c0 - 'a' + 10;
			else goto no_number;
			v <<= 4;
			u1 const c1 = text[1];
			if      ('0' <= c1 && c1 <= '9') v |= c1 - '0';
			else if ('A' <= c1 && c1 <= 'F') v |= c1 - 'A' + 10;
			else if ('a' <= c1 && c1 <= 'f') v |= c1 - 'a' + 10;
			else goto no_number;
			c     = v;
			text += 2;
no_number:;
		}
#endif
		if (c == '\0') break;
		if (-8 <= x && x <= 255) GUIoutputcharwin(dst + x, ASCII2Font[c]);
		x += 6;
	}
	while (--n != 0);
}


void OutputUnder(s4 const edx, u1* const esi)
{
	if (-8 <= edx && edx <= 255)
	{
		memset(esi + edx + 5 * 288 - 1, 0xE8, 5);
	}
}


void GUIOuttextwin(u4 x, u4 const y, char const* const text)
{
	GUIOutputStringwin(x, vidbuffer + y * 288 + 16, text);
}
