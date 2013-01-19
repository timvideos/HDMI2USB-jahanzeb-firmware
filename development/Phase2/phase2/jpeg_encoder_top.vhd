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
		rgb_start 			   : in std_logic;
		done			   : out std_logic;
		error				: out std_logic;
		jpeg_busy		   : out std_logic;
		jpeg_enable		   : in std_logic
		
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
		-- ready		       : out std_logic;
        -- busy	           : out std_logic;
        
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

component rgbfifo IS
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
    almost_empty : OUT STD_LOGIC
  );
END component rgbfifo;
------------------------------------------------------------------------
        -- OPB
signal OPB_ABus      :   std_logic_vector(31 downto 0);
signal OPB_BE             :   std_logic_vector(3 downto 0);
signal OPB_DBus_in        :   std_logic_vector(31 downto 0);
signal OPB_RNW            :   std_logic;
signal OPB_select         :   std_logic;
signal	ready		       :  std_logic;
signal	busy	           :  std_logic;

signal OPB_ABus_i      :   std_logic_vector(31 downto 0);
signal OPB_BE_i             :   std_logic_vector(3 downto 0);
signal OPB_DBus_in_i        :   std_logic_vector(31 downto 0);
signal OPB_RNW_i            :   std_logic;
signal OPB_select_i         :   std_logic;
signal almost_empty         :   std_logic;

signal OPB_DBus_out       :  std_logic_vector(31 downto 0);
signal OPB_XferAck        :  std_logic;
signal OPB_retry          :  std_logic;
signal OPB_toutSup        :  std_logic;
signal OPB_errAck         :  std_logic;
signal error_i         :  std_logic;
signal fifo_rd_en_i         :  std_logic;
signal i_i				: std_logic_vector(5 downto 0);
signal i				: std_logic_vector(5 downto 0);
signal din				: std_logic_vector(23 downto 0);
-- signal addr_i,data_write_i      :   std_logic_vector(31 downto 0);
-- signal addr,data_write      :   std_logic_vector(31 downto 0);
signal rst	: std_logic;
signal iram_wren_i , encoder_ready : std_logic;


    type ROMQ_TYPE is array (0 to 64-1) 
            of std_logic_vector(7 downto 0);
  
  constant qrom_lum : ROMQ_TYPE := 
  (
  -- 100%
  --others => X"01"
 
 -- 75%
   --X"08", X"06", X"06", X"07", X"06", X"05", X"08", X"07", X"07", X"07", X"09", X"09", X"08", X"0A", X"0C", X"14",
   --X"0D", X"0C", X"0B", X"0B", X"0C", X"19", X"12", X"13", X"0F", X"14", X"1D", X"1A", X"1F", X"1E", X"1D", X"1A",
   --X"1C", X"1C", X"20", X"24", X"2E", X"27", X"20", X"22", X"2C", X"23", X"1C", X"1C", X"28", X"37", X"29", X"2C",
   --X"30", X"31", X"34", X"34", X"34", X"1F", X"27", X"39", X"3D", X"38", X"32", X"3C", X"2E", X"33", X"34", X"32"    
   
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
  --X"09", X"09", X"09", X"0C", X"0B", X"0C", X"18", X"0D", 
  --X"0D", X"18", X"32", X"21", X"1C", X"21", X"32", X"32", 
  --X"32", X"32", X"32", X"32", X"32", X"32", X"32", X"32", 
  --X"32", X"32", X"32", X"32", X"32", X"32", X"32", X"32", 
  --X"32", X"32", X"32", X"32", X"32", X"32", X"32", X"32", 
  --X"32", X"32", X"32", X"32", X"32", X"32", X"32", X"32", 
  --X"32", X"32", X"32", X"32", X"32", X"32", X"32", X"32", 
  --X"32", X"32", X"32", X"32", X"32", X"32", X"32", X"32"
  
  -- 100% 
  --others => X"01"
  );


