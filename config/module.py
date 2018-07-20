def loadModule():
    print("Load Module: Bootloader")

    btlComponent = Module.CreateComponent("btl", "Bootloader", "/Bootloader/", "config/bootloader.py")
    btlComponent.addDependency("btl_UART_dependency", "UART")
    btlComponent.addDependency("btl_I2C_dependency", "I2C")
    btlComponent.addDependency("btl_MEMORY_dependency", "MEMORY")