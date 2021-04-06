# coding: utf-8
"""*****************************************************************************
* Copyright (C) 2021 Microchip Technology Inc. and its subsidiaries.
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
*****************************************************************************"""

def genRtosTask(symbol, event):
    component = symbol.getComponent()

    gen_rtos_task = False

    if (Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") != "BareMetal"):
        if (component.getSymbolByID("BTL_LIVE_UPDATE").getValue() == True):
            gen_rtos_task = True

    symbol.setEnabled(gen_rtos_task)

def showRTOSMenu(symbol, event):
    component = symbol.getComponent()

    show_rtos_menu = False

    if (Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") != "BareMetal"):
        if (component.getSymbolByID("BTL_LIVE_UPDATE").getValue() == True):
            show_rtos_menu = True

    symbol.setVisible(show_rtos_menu)

def btlRtosMicriumOSIIIAppTaskVisibility(symbol, event):
    if (event["value"] == "MicriumOSIII"):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def btlRtosMicriumOSIIITaskOptVisibility(symbol, event):
    symbol.setVisible(event["value"])

def setVisibility(symbol, event):
    symbol.setVisible(event["value"])

def getActiveRtos():
    activeComponents = Database.getActiveComponentIDs()

    for i in range(0, len(activeComponents)):
        if (activeComponents[i] == "FreeRTOS"):
            return "FreeRTOS"
        elif (activeComponents[i] == "ThreadX"):
            return "ThreadX"
        elif (activeComponents[i] == "MicriumOSIII"):
            return "MicriumOSIII"
        elif (activeComponents[i] == "MbedOS"):
            return "MbedOS"

def generateRTOSSymbols(bootloaderComponent, liveUpdateEnabled):

    enable_rtos_settings = False

    if (liveUpdateEnabled == True):
        if (Database.getSymbolValue("HarmonyCore", "SELECT_RTOS") != "BareMetal"):
            enable_rtos_settings = True

    # RTOS Settings
    btlRTOSMenu = bootloaderComponent.createMenuSymbol("BTL_RTOS_MENU", None)
    btlRTOSMenu.setLabel("RTOS settings")
    btlRTOSMenu.setDescription("RTOS settings")
    btlRTOSMenu.setVisible(enable_rtos_settings)
    btlRTOSMenu.setDependencies(showRTOSMenu, ["HarmonyCore.SELECT_RTOS", "BTL_LIVE_UPDATE"])

    btlRTOSStackSize = bootloaderComponent.createIntegerSymbol("BTL_RTOS_STACK_SIZE", btlRTOSMenu)
    btlRTOSStackSize.setLabel("Stack Size (in bytes)")
    btlRTOSStackSize.setDefaultValue(4096)

    btlRTOSMsgQSize = bootloaderComponent.createIntegerSymbol("BTL_RTOS_TASK_MSG_QTY", btlRTOSMenu)
    btlRTOSMsgQSize.setLabel("Maximum Message Queue Size")
    btlRTOSMsgQSize.setDescription("A µC/OS-III task contains an optional internal message queue (if OS_CFG_TASK_Q_EN is set to DEF_ENABLED in os_cfg.h). This argument specifies the maximum number of messages that the task can receive through this message queue. The user may specify that the task is unable to receive messages by setting this argument to 0")
    btlRTOSMsgQSize.setDefaultValue(0)
    btlRTOSMsgQSize.setVisible(getActiveRtos() == "MicriumOSIII")
    btlRTOSMsgQSize.setDependencies(btlRtosMicriumOSIIIAppTaskVisibility, ["HarmonyCore.SELECT_RTOS"])

    btlRTOSTaskTimeQuanta = bootloaderComponent.createIntegerSymbol("BTL_RTOS_TASK_TIME_QUANTA", btlRTOSMenu)
    btlRTOSTaskTimeQuanta.setLabel("Task Time Quanta")
    btlRTOSTaskTimeQuanta.setDescription("The amount of time (in clock ticks) for the time quanta when Round Robin is enabled. If you specify 0, then the default time quanta will be used which is the tick rate divided by 10.")
    btlRTOSTaskTimeQuanta.setDefaultValue(0)
    btlRTOSTaskTimeQuanta.setVisible(getActiveRtos() == "MicriumOSIII")
    btlRTOSTaskTimeQuanta.setDependencies(btlRtosMicriumOSIIIAppTaskVisibility, ["HarmonyCore.SELECT_RTOS"])

    btlRTOSTaskPriority = bootloaderComponent.createIntegerSymbol("BTL_RTOS_TASK_PRIORITY", btlRTOSMenu)
    btlRTOSTaskPriority.setLabel("Task Priority")
    btlRTOSTaskPriority.setDefaultValue(1)

    btlRTOSTaskDelay = bootloaderComponent.createBooleanSymbol("BTL_RTOS_USE_DELAY", btlRTOSMenu)
    btlRTOSTaskDelay.setLabel("Use Task Delay?")
    btlRTOSTaskDelay.setDefaultValue(True)

    btlRTOSTaskDelayVal = bootloaderComponent.createIntegerSymbol("BTL_RTOS_DELAY", btlRTOSTaskDelay)
    btlRTOSTaskDelayVal.setLabel("Task Delay")
    btlRTOSTaskDelayVal.setDefaultValue(1)
    btlRTOSTaskDelayVal.setVisible((btlRTOSTaskDelay.getValue() == True))
    btlRTOSTaskDelayVal.setDependencies(setVisibility, ["BTL_RTOS_USE_DELAY"])

    btlRTOSTaskSpecificOpt = bootloaderComponent.createBooleanSymbol("BTL_RTOS_TASK_OPT_NONE", btlRTOSMenu)
    btlRTOSTaskSpecificOpt.setLabel("Task Specific Options")
    btlRTOSTaskSpecificOpt.setDescription("Contains task-specific options. Each option consists of one bit. The option is selected when the bit is set. The current version of µC/OS-III supports the following options:")
    btlRTOSTaskSpecificOpt.setDefaultValue(True)
    btlRTOSTaskSpecificOpt.setVisible(getActiveRtos() == "MicriumOSIII")
    btlRTOSTaskSpecificOpt.setDependencies(btlRtosMicriumOSIIIAppTaskVisibility, ["HarmonyCore.SELECT_RTOS"])

    btlRTOSTaskStkChk = bootloaderComponent.createBooleanSymbol("BTL_RTOS_TASK_OPT_STK_CHK", btlRTOSTaskSpecificOpt)
    btlRTOSTaskStkChk.setLabel("Stack checking is allowed for the task")
    btlRTOSTaskStkChk.setDescription("Specifies whether stack checking is allowed for the task")
    btlRTOSTaskStkChk.setDefaultValue(True)
    btlRTOSTaskStkChk.setDependencies(btlRtosMicriumOSIIITaskOptVisibility, ["BTL_RTOS_TASK_OPT_NONE"])

    btlRTOSTaskStkClr = bootloaderComponent.createBooleanSymbol("BTL_RTOS_TASK_OPT_STK_CLR", btlRTOSTaskSpecificOpt)
    btlRTOSTaskStkClr.setLabel("Stack needs to be cleared")
    btlRTOSTaskStkClr.setDescription("Specifies whether the stack needs to be cleared")
    btlRTOSTaskStkClr.setDefaultValue(True)
    btlRTOSTaskStkClr.setDependencies(btlRtosMicriumOSIIITaskOptVisibility, ["BTL_RTOS_TASK_OPT_NONE"])

    btlRTOSTaskSaveFp = bootloaderComponent.createBooleanSymbol("BTL_RTOS_TASK_OPT_SAVE_FP", btlRTOSTaskSpecificOpt)
    btlRTOSTaskSaveFp.setLabel("Floating-point registers needs to be saved")
    btlRTOSTaskSaveFp.setDescription("Specifies whether floating-point registers are saved. This option is only valid if the processor has floating-point hardware and the processor-specific code saves the floating-point registers")
    btlRTOSTaskSaveFp.setDefaultValue(False)
    btlRTOSTaskSaveFp.setDependencies(btlRtosMicriumOSIIITaskOptVisibility, ["BTL_RTOS_TASK_OPT_NONE"])

    btlRTOSTaskNoTls = bootloaderComponent.createBooleanSymbol("BTL_RTOS_TASK_OPT_NO_TLS", btlRTOSTaskSpecificOpt)
    btlRTOSTaskNoTls.setLabel("TLS (Thread Local Storage) support needed for the task")
    btlRTOSTaskNoTls.setDescription("If the caller doesn’t want or need TLS (Thread Local Storage) support for the task being created. If you do not include this option, TLS will be supported by default. TLS support was added in V3.03.00")
    btlRTOSTaskNoTls.setDefaultValue(False)
    btlRTOSTaskNoTls.setDependencies(btlRtosMicriumOSIIITaskOptVisibility, ["BTL_RTOS_TASK_OPT_NONE"])

    ############################################################################
    #### Code Generation ####
    ############################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    btlSystemRtosTasksFile = bootloaderComponent.createFileSymbol("BTL_SYS_RTOS_TASK", None)
    btlSystemRtosTasksFile.setType("STRING")
    btlSystemRtosTasksFile.setOutputName("core.LIST_SYSTEM_RTOS_TASKS_C_DEFINITIONS")
    btlSystemRtosTasksFile.setSourcePath("../bootloader/templates/system/rtos_tasks.c.ftl")
    btlSystemRtosTasksFile.setMarkup(True)
    btlSystemRtosTasksFile.setEnabled(enable_rtos_settings)
    btlSystemRtosTasksFile.setDependencies(genRtosTask, ["HarmonyCore.SELECT_RTOS", "BTL_LIVE_UPDATE"])
