/*******************************************************************************
  SD Card (SPI) Driver Local Data Structures

  Company:
    Microchip Technology Inc.

  File Name:
    drv_sdspi_local.h

  Summary:
    SD Card (SPI) Driver local declarations, structures and function prototypes.

  Description:
    This file contains the SD Card (SPI) Driver's local declarations and definitions.
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

#ifndef _DRV_SDSPI_LOCAL_H
#define _DRV_SDSPI_LOCAL_H


// *****************************************************************************
// *****************************************************************************
// Section: File includes
// *****************************************************************************
// *****************************************************************************

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

#include "configuration.h"
#include "system/dma/sys_dma.h"
#include "driver/sdspi/drv_sdspi.h"
#include "osal/osal.h"

// *****************************************************************************
// *****************************************************************************
// Section: Helper Macros
// *****************************************************************************
// *****************************************************************************
/* Helper macros for the driver */


// *****************************************************************************
/* SDCARD Driver Buffer Handle Macros

  Summary:
    SDCARD driver Buffer Handle Macros

  Description:
    Buffer handle related utility macros. SDCARD driver buffer handle is a
    combination of buffer token and the buffer object index. The buffertoken
    is a 16 bit number that is incremented for every new write or erase request
    and is used along with the buffer object index to generate a new buffer
    handle for every request.

  Remarks:
    None
*/

#define _DRV_SDSPI_INDEX_MASK                   (0x000000FF)
#define _DRV_SDSPI_INSTANCE_MASK                (0x0000FF00)
#define _DRV_SDSPI_TOKEN_MAX                    (0xFFFF)

#define _DRV_SDSPI_FLOATING_BUS_TIMEOUT            (1000)
#define _DRV_SDSPI_R1B_RESP_TIMEOUT                (100)

#define _DRV_SDSPI_READ_TIMEOUT_IN_MS              (250)
#define _DRV_SDSPI_WRITE_TIMEOUT_IN_MS             (250)

#define _DRV_SDSPI_APP_CMD_RESP_TIMEOUT_IN_MS      (1000)
#define _DRV_SDSPI_CSD_TOKEN_TIMEOUT_IN_MS         (1000)

#define _DRV_SDSPI_COMMAND_RESPONSE_TRIES           (10)

// *****************************************************************************
// *****************************************************************************
// Section: SD Card constants
// *****************************************************************************
// *****************************************************************************
/* Constants used by SD Card (SPI) Driver */

// *****************************************************************************
/* SD Card initial speed

  Summary:
    Initial speed of the SPI communication.

  Description:
    This macro holds the value of the initial communication speed with SD card.
    SD card only work at <=400kHz SPI frequency during initialization.

  Remarks:
    None.
*/

#define _DRV_SDSPI_SPI_INITIAL_SPEED                        400000


// *****************************************************************************
/* Count for 8 clock pulses

  Summary:
    Bytes count which should be passed to DRV_SPI_BufferReadAdd function to send
    8 clock pulses.

  Description:
    This macro holds the bytes count which should be passed to DRV_SPI_BufferReadAdd
    function to send 8 clock pulses. Sending one byte will send 8 clock pulses.


  Remarks:
    None.
*/

#define _DRV_SDSPI_SEND_8_CLOCKS                                            1

// *****************************************************************************
/* No of bytes to be read for SD card CSD.

  Summary:
    Number of bytes to be read to get the SD card CSD.

  Description:
    This macro holds number of bytes to be read to get the SD card CSD.


  Remarks:
    None.
*/

#define _DRV_SDSPI_CSD_READ_SIZE                                            20

// *****************************************************************************
/* No of bytes to be read for SD card CID.

  Summary:
    Number of bytes to be read to get the SD card CID.

  Description:
    This macro holds number of bytes to be read to get the SD card CID.


  Remarks:
    None.
*/
#define _DRV_SDSPI_CID_READ_SIZE                                            20

// *****************************************************************************
/* SD card V2 device type.

  Summary:
    Holds the value to be checked against to state the device type is V2.

  Description:
    This macro holds value to be checked against to state the device type is V2.

  Remarks:
    None.
*/

#define _DRV_SDSPI_CHECK_V2_DEVICE                                          0xC0


// *****************************************************************************
/* SD card sector size.

  Summary:
    Holds the SD card sector size.

  Description:
    This macro holds the SD card sector size.

  Remarks:
    None.
*/

#define _DRV_SDSPI_MEDIA_BLOCK_SIZE                                         512


// *****************************************************************************
/* SD card transmit bit.

  Summary:
    Holds the SD card transmit bit position.

  Description:
    This macro holds the SD card transmit bit position.

  Remarks:
    None.
*/

#define DRV_SDSPI_TRANSMIT_SET                                              0x40


// *****************************************************************************
/* Write response token bit mask.

  Summary:
    Bit mask to AND with the write token response byte from the media,

  Description:
    This macro holds the bit mask to AND with the write token response byte from
    the media to clear the don't care bits.

  Remarks:
    None.
*/

#define DRV_SDSPI_WRITE_RESPONSE_TOKEN_MASK                                0x1F


// *****************************************************************************
/* SPI Bus floating

  Summary:
    This macro represents a floating SPI bus condition.

  Description:
    This macro represents a floating SPI bus condition.

  Remarks:
    None.
*/

