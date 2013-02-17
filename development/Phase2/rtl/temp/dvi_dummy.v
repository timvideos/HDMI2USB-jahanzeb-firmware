//////////////////////////////////////////////////////////////////////////////
/// Copyright (c) 2013, Jahanzeb Ahmad
/// All rights reserved.
///
// Redistribution and use in source and binary forms, with or without modification, 
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


`timescale 1 ns / 1 ps


module dvi_dummy (
  input wire        rst_n,    //The pink reset button
  input wire        clk,      //100 MHz osicallator
  
  input wire [3:0]  RX0_TMDS,
  input wire [3:0]  RX0_TMDSB,

  output wire [3:0] TX0_TMDS,
  output wire [3:0] TX0_TMDSB,
  
  output reg [23:0] rgb,
  output reg rgb_de,
  output reg hsync,
  output reg vsync,
  output wire pclk,

  input  wire SW,
	
  output wire [4:0] LED,
  output wire clk10x

);
assign clk10x = 0;
assign LED = 0;
assign TX0_TMDS = 0;
assign TX0_TMDSB = 0;



reg [23:0] rgb_i;
reg pclk_i,de_valid;
reg [31:0] counter_hsync,counter_vsync;
reg [31:0] total_counter;
reg [3:0] pclk_count;
assign pclk = pclk_i;
// assign pclk = clk;

always @(posedge clk) begin
	if (~rst_n) begin	
		pclk_count <= 0;
		pclk_i <= 0;
	end else begin
	pclk_count <= pclk_count +1;
		if (pclk_count == 2) begin
			pclk_i <= ~ pclk_i;
			pclk_count <= 0;
		end
	end 
end 

always @(pclk_i,rst_n) begin
// always @(posedge clk) begin
	if (~rst_n) begin	
		rgb <= 0;
		rgb_i <= 0;
		rgb_de <= 0;
		hsync <= 0;
		vsync <= 0;
		counter_hsync <= 0;
		counter_vsync <= 0;
		de_valid <= 0;
	end else if (pclk_i) begin
	// end else begin
		if (de_valid == 1) begin
			rgb_i <= rgb_i + 1;
			rgb	 <= rgb_i;
		end
		
		counter_hsync <= counter_hsync +1;
		
		if (counter_hsync < 1048) begin
			hsync <= 1;
		end else if (counter_hsync == 1100 ) begin
			hsync <= 0;
		end else if (counter_hsync == 1300 ) begin
			counter_hsync <= 0;
			counter_vsync <= counter_vsync +1;
		end
		
		
		if ((counter_hsync == 50) & de_valid) begin
			rgb_de <= 1;
		end else if ((counter_hsync == (50+1024)) & de_valid) begin
			rgb_de <= 0;
		end 
		
		
		if (counter_vsync == 0) begin
			vsync <= 1;
			rgb_i <=0;
		end else if (counter_vsync == 30) begin
			de_valid <= 1;
		end else if (counter_vsync == (768 + 30)) begin
			de_valid <= 0;
		end else if (counter_vsync == (768 + 34)) begin
			vsync <= 0;
		end else if (counter_vsync == (768 + 34+7)) begin
			counter_vsync <= 0;
		end 
		
	
		

	end 
end 
	
endmodule
