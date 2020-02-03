/*******************************************************************************
  MPLAB Harmony Application Source File

  Company:
    Microchip Technology Inc.

  File Name:
    app_same54.c

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

// DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2020 Microchip Technology Inc. and its subsidiaries.
*
* Subject to your compliance with these terms, you may use Microchip software
* and any derivatives exclusively with Microchip products. It is your
* responsibility to comply with third party license terms applicable to your
* use of third party software (including open source software) that may
* accompany Microchip software.
*
* THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
* EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
* WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
* PARTICULAR PURPOSE.
*
* IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
* INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
* WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
* BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
* FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
* ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
* THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
*******************************************************************************/
// DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include "definitions.h"
#include "app_same54.h"
#include "bsp/bsp.h"
#include "user.h"
#include <string.h>

// *****************************************************************************
// *****************************************************************************
// Section: Global Data Definitions
// *****************************************************************************
// *****************************************************************************
/* Definitions */
#define APP_BL_NUM_I2C_SLAVES                       1

#define APP_BL_SDCARD_MOUNT_NAME                    SYS_FS_MEDIA_IDX0_MOUNT_NAME_VOLUME_IDX0
#define APP_BL_SDCARD_DEV_NAME                      SYS_FS_MEDIA_IDX0_DEVICE_NAME_VOLUME_IDX0

#define APP_BL_STATUS_BIT_BUSY                      (0x01 << 0)
#define APP_BL_STATUS_BIT_INVALID_COMMAND           (0x01 << 1)
#define APP_BL_STATUS_BIT_INVALID_MEM_ADDR          (0x01 << 2)
#define APP_BL_STATUS_BIT_COMMAND_EXECUTION_ERROR   (0x01 << 3)      //Valid only when APP_BL_STATUS_BIT_BUSY is 0
#define APP_BL_STATUS_BIT_CRC_ERROR                 (0x01 << 4)
#define APP_BL_STATUS_BIT_ALL                       (APP_BL_STATUS_BIT_BUSY | APP_BL_STATUS_BIT_INVALID_COMMAND | APP_BL_STATUS_BIT_INVALID_MEM_ADDR | \
                                                    APP_BL_STATUS_BIT_COMMAND_EXECUTION_ERROR | APP_BL_STATUS_BIT_CRC_ERROR)
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

static APP_DATA                         appData;
static uint32_t                         crc_tab[256];
static BUFFER_ATTRIBUTES uint8_t        sdCardBuffer[APP_MAX_MEM_PAGE_SIZE];

/* For multiple I2C slaves on the same bus, set the APP_BL_NUM_I2C_SLAVES macro
 * to the number of slaves on the bus and populate this data structure with the
 * corresponding I2C slave's firmware update information as shown below for a
 * SAM E54 I2C slave.
 * For SAM D20, SAM D21, SAM C21N, SAM D11, SAM DA1, SAM L10, SAM L11, SAM L21, SAM L22:
    .i2cSlaveAddr       = <I2C Slave Address>,
    .erasePageSize      = 256,
    .programPageSize    = 64,
    .appStartAddr       = 0x800,
    .filename           = <firmware file name (.bin)>
 * For SAM E54:
    .i2cSlaveAddr       = <I2C Slave Address>,
    .erasePageSize      = 8192,
    .programPageSize    = 512,
    .appStartAddr       = 0x2000,
    .filename           = <firmware file name (.bin)>
 */
const APP_FIRMWARE_UPDATE_INFO  firmwareUpdateInfo[APP_BL_NUM_I2C_SLAVES] =
{
    {
        .i2cSlaveAddr       = 0x0054,
        .erasePageSize      = 8192,
        .programPageSize    = 512,
        .appStartAddr       = 0x2000,
        .filename           = "sam_e54_xpro.X.production.bin"
    },

    /* Add firmware update information for the additional I2C slaves on the bus
     * here */
};

// *****************************************************************************
// *****************************************************************************
// Section: Application Callback Functions
// *****************************************************************************
// *****************************************************************************

