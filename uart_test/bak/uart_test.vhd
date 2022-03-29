----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:44:47 07/06/2016 
-- Design Name: 
-- Module Name:    uart_test - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_test is
	port(clk : in std_logic;
		 rst_n : in std_logic;
		 key : in std_logic;
 		 txd : out std_logic;
		 rxd : in std_logic);
end uart_test;

architecture Behavioral of uart_test is
	type array_type is array (23 downto 0) of std_logic_vector(7 downto 0);
	signal data : array_type;		--declare the data to be send 
	signal recieve_buff : std_logic_vector(7 downto 0);
	signal transmit_buff : std_logic_vector(7 downto 0);
	signal cmd : std_logic_vector(1 downto 0);
	signal txd_done : std_logic;
	signal r_ready : std_logic;

	type uart_states is (IDLE, SEND, WAIT_OVER, STOP);
	signal state : uart_states := IDLE;
	signal haha : std_logic_vector(3 downto 0);
	signal CONTROL0: std_logic_vector(35 downto 0);
	signal TRIG0: std_logic_vector(255 downto 0);

	component uart_ax516 is
	port(clk : in std_logic;		--50MHZ
		 rst_n : in std_logic;
		 recieve_buff : out std_logic_vector(7 downto 0);
		 transmit_buff : in std_logic_vector(7 downto 0);
		 cmd : in std_logic_vector(1 downto 0);		-- uart cmd, bit 1 is send, and bit 0  is  allow to recieve
		 txd : out std_logic;
		 rxd : in std_logic;
		 txd_done : out std_logic;
		 r_ready : out std_logic);
	end component;

	component chipscope_icon
	port(CONTROL0: inout std_logic_vector(35 downto 0));
	end component;
	
	component chipscope_ila
	port (
		CONTROL: inout std_logic_vector(35 downto 0);
		CLK: in std_logic;
		TRIG0: in std_logic_vector(255 downto 0));
	end component;
begin
	data(0) <= "01001000";		-- "H" 0x48
	data(1) <= "01000101";		-- "E" 0x45
	data(2) <= "01001100";		-- "L" 0x4C
	data(3) <= "01001100";		-- "L" 0x4C
	data(4) <= "01001111";		-- "O" 0x4F
	
	data(5) <= "00100000";		-- " " 0x20
	data(6) <= "00100000";		-- " " 0x20
	data(7) <= "00100001";		-- "!" 0x21
	data(8) <= "00100001";		-- "!" 0x21
	data(9) <= "00001010";		-- "\r" 0x0a
	data(10) <= "00001101";		-- "\n" 0x0d
	
	U1 : uart_ax516 port map(clk => clk,
							rst_n => rst_n,
							recieve_buff => recieve_buff,
							transmit_buff=> transmit_buff,
							cmd => cmd,
							txd => txd,
							rxd => rxd,
							txd_done => txd_done,
							r_ready => r_ready
							);

	process(clk, rst_n)			--in the beginning, send "hello"
	variable cnt : integer range 0 to 20 := 0;
	begin
		if rst_n = '0' then
			cnt := 0;
			cmd <= "01"; 	--enable uart recieve
			state <= IDLE;
		elsif clk'event and clk = '1' then
			case state is
				when IDLE =>
					cnt := 0;
					state <= SEND;
				when SEND =>
					if txd_done = '0' then
						transmit_buff <= data(cnt);
						cnt := cnt + 1;
						cmd(1) <= '1'; 	--send cmd
						state <= WAIT_OVER;
					else
						state <= SEND;
					end if;
				when WAIT_OVER=>
					if txd_done = '1' then
						cmd(1) <= '0';
						if cnt = 11 then
							state <= STOP;
						else
							state <= SEND;
						end if;
					else
						state <= WAIT_OVER;
					end if;
				when STOP =>
					if r_ready = '1' then
						transmit_buff <= recieve_buff;
					end if;
					cmd(1) <= r_ready;
					
			end case;
		end if;
	end process;
	
--	cmd(0) <= '1';
--	process(clk)
--		variable cnt : integer range 0 to 2048;
--	begin
--		if rst_n = '0' then
--			state <= IDLE;
--		elsif clk'event and clk = '1' then
--			case state is
--				when IDLE =>
--					haha <= "0010";
--					if r_ready = '1' and txd_done = '0' then
--						state <= WAIT_OVER;
----					elsif r_ready = '1' then
----						state <= SEND;
--					else
--						state <= IDLE;
--					end if;
--				when SEND =>
--					haha <= "0011";
--					if txd_done = '0' then
--						state <= WAIT_OVER;
--					else
--						state <= SEND;
--					end if;
--				when WAIT_OVER =>
--					haha <= "0100";
--					transmit_buff <= recieve_buff;
--					cmd(1) <= '1';
--					state <= STOP;
--				when STOP =>
--					haha <= "0101";
--					if txd_done = '1' then
--						cmd(1) <= '0';
--						state <= IDLE;
--					else
--						state <= STOP;
--					end if;
--			end case;
--		end if;
--	end process;



	U2 : chipscope_icon port map (CONTROL0 => CONTROL0);
	U3 : chipscope_ila port map (CONTROL => CONTROL0, CLK => clk, TRIG0 => TRIG0);
	
	TRIG0(7 downto 0) <= recieve_buff;
	TRIG0(15 downto 8) <= transmit_buff;
	TRIG0(17 downto 16) <= cmd;
	TRIG0(18) <= r_ready;
	TRIG0(19) <= txd_done;
	TRIG0(23 downto 20) <= haha;
end Behavioral;