TYPE states is (s_reset,write_lum_tables_2,write_lum_tables_1,write_lum_tables_0,write_chr_tables_0,write_chr_tables_1,write_chr_tables_2,wait_for_start0,wait_for_start1,wait_for_start2,write_res_reg,s_wait,s_done1,s_done2,wait1,wait2,wait3,wait4);

SIGNAL ps	 	: states;
SIGNAL ns		: states;
signal fifo_full,fifo_empty,fifo_rd_en,iram_wren_ii : std_logic;
signal fifo_data : std_logic_vector(23 downto 0);
signal iram_fifo_afull : std_logic;
signal start,rgb_start_q : std_logic;

begin




jpeg_busy <= encoder_ready;
start <= (rgb_start xor rgb_start_q ) and rgb_start;

--- sync process -----------------------------------------
sync: PROCESS(clk,rst_n)
BEGIN
	IF rst_n = '0' THEN
		ps <= s_reset;
		rgb_start_q <= '0';
		rst <= '1';
	ELSIF rising_edge(clk) THEN
	-- error_i <= fifo_full;
	rst <= '0';
	error <= '0';
	
		if fifo_full = '1' or jpeg_enable = '0' then
			ps <= s_reset;
			rst <= '1';
			error <= '1';
		else 
			ps <= ns;	

		end if;
		

		rgb_start_q <= rgb_start;
		
		i <= i_i;
		OPB_ABus <= OPB_ABus_i;
		OPB_BE <= OPB_BE_i;
		OPB_DBus_in <= OPB_DBus_in_i;
		OPB_RNW <= OPB_RNW_i;
		OPB_select <= OPB_select_i;		
	END IF;
END PROCESS sync;
------- comb procc ------------------------------------
comb: PROCESS(ps,i,OPB_DBus_out,OPB_XferAck,start,resx,resy)
BEGIN
ns <= ps;
i_i <= i;
encoder_ready  <= '0';
OPB_ABus_i    <= (others => '0');
OPB_BE_i      <= (others => '0');
OPB_DBus_in_i <= (others => '0');
OPB_RNW_i     <= '0';
OPB_select_i  <= '0';
done <= '0';	  
CASE ps IS
WHEN s_reset =>
	ns <= wait_for_start0;
	i_i <= (others => '0');
	OPB_ABus_i    <= (others => '0');
	OPB_BE_i      <= (others => '0');
	OPB_DBus_in_i <= (others => '0');
	OPB_RNW_i     <= '0';
	OPB_select_i  <= '0';	
when wait_for_start0 =>
	if start = '1' then
		ns <= wait_for_start1;
	end if;
when wait_for_start1 =>
	if start = '1' then
		ns <= write_lum_tables_0;
	end if;
when write_lum_tables_0	=>
	  ns <= write_lum_tables_1;
	  OPB_ABus_i    <= (others => '0');
      OPB_BE_i      <= (others => '0');
      OPB_DBus_in_i <= (others => '0');
      OPB_RNW_i     <= '0';
      OPB_select_i  <= '0';

when write_lum_tables_1 =>
	
	i_i <= i + 1;
	OPB_select_i  <= '1';
    OPB_ABus_i    <= X"0000_0100" + i*X"04";
    OPB_RNW_i     <= '0';
    OPB_BE_i      <= X"F";
    OPB_DBus_in_i <= X"0000_00" & (qrom_lum(conv_integer(i)));
	ns <= write_lum_tables_2;

when write_lum_tables_2 =>

	if OPB_XferAck /= '1' then
	else
		if i = 0 then
			ns <= write_chr_tables_0;
			i_i <= (others =>'0');
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
	

	i_i <= i + 1;
	OPB_select_i  <= '1';
    OPB_ABus_i    <= X"0000_0200" + i*X"04";
    OPB_RNW_i     <= '0';
    OPB_BE_i      <= X"F";
    OPB_DBus_in_i <= X"0000_00" & (qrom_chr(conv_integer(i)));
	ns <= write_chr_tables_2;

