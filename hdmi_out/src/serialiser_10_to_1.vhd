-----------------------------------------------------------------------------
--! 	@file		serialiser_1_10.vhd
--! 	@function	并转串
--!		@version	

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

library UNISIM;
use UNISIM.VComponents.all;

entity SERIALISER_10_TO_1 is
	port ( 
			 Clk_x1    	: in std_logic;
			 Clk_x5 	: in std_logic;
			 Data   	: in std_logic_vector (9 downto 0);
			 Rst  		: in std_logic;
			 Serial 	: out std_logic
		 );
end SERIALISER_10_TO_1;

architecture Behavioral of SERIALISER_10_TO_1 is
    signal shift1 : std_logic;
    signal shift2 : std_logic;
begin

	master_serdes : OSERDESE2
	generic map (
					DATA_RATE_OQ => "DDR",   -- DDR, SDR
					DATA_RATE_TQ => "DDR",   -- DDR, BUF, SDR
					DATA_WIDTH => 10,         -- Parallel data width (2-8,10,14)
					INIT_OQ => '1',          -- Initial value of OQ output (1'b0,1'b1)
					INIT_TQ => '1',          -- Initial value of TQ output (1'b0,1'b1)
					SERDES_MODE => "MASTER", -- MASTER, SLAVE
					SRVAL_OQ => '0',         -- OQ output value when SR is used (1'b0,1'b1)
					SRVAL_TQ => '0',         -- TQ output value when SR is used (1'b0,1'b1)
					TBYTE_CTL => "FALSE",    -- Enable tristate byte operation (FALSE, TRUE)
					TBYTE_SRC => "FALSE",    -- Tristate byte source (FALSE, TRUE)
					TRISTATE_WIDTH => 1      -- 3-state converter width (1,4)
				)
	port map (
				 OFB       => open,             -- 1-bit output: Feedback path for data
				 OQ        => Serial,               -- 1-bit output: Data path output
													-- SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
				 SHIFTOUT1 => open,
				 SHIFTOUT2 => open,
				 TBYTEOUT  => open,   -- 1-bit output: Byte group tristate
				 TFB       => open,             -- 1-bit output: 3-state control
				 TQ        => open,               -- 1-bit output: 3-state control
				 CLK       => Clk_x5,             -- 1-bit input: High speed clock
				 CLKDIV    => Clk_x1,       -- 1-bit input: Divided clock
										 -- D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
				 D1 => Data(0),
				 D2 => Data(1),
				 D3 => Data(2),
				 D4 => Data(3),
				 D5 => Data(4),
				 D6 => Data(5),
				 D7 => Data(6),
				 D8 => Data(7),
				 OCE => '1', --ce_delay(0),             -- 1-bit input: Output data clock enable
				 RST => Rst,             -- 1-bit input: Reset
										   -- SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
				 SHIFTIN1 => SHIFT1,
				 SHIFTIN2 => SHIFT2,
	  -- T1 - T4: 1-bit (each) input: Parallel 3-state inputs
				 T1 => '0',
				 T2 => '0',
				 T3 => '0',
				 T4 => '0',
				 TBYTEIN => '0', -- 1-bit input: Byte group tristate
				 TCE => '0'                  -- 1-bit input: 3-state clock enable
			 );

	slave_serdes : OSERDESE2
	generic map (
					DATA_RATE_OQ   => "DDR",   -- DDR, SDR
					DATA_RATE_TQ   => "DDR",   -- DDR, BUF, SDR
					DATA_WIDTH     => 10,      -- Parallel data width (2-8,10,14)
					INIT_OQ        => '1',     -- Initial value of OQ output (1'b0,1'b1)
					INIT_TQ        => '1',     -- Initial value of TQ output (1'b0,1'b1)
					SERDES_MODE    => "SLAVE", -- MASTER, SLAVE
					SRVAL_OQ       => '0',     -- OQ output value when SR is used (1'b0,1'b1)
					SRVAL_TQ       => '0',     -- TQ output value when SR is used (1'b0,1'b1)
					TBYTE_CTL      => "FALSE", -- Enable tristate byte operation (FALSE, TRUE)
					TBYTE_SRC      => "FALSE", -- Tristate byte source (FALSE, TRUE)
					TRISTATE_WIDTH => 1        -- 3-state converter width (1,4)
				)
	port map (
				 OFB       => open,         -- 1-bit output: Feedback path for data
				 OQ        => open,         -- 1-bit output: Data path output
											-- SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
				 SHIFTOUT1 => shift1,
				 SHIFTOUT2 => shift2,

				 TBYTEOUT  => open,    -- 1-bit output: Byte group tristate
				 TFB       => open,    -- 1-bit output: 3-state control
				 TQ        => open,    -- 1-bit output: 3-state control
				 CLK       => Clk_x5,  -- 1-bit input: High speed clock
				 CLKDIV    => Clk_x1,     -- 1-bit input: Divided clock
									   -- D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
				 D1       => '0',
				 D2       => '0',
				 D3       => Data(8),
				 D4       => Data(9),
				 D5       => '0',
				 D6       => '0',
				 D7       => '0',
				 D8       => '0',
				 OCE      => '1', --ce_delay(0),     -- 1-bit input: Output data clock enable
				 RST      => Rst,     -- 1-bit input: Reset
										-- SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
				 SHIFTIN1 => '0',
				 SHIFTIN2 => '0',
	  -- T1 - T4: 1-bit (each) input: Parallel 3-state inputs
				 T1       => '0',
				 T2       => '0',
				 T3       => '0',
				 T4       => '0',
				 TBYTEIN  => '0',     -- 1-bit input: Byte group tristate
				 TCE      => '0'      -- 1-bit input: 3-state clock enable
			 );
end Behavioral;
