library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity UART_RX is
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
end UART_RX;


architecture BEHAVOR of UART_RX is
	component FALLING_EDGE_DETECTOR 
	port (
			Clk		:	in	std_logic; 
			Rst_n	:	in	std_logic;
			Pin		:	in	std_logic;
			Sig		:	out	std_logic
		 );
	end component;

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
	type RX_STATES is (RX_IDLE, RX_START, RX_SAMPLE, RX_STOP);
	signal rx_sta_cur	:	RX_STATES;
	signal rx_sta_next	:	RX_STATES;
	
	--! 检测到起始位
	signal	start_bit_sig	:	std_logic;
	--! 波特率计数使能
	signal 	baud_enalbe		:	std_logic;
	--! 采样标记
	signal 	sample_flag		:	std_logic;

	--! 接受bit计数
	signal cnt 				:	integer range 0 to 8;
	signal rbuff			:	std_logic_vector(7 downto 0);

	--attribute mark_debug : string;
	--attribute mark_debug of rbuff: signal is "true";
	
begin
	
	U_FALLING_EDGE_DETECTOR : FALLING_EDGE_DETECTOR
	port map(
				Clk		=>	Clk,
				Rst_n	=>	Rst_n,
				Pin		=>	Rx_pin,
				Sig		=>	start_bit_sig
			);


	U_BPS_COUNT	: BPS_COUNT
	generic map(
				CLKFREQ		=>	CLKFREQ,
				BAUDRATE 	=> 	BAUDRATE,
			   	HALF_OUT 	=> 	1)
	port map(
				Clk			=>	Clk,
				Enable		=>	baud_enalbe,
				Sig			=>	sample_flag
			);

	U_STATE1 : process(Clk, Rst_n)
	begin
		if Clk'event and Clk = '1' then
			if Rst_n = '0' then
				rx_sta_cur <= RX_IDLE;
			else
				rx_sta_cur <= rx_sta_next;
			end if;
		end if;
	end process;

	U_STATE2 : process(rx_sta_cur, sample_flag, start_bit_sig, Enable, cnt)
	begin
			case rx_sta_cur is 
				when RX_IDLE	=>
					if start_bit_sig = '1' and Enable = '1' then
						rx_sta_next <= RX_START;
					else 
						rx_sta_next <= RX_IDLE;
					end if;
				when RX_START 	=>
					if sample_flag = '1' then
						rx_sta_next <= RX_SAMPLE;
					else
						rx_sta_next <= RX_START;
					end if;
				when RX_SAMPLE	=>
					--! sample_flag 在一bit数据的中间有效,cnt在一bit的后半段+1
					--! 例如，在实际start信号的后半段，状态机已经进入RX_SAMPLE了
					--! 当cnt更新为7时，实际是第6bit的后半段,缺少最后1bit有效位
					--! 当cnt更新为8时，实际是在第7bit中间采样完毕，可以进入RX_STOP
					if cnt = 8 then 
						rx_sta_next <= RX_STOP;
					else
						rx_sta_next <= RX_SAMPLE;
					end if;
				when RX_STOP	=>
					rx_sta_next <= RX_IDLE;
				when others 	=>
					rx_sta_next <= RX_IDLE;
			end case;

	end process;
	U_BAUD_CTL : process(Clk)
	begin
		if Clk'event and Clk = '1' then
			if start_bit_sig = '1' and Enable = '1' then
				baud_enalbe <= '1';
			elsif rx_sta_cur = RX_STOP then
				baud_enalbe <= '0';
			end if;
		end if;
	end process;

	U_CNT : process(Clk)
	begin
		if Clk'event and Clk = '1' then
			if rx_sta_cur = RX_SAMPLE then
				if sample_flag = '1' then
					cnt <= cnt + 1;
				end if;
			else
				cnt <= 0;
			end if;
		end if;
	end process;

	U_DATA : process(Clk)
	begin
		if Clk'event and Clk = '1' then
			if rx_sta_cur = RX_SAMPLE and sample_flag = '1' then
				rbuff(cnt) <= Rx_pin;
			end if;
		end if;
	end process;
	Rx_buf <= rbuff;

	--! 不需要直接复位
	U_DONE : process(Clk)
	begin
		if Clk'event and Clk = '1' then
			if rx_sta_cur = RX_STOP then
				Done	<= 	'1';
			else
				Done	<=	'0';
			end if;
		end if;
	end process;



end BEHAVOR;
