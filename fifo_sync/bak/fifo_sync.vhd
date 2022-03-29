-------------------------------------------------------------------------------
--!		同步fifo
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
entity FIFO_SYNC is
	generic (
			constant DATA_WITH	:	integer := 16;
			--! 实际fifo容量为2**ADDR_WITH
			constant ADDR_WITH	:	integer := 10
		);
	port (
			Clk				:	in	std_logic;
			Rst_n			:	in	std_logic;
			--! 写入侧
			Wr_en			:	in	std_logic;
			Din				:	in	std_logic_vector(DATA_WITH - 1 downto 0);
			Full			:	out	std_logic;
			Almost_full		:	out	std_logic;
			
			--! 读出侧
			Rd_en			:	in	std_logic;
			Dout			:	out	std_logic_vector(DATA_WITH - 1 downto 0);
			Empty			:	out	std_logic;
			Almost_empty	:	out	std_logic;
			Valid			:	out	std_logic
		 );

end FIFO_SYNC;

architecture BEHAVOR of FIFO_SYNC is

	component SIMPLE_DUAL_ONE_CLOCK is
	generic (
			constant DATA_WITH	:	integer := 16;
			--! 实际fifo容量为2**ADDR_WITH
			constant ADDR_WITH	:	integer := 10
		);
	port(
		clk   : in  std_logic;
		ena   : in  std_logic;
		enb   : in  std_logic;
		addra : in  std_logic_vector(ADDR_WITH - 1 downto 0);
		addrb : in  std_logic_vector(ADDR_WITH - 1 downto 0);
		dia   : in  std_logic_vector(DATA_WITH - 1 downto 0);
		dob   : out std_logic_vector(DATA_WITH - 1 downto 0)
	);
	end component;
	
	--! 读指针, 当前读指针，读指针+1, 读指针下一次的更新指针
	signal wp 			: std_logic_vector(ADDR_WITH - 1 downto 0);
	signal wp_suc 		: std_logic_vector(ADDR_WITH - 1 downto 0);
	signal wp_next 		: std_logic_vector(ADDR_WITH - 1 downto 0);

	signal rp 			: std_logic_vector(ADDR_WITH - 1 downto 0);
	signal rp_suc 		: std_logic_vector(ADDR_WITH - 1 downto 0);
	signal rp_next 		: std_logic_vector(ADDR_WITH - 1 downto 0);

	signal full_reg		: std_logic;
	signal full_next 	: std_logic;
	signal empty_reg 	: std_logic;
	signal empty_next 	: std_logic;

	--! 接受命令的组合
	signal operation  	: std_logic_vector(1 downto 0);

	--! wr_en和not full的组合,防止写溢出
	signal wr_allow    	:   std_logic;	


	--! 输入输出寄存
	signal rDout 		:	std_logic_vector(DATA_WITH - 1 downto 0);
	signal rValid		:	std_logic;
	
begin
	U_RAM : SIMPLE_DUAL_ONE_CLOCK
    generic map(DATA_WITH => DATA_WITH,
              ADDR_WITH => ADDR_WITH)
	port map(
				clk   	=>	clk,
				ena   	=>	wr_allow,
				enb   	=>	rd_en,
				addra 	=>	wp,
				addrb 	=>	rp,
				dia   	=>	Din,
				dob   	=>	rDout
			
			);

	--! 时序逻辑
	U_TIME_UP : process(Clk, Rst_n)
	begin
		if Clk'event and Clk = '1' then
			if Rst_n = '0' then
				wp <= (others => '0');
				rp <= (others => '0');
				full_reg <=	'0';
				empty_reg <= '1';
				
			else

				wp <= wp_next;
				rp <= rp_next;
				full_reg <= full_next;
				empty_reg <= empty_next;
			end if;
		end if;
	end process;

	wr_allow <= wr_en and (not full_reg);
	rp_suc <= rp + 1;
	wp_suc <= wp + 1;
	operation <= wr_en & rd_en;

	--! 组合逻辑状态转移
	U_STATE : process(wp, wp_suc, rp, rp_suc, operation, full_reg, empty_reg)
	begin
		--! 如果没有操作, A_next <= A
		wp_next <= wp;
		rp_next <= rp;
		full_next	<=	full_reg;
		empty_next <= empty_reg;
		case operation is
			when "00" =>
			--! 仅read
			when "01" =>
				--! 非空
				if empty_reg = '0' then
					--! 置数据有效
					rp_next <= rp_suc;
					--! 既然读走一个数，后一个状态一定非满
					full_next <= '0';
					--! 下一个读地址与写地址重合，则空
					if rp_suc = wp then
						empty_next <= '1';
					end if;
				end if;
			--! 仅write
			when "10" =>
				--! 不满
				if full_reg = '0' then
					wp_next <= wp_suc;
					--! 既然写了一个数，一定非空了
					empty_next <= '0';
					if wp_suc = rp then
						full_next <= '1';
					end if;
				end if;

			--! 同时读写
			when "11" =>
				wp_next <= wp_suc;
				rp_next <= rp_suc;
			when others => 
		end case;
	end process;

	U_OVALID : process(Clk, Rst_n)
	begin
		if Clk'event and Clk = '1' then
			if Rst_n = '0' then
				rValid <= '0';
			else
				rValid <= rd_en;
			end if;
		end if;
	end process;
	



	--! 输出
	Dout <= rDout;
	Valid <= rValid;
	Empty <= empty_reg;
	Full	<= full_reg;
	Almost_full <= full_next;
	Almost_empty <= empty_next;

end BEHAVOR;
