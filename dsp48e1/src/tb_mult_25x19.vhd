library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity TB_MULT_25X19 is
end TB_MULT_25X19;


architecture BEHAVOR of TB_MULT_25X19 is
	component MULT_25X19
	port (
			Clk  :  in std_logic;
			Rst_n   :   in  std_logic;
			D0	:	in	std_logic_vector(25 downto 0);
			D1	:	in	std_logic_vector(17 downto 0);
			--! 26 + 18 = 44
			Dout	:	out	std_logic_vector(43 downto 0)

		 );
	end component;

	signal clk : std_logic;
	signal rst :   std_logic;
	signal d0 : std_logic_vector(25 downto 0);
	signal d1 : std_logic_vector(17 downto 0);
	signal result : std_logic_vector(43 downto 0);

	
	signal i : std_logic_vector(4 downto 0);
begin
	U_MULT_25X19 : MULT_25X19
	port map(
				Clk => clk,	
				Rst_n   =>  rst,
				D0		=>	d0,
				D1		=>	d1,
				Dout	=>	result
			);
			
	P_RST : process
	begin
	   rst <= '1';
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

	P_MAIN : process(Clk, rst)
	begin
		if rst = '1' then
			i <= "00000";
elsif clk = '1' and clk = '1' then
			case i is
				when "00000" =>
					i <= i + 1;
				when "00001" =>
					d0 <=  "01" & X"123456";
					d1 <=  "01" & X"1234";
					i <= i + 1;
				when "00010" =>
					i <= i + 1;
				when "00011" =>
					i <= i + 1;
				when "00100" =>
					i <= i + 1;
				when "00101" =>
					i <= i + 1;
				when "00110" =>
					i <= i + 1;
				when "00111" =>
					i <= i + 1;
				when "01000" =>
					i <= i + 1;
				when "01001" =>
					i <= i + 1;
				when others =>
			end case;

		end if;
	end process;


end BEHAVOR;
