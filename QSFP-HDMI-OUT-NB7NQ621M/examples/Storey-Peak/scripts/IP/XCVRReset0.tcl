create_system XCVRReset0

add_instance inst altera_xcvr_reset_control
set_instance_property inst AUTO_EXPORT true

# General Options
set_instance_parameter_value inst CHANNELS 4
set_instance_parameter_value inst PLLS 1
set_instance_parameter_value inst SYS_CLK_IN_MHZ 200

# TX PLL
set_instance_parameter_value inst TX_PLL_ENABLE 1

# TX Channel
set_instance_parameter_value inst TX_ENABLE 1

# RX Channel
set_instance_parameter_value inst RX_ENABLE 0

save_system $SYSTEM_PATH/XCVRReset0.qsys
