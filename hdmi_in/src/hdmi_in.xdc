set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]


## PERIOD
#主时钟 = 100M
create_clock -period 10.000 -name Clk -waveform {0.000 5.000} [get_ports Clk]

##HDMI in
## 1920*1080@60Hz  ==> pixel_clock = 148.5Mhz, 6.7ns
create_clock -period 6.700 -name hdmi_clk -waveform {0.000 3.350} -add [get_ports HDMI_rx_clk_p]

#Rst_n
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS12} [get_ports Rst_n]
#Clk
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports Clk]
#HDMI input pins
set_property -dict {PACKAGE_PIN AA5 IOSTANDARD LVCMOS33} [get_ports HDMI_rx_cec]
set_property -dict {PACKAGE_PIN W4 IOSTANDARD TMDS_33} [get_ports HDMI_rx_clk_n]
set_property -dict {PACKAGE_PIN V4 IOSTANDARD TMDS_33} [get_ports HDMI_rx_clk_p]
set_property -dict {PACKAGE_PIN AB12 IOSTANDARD LVCMOS25} [get_ports HDMI_rx_hpa]
set_property -dict {PACKAGE_PIN Y4 IOSTANDARD LVCMOS33} [get_ports HDMI_rx_scl]
set_property -dict {PACKAGE_PIN AB5 IOSTANDARD LVCMOS33} [get_ports HDMI_rx_sda]
set_property -dict {PACKAGE_PIN R3 IOSTANDARD LVCMOS33} [get_ports HDMI_rx_txen]
set_property -dict {PACKAGE_PIN AA3 IOSTANDARD TMDS_33} [get_ports {HDMI_rx_n[0]}]
set_property -dict {PACKAGE_PIN Y3 IOSTANDARD TMDS_33} [get_ports {HDMI_rx_p[0]}]
set_property -dict {PACKAGE_PIN Y2 IOSTANDARD TMDS_33} [get_ports {HDMI_rx_n[1]}]
set_property -dict {PACKAGE_PIN W2 IOSTANDARD TMDS_33} [get_ports {HDMI_rx_p[1]}]
set_property -dict {PACKAGE_PIN V2 IOSTANDARD TMDS_33} [get_ports {HDMI_rx_n[2]}]
set_property -dict {PACKAGE_PIN U2 IOSTANDARD TMDS_33} [get_ports {HDMI_rx_p[2]}]

set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {Ctl_out[0]}]
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports {Ctl_out[1]}]

set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports {Pixel_out[0]}]
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports {Pixel_out[1]}]
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33} [get_ports {Pixel_out[2]}]
set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports {Pixel_out[3]}]
set_property -dict {PACKAGE_PIN N13 IOSTANDARD LVCMOS33} [get_ports {Pixel_out[4]}]
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS33} [get_ports {Pixel_out[5]}]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {Pixel_out[6]}]
set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports {Pixel_out[7]}]



set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports {Terc4_out[0]}]
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports {Terc4_out[1]}]
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports {Terc4_out[2]}]
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports {Terc4_out[3]}]





create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 4 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER true [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 65536 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk_pixel]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 3 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {ctl_valid[0]} {ctl_valid[1]} {ctl_valid[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 3 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {pixel_data_valid[0]} {pixel_data_valid[1]} {pixel_data_valid[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 3 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {terc4_valid[0]} {terc4_valid[1]} {terc4_valid[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 2 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {test_ctl[0]} {test_ctl[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 8 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {test_pixel[0]} {test_pixel[1]} {test_pixel[2]} {test_pixel[3]} {test_pixel[4]} {test_pixel[5]} {test_pixel[6]} {test_pixel[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 4 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {test_terc4[0]} {test_terc4[1]} {test_terc4[2]} {test_terc4[3]}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_pixel]
