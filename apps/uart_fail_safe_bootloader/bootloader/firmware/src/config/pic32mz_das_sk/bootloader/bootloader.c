/*******************************************************************************
  UART Bootloader Source File

  File Name:
    bootloader.c

  Summary:
    This file contains source code necessary to execute UART bootloader.

  Description:
    This file contains source code necessary to execute UART bootloader.
    It implements bootloader protocol which uses UART peripheral to download
    application firmware into internal flash from HOST-PC.
 *******************************************************************************/

// DOM-IGNORE-BEGIN
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
// DOM-IGNORE-END

#include "definitions.h"
#include <device.h>

#define FLASH_START             (0x9d000000UL)
#define FLASH_LENGTH            (0x200000UL)
#define PAGE_SIZE               (2048UL)
#define ERASE_BLOCK_SIZE        (16384UL)
#define PAGES_IN_ERASE_BLOCK    (ERASE_BLOCK_SIZE / PAGE_SIZE)

#define BOOTLOADER_SIZE         16384

#define APP_START_ADDRESS       (PA_TO_KVA0(0x1d000000UL))

#define GUARD_OFFSET            0
#define CMD_OFFSET              2
#define ADDR_OFFSET             0
#define SIZE_OFFSET             1
#define DATA_OFFSET             1
#define CRC_OFFSET              0

#define CMD_SIZE                1
#define GUARD_SIZE              4
#define SIZE_SIZE               4
#define OFFSET_SIZE             4
#define CRC_SIZE                4
#define HEADER_SIZE             (GUARD_SIZE + SIZE_SIZE + CMD_SIZE)
#define DATA_SIZE               ERASE_BLOCK_SIZE

#define WORDS(x)                ((int)((x) / sizeof(uint32_t)))

#define OFFSET_ALIGN_MASK       (~ERASE_BLOCK_SIZE + 1)
#define SIZE_ALIGN_MASK         (~PAGE_SIZE + 1)

#define BTL_GUARD               (0x5048434DUL)

/* Compare Value to achieve a 100Ms Delay */
#define TIMER_COMPARE_VALUE     (CORE_TIMER_FREQUENCY / 10)

enum
{
    BL_CMD_UNLOCK       = 0xa0,
    BL_CMD_DATA         = 0xa1,
    BL_CMD_VERIFY       = 0xa2,
    BL_CMD_RESET        = 0xa3,
    BL_CMD_BKSWAP_RESET = 0xa4,
};

enum
{
    BL_RESP_OK          = 0x50,
    BL_RESP_ERROR       = 0x51,
    BL_RESP_INVALID     = 0x52,
    BL_RESP_CRC_OK      = 0x53,
    BL_RESP_CRC_FAIL    = 0x54,
};

static uint32_t CACHE_ALIGN input_buffer[WORDS(OFFSET_SIZE + DATA_SIZE)];

static uint32_t CACHE_ALIGN flash_data[WORDS(DATA_SIZE)];

static uint32_t flash_addr          = 0;

static uint32_t unlock_begin        = 0;
static uint32_t unlock_end          = 0;

static uint8_t  input_command       = 0;

static bool     packet_received     = false;
static bool     flash_data_ready    = false;

#define LOWER_FLASH_START               (FLASH_START)
#define LOWER_FLASH_SERIAL_START        (LOWER_FLASH_START + (FLASH_LENGTH / 2) - PAGE_SIZE)
#define LOWER_FLASH_SERIAL_SECTOR       (LOWER_FLASH_START + (FLASH_LENGTH / 2) - ERASE_BLOCK_SIZE)

#define UPPER_FLASH_START               (FLASH_START + (FLASH_LENGTH / 2))
#define UPPER_FLASH_SERIAL_START        (UPPER_FLASH_START + (FLASH_LENGTH / 2) - PAGE_SIZE)
#define UPPER_FLASH_SERIAL_SECTOR       (UPPER_FLASH_START + (FLASH_LENGTH / 2) - ERASE_BLOCK_SIZE)

#define FLASH_SERIAL_CHECKSUM_START     0xDEADBEEF
#define FLASH_SERIAL_CHECKSUM_END       0xBEEFDEAD
#define FLASH_SERIAL_CHECKSUM_CLR       0xFFFFFFFF

