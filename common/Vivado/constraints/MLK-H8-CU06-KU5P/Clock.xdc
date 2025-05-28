set_property -dict { PACKAGE_PIN V24 IOSTANDARD DIFF_SSTL12 } [get_ports clock_100_p]
set_property -dict { PACKAGE_PIN W24 IOSTANDARD DIFF_SSTL12 } [get_ports clock_100_n]

create_clock -name clock_100 -period 10 -quiet [get_ports clock_100_p]
