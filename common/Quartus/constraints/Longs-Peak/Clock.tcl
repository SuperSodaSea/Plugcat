set_location_assignment PIN_AP20 -to clock_100
set_instance_assignment -name IO_STANDARD "1.8 V" -to clock_100
set_instance_assignment -name GLOBAL_SIGNAL GLOBAL_CLOCK -to clock_100

set_location_assignment PIN_U29 -to qsfp_refclk
set_location_assignment PIN_U28 -to qsfp_refclk(n)
set_instance_assignment -name IO_STANDARD LVDS -to qsfp_refclk
