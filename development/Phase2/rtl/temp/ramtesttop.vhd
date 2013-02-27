LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;		 
USE ieee.std_logic_unsigned.all;


-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ramtesttop is
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
    C3_MEM_ADDR_ORDER         : string := "BANK_ROW_COLUMN";
    C3_NUM_DQ_PINS            : integer := 16;
    C3_MEM_ADDR_WIDTH         : integer := 13;
    C3_MEM_BANKADDR_WIDTH     : integer := 3
);
port(
   mcb3_dram_dq                            : inout  std_logic_vector(C3_NUM_DQ_PINS-1 downto 0);
   mcb3_dram_a                             : out std_logic_vector(C3_MEM_ADDR_WIDTH-1 downto 0);
   mcb3_dram_ba                            : out std_logic_vector(C3_MEM_BANKADDR_WIDTH-1 downto 0);
   mcb3_dram_ras_n                         : out std_logic;
   mcb3_dram_cas_n                         : out std_logic;
   mcb3_dram_we_n                          : out std_logic;
   mcb3_dram_cke                           : out std_logic;
   mcb3_dram_dm                            : out std_logic;
   mcb3_dram_udqs                          : inout  std_logic;
   mcb3_dram_udqs_n                        : inout  std_logic;
   mcb3_rzq                                : inout  std_logic;
   mcb3_zio                                : inout  std_logic;
   mcb3_dram_udm                           : out std_logic;
   mcb3_dram_odt                           : out std_logic;
   
	mcb3_dram_dqs                           : inout  std_logic;
   mcb3_dram_dqs_n                         : inout  std_logic;
   mcb3_dram_ck                            : out std_logic;
   mcb3_dram_ck_n                          : out std_logic;
   
   -- user signals
   clk		: in std_logic;
   rst_n 	: in std_logic;
   led		: out std_logic_vector(7 downto 0)
   
   
   
);
end ramtesttop;

architecture rtl of ramtesttop is
component ramtest
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
    C3_MEM_ADDR_ORDER         : string := "BANK_ROW_COLUMN";
    C3_NUM_DQ_PINS            : integer := 16;
    C3_MEM_ADDR_WIDTH         : integer := 13;
    C3_MEM_BANKADDR_WIDTH     : integer := 3
);
    port (
   mcb3_dram_dq                            : inout  std_logic_vector(C3_NUM_DQ_PINS-1 downto 0);
   mcb3_dram_a                             : out std_logic_vector(C3_MEM_ADDR_WIDTH-1 downto 0);
   mcb3_dram_ba                            : out std_logic_vector(C3_MEM_BANKADDR_WIDTH-1 downto 0);
   mcb3_dram_ras_n                         : out std_logic;
   mcb3_dram_cas_n                         : out std_logic;
   mcb3_dram_we_n                          : out std_logic;
   mcb3_dram_cke                           : out std_logic;
   mcb3_dram_dm                            : out std_logic;
   mcb3_dram_udqs                          : inout  std_logic;
   mcb3_dram_udqs_n                        : inout  std_logic;
   mcb3_rzq                                : inout  std_logic;
   mcb3_zio                                : inout  std_logic;
   mcb3_dram_udm                           : out std_logic;
	
   c3_sys_clk                              : in  std_logic;
   c3_sys_rst_i                            : in  std_logic;
   c3_calib_done                           : out std_logic;
   c3_clk0                                 : out std_logic;
   c3_rst0                                 : out std_logic;
   mcb3_dram_dqs                           : inout  std_logic;
   mcb3_dram_dqs_n                         : inout  std_logic;
   mcb3_dram_ck                            : out std_logic;
   mcb3_dram_ck_n                          : out std_logic;
   c3_p2_cmd_clk                           : in std_logic;
   c3_p2_cmd_en                            : in std_logic;
   c3_p2_cmd_instr                         : in std_logic_vector(2 downto 0);
   c3_p2_cmd_bl                            : in std_logic_vector(5 downto 0);
   c3_p2_cmd_byte_addr                     : in std_logic_vector(29 downto 0);
   c3_p2_cmd_empty                         : out std_logic;
   c3_p2_cmd_full                          : out std_logic;
   c3_p2_rd_clk                            : in std_logic;
   c3_p2_rd_en                             : in std_logic;
   c3_p2_rd_data                           : out std_logic_vector(31 downto 0);
   c3_p2_rd_full                           : out std_logic;
   c3_p2_rd_empty                          : out std_logic;
   c3_p2_rd_count                          : out std_logic_vector(6 downto 0);
   c3_p2_rd_overflow                       : out std_logic;
   c3_p2_rd_error                          : out std_logic;
   c3_p3_cmd_clk                           : in std_logic;
   c3_p3_cmd_en                            : in std_logic;
   c3_p3_cmd_instr                         : in std_logic_vector(2 downto 0);
   c3_p3_cmd_bl                            : in std_logic_vector(5 downto 0);
   c3_p3_cmd_byte_addr                     : in std_logic_vector(29 downto 0);
   c3_p3_cmd_empty                         : out std_logic;
   c3_p3_cmd_full                          : out std_logic;
   c3_p3_wr_clk                            : in std_logic;
   c3_p3_wr_en                             : in std_logic;
   c3_p3_wr_mask                           : in std_logic_vector(3 downto 0);
   c3_p3_wr_data                           : in std_logic_vector(31 downto 0);
   c3_p3_wr_full                           : out std_logic;
   c3_p3_wr_empty                          : out std_logic;
   c3_p3_wr_count                          : out std_logic_vector(6 downto 0);
   c3_p3_wr_underrun                       : out std_logic;
   c3_p3_wr_error                          : out std_logic
);
end component;


