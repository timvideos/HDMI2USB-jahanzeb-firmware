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

  output_selector : process(switch_case, f_data, in_frame_rate, frame_rate, frame_write_time, proc_time, frame_drop_cnt)
  begin
    case switch_case is
      when "000"  => uart_byte <= in_frame_rate;
      when "001"  => uart_byte <= frame_rate;
      when "010"  => uart_byte <= frame_write_time;
      when "011"  => uart_byte <= proc_time;
      when "100"  => uart_byte <= frame_drop_cnt;
      when "101"  => uart_byte <= f_data;
      when others => uart_byte <= X"FF";
    end case;
  end process;

  send <= clk_1hz;
  uart_send : process(clk_50Mhz_s, rst)
  begin
    if rst = '1' then
      uart_en1 <= '0';
    elsif rising_edge(clk_50Mhz_s) then
      uart_en1 <= '0';
      send_q   <= send;
      if send_q = '0' and send = '1' then
        uart_en1 <= '1';
      end if;
    end if;
  end process;

  frame_size_send : process(clk_50Mhz_s, rst)
  begin
    if rst = '1' then
      f_send_state <= wait_send_edge;
      uart_en_f    <= '0';
      f_data       <= frame_size(23 downto 16);
    elsif rising_edge(clk_50Mhz_s) then

      case f_send_state is
        when wait_send_edge =>
          uart_en_f <= '0';
          if send_q = '0' and send = '1' then
            uart_en_f    <= '1';
            f_data       <= frame_size(23 downto 16);
            f_send_state <= send_byte1;
          end if;
        when send_byte1 =>
          uart_en_f    <= '1';
          f_data       <= frame_size(15 downto 8);
          f_send_state <= send_byte2;
        when send_byte2 =>
          uart_en_f    <= '1';
          f_data       <= frame_size(7 downto 0);
          f_send_state <= wait_send_edge;
        when others =>
          f_send_state <= wait_send_edge;
      end case;

    end if;
  end process;

  uart_en <= uart_en_f when switch_case = "101" else
            uart_en1;



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

