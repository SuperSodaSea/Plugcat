# System clock frequency = 200MHz
create_clock -name system_clock -period 5 -quiet [get_nets system_clock]

# Maximum TX clock frequency = 6GHz / 40 bits per clock = 150MHz
create_clock -name tx_clock_0 -period 6.666 [get_nets tx_clock[0]]
create_clock -name tx_clock_1 -period 6.666 [get_nets tx_clock[1]]

set_clock_groups -asynchronous \
    -group system_clock \
    -group tx_clock_0 \
    -group tx_clock_1
