--Filename		: ll_pkt.vhd
--Author		: kalo
--Description	: something for my own use


library IEEE;
use IEEE.std_logic_1164.all;

package ll_pkt is

	-- A component for reset signal sync output
	component RST_SYNC		
	port (
			Clk		: in std_logic;
			R_async	: in std_logic;
			R_sync	: out std_logic
		);
	end component;
end ll_pkt;
	

--------------------RST_SYNC----------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity RST_SYNC is 
	port(
			Clk		: in std_logic;
			R_async	: in std_logic;
			R_sync	: out std_logic
		);
end RST_SYNC;

architecture BEHAVIOR of RST_SYNC is 
	signal reg_L1 : std_logic;		--latch async reset signal level 1	
	signal reg_L2 : std_logic;		--latch async reset signal level 2
begin
	R_sync <= reg_L2;			--reset signal out

	Main : process(Clk, R_async)
	begin
		if (R_async = '0') then
			reg_L1 <= '0';
			reg_L2 <= '0';
		elsif (Clk'event and Clk = '1') then
			reg_L1 <= '1';
			reg_L2 <= reg_L1;
		end if;
	end process;
end BEHAVIOR;
---------------------------------------------------------------


----------------------package body for other types--------------
package body ll_pkt is 
	----
end ll_pkt;
