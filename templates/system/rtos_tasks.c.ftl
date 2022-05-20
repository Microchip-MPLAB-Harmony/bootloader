<#if (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "FreeRTOS">
    <#lt>void _bootloader_${BTL_TYPE}_Tasks(  void *pvParameters  )
    <#lt>{
    <#lt>    while(1)
    <#lt>    {
    <#lt>        bootloader_${BTL_TYPE}_Tasks();
             <#if BTL_RTOS_USE_DELAY >
    <#lt>        vTaskDelay(${BTL_RTOS_DELAY} / portTICK_PERIOD_MS);
             </#if>
    <#lt>    }
    <#lt>}
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "ThreadX">
    <#lt>TX_THREAD      _bootloader_Task_TCB;
    <#lt>uint8_t*       _bootloader_Task_Stk_Ptr;

    <#lt>static void _bootloader_${BTL_TYPE}_Tasks( ULONG thread_input )
    <#lt>{
    <#lt>    while(1)
    <#lt>    {
    <#lt>        bootloader_${BTL_TYPE}_Tasks(void);
    <#if BTL_RTOS_USE_DELAY == true>
        <#lt>        tx_thread_sleep((ULONG)(${BTL_RTOS_DELAY} / (TX_TICK_PERIOD_MS)));
    </#if>
    <#lt>    }
    <#lt>}
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "MicriumOSIII">
    <#lt>OS_TCB  _bootloader_${BTL_TYPE}_Tasks_TCB;
    <#lt>CPU_STK _bootloader_${BTL_TYPE}_TasksStk[${BTL_RTOS_STACK_SIZE}];

    <#lt>void _bootloader_${BTL_TYPE}_Tasks(  void *pvParameters  )
    <#lt>{
    <#if BTL_RTOS_USE_DELAY == true>
        <#lt>    OS_ERR os_err;
    </#if>
    <#lt>    while(1)
    <#lt>    {
    <#lt>        bootloader_${BTL_TYPE}_Tasks();
    <#if BTL_RTOS_USE_DELAY == true>
        <#lt>        OSTimeDly(${BTL_RTOS_DELAY} , OS_OPT_TIME_DLY, &os_err);
    </#if>
    <#lt>    }
    <#lt>}
<#elseif (HarmonyCore.SELECT_RTOS)?? && HarmonyCore.SELECT_RTOS == "MbedOS">
    <#lt>void _bootloader_${BTL_TYPE}_Tasks( void *pvParameters )
    <#lt>{
    <#lt>    while(1)
    <#lt>    {
    <#lt>        bootloader_${BTL_TYPE}_Tasks(sysObj.drvMemory${INDEX?string});
    <#if BTL_RTOS_USE_DELAY == true>
        <#lt>    thread_sleep_for((uint32_t)(${BTL_RTOS_DELAY} / MBED_OS_TICK_PERIOD_MS));
    </#if>
    <#lt>    }
    <#lt>}
</#if>