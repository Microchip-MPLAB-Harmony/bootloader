<#if BTL_LIVE_UPDATE?? && BTL_LIVE_UPDATE == true>
    <#if (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "BareMetal">
        <#lt>    bootloader_${BTL_TYPE}_Tasks();
    <#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "FreeRTOS">
        <#assign BTL_STACK_SIZE = (BTL_RTOS_STACK_SIZE / 4) >
        <#lt>    xTaskCreate( _bootloader_${BTL_TYPE}_Tasks,
        <#lt>        "BOOTLOADER_${BTL_TYPE}_Tasks",
        <#lt>        ${BTL_STACK_SIZE},
        <#lt>        (void*)NULL,
        <#lt>        ${BTL_RTOS_TASK_PRIORITY},
        <#lt>        (TaskHandle_t*)NULL
        <#lt>    );
    <#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "ThreadX">
        <#lt>    tx_byte_allocate(&byte_pool_0,
        <#lt>       (VOID **) &_bootloader_Task_Stk_Ptr,
        <#lt>        ${BTL_RTOS_STACK_SIZE},
        <#lt>        TX_NO_WAIT);
    
        <#lt>    tx_thread_create(&_bootloder_Task_TCB,
        <#lt>        "BOOTLOADER_${BTL_TYPE}_Tasks",
        <#lt>        _bootloader_${BTL_TYPE}_Tasks,
        <#lt>        0,
        <#lt>        _ootloaderb_Task_Stk_Ptr,
        <#lt>        ${BTL_RTOS_STACK_SIZE},
        <#lt>        ${BTL_RTOS_TASK_PRIORITY},
        <#lt>        ${BTL_RTOS_TASK_PRIORITY},
        <#lt>        TX_NO_TIME_SLICE,
        <#lt>        TX_AUTO_START
        <#lt>        );
    <#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "MicriumOSIII">
        <#assign BTL_RTOS_TASK_OPTIONS = "OS_OPT_TASK_NONE" + BTL_RTOS_TASK_OPT_STK_CHK?then(' | OS_OPT_TASK_STK_CHK', '') + BTL_RTOS_TASK_OPT_STK_CLR?then(' | OS_OPT_TASK_STK_CLR', '') + BTL_RTOS_TASK_OPT_SAVE_FP?then(' | OS_OPT_TASK_SAVE_FP', '') + BTL_RTOS_TASK_OPT_NO_TLS?then(' | OS_OPT_TASK_NO_TLS', '')>
        <#lt>    OSTaskCreate((OS_TCB      *)&_bootloader_${BTL_TYPE}_Tasks_TCB,
        <#lt>                 (CPU_CHAR    *)"BOOTLOADER_${BTL_TYPE}_Tasks",
        <#lt>                 (OS_TASK_PTR  )_bootloader_${BTL_TYPE}_Tasks,
        <#lt>                 (void        *)0,
        <#lt>                 (OS_PRIO      )${BTL_RTOS_TASK_PRIORITY},
        <#lt>                 (CPU_STK     *)&_bootloader_${BTL_TYPE}_TasksStk[0],
        <#lt>                 (CPU_STK_SIZE )0u,
        <#lt>                 (CPU_STK_SIZE )${BTL_RTOS_STACK_SIZE},
        <#if MicriumOSIII.UCOSIII_CFG_TASK_Q_EN == true>
        <#lt>                 (OS_MSG_QTY   )${BTL_RTOS_TASK_MSG_QTY},
        <#else>
        <#lt>                 (OS_MSG_QTY   )0u,
        </#if>
        <#if MicriumOSIII.UCOSIII_CFG_SCHED_ROUND_ROBIN_EN == true>
        <#lt>                 (OS_TICK      )${BTL_RTOS_TASK_TIME_QUANTA},
        <#else>
        <#lt>                 (OS_TICK      )0u,
        </#if>
        <#lt>                 (void        *)0,
        <#lt>                 (OS_OPT       )(${BTL_RTOS_TASK_OPTIONS}),
        <#lt>                 (OS_ERR      *)&os_err);
    <#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "MbedOS">
        <#lt>    Thread BTL_thread((osPriority)(osPriorityNormal + (${BTL_RTOS_TASK_PRIORITY} - 1)), ${BTL_RTOS_STACK_SIZE}, NULL, "_bootloader_${BTL_TYPE}_Tasks");
        <#lt>    BTL_thread.start(callback(_bootloader_${BTL_TYPE}_Tasks, (void *)NULL));
    </#if>
<#else>
    <#lt>    bootloader_${BTL_TYPE}_Tasks();
</#if>
