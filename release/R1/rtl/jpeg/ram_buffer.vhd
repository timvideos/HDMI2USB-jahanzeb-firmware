-- Copyright (c) 2013, Jahanzeb Ahmad
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without modification, 
-- are permitted provided that the following conditions are met:

 -- * Redistributions of source code must retain the above copyright notice, 
   -- this list of conditions and the following disclaimer.
 -- * Redistributions in binary form must reproduce the above copyright notice, 
   -- this list of conditions and the following disclaimer in the documentation and/or 
   -- other materials provided with the distribution.

   -- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
   -- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
   -- OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
   -- SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
   -- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
   -- LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
   -- PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
   -- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
   -- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
   -- POSSIBILITY OF SUCH DAMAGE.

 -- * http://opensource.org/licenses/MIT
 -- * http://copyfree.org/licenses/mit/license.txt

LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;		 
USE ieee.std_logic_unsigned.all;

entity ram_buffer is
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
	iram_wdata_in      : in std_logic_vector(23 downto 0);
	iram_wren_in       : in std_logic;
	iram_clk		   : in std_logic; 
	store_img		   : in std_logic; 
	read_img		   : in std_logic; 	
	
	iram_wdata_out     : out std_logic_vector(23 downto 0);
	iram_wren_out      : out std_logic;
	iram_fifo_afull    : in std_logic;
	
	clk	: in std_logic;
	clk_jpg	: in std_logic;
	rst 	: in std_logic;
	error	: out std_logic
);
end ram_buffer;

architecture rtl of ram_buffer is
component ddr2ram
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
    port (
   mcb3_dram_dq                            : inout  std_logic_vector(C3_NUM_DQ_PINS-1 downto 0);
   mcb3_dram_a                             : out std_logic_vector(C3_MEM_ADDR_WIDTH-1 downto 0);
   mcb3_dram_ba                            : out std_logic_vector(C3_MEM_BANKADDR_WIDTH-1 downto 0);
   mcb3_dram_ras_n                         : out std_logic;
   mcb3_dram_cas_n                         : out std_logic;
   mcb3_dram_we_n                          : out std_logic;
   mcb3_dram_odt                           : out std_logic;
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
COMPONENT rgbfifo
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
    full : OUT STD_LOGIC;
    almost_full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    almost_empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC
  );
END COMPONENT;

-------------------------------------------------------------------------------
signal c3_calib_done                           :  std_logic;
signal c3_clk0                                 :  std_logic;
signal c3_rst0                                 :  std_logic;

signal c3_p2_cmd_en                            :  std_logic;
signal c3_p2_cmd_instr                         :  std_logic_vector(2 downto 0);
signal c3_p2_cmd_bl                            :  std_logic_vector(5 downto 0);
signal c3_p2_cmd_byte_addr                     :  std_logic_vector(29 downto 0);
signal c3_p2_cmd_empty                         :  std_logic;
signal c3_p2_cmd_full                          :  std_logic;

signal c3_p2_rd_en                             :  std_logic;
signal c3_p2_rd_data                           :  std_logic_vector(31 downto 0);
signal c3_p2_rd_full                           :  std_logic;
signal c3_p2_rd_empty                          :  std_logic;
signal c3_p2_rd_count                          :  std_logic_vector(6 downto 0);
signal c3_p2_rd_overflow                       :  std_logic;
signal c3_p2_rd_error                          :  std_logic;

signal c3_p3_cmd_en                            :  std_logic;
signal c3_p3_cmd_instr                         :  std_logic_vector(2 downto 0);
signal c3_p3_cmd_bl                            :  std_logic_vector(5 downto 0);
signal c3_p3_cmd_byte_addr                     :  std_logic_vector(29 downto 0);
signal c3_p3_cmd_empty                         :  std_logic;
signal c3_p3_cmd_full                          :  std_logic;

signal c3_p3_wr_en                             :  std_logic;
signal c3_p3_wr_mask                           :  std_logic_vector(3 downto 0):="0000";
signal c3_p3_wr_data                           :  std_logic_vector(31 downto 0);
signal c3_p3_wr_full                           :  std_logic;
signal c3_p3_wr_empty                          :  std_logic;
signal c3_p3_wr_count                          :  std_logic_vector(6 downto 0);
signal c3_p3_wr_underrun                       :  std_logic;
signal c3_p3_wr_error                          :  std_logic;

signal wr_en : std_logic;
signal rd_en : std_logic;
signal full : std_logic;
signal almost_full : std_logic;
signal empty : std_logic;
signal almost_empty : std_logic;
signal valid : std_logic;

signal din : std_logic_vector(23 downto 0);
signal dout : std_logic_vector(23 downto 0);

signal wrAdd : std_logic_vector(29 downto 0);
signal rdAdd : std_logic_vector(29 downto 0);

