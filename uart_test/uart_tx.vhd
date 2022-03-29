library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity UART_TX is 
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
end UART_TX;

architecture BEHAVOR of UART_TX is
	component BPS_COUNT 
	generic (	
			constant CLKFREQ  : integer := 100e6;
			constant BAUDRATE : integer := 115200;
			constant HALF_OUT : integer := 1);
	port (
			Clk		:	in	std_logic; 
			Enable	:	in	std_logic;
			Sig		:	out	std_logic
		 );
	end component;

	---------------------------------------------------------------------------
	--!	内部信号
	---------------------------------------------------------------------------
	type TX_STATES is (TX_IDLE, TX_START, TX_SHIFT, TX_CRC, TX_STOP);
	signal tx_sta_cur	:	 TX_STATES;
	signal tx_sta_next	:	 TX_STATES;

	--! 波特率计数使能
	signal 	baud_enalbe		:	std_logic;
	--! 数据装载标记
	signal 	load_flag		:	std_logic;

	signal 	cnt 	 		:	integer range 0 to 8;

 	--attribute mark_debug : string;
 	--attribute mark_debug of tx_sta_cur : signal is "true";

begin
	U_BPS_COUNT	: BPS_COUNT
	generic map(
				CLKFREQ		=>	CLKFREQ,
				BAUDRATE 	=> 	BAUDRATE,
			   	HALF_OUT	=> 	0)
	port map(
				Clk			=>	Clk,	
				Enable		=>	baud_enalbe,
				Sig			=>	load_flag	
			);

	U_BAUD_CTL : process(Clk)
	begin
		if Clk'event and Clk = '1' then
			if Start = '1' then
				baud_enalbe <= '1';
			elsif tx_sta_cur = TX_IDLE then
				baud_enalbe <= '0';
			end if;
		end if;
	end process;

	U_STATE1 : process(Clk, Rst_n)
	begin
		if Clk'event and Clk = '1' then
			if Rst_n = '0' then
				tx_sta_cur <= TX_IDLE;
			else
				tx_sta_cur <= tx_sta_next;
			end if;
		end if;
	end process;
	U_STATE2 : process(Start, tx_sta_cur, load_flag, cnt)
	begin
		case tx_sta_cur is 
			when TX_IDLE	=>	
				if Start = '1' then
					tx_sta_next <= TX_START ;
				else
					tx_sta_next <= TX_IDLE;
				end if;
			when TX_START	=>	
				if load_flag = '1' then
					tx_sta_next <= TX_SHIFT;
				else
					tx_sta_next <= TX_START;
				end if;
			when TX_SHIFT	=>	
				if cnt = 7 and load_flag = '1' then
					tx_sta_next <= TX_CRC;
				else
					tx_sta_next <= TX_SHIFT;
				end if;
			when TX_CRC		=>	
				if load_flag = '1' then
					tx_sta_next <= TX_STOP;
				else
					tx_sta_next <= TX_CRC;
				end if;
			when TX_STOP	=>	
				if load_flag = '1' then
					tx_sta_next <= TX_IDLE;
				else
					tx_sta_next <= TX_STOP;
				end if;
			when others 	=>
				tx_sta_next <= TX_IDLE;
		end case;
	end process;



	--! 不需要复位
	U_CNT : process(Clk)
	begin
		if Clk'event and Clk = '1' then
			if tx_sta_cur = TX_SHIFT then
				if load_flag = '1' then
					cnt <= cnt + 1;
				end if;
			else
				cnt <= 0;
			end if;
		end if;
	end process;

	--! 不需要直接复位
	U_DONE : process(Clk)
	begin
		if Clk'event and Clk = '1' then
			if tx_sta_cur = TX_STOP and load_flag = '1' then
				Done	<= 	'1';
			else
				Done	<=	'0';
			end if;
		end if;
	end process;

	Tx_pin <= '0' when tx_sta_cur = TX_START else
			   Tx_buf(cnt) when tx_sta_cur = TX_SHIFT else
			   '1';
			   

end BEHAVOR;