#define LOWER_FLASH_SERIAL_READ         ((T_FLASH_SERIAL *)KVA0_TO_KVA1(LOWER_FLASH_SERIAL_START))
#define UPPER_FLASH_SERIAL_READ         ((T_FLASH_SERIAL *)KVA0_TO_KVA1(UPPER_FLASH_SERIAL_START))

typedef enum
{
    PROGRAM_FLASH_BANK_1,
    PROGRAM_FLASH_BANK_2,
} T_FLASH_BANK;

/* Structure to validate the Flash serial and its checksum
 * Note: The order of the members should not be changed
 */
typedef struct
{
    uint32_t checksum_start;
    uint32_t serial;
    uint32_t checksum_end;
    uint32_t dummy;
} T_FLASH_SERIAL;

T_FLASH_SERIAL CACHE_ALIGN  update_flash_serial;

volatile uint32_t   dummy_read;

static bool         upper_flash_serial_erased   = false;

/* Function to read the Serial number from Flash bank mapped to lower region */
static uint32_t get_LowerFlashSerial(void)
{
    T_FLASH_SERIAL *lower_flash_serial = LOWER_FLASH_SERIAL_READ;

    return (lower_flash_serial->serial);
}

/* Function to update the serial number based on address */
static void update_FlashSerial(uint32_t serial, uint32_t addr)
{
    update_flash_serial.serial          = serial;
    update_flash_serial.checksum_start  = FLASH_SERIAL_CHECKSUM_START;
    update_flash_serial.checksum_end    = FLASH_SERIAL_CHECKSUM_END;

    NVM_QuadWordWrite((uint32_t *)&update_flash_serial, addr);

    while(NVM_IsBusy() == true);
}

/* Function to update the serial number in upper flash panel (Inactive Panel) */
static void update_UpperFlashSerial(void)
{
    uint32_t upper_flash_serial;

    /* Increment Upper Mapped Flash panel serial by 1 to be ahead of the
     * current running Lower Mapped Flash panel serial
     */
    upper_flash_serial = get_LowerFlashSerial() + 1;

    /* Check if the Serial sector was erased during programming */
    if (upper_flash_serial_erased == false)
    {
        /* Erase the Sector in which Flash Serial Resides */
        NVM_PageErase(UPPER_FLASH_SERIAL_SECTOR);

        /* Wait for erase to complete */
        while(NVM_IsBusy() == true);
    }
    else
    {
        upper_flash_serial_erased = false;
    }

    update_FlashSerial(upper_flash_serial, UPPER_FLASH_SERIAL_START);
}

/* Function to swap the banks.
 * This function has to be removed once NVM PLIB has the support 
 */
static void bootloader_ProgramFlashSwapBank( T_FLASH_BANK flash_bank )
{
    /* NVMOP can be written only when WREN is zero. So, clear WREN */
    NVMCONCLR = _NVMCON_WREN_MASK;

    /* Write the unlock key sequence */
    NVMKEY = 0x0;
    NVMKEY = 0xAA996655;
    NVMKEY = 0x556699AA;

    if (flash_bank == PROGRAM_FLASH_BANK_1)
    {
        /* Map Program Flash Memory Bank 1 to lower region */
        NVMCONCLR = _NVMCON_PFSWAP_MASK;
    }
    else if (flash_bank == PROGRAM_FLASH_BANK_2)
    {
        /* Map Program Flash Memory Bank 2 to lower region */
        NVMCONSET = _NVMCON_PFSWAP_MASK;
    }
}

