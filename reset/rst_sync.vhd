--Filename		:	rst_sync.vhd
--Author   		: 	Kalo
--Description	:	Asynchronously reset, and release synchronously
--Called by	 	: 	Top module

library IEEE;
use IEEE.std_logic_1164.all;

entity RST_SYNC is  
	port(
		 Clk			: in std_logic;
		 Rst_async		: in std_logic;
		 Rst_sync	 	: out std_logic
		);
end RST_SYNC;

architecture BEHAVIOR of RST_SYNC is 
	signal reg_L1 : std_logic;		--对复位输入信号Rst_async一级锁存
	signal reg_L2 : std_logic;		--对复位输入信号Rst_async二级锁存
begin
	Rst_sync <= reg_L2;			--reset signal out

	Main : process(Clk, Rst_async)
	begin
		if (Rst_async = '0') then
			reg_L1 <= '0';
			reg_L2 <= '0';
		elsif (Clk'event and Clk = '1') then
			reg_L1 <= '1';
			reg_L2 <= reg_L1;
		end if;
	end process;
end BEHAVIOR;
