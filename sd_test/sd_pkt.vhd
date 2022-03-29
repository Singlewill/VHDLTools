library IEEE;
use IEEE.std_logic_1164.all;
package SD_PKT is
-- polynomial and length for crc7 and crc16 chechsum
constant crc7_pol		: std_logic_vector := "0001001";
constant crc7_len		: natural := 7;
constant crc16_pol	: std_logic_vector := "0001000000100001";
constant crc16_len	: natural := 16;
type RESP_TYPE is (R0, R1, R1b, R2, R3, R6, R7); --R0: No response (CMD0)
------------------
type CMD_TYPE is record
	index	: std_logic_vector(5 downto 0);
	arg		: std_logic_vector(31 downto 0);
	resp	: RESP_TYPE;
end record CMD_TYPE;
-- response status
subtype resp_stat_type is std_ulogic_vector(3 downto 0);
constant resp_stat_valid	: resp_stat_type := (others=>'0');
------------------
-- according bit is set to '1'
constant e_timeout	: natural := 0; -- no response received
constant e_crc			: natural := 1; -- crc of response is wrong
constant e_common		: natural := 2; -- some well-known bits are wrong
constant e_busy			: natural := 3; -- busy timeout: card is still busy
--constant e_unknown	: natural := 4; -- unknow error (invalid program path was taken)
end SD_PKT;
