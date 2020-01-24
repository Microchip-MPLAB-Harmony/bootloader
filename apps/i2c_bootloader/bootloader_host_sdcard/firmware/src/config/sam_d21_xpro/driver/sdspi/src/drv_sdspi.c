/*******************************************************************************
  SD Card (SPI) Driver

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sdspi.c

  Summary:
    SD Card (SPI) Asynchronous driver implementation.

  Description:
    This file contains the SD Card (SPI) Driver's asynchronous driver implementation.
*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2019 Microchip Technology Inc. and its subsidiaries.
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


// *****************************************************************************
// *****************************************************************************
// Section: Include Files
// *****************************************************************************
// *****************************************************************************

#include <string.h>
#include "drv_sdspi_plib_interface.h"
#include "drv_sdspi_local.h"

// *****************************************************************************
// *****************************************************************************
// Section: File Scope Variables
// *****************************************************************************
// *****************************************************************************
static CACHE_ALIGN uint8_t gDrvSDSPICmdResponseBuffer [DRV_SDSPI_INSTANCES_NUMBER][32] ;
static CACHE_ALIGN uint8_t gDrvSDSPIClkPulseData [DRV_SDSPI_INSTANCES_NUMBER][32];
static CACHE_ALIGN uint8_t gDrvSDSPICsdData [DRV_SDSPI_INSTANCES_NUMBER][32];
static CACHE_ALIGN uint8_t gDrvSDSPICidData [DRV_SDSPI_INSTANCES_NUMBER][32];
static CACHE_ALIGN uint8_t gDrvSDSPITempCidData [DRV_SDSPI_INSTANCES_NUMBER][32];

/* Dummy data transmitted by TX DMA, common to all driver instances. */
static CACHE_ALIGN uint8_t  txCommonDummyData[32];

static DRV_SDSPI_OBJ gDrvSDSPIObj[DRV_SDSPI_INSTANCES_NUMBER];

// *****************************************************************************
/* SD Card command table

  Summary:
    Defines the a command table for SD card.

  Description:
    This data structure makes a command table for the SD Card with the command,
    its CRC, expected response and a flag indicating whether the driver expects
    more data or not. This makes the SD card commands easier to handle.

  Remarks:
    The actual response for the command 'CMD_SD_SEND_OP_COND'is R3, but it has
    same number of bytes as R7. So R7 is used in the table.
*/

const DRV_SDSPI_CMD_OBJ gDrvSDSPICmdTable[] =
{
    /* Command                             CRC     response    response length*/
    {CMD_VALUE_GO_IDLE_STATE,              0x95,   RESPONSE_R1,         1 },
    {CMD_VALUE_SEND_OP_COND,               0xF9,   RESPONSE_R1,         1 },
    {CMD_VALUE_SEND_IF_COND,               0x87,   RESPONSE_R7,         5 },
    {CMD_VALUE_SEND_CSD,                   0xAF,   RESPONSE_R1,         1 },
    {CMD_VALUE_SEND_CID,                   0x1B,   RESPONSE_R1,         1 },
    {CMD_VALUE_STOP_TRANSMISSION,          0xC3,   RESPONSE_R1,         1 },
    {CMD_VALUE_SEND_STATUS,                0xAF,   RESPONSE_R2,         2 },
    {CMD_VALUE_SET_BLOCKLEN,               0xFF,   RESPONSE_R1,         1 },
    {CMD_VALUE_READ_SINGLE_BLOCK,          0xFF,   RESPONSE_R1,         1 },
    {CMD_VALUE_READ_MULTI_BLOCK,           0xFF,   RESPONSE_R1,         1 },
    {CMD_VALUE_WRITE_SINGLE_BLOCK,         0xFF,   RESPONSE_R1,         1 },
    {CMD_VALUE_WRITE_MULTI_BLOCK,          0xFF,   RESPONSE_R1,         1 },
    {CMD_VALUE_TAG_SECTOR_START,           0xFF,   RESPONSE_R1,         1 },
    {CMD_VALUE_TAG_SECTOR_END,             0xFF,   RESPONSE_R1,         1 },
    {CMD_VALUE_ERASE,                      0xDF,   RESPONSE_R1b,        1 },
    {CMD_VALUE_APP_CMD,                    0x73,   RESPONSE_R1,         1 },
    {CMD_VALUE_READ_OCR,                   0x25,   RESPONSE_R7,         5 },
    {CMD_VALUE_CRC_ON_OFF,                 0x25,   RESPONSE_R1,         1 },
    {CMD_VALUE_SD_SEND_OP_COND,            0xFF,   RESPONSE_R1,         1 },
    {CMD_VALUE_SET_WR_BLK_ERASE_COUNT,     0xFF,   RESPONSE_R1,         1 }
};

// *****************************************************************************
// *****************************************************************************
// Section: File Scope Functions
// *****************************************************************************
// *****************************************************************************
static inline uint32_t _DRV_SDSPI_MAKE_HANDLE(
    uint16_t token,
    uint8_t drvIndex,
    uint8_t clientIndex
)
{
    return ((token << 16) | (drvIndex << 8) | clientIndex);
}

static inline uint16_t _DRV_SDSPI_UPDATE_TOKEN( uint16_t token )
{
    token++;
    if (token >= _DRV_SDSPI_TOKEN_MAX)
    {
        token = 1;
    }
    return token;
}

static DRV_SDSPI_CLIENT_OBJ* _DRV_SDSPI_DriverHandleValidate( DRV_HANDLE handle )
{
    /* This function returns the pointer to the client object that is
       associated with this handle if the handle is valid. Returns NULL
       otherwise. */

    uint32_t drvInstance = 0;
    DRV_SDSPI_CLIENT_OBJ* clientObj = NULL;
    DRV_SDSPI_OBJ* dObj = NULL;

    if((handle != DRV_HANDLE_INVALID) && (handle != 0))
    {
        /* Extract the drvInstance value from the handle */
        drvInstance = ((handle & _DRV_SDSPI_INSTANCE_MASK) >> 8);

        if (drvInstance >= DRV_SDSPI_INSTANCES_NUMBER)
        {
            return NULL;
        }

        if ((handle & _DRV_SDSPI_INDEX_MASK) >= gDrvSDSPIObj[drvInstance].numClients)
        {
            return NULL;
        }

        /* Extract the client index and obtain the client object */
        clientObj = &((DRV_SDSPI_CLIENT_OBJ *)gDrvSDSPIObj[drvInstance].clientObjPool)[handle & _DRV_SDSPI_INDEX_MASK];

        if ((clientObj->clientHandle != handle) || (clientObj->inUse == false))
        {
            return NULL;
        }

        /* Check if the driver is ready for operation */
        dObj = (DRV_SDSPI_OBJ* )&gDrvSDSPIObj[clientObj->drvIndex];
        if (dObj->status != SYS_STATUS_READY)
        {
            return NULL;
        }
    }

    return(clientObj);
}

static void _DRV_SDSPI_UpdateGeometry( DRV_SDSPI_OBJ *dObj )
{
    uint8_t i = 0;

    /* Update the Media Geometry Table */
    for (i = 0; i <= SYS_MEDIA_GEOMETRY_TABLE_ERASE_ENTRY; i++)
    {
        dObj->mediaGeometryTable[i].blockSize = 512;
        dObj->mediaGeometryTable[i].numBlocks = dObj->discCapacity;
    }

    /* Update the Media Geometry Main Structure */
    dObj->mediaGeometryObj.mediaProperty = (SYS_MEDIA_PROPERTY)(SYS_MEDIA_READ_IS_BLOCKING | SYS_MEDIA_WRITE_IS_BLOCKING),

    /* Number of read, write and erase entries in the table */
    dObj->mediaGeometryObj.numReadRegions = 1,
    dObj->mediaGeometryObj.numWriteRegions = 1,
    dObj->mediaGeometryObj.numEraseRegions = 1,
    dObj->mediaGeometryObj.geometryTable = (SYS_MEDIA_REGION_GEOMETRY *)&dObj->mediaGeometryTable;
}

static void _DRV_SDSPI_CheckWriteProtectStatus
(
    DRV_SDSPI_OBJ *dObj
)
{
    dObj->isWriteProtected = false;

    /* Check if the Write Protect check is enabled */
    if (_DRV_SDSPI_EnableWriteProtectCheck())
    {
        /* Read from the pin */
        dObj->isWriteProtected = SYS_PORT_PinRead (dObj->writeProtectPin);
    }
}

static DRV_SDSPI_BUFFER_OBJ* _DRV_SDSPI_FreeBufferObjectGet(DRV_SDSPI_CLIENT_OBJ* clientObj)
{
    uint32_t index;
    DRV_SDSPI_OBJ* dObj = (DRV_SDSPI_OBJ* )&gDrvSDSPIObj[clientObj->drvIndex];
    DRV_SDSPI_BUFFER_OBJ* pBufferObj = (DRV_SDSPI_BUFFER_OBJ*)dObj->bufferObjPool;

    for (index = 0; index < dObj->bufferObjPoolSize; index++)
    {
        if (pBufferObj[index].inUse == false)
        {
            pBufferObj[index].inUse = true;
            pBufferObj[index].next = NULL;

            /* Generate a unique buffer handle consisting of an incrementing
             * token counter, driver index and the buffer index.
             */
            pBufferObj[index].commandHandle = (DRV_SDSPI_COMMAND_HANDLE)_DRV_SDSPI_MAKE_HANDLE(
                dObj->sdspiTokenCount, (uint8_t)clientObj->drvIndex, index);

            /* Update the token for next time */
            dObj->sdspiTokenCount = _DRV_SDSPI_UPDATE_TOKEN(dObj->sdspiTokenCount);

            return &pBufferObj[index];
        }
    }
    return NULL;
}

static bool _DRV_SDSPI_BufferObjectAddToList(
    DRV_SDSPI_OBJ* dObj,
    DRV_SDSPI_BUFFER_OBJ* bufferObj
)
{
    DRV_SDSPI_BUFFER_OBJ** pBufferObjList;
    bool isFirstBufferInList = false;

    pBufferObjList = (DRV_SDSPI_BUFFER_OBJ**)&(dObj->bufferObjList);

    // Is the buffer object list empty?
    if (*pBufferObjList == NULL)
    {
        *pBufferObjList = bufferObj;
        isFirstBufferInList = true;
    }
    else
    {
        // List is not empty. Iterate to the end of the buffer object list.
        while (*pBufferObjList != NULL)
        {
            if ((*pBufferObjList)->next == NULL)
            {
                // End of the list reached, add the buffer here.
                (*pBufferObjList)->next = bufferObj;
                break;
            }
            else
            {
                pBufferObjList = (DRV_SDSPI_BUFFER_OBJ**)&((*pBufferObjList)->next);
            }
        }
    }

    return isFirstBufferInList;
}

static DRV_SDSPI_BUFFER_OBJ* _DRV_SDSPI_BufferListGet(
    DRV_SDSPI_OBJ* dObj
)
{
    DRV_SDSPI_BUFFER_OBJ* pBufferObj = NULL;

    // Return the element at the head of the linked list
    pBufferObj = (DRV_SDSPI_BUFFER_OBJ*)dObj->bufferObjList;

    return pBufferObj;
}

static void _DRV_SDSPI_RemoveBufferObjFromList(
    DRV_SDSPI_OBJ* dObj
)
{
    DRV_SDSPI_BUFFER_OBJ** pBufferObjList;

    pBufferObjList = (DRV_SDSPI_BUFFER_OBJ**)&(dObj->bufferObjList);

    // Remove the element at the head of the linked list
    if (*pBufferObjList != NULL)
    {
        /* Save the buffer object to be removed. Set the next buffer object as
         * the new head of the linked list. Reset the removed buffer object. */

        DRV_SDSPI_BUFFER_OBJ* temp = *pBufferObjList;
        *pBufferObjList = (*pBufferObjList)->next;
        temp->next = NULL;
        temp->inUse = false;
    }
}

