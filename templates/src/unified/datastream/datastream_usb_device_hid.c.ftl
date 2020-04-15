/*******************************************************************************
 Data Stream USB_DEVICE_HID Source File

  File Name:
    datastream_usb_device_hid.c

  Summary:
    Data Stream USB_DEVICE_HID source

  Description:
    This file contains source code necessary for the data stream interface.
 *******************************************************************************/

//DOM-IGNORE-BEGIN
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
//DOM-IGNORE-END

#include "bootloader/datastream/datastream.h"
#include "usb/usb_device_hid.h"

typedef struct
{
    USB_DEVICE_HANDLE usbHandle;
    USB_DEVICE_HID_TRANSFER_HANDLE transferHandle;
    eDIR currDir;
    bool deviceConfigured;
    bool readRequest;
    bool DataSent;
    bool DataReceived;
    uint8_t *rxBuffer;
    uint32_t rxMaxSize;
    uint32_t rxCurSize;
    uint8_t *txBuffer;
    uint32_t txMaxSize;
    uint32_t txCurPos;
    uintptr_t context;
    DATASTREAM_HandlerType handler;
} USB_HID_DATA;

USB_HID_DATA usbHIDData;

static USB_DEVICE_HID_EVENT_RESPONSE DATASTREAM_USBDeviceHIDEventHandler
(
    USB_DEVICE_HID_INDEX iHID,
    USB_DEVICE_HID_EVENT event,
    void * eventData,
    uintptr_t userData
)
{
    /* Check type of event */
    switch (event)
    {
        case USB_DEVICE_HID_EVENT_REPORT_SENT:
            usbHIDData.DataSent = true;
            break;

        case USB_DEVICE_HID_EVENT_REPORT_RECEIVED:
            usbHIDData.DataReceived = true;
            break;

        case USB_DEVICE_HID_EVENT_SET_IDLE:

            /* For now we just accept this request as is. We acknowledge
             * this request using the USB_DEVICE_HID_ControlStatus()
             * function with a USB_DEVICE_CONTROL_STATUS_OK flag */

            USB_DEVICE_ControlStatus(usbHIDData.usbHandle, USB_DEVICE_CONTROL_STATUS_OK);

            break;

        case USB_DEVICE_HID_EVENT_GET_IDLE:
        default:
            // Nothing to do.
            break;
    }

    return USB_DEVICE_HID_EVENT_RESPONSE_NONE;
}

static void DATASTREAM_USBDeviceEventHandler(USB_DEVICE_EVENT event, void * eventData, uintptr_t context)
{
    switch(event)
    {
        case USB_DEVICE_EVENT_RESET:
        case USB_DEVICE_EVENT_DECONFIGURED:

            /* Host has de configured the device or a bus reset has happened.
             * Device layer is going to de-initialize all function drivers.
             * Hence close handles to all function drivers (Only if they are
             * opened previously. */
            usbHIDData.deviceConfigured = false;
            break;

        case USB_DEVICE_EVENT_CONFIGURED:
            /* Set the flag indicating device is configured. */
            usbHIDData.deviceConfigured = true;

            /* Register application HID event handler */
            USB_DEVICE_HID_EventHandlerSet(USB_DEVICE_HID_INDEX_${USB_DEVICE_INDEX}, DATASTREAM_USBDeviceHIDEventHandler, (uintptr_t)&usbHIDData);
            break;

        case USB_DEVICE_EVENT_SUSPENDED:
            break;

        case USB_DEVICE_EVENT_POWER_DETECTED:
            /* VBUS was detected. We can attach the device */
            USB_DEVICE_Attach (usbHIDData.usbHandle);
            break;

        case USB_DEVICE_EVENT_POWER_REMOVED:
            /* VBUS is not available */
            USB_DEVICE_Detach(usbHIDData.usbHandle);
            break;

        /* These events are not used in this demo */
        case USB_DEVICE_EVENT_RESUMED:
        case USB_DEVICE_EVENT_ERROR:
        default:
            break;
    }
}

