create_system XCVRFPLL0

add_instance inst altera_xcvr_fpll_s10_htile
set_instance_property inst AUTO_EXPORT true

# PLL

## General
set_instance_parameter_value inst set_enable_fractional 1
set_instance_parameter_value inst set_power_mode 1_1V

## Output Frequency
set_instance_parameter_value inst set_output_clock_frequency $XCVRFPLL0_OUTPUT_CLOCK_FREQUENCY
set_instance_parameter_value inst set_fref_clock_frequency 644.53125

# Master CLock Generation Block

## MCGB
set_instance_parameter_value inst enable_mcgb 1

## Bonding
set_instance_parameter_value inst enable_bonding_clks 1
set_instance_parameter_value inst pma_width 20

save_system $SYSTEM_PATH/XCVRFPLL0.qsys
