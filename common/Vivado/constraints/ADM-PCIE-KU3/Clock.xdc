set_property -dict { PACKAGE_PIN AA24 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports clock_250_p]
set_property -dict { PACKAGE_PIN AA25 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports clock_250_n]

create_clock -name clock_250 -period 4 -quiet [get_ports clock_250_p]

set_property -dict { PACKAGE_PIN W23 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports clock_200_p]
set_property -dict { PACKAGE_PIN W24 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports clock_200_n]

create_clock -name clock_200 -period 5 -quiet [get_ports clock_200_p]
