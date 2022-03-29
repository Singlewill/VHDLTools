------------------------------------------------------------------------------
--!		@file		tb_lfsr.vhd
--! 	@function	反馈移位计数器的测试文件
--!		@version	
------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity TB_LFSR is
end TB_LFSR;

architecture BEHAVOR of TB_LFSR is
	component LFSR
	generic(LENGTH : integer);
	port (
		 	Clk	:	in	std_logic;
			Rst_n	:	in	std_logic;
			En	:	in	std_logic;
			Dout	:	out	std_logic_vector(LENGTH - 1 downto 0)
		 );
	end component;


	signal clk : std_logic;
	signal rst: std_logic;
	signal en : std_logic;
	signal data : std_logic_vector(2 downto 0);
begin


	U_LFST : LFSR
	generic map (LENGTH => 3)
	port map(
				Clk => clk,
				Rst_n	=>	rst,
				En		=>	en,
				Dout	=>	data
			);


	process
	begin
		clk <= '1' ;
		wait for 5 ns;
		clk <= '0';
		wait for 5 ns;
	end process;

	process
	begin
		rst <= '0';
		wait for 100 ns;
		rst <= '1';
		wait;

	end process;
end BEHAVOR;
