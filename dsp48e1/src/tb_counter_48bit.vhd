library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity TB_COUNTER_48BIT is
end TB_COUNTER_48BIT;


architecture BEHAVOR of TB_COUNTER_48BIT is
	component COUNTER_48BIT
	generic (
				PARTDATA 	: std_logic_vector(47 downto 0) := X"000000000100";
				MODE		:	--! '1'==> Add, '0' ==> Sub
							  std_logic
			);
	port (
			Clk  		:  	in std_logic;
			Rst_n   	:   in  std_logic;
			Load_data	:	in	std_logic_vector(47 downto 0);
			Load_en		:	in	std_logic;
			Step_data	:	in	std_logic_vector(47 downto 0);
			Cnt_out		:	out	std_logic_vector(47 downto 0)
		 );
	end component;

	signal clk : std_logic;
	signal rst :   std_logic;
	signal load_data  : std_logic_vector(47 downto 0);
	signal load_en : std_logic;
	signal step_data : std_logic_vector(47 downto 0);
	signal cnt: std_logic_vector(47 downto 0);
	signal i : std_logic_vector(4 downto 0);
begin
	U_COUNTER_48BIT : COUNTER_48BIT
	generic map(
			  		PARTDATA => X"000000001500" ,
					MODE	 => '0'
			   )
	port map(
				Clk 		=> clk,	
				Rst_n   	=>  rst,
				Load_data	=>	load_data,
				Load_en		=>	load_en,
				Step_data 	=>	step_data,
				Cnt_out		=>	cnt
			);
			
	P_RST : process
	begin
	   rst <= '1';
	   wait for 50 ns;
	   rst <= '0';

	   wait;
	end process;
	P_CLK : process
	begin
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
		wait for 5 ns;
	end process;



	P_MAIN : process(Clk, rst)
	begin
		if rst = '1' then
			i <= "00000";

		elsif clk = '1' and clk = '1' then
			case i is
				when "00000" =>
					load_data <= X"000000001000";
					step_data <= conv_std_logic_vector(1, 48);
					load_en <= '1';

					i <= i + 1;
				when "00001" =>
					load_en <= '0';
					i <= i + 1;
--				when "00010" =>
--					i <= i + 1;
--				when "00011" =>
--					i <= i + 1;
--				when "00100" =>
--					i <= i + 1;
--				when "00101" =>
--					i <= i + 1;
--				when "00110" =>
--					load_data <= X"000000100000";
--					load_en <= '1';
--					i <= i + 1;
--				when "00111" =>
--					load_en <= '0';
--					i <= i + 1;
--				when "01000" =>
--					i <= i + 1;
--				when "01001" =>
--					i <= i + 1;
				when others =>
			end case;

		end if;
	end process;

end BEHAVOR;
