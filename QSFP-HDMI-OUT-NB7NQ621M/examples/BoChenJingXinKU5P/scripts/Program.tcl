set PROJECT_PATH [file normalize [file dirname [info script]]/..]

set BITSTREAM_PATH [lindex $argv 0]

source $PROJECT_PATH/scripts/Config.tcl

open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target

set HW_DEVICE [lindex [get_hw_devices $HW_DEVICE_NAME] 0]
current_hw_device $HW_DEVICE

set_property PROGRAM.FILE $BITSTREAM_PATH/$TOP_NAME.bit $HW_DEVICE

program_hw_devices $HW_DEVICE

refresh_hw_device $HW_DEVICE
