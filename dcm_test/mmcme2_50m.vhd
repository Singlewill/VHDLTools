library IEEE;
Library UNISIM;
use IEEE.std_logic_1164.all;
use UNISIM.vcomponents.all;

entity MMCME2_50M is
	port(
			Clk_in	:	in	std_logic;	
			Rst_n	:	in	std_logic;
			locked	:	out	std_logic;
			Clk_out	:	out	std_logic
		);
end MMCME2_50M;
architecture BEHAVOR of MMCME2_50M is
	signal 		clk_in1_buf : std_logic;
	signal 		clk_in2_clk_wiz : std_logic;


	signal      clk_out0 : std_logic;

	signal 		do_unused : std_logic_vector(15 downto 0); 
	signal      drdy_unused : std_logic;
	signal      psdone_unused : std_logic;
	signal      locked_int : std_logic;
	signal      clkfbout : std_logic;
	signal      clkfbout_buf : std_logic;
	signal      clkfboutb_unused : std_logic;
	signal 		clkout0b_unused : std_logic; 
	signal 		clkout1_unused : std_logic;
	signal 		clkout1b_unused : std_logic;
	signal 		clkout2_unused : std_logic;
	signal 		clkout2b_unused : std_logic;
	signal 		clkout3_unused : std_logic;
	signal 		clkout3b_unused : std_logic;
	signal 		clkout4_unused : std_logic;
	signal      clkout5_unused : std_logic;
	signal      clkout6_unused : std_logic;
	signal      clkfbstopped_unused : std_logic;
	signal      clkinstopped_unused : std_logic;
	signal      reset_high : std_logic;

	--! fb clock for mmcme2 input
	signal clk_fb_n 	:	std_logic;
begin

	--! 输入时钟经过�?次buf
	U_CLK_IN1 : IBUF
	port map(
				O => clk_in1_buf,
				I =>  Clk_in
			);

	U_MMCME_KALO : MMCME2_ADV
	generic map
	(
		BANDWIDTH            =>	"OPTIMIZED",
		CLKOUT4_CASCADE      =>	FALSE,
		COMPENSATION         => "ZHOLD",
		STARTUP_WAIT         => FALSE,
		DIVCLK_DIVIDE        => 1,
		CLKFBOUT_MULT_F      => 7.000,
		CLKFBOUT_PHASE       => 0.000,
		CLKFBOUT_USE_FINE_PS => FALSE,
		CLKOUT0_DIVIDE_F     => 14.000,
		CLKOUT0_PHASE        => 0.000,
		CLKOUT0_DUTY_CYCLE   => 0.500,
		CLKOUT0_USE_FINE_PS  => FALSE,
		CLKIN1_PERIOD        => 10.000
	)
	port map
	(
	-- Output clocks
		CLKFBOUT            =>	clkfbout,
		CLKFBOUTB           =>	clkfboutb_unused,
		CLKOUT0             =>	clk_out0,
		CLKOUT0B            =>	clkout0b_unused,
		CLKOUT1             =>	clkout1_unused,
		CLKOUT1B            =>	clkout1b_unused,
		CLKOUT2             =>	clkout2_unused,
		CLKOUT2B            =>	clkout2b_unused,
		CLKOUT3             =>	clkout3_unused,
		CLKOUT3B            =>	clkout3b_unused,
		CLKOUT4             =>	clkout4_unused,
		CLKOUT5             =>	clkout5_unused,
		CLKOUT6             =>	clkout6_unused,
	-- Input clock control
		CLKFBIN             =>	clkfbout_buf,	--! 这里�?要�?�究
		CLKIN1              =>	clk_in1_buf,
		CLKIN2              =>	'0',
	-- Tied to always select the primary input clock
		CLKINSEL            => 	'1',
	--Ports for dynamic reconfiguration
		DADDR              	=> (others => '0'),
		DCLK               	=> '0',
		DEN               	=> '0',
		DI                	=> (others => '0'),
		DO                 	=> do_unused,
		DRDY               	=> drdy_unused,
		DWE                	=> '0',
	--Ports for dynamic phase shift
		PSCLK              	=> '0',
		PSEN               	=> '0',
		PSINCDEC          	=> '0',
		PSDONE              =>	psdone_unused,
	-- Other control and status signals
		LOCKED              =>	locked_int,
		CLKINSTOPPED        =>	clkinstopped_unused,
		CLKFBSTOPPED        =>	clkfbstopped_unused,
		PWRDWN              =>	'0',
		RST                 =>	reset_high
	);


	reset_high <= not Rst_n; 
	locked <= locked_int;
	clk_fb_n <= not clk_in1_buf;
  --------------------------------------
  -- Output buffering
  -----------------------------------
	U_CLKF_BUF : BUFG
	port map(
				O =>	clkfbout_buf,
				I =>	clkfbout
			);

	U_CLKOUT_BUF : BUFG 
	port map(
				O   =>Clk_out,
				I   =>clk_out0

			);

end BEHAVOR;
