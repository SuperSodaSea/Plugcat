set_location_assignment PIN_M23 -to clock_125
set_instance_assignment -name IO_STANDARD SSTL-135 -to clock_125

set_location_assignment PIN_T7 -to qsfp_refclk
set_location_assignment PIN_T6 -to qsfp_refclk(n)
set_instance_assignment -name IO_STANDARD LVDS -to qsfp_refclk
