library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity TB_TMDS_DECODER is 
end TB_TMDS_DECODER;

architecture BEHAVOR of TB_TMDS_DECODER is
	component TMDS_DECODER
	port (
			Clk		:	in	std_logic;
			Symbol	:	in	std_logic_vector(9 downto 0);
			Data	:	out	std_logic_vector(7 downto 0)
		 );
	end component;


	signal 	clk		:	std_logic;
	signal 	symbol	:	std_logic_vector(9 downto 0);
	signal 	data	:	std_logic_vector(7 downto 0);
begin
	U_TMDS_DECODER : TMDS_DECODER
    port map(
                 Clk        =>    clk,    
                Symbol    =>    symbol,
                Data    =>    data
               );

	U_CLK : process
	begin
		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;
	end process;

	U_DECODER : process
	begin
		symbol <= "1001001111";
		wait;
	end process;

end BEHAVOR;


