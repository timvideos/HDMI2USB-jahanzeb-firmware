-- //////////////////////////////////////////////////////////////////////////////
-- /// Copyright (c) 2012, Jahanzeb Ahmad
-- /// All rights reserved.
-- ///
-- /// Redistribution and use in source and binary forms, with or without modification, 
-- /// are permitted provided that the following conditions are met:
-- ///
-- ///  * Redistributions of source code must retain the above copyright notice, 
-- ///    this list of conditions and the following disclaimer.
-- ///  * Redistributions in binary form must reproduce the above copyright notice, 
-- ///    this list of conditions and the following disclaimer in the documentation and/or 
-- ///    other materials provided with the distribution.
-- ///
-- ///    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
-- ///    EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
-- ///    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
-- ///    SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
-- ///    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
-- ///    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
-- ///    PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
-- ///    WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
-- ///    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
-- ///    POSSIBILITY OF SUCH DAMAGE.
-- ///  * http://opensource.org/licenses/MIT
-- ///  * http://copyfree.org/licenses/mit/license.txt
-- ///
-- //////////////////////////////////////////////////////////////////////////////
-- /*!
 -- HDMI 2 USB(jpeg) converter top lever module.
 -- this file contains all the necessary modules needed.
 -- description of each module is given in its top level file.

 -- Useful links are
 
 -- http://www.xilinx.com/support/documentation/application_notes/xapp495_S6TMDS_Video_Interface.pdf
 
 -- http://www.xilinx.com/support/documentation/spartan-6.htm
 
 -- http://www.evernew.com.tw/HDMISpecification13a.pdf
 
 -- http://read.pudn.com/downloads110/ebook/456020/E-EDID%20Standard.pdf
 
 -- http://www.nxp.com/documents/user_manual/UM10204.pdf
 
 -- http://www.digilentinc.com/Products/Detail.cfm?NavPath=2,400,836&Prod=ATLYS
 
 -- http://en.wikipedia.org/wiki/Extended_display_identification_data
 
 -- http://en.wikipedia.org/wiki/I%C2%B2C
 
 -- http://en.wikipedia.org/wiki/Hdmi
 
-- */


LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;		 
USE ieee.std_logic_unsigned.all;

Library UNISIM;
use UNISIM.vcomponents.all;


entity hdmi2usb is 
generic (
	SIMULATION             	  : string := "FALSE";
	C3_P0_MASK_SIZE           : integer := 4;
    C3_P0_DATA_PORT_SIZE      : integer := 32;
    C3_P1_MASK_SIZE           : integer := 4;
    C3_P1_DATA_PORT_SIZE      : integer := 32;
    C3_MEMCLK_PERIOD          : integer := 3200;
    C3_RST_ACT_LOW            : integer := 0;
    C3_INPUT_CLK_TYPE         : string := "SINGLE_ENDED";
    C3_CALIB_SOFT_IP          : string := "TRUE";
    C3_SIMULATION             : string := "FALSE";
    DEBUG_EN                  : integer := 0;
    C3_MEM_ADDR_ORDER         : string := "ROW_BANK_COLUMN";
    C3_NUM_DQ_PINS            : integer := 16;
    C3_MEM_ADDR_WIDTH         : integer := 13;
    C3_MEM_BANKADDR_WIDTH     : integer := 3
);

