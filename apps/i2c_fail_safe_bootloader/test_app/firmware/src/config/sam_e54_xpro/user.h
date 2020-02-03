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
#define LED_ON()            LED_On()
#define LED_OFF()           LED_Off()
#define LED_TOGGLE()        LED_Toggle()

#define SWITCH_GET()        SWITCH_Get()
#define SWITCH_PRESSED      SWITCH_STATE_PRESSED
    
#define APP_TIMER_START     SYSTICK_TimerStart
#define APP_TIMER_DelayMs   SYSTICK_DelayMs

#define BTL_TRIGGER_RAM_START  0x20000000U

#define NVMCTRL_AFIRST_MSK  NVMCTRL_STATUS_AFIRST_Msk

static inline void APP_SystemReset( void )
{
    NVIC_SystemReset();
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
