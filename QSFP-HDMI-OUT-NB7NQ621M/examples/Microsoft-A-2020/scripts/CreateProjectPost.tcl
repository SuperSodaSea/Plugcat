project_open Microsoft-A-2020-Example

foreach v [glob ../../../../common/Verilog/*/*.v] {
    set_global_assignment -name VERILOG_FILE $v
}

foreach sv [glob generated/*.sv] {
    set_global_assignment -name SYSTEMVERILOG_FILE $sv
}

foreach v [glob ../sources/*.v] {
    set_global_assignment -name VERILOG_FILE $v
}

foreach tcl [glob ../../../../common/Quartus/constraints/Microsoft-A-2020/*.tcl] {
    source $tcl
}

foreach sdc [glob ../constraints/*.sdc] {
    set_global_assignment -name SDC_FILE $sdc
}
