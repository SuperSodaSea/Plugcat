package require -exact qsys 14.0

set SYSTEM_PATH [lindex $argv 0]
set RESOLUTION [lindex $argv 1]
set REFRESH_RATE [lindex $argv 2]

set_project_property DEVICE_FAMILY "Stratix 10"
set_project_property DEVICE 1SG280LN2F43E2VG

# TODO: Support data rate below 1.0Gbps
# "1920x1080@30" {
#     set XCVR0_DATA_RATE 742.5
#     set XCVRFPLL0_OUTPUT_CLOCK_FREQUENCY 371.25
# }

switch "$RESOLUTION@$REFRESH_RATE" {
    "2560x1440@30" {
        set XCVR0_DATA_RATE 1215.84
        set XCVRFPLL0_OUTPUT_CLOCK_FREQUENCY 607.92
    }
    "1920x1080@60" {
        set XCVR0_DATA_RATE 1485
        set XCVRFPLL0_OUTPUT_CLOCK_FREQUENCY 742.5
    }
    "2560x1440@60" {
        set XCVR0_DATA_RATE 2431.68
        set XCVRFPLL0_OUTPUT_CLOCK_FREQUENCY 1215.84
    }
    "1920x1080@120" -
    "3840x2160@30" {
        set XCVR0_DATA_RATE 2970
        set XCVRFPLL0_OUTPUT_CLOCK_FREQUENCY 1485
    }
    "1920x1080@144" {
        set XCVR0_DATA_RATE 3564
        set XCVRFPLL0_OUTPUT_CLOCK_FREQUENCY 1782
    }
    "2560x1440@120" {
        set XCVR0_DATA_RATE 4863.36
        set XCVRFPLL0_OUTPUT_CLOCK_FREQUENCY 2431.68
    }
    "2560x1440@144" {
        set XCVR0_DATA_RATE 5836.032
        set XCVRFPLL0_OUTPUT_CLOCK_FREQUENCY 2918.016
    }
    "1920x1080@240" -
    "3840x2160@60" {
        set XCVR0_DATA_RATE 5940
        set XCVRFPLL0_OUTPUT_CLOCK_FREQUENCY 2970
    }
    default {
        error "Invalid video mode $RESOLUTION@$REFRESH_RATE"
    }
}

foreach ip [glob ../scripts/IP/*.tcl] {
    source $ip
}
