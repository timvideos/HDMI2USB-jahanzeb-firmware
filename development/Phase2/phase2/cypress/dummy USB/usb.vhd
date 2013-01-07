library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity usb is
    Port (
		rst_n 		: in std_logic;
		
		fdata		: inout std_logic_vector(7 downto 0);
		
		flagA 		: in std_logic;
		flagB 		: in std_logic;
		flagC 		: in std_logic;
		
		faddr		: out std_logic_vector(1 downto 0);
		slwr		: out std_logic;
		slrd		: out std_logic;
		sloe		: out std_logic;
		pktend		: out std_logic;
		slcs		: out std_logic;
		-- A0			: out std_logic;
		
		LED 		: out std_logic_vector(7 downto 0);
		sw	 		: in  std_logic_vector(7 downto 0);
		
		ifclk		: in std_logic
	);
end entity usb;

architecture rtl of usb is

signal counter : std_logic_vector(7 downto 0);
signal fdatain : std_logic_vector(7 downto 0);
signal fdataout : std_logic_vector(7 downto 0);
signal outen : std_logic;



begin

-- LED(7) <= fdata(7) or fdata(6) or fdata(5) or fdata(4) or fdata(3) or fdata(2) or fdata(1) or fdata(0);

-- FLAGA=PF, FLAGB=FF, FLAGC=EF, FLAGD=EP2PF 
-- (Actual FIFO is selected by FIFOADR[0,1] pins)
-- slrd <= 'Z' when sw(2) = '1' else '0' ;
-- sloe <= 'Z' when sw(3) = '1' else '0' ;
-- slwr <= 'Z' when sw(4) = '1' else '0' ;

fdatain <= fdata;
fdata <= counter when outen = '1' else (others => 'Z');

-- LED(7) <= fdatain(7) or fdatain(6) or fdatain(5) or fdatain(4) or fdatain(3) or fdatain(2) or fdatain(1) or fdatain(0);

syncProc: process(rst_n,ifclk)
begin

if rst_n = '0' then		
	counter <= (others => '0');
	outen <= '0';
	pktend <= '1';
elsif rising_edge(ifclk) then
LED(0) <= flagA;
LED(1) <= flagB; --FLAGB=FF
LED(2) <= flagC; --FLAGC=EF

faddr(0) <= sw(0);
faddr(1) <= sw(1);
LED(6 downto 3) <= (others => '0');



	if ((sw(1 downto 0) = "01" or sw(1 downto 0) = "10") and sw(3) = '0' ) then
		counter <= counter +1;
		outen <= '1';
		slwr <= '0';
		if counter = X"0F" then
			pktend <= '0';
			LED(7) <= '0';
		end if;
	else 
		pktend <= '1';
		slwr <= '1';
		LED(7) <= '1';
		outen <= '0';		
	end if;
	
	if (sw(1 downto 0) = "00" and sw(2) = '0') then

		case fdatain is
		when X"03" =>
			LED(6 downto 3) <= "0001";
		when X"04" =>
			LED(6 downto 3) <= "0010";		
		when X"05" =>
			LED(6 downto 3) <= "0100";		
		when X"06" =>
			LED(6 downto 3) <= "1000";		
		when others =>
			LED(6 downto 3) <= "0000";		
		end case;
			

	end if;

slrd <= sw(2);
sloe <= sw(2);


slcs <= '0';
-- pktend <= sw(4);



end if;

end process;

end rtl;