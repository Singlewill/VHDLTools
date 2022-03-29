------------------------------------------------------------------------------
--! 	@file		hdmi_out.vhd
--! 	@function	hdmi信号输出
--!		@version	
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

library UNISIM;
use UNISIM.VComponents.all;

entity HDMI_OUT is
	port (
			Clk			:	in	std_logic;
			Clk_x1	:	in	std_logic;
			Clk_x5	:	in	std_logic;
			Rst_n			:	in	std_logic;

			Blank_i		:	in 	std_logic;
			Hsync_i		:	in	std_logic;
			Vsync_i		:	in	std_logic;
			Red_i		:	in	std_logic_vector(7 downto 0);
			Green_i		:	in	std_logic_vector(7 downto 0);
			Blue_i		:	in	std_logic_vector(7 downto 0);

			HDMI_tx_p		:	out	std_logic_vector(2 downto 0);
			HDMI_tx_n		:	out	std_logic_vector(2 downto 0);
			HDMI_tx_clk_p	:	out	std_logic;
			HDMI_tx_clk_n	:	out	std_logic
		 );
end HDMI_OUT;

architecture BEHAVOR of HDMI_OUT is
	component SERIALISER_10_TO_1
	port ( 
			 Clk_x1    	: in std_logic;
			 Clk_x5 	: in std_logic;
			 Data   	: in std_logic_vector (9 downto 0);
			 Rst  		: in std_logic;
			 Serial 	: out std_logic
		 );
	end component;

	component TMDS_OUTPUT_CHANNEL
	port(
			Clk			:	in	std_logic;
			Clk_x1	:	in	std_logic;
			Clk_x5	:	in	std_logic;
			Rst_n	:	in	std_logic;
			Blank_i		:	in 	std_logic;
			Ctl_i		:	in	std_logic_vector(1 downto 0);
			Symbol_i	:	in	std_logic_vector(7 downto 0);

			Tmds_o		:	out	std_logic
		);
	end component;

	--! 输出信号的非差分信号
	signal tmds_tx	:	std_logic_vector(2 downto 0);
	signal tmds_clk	:	std_logic;

	signal ctl		:	std_logic_vector(1 downto 0);

begin
	ctl <= Vsync_i & Hsync_i;


	--! 因为tmds的三个通道都会经过OSERDESE2
	--！所以clk信号也需要经过OSERDESE2保持相位
	--! 这里为什么是"0000011111",没懂，但输出确实是0101010101
	U_SERIALISER_10_TO_1 : SERIALISER_10_TO_1
	port map(
				 Clk_x1    		=>	Clk_x1,
				 Clk_x5 		=>	Clk_x5,
				 Data   		=>	"0000011111",
				 Rst 			=> 	Rst_n,
				 Serial			=>	tmds_clk
			);

	--! CH0 ==> BLUE
	--! ch0有ctl值
	U_TMDS_OUTPUT_CH0 : TMDS_OUTPUT_CHANNEL
	port map(
				Clk				=>	Clk,
				 Clk_x1    		=>	Clk_x1,
				Clk_x5		=>	Clk_x5,
				Rst_n		=>	Rst_n,
				Blank_i			=>	Blank_i,
				Ctl_i			=>	ctl,
				Symbol_i		=>	Blue_i,
				Tmds_o			=>	tmds_tx(0)
			);

	--! CH1 ==> GREEN
	--! ch1没有ctl值
	U_TMDS_OUTPUT_CH1 : TMDS_OUTPUT_CHANNEL
	port map(
				Clk				=>	Clk,
				 Clk_x1    		=>	Clk_x1,
				Clk_x5		=>	Clk_x5,
				Rst_n		=>	Rst_n,
				Blank_i			=>	Blank_i,
				Ctl_i			=>	"00",
				Symbol_i		=>	Green_i,
				Tmds_o			=>	tmds_tx(1)
			);

	--! CH2 ==> RED
	--! ch2没有ctl值
	U_TMDS_OUTPUT_CH2 : TMDS_OUTPUT_CHANNEL
	port map(
				Clk				=>	Clk,
				 Clk_x1    		=>	Clk_x1,
				Clk_x5		=>	Clk_x5,
				Rst_n		=>	Rst_n,
				Blank_i			=>	Blank_i,
				Ctl_i			=>	"00",
				Symbol_i		=>	Red_i,
				Tmds_o			=>	tmds_tx(2)
			);

    ----------------------------------------------------------------------------------
    -- 将TTL信号通过OBUFDS转换成差分信号
    ----------------------------------------------------------------------------------
	U_CLK_OBUFDS : OBUFDS
	generic map(IOSTANDARD => "TMDS_33",
			   SLEW	=> "FAST")
	port map(
				O	=>	HDMI_tx_clk_p,
				OB	=>	HDMI_tx_clk_n,
				I	=>	tmds_clk
			);

	U_TX0_OBUFDS : OBUFDS
	generic map(IOSTANDARD => "TMDS_33",
			   SLEW	=> "FAST")
	port map(
				O	=>	HDMI_tx_p(0),
				OB	=>	HDMI_tx_n(0),
				I	=>	tmds_tx(0)
			);

	U_TX1_OBUFDS : OBUFDS
	generic map(IOSTANDARD => "TMDS_33",
			   SLEW	=> "FAST")
	port map(
				O	=>	HDMI_tx_p(1),
				OB	=>	HDMI_tx_n(1),
				I	=>	tmds_tx(1)
			);

	U_TX2_OBUFDS : OBUFDS
	generic map(IOSTANDARD => "TMDS_33",
			   SLEW	=> "FAST")
	port map(
				O	=>	HDMI_tx_p(2),
				OB	=>	HDMI_tx_n(2),
				I	=>	tmds_tx(2)
			);



end BEHAVOR;
