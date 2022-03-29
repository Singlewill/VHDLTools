## PERIOD
create_clock -period 10.000 -name Clk -waveform {0.000 5.000} [get_ports Clk]
#create_clock -period 20.000 -waveform {0.000 10.000} [get_pins U_PLL_50M/Clk_out]

## Clock Signal
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports Clk]
#key fifo clk

#create_clock -period 10.000 -waveform {0.000 5.000} [get_pins U_KEY_FIFO/rd_clk]

## Reset Signal
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS12} [get_ports Rst_n]
## UART
#set_property -dict {PACKAGE_PIN AA19 IOSTANDARD LVCMOS33} [get_ports Tx_pin]
#set_property -dict { PACKAGE_PIN V18   IOSTANDARD LVCMOS33 } [get_ports { Rx_pin }];

## SD card
set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS33} [get_ports Sd_clk_o]
#set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports SD_cd]
set_property -dict {PACKAGE_PIN W20 IOSTANDARD LVCMOS33} [get_ports Sd_cmd]
set_property -dict {PACKAGE_PIN V19 IOSTANDARD LVCMOS33} [get_ports {Sd_dat[0]}]
set_property -dict {PACKAGE_PIN T21 IOSTANDARD LVCMOS33} [get_ports {Sd_dat[1]}]
set_property -dict {PACKAGE_PIN T20 IOSTANDARD LVCMOS33} [get_ports {Sd_dat[2]}]
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports {Sd_dat[3]}]











