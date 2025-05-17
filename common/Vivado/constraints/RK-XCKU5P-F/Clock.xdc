set_property -dict { PACKAGE_PIN AC13 IOSTANDARD LVCMOS33 } [get_ports clock_50]

create_clock -name clock_50 -period 20 -quiet [get_ports clock_50]
