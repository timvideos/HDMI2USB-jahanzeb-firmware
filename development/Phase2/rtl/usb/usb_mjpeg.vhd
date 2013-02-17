-- //////////////////////////////////////////////////////////////////////////////
-- /// Copyright (c) 2013, Jahanzeb Ahmad
-- /// All rights reserved.
-- ///
-- // Redistribution and use in source and binary forms, with or without modification, 
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
-- ///   POSSIBILITY OF SUCH DAMAGE.
-- ///
-- ///
-- ///  * http://opensource.org/licenses/MIT
-- ///  * http://copyfree.org/licenses/mit/license.txt
-- ///
-- //////////////////////////////////////////////////////////////////////////////

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity usb_mjpeg is
    Port (
		clk 		: in std_logic;
		rst_n 		: in std_logic;
		sda_byte	: in std_logic_vector(7 downto 0);
		sda_en 		: in std_logic;
		jpeg_byte	: in std_logic_vector(7 downto 0);
		jpeg_clk 	: in std_logic;		
		jpeg_en	 	: in std_logic;		
		fdata		: inout std_logic_vector(7 downto 0);
		flag_full 	: in std_logic;
		flag_empty 	: in std_logic;
		faddr		: out std_logic_vector(1 downto 0);
		slwr		: out std_logic;
		slrd		: out std_logic;
		sloe		: out std_logic;
		pktend		: out std_logic;
		ifclk		: in std_logic;
		resX		: in std_logic_vector(15 downto 0);
		resY		: in std_logic_vector(15 downto 0);
		jpeg_enable	: in std_logic;
		jpeg_error	: in std_logic;
		jpeg_fifo_full	: out std_logic
	);
end entity usb_mjpeg;

architecture rtl of usb_mjpeg is

component bytefifo IS
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    almost_full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
	almost_empty : OUT STD_LOGIC;
    prog_full : OUT STD_LOGIC	
  );
END component bytefifo;
component bytefifoFPGA IS
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    almost_full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
	almost_empty : OUT STD_LOGIC
--    prog_full : OUT STD_LOGIC	
  );
END component bytefifoFPGA;
component edidfifo IS
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
END component edidfifo;

signal rst : std_logic;
signal jpeg_rst : std_logic;
signal jpeg_rd_en : std_logic;
signal jpeg_fifo_empty : std_logic;
signal jpeg_fifo_empty_i : std_logic;
signal jpeg_fifo_almost_empty : std_logic;
signal edid_rd_en : std_logic;
signal edid_fifo_full : std_logic;
signal edid_fifo_empty : std_logic;
signal sloe_i : std_logic;
signal eof : std_logic;
signal pkt_sent : std_logic;
signal fid : std_logic;
signal prog_full : std_logic;
signal jpeg_rd_wr_en : std_logic;
signal jpeg_fifo_full_i : std_logic;

signal jpeg_fdata: std_logic_vector(7 downto 0);
signal edid_fdata: std_logic_vector(7 downto 0);
signal fdatain: std_logic_vector(7 downto 0);
signal fdataout: std_logic_vector(7 downto 0);
signal temp: std_logic_vector(7 downto 0);
signal jpeg_byte_i: std_logic_vector(7 downto 0);

signal cdcout : std_logic_vector(1 downto 0):= "00"; --ep 2
signal cdcin : std_logic_vector(1 downto 0):= "01"; --ep 4
signal uvcin : std_logic_vector(1 downto 0):= "10"; --ep 6

signal jpeg_byte_q: std_logic_vector(7 downto 0);
signal jpeg_byte_q_q: std_logic_vector(7 downto 0);
signal counter: std_logic_vector(7 downto 0);
signal wrightcount: std_logic_vector(11 downto 0);

type states is (uvc_wait,cdc_in_send_edid_1,uvc_in_pktend,uvc_send_data,uvc_set_add,cdc_in_send_edid_pktend,uvc_send_header,s_reset, cdc_out_set_add,cdc_out_read,cdc_out_read_data,cdc_in_send_edid_0);
signal ps : states;