static void _DRV_SDSPI_RemoveClientBuffersFromList(
    DRV_SDSPI_OBJ* dObj,
    DRV_SDSPI_CLIENT_OBJ* clientObj
)
{
    DRV_SDSPI_BUFFER_OBJ** pBufferObjList;
    DRV_SDSPI_BUFFER_OBJ* delBufferObj = NULL;

    pBufferObjList = (DRV_SDSPI_BUFFER_OBJ**)&(dObj->bufferObjList);

    while (*pBufferObjList != NULL)
    {
        // Do not remove the buffer object that is already in process

        if (((*pBufferObjList)->clientHandle == clientObj->clientHandle) &&
                ((*pBufferObjList)->status == DRV_SDSPI_COMMAND_QUEUED))
        {
            // Save the node to be deleted off the list
            delBufferObj = *pBufferObjList;

            // Update the current node to point to the deleted node's next
            *pBufferObjList = (DRV_SDSPI_BUFFER_OBJ*)(*pBufferObjList)->next;

            if (clientObj->eventHandler != NULL)
            {
                /* Call the event handler */
                clientObj->eventHandler((SYS_MEDIA_BLOCK_EVENT)DRV_SDSPI_EVENT_COMMAND_ERROR, delBufferObj->commandHandle, clientObj->context);
            }

            // Reset the deleted node
            delBufferObj->status = DRV_SDSPI_COMMAND_COMPLETED;
            delBufferObj->next = NULL;
            delBufferObj->inUse = false;
        }
        else
        {
            // Move to the next node
            pBufferObjList = (DRV_SDSPI_BUFFER_OBJ**)&((*pBufferObjList)->next);
        }
    }
}

static void _DRV_SDSPI_RemoveBufferObjects (
    DRV_SDSPI_OBJ* dObj
)
{
    DRV_SDSPI_BUFFER_OBJ** pBufferObjList;
    DRV_SDSPI_BUFFER_OBJ* delBufferObj = NULL;
    DRV_SDSPI_CLIENT_OBJ* clientObj = NULL;

    pBufferObjList = (DRV_SDSPI_BUFFER_OBJ**)&(dObj->bufferObjList);

    while (*pBufferObjList != NULL)
    {
        // Save the node to be deleted off the list
        delBufferObj = *pBufferObjList;

        // Update the current node to point to the deleted node's next
        *pBufferObjList = (DRV_SDSPI_BUFFER_OBJ*)(*pBufferObjList)->next;

        /* Get the client object that owns this buffer */
        clientObj = &((DRV_SDSPI_CLIENT_OBJ *)dObj->clientObjPool)[delBufferObj->clientHandle & _DRV_SDSPI_INDEX_MASK];

        if (clientObj->eventHandler != NULL)
        {
            /* Call the event handler */
            clientObj->eventHandler((SYS_MEDIA_BLOCK_EVENT)DRV_SDSPI_EVENT_COMMAND_ERROR, delBufferObj->commandHandle, clientObj->context);
        }

        // Reset the deleted node
        delBufferObj->next = NULL;
        delBufferObj->inUse = false;
    }
}

static uint32_t _DRV_SDSPI_ProcessCSD(uint8_t* csdPtr)
{
    uint32_t discCapacity;
    uint8_t cSizeMultiplier;
    uint16_t blockLength;
    uint32_t cSize;
    uint32_t mult;

    /* Extract some fields from the response for computing the card capacity. */
    /* Note: The structure format depends on if it is a CSD V1 or V2 device.
       Therefore, need to first determine version of the specs that the card
       is designed for, before interpreting the individual fields.
     */
    /* Calculate the MDD_SDSPI_finalLBA (see SD card physical layer
       simplified spec 2.0, section 5.3.2).
       In USB mass storage applications, we will need this information
       to correctly respond to SCSI get capacity requests.  Note: method
       of computing MDD_SDSPI_finalLBA TODO depends on CSD structure spec
       version (either v1 or v2).
     */
    if (csdPtr[0] == DRV_SDSPI_DATA_START_TOKEN)
    {
        /* Note: This is a workaround. Some cards issue data start token
        before sending the 16 byte csd data and some don't. */
        csdPtr = csdPtr + 1;
    }

    if (csdPtr[0] & _DRV_SDSPI_CHECK_V2_DEVICE)
    {
        /* Check CSD_STRUCTURE field for v2+ struct device */
        /* Must be a v2 device (or a reserved higher version, that
           doesn't currently exist) */
        /* Extract the C_SIZE field from the response.  It is a 22-bit
           number in bit position 69:48.  This is different from v1.
           It spans bytes 7, 8, and 9 of the response.
         */
        cSize = (((uint32_t)csdPtr[7] & 0x3F) << 16) | ((uint16_t)csdPtr[8] << 8) | csdPtr[9];
        discCapacity = ((uint32_t)(cSize + 1) * (uint16_t)(1024u));
    }
    else /* Not a V2 device, Must be a V1 device */
    {
        /* Must be a v1 device. Extract the C_SIZE field from the
           response.  It is a 12-bit number in bit position 73:62.
           Although it is only a 12-bit number, it spans bytes 6, 7,
           and 8, since it isn't byte aligned.
         */
        cSize = csdPtr[6] & 0x3;
        cSize <<= 8;
        cSize |= csdPtr[7];
        cSize <<= 2;
        cSize |= (csdPtr[8] >> 6);
        /* Extract the C_SIZE_MULT field from the response.  It is a
           3-bit number in bit position 49:47 */
        cSizeMultiplier = (csdPtr[9] & 0x03) << 1;
        cSizeMultiplier |= ((csdPtr[10] & 0x80) >> 7);

        /* Extract the BLOCK_LEN field from the response. It is a
           4-bit number in bit position 83:80
         */
        blockLength = csdPtr[5] & 0x0F;
        blockLength = 1 << (blockLength - 9);

        /* Calculate the capacity (see SD card physical layer simplified
           spec 2.0, section 5.3.2). In USB mass storage applications,
           we will need this information to correctly respond to SCSI get
           capacity requests (which will cause MDD_SDSPI_ReadCapacity()
           to get called).
         */

        mult = 1 << (cSizeMultiplier + 2);
        discCapacity = (((uint32_t)(cSize + 1) * mult) * blockLength);
    }

    return discCapacity;
}

