set CONFIG_PATH [lindex $argv 0]
set BITSTREAM_PATH [lindex $argv 1]

source $CONFIG_PATH

open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target

set HW_DEVICE [lindex [get_hw_devices $HW_DEVICE_NAME] 0]
current_hw_device $HW_DEVICE

set CFGMEM_PART [lindex [get_cfgmem_parts $CFGMEM_PART_NAME] 0]

set HW_CFGMEM [create_hw_cfgmem -hw_device $HW_DEVICE -mem_dev $CFGMEM_PART]

set_property PROGRAM.FILES $BITSTREAM_PATH/$TOP_NAME.bin $HW_CFGMEM
set_property PROGRAM.ADDRESS_RANGE use_file $HW_CFGMEM
set_property PROGRAM.BLANK_CHECK 0 $HW_CFGMEM
set_property PROGRAM.ERASE 1 $HW_CFGMEM
set_property PROGRAM.CFG_PROGRAM 1 $HW_CFGMEM
set_property PROGRAM.VERIFY 1 $HW_CFGMEM
set_property PROGRAM.UNUSED_PIN_TERMINATION pull-none $HW_CFGMEM

program_hw_devices $HW_DEVICE

program_hw_cfgmem -hw_cfgmem $HW_CFGMEM

refresh_hw_device $HW_DEVICE

boot_hw_device $HW_DEVICE
