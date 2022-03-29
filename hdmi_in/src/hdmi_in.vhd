------------------------------------------------------------------------------
--! 	@file		hdmi_in.vhd
--! 	@function	1,hdmi信号输入
--!					2, 	hdmi_clk => IBUFDS => MMCME => pixel_clk
--!						hdmi_rx	 =>	IBUFDS => IDELAY2 => ISERDESE2 => Symbol(10 downto 0)
--! 				3, 信号输出为HSYNC, VSYNC以及Video data和Audio data
--!		@version	
-----------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

library UNISIM;
use UNISIM.VComponents.all;
use work.hdmi_pkt.all;

entity HDMI_IN is
	port (
			Clk				:	--! 系统时钟	
								in	std_logic; 
			Rst_n			:	in	std_logic;
			--! 3 * tmds channel + 1 clock channel
			HDMI_rx_p		:	in	std_logic_vector(2 downto 0);
			HDMI_rx_n		:	in	std_logic_vector(2 downto 0);
			HDMI_rx_clk_p	:	in	std_logic;
			HDMI_rx_clk_n	:	in	std_logic;

			HDMI_rx_cec		:	inout	std_logic;
			HDMI_rx_hpa		:	in		std_logic;
			HDMI_rx_txen	:	out		std_logic;

			HDMI_rx_scl		:	in		std_logic;
			HDMI_rx_sda		:	inout	std_logic;

			--! OUT
			Symbol_hsync				:	out std_logic;
			Symbol_vsync				:	out std_logic;
			Symbol_blank				:	out std_logic;
			Symbol_ch0				:	out std_logic_vector(7 downto 0);
			Symbol_ch1				:	out std_logic_vector(7 downto 0);
			Symbol_ch2				:	out std_logic_vector(7 downto 0);
			Symbol_ch_valid			:	out std_logic;

			--! ADP数据输出
			Adp_data_valid 	: out std_logic;
		 	Adp_header_bits	:	out std_logic;
			Adp_frame_bits	:	out std_logic;
			Adp_sb0_bits		:	out std_logic_vector(1 downto 0);
			Adp_sb1_bits		:	out std_logic_vector(1 downto 0);
			Adp_sb2_bits		:	out std_logic_vector(1 downto 0);
			Adp_sb3_bits		:	out std_logic_vector(1 downto 0);

			--! 像素时钟信号输出
			Pixel_clock_locked	:	out std_logic;
			Pixel_clock_out		:	out std_logic;
		 );
end HDMI_IN;


