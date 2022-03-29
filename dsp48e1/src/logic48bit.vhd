-----------------------------------------------------------------------------
--! 	@file		logic48bit.vhd
--! 	@function	DSP48E1的第一类应用: 逻辑运算
--!					应用1 : 2输入48bit位逻辑运算
--!		@version	
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


Library UNISIM;
use UNISIM.vcomponents.all;


entity LOGIC48BIT is
	port (
			Clk  :  in std_logic;
			Rst_n   :   in  std_logic;
			Ain	:	in	std_logic_vector(47 downto 0);
			Bin	:	in	std_logic_vector(47 downto 0);
			Logic_out	:	out	std_logic_vector(47 downto 0)
		 );
end LOGIC48BIT;


architecture BEHAVOR of LOGIC48BIT is

	signal low_18bit    :   std_logic_vector(17 downto 0);
	signal low_25bit    :   std_logic_vector(24 downto 0);
	signal low_30bit    :   std_logic_vector(29 downto 0);
	signal low_48bit    :   std_logic_vector(47 downto 0);



begin
	low_18bit	<= (others => '0');
	low_25bit	<= (others => '0');
	low_30bit	<= (others => '0');
	low_48bit	<= (others => '0');



	DSP48E1_inst : DSP48E1
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
					MASK => X"3fffffffffff",           -- 48-bit mask value for pattern detect (1=ignore)
					PATTERN => X"000000000000",        -- 48-bit pattern match for pattern detect
					SEL_MASK => "MASK",                -- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2" 
					SEL_PATTERN => "PATTERN",          -- Select pattern value ("PATTERN" or "C")
					USE_PATTERN_DETECT => "NO_PATDET", -- Enable pattern detect ("PATDET" or "NO_PATDET")
													   -- Register Control Attributes: Pipeline Register Configuration
					--! 这些延时在流水的时候得用
	  				--! A端口到ACOUT的寄存器延时
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
				A => Ain(47 downto 18),                           -- 30-bit input: A data input
				B => Ain(17 downto 0),                           -- 18-bit input: B data input
				C => Bin,                           -- 48-bit input: C data input
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

	  			--! OPMODE = "0110011" ==> 
	  			--! Z = C, Y = 0, X = A:B
	  			--! 见ug479 Page31
				OPMODE => "0110011",                 -- 7-bit input: Operation mode input
				--! ALUMODE : 选择最终输出与X, Y, Z的关系
				--! 这里是两输入, A:B和C, 见ug479 Page42
				--! 这里是 X XOR Z
				ALUMODE => "0111",               -- 4-bit input: ALU control input
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
				PATTERNDETECT => open,   -- 1-bit output: Pattern detect output
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
				P => Logic_out                           -- 48-bit output: Primary data output
			 );


end BEHAVOR;