signal counter_rd : std_logic_vector(7 downto 0);
signal counter_wr : std_logic_vector(7 downto 0);

type write_states is (write_cmd,reset,write_data,write_wait,write_cmd_skip);
signal wr_state : write_states;

type read_states is (read_cmd,reset,read_data,read_wait,wait_data);
signal rd_state : read_states;

begin -- Architecture 


-----------------------------------------------------------------
-- ram read 
ramread : process(rst,clk_jpg)
begin
if rst = '1' then
	c3_p2_cmd_en <= '0'; -- stop read command fifo
	c3_p2_rd_en <= '0'; -- read data fifo
	iram_wren_out <= '0';
	counter_rd <= (others => '0');		
	rdAdd <= "000000000000000000000000000000";	
	c3_p2_cmd_byte_addr <= (others => '0');
	rd_state <= reset;
	
elsif rising_edge(clk_jpg) then -- read_img

	c3_p2_cmd_instr <= "001"; -- prepare to read
	c3_p2_cmd_bl <= "111111"; --total words to read (must be -1 from total)

	c3_p2_cmd_en <= '0'; -- stop read command fifo
	c3_p2_rd_en <= '0'; -- read data fifo
	iram_wren_out <= '0';
	
	case rd_state is

		when  reset =>
			counter_rd <= (others => '0');		
			rdAdd <= (others => '0');
			if (c3_calib_done = '1' ) then
				rd_state <= read_cmd;
			end if;
	
		when read_cmd =>
			if read_img = '1' then
				rd_state <= wait_data;
				c3_p2_cmd_byte_addr <= rdAdd; -- address increments in 4
				c3_p2_cmd_en <= '1';			
				rdAdd <= rdAdd +256;
			else 
				rd_state <= reset;
			end if;
		
		when  wait_data =>
			if c3_p2_rd_full = '1' then
				rd_state <= read_data;
				counter_rd <= (others => '0');
			end if;
			
		when  read_data =>
			if iram_fifo_afull = '0' then
				iram_wdata_out <= c3_p2_rd_data(23 downto 0);
				iram_wren_out <= '1';
				c3_p2_rd_en <= '1';
				counter_rd <= counter_rd +1;
				if counter_rd = 63 then
					rd_state <= read_cmd;
				end if;
			end if;

		when others =>
			rd_state <= reset;
			
	end case;	

end if; -- clk
end process;

-- ram write
ramwrite: process(rst,clk_jpg)
begin
if rst = '1' then
	wrAdd <= "000000000000000000000000000000";
	counter_wr <= (others => '0');
	c3_p3_cmd_byte_addr <= (others => '0');
	c3_p3_cmd_en <= '0'; -- stop Write to command FIFO
	c3_p3_wr_en <= '0'; -- write data fifo
	rd_en <= '0';	
	wr_state <= reset;
elsif rising_edge(clk_jpg) then

	c3_p3_cmd_en <= '0'; -- stop Write to command FIFO
	c3_p3_wr_en <= '0'; -- write data fifo
	rd_en <= '0';
	
	case wr_state is

		when  reset =>
			wrAdd <= (others => '0');
			counter_wr <= (others => '0');		
			if (c3_calib_done = '1' ) then
				wr_state <= write_data;				
			end if;
			
		when  write_data =>			
			if store_img = '1' then
				if almost_empty = '0' then 					
					rd_en <= '1';
					c3_p3_wr_en <= '1';
					c3_p3_wr_data <=  ("00000000" & dout);
					counter_wr <= counter_wr +1;
					if counter_wr = 63 then
						wr_state <= write_cmd_skip;
						counter_wr <= (others => '0');
					end if;
				end if;
			else 
				wr_state <= reset;
			end if;
			
		when  write_cmd_skip =>
			if c3_p3_wr_full = '1' then
				wr_state <= write_cmd;			
			end if;
				
		when  write_cmd =>
			wr_state <= write_wait;
			c3_p3_cmd_instr <= "000"; -- prepare to write
			c3_p3_cmd_bl <= "111111"; --total words to write
			c3_p3_cmd_byte_addr <= wrAdd; -- address 
			c3_p3_cmd_en <= '1'; --Write to command FIFO
			wrAdd <= wrAdd +256;

		when write_wait =>
			if c3_p3_wr_empty = '1' then
				wr_state <= write_data;
				counter_wr <= (others => '0');
			end if;
		
		when others =>
			wr_state <= reset;
			
	end case;	
	
end if; -- clk
end process ramwrite;




-- fifo write
fifowrite: process(rst,iram_clk)
begin
if rst = '1' then
	wr_en <= '0';
	din <= (others => '0');
elsif rising_edge(iram_clk) then
	wr_en <= '0';

	-- if store_img = '1' then
	if store_img = '1' then
		if iram_wren_in = '1' then
		-- if almost_full = '0' then
			din <= (iram_wdata_in(7 downto 0) & iram_wdata_in(15 downto 8) & iram_wdata_in(23 downto 16));
			-- din <= din +1;
			wr_en <= '1';
		end if;
	else
		din <= (others => '0');
	end if;