static void _DRV_SDSPI_CommandSend
(
    SYS_MODULE_OBJ object,
    DRV_SDSPI_COMMANDS command,
    uint32_t address
)
{
    DRV_SDSPI_OBJ* dObj = (DRV_SDSPI_OBJ*)&gDrvSDSPIObj[object];
    uint8_t endianArray[4];

    switch (dObj->cmdState)
    {
        case DRV_SDSPI_CMD_FRAME_PACKET:

            dObj->cmdRespTmrFlag = false;

            /* SD card follows big-endian format */
            *((uint32_t*)endianArray) = *((uint32_t*)&address);

            /* Form the packet */
            dObj->pCmdResp[0] = (gDrvSDSPICmdTable[command].commandCode | DRV_SDSPI_TRANSMIT_SET);
            dObj->pCmdResp[1] = endianArray[3];
            dObj->pCmdResp[2] = endianArray[2];
            dObj->pCmdResp[3] = endianArray[1];
            dObj->pCmdResp[4] = endianArray[0];
            dObj->pCmdResp[5] = gDrvSDSPICmdTable[command].crc;
            /* Dummy data. Only used in case of DRV_SDCARD_STOP_TRANSMISSION */
            dObj->pCmdResp[6] = 0xFF;

            dObj->ncrTries = _DRV_SDSPI_COMMAND_RESPONSE_TRIES;

            dObj->cmdState = DRV_SDSPI_CMD_SEND_PACKET;
            break;

        case DRV_SDSPI_CMD_SEND_PACKET:

            /* Write the framed packet to the card */
            if (_DRV_SDSPI_SPIWrite(dObj, dObj->pCmdResp, DRV_SDSPI_PACKET_SIZE) == false)
            {
                dObj->cmdState = DRV_SDSPI_CMD_EXEC_ERROR;
                break;
            }

            if (command != DRV_SDSPI_STOP_TRANSMISSION)
            {
                dObj->cmdState = DRV_SDSPI_CMD_CHECK_TRANSFER_COMPLETE;
            }
            else
            {
                /* Do an extra read for this command */
                dObj->cmdState = DRV_SDSPI_CMD_CHECK_SPL_CASE;
            }
            break;

        case DRV_SDSPI_CMD_CHECK_SPL_CASE:
            if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_COMPLETE)
            {
                /* Do a dummy read */
                if (_DRV_SDSPI_SPIRead(dObj, dObj->pCmdResp, 1) == true)
                {
                    dObj->cmdState = DRV_SDSPI_CMD_CHECK_TRANSFER_COMPLETE;
                }
                else
                {
                    dObj->cmdState = DRV_SDSPI_CMD_EXEC_ERROR;
                }
            }
            else if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_ERROR)
            {
                dObj->cmdState = DRV_SDSPI_CMD_EXEC_ERROR;
            }
            break;

        case DRV_SDSPI_CMD_CHECK_TRANSFER_COMPLETE:

            if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_COMPLETE)
            {
                if (_DRV_SDSPI_SPIRead(dObj, dObj->pCmdResp, 1) == true)
                {
                    /* Act as per the response type */
                    dObj->cmdState = DRV_SDSPI_CMD_CHECK_RESP_TYPE;
                }
                else
                {
                    dObj->cmdState = DRV_SDSPI_CMD_EXEC_ERROR;
                }
            }
            else if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_ERROR)
            {
                dObj->cmdState = DRV_SDSPI_CMD_EXEC_ERROR;
            }
            break;

        case DRV_SDSPI_CMD_CHECK_RESP_TYPE:

            if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_COMPLETE)
            {
                dObj->cmdResponse.response1.byte = dObj->pCmdResp[0];

                if (dObj->cmdResponse.response1.byte == DRV_SDSPI_MMC_FLOATING_BUS)
                {
                    dObj->ncrTries--;

                    if (dObj->ncrTries == 0)
                    {
                        /* Abort the command operation. */
                        dObj->cmdState = DRV_SDSPI_CMD_EXEC_ERROR;
                    }
                    else
                    {
                        dObj->cmdState = DRV_SDSPI_CMD_CHECK_TRANSFER_COMPLETE;
                    }
                    break;
                }

                /* Received the response */

                switch (gDrvSDSPICmdTable[command].responseType)
                {
                    case RESPONSE_R1:
                        /* Device requires at least 8 clock pulses after the response
                           has been sent, before it can process the next command.
                           CS may be high or low */
                        if (_DRV_SDSPI_SPIRead(dObj, dObj->pCmdResp,
                                _DRV_SDSPI_SEND_8_CLOCKS) == true)
                        {
                            dObj->cmdState = DRV_SDSPI_CMD_EXEC_CHECK_COMPLETION;
                        }
                        else
                        {
                            dObj->cmdState = DRV_SDSPI_CMD_EXEC_ERROR;
                        }
                        break;

                    case RESPONSE_R2:

                        /* We already received the first byte, just make sure it is in the
                           correct location in the structure. */
                        dObj->cmdResponse.response2.byte1 = dObj->cmdResponse.response1.byte;

                        /* Fetch the second byte of the response. */
                        if (_DRV_SDSPI_SPIRead(dObj, dObj->pCmdResp, 1) == true)
                        {
                            dObj->cmdState = DRV_SDSPI_CMD_HANDLE_R2_RESPONSE;
                        }
                        else
                        {
                            dObj->cmdState = DRV_SDSPI_CMD_EXEC_ERROR;
                        }
                        break;

                    case RESPONSE_R1b:

                        /* Keep trying to read from the media, until it signals it is no longer
                           busy. It will continuously send 0x00 bytes until it is not busy.
                           A non-zero value means it is ready for the next command.
                           The R1b response is received after a CMD12,  CMD_STOP_TRANSMISSION
                           command, where the media card may be busy writing its internal buffer
                           to the flash memory.  This can typically take a few milliseconds,
                           with a recommended maximum time-out of 250ms or longer for SD cards.
                         */
                        if (_DRV_SDSPI_SPIRead(dObj, (uint8_t*)dObj->pCmdResp, 1) == true)
                        {
                            dObj->cmdState = DRV_SDSPI_CMD_R1B_READ_BACK;
                        }
                        else
                        {
                            dObj->cmdState = DRV_SDSPI_CMD_EXEC_ERROR;
                        }
                        break;

                    case RESPONSE_R7:

                        /* Fetch the other four bytes of the R3 or R7 response. */
                        /* Note: The SD card argument response field is 32-bit, big endian format.
                           However, the C compiler stores 32-bit values in little endian in RAM.
                           When writing to the bytes, make sure the order it gets stored in is correct. */
                        if (_DRV_SDSPI_SPIRead(dObj, dObj->pCmdResp, 4) == true)
                        {
                            dObj->cmdState = DRV_SDSPI_CMD_HANDLE_R7_RESPONSE;
                        }
                        else
                        {
                            dObj->cmdState = DRV_SDSPI_CMD_EXEC_ERROR;
                        }
                        break;

                    case RESPONSE_R3:
                    default:
                        break;
                }
            }
            else if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_ERROR)
            {
                dObj->cmdState = DRV_SDSPI_CMD_EXEC_ERROR;
            }
            break;

        case DRV_SDSPI_CMD_R1B_READ_BACK:
            if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_COMPLETE)
            {
                dObj->cmdResponse.response1.byte = dObj->pCmdResp[0];

                if (dObj->cmdResponse.response1.byte != 0x00)
                {
                    /* Received the response. Stop the timer */
                    _DRV_SDSPI_CmdResponseTimerStop(dObj);
                    dObj->cmdRespTmrFlag = false;

                    /* Device requires at least 8 clock pulses after the response
                       has been sent, before it can process the next command.
                       CS may be high or low */
                    if (_DRV_SDSPI_SPIWrite(dObj, dObj->pClkPulseData, _DRV_SDSPI_SEND_8_CLOCKS) == false)
                    {
                        dObj->cmdState = DRV_SDSPI_CMD_EXEC_ERROR;
                    }
                    else
                    {
                        dObj->cmdState = DRV_SDSPI_CMD_EXEC_CHECK_COMPLETION;
                    }
                }
                else
                {
                    if (dObj->cmdRespTmrFlag == false)
                    {
                        if (_DRV_SDSPI_CmdResponseTimerStart(dObj, _DRV_SDSPI_R1B_RESP_TIMEOUT) == false)
                        {
                            dObj->cmdState = DRV_SDSPI_CMD_EXEC_ERROR;
                            break;
                        }
                        dObj->cmdRespTmrFlag = true;
                    }

                    if (dObj->cmdRespTmrExpired == true)
                    {
                        /* Abort the command operation. */
                        dObj->cmdState = DRV_SDSPI_CMD_EXEC_ERROR;
                        dObj->cmdRespTmrFlag = false;
                        break;
                    }

                    if (_DRV_SDSPI_SPIRead(dObj, (uint8_t*)dObj->pCmdResp, 1) == true)
                    {
                        dObj->cmdState = DRV_SDSPI_CMD_R1B_READ_BACK;
                    }
                    else
                    {
                        _DRV_SDSPI_CmdResponseTimerStop(dObj);
                        dObj->cmdRespTmrFlag = false;
                        dObj->cmdState = DRV_SDSPI_CMD_EXEC_ERROR;
                    }
                }
            }
            else if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_ERROR)
            {
                dObj->cmdState = DRV_SDSPI_CMD_EXEC_ERROR;
            }
            break;

        case DRV_SDSPI_CMD_HANDLE_R2_RESPONSE:

            if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_COMPLETE)
            {
                dObj->cmdResponse.response2.byte1 = dObj->pCmdResp[0];
                /* Device requires at least 8 clock pulses after the response
                   has been sent, before if can process the next command.
                   CS may be high or low */
                if (_DRV_SDSPI_SPIWrite(dObj, dObj->pClkPulseData, _DRV_SDSPI_SEND_8_CLOCKS) == false)
                {
                    dObj->cmdState = DRV_SDSPI_CMD_EXEC_ERROR;
                }
                else
                {
                    dObj->cmdState = DRV_SDSPI_CMD_EXEC_CHECK_COMPLETION;
                }
            }
            else if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_ERROR)
            {
                dObj->cmdState = DRV_SDSPI_CMD_EXEC_ERROR;
            }
            break;

        case DRV_SDSPI_CMD_HANDLE_R7_RESPONSE:

            if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_COMPLETE)
            {
                /* Handle the endianness */
                dObj->cmdResponse.response7.bytewise.argument.ocrRegisterByte0 =
                    dObj->pCmdResp[3];
                dObj->cmdResponse.response7.bytewise.argument.ocrRegisterByte1 =
                    dObj->pCmdResp[2];
                dObj->cmdResponse.response7.bytewise.argument.ocrRegisterByte2 =
                    dObj->pCmdResp[1];
                dObj->cmdResponse.response7.bytewise.argument.ocrRegisterByte3 =
                    dObj->pCmdResp[0];

                /* Device requires at least 8 clock pulses after the response
                   has been sent, before if can process the next command.
                   CS may be high or low */
                if (_DRV_SDSPI_SPIWrite(dObj, dObj->pClkPulseData, _DRV_SDSPI_SEND_8_CLOCKS) == false)
                {
                    dObj->cmdState = DRV_SDSPI_CMD_EXEC_ERROR;
                }
                else
                {
                    dObj->cmdState = DRV_SDSPI_CMD_EXEC_CHECK_COMPLETION;
                }
            }
            else if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_ERROR)
            {
                dObj->cmdState = DRV_SDSPI_CMD_EXEC_ERROR;
            }
            break;

        case DRV_SDSPI_CMD_EXEC_CHECK_COMPLETION:

            if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_COMPLETE)
            {
                dObj->cmdState = DRV_SDSPI_CMD_CONFIRM_COMPLETE;
            }
            else if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_ERROR)
            {
                dObj->cmdState = DRV_SDSPI_CMD_EXEC_ERROR;
            }
            break;

        case DRV_SDSPI_CMD_CONFIRM_COMPLETE:
            dObj->cmdState = DRV_SDSPI_CMD_EXEC_IS_COMPLETE;
            break;

        case DRV_SDSPI_CMD_EXEC_ERROR:
        case DRV_SDSPI_CMD_EXEC_IS_COMPLETE:
            /* This code will be the first case statement getting executed on calling
               _DRV_SDSPI_CommandSend function, except first time */
            dObj->cmdState = DRV_SDSPI_CMD_FRAME_PACKET;
            break;

        default:
            break;
    }
}

static DRV_SDSPI_ATTACH _DRV_SDSPI_MediaCommandDetect
(
    SYS_MODULE_OBJ object
)
{
    DRV_SDSPI_ATTACH cardStatus = DRV_SDSPI_IS_DETACHED;
    DRV_SDSPI_OBJ* dObj = (DRV_SDSPI_OBJ*)&gDrvSDSPIObj[object];

    switch (dObj->cmdDetectState)
    {
        case DRV_SDSPI_CMD_DETECT_START_INIT:

            /* If the SPI module is not enabled, then the media has evidently not
               been initialized.  Try to send CMD0 and CMD13 to reset the device and
               get it into SPI mode (if present), and then request the status of
               the media.  If this times out, then the card is presumably not
               physically present */

            dObj->sdState = TASK_STATE_CARD_STATUS;

            if (_DRV_SDSPI_SPISpeedSetup(dObj, _DRV_SDSPI_SPI_INITIAL_SPEED) == true)
            {
                dObj->cmdDetectState = DRV_SDSPI_CMD_DETECT_CHECK_FOR_CARD;
            }
            else
            {
                dObj->sdState = TASK_STATE_IDLE;
            }
            break;

        case DRV_SDSPI_CMD_DETECT_CHECK_FOR_CARD:

            /* Send CMD0 to reset the media. If the card is physically present,
               then we should get a valid response. Toggle chip select, to make
               media abandon whatever it may have been doing before.  This ensures
               the CMD0 is sent freshly after CS is asserted low, minimizing risk
               of SPI clock pulse master/slave synchronization problems, due to
               possible application noise on the SCK line. */

            /* Send some "extraneous" clock pulses.  If a previous command was
               terminated before it completed normally, the card might not have
               received the required clocking following the transfer. */

            dObj->sdState = TASK_STATE_CARD_STATUS;

            if (_DRV_SDSPI_SPIWriteWithChipSelectDisabled(dObj, dObj->pClkPulseData,
                        MEDIA_INIT_ARRAY_SIZE) == true)
            {
                dObj->cmdDetectState = DRV_SDSPI_CMD_DETECT_WAIT_TRANSFER_COMPLETE;
            }
            break;

        case DRV_SDSPI_CMD_DETECT_WAIT_TRANSFER_COMPLETE:

            if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_COMPLETE)
            {
                dObj->cmdDetectState = DRV_SDSPI_CMD_DETECT_RESET_SDCARD;
            }
            else if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_ERROR)
            {
                dObj->cmdDetectState = DRV_SDSPI_CMD_DETECT_CHECK_FOR_CARD;
                dObj->sdState = TASK_STATE_IDLE;
            }
            break;

        case DRV_SDSPI_CMD_DETECT_RESET_SDCARD:

            _DRV_SDSPI_CommandSend (object, DRV_SDSPI_GO_IDLE_STATE, 0x00);

            if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_IS_COMPLETE)
            {
                dObj->sdState = TASK_STATE_IDLE;
                /* R1 response byte should be 0x01 after CMD_GO_IDLE_STATE */
                if (dObj->cmdResponse.response1.byte != CMD_R1_END_BIT_SET)
                {
                    /* Assuming that the card is not present. */
                    dObj->cmdDetectState = DRV_SDSPI_CMD_DETECT_CHECK_FOR_CARD;
                }
                else
                {
                    dObj->cmdDetectState = DRV_SDSPI_CMD_DETECT_IDLE_STATE;
                    cardStatus = DRV_SDSPI_IS_ATTACHED;
                }
            }
            else if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_ERROR)
            {
                dObj->sdState = TASK_STATE_IDLE;
                dObj->cmdDetectState = DRV_SDSPI_CMD_DETECT_CHECK_FOR_CARD;
            }
            break;

        case DRV_SDSPI_CMD_DETECT_CHECK_FOR_DETACH:

            if (dObj->sdState == TASK_STATE_CARD_COMMAND)
            {
                cardStatus = DRV_SDSPI_IS_ATTACHED;
            }
            else
            {
                /* Here the default state of the card is attached */
                cardStatus = DRV_SDSPI_IS_ATTACHED;
                dObj->sdState = TASK_STATE_CARD_STATUS;

                /* CMD10: Read CID data structure */
                _DRV_SDSPI_CommandSend (object, DRV_SDSPI_SEND_CID, 0x00);

                /* Change from this state only on completion of command execution */
                if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_IS_COMPLETE)
                {
                    if (dObj->cmdResponse.response1.byte == 0x00)
                    {
                        dObj->cmdDetectState = DRV_SDSPI_CMD_DETECT_CHECK_FOR_DETACH_READ_CID_DATA;
                    }
                    else
                    {
                        dObj->sdState = TASK_STATE_IDLE;
                        dObj->cmdDetectState = DRV_SDSPI_CMD_DETECT_CHECK_FOR_CARD;
                        cardStatus = DRV_SDSPI_IS_DETACHED;
                    }
                }
                else if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_ERROR)
                {
                    dObj->sdState = TASK_STATE_IDLE;
                    dObj->cmdDetectState = DRV_SDSPI_CMD_DETECT_CHECK_FOR_CARD;
                    cardStatus = DRV_SDSPI_IS_DETACHED;
                }
            }
            break;

        case DRV_SDSPI_CMD_DETECT_CHECK_FOR_DETACH_READ_CID_DATA:

            /* Here the default state of the card is attached */
            cardStatus = DRV_SDSPI_IS_ATTACHED;

            /* According to the simplified spec, section 7.2.6, the card will respond
               with a standard response token, followed by a data block of 16 bytes
               suffixed with a 16-bit CRC.
             */
            if (_DRV_SDSPI_SPIRead(dObj, &gDrvSDSPITempCidData[object], _DRV_SDSPI_CID_READ_SIZE) == true)
            {
                dObj->cmdDetectState = DRV_SDSPI_CMD_DETECT_CHECK_FOR_DETACH_PROCESS_CID_DATA;
            }
            else
            {
                dObj->sdState = TASK_STATE_IDLE;
                dObj->cmdDetectState = DRV_SDSPI_CMD_DETECT_CHECK_FOR_CARD;
                cardStatus = DRV_SDSPI_IS_DETACHED;
            }
            break;

        case DRV_SDSPI_CMD_DETECT_CHECK_FOR_DETACH_PROCESS_CID_DATA:

            /* Here the default state of the card is attached */
            cardStatus = DRV_SDSPI_IS_ATTACHED;

            if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_COMPLETE)
            {
                dObj->sdState = TASK_STATE_IDLE;
                if (memcmp(dObj->pCidData, &gDrvSDSPITempCidData[object], _DRV_SDSPI_CID_READ_SIZE - 1) == 0)
                {
                    dObj->cmdDetectState = DRV_SDSPI_CMD_DETECT_CHECK_FOR_DETACH;
                }
                else
                {
                    dObj->cmdDetectState = DRV_SDSPI_CMD_DETECT_CHECK_FOR_CARD;
                    cardStatus = DRV_SDSPI_IS_DETACHED;
                }
            }
            else if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_ERROR)
            {
                dObj->sdState = TASK_STATE_IDLE;
                dObj->cmdDetectState = DRV_SDSPI_CMD_DETECT_CHECK_FOR_CARD;
                cardStatus = DRV_SDSPI_IS_DETACHED;
            }
            break;

        case DRV_SDSPI_CMD_DETECT_IDLE_STATE:

            break;
        default:
            break;
    }

    return cardStatus;
}

