set_property -dict { PACKAGE_PIN AY23 IOSTANDARD DIFF_SSTL12 } [get_ports clock_100_p]
set_property -dict { PACKAGE_PIN BA23 IOSTANDARD DIFF_SSTL12 } [get_ports clock_100_n]

create_clock -name clock_100 -period 10 -quiet [get_ports clock_100_p]

set_property -dict { PACKAGE_PIN AY22 IOSTANDARD DIFF_SSTL12 } [get_ports clock_400_p]
set_property -dict { PACKAGE_PIN BA22 IOSTANDARD DIFF_SSTL12 } [get_ports clock_400_n]

create_clock -name clock_400 -period 2.5 -quiet [get_ports clock_400_p]
