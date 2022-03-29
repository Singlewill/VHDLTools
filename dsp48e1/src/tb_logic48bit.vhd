library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity TB_LOGIC48BIT is
end TB_LOGIC48BIT;


architecture BEHAVOR of TB_LOGIC48BIT is
	component LOGIC48BIT
	port (
			Clk  :  in std_logic;
			Rst_n   :   in  std_logic;
			Ain	:	in	std_logic_vector(47 downto 0);
			Bin	:	in	std_logic_vector(47 downto 0);
			Logic_out	:	out	std_logic_vector(47 downto 0)
		 );
	end component;

	signal clk : std_logic;
	signal rst :   std_logic;
	signal d1 : std_logic_vector(47 downto 0);
	signal d2 : std_logic_vector(47 downto 0);
	signal result : std_logic_vector(47 downto 0);
begin
	U_LOGIC48BIT: LOGIC48BIT
	port map(
				Clk 		=> clk,	
				Rst_n   	=>  rst,
				Ain			=>	d1,
				Bin			=>	d2,
				Logic_out	=>	result
			);
			
	P_RST : process
	begin
	   rst <= '0';
	   wait for 50 ns;
	   rst <= '0';

	   wait;
	end process;
	P_CLK : process
	begin
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
		wait for 5 ns;
	end process;


	P_MAIN : process
	begin
		wait for 20 ns;
		wait until clk'event and clk = '1';
		d1 <=  conv_std_logic_vector(0, 32) & X"12E6";  -- = -0x1a =-26
 		d2 <=  conv_std_logic_vector(0, 32) & X"341B";
 		wait until clk'event and clk = '1';
		d1 <=  conv_std_logic_vector(0, 32) & X"AB12";  -- = -0x1a =-26
 		d2 <=  conv_std_logic_vector(0, 32) & X"8934";
        wait;
	end process;

end BEHAVOR;
