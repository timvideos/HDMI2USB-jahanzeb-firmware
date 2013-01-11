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
LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;		 
USE ieee.std_logic_unsigned.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY jpeg_encoder_top_tb IS
END jpeg_encoder_top_tb;
 
ARCHITECTURE behavior OF jpeg_encoder_top_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 COMPONENT jpeg_encoder_top
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
   signal fdata : std_logic_vector(7 downto 0);

 	--Outputs
   signal faddr : std_logic_vector(1 downto 0);
   signal slwr : std_logic;
   signal slrd : std_logic;
   signal sloe : std_logic;
   signal pktend : std_logic;
   signal jpeg_fifo_full : std_logic;

   
	

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
   signal ram_byte : std_logic_vector(7 downto 0);
   signal ram_wren : std_logic;
   signal ram_wraddr : std_logic_vector(23 downto 0);
   signal total_send : std_logic_vector(23 downto 0):=(others => '0');
   signal done : std_logic;
   signal w_start: std_logic:='0';
   signal w_start2: std_logic:='0';

   signal error: std_logic:= '0';
   -- Clock period definitions
   constant clk_period : time := 20 ns; -- jpeg clk
   constant pclk_period : time := 20.83 ns;
 
BEGIN
       
	-- Instantiate the Unit Under Test (UUT)
	   uut2: usb PORT MAP (
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
		
   uut: jpeg_encoder_top PORT MAP (
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
		w_start <= '1';
		
		wait for pclk_period*(250+10);
		wait until rising_edge(pclk);
		flag_full <= '0';
		wait for pclk_period*10;
		flag_full <= '1';		
		wait until (error = '1' or done = '1');
		wait for 100 ns;
		
		assert false report "end of simulation" severity failure;
		

      wait;
   end process;
   
   data_proc:process(pclk)
   begin
   if rising_edge(pclk) then
	
	if w_start = '1' and w_start2 = '0' then
	iram_wren <= '0';	
		 if total_send = (resx*resy) then
		--if total_send = (resx*x"20") then
			w_start2 <= '1';
		else 
			total_send <= total_send + X"01";
			iram_wdata <= total_send(23 downto 0);--(others =>'1');
			iram_wren <= not iram_wren;	
			-- iram_wren <= '1';	
		end if;
	end if;
	end if;
	
   end process;

END;
