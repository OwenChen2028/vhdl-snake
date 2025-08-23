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

set_property PACKAGE_PIN U18 [get_ports reset_button]						
set_property IOSTANDARD LVCMOS33 [get_ports reset_button]

##====================================================================
## Outputs
##====================================================================

# JA1
set_property PACKAGE_PIN J1 [get_ports {rand_out[0]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {rand_out[0]}]

# JA2
set_property PACKAGE_PIN L2 [get_ports {rand_out[1]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {rand_out[1]}]

# JA3
set_property PACKAGE_PIN J2 [get_ports {rand_out[2]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {rand_out[2]}]

# JA4
set_property PACKAGE_PIN G2 [get_ports {rand_out[3]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {rand_out[3]}]

# JA7
set_property PACKAGE_PIN H1 [get_ports {rand_out[4]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {rand_out[4]}]

# JA8
set_property PACKAGE_PIN K2 [get_ports {rand_out[5]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {rand_out[5]}]

# JA9
set_property PACKAGE_PIN H2 [get_ports {rand_out[6]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {rand_out[6]}]

# JA10
set_property PACKAGE_PIN G3 [get_ports {rand_out[7]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {rand_out[7]}]

# JB1
set_property PACKAGE_PIN A14 [get_ports {clk_out}]					
set_property IOSTANDARD LVCMOS33 [get_ports {clk_out}]

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
