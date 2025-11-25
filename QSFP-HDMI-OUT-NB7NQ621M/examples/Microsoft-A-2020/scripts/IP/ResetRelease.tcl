create_system ResetRelease

add_instance inst altera_s10_user_rst_clkgate
set_instance_property inst AUTO_EXPORT true

set_instance_parameter_value inst outputType "Reset Interface"

save_system $SYSTEM_PATH/ResetRelease.ip
