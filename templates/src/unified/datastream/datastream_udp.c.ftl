/*******************************************************************************
 Data Stream UDP Source File

  File Name:
    datastream_udp.c

  Summary:
    Data Stream UDP source

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
#include "tcpip/tcpip.h"
#include "definitions.h"

#define BOOTLOADER_UDP_PORT_NUMBER      "${BTL_UDP_PORT_NUMBER}"

typedef struct
{
    DATASTREAM_HANDLE udpHandle;
    eDIR currDir;
    UDP_SOCKET udpSocket;
    bool connected;
    uint8_t *rxBuffer;
    uint32_t rxMaxSize;
    uint8_t *txBuffer;
    uint32_t txMaxSize;
    uintptr_t context;
    DATASTREAM_HandlerType handler;
} UDP_DATA;

static UDP_DATA udpData;

void DATASTREAM_Tasks(void)
{

    uint16_t avlBytes = 0;

    if (udpData.connected == false)
    {
        return;
    }

    if (TX == udpData.currDir)
    {
        if(TCPIP_UDP_PutIsReady(udpData.udpSocket) >= udpData.txMaxSize)
        {
            (void) TCPIP_UDP_ArrayPut(udpData.udpSocket, udpData.txBuffer, (uint16_t)udpData.txMaxSize);
            (void) TCPIP_UDP_Flush(udpData.udpSocket);
            udpData.currDir = IDLE;
            udpData.handler(DATASTREAM_BUFFER_EVENT_COMPLETE, (DATASTREAM_HANDLE)udpData.udpHandle, udpData.txMaxSize);

        }
    }

    if (RX == udpData.currDir)
    {
        if (TCPIP_UDP_GetIsReady(udpData.udpSocket) != 0U)
        {
            avlBytes = TCPIP_UDP_GetIsReady(udpData.udpSocket);

            avlBytes = TCPIP_UDP_ArrayGet(udpData.udpSocket, udpData.rxBuffer, avlBytes);
            udpData.currDir = IDLE;
            udpData.handler(DATASTREAM_BUFFER_EVENT_COMPLETE, (DATASTREAM_HANDLE)udpData.udpHandle, avlBytes);
        }
    }
}

/* MISRA C-2012 Rule 21.7 deviated:1 Deviation record ID -  H3_MISRAC_2012_R_21_7_DR_1 */
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block deviate:1 "MISRA C-2012 Rule 21.7" "H3_MISRAC_2012_R_21_7_DR_1"    
</#if>

DATASTREAM_HANDLE DATASTREAM_Open(const DRV_IO_INTENT ioIntent)
{
    SYS_STATUS          tcpipStat;
    static IPV4_ADDR    dwLastIP[2] = { {0xFFFFFFFFU}, {0XFFFFFFFFU} };
    IPV4_ADDR           ipAddr;
    TCPIP_NET_HANDLE    netH;
    int                 i, nNets;

    udpData.udpHandle = DATASTREAM_HANDLE_INVALID;

    tcpipStat = TCPIP_STACK_Status(sysObj.tcpip);

    if(((uint32_t)tcpipStat < 0U) || (tcpipStat != SYS_STATUS_READY))
    {
        return (udpData.udpHandle);
    }

    // now that the stack is ready we can check the available interfaces
    nNets = TCPIP_STACK_NumberOfNetworksGet();

    for (i = 0; i < nNets; i++)
    {
        netH = TCPIP_STACK_IndexToNet(i);

        ipAddr.Val = TCPIP_STACK_NetAddress(netH);

        if(dwLastIP[i].Val != ipAddr.Val)
        {
            dwLastIP[i].Val = ipAddr.Val;

            if (ipAddr.v[0] != 0U && ipAddr.v[0] != 169U) // Wait for a Valid IP
            {
                UDP_PORT port = (uint16_t)atoi(BOOTLOADER_UDP_PORT_NUMBER);

                udpData.udpSocket = TCPIP_UDP_ServerOpen(IP_ADDRESS_TYPE_IPV4,
                     port,
                    (IP_MULTI_ADDRESS*) 0);

                if (udpData.udpSocket == INVALID_SOCKET)
                {
                    return(DATASTREAM_HANDLE_INVALID);
                }

                udpData.connected = true;

                udpData.udpHandle = 0;

                break;
            }
        }
    }

    return(udpData.udpHandle);
}

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 21.7"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>    
</#if>
/* MISRAC 2012 deviation block end */

void DATASTREAM_Close(void)
{
    if (udpData.connected)
    {
        (void) TCPIP_UDP_Close(udpData.udpSocket);
        TCPIP_STACK_Deinitialize(sysObj.tcpip);
    }
}

DRV_CLIENT_STATUS DATASTREAM_ClientStatus(DATASTREAM_HANDLE handle)
{
    if(TCPIP_UDP_IsConnected(udpData.udpSocket) == true)
    {
        return DRV_CLIENT_STATUS_READY;
    }

    return DRV_CLIENT_STATUS_BUSY;
}

int DATASTREAM_Data_Read(DATASTREAM_HANDLE handle, uint8_t *buffer, const uint32_t rxSize)
{
    udpData.rxBuffer = buffer;
    udpData.rxMaxSize = rxSize;
    udpData.currDir = RX;
    return(0);
}

int DATASTREAM_Data_Write(DATASTREAM_HANDLE handle, uint8_t *buffer, const uint32_t txSize)
{
    udpData.txBuffer = buffer;
    udpData.txMaxSize = txSize;
    udpData.currDir = TX;
    return(0);
}

/* MISRA C-2012 Rule 11.1, 11.8 deviated below. Deviation record ID -  
   H3_MISRAC_2012_R_11_1_DR_1 & H3_MISRAC_2012_R_11_8_DR_1*/
<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunknown-pragmas"
</#if>
#pragma coverity compliance block \
(deviate:1 "MISRA C-2012 Rule 11.1" "H3_MISRAC_2012_R_11_1_DR_1" )\
(deviate:1 "MISRA C-2012 Rule 11.8" "H3_MISRAC_2012_R_11_8_DR_1" )   
</#if>

void DATASTREAM_BufferEventHandlerSet
(
    const DATASTREAM_HANDLE hClient,
    const void * eventHandler,
    const uintptr_t context
)
{
    udpData.handler = (DATASTREAM_HandlerType)eventHandler;
    udpData.context = context;
}

<#if core.COVERITY_SUPPRESS_DEVIATION?? && core.COVERITY_SUPPRESS_DEVIATION>
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.1"
#pragma coverity compliance end_block "MISRA C-2012 Rule 11.8"
<#if core.COMPILER_CHOICE == "XC32">
#pragma GCC diagnostic pop
</#if>    
</#if> 
/* MISRAC 2012 deviation block end */