architecture BEHAVOR of HDMI_IN	is
	component TMDS_INPUT_CHANNEL
	port (
			Clk			:	in	std_logic; 
			Clk_high	:	in	std_logic;
			Rst_n		:	in	std_logic;
			Data_in		:	in	std_logic;

			Ctl_valid	:	out std_logic;
			Ctl			:	out std_logic_vector(1 downto 0);
			Terc4_valid 	:	out std_logic;
			Terc4		:	out std_logic_vector(3 downto 0);
			Guardband_valid	:	out	std_logic;	
			Guardband		:	out	std_logic;
			Pixel_valid		:	out std_logic;
			Pixel_data		:	out std_logic_vector(7 downto 0)
			
		 );
	end component;
	signal clk_bufg			:	std_logic;
	--! tmds信号, IBUFDS转化后的差分信号
	signal tmds_in_ch		:	std_logic_vector(2 downto 0);
	signal tmds_in_clk		:	std_logic;

	--! 200M时钟，IDELAYCTL使用
	signal clk_200_unbuf	:	std_logic;
	signal clk_200			:	std_logic;
	signal clk_sys_fb		:	std_logic;


	--! *_unbuf, MMCME输出，未通过BUFG时钟
	signal clk_pixel_unbuf		:	std_logic;
	signal clk_pixel_x5_unbuf	:	std_logic;
	--  上面通过BUFG
	signal clk_pixel			:	std_logic;
	signal clk_pixel_x5			:	std_logic;

	--  clk_pixel MMCME中使用的信号
	signal clk_pixel_locked		:	std_logic;
	signal clk_pixel_fb			:	std_logic;


	--! 三路tmds input channel输出的数据
	signal ctl_valid			:	std_logic_vector(2 downto 0);
	signal ctl					:	CTL_VECTOR(2 downto 0);
	signal guardband_valid		:	std_logic_vector(2 downto 0);
	signal guardband			:	std_logic_vector(2 downto 0);
	signal terc4_valid			:	std_logic_vector(2 downto 0);
	signal terc4					:	TERC4_VECTOR(2 downto 0);
	--signal pixel_data_valid			:	std_logic_vector(2 downto 0);
	signal pixel_data				:	PIXEL_DATA_VECTOR(2 downto 0);


	--! 数据周期判断
	--signal is_video_data		:	std_logic;
	--! 这个is_data_island是个粗糙的范围，比in_adp多了guardband
	--! 但是完美覆盖这阶段的HSYNC,VSYNC
	signal is_data_island		:	std_logic;
	signal is_ctl				:	std_logic;


	--! 检测是否处于video data period
    signal vdp_prefix_detect    : std_logic_vector(7 downto 0);
    signal vdp_guardband_detect : std_logic;
    signal vdp_prefix_seen      : std_logic;
    signal vdp_prefix_seen_l1      : std_logic;
    signal vdp_prefix_seen_l2      : std_logic;
    signal in_vdp               : std_logic;
	
	--! 检测是否处于audio data period, 也就是data island perido
    signal adp_prefix_detect    : std_logic_vector(7 downto 0) := (others => '0');
    signal adp_guardband_detect : std_logic;
    signal adp_prefix_seen      : std_logic;
	signal adp_prefix_seen_l1	:	std_logic;
	signal adp_prefix_seen_l2	:	std_logic;
    signal in_adp               : std_logic;

	o
	attribute mark_debug : string;
	attribute mark_debug of in_adp : signal is "true";
	attribute mark_debug of in_vdp : signal is "true";
	attribute mark_debug of ctl_valid : signal is "true";
	attribute mark_debug of ctl : signal is "true";
	attribute mark_debug of terc4_valid: signal is "true";
	attribute mark_debug of terc4: signal is "true";
	attribute mark_debug of pixel_data : signal is "true";

