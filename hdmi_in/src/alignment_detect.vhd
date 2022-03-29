------------------------------------------------------------------------------
--! 	@file		alignment_detect.vhd
--! 	@function	对IDELAY2的CNTVALUEIN和CE进行动态控制以调整输入延时
--! 	@TODO		这个模块的结构也乱的要死， 改!!
--!		@version	V1.0
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity ALIGNMENT_DETECT is
	port ( 
			 Clk            : in  std_logic;
			 Rst_n			: in  std_logic;
			 Symbol_valid	: in  std_logic;
			 Delay_cnt    	: out std_logic_vector(4 downto 0);
			 Delay_ce       : out std_logic;
			 Bitslip        : out std_logic
		 );
end ALIGNMENT_DETECT;

architecture BEHAVOR of ALIGNMENT_DETECT is
	--! 1920*1080 = 21bit
    signal signal_quality : std_logic_vector(19 downto 0);
    signal idelay_ce      : std_logic;
    signal idelay_count   : std_logic_vector(4 downto 0);
    signal ibitslip      : std_logic;
begin
    Delay_cnt 	<= idelay_count;
    Delay_ce    <= idelay_ce;
	Bitslip		<= ibitslip;
 
	P_ALIGN_DETECT : process(Clk, Rst_n)
	begin
		if Rst_n = '0' then
			signal_quality 	<=	(others => '0');
			idelay_count 	<= 	(others => '0');
		elsif Clk'event and Clk = '1' then
			idelay_ce <= '0';
			ibitslip <= '0';

			if Symbol_valid = '1' then
				signal_quality <= (others => '0');
			else
				signal_quality <= signal_quality + 1;
			end if;


			if signal_quality = X"FFFFF" then
				idelay_count <= idelay_count + 1;
				idelay_ce <= '1';
			end if;

			if idelay_count = "1111" then
				ibitslip <= '1';
			end if;
		end if;
	end process;

end BEHAVOR;
