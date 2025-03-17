# Bank 128, X0Y16~X0Y19

# 156.25MHz, Reconfigurable with Si5338
set_property PACKAGE_PIN L29 [get_ports qsfp0_refclk_p]
set_property PACKAGE_PIN L30 [get_ports qsfp0_refclk_n]

create_clock -name qsfp0_refclk -period 6.4 [get_ports qsfp0_refclk_p]

set_property PACKAGE_PIN H31 [get_ports qsfp0_txp[0]]
set_property PACKAGE_PIN H32 [get_ports qsfp0_txn[0]]
set_property PACKAGE_PIN G29 [get_ports qsfp0_txp[1]]
set_property PACKAGE_PIN G30 [get_ports qsfp0_txn[1]]
set_property PACKAGE_PIN D31 [get_ports qsfp0_txp[2]]
set_property PACKAGE_PIN D32 [get_ports qsfp0_txn[2]]
set_property PACKAGE_PIN B31 [get_ports qsfp0_txp[3]]
set_property PACKAGE_PIN B32 [get_ports qsfp0_txn[3]]

set_property PACKAGE_PIN G33 [get_ports qsfp0_rxp[0]]
set_property PACKAGE_PIN G34 [get_ports qsfp0_rxn[0]]
set_property PACKAGE_PIN F31 [get_ports qsfp0_rxp[1]]
set_property PACKAGE_PIN F32 [get_ports qsfp0_rxn[1]]
set_property PACKAGE_PIN E33 [get_ports qsfp0_rxp[2]]
set_property PACKAGE_PIN E34 [get_ports qsfp0_rxn[2]]
set_property PACKAGE_PIN C33 [get_ports qsfp0_rxp[3]]
set_property PACKAGE_PIN C34 [get_ports qsfp0_rxn[3]]

set_property -dict { PACKAGE_PIN AK13 IOSTANDARD LVCMOS33 } [get_ports qsfp0_modprsl]
set_property -dict { PACKAGE_PIN AE13 IOSTANDARD LVCMOS33 } [get_ports qsfp0_intl]
set_property -dict { PACKAGE_PIN AL12 IOSTANDARD LVCMOS33 } [get_ports qsfp0_resetl]
set_property -dict { PACKAGE_PIN AF13 IOSTANDARD LVCMOS33 } [get_ports qsfp0_lpmode]
set_property -dict { PACKAGE_PIN AK11 IOSTANDARD LVCMOS33 } [get_ports qsfp0_scl]
set_property -dict { PACKAGE_PIN AL13 IOSTANDARD LVCMOS33 } [get_ports qsfp0_sda]
