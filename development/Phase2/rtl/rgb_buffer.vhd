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

entity rgb_buffer is
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
end entity rgb_buffer;

architecture rtl of rgb_buffer is

COMPONENT rgb_fifo
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    almost_full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    almost_empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC
  );
END COMPONENT;

signal din		: std_logic_vector(23 downto 0);
signal dout_r	: std_logic_vector(7 downto 0);
signal dout_g	: std_logic_vector(7 downto 0);
signal dout_b	: std_logic_vector(7 downto 0);

signal wr_en : std_logic;
signal rd_en : std_logic;

signal full_r : std_logic;
signal almost_full_r : std_logic;
signal empty_r : std_logic;
signal almost_empty_r : std_logic;
signal valid_r : std_logic;

signal full_g : std_logic;
signal almost_full_g : std_logic;
signal empty_g : std_logic;
signal almost_empty_g : std_logic;
signal valid_g : std_logic;

signal full_b : std_logic;
signal almost_full_b : std_logic;
signal empty_b : std_logic;
signal almost_empty_b : std_logic;
signal valid_b : std_logic;

begin

fifo_overflow <= full_r or full_g or full_b;

writefifo: process(rst,iram_clk)
begin 
if rst = '1' then
	wr_en <= '0';
	din <= (others => '0');
elsif rising_edge(iram_clk) then 

	wr_en <= '0';
	din <= iram_wdata_in;

	if encoder_ready = '1' and almost_full_r = '0' and almost_full_g = '0' and almost_full_b = '0' and iram_wren_in = '1' then
		wr_en <= '1';	
		-- din <= din +1;	-- to produce a fix input patteren 
	end if;
	
end if;
end process writefifo;

r_rgb_fifo : rgb_fifo
PORT MAP (
rst => rst,
wr_clk => iram_clk,
rd_clk => clk,
din => din(23 downto 16),
wr_en => wr_en,
rd_en => rd_en,
dout => dout_r,
full => full_r,
almost_full => almost_full_r,
empty => empty_r,
almost_empty => almost_empty_r,
valid => valid_r
);


g_rgb_fifo : rgb_fifo
PORT MAP (
rst => rst,
wr_clk => iram_clk,
rd_clk => clk,
din => din(15 downto 8),
wr_en => wr_en,
rd_en => rd_en,
dout => dout_g,
full => full_g,
almost_full => almost_full_g,
empty => empty_g,
almost_empty => almost_empty_g,
valid => valid_g
);


b_rgb_fifo : rgb_fifo
PORT MAP (
rst => rst,
wr_clk => iram_clk,
rd_clk => clk,
din => din(7 downto 0),
wr_en => wr_en,
rd_en => rd_en,
dout => dout_b,
full => full_b,
almost_full => almost_full_b,
empty => empty_b,
almost_empty => almost_empty_b,
valid => valid_b
);
 
readprocess: process(rst,clk)
begin
if rst = '1' then
	rd_en <= '0';
elsif rising_edge(clk) then

	iram_wdata_out <= (dout_b & dout_g & dout_r);
	iram_wren_out <= valid_b and valid_g and valid_r;
	
	rd_en <= '0';	
	
	if  almost_empty_r = '0' and  almost_empty_g = '0' and  almost_empty_b = '0' and iram_fifo_afull = '0' then
		rd_en <= '1';		
	end if;

end if;
end process readprocess;


end architecture rtl;