static void _DRV_SDSPI_MediaInitialize ( SYS_MODULE_OBJ object )
{
    /* Get the driver object */
    DRV_SDSPI_OBJ *dObj = ( DRV_SDSPI_OBJ* )&gDrvSDSPIObj[object];

    /* Check what state we are in, to decide what to do */
    switch (dObj->mediaInitState)
    {
        case DRV_SDSPI_INIT_CHIP_DESELECT:

            dObj->discCapacity = 0;
            dObj->sdCardType = DRV_SDSPI_MODE_NORMAL;

            /* Keep the chip select high(not selected) to send clock pulses  */
            SYS_PORT_PinSet(dObj->chipSelectPin);

            /* 400kHz. Initialize SPI port to <= 400kHz */
            _DRV_SDSPI_SPISpeedSetup(dObj, _DRV_SDSPI_SPI_INITIAL_SPEED);
            dObj->mediaInitState = DRV_SDSPI_INIT_RAMP_TIME;

            break;

        case DRV_SDSPI_INIT_RAMP_TIME:

            /* Send at least 74 clock pulses with chip select high */
            if (_DRV_SDSPI_SPIWriteWithChipSelectDisabled(dObj, dObj->pClkPulseData,
                        MEDIA_INIT_ARRAY_SIZE) == true)
            {
                /* Check the status of completion in the next state */
                dObj->mediaInitState = DRV_SDSPI_INIT_CHIP_SELECT;
            }
            else
            {
                dObj->mediaInitState = DRV_SDSPI_INIT_ERROR;
            }
            break;

        case DRV_SDSPI_INIT_CHIP_SELECT:
            if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_COMPLETE)
            {
                /* This ensures the CMD0 is sent freshly after CS is asserted low,
                   minimizing risk of SPI clock pulse master/slave synchronization problems,
                   due to possible application noise on the SCK line.
                 */
                dObj->mediaInitState = DRV_SDSPI_INIT_RESET_SDCARD;
            }
            else if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_ERROR)
            {
                dObj->mediaInitState = DRV_SDSPI_INIT_ERROR;
            }
            break;

        case DRV_SDSPI_INIT_RESET_SDCARD:

            /* Send the command (CMD0) to software reset the device  */
            _DRV_SDSPI_CommandSend(object, DRV_SDSPI_GO_IDLE_STATE, 0x00);

            /* Change from this state only on completion of command execution */
            if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_IS_COMPLETE)
            {
                if (dObj->cmdResponse.response1.byte == CMD_R1_END_BIT_SET)
                {
                    dObj->mediaInitState = DRV_SDSPI_INIT_CHK_IFACE_CONDITION;
                }
                else
                {
                    dObj->mediaInitState = DRV_SDSPI_INIT_RAMP_TIME;
                }
            }
            else if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_ERROR)
            {
                dObj->mediaInitState = DRV_SDSPI_INIT_ERROR;
            }
            break;

        case DRV_SDSPI_INIT_CHK_IFACE_CONDITION:

            /* Send CMD8 (SEND_IF_COND) to specify/request the SD card interface
               condition (ex: indicate what voltage the host runs at).
               0x000001AA --> VHS = 0001b = 2.7V to 3.6V.  The 0xAA LSB is the check
               pattern, and is arbitrary, but 0xAA is recommended (good blend of 0's
               and '1's). The SD card has to echo back the check pattern correctly
               however, in the R7 response. If the SD card doesn't support the
               operating voltage range of the host, then it may not respond. If it
               does support the range, it will respond with a type R7 response packet
               (6 bytes/48 bits). Additionally, if the SD card is MMC or SD card
               v1.x spec device, then it may respond with invalid command.  If it is
               a v2.0 spec SD card, then it is mandatory that the card respond to CMD8
             */
            _DRV_SDSPI_CommandSend(object, DRV_SDSPI_SEND_IF_COND, 0x1AA);

            /* Note: CRC value in the table is set for value "0x1AA", it should
               be changed if a different value is passed. */

            /* Change from this state only on completion of command execution */
            if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_IS_COMPLETE)
            {
                if (((dObj->cmdResponse.response7.bytewise.argument.ocrRegister & 0xFFF) == 0x1AA)
                        && (false == dObj->cmdResponse.response7.bitwise.bits.illegalCommand))
                {
                    dObj->sdHcHost = 1;
                }
                else
                {
                    dObj->sdHcHost = 0;
                }

                dObj->mediaInitState = DRV_SDSPI_INIT_READ_OCR_REGISTER;
            }
            else if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_ERROR)
            {
                dObj->mediaInitState = DRV_SDSPI_INIT_ERROR;
            }

            break;

        case DRV_SDSPI_INIT_READ_OCR_REGISTER:
            /*Send CMD58 (Read OCR [operating conditions register]). Response
             * type is R3, which has 5 bytes. Byte 4 = normal R1 response byte,
             * Bytes 3-0 are = OCR register value.
             */
            _DRV_SDSPI_CommandSend (object, DRV_SDSPI_READ_OCR, 0x00);

            /* Change from this state only on completion of command execution */
            if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_IS_COMPLETE)
            {
                dObj->mediaInitState = DRV_SDSPI_INIT_SEND_APP_CMD;
                dObj->timerFlag = false;
            }
            else if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_ERROR)
            {
                dObj->mediaInitState = DRV_SDSPI_INIT_ERROR;
            }
            break;

        case DRV_SDSPI_INIT_SEND_APP_CMD:

            /* Send CMD55 (lets SD card know that the next command is application
               specific (going to be ACMD41)) */
            _DRV_SDSPI_CommandSend(object, DRV_SDSPI_APP_CMD, 0x00);

            /* Change from this state only on completion of command execution */
            if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_IS_COMPLETE)
            {
                dObj->mediaInitState = DRV_SDSPI_INIT_SEND_ACMD41;
            }
            else if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_ERROR)
            {
                dObj->mediaInitState = DRV_SDSPI_INIT_ERROR;

                /* Stop the timer */
                _DRV_SDSPI_TimerStop (dObj);
                dObj->timerFlag = false;
            }

            break;

        case DRV_SDSPI_INIT_SEND_ACMD41:

            /* Send ACMD41.  This is to check if the SD card is finished booting
               up/ready for full frequency and all further commands.  Response is
               R3 type (6 bytes/48 bits, middle four bytes contain potentially useful
               data). */
            /* Note: When sending ACMD41, the HCS bit is bit 30, and must be = 1 to
               tell SD card the host supports SDHC
             */
            _DRV_SDSPI_CommandSend(object, DRV_SDSPI_SD_SEND_OP_COND, dObj->sdHcHost << 30);

            /* Change from this state only on completion of command execution */
            if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_IS_COMPLETE)
            {
                if (dObj->cmdResponse.response1.byte == 0x00)
                {
                    dObj->mediaInitState = DRV_SDSPI_INIT_READ_OCR;

                    /* Stop the timer */
                    _DRV_SDSPI_TimerStop (dObj);
                    dObj->timerFlag = false;
                }
                else
                {
                    if (dObj->timerFlag == false)
                    {
                        if (_DRV_SDSPI_TimerStart(dObj, _DRV_SDSPI_APP_CMD_RESP_TIMEOUT_IN_MS) == false)
                        {
                            dObj->mediaInitState = DRV_SDSPI_INIT_ERROR;
                            break;
                        }
                        dObj->timerFlag = true;
                    }

                    if (dObj->timerExpired == true)
                    {
                        dObj->mediaInitState = DRV_SDSPI_INIT_ERROR;
                        dObj->timerFlag = false;
                    }
                    else
                    {
                        dObj->mediaInitState = DRV_SDSPI_INIT_SEND_APP_CMD;
                    }
                }
            }
            else if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_ERROR)
            {
                /* Stop the timer */
                _DRV_SDSPI_TimerStop (dObj);
                dObj->timerFlag = false;
                dObj->mediaInitState = DRV_SDSPI_INIT_ERROR;
            }

            break;

        case DRV_SDSPI_INIT_READ_OCR:

            /* Now send CMD58(Read OCR register ). The OCR register contains
               important info we will want to know about the card (ex: standard
               capacity vs. SDHC).
             */
            _DRV_SDSPI_CommandSend(object, DRV_SDSPI_READ_OCR, 0x00);

            /* Change from this state only on completion of command execution */
            if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_IS_COMPLETE)
            {
                /* Now check the CCS bit (OCR bit 30) in the OCR register, which
                   is in our response packet. This will tell us if it is a SD high
                   capacity (SDHC) or standard capacity device. */
                /* Note: the HCS bit is only valid when the busy bit is also set
                   (indicating device ready).
                 */
                if (dObj->cmdResponse.response7.bytewise.argument.ocrRegister & 0x40000000)
                {
                    dObj->sdCardType = DRV_SDSPI_MODE_HC;
                }
                else
                {
                    dObj->sdCardType = DRV_SDSPI_MODE_NORMAL;
                }

                /* Card initialization is complete, switch to normal operation */
                dObj->mediaInitState = DRV_SDSPI_INIT_INCR_CLOCK_SPEED;
            }
            else if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_ERROR)
            {
                dObj->mediaInitState = DRV_SDSPI_INIT_ERROR;
            }

            break;

        case DRV_SDSPI_INIT_INCR_CLOCK_SPEED:

            /* Basic initialization of media is now complete.  The card will now
               use push/pull outputs with fast drivers.  Therefore, we can now increase
               SPI speed to either the maximum of the micro-controller or maximum of
               media, whichever is slower.  MMC media is typically good for at least
               20Mbps SPI speeds. SD cards would typically operate at up to 25Mbps
               or higher SPI speeds.
             */
            /* 400kHz. Initialize SPI port to <= 400kHz */
            _DRV_SDSPI_SPISpeedSetup(dObj, dObj->sdcardSpeedHz);

            /* Do a dummy read to ensure that the receiver buffer is cleared */
            _DRV_SDSPI_SPIRead(dObj, dObj->pCmdResp, 10);

            dObj->mediaInitState = DRV_SDSPI_INIT_INCR_CLOCK_SPEED_STATUS;

            break;

        case DRV_SDSPI_INIT_INCR_CLOCK_SPEED_STATUS:

            if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_COMPLETE)
            {
                dObj->mediaInitState = DRV_SDSPI_INIT_READ_CSD;
            }
            else if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_ERROR)
            {
                dObj->mediaInitState = DRV_SDSPI_INIT_ERROR;
            }

            break;

        case DRV_SDSPI_INIT_READ_CSD:

            /* CMD9: Read CSD data structure */
            _DRV_SDSPI_CommandSend (object, DRV_SDSPI_SEND_CSD, 0x00);

            /* Change from this state only on completion of command execution */
            if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_IS_COMPLETE)
            {
                if (dObj->cmdResponse.response1.byte == 0x00)
                {
                    dObj->mediaInitState = DRV_SDSPI_INIT_READ_CSD_DATA;
                }
                else
                {
                    dObj->mediaInitState = DRV_SDSPI_INIT_ERROR;
                }
            }
            else if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_ERROR)
            {
                dObj->mediaInitState = DRV_SDSPI_INIT_ERROR;
            }

            break;

        case DRV_SDSPI_INIT_READ_CSD_DATA:

            /* According to the simplified spec, section 7.2.6, the card will respond
               with a standard response token, followed by a data block of 16 bytes
               suffixed with a 16-bit CRC.
             */
            if (_DRV_SDSPI_SPIRead(dObj, dObj->pCsdData, _DRV_SDSPI_CSD_READ_SIZE) == true)
            {
                dObj->mediaInitState = DRV_SDSPI_INIT_PROCESS_CSD;
            }
            else
            {
                dObj->mediaInitState = DRV_SDSPI_INIT_ERROR;
            }

            break;

        case DRV_SDSPI_INIT_PROCESS_CSD:

            if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_COMPLETE)
            {
                dObj->discCapacity = _DRV_SDSPI_ProcessCSD(dObj->pCsdData);
                dObj->mediaInitState = DRV_SDSPI_INIT_READ_CID;
            }
            else if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_ERROR)
            {
                dObj->mediaInitState = DRV_SDSPI_INIT_ERROR;
            }

            break;

        case DRV_SDSPI_INIT_READ_CID:

            /* CMD10: Read CID data structure */
            _DRV_SDSPI_CommandSend (object, DRV_SDSPI_SEND_CID, 0x00);

            /* Change from this state only on completion of command execution */
            if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_IS_COMPLETE)
            {
                if (dObj->cmdResponse.response1.byte == 0x00)
                {
                    dObj->mediaInitState = DRV_SDSPI_INIT_READ_CID_DATA;
                }
                else
                {
                    dObj->mediaInitState = DRV_SDSPI_INIT_ERROR;
                }
            }
            else if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_ERROR)
            {
                dObj->mediaInitState = DRV_SDSPI_INIT_ERROR;
            }

            break;

        case DRV_SDSPI_INIT_READ_CID_DATA:

            /* According to the simplified spec, section 7.2.6, the card will respond
               with a standard response token, followed by a data block of 16 bytes
               suffixed with a 16-bit CRC.
             */
            if (_DRV_SDSPI_SPIRead(dObj, dObj->pCidData, _DRV_SDSPI_CID_READ_SIZE) == true)
            {
                dObj->mediaInitState = DRV_SDSPI_INIT_PROCESS_CID;
            }
            else
            {
                dObj->mediaInitState = DRV_SDSPI_INIT_ERROR;
            }

            break;

        case DRV_SDSPI_INIT_PROCESS_CID:

            if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_COMPLETE)
            {
                dObj->mediaInitState = DRV_SDSPI_INIT_TURN_OFF_CRC;
            }
            else if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_ERROR)
            {
                dObj->mediaInitState = DRV_SDSPI_INIT_ERROR;
            }

            break;

        case DRV_SDSPI_INIT_TURN_OFF_CRC:

            /* Turn off CRC7 if we can, might be an invalid cmd on some
               cards (CMD59). */
            /* Note: POR default for the media is normally with CRC checking
               off in SPI mode anyway, so this is typically redundant.
             */
            _DRV_SDSPI_CommandSend (object, DRV_SDSPI_CRC_ON_OFF, 0x00);

            /* Change from this state only on completion of command execution */
            if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_IS_COMPLETE)
            {
                dObj->mediaInitState = DRV_SDSPI_INIT_SET_BLOCKLEN;
            }
            else if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_ERROR)
            {
                dObj->mediaInitState = DRV_SDSPI_INIT_ERROR;
            }

            break;

        case DRV_SDSPI_INIT_SET_BLOCKLEN:

            /* Now set the block length to media sector size. It
               should be already set to this. */
            _DRV_SDSPI_CommandSend(object, DRV_SDSPI_SET_BLOCKLEN, _DRV_SDSPI_MEDIA_BLOCK_SIZE);

            /* Change from this state only on completion of command execution */
            if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_IS_COMPLETE)
            {
                dObj->mediaInitState = DRV_SDSPI_INIT_SD_INIT_DONE;
            }
            else if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_ERROR)
            {
                dObj->mediaInitState = DRV_SDSPI_INIT_ERROR;
            }

            break;

        case DRV_SDSPI_INIT_SD_INIT_DONE:
            /* Coming for the first time */
            dObj->mediaInitState = DRV_SDSPI_INIT_CHIP_DESELECT;
            break;

        case DRV_SDSPI_INIT_ERROR:
            dObj->mediaInitState = DRV_SDSPI_INIT_CHIP_DESELECT;
            break;

        default:
            break;
    }
}

