library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity TB_MUX48BIT is
end TB_MUX48BIT;


architecture BEHAVOR of TB_MUX48BIT is
	component MUX48BIT
	port (
			Clk  	:  in std_logic;
			Rst_n   :   in  std_logic;
			D0		:	--! 8个48bit数据	
						in	std_logic_vector(47 downto 0);
			D1		:	in	std_logic_vector(47 downto 0);
			D2		:	in	std_logic_vector(47 downto 0);
			D3		:	in	std_logic_vector(47 downto 0);
			D4		:	in	std_logic_vector(47 downto 0);
			D5		:	in	std_logic_vector(47 downto 0);
			D6		:	in	std_logic_vector(47 downto 0);
			D7		:	in	std_logic_vector(47 downto 0);
			Sel		:	--! 选择	
						in	std_logic_vector(2 downto 0);
			Dout	:	out	std_logic_vector(47 downto 0)
		 );
	end component;

	signal clk : std_logic;
	signal rst :   std_logic;
	signal d0 : std_logic_vector(47 downto 0);
	signal d1 : std_logic_vector(47 downto 0);
	signal d2 : std_logic_vector(47 downto 0);
	signal d3 : std_logic_vector(47 downto 0);
	signal d4 : std_logic_vector(47 downto 0);
	signal d5 : std_logic_vector(47 downto 0);
	signal d6 : std_logic_vector(47 downto 0);
	signal d7 : std_logic_vector(47 downto 0);
	signal result : std_logic_vector(47 downto 0);
	signal sel : std_logic_vector(2 downto 0);
begin
	U_MUX48BIT: MUX48BIT
	port map(
				Clk 		=> clk,	
				Rst_n   	=>  rst,
				D0			=>	d0,
				D1			=>	d1,
				D2			=>	d2,
				D3			=>	d3,
				D4			=>	d4,
				D5			=>	d5,
				D6			=>	d6,
				D7			=>	d7,
				Sel			=>	sel,
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
			d0 <= X"111111111111";
			d1 <= X"222222222222";
			d2 <= X"333333333333";
			d3 <= X"444444444444";
			d4 <= X"555555555555";
			d5 <= X"666666666666";
			d6 <= X"777777777777";
			d7 <= X"888888888888";

			sel <= "000";
		elsif clk = '1' and clk = '1' then
			sel <= sel + 1;
		end if;
	end process;

end BEHAVOR;
