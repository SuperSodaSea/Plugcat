set JOBS [lindex $argv 0]

set PROJECT_PATH [file normalize [file dirname [info script]]/..]

source $PROJECT_PATH/scripts/Config.tcl

open_project $PROJECT_NAME.xpr
reset_run synth_1
launch_runs -jobs $JOBS synth_1
wait_on_run synth_1
