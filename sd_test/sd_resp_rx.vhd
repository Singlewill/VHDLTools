library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity SD_RESP_RX is
	generic (RESP_TIMEOUT : integer := 100);
	port (
			Clk				: in std_logic; 
			Rst_n			: in std_logic;
			Clk_tick		: in std_logic;
			Start			: in std_logic;
			Cmd_busy		: in std_logic;

			-- response related
			-- 00: no response
			-- 01: response length 136
			-- 10: response length 48
			-- 11: response length 48 and check Busy after response
			Resp_type	    : in std_logic_vector(1 downto 0);

			Resp_Error		: out std_logic;
			Resp_done		: out std_logic;

			--! sd interface
			Sd_cmd			: 	inout	std_logic;
			Sd_dat			: 	inout	std_logic_vector(3 downto 0)
		 );
end SD_RESP_RX;

architecture BEHAVOR of SD_RESP_RX is
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

	type RESP_STATES is (RESP_IDLE, RESP_WAIT_CMDDONE, RESP_START_BIT, RESP_FIRST_BIT, RESP_SAMPLE, RESP_STOP, RESP_WAIT_BUSY, RESP_FINISH, RESP_ERRORS);
	signal resp_state_next	:	RESP_STATES;
	signal resp_state_cur	:	RESP_STATES;


	signal cnt 				:	integer	 range 0 to 150;

	signal cmd_busy_l1 			:	std_logic;
	signal cmd_busy_falling 	:	std_logic;
	signal resp_shift		:	std_logic_vector(135 downto 0);

	attribute mark_debug : string;
	attribute mark_debug of resp_shift: signal is "true";
	attribute mark_debug of cnt: signal is "true";
	attribute mark_debug of resp_state_cur: signal is "true";
begin
	U_CMDBUSY : process(Clk)
	begin
		if Clk'event and Clk = '1' then
			cmd_busy_l1 <= Cmd_busy;
		end if;
	end process;

	cmd_busy_falling <= '1' when Cmd_busy = '0' and cmd_busy_l1 <= '1' else
						'0';
	U_CNT : process(Clk, Rst_n)
	begin
		if Rst_n = '0' then
			cnt <= 0;
		elsif Clk'event and Clk = '1' then
			if resp_state_cur /= resp_state_next then
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
				resp_state_cur <= RESP_IDLE ;
			else
				resp_state_cur <= resp_state_next;
			end if;
		end if;
	end process;

	U_STATE2 : process(Start, cmd_busy_falling, Clk_tick, resp_state_cur, cnt)
	begin
		case resp_state_cur is
			when RESP_IDLE	=>		-- 0
				--! 需要resp
				if Start = '1' then
					if Resp_type = "00" then
						resp_state_next <= RESP_FINISH;
					else
						resp_state_next <= RESP_WAIT_CMDDONE;
					end if;
				else
					resp_state_next <= RESP_IDLE;
				end if;
			when RESP_WAIT_CMDDONE 	=>	-- 1
				if cmd_busy_falling = '1' then
					resp_state_next <= RESP_START_BIT;
				else
					resp_state_next <= RESP_WAIT_CMDDONE;
				end if;
			--! 等待start位, '0'
			when RESP_START_BIT 	=>		-- 2
				if cnt = RESP_TIMEOUT then
					resp_state_next <= RESP_ERRORS;
				elsif Clk_tick = '1' and Sd_cmd = '0' then
					resp_state_next <= RESP_FIRST_BIT;
				else
					resp_state_next <= RESP_START_BIT;
				end if;
			-- 响应的第一bit，一定为'0'
			when RESP_FIRST_BIT		=>		-- 3
				if Clk_tick = '1' then
					if Sd_cmd = '0' then
						resp_state_next <= RESP_SAMPLE;
					else
						--! 这里应该直接ERROR还是继续等待??
						resp_state_next <= RESP_START_BIT;
					end if;
				end if;

			-- 开始采样resp数据
			when RESP_SAMPLE		=>		-- 4
				--! 136bit - 3(start bit + first bit + stop bit) = 133
				if Resp_type = "01" and cnt = 133 then
					resp_state_next <= RESP_STOP;
				--! 48bit -3 = 45
				elsif cnt = 45 then
					resp_state_next <= RESP_STOP;
				else
					resp_state_next <= RESP_SAMPLE;
				end if;
			when RESP_STOP 			=>		-- 5
				if Clk_tick = '1' then
					--! 停止位高电平
					if Sd_cmd = '1' then
						--!　需要检测数据线busy
						if Resp_type = "11" then
							resp_state_next <= RESP_WAIT_BUSY;
						else
							resp_state_next <= RESP_FINISH;
						end if;
					else
						resp_state_next <= RESP_ERRORS;
					end if;
				else
					resp_state_next <= RESP_STOP;
				end if;
			when RESP_WAIT_BUSY		=>		-- 6
				--! 超时也算完成了
				if cnt = RESP_TIMEOUT then
					resp_state_next <= RESP_FINISH;
				elsif Sd_dat(0) = '1' then
					resp_state_next <= RESP_FINISH;
				else
					resp_state_next <= RESP_WAIT_BUSY;
				end if;

			when RESP_FINISH		=>		-- 7
				resp_state_next <= RESP_IDLE;
			when RESP_ERRORS			=>	-- 8
				resp_state_next <= RESP_IDLE;
		end case;
	end process;


	U_RESP_SHIFT : process(Clk, Rst_n)
	begin
		if Clk'event and Clk = '1' then
			if Rst_n = '0' then
				resp_shift <= (others => '0');
			elsif resp_state_cur = RESP_FIRST_BIT then
				resp_shift <= (others => '0');
			elsif resp_state_cur = RESP_FIRST_BIT or resp_state_cur = RESP_SAMPLE then
				resp_shift <= resp_shift(resp_shift'length - 2 downto 0) & Sd_cmd;
			end if;
		end if;
	end process;

	U_RESP_DONE : process(Clk)
	begin
		if Clk'event and Clk = '1' then
			if resp_state_cur = RESP_ERRORS or 
				resp_state_cur = RESP_FINISH then
				Resp_done <= '1';
			else
				Resp_done <= '0';
			end if;
		end if;
	end process;

	U_RESP_ERROR : process(Clk)
	begin
		if Clk'event and Clk = '1' then
			if resp_state_cur = RESP_ERRORS then
				Resp_Error <= '1';
			else
				Resp_Error <= '0';
			end if;
		end if;
	end process;
end BEHAVOR;


