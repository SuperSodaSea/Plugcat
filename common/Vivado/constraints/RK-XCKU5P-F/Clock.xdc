# Bank 65

set_property -dict { PACKAGE_PIN T24 IOSTANDARD DIFF_SSTL12 } [get_ports clock_200_p]
set_property -dict { PACKAGE_PIN U24 IOSTANDARD DIFF_SSTL12 } [get_ports clock_200_n]

create_clock -name clock_200 -period 5 -quiet [get_ports clock_200_p]

# Bank 84

# Optional
set_property -dict { PACKAGE_PIN AC13 IOSTANDARD LVCMOS33 } [get_ports clock_50]

create_clock -name clock_50 -period 20 -quiet [get_ports clock_50]