#define DRV_SDSPI_MMC_FLOATING_BUS                                          0xFF


// *****************************************************************************
/* SD card bad response

  Summary:
    This macro represents a bad SD card response byte.

  Description:
    This macro represents a bad SD card response byte.

  Remarks:
    None.
*/

#define DRV_SDSPI_MMC_BAD_RESPONSE          DRV_SDSPI_MMC_FLOATING_BUS


// *****************************************************************************
/* SD card start single block

  Summary:
    This macro represents an SD card start single data block token (used for
    single block writes).

  Description:
    This macro represents an SD card start single data block token (used for
    single block writes).

  Remarks:
    None.
*/

#define DRV_SDSPI_DATA_START_TOKEN                     0xFE


// *****************************************************************************
/* SD card start multiple blocks

  Summary:
    This macro represents an SD card start multi-block data token (used for
    multi-block writes).

  Description:
    This macro represents an SD card start multi-block data token (used for
    multi-block writes).

  Remarks:
    None.
*/

#define DRV_SDSPI_DATA_START_MULTI_BLOCK_TOKEN         0xFC


// *****************************************************************************
/* SD card stop transmission

  Summary:
    This macro represents an SD card stop transmission token.  This is used when
    finishing a multi block write sequence.

  Description:
    This macro represents an SD card stop transmission token.  This is used when
    finishing a multi block write sequence.

  Remarks:
    None.
*/

#define DRV_SDSPI_DATA_STOP_TRAN_TOKEN                 0xFD


// *****************************************************************************
/* SD card data accepted token

  Summary:
    This macro represents an SD card data accepted token.

  Description:
    This macro represents an SD card data accepted token.

  Remarks:
    None.
*/

#define DRV_SDSPI_DATA_ACCEPTED                        0x05


// *****************************************************************************
/* SD card R1 response end bit

  Summary:
    This macro holds a value to check R1 response end bit.

  Description:
    This macro holds a value to check R1 response end bit.

  Remarks:
    None.
*/

#define CMD_R1_END_BIT_SET                              0x01


// *****************************************************************************
/* SD card initial packet size

  Summary:
    This macro holds SD card initial packet size.

  Description:
    This macro holds SD card initial packet size.

  Remarks:
    None.
*/

#define DRV_SDSPI_PACKET_SIZE                       6


// *****************************************************************************
/* SD card Media initialization array size

  Summary:
    This macro holds SD card Media initialization array size.

  Description:
    This macro holds SD card Media initialization array size.

  Remarks:
    None.
*/

#define MEDIA_INIT_ARRAY_SIZE                           10

// *****************************************************************************
/* Dummy Buffer for DMA Transfers

  Summary:
    This macro holds the size of the dummy buffer used during DMA transfers.

  Description:
    This macro holds the size of the dummy buffer used during DMA transfers.

  Remarks:
    None.
*/

#define DMA_DUMMY_BUFFER_SIZE                           512


#if defined (DRV_SDSPI_ENABLE_WRITE_PROTECT_CHECK)
    #define _DRV_SDSPI_EnableWriteProtectCheck() true
#else
    #define _DRV_SDSPI_EnableWriteProtectCheck() false
#endif

// *****************************************************************************
// *****************************************************************************
// Section: SD Card Enumerations
// *****************************************************************************
// *****************************************************************************

typedef enum {
    TASK_STATE_IDLE,

    TASK_STATE_CARD_STATUS,

    TASK_STATE_CARD_COMMAND,

} _DRV_SDSPI_TASK_STATE;

typedef enum
{
    DRV_SDSPI_OPERATION_TYPE_READ,

    DRV_SDSPI_OPERATION_TYPE_WRITE,

} DRV_SDSPI_OPERATION_TYPE;

typedef enum
{
    DRV_SDSPI_TRANSFER_OBJ_IS_FREE,

    DRV_SDSPI_TRANSFER_OBJ_IS_IN_QUEUE,

    DRV_SDSPI_TRANSFER_OBJ_IS_PROCESSING,

} DRV_SDSPI_TRANSFER_OBJ_STATE;

typedef enum
{
    /* All data was transferred successfully. */

    DRV_SDSPI_SPI_TRANSFER_STATUS_IN_PROGRESS,

    DRV_SDSPI_SPI_TRANSFER_STATUS_COMPLETE,

    /* There was an error while processing transfer request. */
    DRV_SDSPI_SPI_TRANSFER_STATUS_ERROR,

} DRV_SDSPI_SPI_TRANSFER_STATUS;

typedef enum
{
    DRV_SDSPI_TASK_START_POLLING_TIMER,

    DRV_SDSPI_TASK_WAIT_POLLING_TIMER_EXPIRE,

    /* A device is attached */
    DRV_SDSPI_TASK_CHECK_DEVICE,

    /* If the card is attached, initialize */
    DRV_SDSPI_TASK_MEDIA_INIT,

    /* Idle State  */
    DRV_SDSPI_TASK_IDLE

} DRV_SDSPI_TASK_STATES;

