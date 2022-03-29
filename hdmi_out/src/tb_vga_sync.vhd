
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity TB_VGA_SYNC is
end TB_VGA_SYNC;

architecture BEHAVOR of TB_VGA_SYNC is
	component VGA_SYNC
	generic (
				HRES	:	integer := 800;	
				VRES	:	integer := 600
			);
	port (
			Clk_pixel	:	in	std_logic; 
			Rst_n		:	in	std_logic;
			Hsync		:	out	std_logic;
			Vsync		:	out	std_logic;
			Blank		:	out	std_logic;
			Row_addr	:	out std_logic_vector(11 downto 0);
			Col_addr	:	out std_logic_vector(11 downto 0)
		 );
	end component;

	signal	clk : std_logic;
	signal	rst : std_logic;
	signal hsync 	:	std_logic;
	signal vsync	:	std_logic;
	signal blank	:	std_logic;
	signal row_addr	:  std_logic_vector(11 downto 0);
	signal col_addr	:  std_logic_vector(11 downto 0);

begin
	P_CLK : process
	begin
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
		wait for 5 ns;
	end process;
	P_RST : process
    begin
        rst <= '0';
        wait for 100 ns;
        rst <= '1';
        wait ;
    end process;

	U_VGA_SYNC : VGA_SYNC
	generic map(
					HRES 	=> 800  ,	
					VRES	=>	600
			   )
	port map(
					Clk_pixel	=>	clk,	
					Rst_n      =>  rst,
					Hsync		=>	hsync,
					Vsync		=>	vsync,
					Blank		=>	blank,
					Row_addr	=>	row_addr,
					Col_addr	=>	col_addr
			);



end BEHAVOR;
