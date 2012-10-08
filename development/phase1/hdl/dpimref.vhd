----------------------------------------------------------------------------
--	DPIMREF.VHD -- Digilent Parallel Interface Module Reference Design
----------------------------------------------------------------------------
-- Author:  Gene Apperson
--          Copyright 2004 Digilent, Inc.
----------------------------------------------------------------------------
-- IMPORTANT NOTE ABOUT BUILDING THIS LOGIC IN ISE
--
-- Before building the Dpimref logic in ISE:
-- 	1.  	In Project Navigator, right-click on "Synthesize-XST"
--		(in the Process View Tab) and select "Properties"
--	2.	Click the "HDL Options" tab
--	3. 	Set the "FSM Encoding Algorithm" to "None"
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
--	This module contains an example implementation of Digilent Parallel
--	Interface Module logic. This interface is used in conjunction with the
--	DPCUTIL DLL and a Digilent Communications Module (USB, EtherNet, Serial)
--	to exchange data with an application running on a host PC and the logic
--	implemented in a gate array.
--
--	See the Digilent document, Digilent Parallel Interface Model Reference
--	Manual (doc # 560-000) for a description of the interface.
--
--	This design uses a state machine implementation to respond to transfer
--	cycles. It implements an address register, 8 internal data registers
--	that merely hold a value written, and interface registers to communicate
--	with a Digilent DIO4 board. There is an LED output register whose value 
--	drives the 8 discrete leds on the DIO4. There are two input registers.
--	One reads the switches on the DIO4 and the other reads the buttons.
--
--	Interface signals used in top level entity port:
--		mclk		- master clock, generally 50Mhz osc on system board
--		pdb			- port data bus
--		astb		- address strobe
--		dstb		- data strobe
--		pwr			- data direction (described in reference manual as WRITE)
--		pwait		- transfer synchronization (described in reference manual
--						as WAIT)
--		rgLed		- LED outputs to the DIO4
--		rgSwt		- switch inputs from the DIO4
--		ldb			- led gate signal for the DIO4
--		rgBtn		- button inputs from the DIO4
--		btn			- button on system board (D2SB or D2FT)
--		led			- led on the system board
--		
----------------------------------------------------------------------------
-- Revision History:
--  06/09/2004(GeneA): created
--	08/10/2004(GeneA): initial public release
--	04/25/2006(JoshP): comment addition  
----------------------------------------------------------------------------

-- //////////////////////////////////////////////////////////////////////////////
-- // Copyright (c) 2012, Jahanzeb Ahmad
-- // All rights reserved.
-- //
-- // Redistribution and use in source and binary forms, with or without modification, 
-- // are permitted provided that the following conditions are met:
-- //
-- //  * Redistributions of source code must retain the above copyright notice, 
-- //    this list of conditions and the following disclaimer.
-- //  * Redistributions in binary form must reproduce the above copyright notice, 
-- //    this list of conditions and the following disclaimer in the documentation and/or 
-- //    other materials provided with the distribution.
-- //
-- //    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
-- //    EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
-- //    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
-- //    SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
-- //    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
-- //    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
-- //    PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
-- //    WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
-- //    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
-- //    POSSIBILITY OF SUCH DAMAGE.
-- //
-- //////////////////////////////////////////////////////////////////////////////

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dpimref is
    Port (
		mclk 	: in std_logic;
        pdb		: inout std_logic_vector(7 downto 0);
        astb 	: in std_logic;
        dstb 	: in std_logic;
        pwr 	: in std_logic;
        pwait 	: out std_logic;
		rgLed	: out std_logic_vector(7 downto 0); 
		rgSwt	: in std_logic_vector(7 downto 0);
		rgBtn	: in std_logic_vector(5 downto 0);
		btn		: in std_logic;
		ldg		: out std_logic;
		led		: out std_logic;
		resX	: in std_logic_vector(15 downto 0);
		resY	: in std_logic_vector(15 downto 0)
	);
end dpimref;

architecture Behavioral of dpimref is

------------------------------------------------------------------------
-- Component Declarations
------------------------------------------------------------------------
--component cc is
--port
-- (-- Clock in ports
--  CLK_IN1           : in     std_logic;
--  -- Clock out ports
--  CLK_OUT1          : out    std_logic
-- );
--end component cc;
	
------------------------------------------------------------------------
-- Local Type Declarations
------------------------------------------------------------------------

------------------------------------------------------------------------
--  Constant Declarations
------------------------------------------------------------------------

	-- The following constants define state codes for the EPP port interface
	-- state machine. The high order bits of the state number give a unique
	-- state identifier. The low order bits are the state machine outputs for
	-- that state. This type of state machine implementation uses no
	-- combination logic to generate outputs which should produce glitch
	-- free outputs.
	constant	stEppReady	: std_logic_vector(7 downto 0) := "0000" & "0000";
	constant	stEppAwrA	: std_logic_vector(7 downto 0) := "0001" & "0100";
	constant	stEppAwrB	: std_logic_vector(7 downto 0) := "0010" & "0001";
	constant	stEppArdA	: std_logic_vector(7 downto 0) := "0011" & "0010";
	constant	stEppArdB	: std_logic_vector(7 downto 0) := "0100" & "0011";
	constant	stEppDwrA	: std_logic_vector(7 downto 0) := "0101" & "1000";
	constant	stEppDwrB	: std_logic_vector(7 downto 0) := "0110" & "0001";
	constant	stEppDrdA	: std_logic_vector(7 downto 0) := "0111" & "0010";
	constant	stEppDrdB	: std_logic_vector(7 downto 0) := "1000" & "0011";

------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------

	-- State machine current state register
	signal	stEppCur	: std_logic_vector(7 downto 0) := stEppReady;

	signal	stEppNext	: std_logic_vector(7 downto 0);

	signal	clkMain		: std_logic;

	-- Internal control signales
	signal	ctlEppWait	: std_logic;
	signal	ctlEppAstb	: std_logic;
	signal	ctlEppDstb	: std_logic;
	signal	ctlEppDir	: std_logic;
	signal	ctlEppWr	: std_logic;
	signal	ctlEppAwr	: std_logic;
	signal	ctlEppDwr	: std_logic;
	signal	busEppOut	: std_logic_vector(7 downto 0);
	signal	busEppIn	: std_logic_vector(7 downto 0);
	signal	busEppData	: std_logic_vector(7 downto 0);

	-- Registers
	signal	regEppAdr	: std_logic_vector(3 downto 0);
	signal	regData0	: std_logic_vector(7 downto 0);
	signal	regData1	: std_logic_vector(7 downto 0);
    signal  regData2	: std_logic_vector(7 downto 0);
    signal  regData3	: std_logic_vector(7 downto 0);
    signal  regData4	: std_logic_vector(7 downto 0);
	signal	regData5	: std_logic_vector(7 downto 0);
	signal	regData6	: std_logic_vector(7 downto 0);
	signal	regData7	: std_logic_vector(7 downto 0);
	signal	regLed		: std_logic_vector(7 downto 0);

	signal	cntr		: std_logic_vector(7 downto 0); 

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------

begin

    ------------------------------------------------------------------------
	-- Map basic status and control signals
    ------------------------------------------------------------------------
--cc1: component cc
--port map
--(
--CLK_IN1 => mclk,
--clk_out1 => clkMain
--);
	clkMain <= mclk;

	ctlEppAstb <= astb;
	ctlEppDstb <= dstb;
	ctlEppWr   <= pwr;
	pwait      <= ctlEppWait;	-- drive WAIT from state machine output

	-- Data bus direction control. The internal input data bus always
	-- gets the port data bus. The port data bus drives the internal
	-- output data bus onto the pins when the interface says we are doing
	-- a read cycle and we are in one of the read cycles states in the
	-- state machine.
	busEppIn <= pdb;
	pdb <= busEppOut when ctlEppWr = '1' and ctlEppDir = '1' else "ZZZZZZZZ";

	-- Select either address or data onto the internal output data bus.
	busEppOut <= "0000" & regEppAdr when ctlEppAstb = '0' else busEppData;

	rgLed <= regLed;
	ldg <= '1';

	-- Decode the address register and select the appropriate data register
	-- busEppData <=	cntr(7 downto 0) 	when regEppAdr = "0000" else
	busEppData<=resX(15 downto 8)	when regEppAdr = "0000" else
					resX( 7 downto 0)	when regEppAdr = "0001" else
					resY(15 downto 8) when regEppAdr = "0010" else
					resY( 7 downto 0) when regEppAdr = "0011" else
					regData4 when regEppAdr = "0100" else
					regData5 when regEppAdr = "0101" else
					regData6 when regEppAdr = "0110" else
					regData7 when regEppAdr = "0111" else
					rgSwt    when regEppAdr = "1000" else
					"00" & rgBtn when regEppAdr = "1001" else
					"00000000";

    ------------------------------------------------------------------------
	-- EPP Interface Control State Machine
    ------------------------------------------------------------------------

	-- Map control signals from the current state
	ctlEppWait <= stEppCur(0);
	ctlEppDir  <= stEppCur(1);
	ctlEppAwr  <= stEppCur(2);
	ctlEppDwr  <= stEppCur(3);

	-- This process moves the state machine to the next state
	-- on each clock cycle
	process (clkMain)
		begin
			if clkMain = '1' and clkMain'Event then
				stEppCur <= stEppNext;
					if stEppNext = stEppDrdA then
						cntr <= cntr + 1;
					end if;
			end if;
		end process;

	-- This process determines the next state machine state based
	-- on the current state and the state machine inputs.
	process (stEppCur, stEppNext, ctlEppAstb, ctlEppDstb, ctlEppWr)
		begin
			case stEppCur is
				-- Idle state waiting for the beginning of an EPP cycle
				when stEppReady =>
					if ctlEppAstb = '0' then
						-- Address read or write cycle
						if ctlEppWr = '0' then
							stEppNext <= stEppAwrA;
						else
							stEppNext <= stEppArdA;
						end if;

					elsif ctlEppDstb = '0' then
						-- Data read or write cycle
						if ctlEppWr = '0' then
							stEppNext <= stEppDwrA;
						else
							stEppNext <= stEppDrdA;
						end if;

					else
						-- Remain in ready state
						stEppNext <= stEppReady;
					end if;											

				-- Write address register
				when stEppAwrA =>
					stEppNext <= stEppAwrB;

				when stEppAwrB =>
					if ctlEppAstb = '0' then
						stEppNext <= stEppAwrB;
					else
						stEppNext <= stEppReady;
					end if;		

				-- Read address register
				when stEppArdA =>
					stEppNext <= stEppArdB;

				when stEppArdB =>
					if ctlEppAstb = '0' then
						stEppNext <= stEppArdB;
					else
						stEppNext <= stEppReady;
					end if;

				-- Write data register
				when stEppDwrA =>
					stEppNext <= stEppDwrB;

				when stEppDwrB =>
					if ctlEppDstb = '0' then
						stEppNext <= stEppDwrB;
					else
 						stEppNext <= stEppReady;
					end if;

				-- Read data register
				when stEppDrdA =>
					stEppNext <= stEppDrdB;
										
				when stEppDrdB =>
					if ctlEppDstb = '0' then
						stEppNext <= stEppDrdB;
					else
				  		stEppNext <= stEppReady;
					end if;

				-- Some unknown state				
				when others =>
					stEppNext <= stEppReady;

			end case;
		end process;
		
    ------------------------------------------------------------------------
	-- EPP Address register
    ------------------------------------------------------------------------

	process (clkMain, ctlEppAwr)
		begin
			if clkMain = '1' and clkMain'Event then
				if ctlEppAwr = '1' then
					regEppAdr <= busEppIn(3 downto 0);
				end if;
			end if;
		end process;

    ------------------------------------------------------------------------
	-- EPP Data registers
    ------------------------------------------------------------------------
 	-- The following processes implement the interface registers. These
	-- registers just hold the value written so that it can be read back.
	-- In a real design, the contents of these registers would drive additional
	-- logic.
	-- The ctlEppDwr signal is an output from the state machine that says
	-- we are in a 'write data register' state. This is combined with the
	-- address in the address register to determine which register to write.

	process (clkMain, regEppAdr, ctlEppDwr, busEppIn)
		begin
			if clkMain = '1' and clkMain'Event then
				if ctlEppDwr = '1' and regEppAdr = "0000" then
					regData0 <= busEppIn;
				end if;
			end if;
		end process;

	process (clkMain, regEppAdr, ctlEppDwr, busEppIn)
		begin
			if clkMain = '1' and clkMain'Event then
				if ctlEppDwr = '1' and regEppAdr = "0001" then
					regData1 <= busEppIn;
				end if;
			end if;
		end process;

	process (clkMain, regEppAdr, ctlEppDwr, busEppIn)
		begin
			if clkMain = '1' and clkMain'Event then
				if ctlEppDwr = '1' and regEppAdr = "0010" then
					regData2 <= busEppIn;
				end if;
			end if;
		end process;

	process (clkMain, regEppAdr, ctlEppDwr, busEppIn)
		begin
			if clkMain = '1' and clkMain'Event then
				if ctlEppDwr = '1' and regEppAdr = "0011" then
					regData3 <= busEppIn;
				end if;
			end if;
		end process;

	process (clkMain, regEppAdr, ctlEppDwr, busEppIn)
		begin
			if clkMain = '1' and clkMain'Event then
				if ctlEppDwr = '1' and regEppAdr = "0100" then
					regData4 <= busEppIn;
				end if;
			end if;
		end process;

	process (clkMain, regEppAdr, ctlEppDwr, busEppIn)
		begin
			if clkMain = '1' and clkMain'Event then
				if ctlEppDwr = '1' and regEppAdr = "0101" then
					regData5 <= busEppIn;
				end if;
			end if;
		end process;

	process (clkMain, regEppAdr, ctlEppDwr, busEppIn)
		begin
			if clkMain = '1' and clkMain'Event then
				if ctlEppDwr = '1' and regEppAdr = "0110" then
					regData6 <= busEppIn;
				end if;
			end if;
		end process;

	process (clkMain, regEppAdr, ctlEppDwr, busEppIn)
		begin
			if clkMain = '1' and clkMain'Event then
				if ctlEppDwr = '1' and regEppAdr = "0111" then
					regData7 <= busEppIn;
				end if;
			end if;
		end process;

	process (clkMain, regEppAdr, ctlEppDwr, busEppIn)
		begin
			if clkMain = '1' and clkMain'Event then
				if ctlEppDwr = '1' and regEppAdr = "1010" then
					regLed <= busEppIn;
				end if;
			end if;
		end process;


	------------------------------------------------------------------------
    -- Gate array configuration verification logic
	------------------------------------------------------------------------
	-- This logic will flash the led on the gate array. This is to verify
	-- that the gate array is properly configured for the test. This is a
	-- simple way to verify that the gate array actually got configured.

 	-- led <= btn or cntr(23);

	-- process (clkMain)
		-- begin
			-- if clkMain = '1' and clkMain'Event then
				-- cntr <= cntr + 1;
			-- end if;
		-- end process;

----------------------------------------------------------------------------

end Behavioral;
