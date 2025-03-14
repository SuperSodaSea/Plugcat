set_property -dict { PACKAGE_PIN E18 IOSTANDARD LVCMOS18 } [get_ports clock_50]

create_clock -name clock_50 -period 20 -quiet [get_ports clock_50]
