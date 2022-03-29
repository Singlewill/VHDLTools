## PERIOD
create_clock -period 10.000 -name Clk -waveform {0.000 5.000} [get_ports Clk]

## Clock Pin
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports Clk]
## Reset Pin
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS12} [get_ports Rst_n]
## UART Pin
set_property -dict {PACKAGE_PIN AA19 IOSTANDARD LVCMOS33} [get_ports Tx_pin]
set_property -dict {PACKAGE_PIN V18 IOSTANDARD LVCMOS33} [get_ports Rx_pin]

#where value1 is either VCCO or GND
#where value2 is the voltage provided to configuration bank 0
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

