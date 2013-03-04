library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use ieee.numeric_std.all;
  
library STD;
use STD.TEXTIO.ALL;  
  
library unisim;
use unisim.vcomponents.all;

ENTITY hdmi2usb_tb IS
END hdmi2usb_tb;
 
ARCHITECTURE behavior OF hdmi2usb_tb IS 
-------------------------------------------------------------------------------------
--------------------------------- constants -----------------------------------------
-------------------------------------------------------------------------------------
constant DEBUG_EN              : integer :=0;   
constant  C3_MEMCLK_PERIOD : integer    := 3200;
constant C3_RST_ACT_LOW : integer := 0;
constant C3_INPUT_CLK_TYPE : string := "SINGLE_ENDED";
constant C3_CLK_PERIOD_NS   : real := 3200.0 / 1000.0;
constant C3_TCYC_SYS        : real := C3_CLK_PERIOD_NS/2.0;
constant C3_TCYC_SYS_DIV2   : time := C3_TCYC_SYS * 1 ns;
constant C3_NUM_DQ_PINS        : integer := 16;
constant C3_MEM_ADDR_WIDTH     : integer := 13;
constant C3_MEM_BANKADDR_WIDTH : integer := 3;   
constant C3_MEM_ADDR_ORDER     : string := "ROW_BANK_COLUMN"; 
constant C3_P2_MASK_SIZE : integer      := 4;
constant C3_P2_DATA_PORT_SIZE : integer := 32;  
constant C3_P3_MASK_SIZE   : integer    := 4;
constant C3_P3_DATA_PORT_SIZE  : integer := 32;
constant C3_MEM_BURST_LEN	  : integer := 4;
constant C3_MEM_NUM_COL_BITS   : integer := 10;
constant C3_SIMULATION      : string := "TRUE";
constant C3_CALIB_SOFT_IP      : string := "FALSE";



-------------------------------------------------------------------------------------
---------------------------------- components ---------------------------------------
-------------------------------------------------------------------------------------
component edid_master_slave_hack is
port(
	rst_n : in std_logic;
	clk : in std_logic;
	sda_lcd : inout std_logic;
	scl_lcd : out std_logic;
	sda_pc : inout std_logic;
	scl_pc : in std_logic;
	hpd_lcd : in std_logic;
	reg hpd_pc : out std_logic;
	sda_byte : out std_logic_vector(7 downto 0);
	sda_byte_en : out std_logic
);

component ddr2_model_c3 is
port (
	ck      : in    std_logic;
	ck_n    : in    std_logic;
	cke     : in    std_logic;
	cs_n    : in    std_logic;
	ras_n   : in    std_logic;
	cas_n   : in    std_logic;
	we_n    : in    std_logic;
	dm_rdqs : inout std_logic_vector(1 downto 0);
	ba      : in    std_logic_vector(2 downto 0);
	addr    : in    std_logic_vector(12 downto 0);
	dq      : inout std_logic_vector(15 downto 0);
	dqs     : inout std_logic_vector(1 downto 0);
	dqs_n   : inout std_logic_vector(1 downto 0);
	rdqs_n  : out   std_logic_vector(1 downto 0);
	odt     : in    std_logic
	);
end component;	

