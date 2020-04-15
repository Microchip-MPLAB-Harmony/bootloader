/*******************************************************************************
  Bootloader Data Stream Interface Header File

  Company:
    Microchip Technology Inc.

  File Name:
    datastream.h

  Summary:
    Bootloader Data Stream Interface Header File

  Description:
    The Bootloader Data Stream provides an abstraction layer to allow any type
    of communication protocol/interface to be used by the bootloader.
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

#ifndef DATASTREAM_H
#define DATASTREAM_H

#include <stdint.h>
#include <stdbool.h>
#include "system/system.h"
#include "driver/driver_common.h"

#ifdef  __cplusplus
extern "C" {
#endif

#define APP_USR_CONTEXT 1


// *****************************************************************************
/* Datastream Buffer Handle

  Summary:
    Handle identifying a read or write buffer passed to the driver.

  Description:

  Remarks:
    None
*/

typedef uintptr_t DATASTREAM_HANDLE;

#define DATASTREAM_HANDLE_INVALID (((DATASTREAM_HANDLE) -1))

// *****************************************************************************
/* DATASTREAM Driver Buffer Events

   Summary
    Identifies the possible events that can result from a buffer add request.

   Description
    This enumeration identifies the possible events that can result from a
    buffer add request caused by the client calling either the
    DRV_USART_BufferAddRead or DRV_USART_BufferAddWrite functions.

   Remarks:
    One of these values is passed in the "event" parameter of the event
    handling callback function that the client registered with the driver by
    calling the DRV_USART_BufferEventHandlerSet function when a buffer
    transfer request is completed.

*/

typedef enum
{
    /* All data from or to the buffer was transferred successfully. */
    DATASTREAM_BUFFER_EVENT_COMPLETE,

    /* There was an error while processing the buffer transfer request. */
    DATASTREAM_BUFFER_EVENT_ERROR,

    /* Data transfer aborted (Applicable in DMA mode) */
    DATASTREAM_BUFFER_EVENT_ABORT

} DATASTREAM_BUFFER_EVENT;

typedef enum {
    IDLE = 0,
    RX,
    TX
} eDIR;

typedef void (*DATASTREAM_HandlerType)
(
    DATASTREAM_BUFFER_EVENT buffEvent,
    DATASTREAM_HANDLE handle,
    uintptr_t context
);

void DATASTREAM_BufferEventHandlerSet
(
    const DATASTREAM_HANDLE hClient,
    const void *eventHandler,
    const uintptr_t context
);

DATASTREAM_HANDLE DATASTREAM_Open(const DRV_IO_INTENT ioIntent);

void DATASTREAM_Close(void);

DRV_CLIENT_STATUS DATASTREAM_ClientStatus(DATASTREAM_HANDLE handle);

int DATASTREAM_Data_Read(DATASTREAM_HANDLE handle, uint8_t *buffer, const uint32_t rxSize);

int DATASTREAM_Data_Write(DATASTREAM_HANDLE handle, uint8_t *buffer, const uint32_t txSize);

void DATASTREAM_Tasks(void);

//DOM-IGNORE-END
#ifdef  __cplusplus
}
#endif

#endif  /* DATASTREAM_H */

