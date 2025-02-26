set BITSTREAM_PATH [lindex $argv 0]

set PROJECT_PATH [file normalize [file dirname [info script]]/..]

source $PROJECT_PATH/scripts/Config.tcl

open_project $PROJECT_NAME.xpr
open_run impl_1

file mkdir $BITSTREAM_PATH
write_bitstream -force -bin_file $BITSTREAM_PATH/$TOP_NAME.bit