static void _DRV_SDSPI_AttachDetachTasks
(
    SYS_MODULE_OBJ object
)
{
    DRV_SDSPI_OBJ* dObj;

    /* Get the driver object */
    dObj = (DRV_SDSPI_OBJ*)&gDrvSDSPIObj[object];

    /* Block other clients/threads from accessing the SD Card */
    if (OSAL_MUTEX_Lock(&dObj->transferMutex, OSAL_WAIT_FOREVER ) != OSAL_RESULT_TRUE)
    {
        return;
    }

    switch ( dObj->taskState )
    {
        case DRV_SDSPI_TASK_START_POLLING_TIMER:
            if (_DRV_SDSPI_CardDetectPollingTimerStart(dObj, dObj->pollingIntervalMs) == true)
            {
                dObj->taskState = DRV_SDSPI_TASK_WAIT_POLLING_TIMER_EXPIRE;
            }
            break;

        case DRV_SDSPI_TASK_WAIT_POLLING_TIMER_EXPIRE:
            if (dObj->cardPollingTimerExpired == true)
            {
                dObj->cardPollingTimerExpired = false;
                dObj->taskState = DRV_SDSPI_TASK_CHECK_DEVICE;
            }
            break;

        case DRV_SDSPI_TASK_CHECK_DEVICE:
            /* Check for device attach */

            dObj->isAttached = (DRV_SDSPI_ATTACH)_DRV_SDSPI_MediaCommandDetect (object);
            if (dObj->isAttachedLastStatus != dObj->isAttached)
            {
                dObj->isAttachedLastStatus = dObj->isAttached;
                /* We should call a function on device attach and detach */
                if (DRV_SDSPI_IS_ATTACHED == dObj->isAttached)
                {
                    /* An SD card seems to be present. Initiate a full card initialization. */
                    dObj->taskState = DRV_SDSPI_TASK_MEDIA_INIT;
                }
                else
                {
                    dObj->taskState = DRV_SDSPI_TASK_START_POLLING_TIMER;
                    dObj->mediaState = SYS_MEDIA_DETACHED;
                    _DRV_SDSPI_RemoveBufferObjects (dObj);
                    /* SD Card seems to have been removed, check for attach */
                    dObj->cmdDetectState = DRV_SDSPI_CMD_DETECT_START_INIT;
                }
            }
            else if (dObj->sdState == TASK_STATE_IDLE)
            {
                dObj->taskState = DRV_SDSPI_TASK_START_POLLING_TIMER;
            }
            break;

        case DRV_SDSPI_TASK_MEDIA_INIT:
            /* Update the card details to the internal data structure */
            _DRV_SDSPI_MediaInitialize (object);

            /* Once the initialization is complete, move to the next stage */
            if (dObj->mediaInitState == DRV_SDSPI_INIT_SD_INIT_DONE)
            {
                /* Check and update the card's write protected status */
                _DRV_SDSPI_CheckWriteProtectStatus (dObj);

                /* Update the Media Geometry structure */
                _DRV_SDSPI_UpdateGeometry (dObj);

                /* State that the device is attached. */
                dObj->mediaState = SYS_MEDIA_ATTACHED;
                dObj->cmdDetectState = DRV_SDSPI_CMD_DETECT_CHECK_FOR_DETACH;
                dObj->taskState = DRV_SDSPI_TASK_START_POLLING_TIMER;
            }
            else if (dObj->mediaInitState == DRV_SDSPI_INIT_ERROR)
            {
                /* The SD card is probably removed. Go back and check for card insertion. */
                dObj->isAttachedLastStatus = dObj->isAttached = DRV_SDSPI_IS_DETACHED;
                dObj->cmdDetectState = DRV_SDSPI_CMD_DETECT_START_INIT;
                dObj->taskState = DRV_SDSPI_TASK_START_POLLING_TIMER;
            }
            break;

        case DRV_SDSPI_TASK_IDLE:
        default:
            break;
    }

    /* Release the Mutex to allow other clients/threads to access the SD Card */
    OSAL_MUTEX_Unlock(&dObj->transferMutex);
}

