------------------------------------------------------------------------------
--! 	@file		tb_tmds_decoder.vhd
--! 	@function	tmds_decoder.vhd的测试文件
--!		@version	
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


entity TB_TMDS_DECODER is
end TB_TMDS_DECODER;

architecture BEHAVOR of TB_TMDS_DECODER is
	component TMDS_DECODER 
	port ( 
			 Clk              : in  std_logic;
			 Data_in			: in  std_logic_vector (9 downto 0);
			 Symbol_valid   : out std_logic;

			 Ctl_valid        : out std_logic;
			 Ctl              : out std_logic_vector (1 downto 0);

			 Terc4_valid      : out std_logic;
			 Terc4            : out std_logic_vector (3 downto 0);

			 Data_valid       : out std_logic;
			 Data_out         : out std_logic_vector (7 downto 0)
		 );
	end component;


	signal clk 			: std_logic;
	signal data_in		: std_logic_vector(9 downto 0);
	signal symbol_valid : std_logic;
	signal ctl_valid 	: std_logic;
	signal ctl 			: std_logic_vector(1 downto 0);
	signal terc4_valid 	: std_logic;
	signal terc4 		: std_logic_vector(3 downto 0);
	signal data_valid 	: std_logic;
	signal data_out 	: std_logic_vector(7 downto 0);
begin
	U_CLK : process
	begin
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
		wait for 5 ns;
	end process;

	U_TMDS_DECODER : TMDS_DECODER
	port map(
				Clk				=>	clk,	
				Data_in			=>	data_in,
				Symbol_valid	=>	symbol_valid,
				Ctl_valid		=>	ctl_valid,
				Ctl				=>	ctl,
				Terc4_valid		=>	terc4_valid,
				Terc4			=>	terc4,
				Data_valid		=>	data_valid,
				Data_out		=>	data_out
			);

	U_MAIN : process
	begin

		wait until clk'event and clk = '1';
		data_in	<=  "0010101011";		-- ctl

		wait until clk'event and clk = '1';
		data_in	<=  "1011001100";		-- terc4

		wait until clk'event and clk = '1';
		data_in	<=  "0101010100";		-- ctl

		wait until clk'event and clk = '1';
		data_in	<= "1011111100";		-- data

		wait until clk'event and clk = '1';
		data_in	<=  "1010101011";		-- ctl

		wait until clk'event and clk = '1';
		data_in	<= "0011111001";		-- data

		wait until clk'event and clk = '1';
		data_in	<=  "0101100011";		-- terc4


		wait until clk'event and clk = '1';
		data_in	<=  "1111111111";		-- terc4

		wait;


	end process;




end BEHAVOR;