component clkgen
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic
 );
end component;



signal c3_sys_clk                              :   std_logic;
signal c3_sys_rst_i                            :   std_logic;
signal c3_calib_done                           :  std_logic;
signal c3_clk0                                 :  std_logic;
signal c3_rst0                                 :  std_logic;
signal c3_p2_cmd_clk                           :  std_logic;
signal c3_p2_cmd_en                            :  std_logic;
signal c3_p2_cmd_instr                         :  std_logic_vector(2 downto 0);
signal c3_p2_cmd_bl                            :  std_logic_vector(5 downto 0);
signal c3_p2_cmd_byte_addr                     :  std_logic_vector(29 downto 0);
signal c3_p2_cmd_empty                         :  std_logic;
signal c3_p2_cmd_full                          :  std_logic;
signal c3_p2_rd_clk                            :  std_logic;
signal c3_p2_rd_en                             :  std_logic;
signal c3_p2_rd_data                           :  std_logic_vector(31 downto 0);
signal c3_p2_rd_full                           :  std_logic;
signal c3_p2_rd_empty                          :  std_logic;
signal c3_p2_rd_count                          :  std_logic_vector(6 downto 0);
signal c3_p2_rd_overflow                       :  std_logic;
signal c3_p2_rd_error                          :  std_logic;
signal c3_p3_cmd_clk                           :  std_logic;
signal c3_p3_cmd_en                            :  std_logic;
signal c3_p3_cmd_instr                         :  std_logic_vector(2 downto 0);
signal c3_p3_cmd_bl                            :  std_logic_vector(5 downto 0);
signal c3_p3_cmd_byte_addr                     :  std_logic_vector(29 downto 0);
signal c3_p3_cmd_empty                         :  std_logic;
signal c3_p3_cmd_full                          :  std_logic;
signal c3_p3_wr_clk                            :  std_logic;
signal c3_p3_wr_en                             :  std_logic;
signal c3_p3_wr_mask                           :  std_logic_vector(3 downto 0);
signal c3_p3_wr_data                           :  std_logic_vector(31 downto 0);
signal c3_p3_wr_full                           :  std_logic;
signal c3_p3_wr_empty                          :  std_logic;
signal c3_p3_wr_count                          :  std_logic_vector(6 downto 0);
signal c3_p3_wr_underrun                       :  std_logic;
signal c3_p3_wr_error                          :  std_logic;
signal rst                          :  std_logic;


type mystates is (s_reset,s_write,s_read);

signal state : mystates;
signal counter: std_logic_vector(3 downto 0);
signal counter2: std_logic_vector(23 downto 0);

