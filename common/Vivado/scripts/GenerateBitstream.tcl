set CONFIG_PATH [lindex $argv 0]
set BITSTREAM_PATH [lindex $argv 1]

source $CONFIG_PATH

open_project $PROJECT_NAME.xpr
open_run impl_1

file mkdir $BITSTREAM_PATH
write_bitstream -force -bin_file $BITSTREAM_PATH/$TOP_NAME.bit
