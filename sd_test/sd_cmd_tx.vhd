library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

use work.sd_pkt.all;

entity SD_CMD_TX is
	port (
			
			Clk				:	in		std_logic;
			Clk_tick			: 	in		std_logic; 
			Rst_n			:	in 		std_logic;

			Start			:	in		std_logic;
			Fast			:	in		std_logic;
			Cmd_in			:	in		cmd_type;
			Done			:	out		std_logic;
			Busy			:	out		std_logic;
		
			--! sd interface
			sd_cmd			: 	inout	std_logic;
			sd_dat			: 	inout	std_logic_vector(3 downto 0)
			
		 );
end SD_CMD_TX;
architecture BEHAVOR of SD_CMD_TX is
	component CRC is
	generic (
			constant LENGTH		: natural;
			constant POLYNOMIAL	: std_logic_vector
			);
	port(
			Rst_n				: in  std_logic;
			Clk					: in  std_logic;
			Clk_en				: in  std_logic;
			Clear				: in  std_logic;
			Start				: in  std_logic;
			Shift_out			: in  std_logic;
			Din					: in  std_logic;
			Dout				: out std_logic
		);
	end component;

	type SD_TX_STATES is (SD_INIT, SD_TX_IDLE, SD_TX_SENDING, SD_TX_CRC, SD_TX_STOP, SD_TX_FINISH);
	signal sd_tx_state_cur	:	SD_TX_STATES;
	signal sd_tx_state_next	:	SD_TX_STATES;

	--! 期间会使用的延时
	constant 	resp_timeout	: natural := 100; -- recommended: 64 cycles
	constant	timeout_1s_slow	: natural := 400e3;	-- 400 kHz
	constant	timeout_1s_fast	: natural :=  50e6;	--  50 MHz
	signal		timeout_1s			: natural range 0 to 50e6;
	--! CMD缓存值，共40bit, 不包含CRC和结束位
	signal cmd_shift 		:	std_logic_vector(39 downto 0);



	--! CRC7模块相关
	signal crc_start		:	std_logic;
	signal crc_shift		:	std_logic;
	signal crc_clear		:	std_logic;
	signal crc_in			:	std_logic;
	signal crc_out			:	std_logic;


	signal resp_shift		:	std_logic_vector(135 downto 0);


	signal cnt 				:	integer	 range 0 to 128;
	--! Start信号的拓展信号,拓展至Clk_tick高电平位置
	signal start_extend		:	std_logic;

