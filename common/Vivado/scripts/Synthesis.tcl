set CONFIG_PATH [lindex $argv 0]
set JOBS [lindex $argv 1]

source $CONFIG_PATH

open_project $PROJECT_NAME.xpr
reset_run synth_1
launch_runs -jobs $JOBS synth_1
wait_on_run synth_1