begin
rst <= not rst_n;

u_ramtest : ramtest
    generic map (
    C3_P0_MASK_SIZE => C3_P0_MASK_SIZE,
    C3_P0_DATA_PORT_SIZE => C3_P0_DATA_PORT_SIZE,
    C3_P1_MASK_SIZE => C3_P1_MASK_SIZE,
    C3_P1_DATA_PORT_SIZE => C3_P1_DATA_PORT_SIZE,
    C3_MEMCLK_PERIOD => C3_MEMCLK_PERIOD,
    C3_RST_ACT_LOW => C3_RST_ACT_LOW,
    C3_INPUT_CLK_TYPE => C3_INPUT_CLK_TYPE,
    C3_CALIB_SOFT_IP => C3_CALIB_SOFT_IP,
    C3_SIMULATION => C3_SIMULATION,
    DEBUG_EN => DEBUG_EN,
    C3_MEM_ADDR_ORDER => C3_MEM_ADDR_ORDER,
    C3_NUM_DQ_PINS => C3_NUM_DQ_PINS,
    C3_MEM_ADDR_WIDTH => C3_MEM_ADDR_WIDTH,
    C3_MEM_BANKADDR_WIDTH => C3_MEM_BANKADDR_WIDTH
)
    port map (

    c3_sys_clk  =>         clk,
  c3_sys_rst_i    =>       rst,                        

  mcb3_dram_dq       =>    mcb3_dram_dq,  
  mcb3_dram_a        =>    mcb3_dram_a,  
  mcb3_dram_ba       =>    mcb3_dram_ba,
  mcb3_dram_ras_n    =>    mcb3_dram_ras_n,                        
  mcb3_dram_cas_n    =>    mcb3_dram_cas_n,                        
  mcb3_dram_we_n     =>    mcb3_dram_we_n,                          
  
  mcb3_dram_cke      =>    mcb3_dram_cke,                          
  mcb3_dram_ck       =>    mcb3_dram_ck,                          
  mcb3_dram_ck_n     =>    mcb3_dram_ck_n,       
  mcb3_dram_dqs      =>    mcb3_dram_dqs,                          
  mcb3_dram_dqs_n  =>      mcb3_dram_dqs_n,
  mcb3_dram_udqs  =>       mcb3_dram_udqs,    -- for X16 parts           
  mcb3_dram_udqs_n    =>   mcb3_dram_udqs_n,  -- for X16 parts
  mcb3_dram_udm  =>        mcb3_dram_udm,     -- for X16 parts
  mcb3_dram_dm  =>       mcb3_dram_dm,
  
	c3_clk0	=>	        c3_clk0, --output 
	c3_rst0		=>        c3_rst0, --output


	c3_calib_done      =>    c3_calib_done, 
	mcb3_rzq        =>            mcb3_rzq,

	mcb3_zio        =>            mcb3_zio,

	c3_p2_cmd_clk                           =>  c3_clk0,
   c3_p2_cmd_en                            =>  c3_p2_cmd_en,
   c3_p2_cmd_instr                         =>  c3_p2_cmd_instr,
   c3_p2_cmd_bl                            =>  c3_p2_cmd_bl,
   c3_p2_cmd_byte_addr                     =>  c3_p2_cmd_byte_addr,
   c3_p2_cmd_empty                         =>  c3_p2_cmd_empty,
   c3_p2_cmd_full                          =>  c3_p2_cmd_full,
   c3_p2_rd_clk                            =>  c3_clk0,
   c3_p2_rd_en                             =>  c3_p2_rd_en,
   c3_p2_rd_data                           =>  c3_p2_rd_data,
   c3_p2_rd_full                           =>  c3_p2_rd_full,
   c3_p2_rd_empty                          =>  c3_p2_rd_empty,
   c3_p2_rd_count                          =>  c3_p2_rd_count,
   c3_p2_rd_overflow                       =>  c3_p2_rd_overflow,
   c3_p2_rd_error                          =>  c3_p2_rd_error,
   c3_p3_cmd_clk                           =>  c3_clk0,
   c3_p3_cmd_en                            =>  c3_p3_cmd_en,
   c3_p3_cmd_instr                         =>  c3_p3_cmd_instr,
   c3_p3_cmd_bl                            =>  c3_p3_cmd_bl,
   c3_p3_cmd_byte_addr                     =>  c3_p3_cmd_byte_addr,
   c3_p3_cmd_empty                         =>  c3_p3_cmd_empty,
   c3_p3_cmd_full                          =>  c3_p3_cmd_full,
   c3_p3_wr_clk                            =>  c3_clk0,
   c3_p3_wr_en                             =>  c3_p3_wr_en,
   c3_p3_wr_mask                           =>  c3_p3_wr_mask,
   c3_p3_wr_data                           =>  c3_p3_wr_data,
   c3_p3_wr_full                           =>  c3_p3_wr_full,
   c3_p3_wr_empty                          =>  c3_p3_wr_empty,
   c3_p3_wr_count                          =>  c3_p3_wr_count,
   c3_p3_wr_underrun                       =>  c3_p3_wr_underrun,
   c3_p3_wr_error                          =>  c3_p3_wr_error
);



