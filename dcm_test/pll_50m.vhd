
library IEEE;
Library UNISIM;
use IEEE.std_logic_1164.all;
use UNISIM.vcomponents.all;

entity PLL_50M is
	port(
			Clk_in	:	in	std_logic;	
			Rst_n:	in	std_logic;
			locked	:	out	std_logic;
			Clk_out	:	out	std_logic
		);
end PLL_50M;
architecture BEHAVOR of PLL_50M is
	signal clkfbout : std_logic;
	signal clkfbout_buf : std_logic;
	signal clk_in1_buf : std_logic;
	signal clkout0 : std_logic;
	signal reset_high : std_logic;
begin
	reset_high <= not Rst_n;



	-- !    
	-- !    F0out = Fin *  CLKFBOUT_MULT_F / CLKOUT0_DIVIDE / DIVCLK_DIVIDE
	-- !    
	-- !    
	U_PLLE2 : PLLE2_BASE
	generic map (
					BANDWIDTH => "OPTIMIZED",  -- OPTIMIZED, HIGH, LOW
					CLKFBOUT_MULT => 8,        -- Multiply value for all CLKOUT, (2-64)
					CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB, (-360.000-360.000).
					CLKIN1_PERIOD => 0.0,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
											   -- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
					CLKOUT0_DIVIDE => 16,
					CLKOUT1_DIVIDE => 1,
					CLKOUT2_DIVIDE => 1,
					CLKOUT3_DIVIDE => 1,
					CLKOUT4_DIVIDE => 1,
					CLKOUT5_DIVIDE => 1,
	  				-- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
					CLKOUT0_DUTY_CYCLE => 0.5,
					CLKOUT1_DUTY_CYCLE => 0.5,
					CLKOUT2_DUTY_CYCLE => 0.5,
					CLKOUT3_DUTY_CYCLE => 0.5,
					CLKOUT4_DUTY_CYCLE => 0.5,
					CLKOUT5_DUTY_CYCLE => 0.5,
	  				-- CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
					CLKOUT0_PHASE => 0.0,
					CLKOUT1_PHASE => 0.0,
					CLKOUT2_PHASE => 0.0,
					CLKOUT3_PHASE => 0.0,
					CLKOUT4_PHASE => 0.0,
					CLKOUT5_PHASE => 0.0,
					DIVCLK_DIVIDE => 1,        -- Master division value, (1-56)
					REF_JITTER1 => 0.0,        -- Reference input jitter in UI, (0.000-0.999).
					STARTUP_WAIT => "FALSE"    -- Delay DONE until PLL Locks, ("TRUE"/"FALSE")
				)
	port map (
	  			 -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
				 CLKOUT0 	=> clkout0,   -- 1-bit output: CLKOUT0

	  			 -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
				 CLKFBOUT 	=> clkfbout, -- 1-bit output: Feedback clock
				 LOCKED 	=> locked,     -- 1-bit output: LOCK
				 CLKIN1 	=> clk_in1_buf,     -- 1-bit input: Input clock
											-- Control Ports: 1-bit (each) input: PLL control ports
				 PWRDWN 	=> '0',     -- 1-bit input: Power-down
				 RST 		=> reset_high,           -- 1-bit input: Reset
											  -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
				 CLKFBIN 	=> clkfbout_buf -- 1-bit input: Feedback clock
			 );


	--! 输入时钟经过一次buf
	U_CLK_IN1 : IBUF
	port map(
				O => clk_in1_buf,
				I =>  Clk_in
			);

	U_CLKF_BUF : BUFG
	port map(
				O =>	clkfbout_buf,
				I =>	clkfbout
			);

	U_CLKOUT_BUF : BUFG 
	port map(
				O   =>Clk_out,
				I   =>clkout0

			);
end BEHAVOR;