/* Function to Select Appropriate program flash bank based on the serial number */
void bootloader_ProgramFlashBankSelect( void )
{
    /* Map Program Flash Bank 1 to lower region after a reset */
    bootloader_ProgramFlashSwapBank(PROGRAM_FLASH_BANK_1);

    T_FLASH_SERIAL *lower_flash_serial = LOWER_FLASH_SERIAL_READ;
    T_FLASH_SERIAL *upper_flash_serial = UPPER_FLASH_SERIAL_READ;

    /* If Both Flash Panels do not have any Serial number */
    if( lower_flash_serial->checksum_start == FLASH_SERIAL_CHECKSUM_CLR &&
        upper_flash_serial->checksum_start == FLASH_SERIAL_CHECKSUM_CLR)
    {
        /* Program Checksum and initial ID's for both panels*/
        update_FlashSerial(0, LOWER_FLASH_SERIAL_START);
        update_FlashSerial(0, UPPER_FLASH_SERIAL_START);
    }
    /* If both the panels have proper checksum and serial number*/
    else if((lower_flash_serial->checksum_start == FLASH_SERIAL_CHECKSUM_START) &&
        (lower_flash_serial->checksum_end == FLASH_SERIAL_CHECKSUM_END) &&
        (upper_flash_serial->checksum_start == FLASH_SERIAL_CHECKSUM_START) &&
        (upper_flash_serial->checksum_end == FLASH_SERIAL_CHECKSUM_END))
    {
        /* If Upper flash panel has latest firmware */
        if(upper_flash_serial->serial > lower_flash_serial->serial)
        {
            /* Map Program Flash Bank 2 to lower region */
            bootloader_ProgramFlashSwapBank(PROGRAM_FLASH_BANK_2);

            /* Perform Dummy Read of Inactive panel(Upper Flash) after BankSwap
             * for Swap to take effect
             */
            dummy_read = *(uint32_t *)(UPPER_FLASH_START);
        }
    }
    /* Fallback Case when Panel 1 checksum and serial number is corrupted */
    else if((upper_flash_serial->checksum_start == FLASH_SERIAL_CHECKSUM_START) &&
            (upper_flash_serial->checksum_end == FLASH_SERIAL_CHECKSUM_END))
    {
        /* Map Program Flash Bank 2 to lower region */
        bootloader_ProgramFlashSwapBank(PROGRAM_FLASH_BANK_2);

        /* Perform Dummy Read of Inactive panel(Upper Flash) after BankSwap
         * for Swap to take effect
         */
        dummy_read = *(uint32_t *)(UPPER_FLASH_START);
    }
}

/* Function to Send the final response for reset command and trigger a reset */
static void trigger_Reset(void)
{
    UART2_WriteByte(BL_RESP_OK);

    while(UART2_TransmitComplete() == false);

    /* Perform system unlock sequence */ 
    SYSKEY = 0x00000000;
    SYSKEY = 0xAA996655;
    SYSKEY = 0x556699AA;

    RSWRSTSET = _RSWRST_SWRST_MASK;
    (void)RSWRST;
}

/* Function to Generate CRC by reading the firmware programmed into internal flash */
static uint32_t crc_generate(void)
{
    uint32_t   i, j, value;
    uint32_t   crc_tab[256];
    uint32_t   size    = unlock_end - unlock_begin;
    uint32_t   crc     = 0xffffffff;
    uint8_t    data;

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

    for (i = 0; i < size; i++)
    {
        data = *(uint8_t *)KVA0_TO_KVA1((unlock_begin + i));

        crc = crc_tab[(crc ^ data) & 0xff] ^ (crc >> 8);
    }
    return crc;
}

/* Function to receive application firmware via UART/USART */
static void input_task(void)
{
    static uint32_t ptr             = 0;
    static uint32_t size            = 0;
    static bool     header_received = false;
    uint8_t         *byte_buf       = (uint8_t *)&input_buffer[0];
    uint8_t         input_data      = 0;

    if (packet_received == true)
    {
        return;
    }

    if (UART2_ReceiverIsReady() == false)
    {
        return;
    }

    input_data = UART2_ReadByte();

    /* Check if 100 ms have elapsed */
    if (CORETIMER_CompareHasExpired())
    {
        header_received = false;
    }

    if (header_received == false)
    {
        byte_buf[ptr++] = input_data;

        if (ptr == HEADER_SIZE)
        {
            if (input_buffer[GUARD_OFFSET] != BTL_GUARD)
            {
                UART2_WriteByte(BL_RESP_ERROR);
            }
            else
            {
                size            = input_buffer[SIZE_OFFSET];
                input_command   = (uint8_t)input_buffer[CMD_OFFSET];
                header_received = true;
            }

            ptr = 0;
        }
    }
    else if (header_received == true)
    {
        if (ptr < size)
        {
            byte_buf[ptr++] = input_data;
        }

        if (ptr == size)
        {
            ptr = 0;
            size = 0;
            packet_received = true;
            header_received = false;
        }
    }

    CORETIMER_Start();
}

