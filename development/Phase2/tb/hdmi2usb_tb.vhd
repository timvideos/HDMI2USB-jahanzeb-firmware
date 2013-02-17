-- //////////////////////////////////////////////////////////////////////////////
-- /// Copyright (c) 2013, Jahanzeb Ahmad
-- /// All rights reserved.
-- ///
-- /// Redistribution and use in source and binary forms, with or without modification, 
-- /// are permitted provided that the following conditions are met:
-- ///
-- ///  * Redistributions of source code must retain the above copyright notice, 
-- ///    this list of conditions and the following disclaimer.
-- ///  * Redistributions in binary form must reproduce the above copyright notice, 
-- ///    this list of conditions and the following disclaimer in the documentation and/or 
-- ///    other materials provided with the distribution.
-- ///
-- ///    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
-- ///    EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
-- ///    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
-- ///    SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
-- ///    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
-- ///    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
-- ///    PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
-- ///    WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
-- ///    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
-- ///   POSSIBILITY OF SUCH DAMAGE.
-- ///
-- ///
-- ///  * http://opensource.org/licenses/MIT
-- ///  * http://copyfree.org/licenses/mit/license.txt
-- ///
-- //////////////////////////////////////////////////////////////////////////////
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
 
ENTITY hdmi2usb_tb IS
END hdmi2usb_tb;
 
ARCHITECTURE behavior OF hdmi2usb_tb IS 
 
   type char_file is file of character;

  file f_capture           : text;
  file f_capture_bin       : char_file;
  constant CAPTURE_ORAM    : string := "..\sim\OUT_RAM.txt";
  constant CAPTURE_BIN     : string := "..\sim\test_out.jpg";
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT hdmi2usb
    PORT(
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
         pdb : INOUT  std_logic_vector(7 downto 0);
         astb : IN  std_logic;
         dstb : IN  std_logic;
         pwr : IN  std_logic;
         pwait : OUT  std_logic;
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
         ifclk : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal rst_n : std_logic := '0';
   signal clk : std_logic := '0';
   signal RX0_TMDS : std_logic_vector(3 downto 0) := (others => '0');
   signal RX0_TMDSB : std_logic_vector(3 downto 0) := (others => '0');
   signal SW : std_logic_vector(2 downto 0) := (others => '1');
   signal scl_pc : std_logic := '0';
   signal astb : std_logic := '0';
   signal dstb : std_logic := '0';
   signal pwr : std_logic := '0';
   signal flagA : std_logic := '0';
   signal flagB : std_logic := '1';
   signal flagC : std_logic := '0';
   signal ifclk : std_logic := '0';

	--BiDirs
   signal sda_pc : std_logic;
   signal sda_lcd : std_logic;
   signal pdb : std_logic_vector(7 downto 0);
   signal fdata : std_logic_vector(7 downto 0);

 	--Outputs
   signal TX0_TMDS : std_logic_vector(3 downto 0);
   signal TX0_TMDSB : std_logic_vector(3 downto 0);
   signal LED : std_logic_vector(7 downto 0);
   signal scl_lcd : std_logic;
   signal pwait : std_logic;
   signal faddr : std_logic_vector(1 downto 0);
   signal slwr : std_logic;
   signal slrd : std_logic;
   signal sloe : std_logic;
   signal pktend : std_logic;
   signal slcs : std_logic;
   signal done : std_logic:= '0';

   -- Clock period definitions
   constant clk_period : time := 9 ns;
   constant ifclk_period : time := 20.83 ns;
 
BEGIN
----------------------------------
 p_capture : process
    variable fLine           : line;
    variable fLine_bin       : line;
  begin
    file_open(f_capture, CAPTURE_ORAM, write_mode);
    file_open(f_capture_bin, CAPTURE_BIN, write_mode);
    
    while done /= '1' loop
      wait until rising_edge(ifclk);
      
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
   uut: hdmi2usb PORT MAP (
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
          pdb => pdb,
          astb => astb,
          dstb => dstb,
          pwr => pwr,
          pwait => pwait,
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
          ifclk => ifclk
        );

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
		rst_n <= '0';
      wait for 100 ns;	
		rst_n <= '1';

      -- wait for clk_period*10;
		-- done <= '0';
	  -- wait for 70 ms;
		-- done <= '1';
	  -- wait for 1 ms;
      -- insert stimulus here 
	  -- assert false report "end of simulation" severity failure;
	  
      wait;
   end process;

END;
