library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
entity TB_CRC is
end TB_CRC;
architecture BEHAVOR of TB_CRC is
	component CRC
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
	end component;



	signal clk		:	std_logic;
	signal rst 		:	std_logic;
	signal clear	:	std_logic;


	signal crc_start	:	std_logic;
	signal crc_out	:	std_logic;
	--! crc16样例，crc16=0xD877
	--signal din	:	std_logic_vector(79 downto 0) := X"112233445566778899aa";
	--signal dout	:	std_logic_vector(15 downto 0);

	--! crc7样例, crc7 = 0x4a
	signal din	:	std_logic_vector(39 downto 0) := "0100000000000000000000000000000000000000";
	signal dout	:	std_logic_vector(6 downto 0);

	signal a : 	std_logic;
	signal b : std_logic;
	type STATES is (ONE, TWO, THREE);
	signal state : STATES;
	signal cnt : integer;

begin
	U_SD_CLK_GEN : CRC
	generic map(
				   LENGTH => 7, 
				   POLYNOMIAL=>"0001001"
			   )
	port map(
				Rst_n =>	rst,
				Clk			=>	clk,
				Clear		=>	'0',

				------------------
				Start	=>	crc_start,
				Shift_out		=>	crc_out,
				Din=>	a,
				Dout=>	b
			);

	U_CLK : process
	begin
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
		wait for 5 ns;
	end process;

	U_RST : process
	begin
		rst <= '0';
		wait for 100 ns;
		rst <= '1';
		wait;
	end process;

	U_IN : process(clk, rst)
	begin
		if rst = '0' then
			state <= ONE;
			cnt <= 0;
		elsif clk'event and clk = '1' then
			case state is
				when ONE =>
			
					if cnt = 40 then
						cnt <= 0;
						crc_start <= '0';
						state <= TWO;
					else
						--高位在前
						a <= din(39);
						din <= din(38 downto 0) & '0'; 
						cnt <= cnt + 1;
						crc_start <= '1';
						state <= ONE;
					end if;

				when TWO =>
					if cnt = 7 then
						crc_out <= '0';
						cnt <= 0;
						crc_out <= '0';
						state <= THREE;
					else
						crc_out <= '1';
						cnt <= cnt + 1;
						state <= TWO;
					end if;
					dout <= dout(5 downto 0) & b;
				when THREE =>
				end case;
		end if;
	end process;
end BEHAVOR;