when write_chr_tables_2 =>

	if OPB_XferAck /= '1' then
	else
		if i = 0 then
			ns <= write_res_reg;
		else
			ns <= write_chr_tables_1;
		end if;	
    end if;

when write_res_reg =>
	OPB_select_i  <= '1';
    OPB_ABus_i    <= X"0000_0004";
    OPB_RNW_i     <= '0';
    OPB_BE_i      <= X"F";
    OPB_DBus_in_i <= resx & resy;
    -- OPB_DBus_in_i <= X"04000300";
	ns <= wait_for_start2;

when wait_for_start2 =>
	if start = '1' then
		OPB_select_i  <= '1';
		OPB_ABus_i    <= X"0000_0000";
		OPB_RNW_i     <= '0';
		OPB_BE_i      <= X"F";
		OPB_DBus_in_i <= X"0000_0007"; -- RGB= 11, sof= 1, 
		ns <= wait1;

	end if;

when wait1 => 
	ns <= wait2;
when wait2 => 
	ns <= wait3;
when wait3 => 
	ns <= wait4;
when wait4 => 
	ns <= s_done1;



when s_done1 => 

		encoder_ready <= '1';
      OPB_ABus_i    <= (others => '0');
      OPB_BE_i      <= (others => '0');
      OPB_DBus_in_i <= (others => '0');
      OPB_RNW_i     <= '0';
      OPB_select_i  <= '0';	  
	  ns <= s_done2;
	  
when s_done2 =>
		encoder_ready <= '1';

			ns <= s_wait;
			OPB_select_i  <= '1';
			OPB_ABus_i    <= X"0000_000C";
			OPB_RNW_i     <= '1';
			OPB_BE_i      <= X"F";


			
when s_wait =>
	
		encoder_ready <= '1';
		-- if OPB_XferAck /= '1' then
		-- else
			-- if busy = '0' then
			if OPB_DBus_out = X"0000_0002" then
				ns <= wait_for_start2;
				done <= '1';
			else
				ns <= s_done1;
			end if;
		-- end if;
	
WHEN OTHERS =>
	ns <= s_reset;
END CASE;




END PROCESS comb;


fifoprocess: process(clk,rst)
begin
if rst = '1' then
	fifo_rd_en <= '0';
	iram_wren_ii <= '0';
elsif rising_edge(clk) then

fifo_rd_en <= '0';
iram_wren_ii <= '0';

	if iram_fifo_afull = '0' and almost_empty = '0' then
		fifo_rd_en <= '1';
		iram_wren_ii <= '1';
	-- elsif iram_fifo_afull = '0' and fifo_empty = '1' then
		-- iram_wren_ii <= '1';
	end if;

end if;

end process;

fifo_rd_en_i <= ((fifo_rd_en xor fifo_full) and fifo_rd_en);

fifo24: rgbfifo port map
(

rst => rst,
wr_clk => iram_clk,
rd_clk => clk,
-- din => iram_wdata,
din => din,
wr_en => iram_wren_i,
rd_en => fifo_rd_en_i,
dout => fifo_data,
full => fifo_full,
empty => fifo_empty,
almost_empty => almost_empty
);
process(iram_clk,rst_n)
begin
if rst_n = '0' then
	iram_wren_i <= '0';
	din <= (others => '0');
elsif rising_edge(iram_clk) then
	iram_wren_i <= iram_wren and encoder_ready;
	din <= iram_wdata;
end if;
end process;
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
-- ready		       => ready,
-- busy	           => busy,

-- IMAGE RAM
iram_wdata         => fifo_data,
iram_wren          => iram_wren_ii,
-- iram_wren          => fifo_rd_en_i,
iram_fifo_afull    => iram_fifo_afull,

-- OUT RAM
ram_byte           => ram_byte,
ram_wren           => ram_wren,
ram_wraddr         => ram_wraddr,
outif_almost_full  => outif_almost_full
);

end architecture RTL; 

