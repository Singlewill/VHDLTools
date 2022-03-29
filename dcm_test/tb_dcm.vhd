library  IEEE;
use IEEE.std_logic_1164.all;


Library UNISIM;
use UNISIM.vcomponents.all;
entity TB_MMCME2 is
end TB_MMCME2;
architecture BEVAVOR of TB_MMCME2 is
	component clk_wiz_0_clk_wiz_0_clk_wiz is
		port (
				 clk_in1 : in STD_LOGIC;
				 clk_out1 : out STD_LOGIC;
				 clk_out2 : out STD_LOGIC;
				 clk_out3 : out STD_LOGIC;
				 clk_out4 : out STD_LOGIC;
				 reset : in STD_LOGIC;
				 locked : out STD_LOGIC
			 );
	end component;


	component PLL_50M is
		port(
				Clk_in	:	in	std_logic;	
				Rst_n:	in	std_logic;
				locked	:	out	std_logic;
				Clk_out	:	out	std_logic
			);
	end component;
	component MMCME2_50M is
		port(
				Clk_in	:	in	std_logic;	
				Rst_n:	in	std_logic;
				locked	:	out	std_logic;
				Clk_out	:	out	std_logic
			);
	end component;
	component MMCM_BASE_CLK is
	port(
			Clk_in		:	in	std_logic;	
			Rst_n		:	in	std_logic;
			locked		:	out	std_logic;
			Clk_out0	:	out	std_logic;
			Clk_out1	:	out	std_logic
		);
	end component;


	signal rst : std_logic;
	signal locked : std_logic;
	--! 时钟输入
	signal clk	:	std_logic;
	signal clkout0 : std_logic;
	signal clkout1 : std_logic;
	signal clkout2 : std_logic;
	signal clkout3 : std_logic;
	signal clkout4 : std_logic;
	
begin

	U_CLK : process
	begin
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
		wait for 5 ns;
	end process;

	U_RST: process
	begin
		rst <= '0';
		wait for 100 ns;
		rst <= '1';
		wait;
	end process;
	


--	U_CLK_WIZ : clk_wiz_0_clk_wiz_0_clk_wiz
--	port map(
--				clk_in1		=>	clk,
--				clk_out1 	=>	clkout1,
--				clk_out2 	=>	clkout2,
--				clk_out3 	=>	clkout3,
--				clk_out4 	=>	clkout4,
--				reset 		=>	rst,
--				locked 		=>	locked
--			);

--	U_PLL : MMCME2_50M
--	port map ( 
--				 Clk_in	=> clk,
--				 Rst_n=> rst,
--				 locked		=> locked,
--				 Clk_out	=> clkout1
--			 );
--   U_CLK_WIZ : clk_wiz_clk_wiz
--   port map(
--      clk_in1 => clk,
--      reset => rst,
--     locked => locked,
--    clk_out1 => clkout1
--);
	U_MMCM_BASE : MMCM_BASE_CLK
	port map(
				Clk_in	=>	clk,	
				Rst_n 	=>	rst,
				locked 	=>	locked,
				Clk_out0 	=>	clkout0,
				Clk_out1	=>	clkout1
			);
end BEVAVOR;
