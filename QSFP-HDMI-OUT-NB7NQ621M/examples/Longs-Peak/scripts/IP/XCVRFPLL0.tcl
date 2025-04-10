create_system XCVRFPLL0

add_instance inst altera_xcvr_fpll_a10
set_instance_property inst AUTO_EXPORT true

# General
set_instance_parameter_value inst gui_enable_fractional 1

# Reference Clock
set_instance_parameter_value inst gui_desired_refclk_frequency 644.53125

# Settings
set_instance_parameter_value inst gui_bw_sel low

# Output Frequency
set_instance_parameter_value inst gui_hssi_output_clock_frequency $XCVRFPLL0_OUTPUT_CLOCK_FREQUENCY

save_system $SYSTEM_PATH/XCVRFPLL0.qsys
