# CITATION: referenced http://www.nhn.ou.edu/~bumm/ELAB/download/Basys3_Master.xdc

##====================================================================
## Clock
##====================================================================

set_property PACKAGE_PIN W5 [get_ports clk_ext]
set_property IOSTANDARD LVCMOS33 [get_ports clk_ext]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk_ext]

##====================================================================
## Inputs
##====================================================================

set_property PACKAGE_PIN T18 [get_ports up_button]						
set_property IOSTANDARD LVCMOS33 [get_ports up_button]

set_property PACKAGE_PIN W19 [get_ports left_button]						
set_property IOSTANDARD LVCMOS33 [get_ports left_button]

set_property PACKAGE_PIN T17 [get_ports right_button]
set_property IOSTANDARD LVCMOS33 [get_ports right_button]

set_property PACKAGE_PIN U17 [get_ports down_button]
set_property IOSTANDARD LVCMOS33 [get_ports down_button]

set_property PACKAGE_PIN V17 [get_ports {pause_switch}]					
set_property IOSTANDARD LVCMOS33 [get_ports {pause_switch}]

set_property PACKAGE_PIN V16 [get_ports {reset_switch}]
set_property IOSTANDARD LVCMOS33 [get_ports {reset_switch}]

##====================================================================
## Outputs
##====================================================================

# JA1
set_property PACKAGE_PIN J1 [get_ports {direction[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {direction[0]}]

# JA2
set_property PACKAGE_PIN L2 [get_ports {direction[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {direction[1]}]

# JA3
set_property PACKAGE_PIN J2 [get_ports {update_out}]
set_property IOSTANDARD LVCMOS33 [get_ports {update_out}]

##====================================================================
## Implementation Assist
##====================================================================

## These additional constraints are recommended by Digilent, do not remove!
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
