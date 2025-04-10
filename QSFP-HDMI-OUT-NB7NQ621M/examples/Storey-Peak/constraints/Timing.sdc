create_clock -name clock_125 -period 8 [get_ports clock_125]

# System clock frequency = 200MHz
create_clock -name system_clock -period 5 [get_pins pll0|inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk]

# Maximum TX clock frequency = 6GHz / 40 bits per clock = 150MHz
create_clock -name tx_clock_0 -period 6.666 [get_pins xcvr_wrapper_0|xcvrs[0].xcvr|inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pcs|ch[1].inst_sv_pcs_ch|inst_sv_hssi_8g_tx_pcs|wys|clkout]
create_clock -name tx_clock_1 -period 6.666 [get_pins xcvr_wrapper_0|xcvrs[1].xcvr|inst|gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|inst_sv_pcs|ch[1].inst_sv_pcs_ch|inst_sv_hssi_8g_tx_pcs|wys|clkout]

set_clock_groups -asynchronous \
    -group system_clock \
    -group tx_clock_0 \
    -group tx_clock_1

derive_pll_clocks
derive_clock_uncertainty
