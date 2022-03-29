------------------------------------------------------------------------------
--! 	@file		vga_sync.vhd
--! 	@function	生成vga同步信号
--!		@version	
-----------------------------------------------------------------------------
--!  	1280*720@60Mhz	==>		Clk_pixel = 75M
--!  	800*600@60Mhz	==>		Clk_pixel = 40M
--! 	这里用了太多的组合逻辑，可优化
-----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


entity VGA_SYNC is
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
end VGA_SYNC;


architecture BEHAVOR of VGA_SYNC is
	signal h_sync	:	std_logic_vector(11 downto 0);
	signal h_bporch	:	std_logic_vector(11 downto 0);
	signal h_active	:	std_logic_vector(11 downto 0);
	signal h_fporch	:	std_logic_vector(11 downto 0);
	signal h_total	:	std_logic_vector(11 downto 0);

	signal v_sync	:	std_logic_vector(11 downto 0);
	signal v_bporch	:	std_logic_vector(11 downto 0);
	signal v_active	:	std_logic_vector(11 downto 0);
	signal v_fporch	:	std_logic_vector(11 downto 0);
	signal v_total	:	std_logic_vector(11 downto 0);

	signal cnt_h	:	std_logic_vector(11 downto 0) := (others => '0');	
	signal cnt_v	:	std_logic_vector(11 downto 0) := (others => '0');

	signal is_blank	:	std_logic;
begin
	PAR_GEN1 : if HRES = 1280 and VRES = 720 generate
		h_sync		<= conv_std_logic_vector(44, 12);
		h_bporch	<= conv_std_logic_vector(220, 12);
		h_active	<= conv_std_logic_vector(1280, 12);
		h_fporch	<= conv_std_logic_vector(110,  12);
		h_total		<= conv_std_logic_vector(1654, 12);

		v_sync		<= conv_std_logic_vector(5, 12);
		v_bporch	<= conv_std_logic_vector(20, 12);
		v_active	<= conv_std_logic_vector(720, 12);
		v_fporch	<= conv_std_logic_vector(5, 12);
		v_total		<= conv_std_logic_vector(750, 12);
	end generate PAR_GEN1;

	PAR_GEN2 : if HRES = 800 and VRES = 600 generate
		h_sync		<= conv_std_logic_vector(128, 12);
		h_bporch	<= conv_std_logic_vector(88, 12);
		h_active	<= conv_std_logic_vector(800, 12);
		h_fporch	<= conv_std_logic_vector(40,  12);
		h_total		<= conv_std_logic_vector(1056, 12);

		v_sync		<= conv_std_logic_vector(4, 12);
		v_bporch	<= conv_std_logic_vector(23, 12);
		v_active	<= conv_std_logic_vector(600, 12);
		v_fporch	<= conv_std_logic_vector(1, 12);
		v_total		<= conv_std_logic_vector(628, 12);
	end generate PAR_GEN2;

	P_CNTH : process(Clk_pixel, Rst_n)
	begin
		if Clk_pixel'event and Clk_pixel = '1' then
			if Rst_n = '0' then
				cnt_h <= (others => '0');
			elsif cnt_h = h_total - 1 then
				cnt_h <= (others => '0');
			else
				cnt_h <= cnt_h + 1;
			end if;
		end if;
	end process;

	P_CNTV : process(Clk_pixel, Rst_n)
	begin
		if Clk_pixel'event and Clk_pixel = '1' then
			if Rst_n = '0' then
				cnt_v <= (others => '0');
			elsif cnt_h = h_total - 1 and cnt_v = v_total - 1 then
				cnt_v <= (others => '0');
			elsif cnt_h = h_total - 1 then
				cnt_v <= cnt_v + 1;
			end if;
		end if;
	end process;

	is_blank	<= '0' when (cnt_h >= h_sync + h_bporch and cnt_h < h_sync + h_bporch + h_active) and 
			 				(cnt_v >= v_sync + v_bporch and cnt_v < v_sync + v_bporch + v_active) else
			 		'1';

	Hsync 		<= '0' when cnt_h	< h_sync else
			 		'1';
	Vsync 		<= '0' when cnt_v	< v_sync else
			 		'1';
	Blank		<= is_blank;
	Row_addr 	<= cnt_h - h_sync - h_bporch when is_blank = '0' else
					(others => '0');

	Col_addr 	<= cnt_v - v_sync - v_bporch when is_blank = '0' else
				(others => '0');


end BEHAVOR;