static void APP_I2CEventHandler(uintptr_t context )
{
    APP_TRANSFER_STATUS* trasnferStatus = (APP_TRANSFER_STATUS*)context;

    if(SERCOM7_I2C_ErrorGet() == SERCOM_I2C_ERROR_NONE)
    {
        if (trasnferStatus)
        {
            *trasnferStatus = APP_TRANSFER_STATUS_SUCCESS;
        }
    }
    else
    {
        if (trasnferStatus)
        {
            *trasnferStatus = APP_TRANSFER_STATUS_ERROR;
        }
    }
}

static void APP_SysFSEventHandler(SYS_FS_EVENT event, void* eventData, uintptr_t context)
{
    switch(event)
    {
        /* If the event is mount then check which media has been mounted */
        case SYS_FS_EVENT_MOUNT:
            if(strcmp((const char *)eventData, APP_BL_SDCARD_MOUNT_NAME) == 0)
            {
                appData.isSDCardMount = true;
            }
            break;

        /* If the event is unmount then check which media has been unmount */
        case SYS_FS_EVENT_UNMOUNT:
            if(strcmp((const char *)eventData, APP_BL_SDCARD_MOUNT_NAME) == 0)
            {
                appData.isSDCardMount = false;
            }
            break;

        case SYS_FS_EVENT_ERROR:
            break;
    }
}

// *****************************************************************************
// *****************************************************************************
// Section: Application Local Functions
// *****************************************************************************
// *****************************************************************************
static void APP_CRCTablePopulate(void)
{
    uint32_t i, j, value;

    for (i = 0; i < 256; i++)
    {
        value = i;

        for (j = 0; j < 8; j++)
        {
            if (value & 1)
            {
                value = (value >> 1) ^ 0xEDB88320;
            }
            else
            {
                value >>= 1;
            }
        }
        crc_tab[i] = value;
    }
}

static uint32_t APP_CRCGenerate(
    uint32_t initCRC,
    uint8_t* pBuffer,
    uint32_t nBytes
)
{
    uint32_t    i;
    uint8_t     data;
    uint32_t    crc = initCRC;

    for (i = 0; i < nBytes; i++)
    {
        data = pBuffer[i];

        crc = crc_tab[(crc ^ data) & 0xff] ^ (crc >> 8);
    }
    return crc;
}

static int32_t APP_SDCARD_ReadData(uint8_t* pBuffer, uint32_t nBytes)
{
    int32_t nBytesRead;

    nBytesRead = SYS_FS_FileRead(appData.fileHandle, (void *)pBuffer, nBytes);

    if (nBytesRead == -1)
    {
        /* There was an error while reading the file */
        SYS_FS_FileClose(appData.fileHandle);
        appData.fileHandle = SYS_FS_HANDLE_INVALID;
    }
    else
    {
        if(SYS_FS_FileEOF(appData.fileHandle) == true)
        {
            SYS_FS_FileClose(appData.fileHandle);
            appData.fileHandle = SYS_FS_HANDLE_INVALID;
        }
    }
    return nBytesRead;
}

static uint32_t APP_ProgramCommandHeaderGen(
    uint32_t memAddr,
    uint32_t nBytes
)
{
    uint32_t nTxBytes = 0;

    appData.wrBuffer[nTxBytes++] = APP_BL_COMMAND_PROGRAM;
    appData.wrBuffer[nTxBytes++] = (nBytes >> 24);
    appData.wrBuffer[nTxBytes++] = (nBytes >> 16);
    appData.wrBuffer[nTxBytes++] = (nBytes >> 8);
    appData.wrBuffer[nTxBytes++] = (nBytes);
    appData.wrBuffer[nTxBytes++] = (memAddr >> 24);
    appData.wrBuffer[nTxBytes++] = (memAddr >> 16);
    appData.wrBuffer[nTxBytes++] = (memAddr >> 8);
    appData.wrBuffer[nTxBytes++] = (memAddr);

    return nTxBytes;
}

