library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_TEXTIO.ALL;

-- USE ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


  
library STD;
use STD.TEXTIO.ALL;  
  
library unisim;
use unisim.vcomponents.all;


ENTITY ram_buffer_jpeg_encoder_tb IS
END ram_buffer_jpeg_encoder_tb;
 
ARCHITECTURE behavior OF ram_buffer_jpeg_encoder_tb IS 


-- ========================================================================== --
-- Parameters                                                                 --
-- ========================================================================== --


	type char_file is file of character;

	file f_capture           : text;
	file f_capture_bin       : char_file;
	constant CAPTURE_ORAM    : string := "..\sim\image.txt";
	constant CAPTURE_BIN     : string := "..\sim\image.jpg";
	
	

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
 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ram_buffer	
	generic(
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
    PORT(
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
         iram_wdata_in : IN  std_logic_vector(23 downto 0);
         iram_wren_in : IN  std_logic;
         iram_clk : IN  std_logic;
         store_img : IN  std_logic;
         read_img : IN  std_logic;
         iram_wdata_out : OUT  std_logic_vector(23 downto 0);
         iram_wren_out : OUT  std_logic;
         iram_fifo_afull : IN  std_logic;
         clk : IN  std_logic;
         clk_jpg : IN  std_logic;
         rst : IN  std_logic;
         error : OUT  std_logic
        );
    END COMPONENT;
	
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
	
	component jpeg_encoder_top is
	port 
	(
		clk                : in  std_logic;
		rst_n              : in  std_logic;
			
		iram_wdata         : in  std_logic_vector(23 downto 0);
		iram_wren          : in  std_logic;
		iram_fifo_afull    : out std_logic; 
		store_img		   : out std_logic; 
		read_img		   : out std_logic; 

		ram_byte           : out std_logic_vector(7 downto 0);
		ram_wren           : out std_logic;
		ram_wraddr         : out std_logic_vector(23 downto 0);
		outif_almost_full  : in  std_logic;
		resx 			   : in std_logic_vector(15  DOWNTO 0);
		resy			   : in std_logic_vector(15 DOWNTO 0);

		rgb_start 			: in std_logic;
		done			   	: out std_logic;
		error				: out std_logic;
		jpeg_busy		   	: out std_logic;
		jpeg_enable		   	: in std_logic
	);
	end component jpeg_encoder_top;	
    

   --Inputs
   signal iram_wdata_in : std_logic_vector(23 downto 0) := (others => '0');
   signal iram_wren_in : std_logic := '0';
   signal iram_clk : std_logic := '0';
   signal store_img : std_logic := '0';
   signal read_img : std_logic := '0';
   signal iram_fifo_afull : std_logic := '0';
   signal clk : std_logic := '0';
   signal clk_jpg : std_logic := '0';
   signal rst : std_logic := '1';

	--BiDirs
   signal mcb3_dram_dq : std_logic_vector(15 downto 0);
   signal mcb3_dram_udqs : std_logic;
   signal mcb3_dram_udqs_n : std_logic;
   signal mcb3_rzq : std_logic;
   signal mcb3_zio : std_logic;
   signal mcb3_dram_dqs : std_logic;
   signal mcb3_dram_dqs_n : std_logic;

 	--Outputs
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
   signal iram_wdata_out : std_logic_vector(23 downto 0);
   signal iram_wren_out : std_logic;
   signal error : std_logic;
      
   signal mcb3_enable1 : std_logic;   
   signal mcb3_enable2 : std_logic;   
   signal mcb3_command : std_logic_vector(2 downto 0);
   signal mcb3_dram_dm_vector : std_logic_vector(1 downto 0);
   signal mcb3_dram_dqs_n_vector : std_logic_vector(1 downto 0);
   signal mcb3_dram_dqs_vector : std_logic_vector(1 downto 0);
   
   signal rst_n : std_logic;

   signal sim : std_logic:='1';
   signal jpeg_enable : std_logic:='0';
   signal w_start2 : std_logic:='0';
   signal w_start : std_logic:='0';
   signal start : std_logic:='0';
   signal outif_almost_full : std_logic:='0';
   signal iram_wren : std_logic:='0';
   signal ram_wren : std_logic:='0';
   signal done : std_logic:='0';
   signal jpeg_busy : std_logic:='0';
   
   signal ram_byte : std_logic_vector(7 downto 0):=(others => '0');
   signal ram_wraddr : std_logic_vector(23 downto 0):=(others => '0');
   signal total_send : std_logic_vector(23 downto 0):=(others => '0');   
   signal iram_wdata : std_logic_vector(23 downto 0):=(others => '0');   
   signal to_send : std_logic_vector(23 downto 0):=(others => '0');   
   
	signal resx : std_logic_vector(15 downto 0):=(others => '0');   
	signal resy : std_logic_vector(15 downto 0):=(others => '0');   


   -- Clock period definitions
   constant iram_clk_period : time := 15 ns;
   constant clk_period : time := 10 ns;
   constant clk_jpg_period : time := 9 ns;
 
BEGIN
 
 
----------------------------------
 p_capture : process
    variable fLine           : line;
    variable fLine_bin       : line;
  begin
    file_open(f_capture, CAPTURE_ORAM, write_mode);
    file_open(f_capture_bin, CAPTURE_BIN, write_mode);
    
    while sim = '1' loop
      wait until rising_edge(clk_jpg);
      
      if ram_wren = '1' then
        hwrite(fLine, ram_byte);
        writeline(f_capture, fLine);
        
		write(f_capture_bin, CHARACTER'VAL(to_integer(unsigned(ram_byte))));
        
      end if;
    
    end loop;
    
    file_close(f_capture);
    file_close(f_capture_bin);
  
    wait;  
end process; 
 
-- Instantiate the Unit Under Test (UUT)
-- ========================================================================== --
-- Memory model instances                                                     -- 
-- ========================================================================== --
zio_pulldown3 : PULLDOWN port map(O => mcb3_zio);
rzq_pulldown3 : PULLDOWN port map(O => mcb3_rzq);

   
mcb3_command <= (mcb3_dram_ras_n & mcb3_dram_cas_n & mcb3_dram_we_n);

process(clk)
begin
  if (rising_edge(clk)) then
	if (rst = '1') then
	  mcb3_enable1   <= '0';
	  mcb3_enable2 <= '0';
	elsif (mcb3_command = "100") then
	  mcb3_enable2 <= '0';
	elsif (mcb3_command = "101") then
	  mcb3_enable2 <= '1';
	else
	  mcb3_enable2 <= mcb3_enable2;
	end if;
	mcb3_enable1     <= mcb3_enable2;
  end if;
end process;

-----------------------------------------------------------------------------
--read
-----------------------------------------------------------------------------
mcb3_dram_dqs_vector(1 downto 0) <= (mcb3_dram_udqs & mcb3_dram_dqs) when (mcb3_enable2 = '0' and mcb3_enable1 = '0') else "ZZ";
mcb3_dram_dqs_n_vector(1 downto 0) <= (mcb3_dram_udqs_n & mcb3_dram_dqs_n) when (mcb3_enable2 = '0' and mcb3_enable1 = '0') else "ZZ";

-----------------------------------------------------------------------------
--write
-----------------------------------------------------------------------------
mcb3_dram_dqs <= mcb3_dram_dqs_vector(0) when ( mcb3_enable1 = '1') else 'Z';
mcb3_dram_udqs <= mcb3_dram_dqs_vector(1) when (mcb3_enable1 = '1') else 'Z';

mcb3_dram_dqs_n <= mcb3_dram_dqs_n_vector(0) when (mcb3_enable1 = '1') else 'Z';
mcb3_dram_udqs_n <= mcb3_dram_dqs_n_vector(1) when (mcb3_enable1 = '1') else 'Z';

mcb3_dram_dm_vector <= (mcb3_dram_udm & mcb3_dram_dm);

------------------------------------------------------------------------------
-- ram model
------------------------------------------------------------------------------

u_mem_c3 : ddr2_model_c3 port map(
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
 
-- Instantiate the Unit Under Test (UUT)
uut_ram: ram_buffer generic map
(  
	C3_P0_MASK_SIZE  =>     C3_P2_MASK_SIZE,
	C3_P0_DATA_PORT_SIZE  => C3_P2_DATA_PORT_SIZE,
	C3_P1_MASK_SIZE       => C3_P3_MASK_SIZE,
	C3_P1_DATA_PORT_SIZE  => C3_P3_DATA_PORT_SIZE, 
	C3_MEMCLK_PERIOD  =>       C3_MEMCLK_PERIOD,
	C3_RST_ACT_LOW    =>     C3_RST_ACT_LOW,
	C3_INPUT_CLK_TYPE =>     C3_INPUT_CLK_TYPE, 
	DEBUG_EN              => DEBUG_EN,
	C3_MEM_ADDR_ORDER     => C3_MEM_ADDR_ORDER,
	C3_NUM_DQ_PINS        => C3_NUM_DQ_PINS,
	C3_MEM_ADDR_WIDTH     => C3_MEM_ADDR_WIDTH,
	C3_MEM_BANKADDR_WIDTH => C3_MEM_BANKADDR_WIDTH,
	C3_SIMULATION   =>      C3_SIMULATION,
	C3_CALIB_SOFT_IP      => C3_CALIB_SOFT_IP
) 
PORT MAP (
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
	iram_wdata_in => iram_wdata_in,
	iram_wren_in => iram_wren_in,
	iram_clk => iram_clk,
	store_img => store_img,
	read_img => read_img,
	iram_wdata_out => iram_wdata_out,
	iram_wren_out => iram_wren_out,
	iram_fifo_afull => iram_fifo_afull,
	clk => clk,
	clk_jpg => clk_jpg,
	rst => rst,
	error => error
);

uut_jpeg: jpeg_encoder_top PORT MAP (
	clk                => clk_jpg,
	rst_n              => rst_n,
		
	iram_wdata         => iram_wdata_out,
	iram_wren          => iram_wren_out,
	iram_fifo_afull    => iram_fifo_afull,
	store_img		   => store_img,
	read_img		   => read_img,

	ram_byte           => ram_byte,
	ram_wren           => ram_wren,
	ram_wraddr         => ram_wraddr,
	outif_almost_full  => outif_almost_full,
	resx 			   => resx,
	resy			   => resy,

	rgb_start 			=> start,
	done			   	=> done,
	error				=> error,
	jpeg_busy		   	=> jpeg_busy,
	jpeg_enable		   	=> jpeg_enable
);

   -- Clock process definitions
   iram_clk_process :process
   begin
		iram_clk <= '0';
		wait for iram_clk_period/2;
		iram_clk <= '1';
		wait for iram_clk_period/2;
   end process;
 
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   clk_jpg_process :process
   begin
		clk_jpg <= '0';
		wait for clk_jpg_period/2;
		clk_jpg <= '1';
		wait for clk_jpg_period/2;
   end process;
 


   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		rst_n <= '0';
		rst <= '1';
      wait for 210 us;	
		rst_n <= '1';
		rst <= '0';
		-- resx <= X"0500";resy <= X"02D0";to_send <= X"0E_10_00"; -- 1280×720  (921600)
		-- resx <= X"0400";resy <= X"0300";to_send <= X"0C_00_00"; -- 1024x768 (786432)
		-- resx <= X"0010";resy <= X"0010";to_send <= X"00_01_00"; -- 16x16 (256)
		-- resx <= X"0080";resy <= X"0080";to_send <= X"00_40_00"; -- 128x128 
		resx <= X"0400";resy <= X"0080";to_send <= X"02_00_00"; -- 1024*128 -- 131072
		-- resx <= X"0400";resy <= X"0008";to_send <= X"00_20_00"; -- 1024*8 -- 8192
		
		
		
		assert false report "Start of simulation" severity warning;
		wait for iram_clk_period;
		jpeg_enable <= '1';
		
		
		-- first vsync
		wait for iram_clk_period*10;
		start <= '1';	
		wait for iram_clk_period;
		start <= '0';	
		
		wait for iram_clk_period*1000;
		
		w_start <= '1';		
		wait until (w_start2 = '1'); -- image stored in ddr2 ram 
		w_start <= '0';		
		
		wait for iram_clk_period*1000; -- wait before second vsync
		
		start <= '1';	
		wait for iram_clk_period;
		start <= '0';
		
		wait until (done = '1');
		wait for 1 us;
		sim <= '0';
		wait for iram_clk_period*10;
		
		assert false report "end of simulation" severity failure;	

      wait;
   end process;
 

---------------
data_proc:process(iram_clk)	
begin
	if rising_edge(iram_clk) then
	iram_wren <= '0';	
		if w_start = '1' and w_start2 = '0' and store_img = '1' then
			if total_send = to_send then
				w_start2 <= '1';
			else				
				iram_wdata_in <= total_send(23 downto 0);			
				total_send <= std_logic_vector(unsigned(total_send) + 1);
				iram_wren_in <= '1';	
			end if;
		end if;
	end if;	
end process data_proc;

END; -- Architecture 