component hdmi2usb
port(
	rst_n : IN  std_logic;
	clk : IN  std_logic;
	RX0_TMDS : IN  std_logic_vector(3 downto 0);
	RX0_TMDSB : IN  std_logic_vector(3 downto 0);
	TX0_TMDS : OUT  std_logic_vector(3 downto 0);
	TX0_TMDSB : OUT  std_logic_vector(3 downto 0);
	SW : IN  std_logic_vector(2 downto 0);
	LED : OUT  std_logic_vector(7 downto 0);
	scl_pc : IN  std_logic;
	scl_lcd : OUT  std_logic;
	sda_pc : INOUT  std_logic;
	sda_lcd : INOUT  std_logic;
	fdata : INOUT  std_logic_vector(7 downto 0);
	flagA : IN  std_logic;
	flagB : IN  std_logic;
	flagC : IN  std_logic;
	faddr : OUT  std_logic_vector(1 downto 0);
	slwr : OUT  std_logic;
	slrd : OUT  std_logic;
	sloe : OUT  std_logic;
	pktend : OUT  std_logic;
	slcs : OUT  std_logic;
	ifclk : IN  std_logic;
	mcb3_dram_dq : INOUT  std_logic_vector(15 downto 0);
	mcb3_dram_a : OUT  std_logic_vector(12 downto 0);
	mcb3_dram_ba : OUT  std_logic_vector(2 downto 0);
	mcb3_dram_ras_n : OUT  std_logic;
	mcb3_dram_cas_n : OUT  std_logic;
	mcb3_dram_we_n : OUT  std_logic;
	mcb3_dram_cke : OUT  std_logic;
	mcb3_dram_dm : OUT  std_logic;
	mcb3_dram_udqs : INOUT  std_logic;
	mcb3_dram_udqs_n : INOUT  std_logic;
	mcb3_rzq : INOUT  std_logic;
	mcb3_zio : INOUT  std_logic;
	mcb3_dram_udm : OUT  std_logic;
	mcb3_dram_odt : OUT  std_logic;
	mcb3_dram_dqs : INOUT  std_logic;
	mcb3_dram_dqs_n : INOUT  std_logic;
	mcb3_dram_ck : OUT  std_logic;
	mcb3_dram_ck_n : OUT  std_logic;
	uvc_enable : IN  std_logic
);
end component;



-------------------------------------------------------------------------------------
-- signal 
-------------------------------------------------------------------------------------

--Inputs
signal rst_n : std_logic := '0';
signal clk : std_logic := '0';
signal RX0_TMDS : std_logic_vector(3 downto 0) := (others => '0');
signal RX0_TMDSB : std_logic_vector(3 downto 0) := (others => '0');
signal SW : std_logic_vector(2 downto 0) := (others => '0');
signal scl_pc : std_logic := '0';
signal flagA : std_logic := '0';
signal flagB : std_logic := '0';
signal flagC : std_logic := '0';
signal ifclk : std_logic := '0';
signal uvc_enable : std_logic := '0';

--BiDirs
signal sda_pc : std_logic;
signal sda_lcd : std_logic;
signal fdata : std_logic_vector(7 downto 0);
signal mcb3_dram_dq : std_logic_vector(15 downto 0);
signal mcb3_dram_udqs : std_logic;
signal mcb3_dram_udqs_n : std_logic;
signal mcb3_rzq : std_logic;
signal mcb3_zio : std_logic;
signal mcb3_dram_dqs : std_logic;
signal mcb3_dram_dqs_n : std_logic;

--Outputs
signal TX0_TMDS : std_logic_vector(3 downto 0);
signal TX0_TMDSB : std_logic_vector(3 downto 0);
signal LED : std_logic_vector(7 downto 0);
signal scl_lcd : std_logic;
signal faddr : std_logic_vector(1 downto 0);
signal slwr : std_logic;
signal slrd : std_logic;
signal sloe : std_logic;
signal pktend : std_logic;
signal slcs : std_logic;
signal mcb3_dram_a : std_logic_vector(12 downto 0);
signal mcb3_dram_ba : std_logic_vector(2 downto 0);
signal mcb3_dram_ras_n : std_logic;
signal mcb3_dram_cas_n : std_logic;
signal mcb3_dram_we_n : std_logic;
signal mcb3_dram_cke : std_logic;
signal mcb3_dram_dm : std_logic;
signal mcb3_dram_udm : std_logic;
signal mcb3_dram_odt : std_logic;
signal mcb3_dram_ck : std_logic;
signal mcb3_dram_ck_n : std_logic;

-- Clock period definitions
constant clk_period : time := 10 ns;
constant ifclk_period : time := 10 ns;

 
BEGIN  -- begin of test bench
 
   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   ifclk_process :process
   begin
		ifclk <= '0';
		wait for ifclk_period/2;
		ifclk <= '1';
		wait for ifclk_period/2;
   end process;
   
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

   
   
