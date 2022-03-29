#set_property CFGBVS VCCO [current_design]
#set_property CONFIG_VOLTAGE 3.3 [current_design]


## PERIOD
#主时钟 = 100M
create_clock -period 10.000 -name Clk -waveform {0.000 5.000} [get_ports Clk]

##HDMI in
## 1920*1080@60Hz  ==> pixel_clock = 148.5Mhz, 6.7ns
#create_clock -period 6.700 -name hdmi_clk -waveform {0.000 3.350} -add [get_ports HDMI_rx_clk_p]

#Rst_n
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS12} [get_ports Rst_n]
#Clk
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports Clk]

#HDMI output pins
set_property -dict {PACKAGE_PIN U1 IOSTANDARD TMDS_33} [get_ports HDMI_tx_clk_n]
set_property -dict {PACKAGE_PIN T1 IOSTANDARD TMDS_33} [get_ports HDMI_tx_clk_p]
set_property -dict {PACKAGE_PIN Y1 IOSTANDARD TMDS_33} [get_ports {HDMI_tx_n[0]}]
set_property -dict {PACKAGE_PIN W1 IOSTANDARD TMDS_33} [get_ports {HDMI_tx_p[0]}]
set_property -dict {PACKAGE_PIN AB1 IOSTANDARD TMDS_33} [get_ports {HDMI_tx_n[1]}]
set_property -dict {PACKAGE_PIN AA1 IOSTANDARD TMDS_33} [get_ports {HDMI_tx_p[1]}]
set_property -dict {PACKAGE_PIN AB2 IOSTANDARD TMDS_33} [get_ports {HDMI_tx_n[2]}]
set_property -dict {PACKAGE_PIN AB3 IOSTANDARD TMDS_33} [get_ports {HDMI_tx_p[2]}]
set_property -dict { PACKAGE_PIN AA4   IOSTANDARD LVCMOS33 } [get_ports { HDMI_tx_cec }]; #IO_L11N_T1_SRCC_34 Sch=hdmi_tx_cec
set_property -dict { PACKAGE_PIN AB13  IOSTANDARD LVCMOS25 } [get_ports { HDMI_tx_hpd }]; #IO_L3N_T0_DQS_13 Sch=hdmi_tx_hpd
set_property -dict { PACKAGE_PIN U3    IOSTANDARD LVCMOS33 } [get_ports { HDMI_tx_rscl }]; #IO_L6P_T0_34 Sch=hdmi_tx_rscl
set_property -dict { PACKAGE_PIN V3    IOSTANDARD LVCMOS33 } [get_ports { HDMI_tx_rsda }]; #IO_L6N_T0_VREF_34 Sch=hdmi_tx_rsda