end if; -- rst clk
end process fifowrite;

----------------------------------------------------------------- 
rgbfifoComp : rgbfifo
  PORT MAP (
    rst => (not store_img),
    wr_clk => iram_clk,
    rd_clk => clk_jpg,
    din => din,
    wr_en => wr_en,
    rd_en => rd_en,
    dout => dout,
    full => full,
    almost_full => almost_full,
    empty => empty,
    almost_empty => almost_empty,
    valid => valid
  );

-- --------temp ---------------------------------------------------------------------------------
error <= (not c3_calib_done) or c3_p2_rd_error or c3_p2_rd_overflow or c3_p3_wr_underrun or c3_p3_wr_error or almost_full;


---------------------------------------------------

ramComp : ddr2ram
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

c3_sys_clk  		=>    clk,
c3_sys_rst_i    	=>    rst,
mcb3_dram_dq       	=>    mcb3_dram_dq,  
mcb3_dram_a        	=>    mcb3_dram_a,  
mcb3_dram_ba       	=>    mcb3_dram_ba,
mcb3_dram_ras_n    	=>    mcb3_dram_ras_n,                        
mcb3_dram_cas_n    	=>    mcb3_dram_cas_n,                        
mcb3_dram_we_n     	=>    mcb3_dram_we_n,                          
mcb3_dram_odt    	=>    mcb3_dram_odt,
mcb3_dram_cke      	=>    mcb3_dram_cke,                          
mcb3_dram_ck       	=>    mcb3_dram_ck,                          
mcb3_dram_ck_n     	=>    mcb3_dram_ck_n,       
mcb3_dram_dqs      	=>    mcb3_dram_dqs,                          
mcb3_dram_dqs_n  	=>    mcb3_dram_dqs_n,
mcb3_dram_udqs  	=>    mcb3_dram_udqs,    -- for X16 parts           
mcb3_dram_udqs_n    =>    mcb3_dram_udqs_n,  -- for X16 parts
mcb3_dram_udm  		=>    mcb3_dram_udm,     -- for X16 parts
mcb3_dram_dm  		=>    mcb3_dram_dm,
c3_clk0				=>	  c3_clk0,
c3_rst0				=>    c3_rst0,
c3_calib_done      	=>    c3_calib_done,
mcb3_rzq        	=>    mcb3_rzq,
mcb3_zio        	=>    mcb3_zio,

-- read port
c3_p2_cmd_clk                           =>  clk_jpg,
c3_p2_cmd_en                            =>  c3_p2_cmd_en,
c3_p2_cmd_instr                         =>  c3_p2_cmd_instr,
c3_p2_cmd_bl                            =>  c3_p2_cmd_bl,
c3_p2_cmd_byte_addr                     =>  c3_p2_cmd_byte_addr,
c3_p2_cmd_empty                         =>  c3_p2_cmd_empty,
c3_p2_cmd_full                          =>  c3_p2_cmd_full,

c3_p2_rd_clk                            =>  clk_jpg,
c3_p2_rd_en                             =>  c3_p2_rd_en,
c3_p2_rd_data                           =>  c3_p2_rd_data,
c3_p2_rd_full                           =>  c3_p2_rd_full,
c3_p2_rd_empty                          =>  c3_p2_rd_empty,
c3_p2_rd_count                          =>  c3_p2_rd_count,
c3_p2_rd_overflow                       =>  c3_p2_rd_overflow,
c3_p2_rd_error                          =>  c3_p2_rd_error,

-- write port
c3_p3_cmd_clk                           =>  clk_jpg,
c3_p3_cmd_en                            =>  c3_p3_cmd_en,
c3_p3_cmd_instr                         =>  c3_p3_cmd_instr,
c3_p3_cmd_bl                            =>  c3_p3_cmd_bl,
c3_p3_cmd_byte_addr                     =>  c3_p3_cmd_byte_addr,
c3_p3_cmd_empty                         =>  c3_p3_cmd_empty,
c3_p3_cmd_full                          =>  c3_p3_cmd_full,

c3_p3_wr_clk                            =>  clk_jpg,
c3_p3_wr_en                             =>  c3_p3_wr_en,
c3_p3_wr_mask                           =>  c3_p3_wr_mask,
c3_p3_wr_data                           =>  c3_p3_wr_data,
c3_p3_wr_full                           =>  c3_p3_wr_full,
c3_p3_wr_empty                          =>  c3_p3_wr_empty,
c3_p3_wr_count                          =>  c3_p3_wr_count,
c3_p3_wr_underrun                       =>  c3_p3_wr_underrun,
c3_p3_wr_error                          =>  c3_p3_wr_error
);

end rtl;

