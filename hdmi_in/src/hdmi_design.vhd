-----------------------------------------------------------------------------
--! 	@file		hdmi_design.vhd
--! 	@function	
--!		@version	
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


entity HDMI_DESIGN is

	port (
			Clk				:	--! 系统时钟	
								in	std_logic; 
			Rst_n		:	in	std_logic;
			HDMI_rx_p		:	in	std_logic_vector(2 downto 0);
			HDMI_rx_n		:	in	std_logic_vector(2 downto 0);
			HDMI_rx_clk_p	:	in	std_logic;
			HDMI_rx_clk_n	:	in	std_logic;
			HDMI_rx_cec		:	inout	std_logic;
			HDMI_rx_hpa		:	in		std_logic;
			HDMI_rx_txen	:	out		std_logic;
			HDMI_rx_scl		:	in		std_logic;
			HDMI_rx_sda		:	inout	std_logic;
		 );
end HDMI_DESIGN;


architecture BEHAVOR of HDMI_DESIGN is
	component HDMI_IN 
	port (
			Clk				:	in	std_logic; 
			Rst_n			:	in	std_logic;
			HDMI_rx_p		:	in	std_logic_vector(2 downto 0);
			HDMI_rx_n		:	in	std_logic_vector(2 downto 0);
			HDMI_rx_clk_p	:	in	std_logic;
			HDMI_rx_clk_n	:	in	std_logic;
			HDMI_rx_cec		:	inout	std_logic;
			HDMI_rx_hpa		:	in		std_logic;
			HDMI_rx_txen	:	out		std_logic;
			HDMI_rx_scl		:	in		std_logic;
			HDMI_rx_sda		:	inout	std_logic;

			Symbol_hsync				:	out std_logic;
			Symbol_vsync				:	out std_logic;
			Symbol_blank				:	out std_logic;
			Symbol_ch0				:	out std_logic_vector(7 downto 0);
			Symbol_ch1				:	out std_logic_vector(7 downto 0);
			Symbol_ch2				:	out std_logic_vector(7 downto 0);
			Symbol_ch_valid			:	out std_logic;

			Adp_data_valid 	: out std_logic;
		 	Adp_header_bits	:	out std_logic;
			Adp_frame_bits	:	out std_logic;
			Adp_sb0_bits		:	out std_logic_vector(1 downto 0);
			Adp_sb1_bits		:	out std_logic_vector(1 downto 0);
			Adp_sb2_bits		:	out std_logic_vector(1 downto 0);
			Adp_sb3_bits		:	out std_logic_vector(1 downto 0);

			Pixel_clock_locked	:	out std_logic;
			Pixel_clock_out		:	out std_logic;
		 );
	end component;


	component EXTRACT_AVI_INFOFRAME 
	port ( 
			 Clk                 : in std_logic;
			 Adp_data_valid      : in std_logic;
			 Adp_header_bit      : in std_logic;
			 Adp_frame_bit       : in std_logic;
			 Adp_subpacket0_bits : in std_logic_vector (1 downto 0);
			 Input_is_ycbcr      : out std_logic;
			 Input_is_422        : out std_logic;
			 Input_is_srgb       : out std_logic
	   );
	end component;
	--------------------------------------------------------------------------
	--! 内部信号定义
	--------------------------------------------------------------------------
	signal symbol_hsync			: 	std_logic;
	signal symbol_vsync			: 	std_logic;
	signal symbol_blank			: 	std_logic;
	signal symbol_ch0			: 	std_logic;
	signal symbol_ch1 			: 	std_logic;
	signal symbol_ch2			: 	std_logic;
	signal symbol_ch_valid		: 	std_logic;

	signal adp_data_valid		: 	std_logic;
	signal adp_header_valid		: 	std_logic;
	signal adp_frame_bits 		: 	std_logic;
	signal adp_sb0_bits			: 	std_logic; 
	signal adp_sb1_bits			: 	std_logic; 
	signal adp_sb2_bits			: 	std_logic; 
	signal adp_sb3_bits			: 	std_logic; 

	signal pixel_clock			:	std_logic;
	signal pixel_clock_locked	:	std_logic;

	signal is_ycbcr				:	std_logic;
	signal is_422				:	std_logic;
	signal is_srgb				:	std_logic;
begin
	U_HDMI_IN : HDMI_IN
	port map(
				Clk					=>	Clk,
				Rst_n				=>	Rst_n,
				HDMI_rx_p			=>	HDMI_rx_p,
				HDMI_rx_n			=>	HDMI_rx_n,
				HDMI_rx_clk_p		=>	HDMI_rx_clk_p,
				HDMI_rx_clk_n		=>	HDMI_rx_clk_n,
				HDMI_rx_cec			=>	HDMI_rx_cec,
				HDMI_rx_hpa			=>	HDMI_rx_hpa,
				HDMI_rx_txen		=>	HDMI_rx_txen,
				HDMI_rx_scl			=>	HDMI_rx_scl,
				HDMI_rx_sda			=>	HDMI_rx_sda,

				Symbol_hsync		=>	symbol_hsync,
				Symbol_vsync		=>	symbol_vsync,
				Symbol_blank		=>	symbol_blank,
				Symbol_ch0			=>	symbol_ch0,
				Symbol_ch1			=>	symbol_ch1,
				Symbol_ch2			=>	symbol_ch2,
				Symbol_ch_valid		=>	symbol_ch_valid,

				Adp_data_valid 		=>	adp_data_valid,
				Adp_header_bits		=>	adp_header_valid,
				Adp_frame_bits		=>	adp_frame_bits,
				Adp_sb0_bits		=>	adp_sb0_bits,
				Adp_sb1_bits		=>	adp_sb1_bits,
				Adp_sb2_bits		=>	adp_sb2_bits,
				Adp_sb3_bits		=>	adp_sb3_bits,

				Pixel_clock_locked	=>	pixel_clock_locked,
				Pixel_clock_out		=> 	pixel_clock,
			);


	U_EXTRACT_AVI_INFOFRAME : EXTRACT_AVI_INFOFRAME
	port map(
				Clk                	=>	pixel_clock, 
				Adp_data_valid      =>	adp_data_valid,
				Adp_header_bit      =>	adp_header_valid,
				Adp_frame_bit       =>	adp_frame_bits,
				Adp_subpacket0_bits	=>	adp_sb0_bits,
				Input_is_ycbcr      =>	is_ycbcr,
				Input_is_422        =>	is_422,
				Input_is_srgb       =>	is_srgb
			);

end BEHAVOR;
