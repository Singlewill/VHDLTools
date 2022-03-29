------------------------------------------------------------------------------
--! 	@file		sd_clk_gen.vhd
--! 	@function	sd时钟生成
--!		@version	
-----------------------------------------------------------------------------
--		输入Clk_in为100Mhz
--		当Fast = 0, Clk_out输出200KHz
--		当Fast = 1, Clk_out输出50MHz
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


entity SD_CLK_GEN is
	port (
			Clk_in	:	in	std_logic ;
			Rst_n	:	in	std_logic;
			Fast	:	in	std_logic;
			Clk_out	:	out	std_logic
		 );


end SD_CLK_GEN;
architecture BEHAVOR of SD_CLK_GEN is
	--! div = CLK_IN_FREQ/CLK_OUT_FREQ - 1
	constant	fast_div	:	integer	:= 0;	-- 50Mhz
	constant 	slow_div	:	integer := 249;	-- 200Khz
	signal 		cnt_val		:	integer range 0 to 499;
	signal 		div_val		:	integer range 0 to 499;

	signal 		clk_tmp 	:	std_logic;


begin
	div_val	<= fast_div when Fast = '1' else	--!	50MHz
			   slow_div;						--! 200KHz

	U_DIV : process(Clk_in, Rst_n)
	begin
		if Clk_in'event and Clk_in = '1' then
			if Rst_n = '0' then
				cnt_val <= 0;
				clk_tmp	<= '0';
			elsif cnt_val >= div_val then
				cnt_val <= 0;
				clk_tmp <= not clk_tmp;
			else
				cnt_val <= cnt_val + 1;
			end if;
		end if;
					   
	end process;
	Clk_out <= 	clk_tmp;

end BEHAVOR;

