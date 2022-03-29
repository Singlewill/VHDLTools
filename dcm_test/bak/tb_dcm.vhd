library  IEEE;
use IEEE.std_logic_1164.all;


Library UNISIM;
use UNISIM.vcomponents.all;
entity TB_MMCME2 is
end TB_MMCME2;
architecture BEVAVOR of TB_MMCME2 is
component clk_wiz_clk_wiz
port
 (-- Clock in ports
  -- Clock out ports
  clk_out1          : out    std_logic;
  -- Status and control signals
  reset             : in     std_logic;
  locked            : out    std_logic;
  clk_in1           : in     std_logic
 );
end component;

component 	MMCME2_50
port 
(		
				Clk_in1	:	in	std_logic;	
				reset	:	in	std_logic;
				locked	:	out	std_logic;
				Clk_out1	:	out	std_logic
);
end component;
	signal rst : std_logic;
	signal locked : std_logic;
	--! 时钟输入
	--signal clk_n : std_logic;
	signal clk	:	std_logic;
	signal clkf	:	std_logic;
	signal clkout1 : std_logic;
	signal outlast	:	std_logic;
	signal clkfbin2	:	std_logic;
	signal clkfbout	:	std_logic;
	signal clkfboutb	:	std_logic;
	
	signal do : std_logic_vector(15 downto 0) := (others => '0');
	signal DRDY : std_logic := '0';
	signal di  : std_logic_vector(15 downto 0) := (others => '0');
	
	signal DADDR  : std_logic_vector(6 downto 0) := (others => '0');
	signal PSDONE : std_logic := '0'; 
--	signal PSDONE : std_logic;
	
begin
    --clk_n <= not clkfbin2;
	-- !    
	-- !    F0out = Fin *  CLKFBOUT_MULT_F / CLKOUT0_DIVIDE / DIVCLK_DIVIDE
	-- !    
	-- !    

--	U_MMCME2_BASE : MMCME2_ADV
--	   generic map (
--       BANDWIDTH => "OPTIMIZED",      -- Jitter programming (OPTIMIZED, HIGH, LOW)
--       CLKOUT4_CASCADE    => FALSE,
--       COMPENSATION        => "ZHOLD",
--       STARTUP_WAIT         => FALSE,
--      DIVCLK_DIVIDE        => 1,
--       CLKFBOUT_MULT_F    => 10.00,
--       CLKFBOUT_PHASE     => 00.00,
--       CLKFBOUT_USE_FINE_PS => FALSE,
--       CLKOUT0_DIVIDE_F     => 20.000,
--       CLKOUT0_PHASE   => 0.000,
--       CLKOUT0_DUTY_CYCLE   => 0.500,
--      CLKOUT0_USE_FINE_PS  => FALSE,
--       CLKIN1_PERIOD          => 10.000,
--        REF_JITTER1 => 0.01, 
--        REF_JITTER2 => 0.01
--    )
--    port map (
--       -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
--       CLKOUT0 => clkout1,           -- 1-bit output: CLKOUT0
--       CLKFBOUT => CLKFBOUT,         -- 1-bit output: Feedback clock
--       CLKFBOUTB => CLKFBOUTB,       -- 1-bit output: Inverted CLKFBOUT
--        CLKFBIN => CLKFBIN2,            -- 1-bit input: Feedback clock
        
--        CLKIN1 => clkf,             -- 1-bit input: Primary clock
--        CLKIN2 => '0',             -- 1-bit input: Secondary clock
--       CLKINSEL => '1',         -- 1-bit input: Clock select, High=CLKIN1 Low=CLKIN2
        
--      -- DRP Ports: 7-bit (each) input: Dynamic reconfiguration ports
--       DADDR => "0000000",               -- 7-bit input: DRP address
--       DCLK => '0',                 -- 1-bit input: DRP clock
--       DEN => '0',                   -- 1-bit input: DRP enable
--       DI => "0000000000000000",                     -- 16-bit input: DRP data
--       DWE => '0',                   -- 1-bit input: DRP write enable
--       -- DRP Ports: 16-bit (each) output: Dynamic reconfiguration ports
--     --  DO => do,                     -- 16-bit output: DRP data
--       DRDY => DRDY,                 -- 1-bit output: DRP ready
--       -- Dynamic Phase Shift Ports: 1-bit (each) output: Ports used for dynamic phase shifting of the outputs
--       -- Dynamic Phase Shift Ports: 1-bit (each) input: Ports used for dynamic phase shifting of the outputs
--       PSCLK => '0',               -- 1-bit input: Phase shift clock
--       PSEN => '0',                 -- 1-bit input: Phase shift enable
--       PSINCDEC => '0',         -- 1-bit input: Phase shift increment/decrement
--       PSDONE => PSDONE,             -- 1-bit output: Phase shift done
--       -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
       
       
--       -- Status Ports: 1-bit (each) output: MMCM status ports
----       CLKFBSTOPPED => CLKFBSTOPPED, -- 1-bit output: Feedback clock stopped
----       CLKINSTOPPED => CLKINSTOPPED, -- 1-bit output: Input clock stopped
--       LOCKED => LOCKED,             -- 1-bit output: LOCK
--       -- Clock Inputs: 1-bit (each) input: Clock inputs

--       -- Control Ports: 1-bit (each) input: MMCM control ports
  
--       PWRDWN => '0',             -- 1-bit input: Power-down
--       RST => RST                  -- 1-bit input: Reset


--       -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
       
--    );