/* Function to process the received command */
static void command_task(void)
{
    uint32_t i;

    if (BL_CMD_UNLOCK == input_command)
    {
        uint32_t begin  = (input_buffer[ADDR_OFFSET] & OFFSET_ALIGN_MASK);

        uint32_t end    = begin + (input_buffer[SIZE_OFFSET] & SIZE_ALIGN_MASK);

        if (end > begin && end <= (FLASH_START + FLASH_LENGTH))
        {
            unlock_begin = begin;
            unlock_end = end;
            UART2_WriteByte(BL_RESP_OK);
        }
        else
        {
            unlock_begin = 0;
            unlock_end = 0;
            UART2_WriteByte(BL_RESP_ERROR);
        }
    }
    else if (BL_CMD_DATA == input_command)
    {
        flash_addr = (input_buffer[ADDR_OFFSET] & OFFSET_ALIGN_MASK);

        if (unlock_begin <= flash_addr && flash_addr < unlock_end)
        {
            for (i = 0; i < WORDS(DATA_SIZE); i++)
                flash_data[i] = input_buffer[i + DATA_OFFSET];

            flash_data_ready = true;
        }
        else
        {
            UART2_WriteByte(BL_RESP_ERROR);
        }
    }
    else if (BL_CMD_VERIFY == input_command)
    {
        uint32_t crc        = input_buffer[CRC_OFFSET];
        uint32_t crc_gen    = 0;

        crc_gen = crc_generate();

        if (crc == crc_gen)
            UART2_WriteByte(BL_RESP_CRC_OK);
        else
            UART2_WriteByte(BL_RESP_CRC_FAIL);
    }
    else if (BL_CMD_RESET == input_command)
    {
        trigger_Reset();
    }
    else if (BL_CMD_BKSWAP_RESET == input_command)
    {
        update_UpperFlashSerial();

        trigger_Reset();
    }
    else
    {
        UART2_WriteByte(BL_RESP_INVALID);
    }

    packet_received = false;
}

/* Function to program received application firmware data into internal flash */
static void flash_task(void)
{
    uint32_t addr       = flash_addr;
    uint32_t page       = 0;
    uint32_t write_idx  = 0;

    if (addr == LOWER_FLASH_SERIAL_SECTOR)
    {
        /* Send error response if active Flash Panels (Lower Flash)
         * Serial Sector is being erased.
         */
        flash_data_ready = false;

        UART2_WriteByte(BL_RESP_ERROR);
        
        return;
    }
    else if (addr == UPPER_FLASH_SERIAL_SECTOR)
    {
        upper_flash_serial_erased = true;
    }

    /* Erase the Current sector */
    NVM_PageErase(addr);

    /* Wait for erase to complete */
    while(NVM_IsBusy() == true);

    for (page = 0; page < PAGES_IN_ERASE_BLOCK; page++)
    {
        NVM_RowWrite(&flash_data[write_idx], addr);

        while(NVM_IsBusy() == true);

        addr += PAGE_SIZE;
        write_idx += WORDS(PAGE_SIZE);
    }

    flash_data_ready = false;

    UART2_WriteByte(BL_RESP_OK);
}

void run_Application(void)
{
    uint32_t msp            = *(uint32_t *)(APP_START_ADDRESS);

    void (*fptr)(void);

    /* Set default to APP_RESET_ADDRESS */
    fptr = (void (*)(void))APP_START_ADDRESS;

    if (msp == 0xffffffff)
    {
        return;
    }

    fptr();
}

bool __WEAK bootloader_Trigger(void)
{
    /* Function can be overriden with custom implementation */
    return false;
}

void bootloader_Start(void)
{
    CORETIMER_CompareSet(TIMER_COMPARE_VALUE);

    while (1)
    {
        input_task();

        if (flash_data_ready)
            flash_task();
        else if (packet_received)
            command_task();
    }
}
