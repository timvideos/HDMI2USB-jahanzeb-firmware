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


library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use ieee.numeric_std.all;
  use IEEE.STD_LOGIC_TEXTIO.ALL;
  
library STD;
  use STD.TEXTIO.ALL;  
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY jpeg_encoder_top_tb IS
END jpeg_encoder_top_tb;
 
ARCHITECTURE behavior OF jpeg_encoder_top_tb IS 
   type char_file is file of character;

  file f_capture           : text;
  file f_capture_bin       : char_file;
  constant CAPTURE_ORAM    : string := "..\sim\OUT_RAM.txt";
  constant CAPTURE_BIN     : string := "..\sim\test_out.jpg";
 
    -- Component Declaration for the Unit Under Test (UUT)
component jpeg_encoder_top is
  port 
  (
  

        clk                : in  std_logic;
        rst_n              : in  std_logic;
                
        -- IMAGE RAM
        iram_wdata         : in  std_logic_vector(23 downto 0);
        iram_wren          : in  std_logic;
		iram_fifo_afull    : out std_logic; 
		store_img		   : out std_logic; 
		read_img		   : out std_logic; 
        
        -- OUT RAM
        ram_byte           : out std_logic_vector(7 downto 0);
        ram_wren           : out std_logic;
        ram_wraddr         : out std_logic_vector(23 downto 0);
        outif_almost_full  : in  std_logic;
		resx 			   : in std_logic_vector(15  DOWNTO 0);
		resy			   : in std_logic_vector(15 DOWNTO 0);
		
		-- others
		rgb_start 			: in std_logic;
		done			   	: out std_logic;
		error				: out std_logic;
		jpeg_busy		   	: out std_logic;
		jpeg_enable		   	: in std_logic
		
   );
end component jpeg_encoder_top;
   
   
	
   --Inputs
   -- signal clk : std_logic := '0';
   -- signal rst_n : std_logic := '0';
   signal sda_byte : std_logic_vector(7 downto 0) := (others => '0');
   signal sda_en : std_logic := '0';
   signal jpeg_byte : std_logic_vector(7 downto 0) := (others => '0');
   signal jpeg_clk : std_logic := '0';
   signal jpeg_en : std_logic := '1';
   signal flag_full : std_logic := '1';
   signal flag_empty : std_logic := '0';
   signal ifclk : std_logic := '0';
   -- signal resX : std_logic_vector(15 downto 0) := (others => '0');
   -- signal resY : std_logic_vector(15 downto 0) := (others => '0');
   -- signal jpeg_enable : std_logic := '0';
   signal jpeg_error : std_logic := '0';

	--BiDirs
   signal fdata : std_logic_vector(7 downto 0):= (others => '0');

 	--Outputs
   signal faddr : std_logic_vector(1 downto 0):= (others => '0');
   signal slwr : std_logic:= '0';
   signal slrd : std_logic:= '0';
   signal sloe : std_logic:= '0';
   signal pktend : std_logic:= '0';
   signal jpeg_fifo_full : std_logic:= '0';

   
	

   --Inputs
   signal jpeg_enable : std_logic := '0';
   signal clk : std_logic := '0';
   signal pclk : std_logic := '0';
   signal rst_n : std_logic := '0';
   signal iram_wdata : std_logic_vector(23 downto 0) := (others => '0');
   signal iram_wren : std_logic := '0';
   signal outif_almost_full : std_logic := '0';
   signal resx : std_logic_vector(15 downto 0) := (others => '0');
   signal resy : std_logic_vector(15 downto 0) := (others => '0');
   signal start : std_logic := '0';
   signal jpeg_busy : std_logic := '0';

 	--Outputs
   -- signal iram_fifo_afull : std_logic:='0';
   signal ram_byte : std_logic_vector(7 downto 0):=(others => '0');
   signal ram_wren : std_logic:= '0';
   signal ram_wraddr : std_logic_vector(23 downto 0):=(others => '0');
   signal total_send : std_logic_vector(23 downto 0):=(others => '0');
   signal done : std_logic:= '0';
   signal w_start: std_logic:='0';
   signal w_start2: std_logic:='0';
   signal sim: std_logic:='1';

   signal error: std_logic:= '0';
   signal rgb_start: std_logic:= '0';
   signal read_img: std_logic:= '0';
   signal store_img: std_logic:= '0';
   signal iram_fifo_afull: std_logic:= '0';

   -- Clock period definitions
   constant clk_period : time := 9 ns; -- jpeg clk 111.11 MHz(syntheis acheived)
   constant pclk_period : time := 20.83 ns; -- ~48 MHz
   -- constant pclk_period : time :=  13.4680 ns; -- 74.25 MHz // 720p60
   -- constant pclk_period : time :=  7 ns; 
 
