library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
entity TB_SD_CLK_GEN is
end TB_SD_CLK_GEN;


architecture BEHAVOR of TB_SD_CLK_GEN is
	component SD_CLK_GEN
	port (
			Clk_in	:	in	std_logic ;
			Rst_n	:	in	std_logic;
			Fast	:	in	std_logic;
			Clk_out	:	out	std_logic
		 );
	end component;



	signal clk		:	std_logic;
	signal rst 		:	std_logic;
	signal fast 	:	std_logic;
	signal clk_out	:	std_logic;
begin
	U_SD_CLK_GEN : SD_CLK_GEN
	port map(
				Clk_in	=>	clk,
				Rst_n	=>	rst,
				Fast	=>	fast,
				Clk_out	=> 	clk_out
			);

	U_CLK : process
	begin
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
		wait for 5 ns;
	end process;

	U_RST : process
	begin
		rst <= '0';
		wait for 100 ns;
		rst <= '1';
		wait;
	end process;

	U_FAST : process
	begin
		Fast <= '1';
		wait for 500 us;
		Fast <= '0';
		wait;
	end process;
end BEHAVOR;