port
(
	RX0_TMDS 	: in std_logic_vector(3 downto 0); 
	RX0_TMDSB 	: in std_logic_vector(3 downto 0);
	TX0_TMDS  	: out std_logic_vector(3 downto 0);
	TX0_TMDSB  	: out std_logic_vector(3 downto 0);

	RX1_TMDS  	: in std_logic_vector(3 downto 0);
	RX1_TMDSB  	: in std_logic_vector(3 downto 0);
	TX1_TMDS  	: out std_logic_vector(3 downto 0);
	TX1_TMDSB  	: out std_logic_vector(3 downto 0);

	scl_pc0 	: in std_logic; -- DDC scl connected with PC
	scl_lcd0 	: out std_logic; -- DDC scl connected with LCD
	sda_pc0 	: inout std_logic; -- DDC sda connected with PC
	sda_lcd0	: inout std_logic; -- DDC sda connected with LCD

	scl_pc1 	: in std_logic; -- DDC scl connected with PC
	sda_pc1 	: inout std_logic; -- DDC sda connected with PC	
	
	-- scl_lcd1 	: out std_logic; -- DDC scl connected with LCD
	-- sda_lcd1 	: inout std_logic; -- DDC sda connected with LCD

	btnc 		: in std_logic;
	btnu		: in std_logic; 
	btnl		: in std_logic;
	btnr		: in std_logic; 
	btnd		: in std_logic; 

	LED 		: out std_logic_vector(7 downto 0);
	sw 			: in std_logic_vector(7 downto 0);

	-- USB Chip
	fdata 		: inout std_logic_vector(7 downto 0); 
	flagA 		: in std_logic;
	flagB 		: in std_logic; -- flag_full(flagB)
	flagC 		: in std_logic; -- flag_empty(flagC)
	faddr 		: out std_logic_vector(1 downto 0); 
	slwr 		: out std_logic;
	slrd 		: out std_logic;
	sloe 		: out std_logic;
	pktend 		: out std_logic;
	slcs 		: out std_logic; 
	ifclk 		: in std_logic; 


	-- DDR2 RAM
	mcb3_dram_dq 	: inout std_logic_vector(15 downto 0);
	mcb3_dram_a 	: out std_logic_vector(12 downto 0);
	mcb3_dram_ba 	: out std_logic_vector(2 downto 0);
	mcb3_dram_ras_n : out std_logic;
	mcb3_dram_cas_n	: out std_logic;
	mcb3_dram_we_n	: out std_logic;
	mcb3_dram_cke	: out std_logic;
	mcb3_dram_dm	: out std_logic;
	mcb3_dram_udqs 	: inout std_logic;
	mcb3_dram_udqs_n: inout std_logic;
	mcb3_rzq		: inout std_logic;
	mcb3_zio		: inout std_logic;
	mcb3_dram_udm	: out std_logic;
	mcb3_dram_odt	: out std_logic;
	mcb3_dram_dqs	: inout std_logic;
	mcb3_dram_dqs_n	: inout std_logic;
	mcb3_dram_ck	: out std_logic;
	mcb3_dram_ck_n	: out std_logic;

	rst_n : in std_logic;
	clk	: in std_logic
);

end entity hdmi2usb;

architecture rtl of hdmi2usb is 



signal de_H : std_logic;
signal de : std_logic;
signal hsync : std_logic;
signal vsync : std_logic;
signal pclk_H : std_logic;
signal resx : std_logic_vector(15 DOWNTO 0);
signal resy : std_logic_vector(15 DOWNTO 0);
signal rgb : std_logic_vector(23 DOWNTO 0);

signal rgb_H : std_logic_vector(23 DOWNTO 0);


signal rdy_H0 : std_logic;
signal de_H0 : std_logic;
signal rgb_H0 : std_logic_vector(23 downto 0);
signal hsync_H0 : std_logic;
signal vsync_H0 : std_logic;
signal pclk_H0 : std_logic;
signal resx_H0 : std_logic_vector(15 DOWNTO 0);
signal resy_H0 : std_logic_vector(15 DOWNTO 0);

signal rdy_H1 : std_logic;
signal de_H1 : std_logic;
signal rgb_H1 : std_logic_vector(23 downto 0);
signal hsync_H1 : std_logic;
signal vsync_H1 : std_logic;
signal pclk_H1 : std_logic;
signal resx_H1 : std_logic_vector(15 DOWNTO 0);
signal resy_H1 : std_logic_vector(15 DOWNTO 0);