static void _DRV_SDSPI_BufferIOTasks
(
    SYS_MODULE_OBJ object
)
{
    DRV_SDSPI_OBJ*              dObj;
    DRV_SDSPI_CLIENT_OBJ*       clientObj;
    DRV_SDSPI_BUFFER_OBJ*       currentBufObj;
    DRV_SDSPI_EVENT             evtStatus = DRV_SDSPI_EVENT_COMMAND_COMPLETE;

    /* Get the driver object */
    dObj = (DRV_SDSPI_OBJ*)&gDrvSDSPIObj[object];

    if (OSAL_MUTEX_Lock(&dObj->transferMutex, OSAL_WAIT_FOREVER) != OSAL_RESULT_TRUE)
    {
        SYS_ASSERT(false, "SDSPI Driver: OSAL_MUTEX_Lock failed");
    }

    currentBufObj = _DRV_SDSPI_BufferListGet(dObj);

    /* Check what state we are in, to decide what to do */
    switch (dObj->taskBufferIOState)
    {
        case DRV_SDSPI_BUFFER_IO_CHECK_DEVICE:
            if (dObj->mediaState != SYS_MEDIA_ATTACHED)
            {
                break;
            }

            /* Process reads/writes only if the media is present.
             * Intentional fallthrough.
             */

        case DRV_SDSPI_TASK_PROCESS_QUEUE:

            if (dObj->sdState != TASK_STATE_IDLE)
            {
                break;
            }

            /* Get the first in element from the queue */
            currentBufObj = _DRV_SDSPI_BufferListGet(dObj);
            if (currentBufObj == NULL)
            {
                /* If there are no read queued, check for device attach/detach */
                dObj->taskBufferIOState = DRV_SDSPI_BUFFER_IO_CHECK_DEVICE;
                break;
            }

            dObj->sdState = TASK_STATE_CARD_COMMAND;

            currentBufObj->status = DRV_SDSPI_COMMAND_IN_PROGRESS;

            if (dObj->sdCardType == DRV_SDSPI_MODE_NORMAL)
            {
                currentBufObj->blockStart <<= 9;
            }

            /* Navigate to different cases based on read/write flags */
            if (currentBufObj->opType == DRV_SDSPI_OPERATION_TYPE_READ)
            {
                if (currentBufObj->nBlocks == 1)
                {
                    currentBufObj->command = DRV_SDSPI_READ_SINGLE_BLOCK;
                }
                else
                {
                    currentBufObj->command = DRV_SDSPI_READ_MULTI_BLOCK;
                }

                dObj->taskBufferIOState = DRV_SDSPI_TASK_PROCESS_READ;
            }
            else
            {
                if (currentBufObj->nBlocks == 1)
                {
                    currentBufObj->command = DRV_SDSPI_WRITE_SINGLE_BLOCK;
                }
                else
                {
                    currentBufObj->command = DRV_SDSPI_WRITE_MULTI_BLOCK;
                }

                dObj->taskBufferIOState = DRV_SDSPI_TASK_PROCESS_WRITE;
            }
            break;

        case DRV_SDSPI_TASK_PROCESS_READ:

            /* Note: _DRV_SDSPI_CommandSend() sends 8 SPI clock cycles after
               getting the response. This meets the NAC Min timing parameter, so
               we don't need additional clocking here.
             */
            _DRV_SDSPI_CommandSend (object, (DRV_SDSPI_COMMANDS)currentBufObj->command, currentBufObj->blockStart);
            if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_IS_COMPLETE)
            {
                if (dObj->cmdResponse.response1.byte == 0x00)
                {
                    dObj->timerFlag = false;
                    dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_START_TOKEN;
                }
                else
                {
                    /* Perhaps the card isn't initialized or present */
                    dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_WRITE_ABORT;
                }
            }
            else if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_ERROR)
            {
                dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_WRITE_ABORT;
            }
            break;

        case DRV_SDSPI_TASK_SPI_STATUS:

            if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_COMPLETE)
            {
                dObj->taskBufferIOState = dObj->nextTaskState;
            }
            else if (dObj->spiTransferStatus == DRV_SDSPI_SPI_TRANSFER_STATUS_ERROR)
            {
                dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_WRITE_ABORT;
            }
            break;

        case DRV_SDSPI_TASK_READ_START_TOKEN:

            if (_DRV_SDSPI_SPIRead(dObj, dObj->pCmdResp, 1) == true)
            {
                dObj->nextTaskState = DRV_SDSPI_TASK_READ_START_TOKEN_STATUS;
                dObj->taskBufferIOState = DRV_SDSPI_TASK_SPI_STATUS;
            }
            else
            {
                dObj->timerFlag = false;
                dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_WRITE_ABORT;
            }
            break;

        case DRV_SDSPI_TASK_READ_START_TOKEN_STATUS:

            /* In this case, we have already issued the READ_MULTI_BLOCK command
               to the media, and we need to keep polling the media until it sends
               us the data start token byte. This could typically take a
               couple of milliseconds, up to a maximum of 100ms.
               */
            if (dObj->pCmdResp[0] == DRV_SDSPI_DATA_START_TOKEN)
            {
                dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_DATA;
                /* Received the start token. Stop the timer */
                _DRV_SDSPI_TimerStop(dObj);
                dObj->timerFlag = false;
            }
            else
            {
                if (dObj->timerFlag == false)
                {
                    /* Kick start a timer with 100ms as the timeout value.
                     * If the start token is not received when the timer
                     * fires then fail the operation. */
                    if (_DRV_SDSPI_TimerStart(dObj, _DRV_SDSPI_READ_TIMEOUT_IN_MS) == false)
                    {
                        dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_WRITE_ABORT;
                        break;
                    }
                    dObj->timerFlag = true;
                }

                if (dObj->timerExpired == true)
                {
                    dObj->timerFlag = false;
                    /* Abort the read operation as the card has failed to send the start token. */
                    dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_WRITE_ABORT;
                }
                else
                {
                    dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_START_TOKEN;
                }
            }
            break;

        case DRV_SDSPI_TASK_READ_DATA:

            if (_DRV_SDSPI_SPIRead(dObj, currentBufObj->buffer, _DRV_SDSPI_MEDIA_BLOCK_SIZE) == true)
            {
                dObj->nextTaskState = DRV_SDSPI_TASK_READ_CRC_BYTES;
                dObj->taskBufferIOState = DRV_SDSPI_TASK_SPI_STATUS;
            }
            else
            {
                dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_WRITE_ABORT;
            }
            break;

        case DRV_SDSPI_TASK_READ_CRC_BYTES:

            /* Read 2 bytes of CRC data. In SPI mode of operation the CRC
             * data is ignored. */
            if (_DRV_SDSPI_SPIRead(dObj, dObj->pCmdResp, 2) == true)
            {
                dObj->nextTaskState = DRV_SDSPI_TASK_READ_COMPLETE_CHECK;
                dObj->taskBufferIOState = DRV_SDSPI_TASK_SPI_STATUS;
            }
            else
            {
                dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_WRITE_ABORT;
            }
            break;

        case DRV_SDSPI_TASK_READ_COMPLETE_CHECK:

            if (currentBufObj->command == DRV_SDSPI_READ_MULTI_BLOCK)
            {
                currentBufObj->nBlocks--;
                if (currentBufObj->nBlocks == 0)
                {
                    dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_STOP_TRANSMISSION;
                }
                else
                {
                    currentBufObj->buffer += _DRV_SDSPI_MEDIA_BLOCK_SIZE;
                    dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_START_TOKEN;
                }
            }
            else
            {
                dObj->taskBufferIOState = DRV_SDSPI_TASK_SEND_DUMMY_CLOCK_PULSES;
            }
            break;

        case DRV_SDSPI_TASK_SEND_DUMMY_CLOCK_PULSES:

            /* Send 8 clock pulses */
            if (_DRV_SDSPI_SPIRead(dObj, dObj->pCmdResp, 1) == true)
            {
                dObj->nextTaskState = DRV_SDSPI_TASK_PROCESS_NEXT;
                dObj->taskBufferIOState = DRV_SDSPI_TASK_SPI_STATUS;
            }
            else
            {
                dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_WRITE_ABORT;
            }
            break;

        case DRV_SDSPI_TASK_READ_STOP_TRANSMISSION:

            _DRV_SDSPI_CommandSend (object, DRV_SDSPI_STOP_TRANSMISSION, 0);
            if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_IS_COMPLETE)
            {
                dObj->taskBufferIOState = DRV_SDSPI_TASK_SEND_DUMMY_CLOCK_PULSES;
            }
            else if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_ERROR)
            {
                dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_WRITE_ABORT;
            }
            break;

        case DRV_SDSPI_TASK_PROCESS_WRITE:

            /* Send the write single or write multi command, with the LBA or byte
               address (depending upon SDHC or standard capacity card) */
            _DRV_SDSPI_CommandSend (object, (DRV_SDSPI_COMMANDS)currentBufObj->command, currentBufObj->blockStart);
            if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_IS_COMPLETE)
            {
                if (dObj->cmdResponse.response1.byte == 0x00)
                {
                    dObj->taskBufferIOState = DRV_SDSPI_TASK_WRITE_START_TOKEN;
                }
                else
                {
                    dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_WRITE_ABORT;
                }
            }
            else if (dObj->cmdState == DRV_SDSPI_CMD_EXEC_ERROR)
            {
                dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_WRITE_ABORT;
            }
            break;

        case DRV_SDSPI_TASK_WRITE_START_TOKEN:

            if (currentBufObj->command == DRV_SDSPI_WRITE_MULTI_BLOCK)
            {
                dObj->pCmdResp[0] = DRV_SDSPI_DATA_START_MULTI_BLOCK_TOKEN;
            }
            else
            {
                dObj->pCmdResp[0] = DRV_SDSPI_DATA_START_TOKEN;
            }

            if (_DRV_SDSPI_SPIWrite(dObj, dObj->pCmdResp, 1) == true)
            {
                dObj->nextTaskState = DRV_SDSPI_TASK_WRITE_DATA;
                dObj->taskBufferIOState = DRV_SDSPI_TASK_SPI_STATUS;
            }
            else
            {
                dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_WRITE_ABORT;
            }
            break;


        case DRV_SDSPI_TASK_WRITE_DATA:

            if (_DRV_SDSPI_SPIWrite(dObj, currentBufObj->buffer, 512) == true)
            {
                dObj->nextTaskState = DRV_SDSPI_TASK_WRITE_CRC_BYTES;
                dObj->taskBufferIOState = DRV_SDSPI_TASK_SPI_STATUS;
            }
            else
            {
                dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_WRITE_ABORT;
            }
            break;


        case DRV_SDSPI_TASK_WRITE_CRC_BYTES:

            /* Send 16-bit dummy CRC for the data block that was just sent. */
            if (_DRV_SDSPI_SPIWrite(dObj, dObj->pClkPulseData, 2) == true)
            {
                dObj->nextTaskState = DRV_SDSPI_TASK_WRITE_READ_RESP_TOKEN;
                dObj->taskBufferIOState = DRV_SDSPI_TASK_SPI_STATUS;
            }
            else
            {
                dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_WRITE_ABORT;
            }
            break;

        case DRV_SDSPI_TASK_WRITE_READ_RESP_TOKEN:

            if (_DRV_SDSPI_SPIRead(dObj, dObj->pCmdResp , 1) == true)
            {
                dObj->nextTaskState = DRV_SDSPI_TASK_WRITE_RESP_TOKEN_STATUS;
                dObj->taskBufferIOState = DRV_SDSPI_TASK_SPI_STATUS;
            }
            else
            {
                dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_WRITE_ABORT;
            }
            break;

        case DRV_SDSPI_TASK_WRITE_RESP_TOKEN_STATUS:

            /* Read response token byte from media, mask out top three
             * don't care bits, and check if there was an error */
            if ((dObj->pCmdResp[0] & DRV_SDSPI_WRITE_RESPONSE_TOKEN_MASK) != DRV_SDSPI_DATA_ACCEPTED)
            {
                /* Something went wrong. */
                dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_WRITE_ABORT;
            }
            else
            {
                dObj->taskBufferIOState = DRV_SDSPI_TASK_WRITE_CHECK_BUSY;
                dObj->timerFlag = false;
            }
            break;

        case DRV_SDSPI_TASK_WRITE_CHECK_BUSY:

            /* The media will now send busy token (0x00) bytes until it is
             * internally ready again (after the block is successfully
             * written and the card is ready to accept a new block). */
            if (_DRV_SDSPI_SPIRead(dObj, dObj->pCmdResp, 1) == true)
            {
                dObj->nextTaskState = DRV_SDSPI_TASK_WRITE_CHECK_BUSY_STATUS;
                dObj->taskBufferIOState = DRV_SDSPI_TASK_SPI_STATUS;
            }
            else
            {
                dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_WRITE_ABORT;
            }
            break;

        case DRV_SDSPI_TASK_WRITE_CHECK_BUSY_STATUS:

            if (dObj->pCmdResp[0] == 0x00)
            {
                /* The media is still busy writing data. Kick start a timer
                 * with 250ms as the timeout value. If the card is still
                 * busy at the end of the timeout then abort the operation.
                 * */
                if (dObj->timerFlag == false)
                {
                    if (_DRV_SDSPI_TimerStart(dObj, _DRV_SDSPI_WRITE_TIMEOUT_IN_MS) == false)
                    {
                        dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_WRITE_ABORT;
                        break;
                    }
                    dObj->timerFlag = true;
                }

                if (dObj->timerExpired == true)
                {
                    dObj->timerFlag = false;
                    /* Abort the write operation as the card has failed to complete the operation
                       in time. */
                    dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_WRITE_ABORT;
                }
                else
                {
                    dObj->taskBufferIOState = DRV_SDSPI_TASK_WRITE_CHECK_BUSY;
                }
            }
            else
            {
                /* The card is out of the busy state. Stop the timer */
                _DRV_SDSPI_TimerStop(dObj);
                dObj->timerFlag = false;
                dObj->taskBufferIOState = DRV_SDSPI_TASK_WRITE_COMPLETE_CHECK;
            }
            break;

        case DRV_SDSPI_TASK_WRITE_COMPLETE_CHECK:

            /* The media is done and is no longer busy. Go ahead and
               either send the next packet of data to the media, or the stop
               token if we are finished.
               */
            if (currentBufObj->command == DRV_SDSPI_WRITE_MULTI_BLOCK)
            {
                currentBufObj->nBlocks --;
                if (currentBufObj->nBlocks == 0)
                {
                    dObj->taskBufferIOState = DRV_SDSPI_TASK_WRITE_STOP_TRAN_TOKEN;
                }
                else
                {
                    currentBufObj->buffer += _DRV_SDSPI_MEDIA_BLOCK_SIZE;
                    dObj->taskBufferIOState = DRV_SDSPI_TASK_WRITE_START_TOKEN;
                }
            }
            else
            {
                /* Send eight clock pulses */
                dObj->taskBufferIOState = DRV_SDSPI_TASK_SEND_DUMMY_CLOCK_PULSES;
            }
            break;

        case DRV_SDSPI_TASK_WRITE_STOP_TRAN_TOKEN:

            dObj->pCmdResp[0] = DRV_SDSPI_DATA_STOP_TRAN_TOKEN;
            if (_DRV_SDSPI_SPIWrite(dObj, dObj->pCmdResp, 1) == true)
            {
                dObj->nextTaskState = DRV_SDSPI_TASK_WRITE_STOP_TRAN_DUMMY_PULSES;
                dObj->taskBufferIOState = DRV_SDSPI_TASK_SPI_STATUS;
                dObj->timerFlag = false;
            }
            else
            {
                dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_WRITE_ABORT;
            }
            break;

        case DRV_SDSPI_TASK_WRITE_STOP_TRAN_DUMMY_PULSES:

            if (_DRV_SDSPI_SPIRead(dObj, dObj->pCmdResp, 1) == true)
            {
                dObj->nextTaskState = DRV_SDSPI_TASK_WRITE_STOP_TRAN_CHECK_BUSY;
                dObj->taskBufferIOState = DRV_SDSPI_TASK_SPI_STATUS;
            }
            else
            {
                dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_WRITE_ABORT;
            }
            break;

        case DRV_SDSPI_TASK_WRITE_STOP_TRAN_CHECK_BUSY:

            /* The media will now send busy token (0x00) bytes until it is
             * internally ready again (after the block is successfully
             * written and the card is ready to accept a new block). */
            if (_DRV_SDSPI_SPIRead(dObj, dObj->pCmdResp, 1) == true)
            {
                dObj->nextTaskState = DRV_SDSPI_TASK_WRITE_STOP_TRAN_BUSY_STATUS;
                dObj->taskBufferIOState = DRV_SDSPI_TASK_SPI_STATUS;
            }
            else
            {
                dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_WRITE_ABORT;
            }
            break;

        case DRV_SDSPI_TASK_WRITE_STOP_TRAN_BUSY_STATUS:

            if (dObj->pCmdResp[0] == 0x00)
            {
                /* Kick start a timer with 250ms as the timeout value. If
                 * the card is still busy at the end of the timeout then
                 * abort the operation.  */
                if (dObj->timerFlag == false)
                {
                    if (_DRV_SDSPI_TimerStart(dObj, _DRV_SDSPI_WRITE_TIMEOUT_IN_MS) == false)
                    {
                        dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_WRITE_ABORT;
                        break;
                    }
                    dObj->timerFlag = true;
                }

                if (dObj->timerExpired == true)
                {
                    dObj->timerFlag = false;
                    /* Abort the write operation as the card has failed to complete the operation
                       in time. */
                    dObj->taskBufferIOState = DRV_SDSPI_TASK_READ_WRITE_ABORT;
                }
                else
                {
                    dObj->taskBufferIOState = DRV_SDSPI_TASK_WRITE_STOP_TRAN_CHECK_BUSY;
                }
            }
            else
            {
                /* The card is out of the busy state. Stop the timer */
                _DRV_SDSPI_TimerStop(dObj);
                dObj->timerFlag = false;
                dObj->taskBufferIOState = DRV_SDSPI_TASK_PROCESS_NEXT;
            }
            break;

        case DRV_SDSPI_TASK_READ_WRITE_ABORT:
            /* Reset any of the error flags. */
        case DRV_SDSPI_TASK_PROCESS_NEXT:

            if (dObj->taskBufferIOState == DRV_SDSPI_TASK_PROCESS_NEXT)
            {
                currentBufObj->status = DRV_SDSPI_COMMAND_COMPLETED;
                evtStatus = DRV_SDSPI_EVENT_COMMAND_COMPLETE;
            }
            else
            {
                currentBufObj->status = DRV_SDSPI_COMMAND_ERROR_UNKNOWN;
                evtStatus = DRV_SDSPI_EVENT_COMMAND_ERROR;
            }

            /* Get the client object that owns this buffer */
            clientObj = &((DRV_SDSPI_CLIENT_OBJ *)dObj->clientObjPool)[currentBufObj->clientHandle & _DRV_SDSPI_INDEX_MASK];
            if(clientObj->eventHandler != NULL)
            {
                /* Call the event handler */
                clientObj->eventHandler((SYS_MEDIA_BLOCK_EVENT)evtStatus,
                        (DRV_SDSPI_COMMAND_HANDLE)currentBufObj->commandHandle, clientObj->context);
            }

            /* Free the completed buffer */
            _DRV_SDSPI_RemoveBufferObjFromList(dObj);

            dObj->sdState = TASK_STATE_IDLE;
            dObj->taskBufferIOState = DRV_SDSPI_BUFFER_IO_CHECK_DEVICE;
            break;
    }

    if (OSAL_MUTEX_Unlock(&dObj->transferMutex) != OSAL_RESULT_TRUE)
    {
        SYS_ASSERT(false, "SDCard Driver: OSAL_MUTEX_Unlock failed");
    }
}