process(c3_clk0,rst_n)
begin


if rst_n = '0' then
state <= s_reset;
elsif rising_edge(c3_clk0) then
led(7) <= counter2(23);
led(6) <= c3_p2_rd_empty;

case state is 

when s_reset =>
	counter <= (others => '0');
	counter2 <= (others => '0');
	if (c3_calib_done = '1' ) then
		led(0) <= '1';
		led(7 downto 1) <= (others => '0');
		state <= s_write;
	else
		led(0) <= '0';
		led(7 downto 1) <= (others => '1');
	end if;
when s_write =>

	counter <= counter + 1;
	counter2 <= counter2 + 1;
	
	
	if counter = X"0" then
		c3_p3_wr_en <= '1'; 
		c3_p3_wr_data <= X"00000001"; 
	elsif (counter = X"1") then
		c3_p3_wr_data <= X"00000002"; 
	elsif (counter = X"2") then
		c3_p3_wr_data <= X"00000003"; 	
	elsif (counter = X"3") then
		c3_p3_wr_data <= X"00000004"; 	
	elsif (counter = X"4") then
		c3_p3_wr_en <= '0';	
	elsif (counter = X"5") then
		c3_p3_cmd_instr <= (others => '0'); -- prepare to write
		c3_p3_cmd_bl <= "000100"; --total words to write
		c3_p3_cmd_byte_addr <= (others => '0'); -- address 
	elsif (counter = X"6") then
		c3_p3_cmd_en <= '1'; --Write to command FIFO
	elsif (counter = X"7") then
		c3_p3_cmd_en <= '0'; -- stop Write to command FIFO
	elsif (counter = X"8") then
		state <= s_read;
		counter <= (others => '0');
	end if;
when s_read =>
	counter <= counter + 1;
	
	if counter = X"0" then
		c3_p2_cmd_instr <= "001"; -- prepare to read
		c3_p2_cmd_bl <= "000100"; --total words to read
		c3_p2_cmd_byte_addr <= (others => '0'); -- address 

	elsif (counter = X"1") then
		c3_p2_cmd_en <= '1';	
	elsif (counter = X"2") then
		c3_p2_cmd_en <= '0';
	elsif (counter = X"3") then
		c3_p2_rd_en <= '1';
	elsif (counter = X"4") then
		if ( c3_p2_rd_data = X"00000002" ) then
			led(1) <= '1';
		end if;
	
	elsif (counter = X"5") then
		if ( c3_p2_rd_data = X"00000002" ) then
			led(2) <= '1';
		end if;
		
	elsif (counter = X"6") then
		if ( c3_p2_rd_data = X"00000003" ) then
			led(3) <= '1';
		end if;	
	
	elsif (counter = X"7") then
		if ( c3_p2_rd_data = X"00000004" ) then
			led(4) <= '1';
		end if;	
		c3_p2_rd_en <= '0';	 
	elsif (counter = X"8") then
		state <= s_write;
		counter <= (others => '0');
	end if;
	
end case;
end if;


end process;














end rtl;