signal de_vga : std_logic;
signal hsync_vga : std_logic;
signal vsync_vga : std_logic;
signal pclk_vga : std_logic;
signal resx_vga : std_logic_vector(15 DOWNTO 0);
signal resy_vga : std_logic_vector(15 DOWNTO 0);
signal rgb_vga : std_logic_vector(23 downto 0);


signal de_tp : std_logic;
signal hsync_tp : std_logic;
signal vsync_tp : std_logic;
signal pclk_tp : std_logic;
signal resx_tp : std_logic_vector(15 DOWNTO 0);
signal resy_tp : std_logic_vector(15 DOWNTO 0);
signal rgb_tp : std_logic_vector(23 downto 0);

signal rst : std_logic;

signal edid0_byte : std_logic_vector(7 downto 0);
signal edid0_byte_en : std_logic;
signal hpd : std_logic;
signal edid1_byte : std_logic_vector(7 downto 0);
signal edid1_byte_en : std_logic;


signal slwr_i : std_logic;
signal cmd_en : std_logic;
signal cmd_byte : std_logic_vector(7 downto 0);
signal uvc_rst : std_logic;
signal jpg_start : std_logic;
signal jpg_done : std_logic;
signal jpg_busy : std_logic;
signal hdmi_cmd : std_logic_vector(1 downto 0);
signal dvi_only : std_logic_vector(1 downto 0);
signal usb_cmd : std_logic_vector(2 downto 0);
signal selector_cmd : std_logic_vector(12 downto 0);
signal status : std_logic_vector(3 downto 0);
signal img_clk : std_logic;
signal jpg_enable : std_logic;
signal raw_fifo_full : std_logic;
signal img_out_en : std_logic;
signal ycbcr_en : std_logic;
signal img_out : std_logic_vector(23 downto 0);
signal ycbcr : std_logic_vector(23 downto 0);
signal jpeg_encoder_cmd : std_logic_vector(1 downto 0);
signal outif_almost_full : std_logic;
signal btnr_s : std_logic;
signal btnu_s : std_logic;
signal btnd_s : std_logic;
signal btnl_s : std_logic;
signal jpeg_byte : std_logic_vector(7 downto 0);
signal jpeg_en : std_logic;
signal jpg_fifo_afull : std_logic;
signal error_ram : std_logic;
signal to_send : std_logic_vector(23 downto 0);


	
---------------------------------------------------------------------------------------------------------------------	
begin

rst <= not rst_n;
slcs <= '0';
slwr <= slwr_i;

LED(0) <= de_H0;
LED(1) <= de_H1;
LED(2) <= usb_cmd(1);
LED(3) <= flagB; -- full flag
LED(4) <= flagC; -- empty flag 
LED(5) <= slwr_i;
LED(6) <= selector_cmd(0);
LED(7) <= selector_cmd(1);


debouncerBtnc : entity work.debouncer
	port map(clk    => img_clk,
		     rst_n  => rst_n,
		     insig  => btnc,
		     outsig => hpd);
			 
debouncerBtnu : entity work.debouncer
	port map(clk    => img_clk,
		     rst_n  => rst_n,
		     insig  => btnu,
		     outsig => btnu_s);
		     
debouncerBtnd : entity work.debouncer
	port map(clk    => img_clk,
		     rst_n  => rst_n,
		     insig  => btnd,
		     outsig => btnd_s);		     

debouncerBtnl : entity work.debouncer
	port map(clk    => img_clk,
		     rst_n  => rst_n,
		     insig  => btnl,
		     outsig => btnl_s);		     

debouncerBtnr : entity work.debouncer
	port map(clk    => img_clk,
		     rst_n  => rst_n,
		     insig  => btnr,
		     outsig => btnr_s);		     

		     
