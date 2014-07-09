-- //////////////////////////////////////////////////////////////////////////////
-- /// Copyright (c) 2014, Ajit Mathew <ajitmathew04@gmail.com>
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

--The debug module collects counters from the system for debugging.
--The following counters will be supported:

-- - Device State
-- - Resolution 
-- - in frame rate
-- - frame rate
-- - frame rate write time
-- - processing time
-- - frame drop count
-- - frame size
-- Use the dubugging program to access the counters

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity debug_top is
  port(
    clk           : in  std_logic;
    clk_50Mhz     : out std_logic;
    rst           : in  std_logic;
    vsync         : in  std_logic;
    no_frame_read : in  std_logic;
    pktend        : in  std_logic;
    jpg_busy      : in  std_logic;
    write_img     : in  std_logic;
    sw            : in  std_logic_vector(7 downto 0);
    uart_en       : out std_logic;
    frame_size    : in  std_logic_vector(23 downto 0);
    device_state  : in  std_logic_vector(7 downto 0);
    resX          : in  std_logic_vector(15 downto 0);
    resY          : in  std_logic_vector(15 downto 0);

    clk2 : out std_logic;
    clk1 : out std_logic;
    p    : out std_logic;

    uart_byte : out std_logic_vector(7 downto 0)
    );
end debug_top;

architecture Behavioral of debug_top is

  component counters
    port(
      clk              : in  std_logic;
      clk_ms           : in  std_logic;
      clk_1hz          : in  std_logic;
      rst              : in  std_logic;
      vsync            : in  std_logic;
      no_frame_read    : in  std_logic;
      write_img        : in  std_logic;
      pktend           : in  std_logic;
      jpg_busy         : in  std_logic;
      proc_time        : out std_logic_vector(7 downto 0);
      frame_write_time : out std_logic_vector(7 downto 0);
      frame_rate       : out std_logic_vector(7 downto 0);
      in_frame_rate    : out std_logic_vector(7 downto 0);
      frame_drop_cnt   : out std_logic_vector(7 downto 0)
      );
  end component;

  signal prescaler        : integer range 0 to 50000000;
  signal prescaler1       : integer range 0 to 50000;
  signal clk_ms           : std_logic;
  signal clk_1hz          : std_logic;
  signal proc_time        : std_logic_vector(7 downto 0);
  signal frame_write_time : std_logic_vector(7 downto 0);
  signal frame_rate       : std_logic_vector(7 downto 0);
  signal in_frame_rate    : std_logic_vector(7 downto 0);
  signal frame_drop_cnt   : std_logic_vector(7 downto 0);
  signal switch_case      : std_logic_vector(2 downto 0);
  signal send, send_q     : std_logic;
  signal clk_50Mhz_s      : std_logic;
  signal jpg_busy_s       : std_logic;
  signal cnt              : integer range 0 to 32;
  signal f_data           : std_logic_vector(7 downto 0);
  type f_send_states is (wait_send_edge, send_byte1, send_byte2);
  signal f_send_state     : f_send_states;
  signal uart_en_f        : std_logic;
  signal uart_en1         : std_logic;
  type send_array is array(0 to 15) of std_logic_vector(7 downto 0);
  signal uart_send_array  : send_array;
  signal byte_cnt         : integer range 0 to 15;

