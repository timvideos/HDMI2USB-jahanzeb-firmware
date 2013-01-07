--------------------------------------------------------------------------------
--                                                                            --
--                          V H D L    F I L E                                --
--                          COPYRIGHT (C) 2006                                --
--                                                                            --
--------------------------------------------------------------------------------
--                                                                            --
-- Title       : RAMZ                                                         --
-- Design      : MDCT                                                         --
-- Author      : Michal Krepa                                                 --                                                             --                                                           --
--                                                                            --
--------------------------------------------------------------------------------
--
-- File        : RAMZ.VHD
-- Created     : Sat Mar 5 7:37 2006
--
--------------------------------------------------------------------------------
--
--  Description : RAM memory simulation model
--
--------------------------------------------------------------------------------

library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.NUMERIC_STD.all;
use ieee.std_logic_unsigned.all;
  
entity ROMZ is  
  port (      
        raddr             : in  STD_LOGIC_VECTOR(6 downto 0);
        clk               : in  STD_LOGIC;       
        q                 : out STD_LOGIC_VECTOR(7 downto 0)
  );
end ROMZ;   

architecture RTL of ROMZ is

   type rom_type is array (127 downto 0) of std_logic_vector (7 downto 0);                 
    signal ROM : rom_type:= (
							-- lum table 50%
							X"10", X"0B", X"0C", X"0E", X"0C", X"0A", X"10", X"0E", 
							X"0D", X"0E", X"12", X"11", X"10", X"13", X"18", X"28",
							X"1A", X"18", X"16", X"16", X"18", X"31", X"23", X"25", 
							X"1D", X"28", X"3A", X"33", X"3D", X"3C", X"39", X"33",
							X"38", X"37", X"40", X"48", X"5C", X"4E", X"40", X"44", 
							X"57", X"45", X"37", X"38", X"50", X"6D", X"51", X"57",
							X"5F", X"62", X"67", X"68", X"67", X"3E", X"4D", X"71", 
							X"79", X"70", X"64", X"78", X"5C", X"65", X"67", X"63",
							-- Cr table 50%
							X"11", X"12", X"12", X"18", X"15", X"18", X"2F", X"1A", 
							X"1A", X"2F", X"63", X"42", X"38", X"42", X"63", X"63",
							X"63", X"63", X"63", X"63", X"63", X"63", X"63", X"63", 
							X"63", X"63", X"63", X"63", X"63", X"63", X"63", X"63",
							X"63", X"63", X"63", X"63", X"63", X"63", X"63", X"63", 
							X"63", X"63", X"63", X"63", X"63", X"63", X"63", X"63",
							X"63", X"63", X"63", X"63", X"63", X"63", X"63", X"63", 
							X"63", X"63", X"63", X"63", X"63", X"63", X"63", X"63"
							);                        


begin


    process (CLK)
    begin
        if (CLK'event and CLK = '1') then
                q <= ROM(conv_integer(raddr));
        end if;
    end process;

 
    
end RTL;