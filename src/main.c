#include "LPC17xx.h"
#include "stdio.h"

// EE2024 Assignment 1 skeleton
// (C) CK Tham, ECE, NUS, 2017

// PID controller written in assembly language
extern int pid_ctrl(int en, int st);

uint32_t usTicks=0;

// This function is called every 1us
void SysTick_Handler(void)
{
    usTicks++;
}

// Plant or System under control
// a and b are parameters of the plant
double plant(double u, unsigned start, double a, double b)
{
    static double x1, x2, x3, x4, y;

    if (start)
	{
        x1 = x2 = x3 = x4 = 0.0;
    }

    x4 = x4 + b*(u-x4);
    x3 = x3 + b*(x4-x3);
    x2 = x2 + b*(x3-x2);
    x1 = x1 + b*(x2-x1);
    y = x1;
    return(y);
}

// PID Controller written in C
// This function takes in the error and a start flag and returns the control signal
// The start flag should be 1 the first time this function is called
double PIDcontrol(double en, unsigned start)
{
    static double Kp=0.25, Ki=0.125,  Kd=0.75, sn, enOld, un;
    if (start)
    {
        sn = enOld = 0.0;
    }
    sn = sn + en;
    if (sn>9.5) sn=9.5; else if (sn<-9.5) sn=-9.5;
    un = Kp*en + Ki*sn + Kd*(en-enOld);
    enOld = en;
    return(un);
}

int main(void)
{
    int i, startTicks, stopTicks;
    unsigned int st;
    double sp, y, e, u;
    int intermediate;

	// SystemTick clock configuration
	SysTick_Config(SystemCoreClock / 1000000);  // every 1us

//  ASM version
	sp = 1.0;
	u = 0.0;
	startTicks = usTicks;
    for (i=0; i<50; i++)
    {
        if (i==0) st=1; else st=0;

        y = plant(u,st,-0.8,0.2); // Do NOT change the plant parameters
        e = sp - y;

        //printf("y = %lf\n",y);

        //  Call the assembly language function pid_ctrl() here
        intermediate = pid_ctrl((e * 1000000), st);

        u = (double)intermediate / 1000000;

        //printf("u = %lf\n", u);
       	printf("e = %lf\n",e);
    }
    stopTicks = usTicks;
    printf("Time taken (ASM version): %ld microseconds\n",(stopTicks-startTicks));

//  C version
    sp = 1.0;
    u = 0.0;
    startTicks = usTicks;
    for (i=0; i<50; i++)
    {
        if (i==0) st=1; else st=0;

        y = plant(u,st,-0.8,0.2); // Do NOT change the plant parameters
        e = sp - y;

        // PID controller written in C
        u = PIDcontrol(e, st);
        //printf("%lf\n", u);
       	printf("%lf\n",e);
    }
    stopTicks = usTicks;
    printf("Time taken (C version): %ld microseconds\n",(stopTicks-startTicks));

    // Enter an infinite loop, just incrementing a counter
	// This is for convenience to allow registers, variables and memory locations to be inspected at the end
	volatile static int loop = 0;
	while (1) {
		loop++;
	}
}
