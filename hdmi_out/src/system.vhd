-----------------------------------------------------------------------------
--! 	@file		system.vhd
--! 	@function	顶层例化
--!		@version	
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

library UNISIM;
use UNISIM.VComponents.all;

entity  SYSTEM is
	port (
			Clk		:	in	std_logic; 
			Rst_n	:	in	std_logic;

	        HDMI_tx_rscl  : out   std_logic;
        	HDMI_tx_rsda  : inout std_logic;
        	HDMI_tx_hpd   : in    std_logic;
        	HDMI_tx_cec   : inout std_logic;

			HDMI_tx_p		:	out	std_logic_vector(2 downto 0);
			HDMI_tx_n		:	out	std_logic_vector(2 downto 0);
			HDMI_tx_clk_p	:	out	std_logic;
			HDMI_tx_clk_n	:	out	std_logic
		 );
end SYSTEM;


architecture BEHAVOR of SYSTEM is
	component VGA_CLKGEN
	port	(
				Clk_in		:	in	std_logic;
				Clk_raw_o		:	out	std_logic;
				Clk_x1_o		:	out	std_logic;
				Clk_x5_o	:	out std_logic;
				Locked		:	out	std_logic
			);
	end component;
	component VGA 
	port (
			Clk_pixel	:	in	std_logic; 
			Rst_n		:	in	std_logic;
			Hsync_o		:	out	std_logic;
			Vsync_o		:	out	std_logic;
			Blank_o		:	out	std_logic;
			
			Red_o		:	out	std_logic_vector(7 downto 0);
			Green_o		:	out	std_logic_vector(7 downto 0);
			Blue_o		:	out	std_logic_vector(7 downto 0)
		 );
	end component;
	component HDMI_OUT
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
	end component;


	signal clk_pixel	:	std_logic;
	signal clk_pixel_locked	:	std_logic;
	signal clk_pixel_x1	:	std_logic;
	signal clk_pixel_x5	:	std_logic;
	signal clk_bufg		:	std_logic;

	signal symbol_red	:	std_logic_vector(7 downto 0);
	signal symbol_green	:	std_logic_vector(7 downto 0);
	signal symbol_blue	:	std_logic_vector(7 downto 0);
	signal blank		:	std_logic;
	signal hsync		:	std_logic;
	signal vsync		:	std_logic;
begin
    HDMI_tx_rsda  <= 'Z';
    HDMI_tx_cec   <= 'Z';
    HDMI_tx_rscl  <= '1';

	U_VGA_CLKGEN : VGA_CLKGEN
	port map(
				Clk_in		=>	Clk,
				Clk_raw_o	=>	clk_pixel,
				Clk_x1_o	=>	clk_pixel_x1,
				Clk_x5_o	=>	clk_pixel_x5,
				Locked		=>	clk_pixel_locked
			);

	U_VGA : VGA 
	port map(
			  Clk_pixel		=> clk_pixel,
			  Rst_n			=> Rst_n,
			  Hsync_o      	=> hsync,
			  Vsync_o      	=> vsync,
			  Blank_o     	=> blank,
			  Red_o        	=> symbol_red,
			  Green_o      	=> symbol_green,
			  Blue_o      	=> symbol_blue
			);

	U_HDMI_OUT : HDMI_OUT
	port map(
				Clk				=>	clk_pixel,
				Clk_x1		=>	clk_pixel_x1,
				Clk_x5		=>	clk_pixel_x5,
				Rst_n			=>	clk_pixel_locked,

				Blank_i			=>	blank,
				Hsync_i			=>	hsync,
				Vsync_i			=>	vsync,
				Red_i			=>	symbol_red,
				Green_i			=>	symbol_green,
				Blue_i			=>	symbol_blue,

				HDMI_tx_p		=>	HDMI_tx_p,
				HDMI_tx_n		=>	HDMI_tx_n,
				HDMI_tx_clk_p	=>	HDMI_tx_clk_p,
				HDMI_tx_clk_n	=>	HDMI_tx_clk_n
			);

end BEHAVOR;
