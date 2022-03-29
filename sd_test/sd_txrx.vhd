library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


use work.sd_pkt.all;

entity SD_TXRX is
	port (
			Clk			:	in	std_logic; 
			Rst_n		:	in 	std_logic;

			--! inner interface
			--Start		:	in	std_logic;
			--cmd_in		:	in	cmd_type;
			--Resp_stat	:	out	resp_stat_type;
			--Done		:	out	std_logic;
			



			--! sd interface
			Sd_clk_o		: out		std_logic;
			Sd_cmd			: inout	std_logic;
			Sd_dat			: inout	std_logic_vector(3 downto 0)
		 );
end SD_TXRX;
architecture BEHAVOR of SD_TXRX is
	component SD_CLK_GEN 
	port (
			Clk_in	:	in	std_logic ;
			Rst_n	:	in	std_logic;
			Fast	:	in	std_logic;
			Clk_out	:	out	std_logic
		 );
	end component;
	component SD_CMD_TX 
	port (
			
			Clk				:	in		std_logic;
			Clk_tick			: 	in		std_logic; 
			Rst_n			:	in 		std_logic;
			Start			:	in		std_logic;
			Fast			:	in		std_logic;
			cmd_in			:	in		cmd_type;
			Done			:	out		std_logic;
			Busy			:	out		std_logic;
			--! sd interface
			sd_cmd			: 	inout	std_logic;
			sd_dat			: 	inout	std_logic_vector(3 downto 0)
			
		 );
	end component;
	component SD_RESP_RX 
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
	end component;

	--------------------------------------------------------------------------
	--! 内部信号
	--------------------------------------------------------------------------
	--!指示输出时钟200Khz还是50Mhz
	signal fast 	:	std_logic;
	--signal cnt : 		integer range 

	signal sd_clk			:	std_logic;
	signal sd_clk_l1		:	std_logic;
	signal sd_clk_l2		:	std_logic;
	signal sd_clk_falling	:	std_logic;
	signal sd_clk_rising	:	std_logic;
	--! SD_CMD_TX相关
	signal cmd_start	:	std_logic;
	signal cmd_done		:	std_logic;
	signal cmd			:	cmd_type;
	signal cmd_busy		:	std_logic;

	--! SD_RESP_RX相关
	signal resp_type	:	std_logic_vector(1 downto 0);
	signal resp_error	:	std_logic;
	signal resp_done 	:	std_logic;

	type CMD_STATES is (SD_IDLE, SD_CMD0_UP, SD_CMD0_OFF, SD_CMD0_DONE, SD_CMD8_UP, SD_CMD8_OFF, SD_CMD8_DONE, SD_CMD_TEST);
	signal cmd_sta_cur	:	CMD_STATES;
	signal cmd_sta_next	:	CMD_STATES;


	attribute mark_debug : string;
	attribute mark_debug of cmd_sta_cur : signal is "true";
	attribute mark_debug of cmd_busy: signal is "true";
	attribute mark_debug of cmd_done: signal is "true";
	attribute mark_debug of cmd_start: signal is "true";

	attribute mark_debug of resp_done: signal is "true";
	attribute mark_debug of resp_error: signal is "true";
	attribute mark_debug of Sd_cmd : signal is "true";
	attribute mark_debug of Sd_clk_o: signal is "true";
	
	--------------------------------------------------------------------------
	--------------------------------------------------------------------------
	signal cmd0, cmd2, cmd3, cmd6, cmd7, cmd8, cmd12, cmd17, cmd18, cmd55	: CMD_TYPE;
	signal acmd6, acmd41, acmd42	: CMD_TYPE;
	-- variables used in commands
	signal rca								: std_logic_vector(15 downto 0);	-- used for all acmd commands and some other commands
	signal hcs								: std_logic;											-- set by acmd41
	signal vdd_voltage_window	: std_logic_vector(23 downto 0);	-- set by acmd41
	signal set_cd							: std_logic;											-- enable/disable internal pull-up; acmd42
	signal bus_width					: std_logic_vector(1 downto 0);	-- set by acmd6
	signal sw_mode						: std_logic;											-- mode of SWITCH_FUNC cmd6
	signal fg1								: std_logic_vector(3 downto 0);	-- function of function group 1 set by cmd6
	signal data_address_reg		:	std_logic_vector(31 downto 0);
