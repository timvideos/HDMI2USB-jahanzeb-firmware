//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2012, Jahanzeb Ahmad
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, 
// are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, 
//    this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, 
//    this list of conditions and the following disclaimer in the documentation and/or 
//    other materials provided with the distribution.
//
//    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
//    EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
//    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
//    SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
//    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
//    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
//    PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
//    WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
//    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
//    POSSIBILITY OF SUCH DAMAGE.
//  * http://opensource.org/licenses/MIT
//  * http://copyfree.org/licenses/mit/license.txt
//
//////////////////////////////////////////////////////////////////////////////
/*!
 This module calculates the resolution of the image being displayed so that we can use it in the header of jpeg encoder.
*/
module calc_res(
input wire rst_n,    
input wire clk,      
input de,
input hsync,
input vsync,
output reg [15:0] resX,
output reg [15:0] resY
);

reg [15:0] resX_q,resY_q,resY_t;
reg vsync_q,hsync_q,de_q;
wire hsync_risingedge;
wire vsync_risingedge;
wire de_risingedge;

assign hsync_risingedge = ((hsync_q ^ hsync) & hsync);
assign vsync_risingedge = ((vsync_q ^ vsync) & vsync);
assign de_risingedge = ((de_q ^ de) & de);
assign de_fallingedge = ((de_q ^ de) & de_q);

always @(posedge clk) begin
	
if (~rst_n) begin	
	resX <= 0;
	resY <= 0;		
	resY_q <= 0;
	resX_q <= 0;	
	resY_t <= 0;	
end else begin
	
	vsync_q <= vsync;
	hsync_q <= hsync;
	de_q <= de;

	if (de) begin
		resX_q <= resX_q +1;
	end else if (hsync_risingedge) begin
		resX_q <= 0;
		if (resX_q != 0) begin
			resX <= resX_q;	
		end
	end
	
	if (de_risingedge) begin
		resY_q <= resY_q + 1;
	end else if (de_fallingedge) begin
		resY_t <= resY_q;
	end else if (vsync_risingedge) begin
		resY_q <= 0;
		if (resY_q != 0) begin
			resY <= resY_t;
		end
	end 
	
		
end
	
end
	
endmodule
