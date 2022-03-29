library IEEE; 
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity TMDS_DECODER is 
    port (
        Clk        :    in    std_logic;
        Symbol    :    in    std_logic_vector(9 downto 0);
        Data    :    out    std_logic_vector(7 downto 0)
     );
end TMDS_DECODER;


architecture BEHAVOR of TMDS_DECODER is
	signal reverse		:	std_logic;
	--! flag = 1 indicate XOR
	--! flag = 0 indicate XNOR
	signal flag			:	std_logic;
	signal data_tmp 	:	std_logic_vector(7 downto 0);
begin
	reverse <= 	Symbol(9);
	flag	<=	Symbol(8);

	U_MAIN : process(Clk)
	begin
		if Clk'event and clk = '1' then
			if reverse = '0' then
				data_tmp <= Symbol(7 downto 0);
			else
				data_tmp <= not Symbol(7 downto 0);
			end if;
		end if;
	end process;

	Data(0) <= data_tmp(0);
	Data(1) <= data_tmp(1) xor data_tmp(0) 	when flag = '1' else
			   data_tmp(1) xnor data_tmp(0);
	Data(2) <= data_tmp(2) xor data_tmp(1) 	when flag = '1' else
			   data_tmp(2) xnor data_tmp(1);
	Data(3) <= data_tmp(3) xor data_tmp(2) 	when flag = '1' else
			   data_tmp(3) xnor data_tmp(2);
	Data(4) <= data_tmp(4) xor data_tmp(3) 	when flag = '1' else
			   data_tmp(4) xnor data_tmp(3);
	Data(5) <= data_tmp(5) xor data_tmp(4) 	when flag = '1' else
			   data_tmp(5) xnor data_tmp(4);
	Data(6) <= data_tmp(6) xor data_tmp(5) 	when flag = '1' else
			   data_tmp(6) xnor data_tmp(5);
	Data(7) <= data_tmp(7) xor data_tmp(6) 	when flag = '1' else
			   data_tmp(7) xnor data_tmp(6);
end BEHAVOR;

