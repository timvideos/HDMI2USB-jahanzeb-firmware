-- //////////////////////////////////////////////////////////////////////////////
-- /// Copyright (c) 2013, Jahanzeb Ahmad
-- /// All rights reserved.
-- ///
-- // Redistribution and use in source and binary forms, with or without modification, 
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

LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;		 
USE ieee.std_logic_unsigned.all;

-- use ieee.numeric_std.all;

entity jpeg_encoder_top is
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
		rgb_start 			: in std_logic;
		done			   	: out std_logic;
		error				: out std_logic;
		jpeg_busy		   	: out std_logic;
		jpeg_enable		   	: in std_logic
		
   );
end entity jpeg_encoder_top;

architecture RTL of jpeg_encoder_top is


---------------------------------------------------------------------------------
component JpegEnc is
  port 
  (
        CLK                : in  std_logic;
        RST                : in  std_logic;
        
        -- OPB
        OPB_ABus           : in  std_logic_vector(31 downto 0);
        OPB_BE             : in  std_logic_vector(3 downto 0);
        OPB_DBus_in        : in  std_logic_vector(31 downto 0);
        OPB_RNW            : in  std_logic;
        OPB_select         : in  std_logic;
        OPB_DBus_out       : out std_logic_vector(31 downto 0);
        OPB_XferAck        : out std_logic;
        OPB_retry          : out std_logic;
        OPB_toutSup        : out std_logic;
        OPB_errAck         : out std_logic;
        
        --% IMAGE RAM
        iram_wdata         : in  std_logic_vector(23 downto 0);
        iram_wren          : in  std_logic;
        iram_fifo_afull    : out std_logic; 
        
        --% OUT RAM
        ram_byte           : out std_logic_vector(7 downto 0);
        ram_wren           : out std_logic;
        ram_wraddr         : out std_logic_vector(23 downto 0);
        outif_almost_full  : in  std_logic

   );
end component JpegEnc;

component rgb_buffer is
port 
(
	clk                : in std_logic;
	rst                : in std_logic;
	
	iram_wdata_in      : in std_logic_vector(23 downto 0);
	iram_wren_in       : in std_logic;
	iram_clk		   : in std_logic; 
	
	iram_wdata_out     : out std_logic_vector(23 downto 0);
	iram_wren_out      : out std_logic;
	iram_fifo_afull    : in std_logic;
	encoder_ready      : in std_logic;
	fifo_overflow      : out std_logic
);
end component rgb_buffer;
------------------------------------------------------------------------

type ROMQ_TYPE is array (0 to 64-1) 
		of std_logic_vector(7 downto 0);
  
  constant qrom_lum : ROMQ_TYPE := 
  (
  -- 100%
  --others => X"01"
 
 -- 75%
   -- X"08", X"06", X"06", X"07", X"06", X"05", X"08", X"07", X"07", X"07", X"09", X"09", X"08", X"0A", X"0C", X"14",
   -- X"0D", X"0C", X"0B", X"0B", X"0C", X"19", X"12", X"13", X"0F", X"14", X"1D", X"1A", X"1F", X"1E", X"1D", X"1A",
   -- X"1C", X"1C", X"20", X"24", X"2E", X"27", X"20", X"22", X"2C", X"23", X"1C", X"1C", X"28", X"37", X"29", X"2C",
   -- X"30", X"31", X"34", X"34", X"34", X"1F", X"27", X"39", X"3D", X"38", X"32", X"3C", X"2E", X"33", X"34", X"32"    
   
   -- 50%
   X"10", X"0B", X"0C", X"0E", X"0C", X"0A", X"10", X"0E", 
   X"0D", X"0E", X"12", X"11", X"10", X"13", X"18", X"28",
   X"1A", X"18", X"16", X"16", X"18", X"31", X"23", X"25", 
   X"1D", X"28", X"3A", X"33", X"3D", X"3C", X"39", X"33",
   X"38", X"37", X"40", X"48", X"5C", X"4E", X"40", X"44", 
   X"57", X"45", X"37", X"38", X"50", X"6D", X"51", X"57",
   X"5F", X"62", X"67", X"68", X"67", X"3E", X"4D", X"71", 
   X"79", X"70", X"64", X"78", X"5C", X"65", X"67", X"63"
  );
  
  constant qrom_chr : ROMQ_TYPE := 
  (
   -- 50% for chrominance
  X"11", X"12", X"12", X"18", X"15", X"18", X"2F", X"1A", 
  X"1A", X"2F", X"63", X"42", X"38", X"42", X"63", X"63",
  X"63", X"63", X"63", X"63", X"63", X"63", X"63", X"63", 
  X"63", X"63", X"63", X"63", X"63", X"63", X"63", X"63",
  X"63", X"63", X"63", X"63", X"63", X"63", X"63", X"63", 
  X"63", X"63", X"63", X"63", X"63", X"63", X"63", X"63",
  X"63", X"63", X"63", X"63", X"63", X"63", X"63", X"63", 
  X"63", X"63", X"63", X"63", X"63", X"63", X"63", X"63"
  
  -- 75% chrominance
  -- X"09", X"09", X"09", X"0C", X"0B", X"0C", X"18", X"0D", 
  -- X"0D", X"18", X"32", X"21", X"1C", X"21", X"32", X"32", 
  -- X"32", X"32", X"32", X"32", X"32", X"32", X"32", X"32", 
  -- X"32", X"32", X"32", X"32", X"32", X"32", X"32", X"32", 
  -- X"32", X"32", X"32", X"32", X"32", X"32", X"32", X"32", 
  -- X"32", X"32", X"32", X"32", X"32", X"32", X"32", X"32", 
  -- X"32", X"32", X"32", X"32", X"32", X"32", X"32", X"32", 
  -- X"32", X"32", X"32", X"32", X"32", X"32", X"32", X"32"
  
  -- 100% 
  --others => X"01"
  );

