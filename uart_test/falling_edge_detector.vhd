-------------------------------------------------------------------------------
--! @file		falling_edge_detector.vhd
--! @describe	Pin下降沿检测，检测到输出一个周期的高电平脉冲
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity FALLING_EDGE_DETECTOR is
	port (
			Clk		:	in	std_logic; 
			Rst_n	:	in	std_logic;
			Pin		:	in	std_logic;
			Sig		:	out	std_logic
		 );
end FALLING_EDGE_DETECTOR;


architecture BEHAVOR of FALLING_EDGE_DETECTOR is
	signal pin_l1	:	std_logic;
	signal pin_l2	:	std_logic;
begin
	U_DETECTE : process(Clk, Rst_n)
	begin
		if Clk'event and Clk = '1' then
			if Rst_n = '0' then
				pin_l1 <= '1';
				pin_l2 <= '1';
			else
				pin_l1 <= Pin;
				pin_l2 <= pin_l1;
			end if;
		end if;
	end process;

	Sig	<= '1'  when pin_l2 = '1' and pin_l1 = '0' else
		   '0';
end BEHAVOR;

