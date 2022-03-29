library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity TB_DIV is
end TB_DIV;
architecture BEHAVOR of TB_DIV is
	--! vivado除法IP核位数说明 : 
	--! divident(被除数, X位)和divisor(除数Y位)都要8bit对齐
	--! 结果应该是X+Y位，高X位为商，低Y位为余数
	component div_gen 
	port (
			 aclk : in std_logic;
			 s_axis_divisor_tvalid : in std_logic;
			 s_axis_divisor_tdata : in std_logic_vector(7 downto 0);
			 s_axis_dividend_tvalid : in std_logic;
			 s_axis_dividend_tdata : in std_logic_vector(15 downto 0);
			 m_axis_dout_tvalid : out std_logic;
			 m_axis_dout_tdata : out std_logic_vector(23 downto 0)
		 );
	end component;

	signal clk : std_logic;
	signal rst_n : std_logic;

	--! 除数
	signal divisor_valid : std_logic;
	signal divisor_data : std_logic_vector(7 downto 0);
	--! 被除数
	signal divident_valid : std_logic;
	signal divident_data : std_logic_vector(15 downto 0);

	signal dout_valid : std_logic;
	signal dout_data : std_logic_vector(23 downto 0);

	signal i : std_logic_vector(3 downto 0);

begin
	U_CLK : process
	begin
		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;
	end process;

	U_RST : process
	begin
		rst_n <= '0';
		wait for 50 ns;
		rst_n <= '1';
		wait;
	end process;

	U_DIV : div_gen
	port  map(
			 
				 aclk 					=> clk,
				 s_axis_divisor_tvalid 	=> divisor_valid,
				 s_axis_divisor_tdata 	=> divisor_data,
				 s_axis_dividend_tvalid => divident_valid,
				 s_axis_dividend_tdata 	=> divident_data,
				 m_axis_dout_tvalid 	=> dout_valid,
				 m_axis_dout_tdata 		=> dout_data
			 );

	U_MAIN : process(clk, rst_n)
	begin
		if clk'event and clk = '1' then
			if rst_n = '0' then
				i <= (others => '0');
			else
				case i is
					when "0000" =>
						divisor_valid <= '0';
						divident_valid <= '0';
						i <= i + 1;
					when "0001" =>
						divisor_data <= conv_std_logic_vector(3, 8);
						divident_data <= conv_std_logic_vector(10, 16);
						divisor_valid <= '1';
						divident_valid <= '1';
						i <= i + 1;
					when "0010" =>
						divisor_valid <= '0';
						divident_valid <= '0';
						i <= i + 1;
					when "0011" =>
						i <= i + 1;
					when "0100" =>
						i <= i + 1;
					when others =>
				end case;
			end if;

		end if;
	end process;


end BEHAVOR;