typedef enum
{
    /* A device is attached */
    DRV_SDSPI_BUFFER_IO_CHECK_DEVICE,

    /* Process queue for Read and write */
    DRV_SDSPI_TASK_PROCESS_QUEUE,

    /* Process read */
    DRV_SDSPI_TASK_PROCESS_READ,

    /* Process write */
    DRV_SDSPI_TASK_PROCESS_WRITE,

    /* Wait for the SPI transaction to complete. */
    DRV_SDSPI_TASK_SPI_STATUS,

    /* Read the start token from the SD card. */
    DRV_SDSPI_TASK_READ_START_TOKEN,

    /* Check if the token received is correct */
    DRV_SDSPI_TASK_READ_START_TOKEN_STATUS,

    /* Read 512 bytes of data from the SD card. */
    DRV_SDSPI_TASK_READ_DATA,

    /* Read 2 bytes of crc data from the sd card. */
    DRV_SDSPI_TASK_READ_CRC_BYTES,

    /* Check if read operation is complete. */
    DRV_SDSPI_TASK_READ_COMPLETE_CHECK,

    /* Send Stop tran command to terminate a multi block read operation. */
    DRV_SDSPI_TASK_READ_STOP_TRANSMISSION,

    /* Send 8 clock pulses */
    DRV_SDSPI_TASK_SEND_DUMMY_CLOCK_PULSES,

    /* Send write start token to the SD card. */
    DRV_SDSPI_TASK_WRITE_START_TOKEN,

    /* Write 512 bytes of data to the SD card. */
    DRV_SDSPI_TASK_WRITE_DATA,

    /* Write 2 bytes of CRC data for the write block. */
    DRV_SDSPI_TASK_WRITE_CRC_BYTES,

    /* Wait for the response token from the card. */
    DRV_SDSPI_TASK_WRITE_READ_RESP_TOKEN,

    /* Check if the response token received is correct. */
    DRV_SDSPI_TASK_WRITE_RESP_TOKEN_STATUS,

    /* Read the busy status from the card. */
    DRV_SDSPI_TASK_WRITE_CHECK_BUSY,

    /* Check if the card is still busy with programming of the data. */
    DRV_SDSPI_TASK_WRITE_CHECK_BUSY_STATUS,

    /* Check if the write is complete. */
    DRV_SDSPI_TASK_WRITE_COMPLETE_CHECK,

    /* Send the stop transmission token for multi block writes. */
    DRV_SDSPI_TASK_WRITE_STOP_TRAN_TOKEN,

    /* Send 8 clock pulses post stop tran token. */
    DRV_SDSPI_TASK_WRITE_STOP_TRAN_DUMMY_PULSES,

    /* Read the card busy status. */
    DRV_SDSPI_TASK_WRITE_STOP_TRAN_CHECK_BUSY,

    /* Check if the card has come out of the busy status. */
    DRV_SDSPI_TASK_WRITE_STOP_TRAN_BUSY_STATUS,

    /* SD card write is complete */
    DRV_SDSPI_TASK_PROCESS_NEXT,

    /* Something went wrong on read/write */
    DRV_SDSPI_TASK_READ_WRITE_ABORT

} DRV_SDSPI_BUFFER_IO_TASK_STATES;

typedef enum
{
    /* SD Card is attached from the system */
    DRV_SDSPI_IS_DETACHED,

    /* SD Card is attached to the system */
    DRV_SDSPI_IS_ATTACHED

}DRV_SDSPI_ATTACH;

typedef enum
{
    /* Command code to reset the SD card */
    CMD_VALUE_GO_IDLE_STATE = 0,

    /* Command code to initialize the SD card */
    CMD_VALUE_SEND_OP_COND  = 1,

    /* This macro defined the command code to check for sector addressing */
    CMD_VALUE_SEND_IF_COND  = 8,

    /* Command code to get the Card Specific Data */
    CMD_VALUE_SEND_CSD      = 9,

    /* Command code to get the Card Information */
    CMD_VALUE_SEND_CID      = 10,

    /* Command code to stop transmission during a multi-block read */
    CMD_VALUE_STOP_TRANSMISSION = 12,

    /* Command code to get the card status information */
    CMD_VALUE_SEND_STATUS       = 13,

    /* Command code to set the block length of the card */
    CMD_VALUE_SET_BLOCKLEN      = 16,

    /* Command code to read one block from the card */
    CMD_VALUE_READ_SINGLE_BLOCK  = 17,

    /* Command code to read multiple blocks from the card */
    CMD_VALUE_READ_MULTI_BLOCK   = 18,

    /* Command code to tell the media how many blocks to pre-erase
     (for faster multi-block writes to follow)
     Note: This is an "application specific" command.  This tells the media how
     many blocks to pre-erase for the subsequent WRITE_MULTI_BLOCK */
    CMD_VALUE_SET_WR_BLK_ERASE_COUNT =  23,

    /* Command code to write one block to the card */
    CMD_VALUE_WRITE_SINGLE_BLOCK  = 24,

    /* Command code to write multiple blocks to the card */
    CMD_VALUE_WRITE_MULTI_BLOCK   = 25,

    /* Command code to set the address of the start of an erase operation */
    CMD_VALUE_TAG_SECTOR_START    = 32,

    /* Command code to set the address of the end of an erase operation */
    CMD_VALUE_TAG_SECTOR_END      = 33,

    /* Command code to erase all previously selected blocks */
    CMD_VALUE_ERASE              =  38,

    /* Command code to initialise an SD card and provide the CSD register value.
    Note: this is an "application specific" command (specific to SD cards)
    and must be preceded by CMD_APP_CMD */
    CMD_VALUE_SD_SEND_OP_COND     = 41,

    /* Command code to begin application specific command inputs */
    CMD_VALUE_APP_CMD             = 55,

    /* Command code to get the OCR register information from the card */
    CMD_VALUE_READ_OCR            = 58,

    /* Command code to disable CRC checking */
    CMD_VALUE_CRC_ON_OFF          = 59,

}DRV_SDSPI_COMMAND_VALUE;

