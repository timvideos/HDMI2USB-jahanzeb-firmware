library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity usb is
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
end entity usb;

architecture rtl of usb is

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
    empty : OUT STD_LOGIC
  );
END component bytefifo;
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
signal edid_rd_en : std_logic;
signal edid_fifo_full : std_logic;
signal edid_fifo_empty : std_logic;
signal sloe_i : std_logic;

signal jpeg_fdata: std_logic_vector(7 downto 0);
signal edid_fdata: std_logic_vector(7 downto 0);
signal fdatain: std_logic_vector(7 downto 0);
signal fdataout: std_logic_vector(7 downto 0);

type states is (s_reset, s_cdc_in,s_cdc_out,s_cdc_out_data,s_uvc_in);
signal ps : states;


begin
fdatain <= fdata;
fdata <= fdataout when sloe_i = '1' else "ZZZZZZZZ";

rst <= not rst_n;
jpeg_rst <= rst or (not jpeg_enable) or jpeg_error;
sloe <= sloe_i;

syncProc: process(rst_n,ifclk)
begin

if rst_n = '0' then		
	faddr		<= "00";
	slwr		<= '1';
	slrd		<= '1';
	sloe_i		<= '1';
	pktend		<= '1';
	jpeg_rd_en		<= '0';
elsif rising_edge(ifclk) then

	slwr		<= '1';
	slrd		<= '1';
	sloe_i		<= '1';
	pktend		<= '1';
	edid_rd_en	<= '0';
	jpeg_rd_en 	<= '0';

	case ps is
	when s_reset =>
		faddr		<= "00";
		slwr		<= '1';
		slrd		<= '1';
		sloe_i		<= '1';
		pktend		<= '1';
		jpeg_rd_en	<= '0';
		edid_rd_en	<= '0';
		ps 			<= s_cdc_out;
		fdataout <= (others => '0');
	when s_cdc_out =>
		if (flag_empty = '1') then
			sloe_i		<= '0';
			ps <= s_cdc_out_data;
		else 
			ps <= s_uvc_in;
			faddr	<= "10";			
		end if;
		
	when s_cdc_out_data =>
		slrd		<= '0';
		if ((fdatain = X"45" ) or (fdatain = X"65" )) then
			ps 		<= s_cdc_in;
			faddr	<= "01";
		else 
			pktend		<= '0'; --% to transmit zero length packet because not a valid coommand
			ps <= s_uvc_in;
			faddr	<= "10";			
		end if;

	when s_cdc_in =>
		if (edid_fifo_empty = '1') then
			pktend		<= '0'; --% to transmit zero length packet nothing to transmit
		end if;
		if (flag_full = '1' and edid_fifo_empty = '0') then
			slwr		<= '0';
			edid_rd_en	<= '1';
			fdataout		<= edid_fdata;
		end if;
		if (edid_fifo_empty = '1' or flag_full = '0') then
			ps <= s_uvc_in;
			faddr	<= "10";
		end if;
		
	when s_uvc_in =>
		if (jpeg_fifo_empty = '1' and jpeg_enable = '1') then
			pktend		<= '0'; --% to transmit zero length packet
		end if;
		if (flag_full = '1' and jpeg_fifo_empty = '0' ) then --% when jpeg fifo will be empty and in rst position until jpeg_enable is not high
			slwr		<= '0';
			jpeg_rd_en	<= '1';
			fdataout		<= jpeg_fdata;
		end if;
		if (jpeg_fifo_empty = '1' or flag_full = '0') then
			ps <= s_cdc_out;
			faddr	<= "00";
		end if;
		
	when others =>
		ps <= s_reset;
	end case;



end if;

end process;


jpegbytefifoComp: bytefifo port map(
rst => jpeg_rst,
wr_clk => jpeg_clk,
rd_clk => ifclk,
din => jpeg_byte,
wr_en => jpeg_en,
rd_en => jpeg_rd_en,
dout => jpeg_fdata,
full => jpeg_fifo_full,
empty => jpeg_fifo_empty
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