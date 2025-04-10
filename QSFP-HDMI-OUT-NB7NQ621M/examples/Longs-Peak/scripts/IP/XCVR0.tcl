create_system XCVR0

add_instance inst altera_xcvr_native_a10
set_instance_property inst AUTO_EXPORT true

set_instance_parameter_value inst design_environment NATIVE

# Datapath Options
set_instance_parameter_value inst duplex_mode tx
set_instance_parameter_value inst channels 4
set_instance_parameter_value inst set_data_rate $XCVR0_DATA_RATE
set_instance_parameter_value inst enable_simple_interface 1

# Standard PCS
set_instance_parameter_value inst std_pcs_pma_width 20
set_instance_parameter_value inst std_tx_byte_ser_mode "Serialize x2"

save_system $SYSTEM_PATH/XCVR0.qsys