static uint32_t APP_UnlockCommandHeaderGen(
    uint32_t appStartAddr,
    uint32_t appSize
)
{
    uint32_t nTxBytes = 0;

    appData.wrBuffer[nTxBytes++] = APP_BL_COMMAND_UNLOCK;
    appData.wrBuffer[nTxBytes++] = (appStartAddr >> 24);
    appData.wrBuffer[nTxBytes++] = (appStartAddr >> 16);
    appData.wrBuffer[nTxBytes++] = (appStartAddr >> 8);
    appData.wrBuffer[nTxBytes++] = (appStartAddr);
    appData.wrBuffer[nTxBytes++] = (appSize >> 24);
    appData.wrBuffer[nTxBytes++] = (appSize >> 16);
    appData.wrBuffer[nTxBytes++] = (appSize >> 8);
    appData.wrBuffer[nTxBytes++] = (appSize);

    return nTxBytes;
}

static uint32_t APP_VerifyCommandHeaderGen(uint32_t crc)
{
    uint32_t nTxBytes = 0;

    appData.wrBuffer[nTxBytes++] = APP_BL_COMMAND_VERIFY;
    appData.wrBuffer[nTxBytes++] = (crc >> 24);
    appData.wrBuffer[nTxBytes++] = (crc >> 16);
    appData.wrBuffer[nTxBytes++] = (crc >> 8);
    appData.wrBuffer[nTxBytes++] = (crc);

    return nTxBytes;
}

static uint32_t APP_EraseCommandHeaderGen(uint32_t memAddr)
{
    uint32_t nTxBytes = 0;

    appData.wrBuffer[nTxBytes++] = APP_BL_COMMAND_ERASE;
    appData.wrBuffer[nTxBytes++] = (memAddr >> 24);
    appData.wrBuffer[nTxBytes++] = (memAddr >> 16);
    appData.wrBuffer[nTxBytes++] = (memAddr >> 8);
    appData.wrBuffer[nTxBytes++] = (memAddr);

    return nTxBytes;
}

static int32_t APP_ImageDataWrite(
    uint32_t memAddr,
    uint32_t nBytes
)
{
    int32_t nTxBytes = 0;
    int32_t nDataBytesRead = 0;

    nTxBytes = APP_ProgramCommandHeaderGen(memAddr, nBytes);

    nDataBytesRead = APP_SDCARD_ReadData(sdCardBuffer, nBytes);

    if (nDataBytesRead < 0)
    {
        nTxBytes = -1;
    }
    else
    {
        /* Copy the data read from SD card to I2C wrBuffer */
        memcpy(&appData.wrBuffer[nTxBytes], sdCardBuffer, nDataBytesRead);

        /* Calculate CRC on data being sent to bootloader */
        appData.crcVal = APP_CRCGenerate(appData.crcVal, &appData.wrBuffer[nTxBytes], nBytes);
        nTxBytes += nBytes;
    }

    return nTxBytes;
}

// *****************************************************************************
// *****************************************************************************
// Section: Application Initialization and State Machine Functions
// *****************************************************************************
// *****************************************************************************

/*******************************************************************************
  Function:
    void APP_Initialize ( void )

  Remarks:
    See prototype in app_same54.h.
 */

void APP_SAME54_Initialize ( void )
{
    /* Wait for the switch to reflect idle (not pressed) state */
    while(SWITCH_GET() == SWITCH_STATUS_PRESSED);

    APP_CRCTablePopulate();

    appData.state            = APP_INIT;
    appData.nBytesWritten    = 0;
    appData.appImageSize     = 0;
    appData.isSDCardMount    = false;
    appData.fileSize         = 0;
    appData.i2cSlaveIndex    = 0;
    appData.percentageDone   = 0;

    /* Initial value of CRC */
    appData.crcVal           = 0xffffffff;

    /* Register the File System Event handler */
    SYS_FS_EventHandlerSet(APP_SysFSEventHandler, (uintptr_t)NULL);
}


/******************************************************************************
  Function:
    void APP_Tasks ( void )

  Remarks:
    See prototype in app_same54.h.
 */

