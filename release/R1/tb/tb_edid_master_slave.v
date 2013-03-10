//////////////////////////////////////////////////////////////////////////////
/// Copyright (c) 2012, Jahanzeb Ahmad
/// All rights reserved.
///
/// Redistribution and use in source and binary forms, with or without modification, 
/// are permitted provided that the following conditions are met:
///
///  * Redistributions of source code must retain the above copyright notice, 
///    this list of conditions and the following disclaimer.
///  * Redistributions in binary form must reproduce the above copyright notice, 
///    this list of conditions and the following disclaimer in the documentation and/or 
///    other materials provided with the distribution.
///
///    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
///    EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
///    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
///    SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
///    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
///    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
///    PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
///    WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
///    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
///   POSSIBILITY OF SUCH DAMAGE.
///
///
///  * http://opensource.org/licenses/MIT
///  * http://copyfree.org/licenses/mit/license.txt
///
//////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
module tb_edid_master_slave;

reg rst_n,clk,start;
wire scl_lcd,scl_pc,edid_byte_lcd_en,sda_lcd,sda_pc;
reg hpd_pc;
wire [7:0] edid_byte_lcd;

	initial begin	
	forever begin
	#5;
	clk = ~ clk;   
	end
	end
	
	pullup(sda_lcd);
	pullup(sda_pc);
		
	initial begin
		// Initialize Inputs
		rst_n = 0;
		clk = 0;
		start = 0;
		hpd_pc = 0;
		// Wait 100 ns for global reset to finish
		#100;
		rst_n = 1;
		#500;
		start<=1;
		#500;
		start<=0;
		

		
	end


edidmaster edidmaster(
.rst_n(rst_n),
.clk(clk),
.sda(sda_pc),
.scl(scl_pc),
.stop_reading(1'b0),
.address_w(8'ha0),
.start(~hpd_pc),
.address_r(8'ha1),
.reg0(8'h00),
.sdadata(edid_byte_lcd),
.out_en(edid_byte_lcd_en)
);

edidslave edidslave(
.rst_n(rst_n),
.clk(clk),
.sda(sda_lcd),
.scl(scl_lcd),
.dvi_only(1'b1)
);

edid_master_slave_hack	edid_master_slave_hack
(
.rst_n(rst_n),
.clk(clk),
.sda_lcd(sda_lcd),
.scl_lcd(scl_lcd),
.sda_pc(sda_pc),
.scl_pc(scl_pc),
.hpd_lcd(start),
.hpd_pc(hpd_pc)
);
	
	
	
endmodule
