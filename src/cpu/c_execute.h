#ifndef C_EXECUTE_H
#define C_EXECUTE_H

// this wonderful mess starts up the CPU and initialized the emulation state
void start65816(void);

void continueprog(void);

void endprog(void);

void interror(void);

#endif