typedef enum
{
    /* R1 type response */
    RESPONSE_R1,

    /* R1b type response */
    RESPONSE_R1b,

    /* R2 type response */
    RESPONSE_R2,

    /* R3 type response */
    RESPONSE_R3,

    /* R7 type response */
    RESPONSE_R7

}DRV_SDSPI_RESPONSES;

typedef enum
{
    /* Index of in the CMD_GO_IDLE_STATE command 'Command array' */
    DRV_SDSPI_GO_IDLE_STATE,

    /* Index of in the CMD_SEND_OP_COND command 'Command array' */
    DRV_SDSPI_SEND_OP_COND,

    /* Index of in the CMD_SEND_IF_COND command 'Command array' */
    DRV_SDSPI_SEND_IF_COND,

    /* Index of in the CMD_SEND_CSD command 'Command array' */
    DRV_SDSPI_SEND_CSD,

    /* Index of in the CMD_SEND_CID command 'Command array' */
    DRV_SDSPI_SEND_CID,

    /* Index of in the CMD_STOP_TRANSMISSION command 'Command array' */
    DRV_SDSPI_STOP_TRANSMISSION,

    /* Index of in the CMD_SEND_STATUS command 'Command array' */
    DRV_SDSPI_SEND_STATUS,

    /* Index of in the CMD_SET_BLOCKLEN command 'Command array' */
    DRV_SDSPI_SET_BLOCKLEN,

    /* Index of in the CMD_READ_SINGLE_BLOCK command 'Command array' */
    DRV_SDSPI_READ_SINGLE_BLOCK,

    /* Index of in the CMD_READ_MULTI_BLOCK command 'Command array' */
    DRV_SDSPI_READ_MULTI_BLOCK,

    /* Index of in the CMD_WRITE_SINGLE_BLOCK command 'Command array' */
    DRV_SDSPI_WRITE_SINGLE_BLOCK,

    /* Index of in the CMD_WRITE_MULTI_BLOCK command 'Command array' */
    DRV_SDSPI_WRITE_MULTI_BLOCK,

    /* Index of in the CMD_TAG_SECTOR_START command 'Command array' */
    DRV_SDSPI_TAG_SECTOR_START,

    /* Index of in the CMD_TAG_SECTOR_END command 'Command array' */
    DRV_SDSPI_TAG_SECTOR_END,

    /* Index of in the CMD_ERASE command 'Command array' */
    DRV_SDSPI_ERASE,

    /* Index of in the CMD_APP_CMD command 'Command array' */
    DRV_SDSPI_APP_CMD,

    /* Index of in the CMD_READ_OCR command 'Command array' */
    DRV_SDSPI_READ_OCR,

    /* Index of in the CMD_CRC_ON_OFF command 'Command array' */
    DRV_SDSPI_CRC_ON_OFF,

    /* Index of in the CMD_SD_SEND_OP_COND command 'Command array' */
    DRV_SDSPI_SD_SEND_OP_COND,

    /* Index of in the CMD_SET_WR_BLK_ERASE_COUNT command 'Command array' */
    DRV_SDSPI_SET_WR_BLK_ERASE_COUNT

}DRV_SDSPI_COMMANDS;

typedef enum
{
    /* Normal SD Card */
    DRV_SDSPI_MODE_NORMAL,

    /* SDHC type Card */
    DRV_SDSPI_MODE_HC

}DRV_SDSPI_TYPE;

typedef enum
{
    /* Initial state */
    DRV_SDSPI_CMD_DETECT_START_INIT,

    /* Check for the presence of the SD card */
    DRV_SDSPI_CMD_DETECT_CHECK_FOR_CARD,

    /* Reset the SD card */
    DRV_SDSPI_CMD_DETECT_RESET_SDCARD,

    /* Placeholder state until the MediaInitialize function indicates if the card
    is really present or not. */
    DRV_SDSPI_CMD_DETECT_WAIT_TRANSFER_COMPLETE,

    /* Check whether the card has been detached. */
    DRV_SDSPI_CMD_DETECT_CHECK_FOR_DETACH,

    DRV_SDSPI_CMD_DETECT_CHECK_FOR_DETACH_READ_CID_DATA,

    DRV_SDSPI_CMD_DETECT_CHECK_FOR_DETACH_PROCESS_CID_DATA,

    DRV_SDSPI_CMD_DETECT_IDLE_STATE,

} DRV_SDSPI_CMD_DETECT_STATES;

