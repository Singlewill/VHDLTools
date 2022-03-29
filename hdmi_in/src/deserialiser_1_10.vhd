-----------------------------------------------------------------------------
--! 	@file		deserialiser_1_10.vhd
--! 	@function	解串器
--!		@version	
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

library UNISIM;
use UNISIM.VComponents.all;

entity DESERIALISER_1_10 is
	port (
				Clk			:	in	std_logic;				
				Rst_n		:	in	std_logic;
				Clk_high	:	in	std_logic;
				Data_in		:	in	std_logic;
				Data_out	:	out	std_logic_vector(9 downto 0);
				--! 用于ISERDESE2模块，调整输出顺序
				Bitslip		:	in	std_logic;

				--! Delay_*, 用于调整IDELAY2延迟大小
				Delay_ce	:	in	std_logic;
				Delay_cnt	:	in	std_logic_vector(4 downto 0)
			);
end DESERIALISER_1_10;


architecture BEHAVOR of DESERIALISER_1_10 is
	signal 		delayed 		: std_logic;
	signal 		shift1  		: std_logic;
	signal 		shift2  		: std_logic;
	signal 		clkb    		: std_logic;
	attribute 	IODELAY_GROUP 	: STRING;
	attribute 	IODELAY_GROUP of U_IDELAY2: label is "idelay_group";

begin

	U_IDELAY2 : IDELAYE2
    generic map (
          CINVCTRL_SEL          => "FALSE",
          DELAY_SRC             => "DATAIN",
          HIGH_PERFORMANCE_MODE => "TRUE",
          IDELAY_TYPE           => "VAR_LOAD",
          IDELAY_VALUE          => 0,
          PIPE_SEL              => "FALSE",
          REFCLK_FREQUENCY      => 200.0,
          SIGNAL_PATTERN        => "DATA"
    )
    port map (
          DATAIN      => Data_in,
          IDATAIN     => '0',
          DATAOUT     => delayed,
          CNTVALUEOUT => open,
          C           => Clk,
          CE          => Delay_ce,
          CINVCTRL    => '0',
          CNTVALUEIN  => Delay_cnt,
          INC         => '0',
          LD          => '1',
          LDPIPEEN    => '0',
          REGRST      => '0'
    );
    clkb <= not Clk_high;

ISERDESE2_master : ISERDESE2
   generic map (
      DATA_RATE         => "DDR",
      DATA_WIDTH        => 10,
      DYN_CLKDIV_INV_EN => "FALSE",
      DYN_CLK_INV_EN    => "FALSE",
      INIT_Q1 => '0', INIT_Q2 => '0', INIT_Q3 => '0', INIT_Q4 => '0',
      INTERFACE_TYPE    => "NETWORKING",
      IOBDELAY          => "IFD",
      NUM_CE            => 1,
      OFB_USED          => "FALSE",
      SERDES_MODE       => "MASTER",
      SRVAL_Q1 => '0', SRVAL_Q2 => '0', SRVAL_Q3 => '0', SRVAL_Q4 => '0' 
   )
   port map (
      O => open,
      Q1 => Data_out(9), Q2 => Data_out(8), Q3 => Data_out(7), Q4 => Data_out(6),
      Q5 => Data_out(5), Q6 => Data_out(4), Q7 => Data_out(3), Q8 => Data_out(2),
      SHIFTOUT1 => shift1, SHIFTOUT2 => shift2,
      BITSLIP   => Bitslip,
      CE1 => '1', CE2 => '1',
      CLKDIVP      => '0',
      CLK          => Clk_high,
      CLKB         => clkb,
      CLKDIV       => Clk,
      OCLK         => '0', 
      DYNCLKDIVSEL => '0',
      DYNCLKSEL    => '0',
      D            => '0',
      DDLY         => delayed,
      OFB          => '0',
      OCLKB        => '0',
      RST          => Rst_n,
      SHIFTIN1     => '0',
      SHIFTIN2     => '0' 
   );
               
ISERDESE2_slave : ISERDESE2
   generic map (
      DATA_RATE         => "DDR",
      DATA_WIDTH        => 10,
      DYN_CLKDIV_INV_EN => "FALSE",
      DYN_CLK_INV_EN    => "FALSE",
      INIT_Q1 => '0', INIT_Q2 => '0', INIT_Q3 => '0', INIT_Q4 => '0',
      INTERFACE_TYPE    => "NETWORKING",
      IOBDELAY          => "IFD",
      NUM_CE            => 1,
      OFB_USED          => "FALSE",
      SERDES_MODE       => "SLAVE",  
      SRVAL_Q1 => '0', SRVAL_Q2 => '0', SRVAL_Q3 => '0', SRVAL_Q4 => '0' 
   )
   port map (
      O => open,
      Q1 => open, Q2 => open, Q3 => Data_out(1), Q4 => Data_out(0),
      Q5 => open, Q6 => open, Q7 => open,    Q8 => open,
      SHIFTOUT1 => open, SHIFTOUT2 => open,
      BITSLIP   => bitslip,
      CE1 => '1', CE2 => '1',
      CLKDIVP      => '0',
      CLK          => Clk_high,
      CLKB         => clkb,
      CLKDIV       => Clk,
      OCLK         => '0', 
      DYNCLKDIVSEL => '0',
      DYNCLKSEL    => '0',
      D            => '0',
      DDLY         => '0',
      OFB          => '0',
      OCLKB        => '0',
      RST          => Rst_n,
      SHIFTIN1     => shift1,
      SHIFTIN2     => shift2 
   );

end BEHAVOR;