// *****************************************************************************
// *****************************************************************************
// Section: Driver Interface Function Definitions
// *****************************************************************************
// *****************************************************************************

__WEAK void DRV_SDSPI_RegisterWithSysFs
(
    const SYS_MODULE_INDEX drvIndex
)
{
    /* Weak function to avoid compiler warning when registration with FS is
     * not enabled. */
}

SYS_MODULE_OBJ DRV_SDSPI_Initialize
(
    const SYS_MODULE_INDEX drvIndex,
    const SYS_MODULE_INIT  * const init
)
{
    const DRV_SDSPI_INIT* sdSPIInit = (const DRV_SDSPI_INIT *)init;
    DRV_SDSPI_OBJ* dObj = NULL;
    uint32_t i;

    /* Validate the request */
    if(drvIndex >= DRV_SDSPI_INSTANCES_NUMBER)
    {
        return SYS_MODULE_OBJ_INVALID;
    }

    dObj = &gDrvSDSPIObj[drvIndex];

    if(dObj->inUse == true)
    {
        return SYS_MODULE_OBJ_INVALID;
    }

    /* Initialize the driver object's structure members */
    memset (dObj, 0, sizeof(DRV_SDSPI_OBJ));

    if (OSAL_MUTEX_Create(&dObj->transferMutex) == OSAL_RESULT_FALSE)
    {
        /* If the mutex was not created because the memory required to
        hold the mutex could not be allocated then NULL is returned. */
        return SYS_MODULE_OBJ_INVALID;
    }

    if (OSAL_MUTEX_Create(&dObj->clientMutex) == OSAL_RESULT_FALSE)
    {
        /* If the mutex was not created because the memory required to
        hold the mutex could not be allocated then NULL is returned. */
        return SYS_MODULE_OBJ_INVALID;
    }

    dObj->status                = SYS_STATUS_UNINITIALIZED;
    dObj->inUse                 = true;
    dObj->nClients              = 0;
    dObj->numClients            = sdSPIInit->numClients;
    dObj->bufferObjPool         = sdSPIInit->bufferObjPool;
    dObj->bufferObjPoolSize     = sdSPIInit->bufferObjPoolSize;
    dObj->clientObjPool         = sdSPIInit->clientObjPool;
    dObj->bufferObjList         = (uintptr_t)NULL;
    dObj->spiPlib               = sdSPIInit->spiPlib;
    dObj->remapClockPhase       = sdSPIInit->remapClockPhase;
    dObj->remapClockPolarity    = sdSPIInit->remapClockPolarity;
    dObj->remapDataBits         = sdSPIInit->remapDataBits;
    dObj->rxDMAChannel          = sdSPIInit->rxDMAChannel;
    dObj->txDMAChannel          = sdSPIInit->txDMAChannel;
    dObj->txAddress             = sdSPIInit->txAddress;
    dObj->rxAddress             = sdSPIInit->rxAddress;
    dObj->writeProtectPin       = sdSPIInit->writeProtectPin;
    dObj->chipSelectPin         = sdSPIInit->chipSelectPin;
    dObj->sdcardSpeedHz         = sdSPIInit->sdcardSpeedHz;
    dObj->pollingIntervalMs     = sdSPIInit->pollingIntervalMs;
    dObj->sdspiTokenCount       = 1;

    /* Reset the SDSPI attach/detach variables */
    dObj->isAttached            = DRV_SDSPI_IS_DETACHED;
    dObj->isAttachedLastStatus  = DRV_SDSPI_IS_DETACHED;
    dObj->mediaState            = SYS_MEDIA_DETACHED;

    dObj->taskState             = DRV_SDSPI_TASK_START_POLLING_TIMER;
    dObj->cmdDetectState        = DRV_SDSPI_CMD_DETECT_START_INIT;
    dObj->mediaInitState        = DRV_SDSPI_INIT_CHIP_DESELECT;
    dObj->spiTransferStatus     = DRV_SDSPI_SPI_TRANSFER_STATUS_COMPLETE;

    /* Set up the pointers */
    dObj->pCmdResp              = &gDrvSDSPICmdResponseBuffer[drvIndex][0];
    dObj->pCsdData              = &gDrvSDSPICsdData[drvIndex][0];
    dObj->pCidData              = &gDrvSDSPICidData[drvIndex][0];
    dObj->pClkPulseData         = &gDrvSDSPIClkPulseData[drvIndex][0];

    for (i = 0; i < MEDIA_INIT_ARRAY_SIZE; i++)
    {
        dObj->pClkPulseData[i] = 0xFF;
    }

    /* Each driver instance points to the common dummy data array. */
    dObj->txDummyData            = txCommonDummyData;

    for (i = 0; i < sizeof(txCommonDummyData); i++)
    {
        txCommonDummyData[i] = 0xFF;
    }

    /* Register call-backs with the DMA System Service */
    if (dObj->txDMAChannel != SYS_DMA_CHANNEL_NONE && dObj->rxDMAChannel != SYS_DMA_CHANNEL_NONE)
    {

        SYS_DMA_ChannelCallbackRegister(dObj->txDMAChannel, _DRV_SDSPI_TX_DMA_CallbackHandler, (uintptr_t)dObj);
        SYS_DMA_ChannelCallbackRegister(dObj->rxDMAChannel, _DRV_SDSPI_RX_DMA_CallbackHandler, (uintptr_t)dObj);
    }
    else
    {
        /* Register call-back with the SPI PLIB */
        dObj->spiPlib->callbackRegister(_DRV_SDSPI_SPIPlibCallbackHandler, (uintptr_t)dObj);
    }

    /* Register with file system*/
    if (sdSPIInit->isFsEnabled == true)
    {
        DRV_SDSPI_RegisterWithSysFs(drvIndex);
    }

    /* Update the status */
    dObj->status = SYS_STATUS_READY;

    /* Return the object structure */
    return ( (SYS_MODULE_OBJ)drvIndex );
}

SYS_STATUS DRV_SDSPI_Status (
    SYS_MODULE_OBJ object
)
{
    /* Validate the request */
    if( (object == SYS_MODULE_OBJ_INVALID) || (object >= DRV_SDSPI_INSTANCES_NUMBER) )
    {
        return SYS_STATUS_UNINITIALIZED;
    }

    return (gDrvSDSPIObj[object].status);
}

void DRV_SDSPI_Tasks
(
    SYS_MODULE_OBJ object
)
{
    _DRV_SDSPI_AttachDetachTasks (object);
    _DRV_SDSPI_BufferIOTasks (object);
}

