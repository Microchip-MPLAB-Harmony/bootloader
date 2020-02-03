/*******************************************************************************
  MPLAB Harmony Application Source File

  Company:
    Microchip Technology Inc.

  File Name:
    app.c

  Summary:
    This file contains the source code for the MPLAB Harmony application.

  Description:
    This file contains the source code for the MPLAB Harmony application.  It
    implements the logic of the application's state machine and it may call
    API routines of other MPLAB Harmony modules in the system, such as drivers,
    system services, and middleware.  However, it does not call any of the
    system interfaces (such as the "Initialize" and "Tasks" functions) of any of
    the modules in the system or make any assumptions about when those functions
    are called.  That is the responsibility of the configuration-specific system
    files.
 *******************************************************************************/

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include "app.h"
#include "definitions.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************

#define BTL_TRIGGER_PATTERN (0x5048434DUL)

// *****************************************************************************
/* Application Data

  Summary:
    Holds application data

  Description:
    This structure holds the application's data.

  Remarks:
    This structure should be initialized by the APP_Initialize function.

    Application strings and buffers are be defined outside this structure.
*/

APP_DATA appData;

static uint32_t *ramStart = (uint32_t *)BTL_TRIGGER_RAM_START;

static volatile uint16_t nvmctrlStatus = 0;

// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

/* TODO:  Add any necessary callback functions.
*/

// *****************************************************************************
// *****************************************************************************
// Section: Application Local Functions
// *****************************************************************************
// *****************************************************************************


/* TODO:  Add any necessary local functions.
*/


// *****************************************************************************
// *****************************************************************************
// Section: Application Initialization and State Machine Functions
// *****************************************************************************
// *****************************************************************************

/*******************************************************************************
  Function:
    void APP_Initialize ( void )

  Remarks:
    See prototype in app.h.
 */

void APP_Initialize ( void )
{
    appData.state = APP_INIT;

    APP_TIMER_START();
}


/******************************************************************************
  Function:
    void APP_Tasks ( void )

  Remarks:
    See prototype in app.h.
 */

void APP_Tasks ( void )
{

    /* Check the application's current state. */
    switch ( appData.state )
    {
        /* Application's initial state. */
        case APP_INIT:
        {
            nvmctrlStatus  = NVMCTRL_StatusGet();

            if ((nvmctrlStatus & NVMCTRL_AFIRST_MSK) != 0)
            {
                printf("\n\r####### Application running from NVM Flash BANK A #######\n\r");
            }
            else
            {
                printf("\n\r####### Application running from NVM Flash BANK B  #######\n\r");
            }


            printf("\n\r####### Press and Hold the Switch to trigger Bootloader #######\n\r");

            appData.state = APP_SWITCH_PRESS_WAIT;
            break;
        }

        case APP_SWITCH_PRESS_WAIT:
        {
            if (SWITCH_GET() == SWITCH_PRESSED)
            {
                appData.state = APP_TRIGGER_BOOTLOADER;
            }

            APP_TIMER_DelayMs(1000);

            LED_TOGGLE();

            break;
        }

        case APP_TRIGGER_BOOTLOADER:
        {
            printf("\n\r####### Bootloader Triggered #######\n\r");

            ramStart[0] = BTL_TRIGGER_PATTERN;
            ramStart[1] = BTL_TRIGGER_PATTERN;
            ramStart[2] = BTL_TRIGGER_PATTERN;
            ramStart[3] = BTL_TRIGGER_PATTERN;

            APP_SystemReset();
        }

        default:
        {
            /* TODO: Handle error in application's state machine. */
            break;
        }
    }
}


/*******************************************************************************
 End of File
 */
