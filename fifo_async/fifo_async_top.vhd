library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;


entity FIFO_ASYNC_TOP is
	port (
			Clk		:	in	std_logic; 
			Rst_n	:	in	std_logic;
			Din		:	in	std_logic_vector(7 downto 0);
			Wr		:	in	std_logic;
		
			Dout	:	out 	std_logic_vector(7 downto 0);
			Rd		:	in std_logic
		 );
end FIFO_ASYNC_TOP;

architecture BEHAVOR of FIFO_ASYNC_TOP is
	component FIFO_ASYNC
	generic (
			constant DATA_WIDTH	:	integer := 8;
			constant ADDR_WIDTH	:	integer := 4
		);
	port (
			Rst_n			:	in	std_logic;
			--! 写入侧
			Clk_wr			:	in	std_logic;
			Wr_en            :   in  std_logic;
			Din				:	in	std_logic_vector(DATA_WIDTH - 1 downto 0);
			Full			:	out	std_logic;
			Almost_full		:	out std_logic;

			--! 读出侧
			Clk_rd			:	in	std_logic;
			Rd_en        :   in  std_logic;
			Dout			:	out	std_logic_vector(DATA_WIDTH - 1 downto 0);
			Empty			:	out std_logic;
			Almost_empty	:	out std_logic;
			Valid			:	out std_logic
		 );
	end component;


	signal clk_wr 		:	std_logic;
	signal wr_en       :   std_logic;
	signal rd_en       :   std_logic;
	signal rst			:	std_logic;
	signal almost_full 	:	std_logic;
	signal almost_empty	:	std_logic;
	signal full 		:	std_logic;
	signal empty		:	std_logic;
	signal valid		:	std_logic;

	signal clk2 : std_logic;
begin

	U_CLK2 : process(Clk, Rst_n)
 	begin
		if Clk'event and Clk = '1' then
			if Rst_n = '0' then
				clk2 <= '0';
			else
				clk2 <= not clk2;
			end if;
		end if;
 	end process;

	U_FIFO : FIFO_ASYNC
	generic map(DATA_WIDTH => 8,
			   	ADDR_WIDTH	=> 3)
	port map(
			Rst_n			=>	Rst_n,	
			Clk_wr			=>	clk,
			Wr_en            =>  wr_en,
			Din				=>	Din,
			Almost_full =>	full,

			Clk_rd			=> 	clk2,
			Rd_en        =>  rd_en,
			Dout			=>	Dout,
			Almost_empty =>  empty,
			Valid			=>	valid
	
	);
	U_1 : process(clk, Rst_n)
	begin
		if clk'event and clk = '1' then
			if Wr = '1' and full = '0' then
				wr_en <= '1';
			else
				wr_en <= '0';
			end if;
		end if;
	end process;

	U_2 : process(clk2, Rst_n)
	begin
		if clk2'event and clk2 = '1' then
			if Rd = '1' and empty = '0' then
				rd_en <= '1';
			else
				rd_en <= '0';
			end if;
		end if;
	end process;

end BEHAVOR;
