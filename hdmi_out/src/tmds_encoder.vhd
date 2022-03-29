------------------------------------------------------------------------------
--! 	@file		tmds_encoder.vhd
--! 	@function	tmds编码,严格按照HDMI1.4协议P103流程表而来
--!		@version	v2.0
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


entity TMDS_ENCODER is
	port (
			Clk		:	in	std_logic;
			D_in	:	--! 视频数据	
						in	std_logic_vector(7 downto 0);
			C_in	:	--! 控制周期数据	
						in	std_logic_vector(1 downto 0);
			C_en	:	--! 是否为控制周期或数据岛周期，此时需要输出ctl
						in	std_logic;
			Q_out	:	--! 编码输出	
						out std_logic_vector(9 downto 0)
		 );
end TMDS_ENCODER;



architecture BEHAVOR of TMDS_ENCODER  is
	--! Intermediate data
	signal q_m	:	std_logic_vector(8 downto 0);

	--! number of ones  in D_in
	signal ones_d_in	:	integer range  0 to 8;	

	--! number of ones  in  q_m
	signal ones_q_m	:	integer range  0 to 8;	

	--! number of ones  - number of zeros
	signal diff_q_m	:	integer range -8 to 8;

	signal disparity	:	integer range -16 to 15;

begin 
	--! 计算D_in中'1'的数量
	P_ONES_DIN : process(D_in) 
		variable ones: integer range 0 to 8; 
	begin
		ones := 0;
		for i in 0 to 7 loop
			if(D_in(i) = '1') then
				ones := ones + 1;
			end if;
		end loop;
		ones_d_in <= ones;
	end process;


	--! 8bit --> 9bit
	--! 见hdmi1.4, Page103页流程图
	P_DIN_XOR : process(D_in, q_m, ones_d_in)
	begin
		if(ones_d_in > 4 or (ones_d_in = 4 and D_in(0) = '0')) then
			q_m(0) <= D_in(0);
			q_m(1) <= q_m(0) xnor D_in(1);
			q_m(2) <= q_m(1) xnor D_in(2);
			q_m(3) <= q_m(2) xnor D_in(3);
			q_m(4) <= q_m(3) xnor D_in(4);
			q_m(5) <= q_m(4) xnor D_in(5);
			q_m(6) <= q_m(5) xnor D_in(6);
			q_m(7) <= q_m(6) xnor D_in(7);
			q_m(8) <= '0';
		else
			q_m(0) <= D_in(0);
			q_m(1) <= q_m(0) xor D_in(1);
			q_m(2) <= q_m(1) xor D_in(2);
			q_m(3) <= q_m(2) xor D_in(3);
			q_m(4) <= q_m(3) xor D_in(4);
			q_m(5) <= q_m(4) xor D_in(5);
			q_m(6) <= q_m(5) xor D_in(6);
			q_m(7) <= q_m(6) xor D_in(7);
			q_m(8) <= '1';
		end if;
	end process;

  	--! 计算q_m中'1'的数量
	P_ONES_QM : process(q_m)
		variable ones: integer range 0 to 8;
	begin
		ones := 0;
		for i in 0 to 7 loop
			if(q_m(i) = '1') then
				ones := ones + 1;
			end if;
		end loop;
		ones_q_m <= ones;
		--! '1'的数量 - '0'的数量
		--! 这个写法有点巧妙
		diff_q_m <= ones + ones - 8; 
	end process;

	--! 9bit --> 10 bit
	--! 同样见hdmi1.4, Page103页流程图
	P_TMDS_ENCODER : process(Clk)
	begin
		if Clk'event and Clk = '1' then
			--! 不是控制数据
			if C_en = '0' then
				--! 按照视频数据的8bit-->10bit编码走
				if disparity = 0 or ones_q_m = 4 then
					Q_out(9) <= not q_m(8);
					Q_out(8) <= q_m(8);
					if q_m(8) = '0' then
						Q_out(7 downto 0) <= not q_m(7 downto 0);
						--! 见cnt(t) = cnt(t-1)+ ((N0 {q_m[0:7]} - N1{q_m[0:7]});
						disparity <= disparity - diff_q_m;
					else
						Q_out(7 downto 0) <= q_m(7 downto 0);
						--! 见cnt(t) = cnt(t-1)+ ((N1 {q_m[0:7]} - N0{q_m[0:7]});
						disparity <= disparity + diff_q_m;
					end if;
				else
					--! 见(cnt(t-1)>0 AND (N1{q_m[0:7]} > N0{q_m[0:7]}) or
					--! (cnt(t-1)<0 AND (N0{q_m[0:7]}> N1{q_m[0:7]})
					if((disparity > 0 and ones_q_m > 4) or (disparity < 0 and ones_q_m < 4)) then
						Q_out <= '1' & q_m(8) & not q_m(7 downto 0);
						--! Cnt(t) = Cnt(t-1) + 2*q_m[8] + (N0{q_m[0:7]} - N1{q_m[0:7]});
						if(q_m(8) = '0') then
							disparity <= disparity - diff_q_m;
						else
							disparity <= disparity - diff_q_m + 2;
						end if;
					else
						Q_out <= '0' & q_m(8 downto 0);
						--! Cnt(t)= Cnt(t-1) - 2*(~q_m[8]) + (N1{q_m[0:7]} - N0{q_m[0:7]});
						if(q_m(8) = '0') then
							disparity <= disparity + diff_q_m - 2;
						else
							disparity <= disparity + diff_q_m;
						end if;
					end if;
				end if;
			--! 是控制周期数据
			else
				case C_in is
					when "00" => Q_out <= "1101010100";
					when "01" => Q_out <= "0010101011";
					when "10" => Q_out <= "0101010100";
					when "11" => Q_out <= "1010101011";
					when others => null;
				end case;
				disparity <= 0;
			end if; -- if C_en = '0' then
		end if; -- if Clk'event and Clk = '1' then
	end process;



end BEHAVOR;

