create_system PLL0

add_instance inst altera_iopll
set_instance_property inst AUTO_EXPORT true

set_instance_parameter_value inst gui_reference_clock_frequency 100.0
set_instance_parameter_value inst gui_output_clock_frequency0 200.0

set_instance_parameter_value inst gui_pll_auto_reset true

save_system $SYSTEM_PATH/PLL0.qsys
