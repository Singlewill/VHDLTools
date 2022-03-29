--! 	@file		hdmi_pkt.vhd
--! 	@author		SingleWill
--! 	@function	定义了hdmi处理中使用的一些数据类型
--!		@version	
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

package hdmi_pkt is

	type      	CTL_VECTOR   			is array (integer range <>) of std_logic_vector(1 downto 0);
	type      	TERC4_VECTOR    		is array (integer range <>) of std_logic_vector(3 downto 0);
	--type      	GUARDBAND_VECTOR    	is std_logic_vector;
	type 		PIXEL_DATA_VECTOR		is array (integer range <>) of std_logic_vector(7 downto 0);

end hdmi_pkt;
	


	----------------------package body for other types------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.ALL;
use IEEE.std_logic_arith.ALL;
package body hdmi_pkt is 

end hdmi_pkt;
