#ifndef C_COPYVWIN_H
#define C_COPYVWIN_H

#include "../types.h"

void HighResProc(u2** psrc, u1** pdst, u1* ebx);
void MMXInterpolwin(u2* esi, u1* edi, u1 dl);
void copy640x480x16bwin(void);

#endif
