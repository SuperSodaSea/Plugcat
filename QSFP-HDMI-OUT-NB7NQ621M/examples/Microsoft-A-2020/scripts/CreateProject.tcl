set JOBS [lindex $argv 0]
set RESOLUTION [lindex $argv 1]
set REFRESH_RATE [lindex $argv 2]

project_new Microsoft-A-2020-Example -overwrite

set_global_assignment -name FAMILY "Stratix 10"
set_global_assignment -name DEVICE 1SG280LN2F43E2VG

set_global_assignment -name NUM_PARALLEL_PROCESSORS $JOBS

set_global_assignment -name VERILOG_MACRO RESOLUTION="$RESOLUTION"
set_global_assignment -name VERILOG_MACRO REFRESH_RATE=$REFRESH_RATE

set_global_assignment -name TOP_LEVEL_ENTITY Top

set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output

set_global_assignment -name PROJECT_IP_REGENERATION_POLICY ALWAYS_REGENERATE_IP

set_global_assignment -name DEVICE_INITIALIZATION_CLOCK OSC_CLK_1_125MHZ
set_global_assignment -name GENERATE_COMPRESSED_SOF ON

set_global_assignment -name PWRMGT_SLAVE_DEVICE_TYPE OTHER
set_global_assignment -name PWRMGT_SLAVE_DEVICE0_ADDRESS 60
set_global_assignment -name PWRMGT_VOLTAGE_OUTPUT_FORMAT "DIRECT FORMAT"
set_global_assignment -name PWRMGT_DIRECT_FORMAT_COEFFICIENT_M 1
set_global_assignment -name PWRMGT_TRANSLATED_VOLTAGE_VALUE_UNIT MILLIVOLTS

set_global_assignment -name USE_PWRMGT_SCL SDM_IO14
set_global_assignment -name USE_PWRMGT_SDA SDM_IO11

set_global_assignment -name PRESERVE_UNUSED_XCVR_CHANNEL ON
