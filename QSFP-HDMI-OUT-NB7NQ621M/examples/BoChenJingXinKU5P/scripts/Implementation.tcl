set JOBS [lindex $argv 0]

set PROJECT_PATH [file normalize [file dirname [info script]]/..]

source $PROJECT_PATH/scripts/Config.tcl

open_project $PROJECT_NAME.xpr
reset_run impl_1
launch_runs -jobs $JOBS impl_1
wait_on_run impl_1
