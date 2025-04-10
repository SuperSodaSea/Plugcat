set JOBS [lindex $argv 0]
set RESOLUTION [lindex $argv 1]
set REFRESH_RATE [lindex $argv 2]

project_new Storey-Peak-Example -overwrite

set_global_assignment -name FAMILY "Stratix V"
set_global_assignment -name DEVICE 5SGSKF40I3LNAC

set_global_assignment -name NUM_PARALLEL_PROCESSORS $JOBS

set_global_assignment -name VERILOG_MACRO RESOLUTION="$RESOLUTION"
set_global_assignment -name VERILOG_MACRO REFRESH_RATE=$REFRESH_RATE

set_global_assignment -name TOP_LEVEL_ENTITY Top

set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output

foreach ip [glob ip/*.qsys] {
    set_global_assignment -name QSYS_FILE $ip
}

foreach v [glob ../../../../common/Verilog/*/*.v] {
    set_global_assignment -name VERILOG_FILE $v
}

foreach sv [glob generated/*.sv] {
    set_global_assignment -name SYSTEMVERILOG_FILE $sv
}

foreach v [glob ../sources/*.v] {
    set_global_assignment -name VERILOG_FILE $v
}

foreach tcl [glob ../../../../common/Quartus/constraints/Storey-Peak/*.tcl] {
    source $tcl
}

foreach sdc [glob ../constraints/*.sdc] {
    set_global_assignment -name SDC_FILE $sdc
}