typedef enum
{
    /* Frame the command packet and drive the CS low. */
    DRV_SDSPI_CMD_FRAME_PACKET,

    /* Send the framed command packet. */
    DRV_SDSPI_CMD_SEND_PACKET,
    /* DRV_SDSPI_STOP_TRANSMISSION command is a special case
       that requires an additional read. */
    DRV_SDSPI_CMD_CHECK_SPL_CASE,

    /* Check whether the command processing is complete */
    DRV_SDSPI_CMD_CHECK_TRANSFER_COMPLETE,

    /* Act as per the expected response type for the command */
    DRV_SDSPI_CMD_CHECK_RESP_TYPE,

    /* Switch to this when the response type is R2 */
    DRV_SDSPI_CMD_HANDLE_R2_RESPONSE,

    /* Switch to this when the response type is R7 */
    DRV_SDSPI_CMD_HANDLE_R7_RESPONSE,

    /* Read back the data until the card is not busy */
    DRV_SDSPI_CMD_R1B_READ_BACK,

    /* Check for command execution completion */
    DRV_SDSPI_CMD_EXEC_CHECK_COMPLETION,

    /* Temporary state */
    DRV_SDSPI_CMD_CONFIRM_COMPLETE,

    /* Error state */
    DRV_SDSPI_CMD_EXEC_ERROR,

    /* Command execution is complete */
    DRV_SDSPI_CMD_EXEC_IS_COMPLETE,

}DRV_SDSPI_CMD_STATES;

typedef enum
{
    /* Keep the CS high */
    DRV_SDSPI_INIT_CHIP_DESELECT,

    /* Card ramp up time. Issue clock cycles. */
    DRV_SDSPI_INIT_RAMP_TIME,

    /* Check if the card is ramped up */
    DRV_SDSPI_INIT_RAMP_TIME_STATUS,

    /* Enable the CS */
    DRV_SDSPI_INIT_CHIP_SELECT,

    /* Reset the SD Card using CMD0 */
    DRV_SDSPI_INIT_RESET_SDCARD,

    /* Check the card's interface condition */
    DRV_SDSPI_INIT_CHK_IFACE_CONDITION,

    /* Send OCR to expand the ACMD41 */
    DRV_SDSPI_INIT_READ_OCR_REGISTER,

    /* Send APP CMD */
    DRV_SDSPI_INIT_SEND_APP_CMD,

    /* Send APP CMD ACMD41 to check if the card's internal init is done */
    DRV_SDSPI_INIT_SEND_ACMD41,

    /* Read the Card's Operating Conditions Register */
    DRV_SDSPI_INIT_READ_OCR,

    /* Card's internal init is complete. Increase the SPI frequency. */
    DRV_SDSPI_INIT_INCR_CLOCK_SPEED,

    /* Wait for the dummy read done in the INCR_CLOCK_SPEED state to complete. */
    DRV_SDSPI_INIT_INCR_CLOCK_SPEED_STATUS,

    /* Issue command to read the card's Card Specific Data register */
    DRV_SDSPI_INIT_READ_CSD,

    /* Read the CSD data */
    DRV_SDSPI_INIT_READ_CSD_DATA,

    /* Read the CSD data token */
    DRV_SDSPI_INIT_READ_CSD_DATA_TOKEN,

    /* Read the CSD data token */
    DRV_SDSPI_INIT_READ_CSD_DATA_TOKEN_STATUS,

    /* Process the CSD register data */
    DRV_SDSPI_INIT_PROCESS_CSD,

    /* Issue command to read the card's Card Identification Data register */
    DRV_SDSPI_INIT_READ_CID,

    /* Read the CID data */
    DRV_SDSPI_INIT_READ_CID_DATA,

    /* Process the CID register data */
    DRV_SDSPI_INIT_PROCESS_CID,

    /* Issue command to turn off the CRC */
    DRV_SDSPI_INIT_TURN_OFF_CRC,

    /* Set the block length of the card */
    DRV_SDSPI_INIT_SET_BLOCKLEN,

    /* SD Card Init is done */
    DRV_SDSPI_INIT_SD_INIT_DONE,

    /* Error initializing the SD card */
    DRV_SDSPI_INIT_ERROR

} DRV_SDSPI_INIT_STATE;

typedef struct
{
    /* Command code */
    DRV_SDSPI_COMMAND_VALUE      commandCode;

    /* CRC value for that command */
    uint8_t                     crc;

    /* Response type */
    DRV_SDSPI_RESPONSES         responseType;

    /* Response Length */
    uint32_t                    responseLength;

} DRV_SDSPI_CMD_OBJ;

typedef union
{
    /* This structure allows array-style access of command bytes */
    struct
    {
        uint8_t field[7];
    };

    /* This structure allows byte-wise access of packet command bytes */
    struct
    {
        /* The CRC byte */
        uint8_t crc;

        /* Filler space (since bitwise declarations can't
         cross a uint32_t boundary) */
        uint8_t c32filler[3];

        /* Address byte 0 */
        uint8_t address0;

        /* Address byte 1 */
        uint8_t address1;

        /* Address byte 2 */
        uint8_t address2;

        /* Address byte 3 */
        uint8_t address3;

        /* Command code byte */
        uint8_t cmd;
    };

    /* This structure allows bitwise access to elements of the command bytes */
    struct
    {
        /* Packet end bit */
        uint8_t  endBit:1;

        /* CRC value */
        uint8_t  crc7:7;

        /* Address */
        uint32_t    address;

        /* Command code */
        uint8_t  cmdIndex:6;

        /* Transmit bit */
        uint8_t  transmitBit:1;

        /* Packet start bit */
        uint8_t  startBit:1;
    };
} DRV_SDSPI_CMD_PACKET;

