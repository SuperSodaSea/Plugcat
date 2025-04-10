create_clock -name clock_100 -period 5 [get_ports clock_100]

create_clock -name qsfp_refclk -period 1.551 [get_ports qsfp_refclk]

# System clock frequency = 200MHz
create_clock -name system_clock -period 5 [get_pins pll0|inst|altera_iopll_i|twentynm_pll|iopll_inst|outclk[0]]

# Maximum TX clock frequency = 6GHz / 40 bits per clock = 150MHz
create_clock -name tx_clock -period 6.666 [get_pins xcvr_wrapper_0|xcvr|inst|g_xcvr_native_insts[1].twentynm_xcvr_native_inst|twentynm_xcvr_native_inst|inst_twentynm_pcs|gen_twentynm_hssi_8g_tx_pcs.inst_twentynm_hssi_8g_tx_pcs|sta_tx_clk2_by2_1_out]

set_clock_groups -asynchronous \
    -group system_clock \
    -group tx_clock

derive_pll_clocks
derive_clock_uncertainty