begin
	--------------------------------------------------------------------------
	--------------------------------------------------------------------------
	Sd_clk_o <= sd_clk;
	U_CLK_EDGE : process(Clk)
	begin
		if Clk'event and Clk = '1' then
			sd_clk_l1 <= sd_clk;
			sd_clk_l2 <= sd_clk_l1;
		end if;
	end process;

	sd_clk_falling <= '1' when sd_clk_l1 = '0' and sd_clk_l2 = '1' else
					  '0';
	sd_clk_rising <= '1' when sd_clk_l1 = '1' and sd_clk_l2 = '0' else
					 '0';
	--------------------------------------------------------------------------
	--------------------------------------------------------------------------
	--"GO_IDLE_STATE"				stuff bits
	cmd0		<= (o"00", x"00000000", R0);				-- reset card to idle state
	--"ALL_SEND_CID":				stuff bits
	cmd2		<= (o"02", x"00000000", R2);				-- Ask card to send CID
	--"SEND_RELATIVE_ADDR":	stuff bits
	cmd3		<= (o"03", x"00000000", R6);				-- Ask card to publish RCA
	--"SWITCH_FUNC":		mode,	reserved bits, function group 6-2 (f= don't change), fg1
	cmd6		<= (o"06", sw_mode & "0000000" & x"fffff" & fg1, R1);
	--"SELECT/DESELECT_CARD"
	cmd7		<= (o"07", rca & x"0000", R1b);			-- Put card into transfer state
	--"SEND_IF_COND":				reserved bits, voltage supplied, check pattern
	cmd8		<= (o"10", x"00000" & x"1" & x"aa", R7);	-- send card interface condition
	--"STOP_TRANSMISSION":	stuff bits
	cmd12		<= (o"14", x"00000000", R1b);				-- Force card to stop transmission
	--"READ_SINGLE_BLOCK"
	cmd17		<= (o"21", data_address_reg, R1);				-- Read single block from card
	--"READ_MULTIPLE_BLOCK"
	cmd18		<= (o"22", data_address_reg, R1);				-- Read multiple blocks from card
	--"APP_CMD":						RCA, stuff bits
	cmd55		<= (o"67", rca & x"0000", R1);			-- next command is acmd; 
	--====================
	--"SET_BUS_WIDTH"
	acmd6		<= (o"06", o"0000000000" & bus_width, R1); -- Define data bus width
	--"SD_SEND_OP_COND":		reserved bit, HCS, reserved bits, VDD Voltage Window
	acmd41	<= (o"51", '0' & hcs & o"00" & vdd_voltage_window, R3);	-- send host support info and receive card operating condition
	--"SET_CLR_CARD_DETECT":	stuff bits & set_cd
	acmd42	<= (o"52", o"0000000000" & '0' & set_cd, R1);	-- connect[1]/disconnect[0] the 50KOhm pull-up on CD/DAT3 of SD-Card
	--------------------------------------------------------------------------
	--------------------------------------------------------------------------
	U_SD_CLK_GEN : SD_CLK_GEN
	port map(
				Clk_in		=>	Clk,
				Rst_n		=>	Rst_n,
				Fast		=>	fast,
				Clk_out		=>	sd_clk
			);
	U_SD_CMD_TX : SD_CMD_TX
	port map(
				Clk			=>	Clk,
				Clk_tick	=>	sd_clk_falling,
				Rst_n		=>	Rst_n,
				Start		=>	cmd_start,
				Fast		=>	fast,
				cmd_in		=>	cmd,
				Done		=>	cmd_done,
				Busy		=>	cmd_busy,
				sd_cmd		=>	Sd_cmd,
				sd_dat		=>	Sd_dat
			);
	resp_type <= "00" when cmd.resp = R0 else
				 "01" when cmd.resp = R2 else
				 "10" when cmd.resp = R1 or cmd.resp = R3 
				 		or cmd.resp = R6 or cmd.resp = R7 else
				 "11" when cmd.resp = R1b else
				 "ZZ";
	
	U_SD_RESP_RX : SD_RESP_RX
	port map(
				Clk			=>	Clk,
				Rst_n		=>	Rst_n,
				Clk_tick	=>	sd_clk_rising,
				Start		=>	cmd_start,
				Cmd_busy	=>	cmd_busy,

				-- response related
				-- 00: no response
				-- 01: response length 136
				-- 10: response length 48
				-- 11: response length 48 and check Busy after response
				Resp_type	=> 	resp_type,

				Resp_Error	=>	resp_error,
				Resp_done	=> 	resp_done,

				--! sd interface
				Sd_cmd		=>	Sd_cmd,
				Sd_dat		=>	Sd_dat
			);
	
	U_CNT : process(Clk, Rst_n)
	begin
		if Rst_n = '0' then
			--cnt <= 0;
		elsif Clk'event and Clk = '1' then
			if sd_clk = '1' then
				if cmd_sta_cur /= cmd_sta_next then
				--	cnt <= 0;
				else
				--	cnt <= cnt + 1;
				end if;
			end if;
		end if;
	end process;


	U_STATE : process(Clk, Rst_n)
	begin
		if Clk'event and Clk = '1' then
			if Rst_n = '0' then
				cmd_sta_cur <= SD_IDLE;
			else
				case cmd_sta_cur is
					when SD_IDLE =>	--0
						fast <= '0';
						if cmd_busy = '0' then
							cmd_sta_cur <= SD_CMD0_UP;
						else
							cmd_sta_cur <= SD_IDLE;
						end if;
					when SD_CMD0_UP => -- 1
						cmd <= cmd0;
						cmd_start <= '1';
						cmd_sta_cur <= SD_CMD0_OFF;
					when SD_CMD0_OFF =>	-- 2
						cmd_start <= '0';
						cmd_sta_cur <= SD_CMD0_DONE;
					when SD_CMD0_DONE => -- 3
						if  resp_done = '1' then
							cmd_sta_cur <= SD_CMD8_UP;
						end if;
					when SD_CMD8_UP	=>  -- 4
						cmd <= cmd8;
						cmd_start <= '1';
						cmd_sta_cur <= SD_CMD8_OFF;
					when SD_CMD8_OFF=> -- 5
						cmd_start <= '0';
						cmd_sta_cur <= SD_CMD8_DONE;
					when SD_CMD8_DONE=> -- 6
						if  resp_done = '1' then
							cmd_sta_cur <= SD_CMD_TEST;
						end if;
					when SD_CMD_TEST => -- 7
				end case;
			end if;
		end if;

	end process;

	
end BEHAVOR;
