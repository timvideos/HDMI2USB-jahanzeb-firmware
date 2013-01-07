library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity usb is
    Port (
		clk 		: in std_logic;
		rst_n 		: in std_logic;
		
		fdata		: inout std_logic_vector(7 downto 0);
		flag_full 	: in std_logic;
		flag_empty 	: in std_logic;
		faddr		: out std_logic_vector(1 downto 0);
		slwr		: out std_logic;
		slrd		: out std_logic;
		sloe		: out std_logic;
		pktend		: out std_logic;
		LED 		: out std_logic_vector(7 downto 0);
		ifclk		: in std_logic
	);
end entity usb;

architecture rtl of usb is

type states is (s_reset, s_cdc_in,s_cdc_out,s_cdc_out_data,s_uvc_in);
signal ps : states;

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
signal faddr_i: std_logic_vector(1 downto 0);


-- FIFOADR[1:0] Selected FIFO
-- 00 EP2
-- 01 EP4
-- 10 EP6
-- 11 EP8

signal CDCOUTFIFO: std_logic_vector(1 downto 0) := "00";
signal CDCINFIFO: std_logic_vector(1 downto 0) := "01";
signal UVCINFIFO: std_logic_vector(1 downto 0) := "10";

begin
fdatain <= fdata;
fdata <= fdataout when sloe_i = '0' else "ZZZZZZZZ";
sloe <= sloe_i;

faddr <= faddr_i;
LED(0) <= flag_full;
LED(1) <= flag_empty;
LED(2) <= faddr_i(0);
LED(3) <= faddr_i(1);
LED(4) <= '0';
LED(5) <= '0';
LED(6) <= '0';
LED(7) <= fdatain(7) or fdatain(6) or fdatain(5) or fdatain(4) or fdatain(3) or fdatain(2) or fdatain(1) or fdatain(0);

syncProc: process(rst_n,ifclk)
begin

if rst_n = '0' then		
	faddr_i		<= CDCINFIFO;
	slwr		<= '0';
	slrd		<= '0';
	sloe_i		<= '0';
	pktend		<= '0';
	fdataout	<= (others => '0');
	ps			<= s_reset;
elsif rising_edge(ifclk) then

	slwr		<= '0';
	slrd		<= '0';
	sloe_i		<= '0';
	pktend		<= '0';
	edid_rd_en	<= '0';

	case ps is
	when s_reset => -- 000
		faddr_i		<= CDCINFIFO;
		slwr		<= '0';
		slrd		<= '0';
		sloe_i		<= '0';
		pktend		<= '0';
		jpeg_rd_en	<= '0';
		edid_rd_en	<= '0';
		ps 			<= s_cdc_out;
		fdataout <= (others => '0');
	when s_cdc_out => --010
		if (flag_empty = '0') then
			sloe_i		<= '1';
			ps <= s_cdc_out_data;
		else 
			ps <= s_uvc_in;
			faddr_i	<= CDCINFIFO;			
		end if;
		
	when s_cdc_out_data => --011
		slrd		<= '1';
		sloe_i		<= '1';
		faddr_i	<= CDCINFIFO;
		ps <= s_cdc_in;

	when s_cdc_in => --001
		faddr_i	<= UVCINFIFO;
		ps <= s_uvc_in;
		if (flag_full = '0') then
			slwr		<= '1';
			fdataout		<= (others => '0');
		end if;	
		
	when s_uvc_in => --100
		faddr_i	<= CDCINFIFO;
		ps <= s_cdc_out;
		if (flag_full = '0') then
			slwr		<= '1';
			fdataout		<= (others => '0');
		end if;
		
	
	when others =>
		ps <= s_reset;
	end case;



end if;

end process;

end rtl;