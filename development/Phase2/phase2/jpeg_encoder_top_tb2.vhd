--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:31:03 12/27/2012
-- Design Name:   
-- Module Name:   D:/Dropbox/vWorker/phase2/jpeg_encoder_top_tb.vhd
-- Project Name:  phase2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: jpeg_encoder_top
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use ieee.numeric_std.all;
  use IEEE.STD_LOGIC_TEXTIO.ALL;
  
library STD;
  use STD.TEXTIO.ALL;  
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY jpeg_encoder_top_tb2 IS
END jpeg_encoder_top_tb2;
 
ARCHITECTURE behavior OF jpeg_encoder_top_tb2 IS 
   type char_file is file of character;

  file f_capture           : text;
  file f_capture_bin       : char_file;
  constant CAPTURE_ORAM    : string := "D:\Dropbox\vWorker\phase2\matlab\OUT_RAM.txt";
  constant CAPTURE_BIN     : string := "D:\Dropbox\vWorker\phase2\matlab\test_out.jpg";
 
    -- Component Declaration for the Unit Under Test (UUT)
 COMPONENT jpeg_encoder_top_dummy
  port 
  (
        clk                : in  std_logic;
        rst_n              : in  std_logic;
        -- encoder_ready      : out  std_logic;
        
        -- IMAGE RAM
        iram_wdata         : in  std_logic_vector(23 downto 0);
        iram_wren          : in  std_logic;
        iram_clk		    : in std_logic; 
        
        -- OUT RAM
        ram_byte           : out std_logic_vector(7 downto 0);
        ram_wren           : out std_logic;
        ram_wraddr         : out std_logic_vector(23 downto 0);
        outif_almost_full  : in  std_logic;
		resx 			   : in std_logic_vector(15  DOWNTO 0);
		resy			   : in std_logic_vector(15 DOWNTO 0);
		
		-- others
		rgb_start 			   : in std_logic;
		done			   : out std_logic;
		error				: out std_logic;
		jpeg_busy		   : out std_logic;
		jpeg_enable		   : in std_logic
		
   );
   END COMPONENT;
   
   COMPONENT usb
    PORT(
         clk : IN  std_logic;
         rst_n : IN  std_logic;
         sda_byte : IN  std_logic_vector(7 downto 0);
         sda_en : IN  std_logic;
         jpeg_byte : IN  std_logic_vector(7 downto 0);
         jpeg_clk : IN  std_logic;
         jpeg_en : IN  std_logic;
         fdata : INOUT  std_logic_vector(7 downto 0);
         flag_full : IN  std_logic;
         flag_empty : IN  std_logic;
         faddr : OUT  std_logic_vector(1 downto 0);
         slwr : OUT  std_logic;
         slrd : OUT  std_logic;
         sloe : OUT  std_logic;
         pktend : OUT  std_logic;
         ifclk : IN  std_logic;
         resX : IN  std_logic_vector(15 downto 0);
         resY : IN  std_logic_vector(15 downto 0);
         jpeg_enable : IN  std_logic;
         jpeg_error : IN  std_logic;
         jpeg_fifo_full : OUT  std_logic
        );
    END COMPONENT;
    
	
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
   -- Clock period definitions
   -- constant clk_period : time := 10 ns; -- jpeg clk 100MHz
   -- constant clk_period : time := 7.69231 ns; -- jpeg clk 130MHz
   constant clk_period : time := 9 ns; -- jpeg clk 111.11 MHz(syntheis acheived)
   constant pclk_period : time := 20.83 ns; -- ~48 MHz
   -- constant pclk_period : time :=  13.4680 ns; -- 74.25 MHz // 720p60
 
