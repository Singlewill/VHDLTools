-----------------------------------------------------------------------------
--! 	@file		counter_48bit.vhd
--! 	@function	DSP48E1的第一类应用: 逻辑运算
--!					应用2 : 48bit计数器
--!					1, DSP48E1端口C : Load值,端口A:B : 步进值
--!					2, Load = 1时,OPMODE="011 00 11", Z=C, Y=0, X=A:B
--!					   Load = 0时,OPMODE="010 00 11", Z=P, Y=0, X=A:B
--!					4, Mode = 1,向上计算,ALUMODE="0000", Z+(X+Y+Cin),即Z+X
--!					   Mode = 0,向下计算,ALUMODE="0011", Z-(X+Y+Cin),即Z-X
--! 				5, Load_en,Mode改变后的第三个周期才能捕获到改变后的值
--! 				6, 假如Load_data = 0, PARTDATA = 100,则cnt范围[1 : 100]
--! 				   同时Load_data = 100, PARTDATA = 1, 则cnt范围[99, 1]
--!		@version	
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


Library UNISIM;
use UNISIM.vcomponents.all;


entity COUNTER_48BIT is
	generic (
				PARTDATA 	: std_logic_vector(47 downto 0) := X"000000000100";
				MODE		:	--! '1'==> Add, '0' ==> Sub
							  std_logic
			);
	port (
			Clk  		:  	in std_logic;
			Rst_n   	:   in  std_logic;
			Load_data	:	--! 计数器初始值
							in	std_logic_vector(47 downto 0);
			Load_en		:	--! 恢复计数器值到Load_data
							in	std_logic;
			Step_data	:	--! 步进值
							in	std_logic_vector(47 downto 0);
			Cnt_out		:	out	std_logic_vector(47 downto 0)
		 );
end COUNTER_48BIT;


architecture BEHAVOR of COUNTER_48BIT is

	constant PART_DATA_UP : std_logic_vector(47 downto 0) := PARTDATA - 1;
	constant PART_DATA_DOWN : std_logic_vector(47 downto 0) := PARTDATA + 1;

	--！alumode = 0000	 	==> Z+X
	--！alumode = 0011	 	==> Z-X
	--! 见ug479 Page35
	constant ALUMODE_UP	:	std_logic_vector(3 downto 0) := "0000";
	constant ALUMODE_DOWN	:	std_logic_vector(3 downto 0) := "0011";
	signal part_data	:	std_logic_vector(47 downto 0);
	signal low_18bit    :   std_logic_vector(17 downto 0);
	signal low_25bit    :   std_logic_vector(24 downto 0);
	signal low_30bit    :   std_logic_vector(29 downto 0);
	signal low_48bit    :   std_logic_vector(47 downto 0);

	--! opmode = 010 00 11 ==> Z = P, Y = 0, X = A:B
	--! opmode = 011 00 11 ==> Z = C, Y = 0, X= A:B
	--! 见ug479 Page34
	signal opmode		:	std_logic_vector(6 downto 0);

	--! P值匹配
	signal p_detect		:	std_logic;
