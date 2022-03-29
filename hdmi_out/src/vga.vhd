------------------------------------------------------------------------------
--! 	@file		hdmi_out.vhd
--! 	@function	hdmi信号输出
--!		@version	
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


entity VGA is
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
end VGA;

architecture BEHAVOR of VGA is
	component VGA_SYNC
	generic (
				HRES	:	integer := 800;	
				VRES	:	integer := 600
			);
	port (
			Clk_pixel	:	in	std_logic; 
			Rst_n		:	in	std_logic;
			Hsync		:	out	std_logic;
			Vsync		:	out	std_logic;
			Blank		:	out	std_logic;
			Row_addr	:	out std_logic_vector(11 downto 0);
			Col_addr	:	out std_logic_vector(11 downto 0)
		 );
	end component;

	component VGA_PIXEL_GEN
	port (
			Clk_pixel	:	in	std_logic; 
			Hsync_i		:	in	std_logic;
			Vsync_i		:	in	std_logic;
			Blank_i		:	in	std_logic;
			Row_addr_i	:	in	std_logic_vector(11 downto 0);
			Col_addr_i	:	in	std_logic_vector(11 downto 0);

			Hsync_o		:	out	std_logic;
			Vsync_o		:	out	std_logic;
			Blank_o		:	out	std_logic;
			Red_o		:	out	std_logic_vector(7 downto 0);
			Green_o		:	out	std_logic_vector(7 downto 0);
			Blue_o		:	out	std_logic_vector(7 downto 0)
		 );
	end component;
	--------------------------------------------------------------------------
	--! 内部信号定义
	--------------------------------------------------------------------------
	signal blank	:	std_logic;
	signal hsync	:	std_logic;
	signal vsync	:	std_logic;
	signal row_addr	:	std_logic_vector(11 downto 0);
	signal col_addr	:	std_logic_vector(11 downto 0);
begin

	U_VGA_SYNC : VGA_SYNC
	generic map(
			  		HRES 	=>	1280, 
					VRES	=>	720
			   )
	port map(
					Clk_pixel	=>	Clk_pixel,
					Rst_n		=>	Rst_n,
					Hsync		=>	hsync,
					Vsync		=>	vsync,
					Blank		=> 	blank,
					Row_addr	=>	row_addr,
					Col_addr	=>	col_addr
			);
	U_VGA_PIXEL_GEN : VGA_PIXEL_GEN
	port map(
					Clk_pixel	=>	Clk_pixel,
					Blank_i		=>	blank,
					Hsync_i		=>	hsync,
					Vsync_i		=>	vsync,
					Row_addr_i	=>	row_addr,
					Col_addr_i	=>	col_addr,

					Hsync_o		=>	Hsync_o,
					Vsync_o		=>	Vsync_o,
					Blank_o		=>	Blank_o,
					Red_o		=>	Red_o,
					Green_o		=>	Green_o,
					Blue_o		=>	Blue_o
			);
end BEHAVOR;