begin

  clk_50Mhz <= clk_50Mhz_s;
  clk1      <= jpg_busy_s;
  process(clk, rst)
  begin
    if rst = '1' then
      clk_50Mhz_s <= '0';
    elsif rising_edge(clk) then
      clk_50Mhz_s <= not clk_50Mhz_s;
    end if;
  end process;


  clk_gen : process(clk, rst)
  begin
    if rst = '1' then
      clk_1hz    <= '0';
      prescaler  <= 0;
      prescaler1 <= 0;
    elsif rising_edge(clk) then
      if prescaler = 50000000-1 then
        prescaler <= 0;
        clk_1hz   <= not clk_1hz;
      else
        prescaler <= prescaler + 1;
      end if;
      if prescaler1 = 50000 then
        prescaler1 <= 0;
        clk_ms     <= not clk_ms;
      else
        prescaler1 <= prescaler1 + 1;
      end if;
    end if;
  end process clk_gen;

  switch_case <= sw(2 downto 0);

  send                <= clk_1hz;
  uart_send_array(0)  <= X"AA";
  uart_send_array(1)  <= device_state;
  uart_send_array(2)  <= resX(15 downto 8);
  uart_send_array(3)  <= resX(7 downto 0);
  uart_send_array(4)  <= resY(15 downto 8);
  uart_send_array(5)  <= resY(7 downto 0);
  uart_send_array(6)  <= in_frame_rate;
  uart_send_array(7)  <= frame_rate;
  uart_send_array(8)  <= frame_write_time;
  uart_send_array(9)  <= proc_time;
  uart_send_array(10) <= frame_drop_cnt;
  uart_send_array(11) <= frame_size(23 downto 16);
  uart_send_array(12) <= frame_size(15 downto 8);
  uart_send_array(13) <= frame_size(7 downto 0);


  array_send : process(clk_50Mhz_s, rst)
  begin
    if rst = '1' then
      uart_en   <= '0';
      uart_byte <= uart_send_array(0);
      byte_cnt  <= 0;
    elsif rising_edge(clk_50Mhz_s) then
      send_q <= send;
      case byte_cnt is
        when 0 =>
          uart_en <= '0';
          if send_q = '0' and send = '1' then
            uart_en   <= '1';
            uart_byte <= uart_send_array(0);
            byte_cnt  <= 1;
          end if;
        when 1 =>
          uart_en   <= '1';
          uart_byte <= uart_send_array(1);
          byte_cnt  <= byte_cnt+1;
        when 2 =>
          uart_en   <= '1';
          uart_byte <= uart_send_array(2);
          byte_cnt  <= byte_cnt+1;
        when 3 =>
          uart_en   <= '1';
          uart_byte <= uart_send_array(3);
          byte_cnt  <= byte_cnt+1;
        when 4 =>
          uart_en   <= '1';
          uart_byte <= uart_send_array(4);
          byte_cnt  <= byte_cnt+1;
        when 5 =>
          uart_en   <= '1';
          uart_byte <= uart_send_array(5);
          byte_cnt  <= byte_cnt+1;
        when 6 =>
          uart_en   <= '1';
          uart_byte <= uart_send_array(6);
          byte_cnt  <= byte_cnt+1;
        when 7 =>
          uart_en   <= '1';
          uart_byte <= uart_send_array(7);
          byte_cnt  <= byte_cnt+1;
        when 8 =>
          uart_en   <= '1';
          uart_byte <= uart_send_array(8);
          byte_cnt  <= byte_cnt+1;
        when 9 =>
          uart_en   <= '1';
          uart_byte <= uart_send_array(9);
          byte_cnt  <= byte_cnt+1;
        when 10 =>
          uart_en   <= '1';
          uart_byte <= uart_send_array(10);
          byte_cnt  <= byte_cnt+1;
        when 11 =>
          uart_en   <= '1';
          uart_byte <= uart_send_array(11);
          byte_cnt  <= byte_cnt+1;
        when 12 =>
          uart_en   <= '1';
          uart_byte <= uart_send_array(12);
          byte_cnt  <= byte_cnt+1;
        when 13 =>
          uart_en   <= '1';
          uart_byte <= uart_send_array(13);
          byte_cnt  <= 0;
        when others =>
          byte_cnt <= 0;
      end case;
    end if;
  end process;

  Inst_counters : counters port map(
    clk              => clk,
    clk_ms           => clk_ms,
    clk_1hz          => clk_1hz,
    rst              => rst,
    vsync            => vsync,
    no_frame_read    => no_frame_read,
    write_img        => write_img,
    pktend           => pktend,
    jpg_busy         => jpg_busy,
    proc_time        => proc_time,
    frame_write_time => frame_write_time,
    frame_rate       => frame_rate,
    in_frame_rate    => in_frame_rate,
    frame_drop_cnt   => frame_drop_cnt
    );

end Behavioral;

