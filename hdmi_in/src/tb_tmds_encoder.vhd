------------------------------------------------------------------------------
--! 	@file		tb_tmds_encoder.vhd
--! 	@function	tmds_encoder.vhd的测试文件
--!		@version	
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


entity TB_TMDS_ENCODER is
end TB_TMDS_ENCODER;

architecture BEHAVOR of TB_TMDS_ENCODER is
	component TMDS_ENCODER 
	port ( 
			Clk		:	in	std_logic;
			D_in	:	in	std_logic_vector(7 downto 0);
			C_in	:	in	std_logic_vector(1 downto 0);
			C_en	:	in	std_logic;
			Q_out	:	out std_logic_vector(9 downto 0)

		 );
	end component;


	signal clk 			: std_logic;

	signal data_in		:	std_logic_vector(7 downto 0);
	signal data_out		: std_logic_vector(9 downto 0);
begin
	U_CLK : process
	begin
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
		wait for 5 ns;
	end process;

	U_TMDS_ENCODER : TMDS_ENCODER
	port map(
				Clk		=>	clk,
				D_in	=>	data_in,
				C_in	=>	"00",
				C_en	=>	'0',
				Q_out	=>	data_out
			);

	U_MAIN : process
	begin

		wait until clk'event and clk = '1';
		data_in	<=  "10101011";		

		wait;


	end process;




end BEHAVOR;
