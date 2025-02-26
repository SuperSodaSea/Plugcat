create_ip -module_name MMCM0 -vendor xilinx.com -library ip -name clk_wiz -version 6.0

set_property -dict {
    CONFIG.PRIMITIVE MMCM
    CONFIG.PRIMARY_PORT clk_in1
    CONFIG.PRIM_IN_FREQ 50.000
    CONFIG.PRIM_SOURCE Single_ended_clock_capable_pin

    CONFIG.NUM_OUT_CLKS 2

    CONFIG.CLKOUT1_USED true
    CONFIG.CLK_OUT1_PORT clk_out1
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ 200.000
    CONFIG.CLKOUT1_DRIVES BUFG

    CONFIG.CLKOUT2_USED true
    CONFIG.CLK_OUT2_PORT clk_out2
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ 25.000
    CONFIG.CLKOUT2_DRIVES BUFG
} [get_ips MMCM0]