typedef union
{
    /* Byte-wise access */
    uint8_t byte;

    /* This structure allows bitwise access of the response */
    struct
    {
        /* Card is in idle state */
        unsigned inIdleState:1;

        /* Erase reset flag */
        unsigned eraseReset:1;

        /* Illegal command flag */
        unsigned illegalCommand:1;

        /* CRC error flag */
        unsigned crcError:1;

        /* Erase sequence error flag */
        unsigned eraseSequenceError:1;

        /* Address error flag */
        unsigned addressError:1;

        /* Parameter flag */
        unsigned parameterError:1;

        /* Unused bit 7 */
        unsigned unusedB7:1;
    };

} DRV_SDSPI_RESPONSE_1;

typedef union
{
    /* Get both the bytes */
    uint16_t word;

    struct
    {
        /* Byte-wise access */
        uint8_t      byte0;
        uint8_t      byte1;
    };
    struct
    {
        /* Card is in idle state */
        unsigned inIdleState:1;

        /* Erase reset flag */
        unsigned eraseReset:1;

        /* Illegal command flag */
        unsigned illegalCommand:1;

        /* CRC error flag */
        unsigned crcError:1;

        /* Erase sequence error flag */
        unsigned eraseSequenceError:1;

        /* Address error flag */
        unsigned addressError:1;

        /* Parameter error flag */
        unsigned parameterError:1;

        /* Un-used bit */
        unsigned unusedB7:1;

        /* Card is locked? */
        unsigned cardIsLocked:1;

        /* WP erase skip| lock/unlock command failed */
        unsigned wpEraseSkipLockFail:1;

        /* Error */
        unsigned error:1;

        /* CC error */
        unsigned ccError:1;

        /* Card ECC fail */
        unsigned cardEccFail:1;

        /* WP violation */
        unsigned wpViolation:1;

        /* Erase parameter */
        unsigned eraseParam:1;

        /* out of range or CSD over write */
        unsigned outrangeCsdOverWrite:1;
    };

} DRV_SDSPI_RESPONSE_2;

typedef union
{
    struct
    {
        uint8_t byteR1;

        /* OCR register */
        union
        {
            /* OCR register */
            uint32_t ocrRegister;

            /* OCR register in bytes */
            struct
            {
                uint8_t ocrRegisterByte0;
                uint8_t ocrRegisterByte1;
                uint8_t ocrRegisterByte2;
                uint8_t ocrRegisterByte3;
            };
        }argument;

    } bytewise;
    /* This structure allows bitwise access of the response */
    struct
    {
        struct
        {
        /* Card is in idle state */
        unsigned inIdleState:1;

        /* Erase reset flag */
        unsigned eraseReset:1;

        /* Illegal command flag */
        unsigned illegalCommand:1;

        /* CRC error flag */
        unsigned crcError:1;

        /* Erase sequence error flag */
        unsigned eraseSequenceError:1;

        /* Address error flag */
        unsigned addressError:1;

        /* Parameter error flag */
        unsigned parameterError:1;

        /* un-used bit B7 */
        unsigned unusedB7:1;

        }bits;

        /* Read the complete register */
        uint32_t ocrRegister;

    } bitwise;

} DRV_SDSPI_RESPONSE_7;

typedef union
{
    /* SD Card response 1 */
    DRV_SDSPI_RESPONSE_1  response1;

    /* SD Card response 2 */
    DRV_SDSPI_RESPONSE_2  response2;

    /* SD Card response 7 */
    DRV_SDSPI_RESPONSE_7  response7;

}DRV_SDSPI_RESPONSE_PACKETS;

