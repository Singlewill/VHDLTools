------------------------------------------------------------------------------
--! 	@file		extract_video_info.vhd
--! 	@function	1, 检测AVI InfoFrame Packet,并从中提取相关像素信息
--!					2, Input_is_sRGB 用处不明...
--!		@version	
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity EXTRACT_AVI_INFOFRAME is
	port ( 
			 Clk                 : in std_logic;
			 Adp_data_valid      : in std_logic;
			 Adp_header_bit      : in std_logic;
			 Adp_frame_bit       : in std_logic;
			 Adp_subpacket0_bits : in std_logic_vector (1 downto 0);
			 Input_is_ycbcr      : out std_logic;
			 Input_is_422        : out std_logic;
			 Input_is_srgb       : out std_logic
	   );
end EXTRACT_AVI_INFOFRAME;

architecture Behavioral of EXTRACT_AVI_INFOFRAME is
	--! 只取16个时钟周期, 这里的数据已经够用
	signal header_bits     : STD_LOGIC_VECTOR (15 downto 0);
	signal frame_bits      : STD_LOGIC_VECTOR (15 downto 0);
	signal subpacket0_bits : STD_LOGIC_VECTOR (31 downto 0);
	signal clk_cnt			:	std_logic_vector(4 downto 0);
begin

	process(Ｃlk)
	begin
		if Clk'event and Clk = '1' then
			if Adp_data_valid = '1' then
				-----------------------------------------------
				--! 数据移位
				-----------------------------------------------
				header_bits     <= Adp_header_bit      & header_bits(header_bits'high downto 1);
				frame_bits      <= Adp_frame_bit       & frame_bits(frame_bits'high   downto 1);
				subpacket0_bits <= Adp_subpacket0_bits & subpacket0_bits(subpacket0_bits'high downto 2);

				clk_cnt <= clk_cnt + 1;
			else 
				header_bits		<= (others => '0');
				frame_bits 		<= (others => '0');
				subpacket0_bits <= (others => '0');

				clk_cnt <= (others => '0');
			end if;

			----------------------------------------------------
			--! 这里只取前16个时钟周期，subpacket0已经有32bit,够用了
			----------------------------------------------------
			if clk_cnt = "01111" and frame_bits = x"FFFE" then
				--! Packet Type = 0x82 Version = 0x02
				--! AVI InfoFrame Packet Header
				--! 见HDMI1.4 Page135
				if header_bits = x"0282" then
					--! Y1 Y0
					--! "00" --> RGB
					--! "01" --> YCbCr 422
					--! "10" --> YCbCr 444
					--! "11" -->Future
					--! 见CEA861-D, Page66
					case subpacket0_bits(14 downto 13) is
						when "00"   => Input_is_YCbCr <= '0'; Input_is_422 <= '0';
						when "01"   => Input_is_YCbCr <= '1'; Input_is_422 <= '1';
						when "10"   => Input_is_YCbCr <= '1'; Input_is_422 <= '0';
						when others => NULL;
					end case; 

					--！Q1 Q0
					--! "00" --> default
					--! "01" -->limited range
					--! "10" --> Full range
					--! "11" -->Revered
					--! 见CEA861-D, Page69
					case subpacket0_bits(27 downto 26) is
						when "01"   => Input_is_sRGB <= '1';
						when others => Input_is_sRGB <= '0';
					end case; 

				end if;
			end if; 
		end if;
	end process;

end Behavioral;
