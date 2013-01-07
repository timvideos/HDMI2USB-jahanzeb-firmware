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

signal cdcout : std_logic_vector(1 downto 0):= "00";
signal cdcin : std_logic_vector(1 downto 0):= "01";
signal uvcin : std_logic_vector(1 downto 0):= "10";


type states is (uvc_in_pktend,uvc_send_data,uvc_set_add,cdc_in_send_edid_pktend,cdc_in_send_edid_1,s_reset, cdc_out_set_add,cdc_out_read,cdc_out_read_data,cdc_in_send_edid_0);
signal ps : states;


begin
fdatain <= fdata;
fdata <= fdataout when sloe_i = '1' else "ZZZZZZZZ";

rst <= not rst_n;
jpeg_rst <= rst or (not jpeg_enable) or jpeg_error;
-- jpeg_rst <= rst or (not jpeg_enable);
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
	ps <= s_reset;
elsif rising_edge(ifclk) then

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
		ps 			<= cdc_out_set_add;
		fdataout <= (others => '0');
	when cdc_out_set_add =>
		faddr		<= cdcout;
		ps <= cdc_out_read;
	when cdc_out_read =>
		if flag_empty = '1' then
			ps <= cdc_out_read_data;
			sloe_i <= '0';
		elsif jpeg_enable = '1' then
			ps <= uvc_set_add;
		end if;
	
	when cdc_out_read_data =>
		slrd <= '0';
		sloe_i <= '0';
		if (fdatain = X"45" or fdatain = X"65") then
			ps <= cdc_in_send_edid_0;
		else 
			faddr		<= cdcin;
			ps <= cdc_in_send_edid_pktend;
		end if;

	when cdc_in_send_edid_0 =>
		faddr		<= cdcin;
		ps <= cdc_in_send_edid_1;
		if edid_fifo_empty = '0' then
			edid_rd_en	<= '1';
		end if;
	
	when cdc_in_send_edid_1 =>
		if (flag_full = '1' and edid_fifo_empty = '0') then
			slwr		<= '0';
			edid_rd_en	<= '1';
			fdataout		<= edid_fdata;
		else 
			ps <= cdc_in_send_edid_pktend;
		end if;

	when cdc_in_send_edid_pktend =>
		if flag_full = '1' then
			pktend <= '0';
		end if;
		if jpeg_enable = '1' then
			ps <= uvc_set_add;
		else 
			ps <= cdc_out_set_add;
		end if;
		
	when uvc_set_add =>
		faddr		<= uvcin;

		if (jpeg_fifo_empty = '0') then
			jpeg_rd_en	<= '1';
			ps <= uvc_send_data;
		end if;
		
	when uvc_send_data =>	
		if (flag_full = '1' and jpeg_fifo_empty = '0') then
			slwr		<= '0';
			jpeg_rd_en	<= '1';
			fdataout		<= jpeg_fdata;
		else 
			ps <= uvc_in_pktend;
		end if;
			
	when uvc_in_pktend =>
		-- will be depending on the jpeg payload 
		-- if flag_full = '1' then 
			-- pktend <= '0';
		-- end if;

		ps <= cdc_out_set_add;

		
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