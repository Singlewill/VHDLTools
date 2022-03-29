library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity UART is
	port (
			Clk				:	in	std_logic; 
			Rst_n			:	in	std_logic;
			Rx_pin			:	in	std_logic;
			Tx_pin           :   out std_logic
		 );
end UART;


architecture BEHAVOR of UART is
	component UART_RX 
	generic (
			constant CLKFREQ : integer := 100e6;
			constant BAUDRATE : integer:= 115200);
	port (
			Clk				:	in	std_logic; 
			Rst_n			:	in	std_logic;
			Enable			:	in	std_logic;
			Rx_pin			:	in	std_logic;
			Done			:	out	std_logic;
			Rx_buf			:	out	std_logic_vector(7 downto 0)
		 );
	end component;

	component UART_TX
	generic (
			constant CLKFREQ : integer := 100e6;
			constant BAUDRATE : integer:= 115200);
	port (
				Clk		:	in	std_logic;	
				Rst_n	:	in	std_logic;
				Start	:	in	std_logic;
				Tx_buf	:	in	std_logic_vector(7 downto 0);
				Tx_pin	:	out	std_logic;
				Done	:	out std_logic
			);
	end component;
	
	signal rx_done	:	std_logic;
	signal rx_buff	:	std_logic_vector(7 downto 0);

	signal tx_done	:	std_logic;


begin


	U_UART_RX : UART_RX
	port map(
				Clk		=>	Clk,	
				Rst_n	=>	Rst_n,
				Enable	=>	'1',
				Rx_pin	=>	Rx_pin,
				Done	=>	rx_done,
				Rx_buf	=>	rx_buff
			);
	U_UART_TX : UART_TX
	port map(
				Clk		=>	clk,	
				Rst_n	=>	Rst_n,
				Start	=>	rx_done,
				Tx_buf	=>	rx_buff,
				Tx_pin	=>	Tx_pin,
				Done	=>	tx_done
			);
end BEHAVOR;
