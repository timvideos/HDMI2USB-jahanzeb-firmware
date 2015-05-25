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
 This module handles the communication of EDID structure with PC and monitor /
 projector. It contains two sub-modules and one sequential logic block.

 When the hpd_lcd of the monitor is triggered, the EDID data is read from the
 monitor using the edidmaster block. While reading the EDID data, we determine
 if the monitor supports DVI or HDMI modes and set dvi_only signal.

 During reading the EDID from the monitor, we pull the hpd_pc signal low,
 "disconnecting" the HDMI2USB from the PC. Once the EDID is read from the
 monitor, the hpd_pc is again pulled high and the PC will initiate I2C
 communication with the FPGA to read the EDID data.
*/

module edid_master_slave_hack(
input rst_n,
input clk,

// EDID signals to the "display" side (graphical output from HDMI2USB point of
// view). The HDMI2USB board is the I2C master and reads the  EDID information
// out of the display and stores it internally.
inout sda_lcd,
output scl_lcd,
input hpd_lcd,

// EDID signals to the "pc" side (graphical input from the HDMI2USB point of
// view). The HDMI2USB board is the I2C slave and provides the modified EDID
// information to the connected PC.
inout sda_pc,
input scl_pc,
output reg hpd_pc,

// The raw EDID data read from the display side.
output [7:0] sda_byte,
output sda_byte_en,

// Does the EDID data contain only DVI information?
output reg dvi_only,

// Should we output HDMI or DVI EDID to connected PC?
input hdmi_dvi
);


reg stop;

wire [7:0] edid_byte_lcd;
reg [6:0] counter;
reg [6:0] segments, segment_count;
reg [7:0] debounce_hpd;
reg hpda_stable,hpda_stable_q;
wire start_reading,edid_byte_lcd_en;

//% Start reading from lcd on the rising edge of hpd
assign start_reading = (hpda_stable^hpda_stable_q) & hpda_stable;

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
		//% Debounce hpd (hot plug detect) from the LCD.
		debounce_hpd <= {debounce_hpd[6:0],hpd_lcd};		
		if (debounce_hpd == 8'd255) begin
			hpda_stable <= 1;
		end
		hpda_stable_q <= hpda_stable;
		
		if (start_reading) begin
			hpd_pc <= 0;
			stop <= 0;
		end
		
		//% Assuming only edid segment and then will be updated after.
		if (start_reading | stop) begin 
			segments <= 0;
			segment_count <= 0;
			counter <= 0;
		end

		//% Read the EDID information and determine if it contains HDMI or DVI data.
		if (edid_byte_lcd_en) begin
			counter <= counter +1;
			
			if (segment_count==0) begin //% edid segment  
				if (counter == 127) begin //% only dvi resolution so don't read further.
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
				if (counter == 127) begin //% only dvi resolution so don't read further.
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

//% EDID master module for reading EDID from LCD
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

//% EDID slave for transmitting EDID to PC
edidslave edid_slave(
.rst_n(rst_n),
.clk(clk),
.sda(sda_pc),
.scl(scl_pc),
.dvi_only(hdmi_dvi)
);

endmodule
