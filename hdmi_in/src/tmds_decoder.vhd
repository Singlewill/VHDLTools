------------------------------------------------------------------------------
--! 	@file		tmds_decoder.vhd
--! 	@function	tmds解码
--!					1, 包含Control Period, Data Island Period, Video Data Period
--!						数据，前二是直接查表得到
--!					2, 原始数据在此经过二级流水处理	
--! 				3, 这里的Data_valid和Terc4_valid只是个粗略的判断，精确判断还是
--!						需要看CTL周期的preamble
--!		@version	v2.0
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


entity TMDS_DECODER is
	port ( 
			Clk              : in  std_logic;
			Data_in			: in  std_logic_vector (9 downto 0);
			Symbol_valid   	: out std_logic;

			Ctl_valid        : out std_logic;
			Ctl              : out std_logic_vector (1 downto 0);

			Terc4_valid      : out std_logic;
			Terc4            : out std_logic_vector (3 downto 0);

			Guardband_valid	:	out	std_logic;	
			Guardband		:	out	std_logic;

			Data_valid       : out std_logic;
			Data_out         : out std_logic_vector (7 downto 0)
		 );
end TMDS_DECODER;

architecture BEHAVOR of TMDS_DECODER is
	signal terc4_valid_tmp	:	std_logic;
	signal terc4_tmp		:	std_logic_vector(3 downto 0);

	signal ctl_valid_tmp	:	std_logic;
	signal ctl_tmp			:	std_logic_vector(1 downto 0);

	signal guardband_valid_tmp	:	std_logic;
	--! '1' --> '1011001100',  video C0 & C2
	--! '0' --> '0100110011',  video C1 , data island C1 & C2
	signal guardband_tmp	:	std_logic;

	signal data_valid_tmp	:	std_logic := '0';
	--! 根据Data_in bit9决定是否反转
	signal sometimes_inverted	:	std_logic_vector(8 downto 0);

