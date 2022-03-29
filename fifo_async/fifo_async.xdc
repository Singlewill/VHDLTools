## Clock Signal
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports Clk]
## Reset Signal
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS12} [get_ports Rst_n]
#
#
create_clock -period 10.000 -name Clk -waveform {0.000 5.000} [get_ports Clk]



create_generated_clock -name clk_50m -source [get_pins clk2_reg/C] -divide_by 2  [get_pins clk2_reg/Q]
#fifo写时钟域到读时钟域
set_max_delay 20 -from [get_cells U_FIFO/wp_reg[*]] -to [get_cells U_FIFO/U_WP_SYNC/dout_l1_reg[*]] -datapath_only

#fifo读时钟域到写时钟域
set_max_delay 10 -from [get_cells U_FIFO/rp_reg[*]] -to [get_cells U_FIFO/U_RP_SYNC/dout_l1_reg[*]] -datapath_only
