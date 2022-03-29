library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity TB_MULT_25X35 is
end TB_MULT_25X35;


architecture BEHAVOR of TB_MULT_25X35 is
	component MULT_25X35
	port (
			Clk  :  in std_logic;
			Rst_n   :   in  std_logic;
			D0	:	in	std_logic_vector(24 downto 0);
			D1	:	in	std_logic_vector(34 downto 0);
			Dout	:	out	std_logic_vector(59 downto 0)
		 );
	end component;

	signal clk : std_logic;
	signal rst :   std_logic;
	signal d0 : std_logic_vector(24 downto 0);
	signal d1 : std_logic_vector(34 downto 0);
	signal result : std_logic_vector(59 downto 0);

	
	signal i : std_logic_vector(4 downto 0);
begin
	U_MULT_25X35 : MULT_25X35
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
					d0 <=  '0' & X"121212";
					d1 <=  "011" & X"78787878";
					i <= i + 1;
				when "00010" =>
					d0 <=  '0' & X"283456";
					d1 <=  "011" & X"28345678";
					i <= i + 1;
				when "00011" =>
					d0 <=  '0' & X"777777";
                    d1 <=  "011" & X"eeeeeeee";
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
