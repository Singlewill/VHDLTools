library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

use work.sd_pkt.all;


entity TB_SD_CMD_TX is
end TB_SD_CMD_TX;

architecture BEHAVOR of TB_SD_CMD_TX is
	component SD_CMD_TX 
	port (
			
			Clk				:	in		std_logic;
			Clk_tick			: 	in		std_logic; 
			Rst_n			:	in 		std_logic;

			Start			:	in		std_logic;
			Fast			:	in		std_logic;
			Cmd_in			:	in		cmd_type;
			Done			:	out		std_logic;
			Busy			:	out		std_logic;
		
			--! sd interface
			sd_cmd			: 	inout	std_logic;
			sd_dat			: 	inout	std_logic_vector(3 downto 0)
			
		 );
	end component;
	component SD_CLK_GEN 
	port (
			Clk_in	:	in	std_logic ;
			Rst_n	:	in	std_logic;
			Fast	:	in	std_logic;
			Clk_out	:	out	std_logic
		 );
	end component;


	signal	clk			:	std_logic;
	signal 	rst			:	std_logic;
	signal sd_clk			:	std_logic;
	signal sd_clk_l1		:	std_logic;
	signal sd_clk_l2		:	std_logic;
	signal sd_clk_falling	:	std_logic;


	signal 	start		:	std_logic;
	signal fast :	std_logic;
	signal cmd_in	:	cmd_type;
	signal done : std_logic;
	signal busy	:	std_logic;
	signal	sd_cmd	:	std_logic;
	signal sd_dat : std_logic_vector(3 downto 0);
begin
	U_SD_CLK_GEN : SD_CLK_GEN
	port map(
				Clk_in		=>	Clk,
				Rst_n		=>	Rst_n,
				Fast		=>	fast,
				Clk_out		=>	sd_clk
			);


	U_SD : SD_CMD_TX
	port map(
				Clk	=>	clk;	
				Clk_tick => sd_clk_falling ,
				Rst_n	=>	rst,
				Start	=>	start,
				Fast	=>	fast,
				Cmd_in	=>	cmd_in,
				Done	=>	done,
				Busy	=>	busy,
				sd_cmd	=>	sd_cmd,
				sd_dat => sd_dat
			);

	U_CLK_EDGE : process(clk)
	begin
		if clk'event and clk = '1' then
			sd_clk_l1 <= sd_clk;
			sd_clk_l2 <= sd_clk_l2;
		end if;
	end process;

	sd_clk_falling <= '1' when sd_clk = '0' and sd_clk_l2 = '1' else
					  '0';

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
	U_MAIN : process
	begin
		
		wait for 500 us;
		Fast <= '0';
		wait;
end BEHAVOR;
