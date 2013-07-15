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
/*!
 This module handles the communication of EDID structure with PC and monitor/projector.
 It contains two sub-modules and one sequaltial logic block.
 The sequaltial logic block reads the EDID from montor when it detects the HPD from monitor by using edidmaster block.
 at the same time it pulls the HPD connected with PC HDMI to down, simulating the HDP disconnect. 
 Then PC initiates the i2c communication with FPGA using edidslave block and reads the EDID structure. 
*/

module edid_master_slave_hack(
input rst_n,
input clk,
inout sda_lcd,
output scl_lcd,
inout sda_pc,
input scl_pc,
input hpd_lcd,
output reg hpd_pc,
output [7:0] sda_byte,
output sda_byte_en,
output reg dvi_only,
input hdmi_dvi
);


reg stop;

wire [7:0] edid_byte_lcd;
reg [6:0] counter;
reg [6:0] segments, segment_count;
reg [7:0] debounce_hpd;
reg hpda_stable,hpda_stable_q;
wire start_reading,edid_byte_lcd_en;

assign start_reading = (hpda_stable^hpda_stable_q) & hpda_stable; //% start reading from lcd on the rising edge of hpd

always @(posedge clk) begin

	if (~rst_n) begin	
		counter <= 0;
		stop <= 0;
		dvi_only <= 1;
		segments <= 0;
		segment_count <= 0;
		hpd_pc <= 0;
		hpda_stable <= 0;
		hpda_stable_q <= 0;
	end else begin 
		//% debounce hpd_lcd
		debounce_hpd <= {debounce_hpd[6:0],hpd_lcd};		
		if (debounce_hpd == 8'd255) begin
			hpda_stable <= 1;
		end
		hpda_stable_q <= hpda_stable;
		
		if (start_reading) begin
			hpd_pc <= 0;
			stop <= 0;
		end
		
		if (start_reading | stop) begin //% assuming only edid segment and then will be updated after 
			segments <= 0;
			segment_count <= 0;
			counter <= 0;
		end

		if (edid_byte_lcd_en) begin
			
			counter <= counter +1;
			
			if (segment_count==0) begin //% edid segment  
				if (counter == 127) begin //% only dvi resolution so dont read further. 
					if (segments == 0) begin
						stop <= 1;
						hpd_pc <= 1;
					end else begin
						segment_count <= 1;
					end
				end
				if (counter == 126) begin
					if  (edid_byte_lcd == 0) begin
						dvi_only <= 1;
					end else begin
						segments <= edid_byte_lcd;
					end
				end				
			end else begin //% edid extensions 
				if (counter == 127) begin //% only dvi resolution so dont read further. 
					if (segment_count == segments) begin
						stop <= 1;
						hpd_pc <=1;
					end else begin
						segment_count <= segment_count+1;
					end					
				end
				if (counter == 0) begin
					if (edid_byte_lcd == 2) begin //% hdmi detected
						dvi_only <= 0;
					end
				end
				
			end
		end 
	
	end // rst and clk

end // always

//% EDID master module for reading edid from LCD
edidmaster edid_master(
.rst_n(rst_n),
.clk(clk),
.sda(sda_lcd),
.scl(scl_lcd),
.stop_reading(stop),
.address_w(8'ha0),
.start(start_reading),
.address_r(8'ha1),
.reg0(8'h0),
.sdadata(edid_byte_lcd),
.out_en(edid_byte_lcd_en)
);
assign sda_byte = edid_byte_lcd;
assign sda_byte_en = edid_byte_lcd_en;

//% EDID slave for transmiting EDID to PC
edidslave edid_slave(
.rst_n(rst_n),
.clk(clk),
.sda(sda_pc),
.scl(scl_pc),
.dvi_only(hdmi_dvi)
);

endmodule
