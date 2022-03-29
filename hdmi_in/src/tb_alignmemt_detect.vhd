------------------------------------------------------------------------------
--! 	@file		tb_alignment_detect.vhd
--! 	@function	对alignment_detect模块的测试文件
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity TB_ALIGNMENT_DETECT is 
end TB_ALIGNMENT_DETECT;



architecture BEHAVOR of TB_ALIGNMENT_DETECT is 
	component ALIGNMENT_DETECT 
	port ( 
			 Clk            : in  std_logic;
			 Rst_n			: in  std_logic;
			 Symbol_valid	: in  std_logic;
			 Delay_cnt    	: out std_logic_vector(4 downto 0);
			 Delay_ce       : out std_logic;
			 Bitslip        : out std_logic
		 );
	end component;


	signal	clk	:	std_logic;
	signal	rst	:	std_logic;
	signal  valid : 	std_logic;

	signal delay_cnt : std_logic_vector(4 downto 0);
	signal delay_ce : std_logic;
	signal bitslip : std_logic;
begin
	U_ALIGNMENT_DETECT : ALIGNMENT_DETECT
	port map(
				Clk => clk,	
				Rst_n => rst,
				Symbol_valid => valid,
				Delay_cnt => delay_cnt,
				Delay_ce => delay_ce,
				Bitslip => bitslip
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

	U_MAIN : process
	begin
--		valid <= '1';
--		wait for 100 ns;
		valid <= '0';
		wait for 100 ns;
	end process;
end BEHAVOR;