TYPE states is (write_res_reg_0,reg_done,wait_for_start2_done,s_reset,write_lum_tables_2,write_lum_tables_1,write_lum_tables_0,write_chr_tables_0,write_chr_tables_1,write_chr_tables_2,wait_for_start0,wait_for_start1,wait_for_start2,write_res_reg,s_wait,s_done1,s_done2);

SIGNAL ps	 	: states;
SIGNAL ns		: states;

-- OPB
signal OPB_ABus      :   std_logic_vector(31 downto 0);
signal OPB_BE        :   std_logic_vector(3 downto 0);
signal OPB_DBus_in   :   std_logic_vector(31 downto 0);
signal OPB_RNW       :   std_logic;
signal OPB_select    :   std_logic;


signal OPB_ABus_i      		:   std_logic_vector(31 downto 0);
signal OPB_BE_i             :   std_logic_vector(3 downto 0);
signal OPB_DBus_in_i        :   std_logic_vector(31 downto 0);
signal OPB_RNW_i            :   std_logic;
signal OPB_select_i         :   std_logic;
signal almost_empty         :   std_logic;

signal OPB_DBus_out       :  std_logic_vector(31 downto 0);
signal OPB_XferAck        :  std_logic;
signal OPB_retry          :  std_logic;
signal OPB_toutSup        :  std_logic;
signal OPB_errAck       :  std_logic;
signal error_i          :  std_logic;
signal counter_i		: std_logic_vector(5 downto 0);
signal counter			: std_logic_vector(5 downto 0);
signal iram_wdata_i		: std_logic_vector(23 downto 0);
signal rst				: std_logic;
signal start : std_logic;
signal rgb_start_q : std_logic;

signal iram_wren_i   : std_logic;
signal encoder_ready_i : std_logic;
signal encoder_ready : std_logic;
signal iram_fifo_afull : std_logic;




begin

jpeg_busy <= encoder_ready;

--- sync process -----------------------------------------
sync: PROCESS(clk,rst_n)
BEGIN
	IF rst_n = '0' THEN
		ps <= s_reset;
		rgb_start_q <= '0';
		rst <= '1';
	ELSIF rising_edge(clk) THEN
	
		rgb_start_q <= rgb_start;
		start <= ((rgb_start_q xor rgb_start) and rgb_start);

		-- error <= '0';
		rst <= '0';
	
		if jpeg_enable = '0' then
			ps <= s_reset;			
			-- error <= '1';
			rst <= '1';
		else 
			ps <= ns;
			if ns = s_reset then
				rst <= '1';
			end if;
		end if;
		
		counter <= counter_i;
		OPB_ABus <= OPB_ABus_i;
		OPB_BE <= OPB_BE_i;
		OPB_DBus_in <= OPB_DBus_in_i;
		OPB_RNW <= OPB_RNW_i;
		OPB_select <= OPB_select_i;	
		encoder_ready <= encoder_ready_i;
		
	END IF;
END PROCESS sync;
------- comb procc ------------------------------------
comb: PROCESS(ps,counter,OPB_DBus_out,OPB_XferAck,start,resx,resy,encoder_ready)
BEGIN
ns <= ps;
counter_i <= counter;
OPB_ABus_i    <= (others => '0');
OPB_BE_i      <= (others => '0');
OPB_DBus_in_i <= (others => '0');
OPB_RNW_i     <= '0';
OPB_select_i  <= '0';
done <= '0';	
encoder_ready_i <= encoder_ready;
CASE ps IS
WHEN s_reset =>
	ns <= wait_for_start0;
	counter_i <= (others => '0');
	OPB_ABus_i    <= (others => '0');
	OPB_BE_i      <= (others => '0');
	OPB_DBus_in_i <= (others => '0');
	OPB_RNW_i     <= '0';
	OPB_select_i  <= '0';	
	encoder_ready_i <= '0';
when wait_for_start0 =>
	if start = '1' then
		ns <= wait_for_start1;
		encoder_ready_i <= '1'; -- move this to apropriate place if wait for start is enabled
	end if;
when wait_for_start1 =>
	-- if start = '1' then
		ns <= write_lum_tables_0;
	-- end if;
when write_lum_tables_0	=>
	  ns <= write_lum_tables_1;
	  OPB_ABus_i    <= (others => '0');
      OPB_BE_i      <= (others => '0');
      OPB_DBus_in_i <= (others => '0');
      OPB_RNW_i     <= '0';
      OPB_select_i  <= '0';