begin

	--! 数据入口第一个时钟
	DECODE_CTL_FIRST:  process(Clk)
	begin
		if Clk'event and Clk = '1' then
			terc4_valid_tmp <= '0';
			ctl_valid_tmp 	<= '0';
			data_valid_tmp 	<= '0';
			guardband_valid_tmp	<= '0';

			---------------------------------------------------------------------------
			case Data_in is
				--! 四个CTL周期编码
				when "1101010100"	=>
					ctl_tmp <= "00";
					ctl_valid_tmp <= '1';
				when "0010101011"	=>
					ctl_tmp <= "01";
					ctl_valid_tmp <= '1';
				when "0101010100" 	=>
					ctl_tmp <= "10";
					ctl_valid_tmp <= '1';
				when "1010101011" 	=>
					ctl_tmp <= "11";
					ctl_valid_tmp <= '1';


				--! GUARDBAND 0
				when "0100110011"	=>
					guardband_valid_tmp	<= '1';
					guardband_tmp		<= '0';

				--! 16个Data Island 周期编码
				when "1010011100"	=>
					terc4_tmp 		<= "0000";
					terc4_valid_tmp <= '1';
				when "1001100011"	=>
					terc4_tmp 		<= "0001";
					terc4_valid_tmp <= '1';
				when "1011100100"	=>
					terc4_tmp 		<= "0010";
					terc4_valid_tmp <= '1';
				when "1011100010"	=>
					terc4_tmp 		<= "0011";
					terc4_valid_tmp <= '1';
				when "0101110001"	=>
					terc4_tmp 		<= "0100";
					terc4_valid_tmp <= '1';
				when "0100011110"	=>
					terc4_tmp 		<= "0101";
					terc4_valid_tmp <= '1';
				when "0110001110"	=>
					terc4_tmp 		<= "0110";
					terc4_valid_tmp <= '1';
				when "0100111100"	=>
					terc4_tmp 		<= "0111";
					terc4_valid_tmp <= '1';
				--! TERC4 + GUARDBAND 1
				when "1011001100"	=>
					guardband_valid_tmp	<= '1';
					guardband_tmp		<= '1';
					terc4_tmp 		<= "1000";
					terc4_valid_tmp <= '1';
				when "0100111001"	=>
					terc4_tmp 		<= "1001";
					terc4_valid_tmp <= '1';
				when "0110011100"	=>
					terc4_tmp 		<= "1010";
					terc4_valid_tmp <= '1';
				when "1011000110"	=>
					terc4_tmp 		<= "1011";
					terc4_valid_tmp <= '1';
				when "1010001110"	=>
					terc4_tmp 		<= "1100";
					terc4_valid_tmp <= '1';
				when "1001110001"	=>
					terc4_tmp 		<= "1101";
					terc4_valid_tmp <= '1';
				when "0101100011"	=>
					terc4_tmp 		<= "1110";
					terc4_valid_tmp <= '1';
				when "1011000011"	=>
					terc4_tmp 		<= "1111";
					terc4_valid_tmp <= '1';


				--! 剩下的就是Video data
				when others 	=>
					data_valid_tmp <= '1';
					
					if Data_in(9) = '1'then
						sometimes_inverted <=  Data_in(8 downto 0) xor "011111111";
					else
						sometimes_inverted <= Data_in(8 downto 0);
					end if;
			end case;
		end if; -- if Clk'event and Clk = '1' then
	end process;



	--! 数据进入第二个周期
	DECODE_CTL_SECOND : process(Clk)
	begin

		if Clk'event and Clk = '1' then
			Terc4_valid 	<= terc4_valid_tmp;
			Ctl_valid		<= ctl_valid_tmp;
			Data_valid  	<= data_valid_tmp;
			Guardband_valid	<=  guardband_valid_tmp;


			Terc4 			<= terc4_tmp;
			Ctl 			<= ctl_tmp;
			Guardband		<= guardband_tmp;

			--! 这里判断data_valid_tmp 好像无所谓
			--if data_valid_tmp = '1' then
				if sometimes_inverted(8) = '1' then
					Data_out(0) <= sometimes_inverted(0);
					Data_out(1) <= sometimes_inverted(1)  xor sometimes_inverted(0);
					Data_out(2) <= sometimes_inverted(2)  xor sometimes_inverted(1);
					Data_out(3) <= sometimes_inverted(3)  xor sometimes_inverted(2);
					Data_out(4) <= sometimes_inverted(4)  xor sometimes_inverted(3);
					Data_out(5) <= sometimes_inverted(5)  xor sometimes_inverted(4);
					Data_out(6) <= sometimes_inverted(6)  xor sometimes_inverted(5);
					Data_out(7) <= sometimes_inverted(7)  xor sometimes_inverted(6);
				else
					Data_out(0) <= sometimes_inverted(0);
					Data_out(1) <= sometimes_inverted(1)  xnor sometimes_inverted(0);
					Data_out(2) <= sometimes_inverted(2)  xnor sometimes_inverted(1);
					Data_out(3) <= sometimes_inverted(3)  xnor sometimes_inverted(2);
					Data_out(4) <= sometimes_inverted(4)  xnor sometimes_inverted(3);
					Data_out(5) <= sometimes_inverted(5)  xnor sometimes_inverted(4);
					Data_out(6) <= sometimes_inverted(6)  xnor sometimes_inverted(5);
					Data_out(7) <= sometimes_inverted(7)  xnor sometimes_inverted(6);
				end if; -- Data_out(0) <=  sometimes_inverted(0);
			--end if;	-- if data_valid_tmp = '1' then
		end if;	-- if Clk'event and Clk = '1' then
	end process;	


	U_SYMBOL_VALID : process(Clk)
	begin
		if Clk'event and Clk = '1' then
			if Data_in = "1101010100" or Data_in = "0010101011" then
				Symbol_valid <= '1';
			else
				Symbol_valid <= '0';
			end if;
		end if;
	end process;

end BEHAVOR;

