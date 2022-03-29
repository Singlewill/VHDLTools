library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

use work.sd_pkt.all;

entity TB_SD_TXRX is
end TB_SD_TXRX;

architecture  BEHAVOR of TB_SD_TXRX is
	component SD_TXRX 
	port (
			Clk			:	in	std_logic; 
			Rst_n		:	in 	std_logic;
			Start		:	in	std_logic;
			cmd_in		:	in	cmd_type;
			Resp_stat	:	out	resp_stat_type;
			Done		:	out	std_logic;

			Sd_clk_o		: out		std_logic;
			Sd_cmd			: inout	std_logic;
			Sd_dat			: inout	std_logic_vector(3 downto 0)
		 );
	end component;

	signal clk		:	std_logic;
	signal rst	:	std_logic;
	signal start	:	std_logic;
	signal cmd : CMD_TYPE;
	signal resp_stat :resp_stat_type;
	signal done : std_logic;
	signal sd_clk : std_logic;
	signal sd_cmd : std_logic;
	signal sd_dat : std_logic_vector(3 downto 0);

	signal data_address  : std_logic_vector(31 downto 0) := (others => '0');
begin

	U_SD_TXRX : SD_TXRX
	port map(
				Clk 	=>	clk,			
				Rst_n	=>	rst,
				Start	=>	start,
				cmd_in	=>	cmd,
				Resp_stat => resp_stat,
				Done	=>	done,
				Sd_clk_o => sd_clk,
				Sd_cmd	=>	sd_cmd,
				Sd_dat => sd_dat
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
end BEHAVOR;
