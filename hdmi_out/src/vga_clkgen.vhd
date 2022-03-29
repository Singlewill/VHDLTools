-----------------------------------------------------------------------------
--! 	@file		vga_clkgen.vhd
--! 	@function	产生vga时钟
--!		@version	
-----------------------------------------------------------------------------
--!		Clk_o	= 150 M 	Clk_high_o = 150*5M
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

library UNISIM;
use UNISIM.VComponents.all;

entity VGA_CLKGEN is
	port	(
				Clk_in		:	in	std_logic;
				Clk_raw_o		:	out	std_logic;
				Clk_x1_o		:	out	std_logic;
				Clk_x5_o	:	out std_logic;
				Locked		:	out	std_logic
			);
end VGA_CLKGEN;


architecture BEHAVOR of VGA_CLKGEN is

	signal clk_pixel_fb	: std_logic;
	signal clk_pixel_locked	:	std_logic;

	signal clk_pixel_raw_unbuf : std_logic;
	signal clk_pixel_raw_bufg 	: std_logic;
	signal clk_pixel_x5_unbuf : std_logic;
	signal clk_pixel_x5_bufio : std_logic;
	signal clk_pixel_x1_unbuf: std_logic;
	signal clk_pixel_x1_bufg: std_logic;


begin
	Locked <= not clk_pixel_locked;

	U_MMCM_HDMI_CLK : MMCME2_BASE
	generic map (
				--! 注意这里的数都有范围限定
				BANDWIDTH 			=> "OPTIMIZED",		-- Jitter programming (OPTIMIZED, HIGH, LOW)
				DIVCLK_DIVIDE   	=> 1,          		-- Master division value (1-106)
				CLKFBOUT_MULT_F 	=> 7.5,        		-- Multiply value for all CLKOUT (2.000-64.000).
				CLKFBOUT_PHASE 		=> 0.0,         		-- Phase offset in degrees of CLKFB (-360.000-360.000).
				--! 重点:CLKIN1_PERIOD这里是无所谓的
				--! 外面的约束文件对HDMI时钟的约束会覆盖这条
				CLKIN1_PERIOD 		=> 10.0, 				-- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
				CLKOUT0_DIVIDE_F 	=> 2.0,       		-- Divide amount for CLKOUT0 (1.000-128.000)
				CLKOUT1_DIVIDE   	=> 10,
				CLKOUT2_DIVIDE   	=> 10,
				CLKOUT3_DIVIDE   	=> 1,
				CLKOUT4_DIVIDE   	=> 1,
				CLKOUT5_DIVIDE   	=> 1,
				CLKOUT6_DIVIDE   	=> 1,
				-- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
				CLKOUT0_DUTY_CYCLE 	=> 0.5,
				CLKOUT1_DUTY_CYCLE 	=> 0.5,
				CLKOUT2_DUTY_CYCLE 	=> 0.5,
				CLKOUT3_DUTY_CYCLE 	=> 0.5,
				CLKOUT4_DUTY_CYCLE 	=> 0.5,
				CLKOUT5_DUTY_CYCLE 	=> 0.5,
				CLKOUT6_DUTY_CYCLE 	=> 0.5,
				-- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
				CLKOUT0_PHASE 		=> 0.0,
				CLKOUT1_PHASE 		=> 0.0,
				CLKOUT2_PHASE 		=> 0.0,
				CLKOUT3_PHASE 		=> 0.0,
				CLKOUT4_PHASE 		=> 0.0,
				CLKOUT5_PHASE 		=> 0.0,
				CLKOUT6_PHASE 		=> 0.0,
				CLKOUT4_CASCADE 	=> FALSE,  			-- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
				REF_JITTER1 		=> 0.0,        		-- Reference input jitter in UI (0.000-0.999).
				STARTUP_WAIT 		=> FALSE      		-- Delays DONE until MMCM is locked (FALSE, TRUE)
				)
	port map (
				 -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
				 CLKOUT0   			=> clk_pixel_x5_unbuf,   	-- 1-bit output: CLKOUT0
				 CLKOUT0B  			=> open,         		-- 1-bit output: Inverted CLKOUT0
				 CLKOUT1   			=> clk_pixel_raw_unbuf, 	-- 1-bit output: CLKOUT1
				 CLKOUT1B  			=> open,         		-- 1-bit output: Inverted CLKOUT1
				 CLKOUT2   			=> clk_pixel_x1_unbuf, 				-- 1-bit output: CLKOUT2
				 CLKOUT2B  			=> open,         	-- 1-bit output: Inverted CLKOUT2
				 CLKOUT3   			=> open,         	-- 1-bit output: CLKOUT3
				 CLKOUT3B  			=> open,         	-- 1-bit output: Inverted CLKOUT3
				 CLKOUT4   			=> open,         	-- 1-bit output: CLKOUT4
				 CLKOUT5   			=> open,         	-- 1-bit output: CLKOUT5
				 CLKOUT6   			=> open,         	-- 1-bit output: CLKOUT6
				 -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
				 CLKFBOUT  			=> clk_pixel_fb,       -- 1-bit output: Feedback clock
				 CLKFBOUTB 			=> open,          -- 1-bit output: Inverted CLKFBOUT
				 -- Status Ports: 1-bit (each) output: MMCM status ports
				 LOCKED    			=> clk_pixel_locked,        -- 1-bit output: LOCK
				 -- Clock Inputs: 1-bit (each) input: Clock input
				 CLKIN1    			=> Clk_in, 	-- 1-bit input: Clock
				 -- Control Ports: 1-bit (each) input: MMCM control ports
				 PWRDWN    			=> '0',           	-- 1-bit input: Power-down
				 RST       			=> '0',           	-- 1-bit input: Reset
				 -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
				 CLKFBIN   			=> clk_pixel_fb		-- 1-bit input: Feedback clock
			 );

	U_BUFG_CLK : BUFG
	PORT MAP (
		  		I => clk_pixel_raw_unbuf,
				O => clk_pixel_raw_bufg 
			  );

	U_BUFIO_CKL_X5 : BUFIO
	port map(
				I => clk_pixel_x5_unbuf,	
				O => clk_pixel_x5_bufio
			);

	U_BUFG_CLK_X1 : BUFG
	PORT MAP (
		  		I => clk_pixel_x1_unbuf,
				O => clk_pixel_x1_bufg
			  );

	Clk_x5_o <= clk_pixel_x5_bufio;
	Clk_x1_o <= clk_pixel_x1_bufg;
	Clk_raw_o	<= clk_pixel_raw_bufg;
end BEHAVOR;