begin
	timeout_1s <= timeout_1s_fast when Fast = '1' else
				  timeout_1s_slow ;

	U_CRC7 : CRC
	generic map(
			  		LENGTH 		=> crc7_len,
					POLYNOMIAL	=> crc7_pol

			   )
	port map(
				Rst_n 		=>	Rst_n,
				Clk			=>	Clk,
				Clk_en		=>	Clk_tick,
				Clear		=>	crc_clear,
				Start		=>	crc_start,
				Shift_out	=>	crc_shift,
				Din			=>	crc_in,
				Dout		=>	crc_out

			);

	--! 使用组合逻辑输出
	sd_cmd	<= cmd_shift(cmd_shift'length - 1) 	when sd_tx_state_cur = SD_TX_SENDING else
			  crc_out							when sd_tx_state_cur = SD_TX_CRC else
			  '1'								when sd_tx_state_cur = SD_TX_STOP else
			  '1'								when sd_tx_state_cur = SD_INIT else
			  'Z';

	--!使用时序逻辑输出,仿真图比较好看，但是没必要
	--U_SDCMD : process(Clk)
	--begin
	--	if Clk'event and Clk = '1' then
	--		if Clk_tick = '1' then
	--			if sd_tx_state_cur = SD_TX_SENDING then
	--				sd_cmd <= cmd_shift(cmd_shift'length - 1);
	--			elsif sd_tx_state_cur = SD_TX_CRC then
	--				sd_cmd <= crc_out;
	--			elsif sd_tx_state_cur = SD_TX_STOP or sd_tx_state_cur = SD_INIT then
	--				sd_cmd <= '1';
	--			else
	--				sd_cmd <= 'Z';
	--			end if;
	--		end if;
	--	end if;
	--end process;

	crc_in <= cmd_shift(cmd_shift'length - 1) when sd_tx_state_cur = SD_TX_SENDING else
			  'Z';
	crc_start <= '1' when sd_tx_state_cur = SD_TX_SENDING else
				 '0';
	crc_clear <= '1' when sd_tx_state_cur = SD_TX_IDLE else
				 '0';
	crc_shift <= '1' when sd_tx_state_cur = SD_TX_CRC else
				 '0';

	--! 扩展Start信号至Clk_tick
	U_START_EXTENT : process(Clk, Rst_n)
	begin
		if Clk'event and Clk = '1' then
			if Rst_n = '0' then
				start_extend <= '0';
			else
				if Start = '1' then
					start_extend <= '1' ;
				elsif Clk_tick = '1' then
					start_extend <= '0' ;
				end if;
				
			end if;
		end if;
	end process;

	U_CNT : process(Clk, Rst_n)
	begin
		if Rst_n = '0' then
			cnt <= 0;
		elsif Clk'event and Clk = '1' then
			if sd_tx_state_cur /= sd_tx_state_next then
				cnt <= 0;
			elsif Clk_tick = '1' then
				cnt <= cnt + 1;
			end if;
		end if;
	end process;

	U_STATE1 : process(Clk, Rst_n)
	begin
		if Clk'event and Clk = '1' then
			if Rst_n = '0' then
				sd_tx_state_cur <= SD_INIT;
			else
				sd_tx_state_cur <= sd_tx_state_next;
			end if;
		end if;
	end process;

	U_CMDSHIFT : process(Clk, Rst_n)
	begin
		if Clk'event and Clk = '1' then
			if Rst_n = '0' then
				cmd_shift <= (others => '0');
			elsif sd_tx_state_cur = SD_TX_IDLE and Start = '1' then
				cmd_shift <= "01" & Cmd_in.index & Cmd_in.arg;
			elsif sd_tx_state_cur = SD_TX_SENDING and Clk_tick = '1'then
				cmd_shift <= cmd_shift(cmd_shift'length - 2 downto 0) & '0';
			end if;
		end if;
	end process;




	U_STATE2: process(start_extend, Clk_tick, sd_tx_state_cur, cnt)
	begin
			case sd_tx_state_cur is
				when SD_INIT 		=>
					if cnt = 74 then
						sd_tx_state_next <= SD_TX_IDLE;
					else
						sd_tx_state_next <= SD_INIT;
					end if;
				when SD_TX_IDLE 	=>
					if start_extend = '1' then
						sd_tx_state_next <= SD_TX_SENDING;
					else 
						sd_tx_state_next <= SD_TX_IDLE;
					end if;
				when SD_TX_SENDING 	=>
					--! 组合逻辑，不能用length - 1
					if cnt = cmd_shift'length then
						sd_tx_state_next <= SD_TX_CRC;
					else 
						sd_tx_state_next <= SD_TX_SENDING;
					end if;
				when SD_TX_CRC 		=>
					--! 组合逻辑，不能用length - 1
					if cnt = crc7_len then
						sd_tx_state_next <= SD_TX_STOP;
					else 
						sd_tx_state_next <= SD_TX_CRC;
					end if;
				when SD_TX_STOP		=>
					if Clk_tick = '1' then
						sd_tx_state_next 	<=  SD_TX_FINISH;
					else
						sd_tx_state_next 	<=  SD_TX_STOP;
					end if;
				when SD_TX_FINISH	=>
					sd_tx_state_next 	<=  SD_TX_IDLE;

				when others 		=>
					sd_tx_state_next  	<=  SD_INIT;
			end case;

	end process;


	U_DONE : process(Clk, Rst_n)
	begin
		if Clk'event and Clk = '1' then
			if Rst_n = '0' then
				Done <= '0';
			elsif sd_tx_state_cur = SD_TX_FINISH then
				Done <= '1';
			else
				Done <= '0';
			end if;
		end if;
	end process;

	--U_BUSY : process(Clk)
	--begin
	--	if Clk'event and Clk = '1' then
	--		if sd_tx_state_cur = SD_TX_IDLE then
	--			Busy <= '0';
	--		else
	--			Busy <= '1';
	--		end if;
	--	end if;
	--end process;

	Busy <= '0' when sd_tx_state_cur = SD_TX_IDLE else
			'1';
end BEHAVOR;