jpeg_encoder : entity work.jpeg_encoder_top
	port map(clk               => img_clk,
		     uvc_rst             => uvc_rst,
		     iram_wdata        => img_out,
		     iram_wren         => img_out_en,
		     iram_fifo_afull   => jpg_fifo_afull,
		     ram_byte          => jpeg_byte,
		     ram_wren          => jpeg_en,
		     outif_almost_full => outif_almost_full,
		     resx              => resx,
		     resy              => resy,
		     jpeg_encoder_cmd  => jpeg_encoder_cmd,
			 enable				=> jpg_enable,
		     start             => jpg_start,
		     done              => jpg_done,
		     busy              => jpg_busy);
			 
		     
jpg_enable <= (usb_cmd(2) and usb_cmd(1));
		     
ddr2_comp : entity work.image_buffer
	generic map(C3_P0_MASK_SIZE       => C3_P0_MASK_SIZE,
		        C3_P0_DATA_PORT_SIZE  => C3_P0_DATA_PORT_SIZE,
		        C3_P1_MASK_SIZE       => C3_P1_MASK_SIZE,
		        C3_P1_DATA_PORT_SIZE  => C3_P1_DATA_PORT_SIZE,
		        C3_MEMCLK_PERIOD      => C3_MEMCLK_PERIOD,
		        C3_RST_ACT_LOW        => C3_RST_ACT_LOW,
		        C3_INPUT_CLK_TYPE     => C3_INPUT_CLK_TYPE,
		        C3_CALIB_SOFT_IP      => C3_CALIB_SOFT_IP,
		        C3_SIMULATION         => C3_SIMULATION,
		        DEBUG_EN              => DEBUG_EN,
		        C3_MEM_ADDR_ORDER     => C3_MEM_ADDR_ORDER,
		        C3_NUM_DQ_PINS        => C3_NUM_DQ_PINS,
		        C3_MEM_ADDR_WIDTH     => C3_MEM_ADDR_WIDTH,
		        C3_MEM_BANKADDR_WIDTH => C3_MEM_BANKADDR_WIDTH)
	port map(mcb3_dram_dq     => mcb3_dram_dq,
		     mcb3_dram_a      => mcb3_dram_a,
		     mcb3_dram_ba     => mcb3_dram_ba,
		     mcb3_dram_ras_n  => mcb3_dram_ras_n,
		     mcb3_dram_cas_n  => mcb3_dram_cas_n,
		     mcb3_dram_we_n   => mcb3_dram_we_n,
		     mcb3_dram_cke    => mcb3_dram_cke,
		     mcb3_dram_dm     => mcb3_dram_dm,
		     mcb3_dram_udqs   => mcb3_dram_udqs,
		     mcb3_dram_udqs_n => mcb3_dram_udqs_n,
		     mcb3_rzq         => mcb3_rzq,
		     mcb3_zio         => mcb3_zio,
		     mcb3_dram_udm    => mcb3_dram_udm,
		     mcb3_dram_odt    => mcb3_dram_odt,
		     mcb3_dram_dqs    => mcb3_dram_dqs,
		     mcb3_dram_dqs_n  => mcb3_dram_dqs_n,
		     mcb3_dram_ck     => mcb3_dram_ck,
		     mcb3_dram_ck_n   => mcb3_dram_ck_n,
		     img_in           => rgb,
		     img_in_en        => de,
		     img_out          => img_out,
		     img_out_en       => img_out_en,
		     jpg_fifo_afull   => jpg_fifo_afull,
		     raw_fifo_afull   => raw_fifo_full,
		     clk              => clk,
		     clk_out          => img_clk,
		     jpg_or_raw       => usb_cmd(1),
			 vsync			  => vsync,
			 jpg_busy		  => jpg_busy,
			 jpg_done		  => jpg_done,
			 jpg_start		  => jpg_start,
			 resX			  => resX,
			 resY			  => resY,
			 to_send		  => to_send,
		     rst              => rst,
			 uvc_rst		  => uvc_rst,
		     error            => error_ram);
		     