BEGIN
----------------------------------
 p_capture : process
    variable fLine           : line;
    variable fLine_bin       : line;
  begin
    file_open(f_capture, CAPTURE_ORAM, write_mode);
    file_open(f_capture_bin, CAPTURE_BIN, write_mode);
    
    while sim = '1' loop--done /= '1' loop
      wait until rising_edge(pclk); -- in this tb ifclk and pclk are same just for simulation it will not make any effect on simulation
	  -- wait for 1 ns;
      
      if slwr = '0' then
        hwrite(fLine, fdata);
        writeline(f_capture, fLine);
        
        write(f_capture_bin, CHARACTER'VAL(to_integer(unsigned(fdata))));
        
      end if;
    
    end loop;
    
    file_close(f_capture);
    file_close(f_capture_bin);
  
    wait;  
  end process;
---------------------------------------------       
	-- Instantiate the Unit Under Test (UUT)
	   uut_usb: usb_mjpeg PORT MAP (
          clk => clk,
          rst_n => rst_n,
          sda_byte => sda_byte,
          sda_en => sda_en,
          jpeg_byte => ram_byte,
          jpeg_clk => clk,
          jpeg_en => ram_wren,
          fdata => fdata,
          flag_full => flag_full,
          flag_empty => flag_empty,
          faddr => faddr,
          slwr => slwr,
          slrd => slrd,
          sloe => sloe,
          pktend => pktend,
          ifclk => pclk,
          resX => resX,
          resY => resY,
          jpeg_enable => jpeg_enable,
          jpeg_error => error,
          jpeg_fifo_full => jpeg_fifo_full
        );
		
   uut_jpeg: jpeg_encoder_top_dummy PORT MAP (
          clk => clk,
          rst_n => rst_n,
          iram_wdata => iram_wdata,
          iram_wren => iram_wren,
		  iram_clk => pclk,
         -- iram_fifo_afull => iram_fifo_afull,
          ram_byte => ram_byte,
          ram_wren => ram_wren,
          ram_wraddr => ram_wraddr,
          outif_almost_full => jpeg_fifo_full,
          resx => resx,
          resy => resy,
          rgb_start => start,
          done => done,
		  error => error,	  
		  jpeg_enable => jpeg_enable,	  
		  jpeg_busy => jpeg_busy
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
		-- resx <= X"0020";resy <= X"0020"; -- 32x32
		
		wait for pclk_period*1024;
		jpeg_enable <= '1';
		wait for pclk_period*10;
		start <= '1';	
		wait for pclk_period;
		start <= '0';

		wait for pclk_period*1000;
		start <= '1';	
		wait for pclk_period;
		start <= '0';

		wait for pclk_period*10;
		start <= '1';	
		wait for pclk_period;
		start <= '0';
		wait for pclk_period*1024;		
		start <= '1';
		wait for pclk_period*(10);
		start <= '0';
		w_start <= '1';
		
		
		flag_full <= '0';		
		
		wait for pclk_period*1024;		
		
		flag_full <= '1';
		
		wait for pclk_period*102;		
		
		flag_full <= '0';

		wait for pclk_period*124;		
		
		flag_full <= '1';

		wait for pclk_period*14;		
		
		flag_full <= '0';

		wait for pclk_period*14;		
		
		flag_full <= '1';
		
		
		wait until (error = '1' or done = '1');
		wait for pclk_period*(10000);
		sim <= '0';
		wait for pclk_period*(10);
		assert false report "end of simulation" severity failure;
		

      wait;
   end process;
   
data_proc:process(pclk)
	
   begin
   if rising_edge(pclk) then
	
	if w_start = '1' and w_start2 = '0' then
	iram_wren <= '0';	
		 if total_send = std_logic_vector(unsigned(resx)*unsigned(resy)) then
		--if total_send = (resx*x"20") then
			w_start2 <= '1';
		else 
			-- total_send <= total_send + ;
			total_send <= std_logic_vector(unsigned(total_send) + 1);
			iram_wdata <= total_send(23 downto 0);--(others =>'1');
			-- iram_wren <= not iram_wren;	
			iram_wren <= '1';	
		end if;
	end if;
	end if;
	
   end process;
END;
