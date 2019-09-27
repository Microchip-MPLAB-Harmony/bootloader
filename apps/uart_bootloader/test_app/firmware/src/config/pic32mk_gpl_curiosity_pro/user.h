/*******************************************************************************
  User Configuration Header

  File Name:
    user.h

  Summary:
    Build-time configuration header for the user defined by this project.

  Description:
    An MPLAB Project may have multiple configurations.  This file defines the
    build-time options for a single configuration.

  Remarks:
    It only provides macro definitions for build-time configuration options

*******************************************************************************/

#ifndef USER_H
#define USER_H

#include "bsp/bsp.h"
#include "sys/kmem.h"

// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility

extern "C" {

#endif
// DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: User Configuration macros
// *****************************************************************************
// *****************************************************************************
#define LED_ON()        LED3_On()
#define LED_OFF()       LED3_Off()
#define LED_TOGGLE()    LED3_Toggle()

#define SWITCH_GET()    SWITCH1_Get()
#define SWITCH_PRESSED  SWITCH1_STATE_PRESSED
    
#define APP_TIMER_START     CORETIMER_Start
#define APP_TIMER_DelayMs   CORETIMER_DelayMs

#define BTL_TRIGGER_RAM_START   KVA0_TO_KVA1(0x80000000)

static inline void APP_SystemReset( void )
{
    /* Perform system unlock sequence */ 
    SYSKEY = 0x00000000;
    SYSKEY = 0xAA996655;
    SYSKEY = 0x556699AA;

    RSWRSTSET = _RSWRST_SWRST_MASK;
    (void)RSWRST;
}

//DOM-IGNORE-BEGIN
#ifdef __cplusplus
}
#endif
//DOM-IGNORE-END

#endif // USER_H
/*******************************************************************************
 End of File
*/
