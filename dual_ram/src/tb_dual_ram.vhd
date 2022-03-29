library IEEE;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


entity TB_DUAL_RAM is
end TB_DUAL_RAM;

architecture BEHAVOR of TB_DUAL_RAM is
	component SIMPLE_DUAL_ONE_CLOCK
	generic (
			constant DATA_WIDTH	:	integer := 8;
			--! 实际fifo容量为2**ADDR_WITH
			constant ADDR_WIDTH	:	integer := 4
		);
	port(
		Clk   : in  std_logic;
		Rst_n : in 	std_logic;
		Ena   : in  std_logic;
		Enb   : in  std_logic;
		Addra : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
		Addrb : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
		Dia   : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		Dob   : out std_logic_vector(DATA_WIDTH - 1 downto 0)
	);
	end component;
	
	component blk_mem_gen_0
	  PORT (
      clka : IN STD_LOGIC;
      ena : IN STD_LOGIC;
      wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      clkb : IN STD_LOGIC;
      enb : IN STD_LOGIC;
      addrb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
    end component;
    
    component blk_mem_gen_1
  PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        clkb : IN STD_LOGIC;
        enb : IN STD_LOGIC;
        web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addrb : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        dinb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
    end component;
    


	signal clk 	:	std_logic;
	signal rst 	:	std_logic;
	signal rst_cnt 	:	std_logic;
	signal din	:	std_logic_vector(7 downto 0);
	signal din_l1	:	std_logic_vector(7 downto 0);
  signal din_valid : std_logic;
	signal din_valid_l1	:	std_logic;


	signal ena		:	std_logic;
	signal addra 	:	std_logic_vector(7 downto 0);
	signal dina		:	std_logic_vector(7 downto 0);
	signal counter	:	std_logic_vector(7 downto 0);

	signal enb		:	std_logic;
	signal addrb 	:	std_logic_vector(7 downto 0);
	signal doutb	:	std_logic_vector(7 downto 0);
	



	signal i : integer range 0 to 1023;
begin

--	U_blk_mem_gen_0 : blk_mem_gen_0 
--  PORT MAP(
--  clka  => clk,
--  ena  => ena,
--  wea  => "1",
--  addra  => addra,
--  dina  => dina,
--  clkb  => clk,
--  enb => '1',
--  addrb => addrb,
--  doutb  => doutb
--);

	U_DUAL_RAM : SIMPLE_DUAL_ONE_CLOCK
	generic map(
			  		DATA_WIDTH => 8, 
					ADDR_WIDTH	=> 8
			   )
	port map(
				Clk 	=>	clk,
				Rst_n 	=>	rst,
				Ena 	=>	ena,
				Enb		=>	'1',
				Addra 	=>	addra,
				addrb 	=>	addrb,

				Dia 	=>	dina,
				Dob 	=>	doutb
			);
	P_CLK : process
	begin
		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;
	end process;


	P_RST : process
	begin
		rst <= '0';
		wait for 100 ns;
		rst <= '1';
		wait ;
	end process;

	U_DIN : process(clk, rst)
	begin
		if Clk'event and Clk = '1' then
			if rst = '0' then
				din	<= conv_std_logic_vector(1, 8);
				din_valid <= '0';
				i <= 0;
			else
				case i is
					when 0 =>
						din	<= conv_std_logic_vector(2, 8);
						din_valid <= '1';
						i <= i + 1;
					when 1 =>
						din	<= conv_std_logic_vector(3, 8);
						i <= i + 1;
					when 2 =>
						din	<= conv_std_logic_vector(4, 8);
						i <= i + 1;
					when 3 =>
						din	<= conv_std_logic_vector(4, 8);
						i <= i + 1;
					when 4 =>
						din	<= conv_std_logic_vector(4, 8);
						i <= i + 1;
					when 5 =>
						din	<= conv_std_logic_vector(6, 8);
						i <= i + 1;
					when 6 =>
						din	<= conv_std_logic_vector(7, 8);
						din_valid <= '0';
						i <= i + 1;
					when 7 =>
						din	<= conv_std_logic_vector(8, 8);
						i <= i + 1;
					when 8 =>
						i <= i + 1;
					when others =>
				end case;
			end if;
			din_l1 <= din;
			din_valid_l1 <= din_valid;
		end if;
	end process;


	dina <= doutb + counter;
	addra	<= din_l1;
	addrb <= din;

	--! 写入
	--! 前后两次数据有效，但是数据不一致
	--! 数据即将失效
	rst_cnt <= '1' when (din_l1 /= din) or 
			   			(din_valid = '0' and din_valid_l1 = '1') else
			   '0';
	ena <= '1' when (din_valid = '1' and din_valid_l1 = '1' and din_l1 /= din) or 
			   			(din_valid = '0' and din_valid_l1 = '1') else
			   '0';

	U_CNT : process(clk)
	begin
		if Clk'event and Clk = '1' then
			if rst_cnt = '1' then
				counter <= conv_std_logic_vector(1, 8);
			else
				counter <= counter + 1;
			end if;
		end if;
	end process;





end BEHAVOR;