typedef union
{
    struct
    {
        /* Access 32 bit format 1st */
        uint32_t access32_0;

        /* Access 32 bit format 2nd */
        uint32_t access32_1;

        /* Access 32 bit format 3rd */
        uint32_t access32_2;

        /* Access 32 bit format 4th */
        uint32_t access32_3;
    };
    struct
    {
        /* Access as bytes */
        uint8_t byte[16];
    };

    struct
    {
        /* Un used bit */
        unsigned unUsed           :1;

        /* Crc */
        unsigned crc                :7;

        /* Ecc */
        unsigned ecc                :2;

        /* File format */
        unsigned fileFormat        :2;

        /* temporary write protection */
        unsigned tempWriteProtect  :1;

        /* Permanent write protection */
        unsigned permanantWriteProtect :1;

        /* Copy flag */
        unsigned copyFlag           :1;

        /* File format group */
        unsigned fileFormatGroup    :1;

        /* Reserved bits */
        unsigned reserved_1         :5;

        /* Partial blocks for write allowed */
        unsigned writeBlockPartial   :1;

        /* Max. write data block length high */
        unsigned writeBlockLenHigh    :2;

        /* Max. write data block length low */
        unsigned writeBlockLenLow     :2;

        /* write speed factor */
        unsigned writeSpeedFactor     :3;

        /* default Ecc */
        unsigned defaultEcc            :2;

        /* Write protect group enable */
        unsigned writeProtectGrpEnable :1;

        /* Write protect group size */
        unsigned writeProtectGrpSize   :5;

        /* Erase sector size low */
        unsigned eraseSectorSizeLow   :3;

        /* Erase sector size high */
        unsigned eraseSectorSizeHigh   :2;

        /* Sector size */
        unsigned sectorSize        :5;

        /* TODO  erase single block enable??*/
        /* Device size multiplier low */
        unsigned deviceSizeMultiLow      :1;

        /* Device size multiplier high */
        unsigned deviceSizeMultiHigh      :2;

        /* Max. write current @VDD max */
        unsigned vddWriteCurrentMax     :3;

        /* max. write current @VDD min */
        unsigned vddWriteCurrentMin      :3;

        /* max. read current @VDD max */
        unsigned vddReadCurrentMax     :3;

        /* max. read current @VDD min */
        unsigned vddReadCurrentMin     :3;

        /* device size low */
        unsigned deviceSizeLow         :2;

        /* device size high */
        unsigned deviceSizeHigh        :8;

        /* device size upper */
        unsigned deviceSizeUp          :2;

        /* reserved bits */
        unsigned reserved2             :2;

        /* DSR implemented */
        unsigned dsrImplemented        :1;

        /* Read block misalignment */
        unsigned readBlockMissAllign  :1;

        /* Write block misalignment */
        unsigned writeBlockMissAllign :1;

        /* Partial blocks for read allowed */
        unsigned partialBlockRead     :1;

        /* Max. read data block length */
        unsigned readDataBlockMax     :4;

        /* Card command classes low */
        unsigned cardCmdClassesLow    :4;

        /* Card command classes high */
        unsigned cardCmdClassesHigh   :8;

        /* max. data transfer rate */
        unsigned maxDataTrasferRate   :8;

        /* Data read access-time-2 in clock cycles (NSAC*100) */
        unsigned dataReadTime2Clocks   :8;

        /* data read access-time-1 */
        unsigned dataReadTime1Clocks   :8;

        /* Reserved bits */
        unsigned reserved3             :2;

        /* Specification version */
        unsigned specVersion           :4;

        /* CSD structure */
        unsigned csdStructure         :2;
    };

} DRV_SDSPI_CSD;

typedef union
{
    struct
    {
        /* Access 32 bit format 1st */
        uint32_t access32_0;

        /* Access 32 bit format 2nd */
        uint32_t access32_1;

        /* Access 32 bit format 3rd */
        uint32_t access32_2;

        /* Access 32 bit format 4th */
        uint32_t access32_3;
    };
    struct
    {
        uint8_t byte[16];
    };
    struct
    {
        /* Unused bit */
        unsigned    notUsed            :1;

        /* Crc */
        unsigned    crc                 :7;

        /* Manufacturing date */
        unsigned    mnufacturingDate    :8;

        /* Product serial number */
        uint32_t       serialNumber;

        /* Product revision */
        unsigned    revision            :8;

        /* Product name */
        char        name[6];

        /* OEM Application ID */
        uint16_t        oemId;

        /* Manufacturer ID */
        unsigned    manufacturerId     :8;
    };
} DRV_SDSPI_CID;

typedef struct _DRV_SDSPI_CLIENT_OBJ_STRUCT
{
    /* Save the index while opening the driver */
    SYS_MODULE_INDEX                                drvIndex;

    /* Flag to indicate in use  */
    bool                                            inUse;

    /* The intent with which the client was opened */
    DRV_IO_INTENT                                   intent;

    /* Client specific event handler */
    DRV_SDSPI_EVENT_HANDLER                         eventHandler;

    /* Client specific context */
    uintptr_t                                       context;

    /* Client handle assigned to this client object when it was opened */
    DRV_HANDLE                                      clientHandle;

} DRV_SDSPI_CLIENT_OBJ;

typedef struct DRV_SDSPI_BUFFER_OBJ
{
    bool                                            inUse;

    /* Handle to the client that owns this buffer object */
    DRV_HANDLE                                      clientHandle;

    /* Present status of this command */
    DRV_SDSPI_COMMAND_STATUS                        status;

    /* Current command handle of this buffer object */
    DRV_SDSPI_COMMAND_HANDLE                        commandHandle;

    /* Pointer to the source/destination buffer */
    uint8_t*                                        buffer;

    /* Sector start address */
    uint32_t                                        blockStart;

    /* Number of sectors  */
    uint32_t                                        nBlocks;

    uint8_t                                         command;

    /* Operation type - read/write */
    DRV_SDSPI_OPERATION_TYPE                        opType;

    /* Pointer to the next buffer in the queue */
    struct DRV_SDSPI_BUFFER_OBJ*                    next;

}DRV_SDSPI_BUFFER_OBJ;

