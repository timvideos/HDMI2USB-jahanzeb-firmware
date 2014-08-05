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

library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.NUMERIC_STD.all;
  
 entity RAMF is 
   generic (
     RAMD_W : INTEGER := 12;
     RAMA_W : INTEGER := 6  
     );     
   port (      
     d      : in  STD_LOGIC_VECTOR(RAMD_W-1 downto 0);
     waddr  : in  STD_LOGIC_VECTOR(RAMA_W-1 downto 0);
     raddr  : in  STD_LOGIC_VECTOR(RAMA_W-1 downto 0);
     we     : in  STD_LOGIC;
     clk    : in  STD_LOGIC;
     
     q      : out STD_LOGIC_VECTOR(RAMD_W-1 downto 0)
  );
end RAMF;   

architecture RTL of RAMF is
  type mem_type is array ((2**RAMA_W)-1 downto 0) of 
                              STD_LOGIC_VECTOR(RAMD_W-1 downto 0);
  signal mem                    : mem_type;
  signal read_addr              : STD_LOGIC_VECTOR(RAMA_W-1 downto 0);
  
begin       
  
  -------------------------------------------------------------------------------
  q_sg:
  -------------------------------------------------------------------------------
  q <= mem(TO_INTEGER(UNSIGNED(read_addr)));    
  
  -------------------------------------------------------------------------------
  read_proc: -- register read address
  -------------------------------------------------------------------------------
  process (clk)
  begin 
    if clk = '1' and clk'event then        
      read_addr <= raddr;
    end if;  
  end process;
  
  -------------------------------------------------------------------------------
  write_proc: --write access
  -------------------------------------------------------------------------------
  process (clk) begin
    if clk = '1' and clk'event then
      if we = '1'  then
        mem(TO_INTEGER(UNSIGNED(waddr))) <= d;
      end if;
    end if;
  end process;
    
end RTL;
----------------------------------------------------------------------------------

library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.numeric_std.all;
library WORK;
  
entity FIFO is   
  generic (
        DATA_WIDTH         : INTEGER   := 12;
        ADDR_WIDTH         : INTEGER   := 2
       );
  port (        
        rst               : in  STD_LOGIC;
        clk               : in  STD_LOGIC;
        rinc              : in  STD_LOGIC;
        winc              : in  STD_LOGIC;
        datai             : in  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        
        datao             : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        fullo             : out STD_LOGIC;
        emptyo            : out STD_LOGIC;
        count             : out STD_LOGIC_VECTOR (ADDR_WIDTH downto 0)
        );
end FIFO;

architecture RTL of FIFO is

  signal raddr_reg        : unsigned(ADDR_WIDTH-1 downto 0);
  signal waddr_reg        : unsigned(ADDR_WIDTH-1 downto 0);
  signal count_reg        : unsigned(ADDR_WIDTH downto 0);
  signal rd_en_reg        : STD_LOGIC;
  signal wr_en_reg        : STD_LOGIC;
  signal empty_reg        : STD_LOGIC;
  signal full_reg         : STD_LOGIC;
  signal ramq             : STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
  signal ramd             : STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
  signal ramwaddr         : STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
  signal ramenw           : STD_LOGIC; 
  signal ramraddr         : STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
  signal ramenr           : STD_LOGIC;

  constant ZEROS_C        : STD_LOGIC_VECTOR(ADDR_WIDTH downto 0) := (others => '0'); 
  constant ONES_C         : STD_LOGIC_VECTOR(ADDR_WIDTH downto 0) := (others => '1'); 

  component RAMF
  generic (
           RAMD_W : INTEGER := 12;
           RAMA_W : INTEGER := 6
  );   
  port (      
        d                 : in  STD_LOGIC_VECTOR(RAMD_W-1 downto 0);
        waddr             : in  STD_LOGIC_VECTOR(RAMA_W-1 downto 0);
        raddr             : in  STD_LOGIC_VECTOR(RAMA_W-1 downto 0);
        we                : in  STD_LOGIC;
        clk               : in  STD_LOGIC;
        
        q                 : out STD_LOGIC_VECTOR(RAMD_W-1 downto 0)
  );
  end component;
begin 

  U_RAMF : RAMF
  generic map (
           RAMD_W => DATA_WIDTH,
           RAMA_W => ADDR_WIDTH
  )   
  port map (      
        d            => ramd,               
        waddr        => ramwaddr,     
        raddr        => ramraddr,     
        we           => ramenw,     
        clk          => clk,     
        
        q            => ramq     
  ); 
  
  ramd          <= datai;
  
  ramwaddr      <= std_logic_vector(waddr_reg);
  
  ramenw        <= wr_en_reg;
  
  ramraddr      <= std_logic_vector(raddr_reg);

  ramenr        <= '1';      
  
  datao         <= ramq;
  
  emptyo        <= empty_reg;
  
  fullo         <= full_reg;
  
  rd_en_reg     <= (rinc and not empty_reg);                      
  
  wr_en_reg     <= (winc and not full_reg); 
  
  count <= std_logic_vector(count_reg);    

  process(clk)
  begin 
    if clk = '1' and clk'event then
      if rst = '1' then
        empty_reg         <= '1';   
      else
        if count_reg = unsigned(ZEROS_C) or
          (count_reg = 1 and rd_en_reg = '1' and wr_en_reg = '0') then
          empty_reg       <= '1';
        else
          empty_reg       <= '0';
        end if;  
      end if;
    end if;
  end process;

  process(clk)
  begin 
    if clk = '1' and clk'event then
      if rst = '1' then
        full_reg          <= '0';   
      else
        if count_reg = 2**ADDR_WIDTH or
          (count_reg = 2**ADDR_WIDTH-1 and wr_en_reg = '1' and rd_en_reg = '0') then 
          full_reg        <= '1';
        else
          full_reg        <= '0';
        end if;  
      end if;
    end if;
  end process;

  process(clk)
  begin 
    if clk = '1' and clk'event then
      if rst = '1' then
        raddr_reg <= (others => '0');   
      else
        if rd_en_reg = '1' then
          raddr_reg <= raddr_reg + to_unsigned(1, raddr_reg'length);
        end if; 
      end if;
    end if;
  end process;          

  process(clk)
  begin 
    if clk = '1' and clk'event then
      if rst = '1' then
        waddr_reg <= (others => '0');  
      else        
        if wr_en_reg = '1' then
          waddr_reg <= waddr_reg + to_unsigned(1, waddr_reg'length);
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin 
    if clk = '1' and clk'event then
      if rst = '1' then
        count_reg         <= (others => '0');   
      else
        if (rd_en_reg = '1' and wr_en_reg = '0') or (rd_en_reg = '0' and wr_en_reg = '1') then
          if rd_en_reg = '1' then
            count_reg     <= count_reg - to_unsigned(1, count_reg'length);
          else
            count_reg     <= count_reg + to_unsigned(1, count_reg'length);
          end if;
        end if;
      end if;
    end if;
  end process;

end RTL;
