create_system PLL0

add_instance inst altera_xcvr_native_s10_htile
set_instance_property inst AUTO_EXPORT true

# Design Environment
set_instance_parameter_value inst design_environment NATIVE

# Common PMA Options
set_instance_parameter_value inst anlg_voltage 1_1V

# Datapath Options
set_instance_parameter_value inst channel_type GX
set_instance_parameter_value inst protocol_mode basic_std
set_instance_parameter_value inst pma_mode basic
set_instance_parameter_value inst duplex_mode tx
set_instance_parameter_value inst channels 4
set_instance_parameter_value inst set_data_rate $XCVR0_DATA_RATE
set_instance_parameter_value inst enable_simple_interface 1

# TX PMA
set_instance_parameter_value inst bonded_mode pma_only

# Standard PCS
set_instance_parameter_value inst std_pcs_pma_width 20
set_instance_parameter_value inst std_tx_byte_ser_mode "Serialize x2"

# PCS-Core Interface
set_instance_parameter_value inst tx_fifo_pfull 10

# Analog PMA Settings
set_instance_parameter_value inst tx_pma_optimal_settings 0
set_instance_parameter_value inst tx_pma_output_swing_ctrl 31
set_instance_parameter_value inst tx_pma_slew_rate_ctrl 4

save_system $SYSTEM_PATH/XCVR0.ip
