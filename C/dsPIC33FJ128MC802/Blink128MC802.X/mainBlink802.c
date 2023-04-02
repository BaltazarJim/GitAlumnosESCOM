/* 
 * File:   mainBlink802.c
 * Author: Baltazar
 *
 * Created on April 2, 2023, 12:57 AM
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "ConfigFOSC.h"
#include <libpic30.h>
#include <xc.h>

/*
 * 
 */
int main(int argc, char** argv) {
    AD1PCFGL = 0XFFFF;  //Configure pins ANX as digital (5 Analog pins))
    TRISB = 0XFF00;     //Configure PORTB <15:8> as inputs and <7:0> as ouputs
                          
    for (;;)
    {
        PORTB ^= 0X00FF;
        __delay_ms(100);        
        
    }

    return (EXIT_SUCCESS);
}