img_sel_comp : entity work.image_selector
	port map(rgb_H0       => rgb_H0,
		     de_H0        => de_H0,
		     pclk_H0      => pclk_H0,
		     hsync_H0     => hsync_H0,
		     vsync_H0     => vsync_H0,
		     resX_H0      => resX_H0,
		     resY_H0      => resY_H0,
		     rgb_H1       => rgb_H1,
		     de_H1        => de_H1,
		     pclk_H1      => pclk_H1,
		     hsync_H1     => hsync_H1,
		     vsync_H1     => vsync_H1,
		     resX_H1      => resX_H1,
		     resY_H1      => resY_H1,
		     rgb_tp       => rgb_tp,
		     de_tp        => de_tp,
		     pclk_tp      => pclk_tp,
		     hsync_tp     => hsync_tp,
		     vsync_tp     => vsync_tp,
		     resX_tp      => resX_tp,
		     resY_tp      => resY_tp,
		     rgb_vga      => rgb_vga,
		     de_vga       => de_vga,
		     pclk_vga     => pclk_vga,
		     hsync_vga    => hsync_vga,
		     vsync_vga    => vsync_vga,
		     resX_vga     => resX_vga,
		     resY_vga     => resY_vga,
		     selector_cmd => selector_cmd,
		     rgb          => rgb,
		     de           => de,
		     hsync        => hsync,
		     vsync        => vsync,
		     resX         => resX,
		     resY         => resY,
			 rgb_H		  => rgb_H,
			 de_H		  => de_H,
			 pclk_H		  => pclk_H,
		     clk          => img_clk,
		     rst          => rst);

hdmiMatri_Comp : entity work.hdmimatrix
	port map(rst_n           => rst_n,
		     RX0_TMDS        => RX0_TMDS,
		     RX0_TMDSB       => RX0_TMDSB,
		     TX0_TMDS        => TX0_TMDS,
		     TX0_TMDSB       => TX0_TMDSB,
		     RX1_TMDS        => RX1_TMDS,
		     RX1_TMDSB       => RX1_TMDSB,
		     TX1_TMDS        => TX1_TMDS,
		     TX1_TMDSB       => TX1_TMDSB,
		     rx0_de          => de_H0,
		     rx1_de          => de_H1,
		     rx1_hsync       => hsync_H1,
		     rx0_hsync       => hsync_H0,
		     rx1_vsync       => vsync_H1,
		     rx0_vsync       => vsync_H0,
		     rx1_pclk        => pclk_H1,
		     rx0_pclk        => pclk_H0,
			 rdy0			 => rdy_H0,	 
			 rdy1			 => rdy_H1,			 
			 rx0_rgb		=> rgb_H0,
			 rx1_rgb		=> rgb_H1,			 
			 tx_rgb			=> rgb_H,			 
			 tx_de 			 => de_H,
			 tx_hsync 		 => hsync,
			 tx_vsync 		 => vsync,
			 tx_pclk 		 => pclk_H,
			 rst => rst);	 

			 
calc_res0 : entity work.calc_res
	port map(rst_n => rst_n,
		     clk   => pclk_H0,
		     de    => de_H0,
		     hsync => hsync_H0,
		     vsync => vsync_H0,
		     resX  => resX_H0,
		     resY  => resY_H0);
		     
		     
calc_res1 : entity work.calc_res
	port map(rst_n => rst_n,
		     clk   => pclk_H1,
		     de    => de_H1,
		     hsync => hsync_H1,
		     vsync => vsync_H1,
		     resX  => resX_H1,
		     resY  => resY_H1);


edid_hack0 : entity work.edid_master_slave_hack
	port map(rst_n       => rst_n,
		     clk         => img_clk,
		     sda_lcd     => sda_lcd0,
		     scl_lcd     => scl_lcd0,
		     sda_pc      => sda_pc0,
		     scl_pc      => scl_pc0,
		     hpd_lcd     => hpd,
			 hpd_pc		 => open,
		     sda_byte    => edid0_byte,
		     sda_byte_en => edid0_byte_en,
			 dvi_only	 => dvi_only(0),
			 hdmi_dvi	 => hdmi_cmd(0));

