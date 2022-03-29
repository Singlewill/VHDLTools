library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity TB_MULT_25X18 is
end TB_MULT_25X18;


architecture BEHAVOR of TB_MULT_25X18 is
	component MULT_25X18
	port (
			Clk  :  in std_logic;
			Rst_n   :   in  std_logic;
			Ain	:	in	std_logic_vector(24 downto 0);
			Bin	:	in	std_logic_vector(17 downto 0);
			Cin	:	in	std_logic_vector(47 downto 0);
			--! 25 + 18 = 43
			Pout	:	out	std_logic_vector(42 downto 0)
		 );
	end component;

	signal clk : std_logic;
	signal rst :   std_logic;
	signal d1 : std_logic_vector(24 downto 0);
	signal d2 : std_logic_vector(17 downto 0);
	--! C值最好不要超过Pout位长
	--signal c1 :	std_logic_vector(42 downto 0) := (42 => '1', 0 => '1', others => '0');
	signal c1 : std_logic_vector(47 downto 0) := (others => '1');
	signal result : std_logic_vector(42 downto 0);

	
	signal i : std_logic_vector(4 downto 0);
begin
	U_MULT_TEST : MULT_25X18
	port map(
				Clk => clk,	
				Rst_n   =>  rst,
				Ain		=>	d1,
				Bin		=>	d2,
				Cin		=>	c1,
				Pout	=>	result
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
					d1 <=  conv_std_logic_vector(0, 17) & X"E6";  -- = -0x1a =-26
					d2 <=  conv_std_logic_vector(0, 10) & X"1B";
					i <= i + 1;
				when "00010" =>
					d1 <=  '1' & X"ffffe6";  -- = -0x1a
					d2 <=  conv_std_logic_vector(0, 10) & X"34";
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
