------------------------------------------------------------------------------
--!		@file		lfsr.vhd
--! 	@function	反馈移位计数，伪随机数发生器，(2**LENGTH - 1)伪随机数无限
--!					循环，可作为mem地址使用，比单纯加法器快
--!		@
--!		@version	
------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
--use IEEE.numeric_std.all;
entity LFSR is
	--! LENGTH必须>= 3
	generic(LENGTH : integer);
	port (
		 	Clk	:	in	std_logic;
			Rst_n	:	in	std_logic;
			En	:	in	std_logic;
			Dout	:	out	std_logic_vector(LENGTH - 1 downto 0)
		 );
end LFSR;
architecture BEHAVOR of LFSR is
	signal fb : std_logic;
	signal rdata : std_logic_vector(LENGTH - 1 downto 0);
	signal ll_test : std_logic_vector(3 downto 0);
begin

	fb 		<= not(rdata(LENGTH - 1) XOR rdata(LENGTH/2));
	Dout 	<= rdata;
	process(Clk, Rst_n)
	begin
		if Clk'event and Clk = '1' then
			if Rst_n = '0' then
			     ll_test <= (others => '0');
			       
				rdata <= (others => '0');
			else
			     ll_test <= ll_test + 1;
				rdata <= rdata(LENGTH - 2 downto 0) & fb;
			end if;
		end if;
	end process;



end BEHAVOR;