DRV_HANDLE DRV_SDSPI_Open
(
    const SYS_MODULE_INDEX drvIndex,
    const DRV_IO_INTENT ioIntent
)
{
    uint32_t iClient;
    DRV_SDSPI_CLIENT_OBJ* clientObj = NULL;
    DRV_SDSPI_OBJ* dObj = NULL;

    /* Validate the request */
    if (drvIndex >= DRV_SDSPI_INSTANCES_NUMBER)
    {
        return DRV_HANDLE_INVALID;
    }

    /* Allocate the driver object and set the operation flag to be in use */
    dObj = (DRV_SDSPI_OBJ*)&gDrvSDSPIObj[drvIndex];

    if(dObj->status != SYS_STATUS_READY)
    {
        return DRV_HANDLE_INVALID;
    }

    /* Acquire the instance specific mutex to protect the instance specific
     * client pool */
    if (OSAL_MUTEX_Lock(&dObj->clientMutex , OSAL_WAIT_FOREVER ) == OSAL_RESULT_FALSE)
    {
        return DRV_HANDLE_INVALID;
    }

    /* Flag error if max number of clients are already open.
     * Flag error if driver was already opened exclusively.
     * Flag error if the client is trying to open the driver exclusively
     * when it is already open by other clients in non-exclusive mode.
     * */
    if((dObj->inUse == false) ||
       (dObj->isExclusive == true) ||
       (dObj->nClients >= dObj->numClients) ||
       ((dObj->nClients > 0) && (ioIntent & DRV_IO_INTENT_EXCLUSIVE)))
    {
        OSAL_MUTEX_Unlock( &dObj->clientMutex);
        return DRV_HANDLE_INVALID;
    }

    for(iClient = 0; iClient != dObj->numClients; iClient++)
    {
        if(((DRV_SDSPI_CLIENT_OBJ *)dObj->clientObjPool)[iClient].inUse == false)
        {
            /* This means we have a free client object to use */

            clientObj = &((DRV_SDSPI_CLIENT_OBJ *)dObj->clientObjPool)[iClient];
            clientObj->inUse        = true;
            clientObj->context      = 0;
            clientObj->intent       = ioIntent;
            clientObj->drvIndex     = drvIndex;

            if(ioIntent & DRV_IO_INTENT_EXCLUSIVE)
            {
                /* Set the driver exclusive flag */
                dObj->isExclusive = true;
            }

            dObj->nClients++;

            /* Generate and save the client handle in the client object, which will
             * be then used to verify the validity of the client handle.
             */
            clientObj->clientHandle = (DRV_HANDLE)_DRV_SDSPI_MAKE_HANDLE(dObj->sdspiTokenCount,
                    (uint8_t)drvIndex, iClient);

            /* Increment the instance specific token counter */
            dObj->sdspiTokenCount = _DRV_SDSPI_UPDATE_TOKEN(dObj->sdspiTokenCount);
            break;
        }
    }

    OSAL_MUTEX_Unlock(&dObj->clientMutex);

    /* Driver index is the handle */
    return clientObj ? ((DRV_HANDLE)clientObj->clientHandle) : DRV_HANDLE_INVALID;
}

void DRV_SDSPI_Close (
    DRV_HANDLE handle
)
{
    DRV_SDSPI_OBJ* dObj = NULL;
    DRV_SDSPI_CLIENT_OBJ* clientObj = NULL;

    clientObj = _DRV_SDSPI_DriverHandleValidate(handle);
    if (clientObj == NULL)
    {
        return;
    }

    dObj = (DRV_SDSPI_OBJ* )&gDrvSDSPIObj[clientObj->drvIndex];

    /* Guard against multiple threads trying to open/close the driver */
    if (OSAL_MUTEX_Lock(&dObj->clientMutex , OSAL_WAIT_FOREVER ) == OSAL_RESULT_FALSE)
    {
        return;
    }

    _DRV_SDSPI_RemoveClientBuffersFromList (dObj, clientObj);

    /* Reduce the number of clients */
    dObj->nClients --;

    /* Reset the exclusive flag */
    dObj->isExclusive = false;

    /* Free the client object */
    clientObj->inUse = false;

    OSAL_MUTEX_Unlock(&dObj->clientMutex);
}

void DRV_SDSPI_SetupXfer(
    const DRV_HANDLE handle,
    DRV_SDSPI_COMMAND_HANDLE* commandHandle,
    void* buffer,
    uint32_t blockStart,
    uint32_t nBlocks,
    DRV_SDSPI_OPERATION_TYPE opType
)
{
    DRV_SDSPI_CLIENT_OBJ* clientObj = NULL;
    DRV_SDSPI_BUFFER_OBJ* bufferObj = NULL;
    DRV_SDSPI_OBJ* dObj = NULL;

    if (commandHandle)
    {
        *commandHandle = DRV_SDSPI_COMMAND_HANDLE_INVALID;
    }
    if ((buffer == NULL) || (nBlocks == 0))
    {
        return;
    }

    clientObj = _DRV_SDSPI_DriverHandleValidate(handle);

    if (clientObj == NULL)
    {
        return;
    }

    dObj = (DRV_SDSPI_OBJ* )&gDrvSDSPIObj[clientObj->drvIndex];

    if (dObj->mediaState != SYS_MEDIA_ATTACHED)
    {
        return;
    }

    if (opType == DRV_SDSPI_OPERATION_TYPE_READ)
    {
        if (!(clientObj->intent & DRV_IO_INTENT_READ))
        {
            return;
        }
        if (((blockStart + nBlocks) > dObj->mediaGeometryTable[SYS_MEDIA_GEOMETRY_TABLE_READ_ENTRY].numBlocks))
        {
            return;
        }
    }
    else
    {
        if (!(clientObj->intent & DRV_IO_INTENT_WRITE))
        {
            return;
        }
        if (((blockStart + nBlocks) > dObj->mediaGeometryTable[SYS_MEDIA_GEOMETRY_TABLE_WRITE_ENTRY].numBlocks))
        {
            return;
        }
        /* Return error if the card is write protected */
        if (dObj->isWriteProtected)
        {
            return;
        }
    }

    if (OSAL_MUTEX_Lock(&dObj->transferMutex, OSAL_WAIT_FOREVER) != OSAL_RESULT_TRUE)
    {
        return;
    }

    bufferObj = _DRV_SDSPI_FreeBufferObjectGet(clientObj);

    if (bufferObj != NULL)
    {
        bufferObj->clientHandle  = handle;
        bufferObj->buffer        = buffer;
        bufferObj->blockStart    = blockStart;
        bufferObj->nBlocks       = nBlocks;
        bufferObj->opType        = opType;
        bufferObj->status        = DRV_SDSPI_COMMAND_QUEUED;

        if (commandHandle)
        {
            *commandHandle = bufferObj->commandHandle;
        }
        /* Add the buffer object to the linked list */
        _DRV_SDSPI_BufferObjectAddToList (dObj, bufferObj);
    }

    OSAL_MUTEX_Unlock(&dObj->transferMutex);
}

void DRV_SDSPI_AsyncRead
(
    const DRV_HANDLE handle,
    DRV_SDSPI_COMMAND_HANDLE* commandHandle,
    void* targetBuffer,
    uint32_t blockStart,
    uint32_t nBlocks
)
{
    DRV_SDSPI_SetupXfer(
        handle,
        commandHandle,
        targetBuffer,
        blockStart,
        nBlocks,
        DRV_SDSPI_OPERATION_TYPE_READ
    );
}

void DRV_SDSPI_AsyncWrite
(
    const DRV_HANDLE handle,
    DRV_SDSPI_COMMAND_HANDLE* commandHandle,
    void* sourceBuffer,
    uint32_t blockStart,
    uint32_t nBlocks
)
{
    DRV_SDSPI_SetupXfer(
        handle,
        commandHandle,
        sourceBuffer,
        blockStart,
        nBlocks,
        DRV_SDSPI_OPERATION_TYPE_WRITE
    );
}

DRV_SDSPI_COMMAND_STATUS DRV_SDSPI_CommandStatusGet (
    const DRV_HANDLE handle,
    const DRV_SDSPI_COMMAND_HANDLE commandHandle
)
{
    DRV_SDSPI_CLIENT_OBJ* clientObj;
    DRV_SDSPI_BUFFER_OBJ* bufferPool;
    DRV_SDSPI_OBJ* dObj;
    uint32_t bufferIndex;

    clientObj = _DRV_SDSPI_DriverHandleValidate (handle);

    if ((clientObj == NULL) || (commandHandle == DRV_SDSPI_COMMAND_HANDLE_INVALID))
    {
        return DRV_SDSPI_COMMAND_ERROR_UNKNOWN;
    }

    dObj = (DRV_SDSPI_OBJ* )&gDrvSDSPIObj[clientObj->drvIndex];

    bufferPool = (DRV_SDSPI_BUFFER_OBJ*)dObj->bufferObjPool;
    bufferIndex = commandHandle & _DRV_SDSPI_INDEX_MASK;

    if (bufferIndex >= dObj->bufferObjPoolSize)
    {
        return DRV_SDSPI_COMMAND_ERROR_UNKNOWN;
    }

    /* Check if the buffer object is still valid */
    if (bufferPool[bufferIndex].commandHandle == commandHandle)
    {
        /* Return the last known buffer object status */
        return bufferPool[bufferIndex].status;
    }
    else
    {
        /* This means that object has been re-used by another request. Indicate
         * that the operation is completed.  */
        return (DRV_SDSPI_COMMAND_COMPLETED);
    }
}

SYS_MEDIA_GEOMETRY* DRV_SDSPI_GeometryGet (
    const DRV_HANDLE handle
)
{
    DRV_SDSPI_CLIENT_OBJ* clientObj = NULL;
    DRV_SDSPI_OBJ* dObj = NULL;
    SYS_MEDIA_GEOMETRY* mediaGeometryObj = NULL;

    clientObj = _DRV_SDSPI_DriverHandleValidate (handle);

    if (clientObj != NULL)
    {
        dObj = (DRV_SDSPI_OBJ* )&gDrvSDSPIObj[clientObj->drvIndex];
        mediaGeometryObj = &dObj->mediaGeometryObj;
    }

    return mediaGeometryObj;
}

void DRV_SDSPI_EventHandlerSet (
    const DRV_HANDLE handle,
    const void* eventHandler,
    const uintptr_t context
)
{
    DRV_SDSPI_CLIENT_OBJ* clientObj = NULL;

    clientObj = _DRV_SDSPI_DriverHandleValidate (handle);

    if (clientObj != NULL)
    {
        /* Set the event handler */
        clientObj->eventHandler = (DRV_SDSPI_EVENT_HANDLER)eventHandler;
        clientObj->context = context;
    }
}

bool DRV_SDSPI_IsAttached (
    const DRV_HANDLE handle
)
{
    DRV_SDSPI_CLIENT_OBJ* clientObj = NULL;
    DRV_SDSPI_OBJ* dObj = NULL;
    bool isAttached = false;

    clientObj = _DRV_SDSPI_DriverHandleValidate (handle);

    if (clientObj != NULL)
    {
        dObj = (DRV_SDSPI_OBJ* )&gDrvSDSPIObj[clientObj->drvIndex];

        if (dObj->mediaState == SYS_MEDIA_ATTACHED)
        {
            isAttached = true;
        }
    }

    return isAttached;
}

bool DRV_SDSPI_IsWriteProtected( const DRV_HANDLE handle )
{
    DRV_SDSPI_CLIENT_OBJ* clientObj;
    DRV_SDSPI_OBJ* dObj;

    clientObj = _DRV_SDSPI_DriverHandleValidate (handle);
    if (clientObj == NULL)
        return false;

    dObj = (DRV_SDSPI_OBJ*)&gDrvSDSPIObj[clientObj->drvIndex];

    if (dObj->mediaState == SYS_MEDIA_DETACHED)
    {
        return false;
    }

    return dObj->isWriteProtected;
}
