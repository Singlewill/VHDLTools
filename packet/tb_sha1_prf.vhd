-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  use IEEE.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;
  USE ieee.numeric_std.ALL;

  use ieee.std_logic_textio.all;
  --USE ieee.fixed_generic_pkg.all;
 library std;
   use std.textio.all;

  use work.sha1_pkt.all;

  ENTITY TB_SHA1_PRF IS
  END TB_SHA1_PRF;

  ARCHITECTURE behavior OF TB_SHA1_PRF IS 

  -- Component Declaration
          COMPONENT SHA1_PRF
          PORT(
				Clk			:	in	std_logic;	
				Rst_n		:	in	std_logic;
				Start		:	in	std_logic;
				
				Pmk			:	--! @brief 32Bytes输入
								in	std_logic_vector(255 downto 0);
				Nonce_min	:	--! @brief Noce中小的一个,32 Bytes
								in	std_logic_vector(255 downto 0);
				Nonce_max	:	--! @brief Noce中大的一个,32 Bytes
								in	std_logic_vector(255 downto 0);
				Mac_min		:	--! @brief MAC中小的一个,6 Bytes
								in	std_logic_vector(47 downto 0);
				Mac_max		:	--! @brief Noce中大的一个,6 Bytes
								in	std_logic_vector(47 downto 0);
				Done		: 	out std_logic;
				Kck			:	out KCK_DATA;
				Kek			:	out KEK_DATA;
				Tk			:	out TK_DATA
                  );
          END COMPONENT;


          SIGNAL Clk :  std_logic;
          SIGNAL Rst_n:  std_logic;
		   -- Clock period definitions
		   constant Clk_period : time := 10 ns;


		  -- input 
          SIGNAL start :  std_logic;
		  signal pmk : std_logic_vector(255 downto 0) := X"992194d7a6158009bfa25773108291642f28a0c32a31ab2556a15dee97ef0dbb";
          SIGNAL  nonce_min:  std_logic_vector(255 downto 0) := X"f5b4d6d2a4b5da5069404a07281e40f3079de18bf3a1ce8674345e5a8694cb5f";
          SIGNAL  nonce_max:  std_logic_vector(255 downto 0) := X"5fb9c7d407f764584e2a7725966076c4325be675032f65a579404e2af283d0a5";
		  signal mac_min : std_logic_vector(47 downto 0)  := X"803773f913e0";
		  signal mac_max : std_logic_vector(47 downto 0)  := X"c0ccf8f4231d";

		  -- output 
		  signal done : std_logic;
		  signal kck : KCK_DATA := (others => '0');
		  signal kek : KEK_DATA := (others => '0');
		  signal tk : 	TK_DATA := (others => '0');
		  
		
		  
		  signal ll_hah : std_logic_vector(127 downto 0);
			 
			 
  BEGIN

          uut:SHA1_PRF PORT MAP(
				Clk			=> CLk,	
				Rst_n		=> Rst_n,
				Start		=> start,
				Pmk			=> pmk,
				Nonce_min	=> nonce_min,
				Nonce_max	=> nonce_max,
				Mac_min		=> mac_min,
				Mac_max		=> mac_max,
				Done		=> done,
				Kck			=> kck,
				Kek			=> kek,
				Tk			=> tk
          );

	   -- Clock process definitions
	   Clk_process :process
	   begin
			Clk <= '0';
			wait for Clk_period/2;
			Clk <= '1';
			wait for Clk_period/2;
	   end process;

	   sim_proc : process
		   file file_out : text;
			file file_read : text;
			variable fstatus : FILE_OPEN_STATUS;
		   variable write_line : LINE;
			
			
			variable ll_bit : std_logic_vector(127 downto 0);
			
			variable ll_sig : std_logic_vector(5 downto 0) := "111000";
			--variable ll_sig : std_logic_vector(5 downto 0) := (others => '0');
			variable ll_integer : integer := 100;
	   begin
			--file_open(fstatus, file_out, "write.txt", write_mode);
			file_open(fstatus, file_read, "write.txt", read_mode);
		   Rst_n <= '0';
		   wait for 50 ns;
		   Rst_n <= '1';
		   wait for 20 ns;
		   start <= '1';
		   wait for 20 ns;
		   start <= '0';
		   wait until done = '1';
		   wait for 20 ns;

		   --! write测试
--			write(write_line, string'("TK="));
--			--write(write_line, to_string(tk));
--			hwrite(write_line, tk);
--		   writeline(file_out, write_line);

			
			readline(file_read,  write_line);
			hread(write_line, ll_bit);
			wait for 20 ns;
			ll_hah <= ll_bit;

--			
--			ll_hah(5 downto 0) <= ll_sig(5 downto 0);
--			ll_hah2 <= conv_std_logic_vector(ll_integer, 6);
			
			
		   --start <= '1';
		   --wait for 20 ns;
		   --start <= '0';
		   --wait until done = '1';
			file_close(file_read);
		   wait;
	   end process;
	   

  END;
