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