begin
	opmode <= "0110011" when Load_en = '1' or p_detect =  '1' else
			  "0100011";


	low_18bit	<= (others => '0');
	low_25bit	<= (others => '0');
	low_30bit	<= (others => '0');
	low_48bit	<= (others => '0');


	CNT_UP : if MODE = '0' generate
	begin
		DSP48E1_UP : DSP48E1
		generic map (
						-- Feature Control Attributes: Data Path Selection
						A_INPUT => "DIRECT",               -- Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
						B_INPUT => "DIRECT",               -- Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
						USE_DPORT => FALSE,                -- Select D port usage (TRUE or FALSE)
						--! 这里没有用到乘法器
						USE_MULT => "NONE",            -- Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
						USE_SIMD => "ONE48",               -- SIMD selection ("ONE48", "TWO24", "FOUR12")
														   -- Pattern Detector Attributes: Pattern Detection Configuration
						AUTORESET_PATDET => "NO_RESET",    -- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH" 
						MASK => X"000000000000",           -- 48-bit mask value for pattern detect (1=ignore)
						PATTERN => To_bitvector(PART_DATA_UP),        -- 48-bit pattern match for pattern detect
						SEL_MASK => "MASK",                -- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2" 
						SEL_PATTERN => "PATTERN",          -- Select pattern value ("PATTERN" or "C")
						--! 开启匹配模式
						USE_PATTERN_DETECT => "PATDET", -- Enable pattern detect ("PATDET" or "NO_PATDET")
														   -- Register Control Attributes: Pipeline Register Configuration
						--! 这些延时在流水的时候得用
						ACASCREG => 1,                     -- Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
						ADREG => 1,                        -- Number of pipeline stages for pre-adder (0 or 1)
						ALUMODEREG => 1,                   -- Number of pipeline stages for ALUMODE (0 or 1)
						--! A端口寄存器个数，延迟作用, 
						AREG => 1,                         -- Number of pipeline stages for A (0, 1 or 2)
						BCASCREG => 1,                     -- Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
						BREG => 1,                         -- Number of pipeline stages for B (0, 1 or 2)
						CARRYINREG => 1,                   -- Number of pipeline stages for CARRYIN (0 or 1)
						CARRYINSELREG => 1,                -- Number of pipeline stages for CARRYINSEL (0 or 1)
						CREG => 1,                         -- Number of pipeline stages for C (0 or 1)
						DREG => 1,                         -- Number of pipeline stages for D (0 or 1)
						INMODEREG => 1,                    -- Number of pipeline stages for INMODE (0 or 1)
						--! 不使用乘法器
						MREG => 0,                         -- Number of multiplier pipeline stages (0 or 1)
						OPMODEREG => 1,                    -- Number of pipeline stages for OPMODE (0 or 1)
						PREG => 1                          -- Number of pipeline stages for P (0 or 1)
					)


		port map (
					---------------------------------------------------------------------------------------	
					--! 数据信号输入
					---------------------------------------------------------------------------------------	
					CLK => Clk,                       -- 1-bit input: Clock input
					A => Step_data(47 downto 18),                           -- 30-bit input: A data input
					B => Step_data(17 downto 0),                           -- 18-bit input: B data input
					C => Load_data,                           -- 48-bit input: C data input
					D => low_25bit,                           -- 25-bit input: D data input

					---------------------------------------------------------------------------------------	
					--! 级联数据信号输入
					---------------------------------------------------------------------------------------	
					ACIN => low_30bit,                     -- 30-bit input: A cascade data input
					BCIN => low_18bit,                     -- 18-bit input: B cascade input
					PCIN => low_48bit,                     -- 48-bit input: P cascade input
					CARRYIN => '0',               -- 1-bit input: Carry input signal
					CARRYCASCIN => '0',       -- 1-bit input: Cascade carry input
					MULTSIGNIN => '0',         -- 1-bit input: Multiplier sign input

					---------------------------------------------------------------------------------------	
					--! 配置信息输入
					---------------------------------------------------------------------------------------	

					--! INMODE : 选择A + D的部分
					--! 见ug479 Page28
					INMODE => "00000",                 -- 5-bit input: INMODE control input

					OPMODE => opmode,                 -- 7-bit input: Operation mode input
					ALUMODE => ALUMODE_UP,               -- 4-bit input: ALU control input
					--! CARRYINSEL = "000" => Cin = CARRYIN
					CARRYINSEL => "000",         -- 3-bit input: Carry select input

					---------------------------------------------------------------------------------------	
					--! 级联数据信号输出
					---------------------------------------------------------------------------------------	
					-- Cascade: 30-bit (each) output: Cascade Ports
					ACOUT => open,                   -- 30-bit output: A port cascade output
					BCOUT => open,                   -- 18-bit output: B port cascade output
					PCOUT => open,                   -- 48-bit output: Cascade output
					CARRYCASCOUT => open,     -- 1-bit output: Cascade carry output
					MULTSIGNOUT => open,       -- 1-bit output: Multiplier sign cascade output
													   -- Control: 1-bit (each) output: Control Inputs/Status Bits
					---------------------------------------------------------------------------------------	
					--! 控制信号输出
					---------------------------------------------------------------------------------------	
					OVERFLOW => open,             -- 1-bit output: Overflow in add/acc output
					UNDERFLOW => open,           -- 1-bit output: Underflow in add/acc output
					CARRYOUT => open,             -- 4-bit output: Carry output
					PATTERNBDETECT => open, -- 1-bit output: Pattern bar detect output
					PATTERNDETECT => p_detect,   -- 1-bit output: Pattern detect output
					---------------------------------------------------------------------------------------	
					--! 内部寄存器使能
					---------------------------------------------------------------------------------------	

					--! 一级寄存另CEA2=1
					--! 二级寄存CEA2=1, CEA1=1
					--! 即CEA2比CEA1优先级高
					CEA1 => '0',                     -- 1-bit input: Clock enable input for 1st stage AREG
					CEA2 => '1',                     -- 1-bit input: Clock enable input for 2nd stage AREG
					CEB1 => '0',                     -- 1-bit input: Clock enable input for 1st stage BREG
					CEB2 => '1',                     -- 1-bit input: Clock enable input for 2nd stage BREG
					CEC => '1',                       -- 1-bit input: Clock enable input for CREG
					CEAD => '0',                     -- 1-bit input: Clock enable input for ADREG
					--! 没有使用D值
					CED => '0',                       -- 1-bit input: Clock enable input for DREG
					CEALUMODE => '1',           -- 1-bit input: Clock enable input for ALUMODE
					CECARRYIN => '1',           -- 1-bit input: Clock enable input for CARRYINREG
					CECTRL => '1',                 -- 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
					CEINMODE => '1',             -- 1-bit input: Clock enable input for INMODEREG
					--! 不使用乘法器
					CEM => '0',                       -- 1-bit input: Clock enable input for MREG
					CEP => '1',                       -- 1-bit input: Clock enable input for PREG

					---------------------------------------------------------------------------------------	
					--! 寄存器复位
					---------------------------------------------------------------------------------------	
					--! 不使用复位功能的话，都给'0'
					RSTA => Rst_n,                     -- 1-bit input: Reset input for AREG
					RSTALLCARRYIN =>  Rst_n,   -- 1-bit input: Reset input for CARRYINREG
					RSTALUMODE =>  Rst_n,         -- 1-bit input: Reset input for ALUMODEREG
					RSTB =>  Rst_n,                     -- 1-bit input: Reset input for BREG
					RSTC =>  Rst_n,                     -- 1-bit input: Reset input for CREG
					RSTCTRL =>  Rst_n,               -- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
					RSTD =>  Rst_n,                     -- 1-bit input: Reset input for DREG and ADREG
					RSTINMODE =>  Rst_n,           -- 1-bit input: Reset input for INMODEREG
					RSTM =>  Rst_n,                     -- 1-bit input: Reset input for MREG
					RSTP =>  Rst_n,                      -- 1-bit input: Reset input for PREG

					---------------------------------------------------------------------------------------	
					--! 最终数据信号输出
					---------------------------------------------------------------------------------------	
					P => Cnt_out				-- 48-bit output: Primary data output
				 );

	end generate CNT_UP;
	
	CNT_DOWN : if MODE = '1' generate
	begin
		DSP48E1_UP : DSP48E1
		generic map (
						-- Feature Control Attributes: Data Path Selection
						A_INPUT => "DIRECT",               -- Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
						B_INPUT => "DIRECT",               -- Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
						USE_DPORT => FALSE,                -- Select D port usage (TRUE or FALSE)
						--! 这里没有用到乘法器
						USE_MULT => "NONE",            -- Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
						USE_SIMD => "ONE48",               -- SIMD selection ("ONE48", "TWO24", "FOUR12")
														   -- Pattern Detector Attributes: Pattern Detection Configuration
						AUTORESET_PATDET => "NO_RESET",    -- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH" 
						MASK => X"000000000000",           -- 48-bit mask value for pattern detect (1=ignore)
						PATTERN => To_bitvector(PART_DATA_DOWN),        -- 48-bit pattern match for pattern detect
						SEL_MASK => "MASK",                -- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2" 
						SEL_PATTERN => "PATTERN",          -- Select pattern value ("PATTERN" or "C")
						USE_PATTERN_DETECT => "PATDET", -- Enable pattern detect ("PATDET" or "NO_PATDET")
														   -- Register Control Attributes: Pipeline Register Configuration
						--! 这些延时在流水的时候得用
						ACASCREG => 1,                     -- Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
						ADREG => 1,                        -- Number of pipeline stages for pre-adder (0 or 1)
						ALUMODEREG => 1,                   -- Number of pipeline stages for ALUMODE (0 or 1)
						--! A端口寄存器个数，延迟作用, 
						AREG => 1,                         -- Number of pipeline stages for A (0, 1 or 2)
						BCASCREG => 1,                     -- Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
						BREG => 1,                         -- Number of pipeline stages for B (0, 1 or 2)
						CARRYINREG => 1,                   -- Number of pipeline stages for CARRYIN (0 or 1)
						CARRYINSELREG => 1,                -- Number of pipeline stages for CARRYINSEL (0 or 1)
						CREG => 1,                         -- Number of pipeline stages for C (0 or 1)
						DREG => 1,                         -- Number of pipeline stages for D (0 or 1)
						INMODEREG => 1,                    -- Number of pipeline stages for INMODE (0 or 1)
						--! 不使用乘法器
						MREG => 0,                         -- Number of multiplier pipeline stages (0 or 1)
						OPMODEREG => 1,                    -- Number of pipeline stages for OPMODE (0 or 1)
						PREG => 1                          -- Number of pipeline stages for P (0 or 1)
					)


		port map (
					---------------------------------------------------------------------------------------	
					--! 数据信号输入
					---------------------------------------------------------------------------------------	
					CLK => Clk,                       -- 1-bit input: Clock input
					A => Step_data(47 downto 18),                           -- 30-bit input: A data input
					B => Step_data(17 downto 0),                           -- 18-bit input: B data input
					C => Load_data,                           -- 48-bit input: C data input
					D => low_25bit,                           -- 25-bit input: D data input

					---------------------------------------------------------------------------------------	
					--! 级联数据信号输入
					---------------------------------------------------------------------------------------	
					ACIN => low_30bit,                     -- 30-bit input: A cascade data input
					BCIN => low_18bit,                     -- 18-bit input: B cascade input
					PCIN => low_48bit,                     -- 48-bit input: P cascade input
					CARRYIN => '0',               -- 1-bit input: Carry input signal
					CARRYCASCIN => '0',       -- 1-bit input: Cascade carry input
					MULTSIGNIN => '0',         -- 1-bit input: Multiplier sign input

					---------------------------------------------------------------------------------------	
					--! 配置信息输入
					---------------------------------------------------------------------------------------	

					--! INMODE : 选择A + D的部分
					--! 见ug479 Page28
					INMODE => "00000",                 -- 5-bit input: INMODE control input

					OPMODE => opmode,                 -- 7-bit input: Operation mode input
					ALUMODE => ALUMODE_DOWN,               -- 4-bit input: ALU control input
					--! CARRYINSEL = "000" => Cin = CARRYIN
					CARRYINSEL => "000",         -- 3-bit input: Carry select input

					---------------------------------------------------------------------------------------	
					--! 级联数据信号输出
					---------------------------------------------------------------------------------------	
					-- Cascade: 30-bit (each) output: Cascade Ports
					ACOUT => open,                   -- 30-bit output: A port cascade output
					BCOUT => open,                   -- 18-bit output: B port cascade output
					PCOUT => open,                   -- 48-bit output: Cascade output
					CARRYCASCOUT => open,     -- 1-bit output: Cascade carry output
					MULTSIGNOUT => open,       -- 1-bit output: Multiplier sign cascade output
													   -- Control: 1-bit (each) output: Control Inputs/Status Bits
					---------------------------------------------------------------------------------------	
					--! 控制信号输出
					---------------------------------------------------------------------------------------	
					OVERFLOW => open,             -- 1-bit output: Overflow in add/acc output
					UNDERFLOW => open,           -- 1-bit output: Underflow in add/acc output
					CARRYOUT => open,             -- 4-bit output: Carry output
					PATTERNBDETECT => open, -- 1-bit output: Pattern bar detect output
					PATTERNDETECT => p_detect,   -- 1-bit output: Pattern detect output
					---------------------------------------------------------------------------------------	
					--! 内部寄存器使能
					---------------------------------------------------------------------------------------	

					--! 一级寄存另CEA2=1
					--! 二级寄存CEA2=1, CEA1=1
					--! 即CEA2比CEA1优先级高
					CEA1 => '0',                     -- 1-bit input: Clock enable input for 1st stage AREG
					CEA2 => '1',                     -- 1-bit input: Clock enable input for 2nd stage AREG
					CEB1 => '0',                     -- 1-bit input: Clock enable input for 1st stage BREG
					CEB2 => '1',                     -- 1-bit input: Clock enable input for 2nd stage BREG
					CEC => '1',                       -- 1-bit input: Clock enable input for CREG
					CEAD => '0',                     -- 1-bit input: Clock enable input for ADREG
					--! 没有使用D值
					CED => '0',                       -- 1-bit input: Clock enable input for DREG
					CEALUMODE => '1',           -- 1-bit input: Clock enable input for ALUMODE
					CECARRYIN => '1',           -- 1-bit input: Clock enable input for CARRYINREG
					CECTRL => '1',                 -- 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
					CEINMODE => '1',             -- 1-bit input: Clock enable input for INMODEREG
					--! 不使用乘法器
					CEM => '0',                       -- 1-bit input: Clock enable input for MREG
					CEP => '1',                       -- 1-bit input: Clock enable input for PREG

					---------------------------------------------------------------------------------------	
					--! 寄存器复位
					---------------------------------------------------------------------------------------	
					--! 不使用复位功能的话，都给'0'
					RSTA => Rst_n,                     -- 1-bit input: Reset input for AREG
					RSTALLCARRYIN =>  Rst_n,   -- 1-bit input: Reset input for CARRYINREG
					RSTALUMODE =>  Rst_n,         -- 1-bit input: Reset input for ALUMODEREG
					RSTB =>  Rst_n,                     -- 1-bit input: Reset input for BREG
					RSTC =>  Rst_n,                     -- 1-bit input: Reset input for CREG
					RSTCTRL =>  Rst_n,               -- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
					RSTD =>  Rst_n,                     -- 1-bit input: Reset input for DREG and ADREG
					RSTINMODE =>  Rst_n,           -- 1-bit input: Reset input for INMODEREG
					RSTM =>  Rst_n,                     -- 1-bit input: Reset input for MREG
					RSTP =>  Rst_n,                      -- 1-bit input: Reset input for PREG

					---------------------------------------------------------------------------------------	
					--! 最终数据信号输出
					---------------------------------------------------------------------------------------	
					P => Cnt_out				-- 48-bit output: Primary data output
				 );

	end generate CNT_DOWN;



end BEHAVOR;
