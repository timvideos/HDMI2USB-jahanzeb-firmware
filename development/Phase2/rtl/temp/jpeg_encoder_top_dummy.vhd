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

LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;		 
USE ieee.std_logic_unsigned.all;

-- use ieee.numeric_std.all;

entity jpeg_encoder_top_dummy is
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
end entity jpeg_encoder_top_dummy;

architecture RTL of jpeg_encoder_top_dummy is
component jpegRam is
port (
clk 	: in std_logic;
raddr	: in std_logic_vector(15 downto 0);
q		: out std_logic_vector(7 downto 0)
);
end component;

---------------------------------------------------------------------------------
signal raddr: std_logic_vector(15 downto 0);
signal q: std_logic_vector(7 downto 0);
signal fetch : std_logic;
signal rgb_start_q : std_logic;



begin

process(clk,rst_n) 
begin
if rst_n = '0' then
	raddr <= (others => '0');
	fetch <= '0';
elsif rising_edge(clk) then
fetch <= '0';
ram_wren <= '0';
done <= '0';
rgb_start_q <= rgb_start;
error <= '0';

if rgb_start_q = '0' and rgb_start = '1' then
	jpeg_busy <= '1';
end if;


	if (jpeg_enable = '0') then
		raddr <= (others => '0');
	else 
		if (fetch = '1') then 
			ram_byte <= q;
			ram_wren <= '1';
		elsif outif_almost_full = '0' then
			fetch <= '1';
			if raddr = X"BA62" then
				raddr <= (others => '0');
				done <= '1';
				jpeg_busy <= '0'; 
			else
				raddr <= raddr + 1;
			end if;
		end if;
	end if;

end if;
end process;



jpegram0: jpegRam port map(
clk => clk,
raddr => raddr,
q => q
);
end architecture RTL; 