typedef struct
{
    /* Flag to indicate that the driver object is in use  */
    bool                                            inUse;

    /* Flag to indicate that SD Card is being used in exclusive access mode */
    bool                                            isExclusive;

    /* The status of the driver */
    SYS_STATUS                                      status;

    /* Memory pool for Client Objects */
    uintptr_t                                       clientObjPool;

    /* Number of active clients */
    size_t                                          nClients;

    /* Maximum number of clients */
    size_t                                          numClients;

    /* Instance specific token counter used to generate unique client/transfer handles */
    uint16_t                                        sdspiTokenCount;

    /* Flag to track the status of the command response timer */
    bool                                            cmdRespTmrFlag;

    /* Flag to track the status of the read write transaction timer */
    bool                                            timerFlag;

    /* Handle to the timer used for read/write transaction timeouts. */
    SYS_TIME_HANDLE                                 timerHandle;

    /* Handle to the timer used for command timeouts */
    SYS_TIME_HANDLE                                 cmdRespTmrHandle;

    /* Handle to the timer used for command timeouts */
    SYS_TIME_HANDLE                                 cardPollingTmrHandle;

    /* Timer command state. */
    volatile bool                                   cmdRespTmrExpired;

    volatile bool                                   timerExpired;

    volatile bool                                   cardPollingTimerExpired;

    /* Flag to indicate if the device is Standard Speed or High Speed */
    uint8_t                                         sdHcHost;

    /* Counter to keep track of retries to get command's response from the SD Card */
    uint8_t                                         ncrTries;

    /* Pointer to the buffer used during sending commands and receiving responses
    on the SPI bus */
    uint8_t*                                        pCmdResp;

    /* Pointer to the buffer used to send dummy clock pulses on the SPI bus */
    uint8_t*                                        pClkPulseData;

    /* Pointer to the CSD data of the SD Card */
    uint8_t*                                        pCsdData;

    /* Pointer to the CID data of the SD Card */
    uint8_t*                                        pCidData;

    /* Speed at which SD card communication should happen */
    uint32_t                                        sdcardSpeedHz;

    uint32_t                                        pollingIntervalMs;

    /* Number of sectors in the SD card */
    uint32_t                                        discCapacity;

    /* Flags to track the device presence/absence */
    DRV_SDSPI_ATTACH                                isAttached;

    /* Flag to indicate the SD Card last attached status */
    DRV_SDSPI_ATTACH                                isAttachedLastStatus;

    /* Flag indicating the presence of the SD Card */
    SYS_MEDIA_STATUS                                mediaState;

    /* Write protect state */
    uint8_t                                         isWriteProtected;

    /* SD card type, will be updated by initialization function */
    DRV_SDSPI_TYPE                                  sdCardType;

    /* Size of buffer objects queue */
    uint32_t                                        bufferObjPoolSize;

    /* Pointer to the buffer pool */
    uintptr_t                                       bufferObjPool;

    /* Linked list of buffer objects */
    uintptr_t                                       bufferObjList;

    /* PLIB API list that will be used by the driver to access the hardware */
    const DRV_SDSPI_PLIB_INTERFACE*                 spiPlib;

    const uint32_t*                                 remapDataBits;

    const uint32_t*                                 remapClockPolarity;

    const uint32_t*                                 remapClockPhase;

    SYS_PORT_PIN                                    chipSelectPin;

    SYS_PORT_PIN                                    writeProtectPin;

    volatile DRV_SDSPI_SPI_TRANSFER_STATUS          spiTransferStatus;

    /* This variable holds the current state of the DRV_SDSPI_Task */
    DRV_SDSPI_TASK_STATES                           taskState;

    DRV_SDSPI_BUFFER_IO_TASK_STATES                 nextTaskState;

    /* This variable holds the current state of the DRV_SDSPI_Task */
    DRV_SDSPI_BUFFER_IO_TASK_STATES                 taskBufferIOState;

    /* Different stages of initialization */
    DRV_SDSPI_CMD_DETECT_STATES                     cmdDetectState;

    /* Different states in sending a command */
    DRV_SDSPI_CMD_STATES                            cmdState;

    /* Different stages in media initialization */
    DRV_SDSPI_INIT_STATE                            mediaInitState;

    /* SDCARD driver state: Command/status/idle states */
    _DRV_SDSPI_TASK_STATE                           sdState;

    /* Tracks the command response */
    DRV_SDSPI_RESPONSE_PACKETS                      cmdResponse;

    /* Transmit DMA Channel */
    SYS_DMA_CHANNEL                                 txDMAChannel;

    /* Receive DMA Channel */
    SYS_DMA_CHANNEL                                 rxDMAChannel;

    /* This is the SPI transmit register address. Used for DMA operation. */
    void*                                           txAddress;

    /* This is the SPI receive register address. Used for DMA operation. */
    void*                                           rxAddress;

    /* Pointer to the common transmit dummy data array */
    uint8_t*                                        txDummyData;

    /* Dummy data is read into this variable by RX DMA */
    uint32_t                                        rxDummyData;

    /* Mutex to protect access to SDCard */
    OSAL_MUTEX_DECLARE(transferMutex);

    /* Mutex to protect access to the client object pool */
    OSAL_MUTEX_DECLARE(clientMutex);

    /* SDCARD driver geometry object */
    SYS_MEDIA_GEOMETRY                              mediaGeometryObj;

    /* SDCARD driver media geomtery table. */
    SYS_MEDIA_REGION_GEOMETRY                       mediaGeometryTable[3];

} DRV_SDSPI_OBJ;

#endif //#ifndef _DRV_SDSPI_LOCAL_H