void DATASTREAM_Tasks(void)
{
    if (false == usbHIDData.deviceConfigured)
    {
        return;
    }

    if (RX == usbHIDData.currDir)
    {
        if (usbHIDData.DataReceived == true)
        {
            usbHIDData.DataReceived = false;
            usbHIDData.readRequest = false;
            usbHIDData.currDir = IDLE;
            usbHIDData.handler(DATASTREAM_BUFFER_EVENT_COMPLETE, (DATASTREAM_HANDLE)usbHIDData.usbHandle, 64);
        }
        else if (usbHIDData.readRequest == false)
        {
            usbHIDData.DataReceived = false;

            /* Place a new read request. */
            USB_DEVICE_HID_ReportReceive (USB_DEVICE_HID_INDEX_${USB_DEVICE_INDEX},
                &usbHIDData.transferHandle, usbHIDData.rxBuffer, 64 );

            usbHIDData.readRequest = true;
        }
    }
    else if (TX == usbHIDData.currDir)
    {
        if ( (usbHIDData.DataSent == false) &&
             (usbHIDData.readRequest == false) &&
             (usbHIDData.txCurPos < usbHIDData.txMaxSize))
        {
            /* Prepare the USB module to send the data packet to the host */
            USB_DEVICE_HID_ReportSend (USB_DEVICE_HID_INDEX_${USB_DEVICE_INDEX},
                &usbHIDData.transferHandle, (usbHIDData.txBuffer + usbHIDData.txCurPos), 64);

            usbHIDData.txCurPos += 64;
            usbHIDData.readRequest = true;
        }
        else if ( (usbHIDData.DataSent == true) &&
                  (usbHIDData.txCurPos >= usbHIDData.txMaxSize)) // All data has been sent or is in the buffer
        {
            usbHIDData.readRequest = false;
            usbHIDData.currDir = IDLE;
            usbHIDData.DataSent = false;
            usbHIDData.handler(DATASTREAM_BUFFER_EVENT_COMPLETE, (DATASTREAM_HANDLE)usbHIDData.usbHandle, usbHIDData.context);
        }
        else if (usbHIDData.DataSent == true)
        {
            usbHIDData.readRequest = false;
            usbHIDData.DataSent = false;
        }
    }
}

DATASTREAM_HANDLE DATASTREAM_Open(const DRV_IO_INTENT ioIntent)
{
    usbHIDData.usbHandle = USB_DEVICE_Open( USB_DEVICE_INDEX_${USB_DEVICE_INDEX}, DRV_IO_INTENT_READWRITE );

    if(usbHIDData.usbHandle != USB_DEVICE_HANDLE_INVALID)
    {
        /* This means host operation is enabled. We can
        * move on to the next state */
        USB_DEVICE_EventHandlerSet(usbHIDData.usbHandle, DATASTREAM_USBDeviceEventHandler, 0);
    }

    return((DATASTREAM_HANDLE)usbHIDData.usbHandle);
}

void DATASTREAM_Close(void)
{
    if (usbHIDData.deviceConfigured)
    {
        USB_DEVICE_Detach(usbHIDData.usbHandle);
        USB_DEVICE_Close(usbHIDData.usbHandle);
    }
    USB_DEVICE_Deinitialize(usbHIDData.usbHandle);
}

DRV_CLIENT_STATUS DATASTREAM_ClientStatus(DATASTREAM_HANDLE handle)
{
    if(usbHIDData.deviceConfigured == true)
    {
        return DRV_CLIENT_STATUS_READY;
    }
    else
    {
        return DRV_CLIENT_STATUS_BUSY;
    }
}

int DATASTREAM_Data_Read(DATASTREAM_HANDLE handle, uint8_t *buffer, const uint32_t rxSize)
{
    usbHIDData.rxBuffer = buffer;
    usbHIDData.rxMaxSize = rxSize;
    usbHIDData.rxCurSize = 0;
    usbHIDData.currDir = RX;
    return(0);
}

int DATASTREAM_Data_Write(DATASTREAM_HANDLE handle, uint8_t *buffer, const uint32_t txSize)
{
    usbHIDData.txBuffer = buffer;
    usbHIDData.txMaxSize = txSize;
    usbHIDData.txCurPos = 0;
    usbHIDData.currDir = TX;
    return(0);
}

void DATASTREAM_BufferEventHandlerSet
(
    const DATASTREAM_HANDLE hClient,
    const void * eventHandler,
    const uintptr_t context
)
{
    usbHIDData.handler = (DATASTREAM_HandlerType)eventHandler;
    usbHIDData.context = context;
}