void APP_SAME54_Tasks ( void )
{
    uint32_t nTxBytes;
    uint32_t nBytesToRead;
    uint8_t temp;

    switch (appData.state)
    {
        case APP_INIT:
            SERCOM7_I2C_CallbackRegister( APP_I2CEventHandler, (uintptr_t)&appData.trasnferStatus );
            appData.state = APP_DISK_MOUNT_WAIT;
            break;

        case APP_DISK_MOUNT_WAIT:
            if (appData.isSDCardMount == true)
            {
                appData.state = APP_CURRENT_DRIVE_SET;
            }
            break;

        case APP_CURRENT_DRIVE_SET:
            if(SYS_FS_CurrentDriveSet(APP_BL_SDCARD_MOUNT_NAME) == SYS_FS_RES_FAILURE)
            {
                /* Error while setting current drive */
                appData.state = APP_ERROR;
            }
            else
            {
                /* Start the operations on a switch press by user */
                appData.state = APP_WAIT_SWITCH_PRESS;
            }
            break;

        case APP_WAIT_SWITCH_PRESS:
            if (SWITCH_GET() == SWITCH_STATUS_PRESSED)
            {
                appData.state = APP_LOAD_I2C_SLAVE_DATA;
            }
            break;

        case APP_LOAD_I2C_SLAVE_DATA:
            if (appData.i2cSlaveIndex < APP_BL_NUM_I2C_SLAVES)
            {
                appData.nBytesWritten = 0;
                appData.crcVal = 0xffffffff;
                appData.percentageDone = 0;
                appData.i2cSlaveAddr = firmwareUpdateInfo[appData.i2cSlaveIndex].i2cSlaveAddr;
                appData.erasePageSize = firmwareUpdateInfo[appData.i2cSlaveIndex].erasePageSize;
                appData.programPageSize = firmwareUpdateInfo[appData.i2cSlaveIndex].programPageSize;
                appData.appStartAddr = firmwareUpdateInfo[appData.i2cSlaveIndex].appStartAddr;
                printf("%s 0x%x ", "I2C Slave Addr:", appData.i2cSlaveAddr);
                appData.state = APP_FILE_OPEN;
            }
            else
            {
                printf ("---------------------------------------------------------\r\n");
                appData.state = APP_IDLE;
            }
            break;

        case APP_FILE_OPEN:
            appData.fileHandle = SYS_FS_FileOpen((const char*)firmwareUpdateInfo[appData.i2cSlaveIndex].filename, (SYS_FS_FILE_OPEN_READ));
            if(appData.fileHandle == SYS_FS_HANDLE_INVALID)
            {
                /* Could not open the file. Error out */
                appData.state = APP_ERROR;
            }
            else
            {
                appData.fileSize = SYS_FS_FileSize(appData.fileHandle);
                appData.state = APP_SEND_UNLOCK_COMMAND;
            }
            break;

        case APP_SEND_UNLOCK_COMMAND:
            appData.appImageSize = appData.fileSize;

            /* Convert image size to page size boundary */
            appData.imageSizeMultipleOfPage = appData.appImageSize + (appData.erasePageSize - (appData.appImageSize % appData.erasePageSize));

            nTxBytes = APP_UnlockCommandHeaderGen(appData.appStartAddr, appData.imageSizeMultipleOfPage);
            appData.trasnferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
            SERCOM7_I2C_Write(appData.i2cSlaveAddr, &appData.wrBuffer[0], nTxBytes);
            appData.state = APP_WAIT_UNLOCK_COMMAND_TRANSFER_COMPLETE;
            break;

        case APP_WAIT_UNLOCK_COMMAND_TRANSFER_COMPLETE:
            if (appData.trasnferStatus == APP_TRANSFER_STATUS_SUCCESS)
            {
                appData.state = APP_SEND_ERASE_COMMAND;
            }
            else if (appData.trasnferStatus == APP_TRANSFER_STATUS_ERROR)
            {
                appData.state = APP_ERROR;
            }
            break;

        case APP_SEND_ERASE_COMMAND:
            if (appData.nBytesWritten < appData.appImageSize)
            {
                nTxBytes = APP_EraseCommandHeaderGen((appData.appStartAddr + appData.nBytesWritten));

                appData.nBytesWrittenInErasedPage = 0;
                appData.trasnferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
                SERCOM7_I2C_Write(appData.i2cSlaveAddr, &appData.wrBuffer[0], nTxBytes);
                appData.state = APP_WAIT_ERASE_COMMAND_TRANSFER_COMPLETE;
            }
            else
            {
                /* Firmware programming complete. Now verify CRC by sending verify command */
                appData.state = APP_SEND_VERIFY_COMMAND;
            }
            break;

        case APP_WAIT_ERASE_COMMAND_TRANSFER_COMPLETE:
            if (appData.trasnferStatus == APP_TRANSFER_STATUS_SUCCESS)
            {
                /* Read the status of erase command */
                appData.wrBuffer[0] = APP_BL_COMMAND_READ_STATUS;
                appData.trasnferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
                SERCOM7_I2C_WriteRead(appData.i2cSlaveAddr, &appData.wrBuffer[0], 1,  &appData.status, 1);

                appData.state = APP_READ_STATUS;
                appData.nextState = APP_SEND_WRITE_COMMAND;
            }
            else if (appData.trasnferStatus == APP_TRANSFER_STATUS_ERROR)
            {
                appData.state = APP_ERROR;
            }
            break;

        case APP_SEND_WRITE_COMMAND:
            if (appData.nBytesWritten < appData.imageSizeMultipleOfPage)
            {
                if (appData.appImageSize > appData.nBytesWritten)
                {
                    nBytesToRead = appData.appImageSize - appData.nBytesWritten;

                    if (nBytesToRead < appData.programPageSize)
                    {
                        /* This the last page of data. Fill the buffer bytes with 0xFF */
                        memset(appData.wrBuffer, 0xFF, appData.programPageSize);
                    }

                    nTxBytes = APP_ImageDataWrite((appData.appStartAddr + appData.nBytesWritten), appData.programPageSize);
                }
                else
                {
                    /* Just write 0xFF to remaining pages in the erased row */
                    memset(appData.wrBuffer, 0xFF, appData.programPageSize);
                    nTxBytes = APP_ProgramCommandHeaderGen((appData.appStartAddr + appData.nBytesWritten), appData.programPageSize);

                     /* Calculate CRC on data being sent to bootloader */
                    appData.crcVal = APP_CRCGenerate(appData.crcVal, &appData.wrBuffer[nTxBytes], appData.programPageSize);
                    nTxBytes += appData.programPageSize;
                }

                if (nTxBytes > 0)
                {
                    appData.trasnferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
                    SERCOM7_I2C_Write(appData.i2cSlaveAddr, &appData.wrBuffer[0], nTxBytes);
                    appData.state = APP_WAIT_WRITE_COMMAND_TRANSFER_COMPLETE;
                }
                else
                {
                    /* There was an error reading the data */
                    appData.nextState = APP_ERROR;
                }
            }
            else
            {
                /* Firmware programming complete. Now verify CRC by sending verify command */
                appData.state = APP_SEND_VERIFY_COMMAND;
            }
            break;

        case APP_WAIT_WRITE_COMMAND_TRANSFER_COMPLETE:
            if (appData.trasnferStatus == APP_TRANSFER_STATUS_SUCCESS)
            {
                appData.nBytesWritten += appData.programPageSize;
                appData.nBytesWrittenInErasedPage += appData.programPageSize;

                /* Display progress on console */
                temp = (appData.nBytesWritten/(float)appData.imageSizeMultipleOfPage) * 100.0;
                while ((temp - appData.percentageDone) > 10)
                {
                    appData.percentageDone += 10;
                    printf ("%c%c", 178, 178);
                }

                /* Command transfer complete. Wait for internal write to complete */
                appData.wrBuffer[0] = APP_BL_COMMAND_READ_STATUS;
                appData.trasnferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
                SERCOM7_I2C_WriteRead(appData.i2cSlaveAddr, &appData.wrBuffer[0], 1,  &appData.status, 1);

                appData.state = APP_READ_STATUS;
                if (appData.nBytesWrittenInErasedPage == appData.erasePageSize)
                {
                    /* All the pages of the Erased Row are written. Erase next row. */
                    appData.nextState = APP_SEND_ERASE_COMMAND;
                }
                else
                {
                    /* Continue to write to the Erased Page */
                    appData.nextState = APP_SEND_WRITE_COMMAND;
                }
            }
            else if (appData.trasnferStatus == APP_TRANSFER_STATUS_ERROR)
            {
                appData.nextState = APP_ERROR;
            }
            break;

        case APP_SEND_VERIFY_COMMAND:
            nTxBytes = APP_VerifyCommandHeaderGen(appData.crcVal);
            appData.trasnferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
            SERCOM7_I2C_Write(appData.i2cSlaveAddr, &appData.wrBuffer[0], nTxBytes);
            appData.state = APP_WAIT_VERIFY_COMMAND_TRANSFER_COMPLETE;
            break;

        case APP_WAIT_VERIFY_COMMAND_TRANSFER_COMPLETE:
            if (appData.trasnferStatus == APP_TRANSFER_STATUS_SUCCESS)
            {
                /* Read the status of the verify command */
                appData.wrBuffer[0] = APP_BL_COMMAND_READ_STATUS;
                appData.trasnferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
                SERCOM7_I2C_WriteRead(appData.i2cSlaveAddr, &appData.wrBuffer[0], 1,  &appData.status, 1);

                appData.state = APP_READ_STATUS;
                appData.nextState = APP_SEND_RESET_COMMAND;
            }
            else if (appData.trasnferStatus == APP_TRANSFER_STATUS_ERROR)
            {
                appData.state = APP_ERROR;
            }
            break;

        case APP_READ_STATUS:
            if (appData.trasnferStatus == APP_TRANSFER_STATUS_SUCCESS)
            {
                if (appData.status != 0)
                {
                    appData.state = APP_ERROR;
                }
                else
                {
                    appData.state = appData.nextState;
                }
            }
            else if (appData.trasnferStatus == APP_TRANSFER_STATUS_ERROR)
            {
                /* Slave is busy. Keep checking the status */
                appData.wrBuffer[0] = APP_BL_COMMAND_READ_STATUS;
                appData.trasnferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
                SERCOM7_I2C_WriteRead(appData.i2cSlaveAddr, &appData.wrBuffer[0], 1,  &appData.status, 1);
            }
            break;

        case APP_SEND_RESET_COMMAND:

            appData.wrBuffer[0] = APP_BL_COMMAND_RESET;
            appData.trasnferStatus = APP_TRANSFER_STATUS_IN_PROGRESS;
            SERCOM7_I2C_Write(appData.i2cSlaveAddr, &appData.wrBuffer[0], 1);
            appData.state = APP_WAIT_RESET_COMMAND_TRANSFER_COMPLETE;
            break;

        case APP_WAIT_RESET_COMMAND_TRANSFER_COMPLETE:
            if (appData.trasnferStatus == APP_TRANSFER_STATUS_SUCCESS)
            {
                appData.state = APP_SUCCESSFUL;
            }
            else if (appData.trasnferStatus == APP_TRANSFER_STATUS_ERROR)
            {
                appData.state = APP_ERROR;
            }
            break;

        case APP_SUCCESSFUL:

            LED_ON();
            appData.percentageDone = 100;
            printf ("%d%%   !!Success!!  \r\n", appData.percentageDone);

            /* Load next I2C slave data */
            appData.i2cSlaveIndex++;
            appData.state = APP_LOAD_I2C_SLAVE_DATA;
            break;

        case APP_ERROR:

            LED_OFF();
            if (appData.fileHandle != SYS_FS_HANDLE_INVALID)
            {
                SYS_FS_FileClose(appData.fileHandle);
            }
            printf ("%d%%   !!Failure!!  \r\n", appData.percentageDone);

            /* Load next I2C slave data */
            appData.i2cSlaveIndex++;
            appData.state = APP_LOAD_I2C_SLAVE_DATA;
            break;

        case APP_IDLE:
            break;

        default:
            break;
    }
}


/*******************************************************************************
 End of File
 */