--    U_MMCME2_BASE : MMCME2_BASE
--	generic map (
--					BANDWIDTH => "OPTIMIZED",  -- Jitter programming (OPTIMIZED, HIGH, LOW)
--					CLKFBOUT_MULT_F => 2.0,    -- Multiply value for all CLKOUT (2.000-64.000).
--					CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB (-360.000-360.000).
--					CLKIN1_PERIOD => 10.0,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
--												-- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
--					CLKOUT0_DIVIDE_F  => 8.0,
--					CLKOUT0_DUTY_CYCLE => 0.5,
--					CLKOUT0_PHASE => 0.0,
--					DIVCLK_DIVIDE => 1        -- Master division value (1-106)
----					REF_JITTER1 => 0.0,        -- Reference input jitter in UI (0.000-0.999).
----					CLKOUT4_CASCADE => FALSE,  -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
----					STARTUP_WAIT => FALSE      -- Delays DONE until MMCM is locked (FALSE, TRUE)
--				)
--	port map (
--				 CLKIN1 => clkf,       -- input clk
--				 CLKFBIN => clkfbin2,
--				 PWRDWN => '0',
--				 RST => rst,        

--				 CLKFBOUT => clkfbout,   -- 1-bit output: Feedback clock
--				 CLKFBOUTB => clkfboutb,   -- 1-bit output: Feedback clock
--				 CLKOUT0 => clkout1,     -- 1-bit output: CLKOUT1
--				 LOCKED => locked		-- 0 --> 1


--			 );

--  PLLE2_BASE_inst : PLLE2_BASE
--   generic map (
--      BANDWIDTH => "OPTIMIZED",  -- OPTIMIZED, HIGH, LOW
--      CLKFBOUT_MULT => 5,        -- Multiply value for all CLKOUT, (2-64)
--      CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB, (-360.000-360.000).
--      CLKIN1_PERIOD => 0.0,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
--      -- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
--      CLKOUT0_DIVIDE => 1,
--      CLKOUT1_DIVIDE => 1,
--      CLKOUT2_DIVIDE => 1,
--      CLKOUT3_DIVIDE => 1,
--      CLKOUT4_DIVIDE => 1,
--      CLKOUT5_DIVIDE => 1,
--      -- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
--      CLKOUT0_DUTY_CYCLE => 0.5,
--      CLKOUT1_DUTY_CYCLE => 0.5,
--      CLKOUT2_DUTY_CYCLE => 0.5,
--      CLKOUT3_DUTY_CYCLE => 0.5,
--      CLKOUT4_DUTY_CYCLE => 0.5,
--      CLKOUT5_DUTY_CYCLE => 0.5,
--      -- CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
--      CLKOUT0_PHASE => 0.0,
--      CLKOUT1_PHASE => 0.0,
--      CLKOUT2_PHASE => 0.0,
--      CLKOUT3_PHASE => 0.0,
--      CLKOUT4_PHASE => 0.0,
--      CLKOUT5_PHASE => 0.0,
--      DIVCLK_DIVIDE => 1,        -- Master division value, (1-56)
--      REF_JITTER1 => 0.0,        -- Reference input jitter in UI, (0.000-0.999).
--      STARTUP_WAIT => "FALSE"    -- Delay DONE until PLL Locks, ("TRUE"/"FALSE")
--   )
--   port map (
--      -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
--      CLKOUT0 => clkout1,   -- 1-bit output: CLKOUT0
 
--      -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
--      CLKFBOUT => clkfbout, -- 1-bit output: Feedback clock
--      LOCKED => LOCKED,     -- 1-bit output: LOCK
--      CLKIN1 => clk,     -- 1-bit input: Input clock
--      -- Control Ports: 1-bit (each) input: PLL control ports
--      PWRDWN => '0',     -- 1-bit input: Power-down
--      RST => RST,           -- 1-bit input: Reset
--      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
--      CLKFBIN => clkfbin2    -- 1-bit input: Feedback clock
--   );

  U_BUFG : BUFG
  port map(
    I => CLKFBOUT,
    O => clkfbin2
  );

--  U_BUFG3 : BUFG
--  port map(
--    I => clkout1,
--    O =>outlast
--  );
    U_BUFG2 : IBUF
  port map(
    I => clk,
    O => clkf
  );




	U_CLK : process
	begin
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
		wait for 5 ns;
	end process;

	U_RST: process
	begin
		rst <= '1';
		wait for 100 ns;
		rst <= '0';
		wait;
	end process;
	
	your_instance_name : MMCME2_50
       port map ( 
				Clk_in1	=> clk,
				reset	=> rst,
				locked		=> locked,
				Clk_out1	=> clkout1
     );
     --   U_CLK_WIZ : clk_wiz_clk_wiz
     --   port map(
      --      clk_in1 => clk,
       --      reset => rst,
        --     locked => locked,
         --    clk_out1 => clkout1
        --);
end BEVAVOR;