when write_lum_tables_1 =>	
	counter_i <= counter + 1;
	OPB_select_i  <= '1';
    OPB_ABus_i    <= X"0000_0100" + counter*X"04";
    OPB_RNW_i     <= '0';
    OPB_BE_i      <= X"F";
    OPB_DBus_in_i <= X"0000_00" & (qrom_lum(conv_integer(counter)));
	ns <= write_lum_tables_2;

when write_lum_tables_2 =>
	if OPB_XferAck /= '1' then
	else
		if counter = 0 then
			ns <= write_chr_tables_0;
			counter_i <= (others =>'0');
		else
			ns <= write_lum_tables_0;
		end if;	
    end if;


when write_chr_tables_0	=>
	  ns <= write_chr_tables_1;
	  OPB_ABus_i    <= (others => '0');
      OPB_BE_i      <= (others => '0');
      OPB_DBus_in_i <= (others => '0');
      OPB_RNW_i     <= '0';
      OPB_select_i  <= '0';

when write_chr_tables_1 =>
	counter_i <= counter + 1;
	OPB_select_i  <= '1';
    OPB_ABus_i    <= X"0000_0200" + counter*X"04";
    OPB_RNW_i     <= '0';
    OPB_BE_i      <= X"F";
    OPB_DBus_in_i <= X"0000_00" & (qrom_chr(conv_integer(counter)));
	ns <= write_chr_tables_2;

when write_chr_tables_2 =>
	if OPB_XferAck /= '1' then
	else
		if counter = 0 then
			ns <= write_res_reg_0;
		else
			ns <= write_chr_tables_1;
		end if;	
    end if;

when write_res_reg_0 =>
	ns <= write_res_reg;

when write_res_reg =>
	OPB_select_i  <= '1';
    OPB_ABus_i    <= X"0000_0004";
    OPB_RNW_i     <= '0';
    OPB_BE_i      <= X"F";
    OPB_DBus_in_i <= resx & resy;
	ns <= reg_done;

when reg_done => 
	if OPB_XferAck /= '1' then
		ns <= wait_for_start2;
    end if;

when wait_for_start2 =>
	-- if start = '1' then
		OPB_select_i  <= '1';
		OPB_ABus_i    <= X"0000_0000";
		OPB_RNW_i     <= '0';
		OPB_BE_i      <= X"F";
		OPB_DBus_in_i <= X"0000_0007"; -- RGB= 11, sof= 1, 
		ns <= wait_for_start2_done;
		-- encoder_ready_i <= '1';
	-- end if;

when wait_for_start2_done => 
	if OPB_XferAck /= '1' then
		ns <= s_done1;
    end if;
	
when s_done1 => 	
	OPB_ABus_i    <= (others => '0');
	OPB_BE_i      <= (others => '0');
	OPB_DBus_in_i <= (others => '0');
	OPB_RNW_i     <= '0';
	OPB_select_i  <= '0';	  
	ns <= s_done2;
	  
when s_done2 =>
	ns <= s_wait;
	OPB_select_i  <= '1';
	OPB_ABus_i    <= X"0000_000C";
	OPB_RNW_i     <= '1';
	OPB_BE_i      <= X"F";
			
when s_wait =>	
	if OPB_XferAck /= '1' then
		if OPB_DBus_out = X"0000_0002" then
			ns <= s_reset;
			done <= '1';
			encoder_ready_i <= '0'; 
		else
			ns <= s_done1;
		end if;
	end if;
	
WHEN OTHERS =>
	ns <= s_reset;
	
END CASE;
END PROCESS comb;

-------------------------------------------------------------
jpegencoder: JpegEnc port map
(
CLK                => clk,
RST                => rst,

-- OPB
OPB_ABus           => OPB_ABus,
OPB_BE             => OPB_BE,
OPB_DBus_in        => OPB_DBus_in,
OPB_RNW            => OPB_RNW,
OPB_select         => OPB_select,
OPB_DBus_out       => OPB_DBus_out,
OPB_XferAck        => OPB_XferAck,
OPB_retry          => OPB_retry,
OPB_toutSup        => OPB_toutSup,
OPB_errAck         => OPB_errAck,

-- IMAGE RAM
iram_wdata         => iram_wdata_i,
iram_wren          => iram_wren_i,
iram_fifo_afull    => iram_fifo_afull,

-- OUT RAM
ram_byte           => ram_byte,
ram_wren           => ram_wren,
ram_wraddr         => ram_wraddr,
outif_almost_full  => outif_almost_full
);

rgbbuffer: rgb_buffer 
port map
(
clk => clk,
rst => rst,
iram_wdata_in =>   iram_wdata,
iram_wren_in   => iram_wren,
iram_clk => iram_clk,
iram_wdata_out  => iram_wdata_i,
iram_wren_out => iram_wren_i,
iram_fifo_afull => iram_fifo_afull,
encoder_ready => encoder_ready,
fifo_overflow => error
);

end architecture RTL; 

