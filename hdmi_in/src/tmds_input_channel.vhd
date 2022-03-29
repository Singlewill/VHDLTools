--! 	@file		tmds_input_channel.vhd
--! 	@author		SingleWill
--! 	@function	1, 对单独一路tmds channel输入处理分析
--!						包含IDELAY2模块, alignment模块以及tmds_decoder模块
--!						alignment模块会检测输入是否有效，调整IDELAY2模块的bitslip	
--!					2, 该模块及以下，都在HDMI输入时钟的时钟域下
--!		@version	
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


entity TMDS_INPUT_CHANNEL is
	port (
			Clk			:	in	std_logic; 
			Clk_high	:	in	std_logic;
			Rst_n		:	in	std_logic;
			Data_in		:	in	std_logic;

			--! OUTPUT
			--! 当期数据为CTL数据
			Ctl_valid	:	out std_logic;
			Ctl			:	out std_logic_vector(1 downto 0);

			--! 当前数据为terc4数据
			Terc4_valid 	:	out std_logic;
			Terc4		:	out std_logic_vector(3 downto 0);

			--! 当前数据为Guardband数据
			Guardband_valid	:	out	std_logic;	
			Guardband		:	out	std_logic;

			--! 当前数据为有效像素数据
			Pixel_valid		:	out std_logic;
			Pixel_data		:	out std_logic_vector(7 downto 0)
			
		 );
end TMDS_INPUT_CHANNEL;

architecture BEHAVOR of TMDS_INPUT_CHANNEL is
	component DESERIALISER_1_10 
	port (
			Clk			:	in	std_logic;				
			Rst_n		:	in	std_logic;
			Clk_high	:	in	std_logic;
			Data_in		:	in	std_logic;
			Data_out	:	out	std_logic_vector(9 downto 0);
			Bitslip		:	in	std_logic;
			Delay_ce	:	in	std_logic;
			Delay_cnt	:	in	std_logic_vector(4 downto 0)
		);
	end component;


	component TMDS_DECODER
	port ( 
			Clk            	: in  std_logic;
			Data_in		  	: in  std_logic_vector (9 downto 0);
			Symbol_valid   	: out std_logic;
			Ctl_valid        	: out std_logic;
			Ctl              	: out std_logic_vector (1 downto 0);
			Terc4_valid      	: out std_logic;
			Terc4            	: out std_logic_vector (3 downto 0);
			Guardband_valid	:	out	std_logic;	
			Guardband		:	out	std_logic;
			Data_valid       	: out std_logic;
			Data_out            	: out std_logic_vector (7 downto 0)
		 );
	end component;

	component ALIGNMENT_DETECT 
	port ( 
			Clk            : in  std_logic;
			Rst_n			: in  std_logic;
			Symbol_valid 	: in  std_logic;
			Delay_cnt    : out std_logic_vector(4 downto 0);
			Delay_ce       : out std_logic;
			Bitslip        : out std_logic
		 );
	end component;
	-----------------------------------------------------------------------------------
	--! 内部信号定义
	-----------------------------------------------------------------------------------

	--! 解串后的10bit数据
	signal symbol		:	std_logic_vector(9 downto 0);
	--! 用于ISERDESE2模块，调整输出顺序
	signal bitslip		:	std_logic;
	--! Delay_*, 用于调整IDELAY2延迟大小
	signal delay_ce		:	std_logic;
	signal delay_cnt	:	std_logic_vector(4 downto 0);

	--! 解串之后的数据是否为有效数据
	signal symbol_valid	:	std_logic;

begin
	U_DESERIALISER_1_10 : DESERIALISER_1_10
	port map(
				Clk				=>	Clk,
				Rst_n			=>	Rst_n,
				Clk_high		=>	Clk_high,
				Data_in			=>	Data_in,
				Data_out		=>	symbol,
				Bitslip			=>	bitslip,
				Delay_ce		=>	delay_ce,
				Delay_cnt		=>	delay_cnt
			);


	U_TMDS_DECODER : TMDS_DECODER
	port map(
			 	Clk            	=>	Clk,
			 	Data_in		  	=>	symbol,
			 	Symbol_valid 	=>	symbol_valid,
			 	Ctl_valid       =>	Ctl_valid,
			 	Ctl             =>	Ctl,
			 	Terc4_valid     =>	Terc4_valid,
			 	Terc4           =>	Terc4,
				Guardband_valid	=>	Guardband_valid,
				Guardband		=>	Guardband,
			 	Data_valid      =>	Pixel_valid,
			 	Data_out            =>	Pixel_data
			);

	U_ALIGNMENT_DETECT : ALIGNMENT_DETECT
	port map(
				Clk            	=>	Clk,
				Rst_n			=>	Rst_n,
				Symbol_valid	=>	symbol_valid,
				Delay_cnt    	=>	delay_cnt,
				Delay_ce       	=>	delay_ce,
				Bitslip        	=>	bitslip
			);

end BEHAVOR;
