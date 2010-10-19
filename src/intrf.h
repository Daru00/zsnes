#ifndef INTRF_H
#define INTRF_H

#include "types.h"

extern u4   Init_Mouse(void);
extern void GUIDeInit();
extern void GUIInit();
extern void Get_Key();
extern void Get_MouseData();
extern void Get_MousePositionDisplacement();
extern void JoyRead();
extern void delay();
extern void vidpastecopyscr();

extern u1 GUIWFVID[];
extern u4 NumVideoModes;

#ifndef __MSDOS__
extern u4 CurKeyPos;
extern u4 CurKeyReadPos;
extern u4 converta;
#endif

#endif