begin
fdatain <= fdata;
fdata <= fdataout when sloe_i = '1' else "ZZZZZZZZ";

rst <= not rst_n;
-- jpeg_rst <= (not rst_n) or (not jpeg_enable) or jpeg_error;

sloe <= sloe_i;

syncProc: process(rst_n,ifclk)
begin

if rst_n = '0' then		
	faddr		<= "00";
	slwr		<= '1';
	slrd		<= '1';
	sloe_i		<= '1';
	pktend		<= '1';
	jpeg_rd_en	<= '0';
	fid			<= '0';
	pkt_sent 	<= '0';	
	counter 	<= (others => '0');	
	wrightcount <= (others => '0');	
	wrightcount <= (others => '0');	
	ps <= s_reset;
elsif falling_edge(ifclk) then

	slwr		<= '1';
	slrd		<= '1';
	sloe_i		<= '1';
	pktend		<= '1';
	edid_rd_en	<= '0';
	jpeg_rd_en 	<= '0';


	case ps is
	when s_reset =>
		faddr		<= cdcout;
		slwr		<= '1';
		slrd		<= '1';
		sloe_i		<= '1';
		pktend		<= '1';
		jpeg_rd_en	<= '0';
		edid_rd_en	<= '0';
		fid			<= '0';
		pkt_sent 	<= '0';	
		ps 			<= cdc_out_set_add;
		fdataout 	<= (others => '0');
		counter 	<= (others => '0');	
		wrightcount <= (others => '0');	
	when cdc_out_set_add =>
		faddr	<= cdcout;
		ps 		<= cdc_out_read;
	when cdc_out_read =>
		if flag_empty = '1' then
			ps 		<= cdc_out_read_data;
			sloe_i 	<= '0';
		elsif jpeg_enable = '1' then
			ps <= uvc_set_add;
		end if;
	
	when cdc_out_read_data =>
		slrd 	<= '0';
		sloe_i 	<= '0';
		if (fdatain = X"45" or fdatain = X"65") then
			ps <= cdc_in_send_edid_0;
		else 
			faddr	<= cdcin;
			ps 		<= cdc_in_send_edid_pktend;
		end if;

	when cdc_in_send_edid_0 =>
		faddr	<= cdcin;
		ps 		<= cdc_in_send_edid_1;
	
	when cdc_in_send_edid_1 =>
		if (flag_full = '1' and edid_fifo_empty = '0') then
			slwr		<= '0';
			edid_rd_en	<= '1';
			fdataout	<= edid_fdata;
		else 
			ps <= cdc_in_send_edid_pktend;
		end if;

	when cdc_in_send_edid_pktend =>
		pktend <= '0';
		if jpeg_enable = '1' then
			ps <= uvc_set_add;
		else 
			ps <= cdc_out_set_add;
		end if;
		
	when uvc_set_add =>
		counter 	<= (others => '0');
		wrightcount <= (others => '0');
		faddr		<= uvcin;
		ps 			<= uvc_wait;		

	when uvc_send_data =>
	
		if jpeg_fifo_empty_i = '0' and flag_full = '1' then 
			
			wrightcount <= wrightcount +1; 
			
			if wrightcount = X"200" then		
					ps <= uvc_wait;
					wrightcount <= (others => '0');
			elsif wrightcount = X"000" then
				slwr		<= '0';
				fdataout <= X"0C"; -- header length
				pkt_sent <= '0';	

			elsif wrightcount = X"001" then	
				slwr		<= '0';
				fdataout <= ( "100000" & eof & fid ); --1000 1100 -- EOH  ERR  STI  RES  SCR  PTS  EOF  FID

			elsif wrightcount = X"002" then	
				slwr		<= '0';
				fdataout <= X"00";

			elsif wrightcount = X"003" then	
				slwr		<= '0';
				fdataout <= X"00";

			elsif wrightcount = X"004" then	
				slwr		<= '0';
				fdataout <= X"00";

			elsif wrightcount = X"005" then	
				slwr		<= '0';
				fdataout <= X"00";

			elsif wrightcount = X"006" then	
				slwr		<= '0';
				fdataout <= X"00";

			elsif wrightcount = X"007" then	
				slwr		<= '0';
				fdataout <= X"00";

			elsif wrightcount = X"008" then	
				slwr		<= '0';
				fdataout <= X"00";

			elsif wrightcount = X"009" then	
				slwr		<= '0';
				fdataout <= X"00";


			elsif wrightcount = X"00A" then	
				slwr		<= '0';
				fdataout <= X"00";


			elsif wrightcount = X"00B" then	
				slwr		<= '0';
				fdataout <= X"00";

			else

				slwr		<= '0';
				jpeg_rd_en	<= '1';
				
				temp <= jpeg_fdata;
				fdataout <= jpeg_fdata;			
				
				if temp = X"FF" and jpeg_fdata = X"D9" then
					ps <= uvc_in_pktend;
					pkt_sent <= '1';
					wrightcount <= (others => '0');
				end if;
					
			end if;
		
		end if;	

	
	when uvc_wait =>
		if jpeg_fifo_full_i = '1' and flag_full = '1' then
			ps 	<= uvc_send_data;			
		end if;
		
	when uvc_in_pktend =>
		
		pktend	<= '0';
		ps 		<= cdc_out_set_add;
		fid 	<= not fid;
	
	when others =>
		ps <= s_reset;
	end case;

