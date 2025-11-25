# System clock frequency = 200MHz
set system_clock [get_clocks pll0|inst_outclk0]

# Maximum TX clock frequency = 6GHz / 40 bits per clock = 150MHz
set tx_clock_0 [get_clocks xcvr_wrapper_0|xcvr|tx_clkout|ch1]
set tx_clock_1 [get_clocks xcvr_wrapper_1|xcvr|tx_clkout|ch1]

set_clock_groups -asynchronous \
    -group $system_clock \
    -group $tx_clock_0 \
    -group $tx_clock_1

derive_clock_uncertainty
