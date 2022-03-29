------------------------------------------------------------------------------
--! 	@file		histogram_2d.vhd
--! 	@function	直方图统计
--!		@version	
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_loigc_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity HISTOGRAM_2D is 
	generic (
				IH	:	--! 图像高度	
						integer := 512;
				IW	:	--! 图像宽度	
						integer := 640;
				DW	:	--! Din位宽	
						integer := 14;	
				TW	:	--! 直方图数据位宽LOG2(640*512),向上取整
						integer := 32
				
			);
	port (
			Clk			:	in	std_logic; 
			Rst_n		:	in	std_logic;
			Din			:	in	std_logic_vector(DW - 1 downto 0);
			Din_valid	:	in	std_logic;
			Vsync_in	:	in	std_logic;
	
			Dout		:	out	std_logic(TW - 1 downto 0);
			Dout_valid	:	out	std_logic;
			Int_flag	:	--! 中断信号
							out	std_logic;
			Rdy_out		:	--! 数据输出请求
							in	std_logic
		 );

end HISTOGRAM_2D;

architecture BEHAVOR of HISTOGRAM_2D is
	--! 数据数据打两拍, 主要操作在*_r2
	signal din_r		:	std_logic_vector(DW - 1 downto 0);
	signal din_r2		:	std_logic_vector(DW - 1 downto 0);
	signal din_valid_r	:	std_logic;
	signal din_valid_r2	:	std_logic;
	signal vsync_r		:	std_logic;
begin
	U_SYNC : process(Clk)
	begin
		if Clk'event and Clk = '1' then
			vsync_r 	<= Vsync_in;

			din_r		<= Din;
			din_r2		<= din_r;
			din_valid_r <= Din_valid;
			din_valid_r2<= din_valid_r;
		end if;
	end process;


end BEHAVOR;
