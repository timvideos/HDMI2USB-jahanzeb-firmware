-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Format			Pixel Clock	|				Horizontal (in Pixels) 									|				Vertical (in Lines)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 								|	Active Video |	Front Porch	 | Sync Pulse	 | Back Porch  | Total  | 	Active Video	| Front Porch	 | Sync Pulse	| Back Porch | Total
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1024x768,60Hz	65.000		|		1024	 |		24		 |	136			 |   160	   | 1344  	|		768			|	3			 |  6			| 29		 | 806
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Total Horizontal = 1344
-- Total Vertical   = 806

-- O    Total frame time
-- P    Sync length
-- Q    Back porch
-- R    Active video time
-- S    Front porch
         -- ______________________          ________
-- ________|        VIDEO         |________|  VIDEO (next frame)
    -- |-Q-|----------R-----------|-S-|
-- __   ______________________________   ___________
  -- |_|                              |_|
  -- |P|
  -- |---------------O----------------|
  
  -- reff: http://martin.hinner.info/vga/timing.html
  -- reff: http://www.epanorama.net/faq/vga2rgb/calc.html

LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;		 
USE ieee.std_logic_unsigned.all;

entity pattern is
generic (
	SIMULATION             	  : string := "FALSE");
port 
(	
	rgb 	: out std_logic_vector(23 downto 0);
	resx  : out std_logic_vector(15 downto 0);
	resy  : out std_logic_vector(15 downto 0);
	de		: out std_logic;
	pclk	: out std_logic;
	vsync	: out std_logic;
	hsync	: out std_logic;
	clk     : in  std_logic;
	rst_n   : in  std_logic
);
end entity pattern;

architecture rtl of pattern is

component patternClk
port
 (
  CLK_IN1           : in     std_logic;
  CLK_OUT1          : out    std_logic
 );
end component;



signal counterX : std_logic_vector(15 downto 0);
signal counterY : std_logic_vector(15 downto 0);
signal resX_i : std_logic_vector(15 downto 0);
signal resY_i : std_logic_vector(15 downto 0);

signal spY : integer;
signal bpY : integer;
signal fpY : integer;


signal spX : integer;
signal bpX : integer;
signal fpX : integer;

signal data : std_logic_vector(23 downto 0);


signal pclk_i : std_logic;
signal vsync_i : std_logic;
signal hsync_i : std_logic;
signal vActive : std_logic;
signal hActive : std_logic;

begin


RESF: if (SIMULATION = "FALSE" ) generate
	resX_i <= X"0400";
	resY_i <= X"0300";
		
	spY <= 6;
	bpY <= 29;
	fpY <= 3;
	
	spX <= 136;
	bpX <= 160;
	fpX <= 24;

end generate;
REST: if (SIMULATION = "TRUE" ) generate
	resX_i <= X"0200";
	resY_i <= X"0008";

	spY <= 1;
	bpY <= 2;
	fpY <= 3;
	
	spX <= 16;
	bpX <= 10;
	fpX <= 2;
	
	
end generate;


-- rgb 	<= (data(7 downto 0) & data(23 downto 16) & data(15 downto 8));
rgb 	<= data;

resX	<= resX_i;
resY	<= resY_i;
pclk	<= pclk_i;
vsync	<= vsync_i;
hsync	<= hsync_i;

de <= vActive and hActive;

process(rst_n,pclk_i)
begin
	if rst_n = '0' then
	
		data 	 <= (others => '0');
		counterX <= (others => '0');
		counterY <= (others => '0');
		vsync_i <= '0';
		vActive <= '0';
		hsync_i <= '0';
		hActive <= '0';
		
	elsif rising_edge(pclk_i) then
	
		counterX <= counterX + 1;
		
		if counterY = 0 then 
			vsync_i <= '0';
			vActive <= '0';		
		elsif counterY = spY then
			vsync_i <= '1';
		elsif counterY = (spY+bpY) then
			vActive <= '1';		
		elsif counterY = (spY+bpY+CONV_INTEGER(resY_i)) then
			vActive <= '0';		
		elsif counterY = (spY+bpY+CONV_INTEGER(resY_i)+fpY) then
			counterY <= (others => '0');
			data <= (others => '0');
		end if;
	

		if counterX = 0 then 
			hsync_i <= '0';
			hActive <= '0';		
		elsif counterX = spX then
			hsync_i <= '1';
		elsif counterX = (spX+bpX) then
			hActive <= '1';		
		elsif counterX = (spX+bpX+CONV_INTEGER(resX_i)) then
			hActive <= '0';		
		elsif counterX = (spX+bpX+CONV_INTEGER(resX_i)+fpX) then
			counterX <= (others => '0');
			counterY <= counterY +1;
			counterX <= (others => '0');			
		end if;
	
		if vActive = '1' and hActive = '1' then	
			data <= data +1;
		end if;

		
	end if;
end process;


patternClk_com : patternClk
port map
(
CLK_IN1 => clk,
CLK_OUT1 => pclk_i);

end architecture;
