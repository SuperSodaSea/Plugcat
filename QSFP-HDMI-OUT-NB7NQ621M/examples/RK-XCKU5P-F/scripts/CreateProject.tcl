set RESOLUTION [lindex $argv 0]
set REFRESH_RATE [lindex $argv 1]

set PROJECT_PATH [file normalize [file dirname [info script]]/..]

source $PROJECT_PATH/scripts/Config.tcl

create_project -force -part $PART_NAME $PROJECT_NAME

source $PROJECT_PATH/scripts/IP/GTWizard0.tcl
source $PROJECT_PATH/scripts/IP/MMCM0.tcl

set_property VERILOG_DEFINE [list \
    RESOLUTION="$RESOLUTION" \
    REFRESH_RATE=$REFRESH_RATE \
] [get_filesets sources_1]

set_property top $TOP_NAME [current_fileset]

add_files -fileset sources_1 \
    [glob $PROJECT_PATH/../../../common/Verilog/*/*.v] \
    [glob $PROJECT_PATH/build/generated/*.sv] \
    [glob $PROJECT_PATH/sources/*.v]

add_files -fileset constrs_1 \
    [glob $PROJECT_PATH/../../../common/Vivado/constraints/RK-XCKU5P-F/*.xdc] \
    [glob $PROJECT_PATH/constraints/*.xdc]