create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 4 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER true [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list Clk_IBUF_BUFG]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 3 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {cmd_sta_cur[0]} {cmd_sta_cur[1]} {cmd_sta_cur[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 8 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {U_SD_RESP_RX/cnt[0]} {U_SD_RESP_RX/cnt[1]} {U_SD_RESP_RX/cnt[2]} {U_SD_RESP_RX/cnt[3]} {U_SD_RESP_RX/cnt[4]} {U_SD_RESP_RX/cnt[5]} {U_SD_RESP_RX/cnt[6]} {U_SD_RESP_RX/cnt[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 136 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {U_SD_RESP_RX/resp_shift[0]} {U_SD_RESP_RX/resp_shift[1]} {U_SD_RESP_RX/resp_shift[2]} {U_SD_RESP_RX/resp_shift[3]} {U_SD_RESP_RX/resp_shift[4]} {U_SD_RESP_RX/resp_shift[5]} {U_SD_RESP_RX/resp_shift[6]} {U_SD_RESP_RX/resp_shift[7]} {U_SD_RESP_RX/resp_shift[8]} {U_SD_RESP_RX/resp_shift[9]} {U_SD_RESP_RX/resp_shift[10]} {U_SD_RESP_RX/resp_shift[11]} {U_SD_RESP_RX/resp_shift[12]} {U_SD_RESP_RX/resp_shift[13]} {U_SD_RESP_RX/resp_shift[14]} {U_SD_RESP_RX/resp_shift[15]} {U_SD_RESP_RX/resp_shift[16]} {U_SD_RESP_RX/resp_shift[17]} {U_SD_RESP_RX/resp_shift[18]} {U_SD_RESP_RX/resp_shift[19]} {U_SD_RESP_RX/resp_shift[20]} {U_SD_RESP_RX/resp_shift[21]} {U_SD_RESP_RX/resp_shift[22]} {U_SD_RESP_RX/resp_shift[23]} {U_SD_RESP_RX/resp_shift[24]} {U_SD_RESP_RX/resp_shift[25]} {U_SD_RESP_RX/resp_shift[26]} {U_SD_RESP_RX/resp_shift[27]} {U_SD_RESP_RX/resp_shift[28]} {U_SD_RESP_RX/resp_shift[29]} {U_SD_RESP_RX/resp_shift[30]} {U_SD_RESP_RX/resp_shift[31]} {U_SD_RESP_RX/resp_shift[32]} {U_SD_RESP_RX/resp_shift[33]} {U_SD_RESP_RX/resp_shift[34]} {U_SD_RESP_RX/resp_shift[35]} {U_SD_RESP_RX/resp_shift[36]} {U_SD_RESP_RX/resp_shift[37]} {U_SD_RESP_RX/resp_shift[38]} {U_SD_RESP_RX/resp_shift[39]} {U_SD_RESP_RX/resp_shift[40]} {U_SD_RESP_RX/resp_shift[41]} {U_SD_RESP_RX/resp_shift[42]} {U_SD_RESP_RX/resp_shift[43]} {U_SD_RESP_RX/resp_shift[44]} {U_SD_RESP_RX/resp_shift[45]} {U_SD_RESP_RX/resp_shift[46]} {U_SD_RESP_RX/resp_shift[47]} {U_SD_RESP_RX/resp_shift[48]} {U_SD_RESP_RX/resp_shift[49]} {U_SD_RESP_RX/resp_shift[50]} {U_SD_RESP_RX/resp_shift[51]} {U_SD_RESP_RX/resp_shift[52]} {U_SD_RESP_RX/resp_shift[53]} {U_SD_RESP_RX/resp_shift[54]} {U_SD_RESP_RX/resp_shift[55]} {U_SD_RESP_RX/resp_shift[56]} {U_SD_RESP_RX/resp_shift[57]} {U_SD_RESP_RX/resp_shift[58]} {U_SD_RESP_RX/resp_shift[59]} {U_SD_RESP_RX/resp_shift[60]} {U_SD_RESP_RX/resp_shift[61]} {U_SD_RESP_RX/resp_shift[62]} {U_SD_RESP_RX/resp_shift[63]} {U_SD_RESP_RX/resp_shift[64]} {U_SD_RESP_RX/resp_shift[65]} {U_SD_RESP_RX/resp_shift[66]} {U_SD_RESP_RX/resp_shift[67]} {U_SD_RESP_RX/resp_shift[68]} {U_SD_RESP_RX/resp_shift[69]} {U_SD_RESP_RX/resp_shift[70]} {U_SD_RESP_RX/resp_shift[71]} {U_SD_RESP_RX/resp_shift[72]} {U_SD_RESP_RX/resp_shift[73]} {U_SD_RESP_RX/resp_shift[74]} {U_SD_RESP_RX/resp_shift[75]} {U_SD_RESP_RX/resp_shift[76]} {U_SD_RESP_RX/resp_shift[77]} {U_SD_RESP_RX/resp_shift[78]} {U_SD_RESP_RX/resp_shift[79]} {U_SD_RESP_RX/resp_shift[80]} {U_SD_RESP_RX/resp_shift[81]} {U_SD_RESP_RX/resp_shift[82]} {U_SD_RESP_RX/resp_shift[83]} {U_SD_RESP_RX/resp_shift[84]} {U_SD_RESP_RX/resp_shift[85]} {U_SD_RESP_RX/resp_shift[86]} {U_SD_RESP_RX/resp_shift[87]} {U_SD_RESP_RX/resp_shift[88]} {U_SD_RESP_RX/resp_shift[89]} {U_SD_RESP_RX/resp_shift[90]} {U_SD_RESP_RX/resp_shift[91]} {U_SD_RESP_RX/resp_shift[92]} {U_SD_RESP_RX/resp_shift[93]} {U_SD_RESP_RX/resp_shift[94]} {U_SD_RESP_RX/resp_shift[95]} {U_SD_RESP_RX/resp_shift[96]} {U_SD_RESP_RX/resp_shift[97]} {U_SD_RESP_RX/resp_shift[98]} {U_SD_RESP_RX/resp_shift[99]} {U_SD_RESP_RX/resp_shift[100]} {U_SD_RESP_RX/resp_shift[101]} {U_SD_RESP_RX/resp_shift[102]} {U_SD_RESP_RX/resp_shift[103]} {U_SD_RESP_RX/resp_shift[104]} {U_SD_RESP_RX/resp_shift[105]} {U_SD_RESP_RX/resp_shift[106]} {U_SD_RESP_RX/resp_shift[107]} {U_SD_RESP_RX/resp_shift[108]} {U_SD_RESP_RX/resp_shift[109]} {U_SD_RESP_RX/resp_shift[110]} {U_SD_RESP_RX/resp_shift[111]} {U_SD_RESP_RX/resp_shift[112]} {U_SD_RESP_RX/resp_shift[113]} {U_SD_RESP_RX/resp_shift[114]} {U_SD_RESP_RX/resp_shift[115]} {U_SD_RESP_RX/resp_shift[116]} {U_SD_RESP_RX/resp_shift[117]} {U_SD_RESP_RX/resp_shift[118]} {U_SD_RESP_RX/resp_shift[119]} {U_SD_RESP_RX/resp_shift[120]} {U_SD_RESP_RX/resp_shift[121]} {U_SD_RESP_RX/resp_shift[122]} {U_SD_RESP_RX/resp_shift[123]} {U_SD_RESP_RX/resp_shift[124]} {U_SD_RESP_RX/resp_shift[125]} {U_SD_RESP_RX/resp_shift[126]} {U_SD_RESP_RX/resp_shift[127]} {U_SD_RESP_RX/resp_shift[128]} {U_SD_RESP_RX/resp_shift[129]} {U_SD_RESP_RX/resp_shift[130]} {U_SD_RESP_RX/resp_shift[131]} {U_SD_RESP_RX/resp_shift[132]} {U_SD_RESP_RX/resp_shift[133]} {U_SD_RESP_RX/resp_shift[134]} {U_SD_RESP_RX/resp_shift[135]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 4 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {U_SD_RESP_RX/resp_state_cur[0]} {U_SD_RESP_RX/resp_state_cur[1]} {U_SD_RESP_RX/resp_state_cur[2]} {U_SD_RESP_RX/resp_state_cur[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 1 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list U_SD_RESP_RX/Clk_tick]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list cmd_busy]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list cmd_done]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list cmd_start]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list resp_done]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list resp_error]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list Sd_clk_o_OBUF]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list Sd_cmd_OBUF]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets Clk_IBUF_BUFG]
