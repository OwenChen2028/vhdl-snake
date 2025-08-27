# CITATION: referenced http://www.nhn.ou.edu/~bumm/ELAB/download/Basys3_Master.xdc
# CITATION: referenced https://digilent.com/reference/programmable-logic/basys-3/reference-manual

##====================================================================
## Clock
##====================================================================

set_property PACKAGE_PIN W5 [get_ports clk_ext]
set_property IOSTANDARD LVCMOS33 [get_ports clk_ext]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk_ext]

##====================================================================
## Inputs
##====================================================================

# up button
set_property PACKAGE_PIN T18 [get_ports mv_head_button]						
set_property IOSTANDARD LVCMOS33 [get_ports mv_head_button]

# left button
set_property PACKAGE_PIN W19 [get_ports rm_tail_button]						
set_property IOSTANDARD LVCMOS33 [get_ports rm_tail_button]

# center button
set_property PACKAGE_PIN U18 [get_ports put_head_button]						
set_property IOSTANDARD LVCMOS33 [get_ports put_head_button]

# right button
set_property PACKAGE_PIN T17 [get_ports put_fruit_button]
set_property IOSTANDARD LVCMOS33 [get_ports put_fruit_button]

# down button
set_property PACKAGE_PIN U17 [get_ports reset_button]						
set_property IOSTANDARD LVCMOS33 [get_ports reset_button]

# switch 0
set_property PACKAGE_PIN V17 [get_ports {dir_in[0]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {dir_in[0]}]

# switch 1
set_property PACKAGE_PIN V16 [get_ports {dir_in[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dir_in[1]}]

# switch 8
set_property PACKAGE_PIN V2 [get_ports {rand_in[0]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {rand_in[0]}]

# switch 9
set_property PACKAGE_PIN T3 [get_ports {rand_in[1]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {rand_in[1]}]

# switch 10
set_property PACKAGE_PIN T2 [get_ports {rand_in[2]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {rand_in[2]}]

# switch 11
set_property PACKAGE_PIN R3 [get_ports {rand_in[3]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {rand_in[3]}]

# switch 12
set_property PACKAGE_PIN W2 [get_ports {rand_in[4]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {rand_in[4]}]

# switch 13
set_property PACKAGE_PIN U1 [get_ports {rand_in[5]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {rand_in[5]}]

# switch 14
set_property PACKAGE_PIN T1 [get_ports {rand_in[6]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {rand_in[6]}]

# switch 15
set_property PACKAGE_PIN R2 [get_ports {rand_in[7]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {rand_in[7]}]

##====================================================================
## Outputs
##====================================================================

## hsync and vsync
set_property PACKAGE_PIN P19 [get_ports vga_hsync]
set_property IOSTANDARD LVCMOS33 [get_ports vga_hsync]

set_property PACKAGE_PIN R19 [get_ports vga_vsync]
set_property IOSTANDARD LVCMOS33 [get_ports vga_vsync]

## red
set_property PACKAGE_PIN N19 [get_ports {vga_red[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_red[3]}]

set_property PACKAGE_PIN J19 [get_ports {vga_red[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_red[2]}]

set_property PACKAGE_PIN H19 [get_ports {vga_red[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_red[1]}]

set_property PACKAGE_PIN G19 [get_ports {vga_red[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_red[0]}]

## green
set_property PACKAGE_PIN D17 [get_ports {vga_green[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_green[3]}]

set_property PACKAGE_PIN G17 [get_ports {vga_green[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_green[2]}]

set_property PACKAGE_PIN H17 [get_ports {vga_green[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_green[1]}]

set_property PACKAGE_PIN J17 [get_ports {vga_green[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_green[0]}]

## blue
set_property PACKAGE_PIN J18 [get_ports {vga_blue[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue[3]}]

set_property PACKAGE_PIN K18 [get_ports {vga_blue[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue[2]}]

set_property PACKAGE_PIN L18 [get_ports {vga_blue[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue[1]}]

set_property PACKAGE_PIN N18 [get_ports {vga_blue[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue[0]}]

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