BEGIN
----------------------------------
 p_capture : process
    variable fLine           : line;
    variable fLine_bin       : line;
  begin
    file_open(f_capture, CAPTURE_ORAM, write_mode);
    file_open(f_capture_bin, CAPTURE_BIN, write_mode);
    
    while sim = '1' loop--done /= '1' loop
      wait until rising_edge(clk); -- in this tb ifclk and pclk are same just for simulation it will not make any effect on simulation
	  -- wait for 1 ns;
      
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
---------------------------------------------       
		
   -- uut_jpeg: jpeg_encoder_top_dummy PORT MAP (
   uut_jpeg: jpeg_encoder_top PORT MAP (
        clk      => clk,      
        rst_n    => rst_n,      
                
        -- IMAGE RAM
        iram_wdata   => iram_wdata,  
        iram_wren      => iram_wren,
		iram_fifo_afull=> iram_fifo_afull,
		store_img		=> store_img,
		read_img		=> read_img,
        
        -- OUT RAM
        ram_byte        => ram_byte,
        ram_wren        => ram_wren,
        ram_wraddr      => ram_wraddr,
        outif_almost_full=> outif_almost_full,
		resx 			 => resX,
		resy			 => resY,
		
		-- others
		rgb_start 		=> start,
		done			=> done,
		error			=> error,
		jpeg_busy		=> jpeg_busy,
		jpeg_enable		=> jpeg_enable
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;   
   
   pclk_process :process
   begin
		pclk <= '0';
		wait for pclk_period/2;
		pclk <= '1';
		wait for pclk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		rst_n <= '0';
      wait for 100 ns;	
		rst_n <= '1';
		-- resx <= X"0500";resy <= X"02D0"; -- 1280×720  (921600)
		resx <= X"0400";resy <= X"0300"; -- 1024x768 (786432)
		assert false report "Start of simulation" severity warning;
		
		wait for pclk_period*1024;
		jpeg_enable <= '1';
		
		

		

		wait for pclk_period*10;
		start <= '1';	
		wait for pclk_period;
		start <= '0';
		
		wait for pclk_period*1024*2;	

		
		start <= '1';
		wait for pclk_period*(10);
		start <= '0';
		
		wait for pclk_period*1024*20;		

		w_start <= '1';		
		
		wait for pclk_period*1024*20;
		wait until rising_edge(clk);		
		outif_almost_full <= '1';
		
		wait for pclk_period*1024*20;
		wait until rising_edge(clk);		
		outif_almost_full <= '0';	
		
		wait until (error = '1' or done = '1');

		assert false report "1 Image Encoded" severity warning;

		wait for pclk_period*(10000);
		sim <= '0';
		wait for pclk_period*(10000);
		assert false report "end of simulation" severity failure;
		

      wait;
   end process;
   
data_proc:process(clk)
	
   begin
   if rising_edge(clk) then
   
   
	iram_wren <= '0';	
	if w_start = '1' and w_start2 = '0' and iram_fifo_afull = '0' and read_img = '1' then
	
		 if total_send = std_logic_vector(unsigned(resx)*unsigned(resy)) then
			w_start2 <= '1';
		else			
			total_send <= std_logic_vector(unsigned(total_send) + 1);
			iram_wdata <= total_send(23 downto 0);			
			iram_wren <= '1';	
		end if;
	end if;
	end if;
	
   end process;
END;