begin
	Pixel_clock_locked	<= clk_pixel_locked;
	Pixel_clock_out		<= clk_pixel;

    
	--! 粗略计算处于哪个周期
	is_ctl 			<= '1' when ctl_valid = "111" else
			  			'0';
	--is_video_data 	<= '1' when pixel_data_valid = "111" else
	--				 	'0';
	is_data_island 	<= '1' when terc4_valid = "111" else
					  	'0';

    ---------------------
    -- 将输入差分信号通过IBUFDS转换成普通TTL信号
    ---------------------
	U_CLK_IBUFDS : IBUFDS
	generic map(IOSTANDARD => "TMDS_33")
	port map(
				I 	=> HDMI_rx_clk_p,		
				IB	=> HDMI_rx_clk_n,		
				O	=> tmds_in_clk
			);

	U_RX0_IBUFDS : IBUFDS
	generic map(IOSTANDARD => "TMDS_33")
	port map(
				I 	=> HDMI_rx_p(0),
				IB	=> HDMI_rx_n(0),
				O	=> tmds_in_ch(0)
			);

	U_RX1_IBUFDS : IBUFDS
	generic map(IOSTANDARD => "TMDS_33")
	port map(
				I 	=> HDMI_rx_p(1),
				IB	=> HDMI_rx_n(1),
				O	=> tmds_in_ch(1)
			);

	U_RX2_IBUFDS : IBUFDS
	generic map(IOSTANDARD => "TMDS_33")
	port map(
				I 	=> HDMI_rx_p(2),
				IB	=> HDMI_rx_n(2),
				O	=> tmds_in_ch(2)
			);
	------------------------------------------------------------------------------
   	--! 将hdmi时钟一分为二， 一份raw信号，一份5倍信号用于ISERDESE2(满足采样定理??)
	--! CLKOUT0 = CLKIN *  CLKFBOUT_MULT_F / CLKOUT0_DIVIDE / DIVCLK_DIVIDE
	------------------------------------------------------------------------------
	U_MMCM_HDMI_CLK : MMCME2_BASE
	generic map (
				--! 注意这里的数都有范围限定
				BANDWIDTH 			=> "OPTIMIZED",		-- Jitter programming (OPTIMIZED, HIGH, LOW)
				DIVCLK_DIVIDE   	=> 1,          		-- Master division value (1-106)
				CLKFBOUT_MULT_F 	=> 5.0,        		-- Multiply value for all CLKOUT (2.000-64.000).
				CLKFBOUT_PHASE 		=> 0.0,         		-- Phase offset in degrees of CLKFB (-360.000-360.000).
				--! 重点:CLKIN1_PERIOD这里是无所谓的
				--! 外面的约束文件对HDMI时钟的约束会覆盖这条
				CLKIN1_PERIOD 		=> 10.0, 				-- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
				CLKOUT0_DIVIDE_F 	=> 5.0,       		-- Divide amount for CLKOUT0 (1.000-128.000)
				CLKOUT1_DIVIDE   	=> 5,
				CLKOUT2_DIVIDE   	=> 1,
				CLKOUT3_DIVIDE   	=> 1,
				CLKOUT4_DIVIDE   	=> 1,
				CLKOUT5_DIVIDE   	=> 1,
				CLKOUT6_DIVIDE   	=> 1,
				-- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
				CLKOUT0_DUTY_CYCLE 	=> 0.5,
				CLKOUT1_DUTY_CYCLE 	=> 0.5,
				CLKOUT2_DUTY_CYCLE 	=> 0.5,
				CLKOUT3_DUTY_CYCLE 	=> 0.5,
				CLKOUT4_DUTY_CYCLE 	=> 0.5,
				CLKOUT5_DUTY_CYCLE 	=> 0.5,
				CLKOUT6_DUTY_CYCLE 	=> 0.5,
				-- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
				CLKOUT0_PHASE 		=> 0.0,
				CLKOUT1_PHASE 		=> 0.0,
				CLKOUT2_PHASE 		=> 0.0,
				CLKOUT3_PHASE 		=> 0.0,
				CLKOUT4_PHASE 		=> 0.0,
				CLKOUT5_PHASE 		=> 0.0,
				CLKOUT6_PHASE 		=> 0.0,
				CLKOUT4_CASCADE 	=> FALSE,  			-- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
				REF_JITTER1 		=> 0.0,        		-- Reference input jitter in UI (0.000-0.999).
				STARTUP_WAIT 		=> FALSE      		-- Delays DONE until MMCM is locked (FALSE, TRUE)
				)
	port map (
				 -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
				 CLKOUT0   			=> clk_pixel_unbuf,   	-- 1-bit output: CLKOUT0
				 CLKOUT0B  			=> open,         		-- 1-bit output: Inverted CLKOUT0
				 CLKOUT1   			=> clk_pixel_x5_unbuf, 	-- 1-bit output: CLKOUT1
				 CLKOUT1B  			=> open,         		-- 1-bit output: Inverted CLKOUT1
				 CLKOUT2   			=> open, 				-- 1-bit output: CLKOUT2
				 CLKOUT2B  			=> open,         	-- 1-bit output: Inverted CLKOUT2
				 CLKOUT3   			=> open,         	-- 1-bit output: CLKOUT3
				 CLKOUT3B  			=> open,         	-- 1-bit output: Inverted CLKOUT3
				 CLKOUT4   			=> open,         	-- 1-bit output: CLKOUT4
				 CLKOUT5   			=> open,         	-- 1-bit output: CLKOUT5
				 CLKOUT6   			=> open,         	-- 1-bit output: CLKOUT6
				 -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
				 CLKFBOUT  			=> clk_pixel_fb,       -- 1-bit output: Feedback clock
				 CLKFBOUTB 			=> open,          -- 1-bit output: Inverted CLKFBOUT
				 -- Status Ports: 1-bit (each) output: MMCM status ports
				 LOCKED    			=> clk_pixel_locked,        -- 1-bit output: LOCK
				 -- Clock Inputs: 1-bit (each) input: Clock input
				 CLKIN1    			=> tmds_in_clk, 	-- 1-bit input: Clock
				 -- Control Ports: 1-bit (each) input: MMCM control ports
				 PWRDWN    			=> '0',           	-- 1-bit input: Power-down
				 RST       			=> '0',           	-- 1-bit input: Reset
				 -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
				 CLKFBIN   			=> clk_pixel_fb		-- 1-bit input: Feedback clock
			 );
	U_BUFG_PIXEL_X1	: BUFG
	port map(
				I	=>	clk_pixel_unbuf,	
				O	=>	clk_pixel
			);

	U_BUFG_PIXEL_X5	: BUFG
	port map(
				I	=>	clk_pixel_x5_unbuf,	
				O	=>	clk_pixel_x5
			);


	------------------------------------------------------------------------------
   	--! 通过系统时钟生成一个200M时钟，
	--! 输出给IDELAYCTL, 进而控制IDELAY2
	------------------------------------------------------------------------------

	--! 这里插入一个BUFG, 不然implement error
	--! ERROR: [Place 30-681] Sub-optimal placement for a global clock-capable IO pin and MMCM pair
	U_BUFG_SYS_CLK_IN	: BUFG
	port map(
				I	=>	Clk,	
				O	=>	clk_bufg
			);
	U_MMCM_SYS_CLK	: MMCME2_BASE
	generic map (
					BANDWIDTH 			=> "OPTIMIZED",     -- Jitter programming (OPTIMIZED, HIGH, LOW)
					DIVCLK_DIVIDE   	=> 1,          		-- Master division value (1-106)
					CLKFBOUT_MULT_F 	=> 8.0,        		-- Multiply value for all CLKOUT (2.000-64.000).
					CLKFBOUT_PHASE 		=> 0.0,         	-- Phase offset in degrees of CLKFB (-360.000-360.000).
					CLKIN1_PERIOD 		=> 10.0, 			-- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
				    -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
					CLKOUT0_DIVIDE_F 	=> 4.0,       		-- Divide amount for CLKOUT0 (1.000-128.000).
					CLKOUT1_DIVIDE   	=> 1,
					CLKOUT2_DIVIDE   	=> 1,
					CLKOUT3_DIVIDE   	=> 1,
					CLKOUT4_DIVIDE   	=> 1,
					CLKOUT5_DIVIDE   	=> 1,
					CLKOUT6_DIVIDE   	=> 1,
	  				-- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
					CLKOUT0_DUTY_CYCLE 	=> 0.5,
					CLKOUT1_DUTY_CYCLE 	=> 0.5,
					CLKOUT2_DUTY_CYCLE 	=> 0.5,
					CLKOUT3_DUTY_CYCLE 	=> 0.5,
					CLKOUT4_DUTY_CYCLE 	=> 0.5,
					CLKOUT5_DUTY_CYCLE 	=> 0.5,
					CLKOUT6_DUTY_CYCLE 	=> 0.5,
	  				-- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
					CLKOUT0_PHASE 		=> 0.0,
					CLKOUT1_PHASE 		=> 0.0,
					CLKOUT2_PHASE 		=> 0.0,
					CLKOUT3_PHASE 		=> 0.0,
					CLKOUT4_PHASE 		=> 0.0,
					CLKOUT5_PHASE 		=> 0.0,
					CLKOUT6_PHASE 		=> 0.0,
					CLKOUT4_CASCADE 	=> FALSE,  			-- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
					REF_JITTER1 		=> 0.0,        		-- Reference input jitter in UI (0.000-0.999).
					STARTUP_WAIT 		=> FALSE      		-- Delays DONE until MMCM is locked (FALSE, TRUE)
				)
	port map (
	  				-- Clock Outputs: 1-bit (each) output: User configurable clock outputs
					CLKOUT0   			=> clk_200_unbuf,   -- 1-bit output: CLKOUT0
					CLKOUT0B  			=> open,         	-- 1-bit output: Inverted CLKOUT0
					CLKOUT1   			=> open,         	-- 1-bit output: CLKOUT1
					CLKOUT1B  			=> open,         	-- 1-bit output: Inverted CLKOUT1
					CLKOUT2   			=> open,         	-- 1-bit output: CLKOUT2
					CLKOUT2B		  	=> open,         	-- 1-bit output: Inverted CLKOUT2
					CLKOUT3			  	=> open,         	-- 1-bit output: CLKOUT3
					CLKOUT3B		  	=> open,         	-- 1-bit output: Inverted CLKOUT3
					CLKOUT4			  	=> open,         	-- 1-bit output: CLKOUT4
					CLKOUT5			  	=> open,         	-- 1-bit output: CLKOUT5
					CLKOUT6			  	=> open,         	-- 1-bit output: CLKOUT6
					-- Feedback Clocks: 1-bit (each) output: Clock feedback ports
				 	CLKFBOUT		  	=> clk_sys_fb,      -- 1-bit output: Feedback clock
				 	CLKFBOUTB		  	=> open,         	-- 1-bit output: Inverted CLKFBOUT
					-- Status Ports: 1-bit (each) output: MMCM status ports
					LOCKED			  	=> open,         	-- 1-bit output: LOCK
					-- Clock Inputs: 1-bit (each) input: Clock input
					CLKIN1			  	=> clk_bufg,   			-- 1-bit input: Clock
					-- Control Ports: 1-bit (each) input: MMCM control ports
					PWRDWN			  	=> '0',          	-- 1-bit input: Power-down
					RST				  	=> '0',          	-- 1-bit input: Reset
					-- Feedback Clocks: 1-bit (each) input: Clock feedback ports
					CLKFBIN			  	=> clk_sys_fb  	-- 1-bit input: Feedback clock
			 );

	U_BUFG_SYS200 : BUFG 
	PORT MAP (
		  		I => clk_200_unbuf,
				O => clk_200
			  );
	U_IDELAYCTRL : IDELAYCTRL
    port map (
				RDY    => open,    -- 1-bit output: Ready output
				REFCLK => clk_200, -- 1-bit input:  Reference clock input
				RST    => '0'      -- 1-bit input:  Active high reset input
    		);

	U_INPUT_CHANNEL0 : TMDS_INPUT_CHANNEL
	port map(
				Clk					=>	clk_pixel,
				Clk_high			=>	clk_pixel_x5,
				Rst_n				=>	clk_pixel_locked,
				Data_in				=>	tmds_in_ch(0),

				Ctl_valid			=>	ctl_valid(0),
				Ctl					=>	ctl(0),
				Terc4_valid 		=>	terc4_valid(0),
				Terc4				=>	terc4(0),
				Guardband_valid		=>	guard_valid(0),
				Guardband			=>	guard(0),
				--Pixel_valid			=>	pixel_data_valid(0),
				Pixel_valid			=>	open,
				Pixel_data			=>	pixel_data(0)
			);

	U_INPUT_CHANNEL1 : TMDS_INPUT_CHANNEL
	port map(
				Clk					=>	clk_pixel,
				Clk_high			=>	clk_pixel_x5,
				Rst_n				=>	clk_pixel_locked,
				Data_in				=>	tmds_in_ch(1),

				Ctl_valid			=>	ctl_valid(1),
				Ctl					=>	ctl(1),
				Terc4_valid 		=>	terc4_valid(1),
				Terc4				=>	terc4(1),
				Guardband_valid		=>	guard_valid(0),
				Guardband			=>	guard(0),

				--Pixel_valid			=>	pixel_data_valid(1),
				Pixel_valid			=>	open,
				Pixel_data			=>	pixel_data(1)
			);


	U_INPUT_CHANNEL2 : TMDS_INPUT_CHANNEL
	port map(
				Clk					=>	clk_pixel,
				Clk_high			=>	clk_pixel_x5,
				Rst_n				=>	clk_pixel_locked,
				Data_in				=>	tmds_in_ch(2),

				Ctl_valid			=>	ctl_valid(2),
				Ctl					=>	ctl(2),
				Terc4_valid 		=>	terc4_valid(2),
				Terc4				=>	terc4(2),
				Guardband_valid		=>	guard_valid(0),
				Guardband			=>	guard(0),

				--Pixel_valid			=>	pixel_data_valid(2),
				Pixel_valid			=>	open,
				Pixel_data			=>	pixel_data(2)
			);


	--! HSYNC, VSYNC信号
	U_HVSYNC : process(Clk)
	begin
		if Clk'event and Clk = '1' then
			if is_ctl = '1' then
				Symbol_hsync <= ctl(0)(0);
				Symbol_vsync <= ctl(0)(1);
			elsif is_data_island = '1' then
				Symbol_hsync <= terc4(0)(0);
				Symbol_vsync <= terc4(0)(1);
			else
				Symbol_hsync <= '0';
				Symbol_vsync <= '0';
			end if;
		end if;
	end process;


	U_BLANK : process(Clk)
	begin
		if Clk'event and Clk = '1' then
			if is_ctl = '1'  or in_adp = '1' then
				Symbol_blank <= '1' ;
			elsif in_vdp = '1' then
				Symbol_blank <= '0';
			end if;
		end if;
	end process;

	U_PIXEL_DATA : process(Clk)
	begin
		if Clk'event and Clk = '1' then
			if in_vdp  = '1' then
				Symbol_ch0 	<= pixel_data(0);
				Symbol_ch1 	<= pixel_data(1);
				Symbol_ch2		<= pixel_data(2);
				Symbol_ch_valid <= '1';
			else
				Symbol_ch0	<= (others => '0');
				Symbol_ch1 	<= (others => '0');
				Symbol_ch2 	<= (others => '0');
				Symbol_ch_valid <= '0';
			end if;
		end if;
	end process;

	--! DATA ISLAND PERIOD
	U_INFORFRAME_DATA : process(Clk)
	begin
		if Clk'event and Clk = '1' then
			if in_adp = '1' then
				Adp_data_valid <= '1';
				Adp_header_bits <= terc4(0)(2);
				Adp_frame_bits  <= terc4(0)(3);
				--!  bit1 bit0 
				--!  bit3 bit2
				Adp_sb0_bits		<= terc4(2)(0) & terc4(1)(0);
				Adp_sb1_bits		<= terc4(2)(1) & terc4(1)(1);
				Adp_sb2_bits		<= terc4(2)(2) & terc4(1)(2);
				Adp_sb3_bits		<= terc4(2)(3) & terc4(1)(3);
			else
				Adp_data_valid <= '0';
				Adp_header_bits <= '0';
				Adp_frame_bits  <= '0';
				Adp_sb0_bits <= (others => '0');
				Adp_sb1_bits <= (others => '0');
				Adp_sb2_bits <= (others => '0');
				Adp_sb3_bits <= (others => '0');
			end if;
		end if;
	end process;

	U_PREAMBLE_CHECK : process(Clk)
	begin
		if Clk'event and Clk = '1' then
			--! 判断CTL周期的下一周期是否为Video Data Period
            vdp_prefix_detect <= vdp_prefix_detect(6 downto 0) & '0';
            vdp_prefix_seen <= '0';
            if ctl_valid = "111"  then
				--!   CTL0, CTL1
				--!   CTL2, CTL3
				--! 这里对应10 00
                if ctl(1) = "01" and ctl(2) = "00" then
                    vdp_prefix_detect(0) <=  '1';
                    if vdp_prefix_detect = "01111111" then
                        vdp_prefix_seen <= '1';
                    end if;
                end if;
            end if;

			--! 判断CTL周期的下一周期是否为Audio Data Period,也就是Data Island
            adp_prefix_detect <= adp_prefix_detect(6 downto 0) & '0';
            adp_prefix_seen <= '0';
            if ctl_valid = "111"  then
				--! 这里对应 10 10
                if ctl(1) = "01" and ctl(2) = "01" then
                    adp_prefix_detect(0) <= '1';
                    if adp_prefix_detect = "01111111" then
                        adp_prefix_seen <= '1';
                    end if;
                end if;
            end if;
                
		end if;
	end process;

	U_PERIOD_CHECK : process(Clk)
	begin
		if Clk'event and Clk = '1' then
			---------------------------------------------------------------------------
			--! AUDIO DATA数据判断
			---------------------------------------------------------------------------
			--! 粗暴地越过两个周期的Leading GuardBand
			adp_prefix_seen_l1 <= adp_prefix_seen;
			adp_prefix_seen_l2 <= adp_prefix_seen_l1;
			if adp_prefix_seen_l2 = '1' then
				in_adp <= '1';
			end if;
			
			--! 控制周期，以及Trailing GuardBand清零
			if ctl_valid = '111' or 
			(guard_valid(1) = '1' and guard_valid(2) = '1' and guard(1) = '0' and guard(2) = '0')then
				in_adp <= '0';
			end if;

			---------------------------------------------------------------------------
			--! VIDEO DATA数据判断
			---------------------------------------------------------------------------

			--! 粗暴地越过两个周期的Leading GuardBand
			vdp_prefix_seen_l1 <= vdp_prefix_seen;
			vdp_prefix_seen_l2 <= vdp_prefix_seen_l1;
			if vdp_prefix_seen_l2 = '1' then
				in_vdp <= '1';
			end if;
			
			--! video data没有Trailing GuardBand
			if ctl_valid = '111' then
				in_vdp <= '0';
			end if;

		end if;
	end process;

end BEHAVOR;