----------------------------------------------------------------------------------------
----------------------------- components -----------------------------------------------
----------------------------------------------------------------------------------------
uut: entity work.hdmi2usb PORT MAP (
	rst_n => rst_n,
	clk => clk,
	RX0_TMDS => RX0_TMDS,
	RX0_TMDSB => RX0_TMDSB,
	TX0_TMDS => TX0_TMDS,
	TX0_TMDSB => TX0_TMDSB,
	SW => SW,
	LED => LED,
	scl_pc => scl_pc,
	scl_lcd => scl_lcd,
	sda_pc => sda_pc,
	sda_lcd => sda_lcd,
	fdata => fdata,
	flagA => flagA,
	flagB => flagB,
	flagC => flagC,
	faddr => faddr,
	slwr => slwr,
	slrd => slrd,
	sloe => sloe,
	pktend => pktend,
	slcs => slcs,
	ifclk => ifclk,
	mcb3_dram_dq => mcb3_dram_dq,
	mcb3_dram_a => mcb3_dram_a,
	mcb3_dram_ba => mcb3_dram_ba,
	mcb3_dram_ras_n => mcb3_dram_ras_n,
	mcb3_dram_cas_n => mcb3_dram_cas_n,
	mcb3_dram_we_n => mcb3_dram_we_n,
	mcb3_dram_cke => mcb3_dram_cke,
	mcb3_dram_dm => mcb3_dram_dm,
	mcb3_dram_udqs => mcb3_dram_udqs,
	mcb3_dram_udqs_n => mcb3_dram_udqs_n,
	mcb3_rzq => mcb3_rzq,
	mcb3_zio => mcb3_zio,
	mcb3_dram_udm => mcb3_dram_udm,
	mcb3_dram_odt => mcb3_dram_odt,
	mcb3_dram_dqs => mcb3_dram_dqs,
	mcb3_dram_dqs_n => mcb3_dram_dqs_n,
	mcb3_dram_ck => mcb3_dram_ck,
	mcb3_dram_ck_n => mcb3_dram_ck_n,
	uvc_enable => uvc_enable
);   

----------------------------------------------------------------------------------------------
-------------------------------------- DDR2 RAM ----------------------------------------------
----------------------------------------------------------------------------------------------
ddr2_comp : ddr2_model_c3 port map(
	ck        => mcb3_dram_ck,
	ck_n      => mcb3_dram_ck_n,
	cke       => mcb3_dram_cke,
	cs_n      => '0',
	ras_n     => mcb3_dram_ras_n,
	cas_n     => mcb3_dram_cas_n,
	we_n      => mcb3_dram_we_n,
	dm_rdqs   => mcb3_dram_dm_vector ,
	ba        => mcb3_dram_ba,
	addr      => mcb3_dram_a,
	dq        => mcb3_dram_dq,
	dqs       => mcb3_dram_dqs_vector,
	dqs_n     => mcb3_dram_dqs_n_vector,
	rdqs_n    => open,
	odt       => mcb3_dram_odt
);

----------------------------------------------------------------------------------------------
-------------------------------------- EDID --------------------------------------------------   
----------------------------------------------------------------------------------------------   
edid_comp: edid_master_slave_hack
port map(
	rst_n => rst_n,
	clk => clk,
	sda_lcd => sda,
	scl_lcd => scl,
	sda_pc => sda,
	scl_pc => scl,
	hpd_lcd => hpd_lcd, -- simulates the connection of the monitor cabel connection 
	hpd_pc => hpd_pc, -- reconnects the monitor to PC after reading EDID from monitor
	sda_byte => sda_byte -- byte read from monitor 
	sda_byte_en => sda_byte_en -- edid byte enable signal 
);

----------------------------------------------------------------------------------------------
----------------------------------------- computer--------------------------------------------
----------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------
----------------------------------------- display --------------------------------------------
----------------------------------------------------------------------------------------------


END;