edid_hack1 : entity work.edid_master_slave_hack
	port map(rst_n       => rst_n,
		     clk         => img_clk,
		     sda_lcd     => open,
		     scl_lcd     => open,
		     sda_pc      => sda_pc1, 
		     scl_pc      => scl_pc1, 
		     hpd_lcd     => hpd,
			 hpd_pc		 => open,
		     sda_byte    => edid1_byte,
		     sda_byte_en => edid1_byte_en,
			 dvi_only	 => dvi_only(1),
			 hdmi_dvi	 => hdmi_cmd(1));
		     
rgb2ycbcr_comp: entity work.rgb2ycbcr
	port map(
		rgb 	=> img_out,
		de_in 	=> img_out_en,
		ycbcr 	=> ycbcr,
		de_out 	=> ycbcr_en,
		rst_n 	=> rst_n,
		clk 	=> img_clk);


usb_comp: entity work.usb_top
	port map(edid0_byte       => edid0_byte,
		     edid0_byte_en    => edid0_byte_en,
		     edid1_byte       => edid1_byte,
		     edid1_byte_en    => edid1_byte_en,
		     jpeg_byte        => jpeg_byte,
		     jpeg_clk         => img_clk,
		     jpeg_en          => jpeg_en,
		     jpeg_fifo_full   => outif_almost_full,
		     raw_en           => ycbcr_en,
		     raw_bytes        => ycbcr,
		     raw_fifo_full    => raw_fifo_full,
		     raw_clk          => img_clk,
		     fdata            => fdata,
		     flag_full        => flagB,
		     flag_empty       => flagC,
		     faddr            => faddr,
		     slwr             => slwr_i,
		     slrd             => slrd,
		     sloe             => sloe,
		     pktend           => pktend,
		     ifclk            => ifclk,
		     resX_H0          => resX_H0,
		     resY_H0          => resY_H0,
		     resX_H1          => resX_H1,
		     resY_H1          => resY_H1,
		     de_H0            => de_H0,
		     de_H1            => de_H1,
		     status           => status,
		     usb_cmd          => usb_cmd,
		     jpeg_encoder_cmd => jpeg_encoder_cmd,
		     selector_cmd     => selector_cmd,
		     hdmi_cmd         => hdmi_cmd,
		     uvc_rst          => uvc_rst,
			 to_send		  => to_send,
		     cmd_en           => cmd_en,
		     cmd              => cmd_byte,
		     rst              => rst,
		     clk              => img_clk);
		     
		     
testpattern_comp : entity work.pattern
	generic map( SIMULATION => SIMULATION)
	port map(rgb 	=> rgb_tp,
		     resX  => resX_tp,
		     resY  => resY_tp,
		     de    => de_tp,
		     pclk  => pclk_tp,
		     vsync => vsync_tp,
		     hsync => hsync_tp,
		     clk   => clk,
		     rst_n => rst_n);	
		     
controller_comp : entity work.controller
	port map(status           => status,
		     usb_cmd          => usb_cmd,
		     jpeg_encoder_cmd => jpeg_encoder_cmd,
		     selector_cmd     => selector_cmd,
		     hdmi_cmd         => hdmi_cmd,
			 hdmi_dvi		  => dvi_only,
		     rdy_H            => (rdy_H1 & rdy_H0),
		     btnu             => btnu_s,
		     btnd             => btnd_s,
		     btnl             => btnl_s,
		     btnr             => btnr_s,
		     uvc_rst          => uvc_rst,
		     cmd_byte         => cmd_byte,
		     cmd_en           => cmd_en,
		     rst              => rst,
		     ifclk            => ifclk,
		     clk              => img_clk);		     	          

end architecture rtl;
