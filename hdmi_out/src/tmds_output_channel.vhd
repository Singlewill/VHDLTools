-----------------------------------------------------------------------------
--! 	@file		tmds_output_channel.vhd
--! 	@function	对单独一路tmds channel数据输出
--!		@version	
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


entity TMDS_OUTPUT_CHANNEL is
	port(
			Clk			:	in	std_logic;
			Clk_x1	:	in	std_logic;
			Clk_x5	:	in	std_logic;
			Rst_n	:	in	std_logic;
			Blank_i		:	in 	std_logic;
			Ctl_i		:	in	std_logic_vector(1 downto 0);
			Symbol_i	:	in	std_logic_vector(7 downto 0);

			Tmds_o		:	out	std_logic

		);
end TMDS_OUTPUT_CHANNEL;
architecture BEHAVOR of TMDS_OUTPUT_CHANNEL is
	component TMDS_ENCODER
    Port ( 
			Clk		:	in	std_logic;
			D_in	:	in	std_logic_vector(7 downto 0);
			C_in	:	in	std_logic_vector(1 downto 0);
			C_en	:	in	std_logic;
			Q_out	:	out std_logic_vector(9 downto 0)
        );
	end component;
	component SERIALISER_10_TO_1
	port ( 
			 Clk_x1    	: in std_logic;
			 Clk_x5 	: in std_logic;
			 Data   	: in std_logic_vector (9 downto 0);
			 Rst  		: in std_logic;
			 Serial 	: out std_logic
		 );
	end component;
	-----------------------------------------------------------------------------------
	--! 内部信号定义
	-----------------------------------------------------------------------------------
	signal symbol_encoded	:	std_logic_vector(9 downto 0);
begin
	U_TMDS_ENCODER  : TMDS_ENCODER
	port map(
				Clk		=>	Clk,	
				D_in	=>	Symbol_i,
				C_in	=>	Ctl_i,
				C_en	=>	Blank_i,
				Q_out 	=>	symbol_encoded
			);



	U_SERIALISER_10_TO_1 : SERIALISER_10_TO_1
	port map(
				Clk_x1			=>	Clk_x1,	
				Clk_x5	=>	Clk_x5,
				Data		=>	symbol_encoded,
				--! Rst_n = '0', 不使用复位
				Rst			=>	Rst_n,
				Serial		=>	Tmds_o
			);
end BEHAVOR;

