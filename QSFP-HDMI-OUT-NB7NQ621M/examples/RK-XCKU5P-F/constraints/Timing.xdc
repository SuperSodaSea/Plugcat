set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets clock_50_bufg_wire]

# System clock frequency = 200MHz
create_clock -name system_clock -period 5 -quiet [get_nets system_clock]

# Maximum TX clock frequency = 6GHz / 40 bits per clock = 150MHz
create_clock -name tx_clock -period 6.666 -quiet [get_nets tx_clock]

set_clock_groups -asynchronous \
    -group system_clock \
    -group tx_clock
