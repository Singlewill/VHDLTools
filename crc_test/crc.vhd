-------------------------------------------------------------------------------
--! @file		crc.vhd
--! @function	串行crc校验计算
--!	@describe	由于是串行输入,所以只能计算高位在前的crc方式,如CRC16_XMODEM和
--!				CRC16_CCITT, 而低位在前的需要先读入一个字节，将字节高低位翻转
--!				后再进行计算，这个模块就不合适
-------------------------------------------------------------------------------
------------------------------------------------------------------------------
--!	CRC16变种举例:
--	CRC16_CCITT：多项式x16+x12+x5+1（0x1021），初始值0x0000，低位在前，高位在后，结果与0x0000异或
--	CRC16_CCITT_FALSE：多项式x16+x12+x5+1（0x1021），初始值0xFFFF，低位在后，高位在前，结果与0x0000异或
--	CRC16_XMODEM：多项式x16+x12+x5+1（0x1021），初始值0x0000，低位在后，高位在前，结果与0x0000异或	
--	CRC16_X25：多项式x16+x12+x5+1（0x1021），初始值0x0000，低位在前，高位在后，结果与0xFFFF异或
--	CRC16_MODBUS：多项式x16+x15+x5+1（0x8005），初始值0xFFFF，低位在前，高位在后，结果与0x0000异或
--	CRC16_IBM：多项式x16+x15+x5+1（0x8005），初始值0x0000，低位在前，高位在后，结果与0x0000异或
--	CRC16_MAXIM：多项式x16+x15+x5+1（0x8005），初始值0x0000，低位在前，高位在后，结果与0xFFFF异或
--	CRC16_USB：多项式x16+x15+x5+1（0x8005），初始值0xFFFF，低位在前，高位在后，结果与0xFFFF异或
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity CRC is
	generic (
			constant LENGTH		: natural;
			constant POLYNOMIAL	: std_logic_vector
			);
	port(
			Rst_n				: in  std_logic;
			Clk					: in  std_logic;
			Clear				: in  std_logic;
			Start				: in  std_logic;
			Shift_out			: in  std_logic;
			Din					: in  std_logic;
			Dout				: out std_logic
		);
end CRC;


architecture BEHAVOR of CRC is
	signal reg	: std_logic_vector(LENGTH-1 downto 0);
begin

	Dout <= reg(LENGTH-1);
	U_CALC : process(Rst_n, Clk)
	begin
		if Rst_n = '0' then
			reg <= (others => '0');
		elsif Clk'event and Clk = '1' then
			if Clear = '1' then
				reg <= (others => '0');
			elsif Start = '1' then
				if (reg(LENGTH-1) xor Din) = '1' then
					reg <= (reg(LENGTH-2 downto 0) & '0') xor POLYNOMIAL;
				else
					reg <= (reg(LENGTH-2 downto 0) & '0');
				end if;
			elsif Shift_out = '1' then
				reg <= reg(LENGTH-2 downto 0) & '0';
			end if;
		end if;
	end process;

end BEHAVOR;
