------------------------------------------------------------------------------
--! 	@file		vga_pixel_gen.vhd
--! 	@function	产生VGA信号
--!		@version	
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity VGA_PIXEL_GEN is
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
end VGA_PIXEL_GEN;


architecture BEHAVOR of VGA_PIXEL_GEN is
begin


	P_HSYNC : process(Clk_pixel)
	begin
		if Clk_pixel'event and Clk_pixel = '1' then
			Hsync_o <= Hsync_i;
		end if;
	end process;

	P_VSYNC : process(Clk_pixel)
	begin
		if Clk_pixel'event and Clk_pixel = '1' then
			Vsync_o <= Vsync_i;
		end if;
	end process;

	P_BLANK: process(Clk_pixel)
	begin
		if Clk_pixel'event and Clk_pixel = '1' then
			Blank_o <= Blank_i;
		end if;
	end process;

	P_RGB_OUT : process(Clk_pixel)
	begin
		if Clk_pixel'event and Clk_pixel = '1' then
			if Blank_i = '0' then
				if Col_addr_i <= conv_std_logic_vector(200, 12) then
					Red_o <= conv_std_logic_vector(255, 8);
					Green_o <= conv_std_logic_vector(0, 8);
					Blue_o <= conv_std_logic_vector(0, 8);
				elsif Col_addr_i <= conv_std_logic_vector(400, 12) then
					Red_o <= conv_std_logic_vector(0, 8);
					Green_o <= conv_std_logic_vector(255, 8);
					Blue_o <= conv_std_logic_vector(0, 8);
				else
					Red_o <= conv_std_logic_vector(0, 8);
					Green_o <= conv_std_logic_vector(0, 8);
					Blue_o <= conv_std_logic_vector(255, 8);
				end if;
			else
				Red_o 	<= (others => '0');
				Green_o <= (others => '0');
				Blue_o 	<= (others => '0');
					
			end if;
		end if;
	end process;


end BEHAVOR;