end if;

end process;



eofprocess: process(rst_n,jpeg_clk)
begin

if rst_n = '0' then	
	eof <= '0';	
	jpeg_byte_q <= (others => '0');
	jpeg_byte_q_q <= (others => '0');
	jpeg_rst <= '1';
elsif rising_edge(jpeg_clk) then

	jpeg_byte_q <= jpeg_byte_i;
	jpeg_byte_q_q <= jpeg_byte_q;
	
	jpeg_rst <= (not jpeg_enable) or jpeg_error;
	

	if pkt_sent = '1' then
		eof <= '0';	
	elsif jpeg_byte_q_q = X"FF" and jpeg_byte_q = X"D9" then
		eof <= '1';			
	end if;


end if;
end process;



bytefifo_encoder: bytefifoFPGA port map(
rst => jpeg_rst,
wr_clk => jpeg_clk,
rd_clk => jpeg_clk,
din => jpeg_byte,
wr_en => jpeg_en,
rd_en => jpeg_rd_wr_en,
dout => jpeg_byte_i,
empty => jpeg_fifo_empty,
almost_full => jpeg_fifo_full
);

process(rst_n,jpeg_clk)
begin
if rst_n = '0' then
	jpeg_rd_wr_en <= '0';
elsif falling_edge(jpeg_clk) then
	jpeg_rd_wr_en <= '0';
	if jpeg_fifo_empty = '0' and jpeg_fifo_full_i = '0' then
		jpeg_rd_wr_en <= '1';
	end if;
end if;
end process;

bytefifo_usb: bytefifo port map(
rst => jpeg_rst,
wr_clk => jpeg_clk,
rd_clk => ifclk,
din => jpeg_byte_i,
wr_en => jpeg_rd_wr_en,
rd_en => jpeg_rd_en,
dout => jpeg_fdata,
empty => jpeg_fifo_empty_i,
full => jpeg_fifo_full_i
);



edidfifoComp: edidfifo port map(
rst => rst,
wr_clk => clk,
rd_clk => ifclk,
din => sda_byte,
wr_en => sda_en,
rd_en => edid_rd_en,
dout => edid_fdata,
full => edid_fifo_full,
empty => edid_fifo_empty
);

end rtl;