----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:04:56 07/06/2016 
-- Design Name: 
-- Module Name:    uart_ax516 - Behavioral 
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
use ieee.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_ax516 is
	port(clk : in std_logic;		--50MHZ
		 rst_n : in std_logic;
		 recieve_buff : out std_logic_vector(7 downto 0);
		 transmit_buff : in std_logic_vector(7 downto 0);
		 cmd : in std_logic_vector(1 downto 0);		-- uart cmd, "10" is send, and "01" is  allow to recieve
		 txd : out std_logic;
		 rxd : in std_logic;
		 txd_done : out std_logic;
		 r_ready : out std_logic);
end uart_ax516;

architecture Behavioral of uart_ax516 is
	signal clk_div : std_logic;		--the clk after division

	type RECIEVE_STATES is (R_START, R_CENTER, R_WAIT, R_SAMPLE, R_STOP, R_COMPLETE);
	signal recieve_state : RECIEVE_STATES := R_START;

	type TRANSMIT_STATES is (X_IDLE, X_START, X_WAIT, X_SHIFT, X_STOP); 
	signal transmit_state : TRANSMIT_STATES := X_IDLE; 


begin
	process(clk, rst_n)
		constant  division : integer := 326;
		variable clk_cnt : integer range 0 to 326;
	begin
		if rst_n = '0' then
			clk_cnt := 0;
		elsif clk'event and clk = '1' then
		  	if clk_cnt = division / 2 then                                         
				clk_div <= '1';
				clk_cnt := clk_cnt + 1;
			elsif clk_cnt = division - 1 then                                          
			  	clk_div <= '0';
			   	clk_cnt := 0;                                                      
			else                                                               
				clk_cnt := clk_cnt + 1;                                                
			end if;
		end if;
	end process;


	process(clk_div, rst_n, rxd)		--recieve process
		variable bitcnt_r : integer range 0 to 10 := 0;	--recieve bit count
		variable count : std_logic_vector(4 downto 0);		--clock count
		variable recieve_buff_tmp : std_logic_vector(7 downto 0);
	begin
		if rst_n = '0' then
			recieve_buff <= "00000000";
			bitcnt_r := 0;
			count := "00000";
			recieve_state <= R_START;
		elsif clk_div'event and clk_div = '1' then
			if cmd(0) = '1' then
				case recieve_state is
					when R_START =>		--IDLE state
						if rxd = '0' then	--detect valid signal '0', but not sure  the '0' is noise or not
							r_ready <= '0';
							bitcnt_r := 0;
							count := "00000";
							recieve_state <= R_CENTER;
						else 
							recieve_state <= R_START;
							r_ready <= '0';
						end if;
					when R_CENTER =>		--make sure the signal '0' in R_START is a valid signal
						if rxd = '0' then
							if count = "00100" then	--count 4 clock time, if the signal is still 0 , the it's valid
								recieve_state <= R_WAIT;
								count := "00000";
							else 
								count := count + 1;
								recieve_state <= R_CENTER;	--less than 4 clock, continue
							end if;
						else		--the signal is noise
							recieve_state <= R_START;
						end if;
					when R_WAIT =>		--wait 15 clock, and sample at the 16th clock
						if count >= "01110" then  
							if bitcnt_r = 8 then	
								recieve_state <= R_STOP;
							else
								recieve_state  <= R_SAMPLE;
							end if;
							count := "00000";
						else 
							count := count + 1;
							recieve_state <= R_WAIT;
						end if;
					when R_SAMPLE =>		--sample data
						recieve_buff_tmp(bitcnt_r) := rxd;
						bitcnt_r := bitcnt_r + 1;
						recieve_state <= R_WAIT;		--sample one bit data complete, begin the next 16 clock time
					when R_STOP =>		--recieve STOP bit
						
						if count >= "01000" then
							count := "00000";
							recieve_state <= R_COMPLETE;
						else
							count := count + 1;
							recieve_state <= R_STOP;
						end if;
					when R_COMPLETE =>
						recieve_buff <= recieve_buff_tmp;	
						r_ready <= '1';		--set flag
						recieve_state <= R_START; 
					when others =>
						recieve_state <= R_START;
				end case;	--case cmd(0)='1'
			end if;			
		end if;	--if rst_n = '0'
	end process;	--recieve

	process(clk_div, rst_n, cmd)
		variable count : std_logic_vector(4 downto 0);		--clock count
		variable bitcnt_t: INTEGER range 0 to 8 := 0; --transmit bit count
		variable txd_tmp : std_logic;
	begin
		if rst_n = '0' then
			transmit_state <= X_IDLE;
			txd_tmp := '1';
			count := "00000";
			bitcnt_t := 0;
		elsif clk_div'event and clk_div = '1' then
			case transmit_state is
				when X_IDLE =>
					txd_done <= '0';
					count := "00000";
					bitcnt_t := 0;
					if cmd(1) = '1'  then
						transmit_state <= X_START;
					else
						transmit_state <= X_IDLE;
					end if;
				when X_START =>	-- send start bit '0', 16 clock
					if count = "01111" then
						transmit_state <= X_SHIFT; 
						count := "00000";
					else
						count := count + 1;
						txd_tmp := '0';		--start bit '0'
						transmit_state <= X_START;
					end if;
				when X_WAIT =>	--wait 15 clock time , and send data at 16th clock
					if count >= "01110" then
						if bitcnt_t = 8 then  --8 bit data send complete
							transmit_state <= X_STOP;
							bitcnt_t := 0;
							count := "00000";
						else 
							transmit_state <= X_SHIFT;
						end if;
						count := "00000";
					else		--wait until 15 clock time
						count := count + 1;
						transmit_state <= X_WAIT;
					end if;
				when X_SHIFT => --send bit
					txd_tmp := transmit_buff(bitcnt_t);
					bitcnt_t := bitcnt_t + 1;
					transmit_state <= X_WAIT;
				when X_STOP => --send stop bit 
					if count >= "01000" then
						txd_done <= '1';		
						if cmd(1) ='0' then  --use should set cmd to '0' to start another transmit
							count := "00000";
							transmit_state <= X_IDLE;
						else 				
							count := count;
							transmit_state <= X_STOP;
						end if;
					else
						count := count + 1;
						txd_tmp := '1';		
						transmit_state <= X_STOP;
					end if;
				when others =>
					transmit_state <= X_IDLE;
			end case;
		end if;
		txd <= txd_tmp;
	end process;
end Behavioral;

