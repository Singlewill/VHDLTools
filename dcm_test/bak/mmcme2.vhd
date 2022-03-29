library IEEE;
use IEEE.std_logic_1164.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity MMCME2 is
	port(
				Clk	:	in	std_logic;	
				Rst	:	in	std_logic;
				Locked	:	out	std_logic;
				Clk_out	:	out	std_logic
			);
end MMCME2;
architecture BEHAVOR of MMCME2 is
    signal clk_n    :   std_logic;
	signal clk_buf	:	std_logic;
	signal rst_high : std_logic;

	signal        clk_out1_clk_wiz : std_logic;
	signal        clk_out2_clk_wiz : std_logic;
	signal        clk_out3_clk_wiz : std_logic;
	signal        clk_out4_clk_wiz : std_logic;
	signal        clk_out5_clk_wiz : std_logic;
	signal        clk_out6_clk_wiz : std_logic ;
	signal        clk_out7_clk_wiz : std_logic;

	signal         do_unused : std_logic_vector(15 downto 0);
	signal        drdy_unused : std_logic;
	signal        psdone_unused : std_logic;
	signal        locked_int : std_logic;
	signal        clkfbout_clk_wiz : std_logic;
	signal        clkfbout_buf_clk_wiz : std_logic;
	signal        clkfboutb_unused : std_logic;
	signal clkout0b_unused : std_logic;
	signal clkout1_unused : std_logic;
	signal clkout1b_unused : std_logic;
	signal clkout2_unused : std_logic;
	signal clkout2b_unused : std_logic;
	signal clkout3_unused : std_logic;
	signal clkout3b_unused : std_logic;
	signal clkout4_unused : std_logic;
	signal        clkout5_unused : std_logic;
	signal        clkout6_unused : std_logic;
	signal        clkfbstopped_unused : std_logic;
	signal        clkinstopped_unused : std_logic;
	signal        reset_high : std_logic;
begin
    clk_n <= not clk_buf;
	rst_high <= RST;
	U_CLKBUF : IBUF
	port map(
				O =>	clk_buf,	
				I =>	Clk
			);
  U_CLKBOUT :BUFG
  port map(
  			O => clkfbout_buf_clk_wiz,
			I => clkfbout_clk_wiz
		  );
  U_CLKOUT : BUFG
  port map(
		  	O => Clk_out,
			I => clk_out1_clk_wiz
		  );



	U_MMCME2_ADV : MMCME2_ADV
	generic map(
				BANDWIDTH            => "OPTIMIZED",
				CLKOUT4_CASCADE      => FALSE,
				COMPENSATION         => "ZHOLD",
				STARTUP_WAIT         => FALSE,
				DIVCLK_DIVIDE        => 1,
				CLKFBOUT_MULT_F      => 10.000,
				CLKFBOUT_PHASE       => 0.000,
				CLKFBOUT_USE_FINE_PS => FALSE,
				CLKOUT0_DIVIDE_F     => 20.000,
				CLKOUT0_PHASE        => 0.000,
				CLKOUT0_DUTY_CYCLE   => 0.500,
				CLKOUT0_USE_FINE_PS  => FALSE,
				CLKIN1_PERIOD        => 10.000
				--REF_JITTER1 => 0.0,
				--REF_JITTER2 => 0.0
			  )
	port map(
				--Output clocks
				CLKFBOUT            => clkfbout_clk_wiz,
				CLKFBOUTB           => clkfboutb_unused,
				CLKOUT0             => clk_out1_clk_wiz,
				CLKOUT0B            => clkout0b_unused,
				CLKOUT1             => clkout1_unused,
				CLKOUT1B            => clkout1b_unused,
				CLKOUT2             => clkout2_unused,
				CLKOUT2B            => clkout2b_unused,
				CLKOUT3             => clkout3_unused,
				CLKOUT3B            => clkout3b_unused,
				CLKOUT4             => clkout4_unused,
				CLKOUT5             => clkout5_unused,
				CLKOUT6             => clkout6_unused,

				-- Input clock control
				CLKFBIN             => clkfbout_buf_clk_wiz,
				--CLKFBIN             => clk_n,
				CLKIN1              => clk_buf,
				CLKIN2              => '0',
				-- Tied to always select the primary input clock
				CLKINSEL           => '1',
				-- Ports for dynamic reconfiguration
				DADDR             	=> (others => '0'),
				DCLK               => '0',
				DEN                => '0',
				DI                 => (others => '0'),
				DO                 => do_unused,
				DRDY               => drdy_unused,
				DWE                => '0',
				--Ports for dynamic phase shift
				PSCLK              => '0',
				PSEN               => '0',
				PSINCDEC          => '0',
				PSDONE             => psdone_unused,
				-- Other control and status signals
				LOCKED              => locked_int,
				CLKINSTOPPED        => clkinstopped_unused,
				CLKFBSTOPPED        => clkfbstopped_unused,
				PWRDWN              => '0',
				RST                 => rst_high
			);


end BEHAVOR;
