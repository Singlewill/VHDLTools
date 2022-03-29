-- File name 			ll_simulate.vhd
-- Author				kalo

library IEEE;
use IEEE.std_logic_1164.all;

package ll_simulate is
	constant NUS : STRING(2 to 1) := (others => ' ');
  	function to_hstring (value : STD_LOGIC_VECTOR) return STRING;

end ll_simulate;




----------------------package body for other types--------------
package body ll_simulate is 
  ----
	function to_hstring (value : STD_LOGIC_VECTOR) return STRING is 
	constant ne     : INTEGER := (value'length+3)/4; 
	variable pad    : STD_LOGIC_VECTOR(0 to (ne*4 - value'length) - 1); 
	variable ivalue : STD_LOGIC_VECTOR(0 to ne*4 - 1); 
	variable result : STRING(1 to ne); 
	variable quad   : STD_LOGIC_VECTOR(0 to 3); 
	begin 
		if value'length < 1 then 
			return NUS; 
		else 
			if value (value'left) = 'Z' then 
				pad := (others => 'Z'); 
			else 
				pad := (others => '0'); 
			end if; 
			ivalue := pad & value; 
			for i in 0 to ne-1 loop 
				quad := To_X01Z(ivalue(4*i to 4*i+3)); 
				case quad is 
					when x"0"   => result(i+1) := '0'; 
					when x"1"   => result(i+1) := '1'; 
					when x"2"   => result(i+1) := '2'; 
					when x"3"   => result(i+1) := '3'; 
					when x"4"   => result(i+1) := '4'; 
					when x"5"   => result(i+1) := '5'; 
					when x"6"   => result(i+1) := '6'; 
					when x"7"   => result(i+1) := '7'; 
					when x"8"   => result(i+1) := '8'; 
					when x"9"   => result(i+1) := '9'; 
					when x"A"   => result(i+1) := 'A'; 
					when x"B"   => result(i+1) := 'B'; 
					when x"C"   => result(i+1) := 'C'; 
					when x"D"   => result(i+1) := 'D'; 
					when x"E"   => result(i+1) := 'E'; 
					when x"F"   => result(i+1) := 'F'; 
					when "ZZZZ" => result(i+1) := 'Z'; 
					when others => result(i+1) := 'X'; 
				end case; 
			end loop; 
			return result; 
		end if; 
	end function to_hstring;
end ll_simulate;


