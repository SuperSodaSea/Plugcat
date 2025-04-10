package require -exact qsys 14.0

set SYSTEM_PATH [lindex $argv 0]
set RESOLUTION [lindex $argv 1]
set REFRESH_RATE [lindex $argv 2]

set_project_property DEVICE_FAMILY "Stratix V"
set_project_property DEVICE 5SGSMD5K2F40I3L

switch "$RESOLUTION@$REFRESH_RATE" {
    "1920x1080@30" {
        set XCVR0_DATA_RATE 742.5
        set XCVR0_REFERENCE_CLOCK_FREQUENCY "148.5 MHz"
    }
    "2560x1440@30" {
        set XCVR0_DATA_RATE 1215.84
        set XCVR0_REFERENCE_CLOCK_FREQUENCY "121.584 MHz"
    }
    "1920x1080@60" {
        set XCVR0_DATA_RATE 1485
        set XCVR0_REFERENCE_CLOCK_FREQUENCY "148.5 MHz"
    }
    "2560x1440@60" {
        set XCVR0_DATA_RATE 2431.68
        set XCVR0_REFERENCE_CLOCK_FREQUENCY "121.584 MHz"
    }
    "1920x1080@120" -
    "3840x2160@30" {
        set XCVR0_DATA_RATE 2970
        set XCVR0_REFERENCE_CLOCK_FREQUENCY "148.5 MHz"
    }
    "1920x1080@144" {
        set XCVR0_DATA_RATE 3564
        set XCVR0_REFERENCE_CLOCK_FREQUENCY "148.5 MHz"
    }
    "2560x1440@120" {
        set XCVR0_DATA_RATE 4863.36
        set XCVR0_REFERENCE_CLOCK_FREQUENCY "121.584 MHz"
    }
    "2560x1440@144" {
        set XCVR0_DATA_RATE 5836.032
        set XCVR0_REFERENCE_CLOCK_FREQUENCY "145.9008 MHz"
    }
    "1920x1080@240" -
    "3840x2160@60" {
        set XCVR0_DATA_RATE 5940
        set XCVR0_REFERENCE_CLOCK_FREQUENCY "148.5 MHz"
    }
    default {
        error "Invalid video mode $RESOLUTION@$REFRESH_RATE"
    }
}

foreach ip [glob ../scripts/IP/*.tcl] {
    source $ip
}
