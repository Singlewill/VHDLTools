
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
-- sd
use work.sd_const_pkg.all;

entity TB_SIMPLE_SD is
end TB_SIMPLE_SD;

architecture BEHAVOR of TB_SIMPLE_SD is
	component simple_sd
		port(
            rst                    : in  std_logic;
            clk                    : in  std_logic;
            sd_clk            : out        std_logic;
            sd_cmd            : inout    std_logic;
            sd_dat            : inout    std_logic_vector(3 downto 0);
            sd_cd                : in        std_logic := '0';
            sleep                : in  std_logic := '0';
            mode                : in  sd_mode_record := sd_mode_fast;
            mode_fb            : out sd_mode_record;
            dat_address    : in  sd_dat_address_type := (others=>'0');
            ctrl_tick        : in  sd_tick_record := sd_tick_zero;
            fb_tick            : out sd_tick_record;
            dat_block        : out dat_block_type;
            dat_valid        : out std_logic;
            dat_tick        : out std_logic;
            unit_stat        : out sd_controller_stat_type
        );

	end component;

	signal clk	:	std_logic;
	signal rst	:	std_logic;

	signal sd_clk: std_logic;
	signal	sd_cmd			: 	std_logic;
	signal 	sd_dat			: 	std_logic_vector(3 downto 0);
	signal 	sd_cd				: 		std_logic := '0';
	signal sleep				:   std_logic := '0';
	signal mode				:   sd_mode_record := sd_mode_fast;
	signal mode_fb			:  sd_mode_record;
	signal dat_address	:   sd_dat_address_type := (others=>'0');
	signal ctrl_tick		:   sd_tick_record := sd_tick_zero;
	signal fb_tick			:  sd_tick_record;
	signal dat_block		:  dat_block_type;
	signal dat_valid		:  std_logic;
	signal dat_tick		:  std_logic;
	signal unit_stat		:  sd_controller_stat_type;
begin
	sleep <= '0';
	mode.fast <= '1';
	mode.wide_bus <= '1';

	ctrl_tick.read_multiple	<= '0';
	ctrl_tick.stop_transfer	<= '0';


	U_SIMPLE_SD :  simple_sd
	port map(
				rst			=>	rst,
				clk			=>	clk,
				sd_clk		=>	sd_clk		,
				sd_cmd		=>	sd_cmd		,
				sd_dat		=>	sd_dat		,
				sd_cd		=>	sd_cd		,
				sleep		=>	sleep		,
				mode		=>	mode		,
				mode_fb	    =>	mode_fb		,
				dat_address =>	dat_address ,
				ctrl_tick   =>	ctrl_tick	,
				fb_tick		=>	fb_tick		,
				dat_block	=>	dat_block	,
				dat_valid	=>	dat_valid	,
				dat_tick	=>	dat_tick	,
				unit_stat	=>	unit_stat	
					
			);


	U_CLK : process
	begin
		clk <= '1';
		wait for 10 ns;
		clk <= '0';
		wait for 10 ns;
	end process;
	U_RST : process
	begin
		rst <= '0';
		ctrl_tick.read_single <= '0';
		wait for 100 ns;
		rst <= '1';
		wait for 10 ns;
		ctrl_tick.read_single <= '1';
		wait for 10 ns;
		ctrl_tick.read_single <= '0';
		wait;
	end process;

end BEHAVOR;



