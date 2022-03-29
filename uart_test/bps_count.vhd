-------------------------------------------------------------------------------
--! @file		bps_count.vhd
--! @function	波特率计数,每个bit输出一个脉冲
--! @eg			(1)　这里的逻辑不需要复位
--!				(2)  HALF_OUT = 1时，在bit中间输出脉冲
--!					 HALF_OUT = 0时，在bit末尾输出脉冲					
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity BPS_COUNT is
	generic (
			constant CLKFREQ  : integer := 100e6;
			constant BAUDRATE : integer := 115200;
			constant HALF_OUT : integer := 1);
	port (
			Clk		:	in	std_logic; 
			Enable	:	in	std_logic;
			Sig		:	out	std_logic
		 );
end BPS_COUNT;


architecture BEHAVOR of BPS_COUNT is
	--! CNT_UP计数 :
	--! CNT_UP = CLK_FREQ / BAUDRATE;
	--! Clk = 100Mhz时, CNT_UP=868 		=> bps=115200
	--! Clk = 100Mhz时, CNT_UP=10416 	=> bps=9600
	constant CNT_UP	:	integer := CLKFREQ/BAUDRATE;
	signal cnt		:	integer range 0 to CNT_UP;
begin
	U_CNT : process(Clk)
	begin
		if Clk'event and Clk = '1' then
			if Enable = '1' then
				if cnt = CNT_UP then
					cnt <= 0;
				else
					cnt <= cnt + 1;
				end if;
			else
				cnt <= 0;
			end if;
		end if;
	end process;

	Sig	<=	'1' when cnt = CNT_UP/2 and HALF_OUT = 1 else
		   '1' when cnt = CNT_UP and HALF_OUT = 0 else
		   '0';
end BEHAVOR;
