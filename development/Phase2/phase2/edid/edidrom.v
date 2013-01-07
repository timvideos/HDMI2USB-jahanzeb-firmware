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
 ROM for EDID DVI structure only, not for HDMI.
*/

module edidrom (clk,adr,data);

input clk;
input [7:0] adr;
output [7:0] data;


reg [7:0] data ;
       
always @ (posedge clk)
begin
  case (adr)
    // 0-7  bytes fixed header
    // 0-7  bytes fixed header
	0 : data = 8'h00; 
    1 : data = 8'hff; 
    2 : data = 8'hff;
    3 : data = 8'hff;
    4 : data = 8'hff;
    5 : data = 8'hff;
    6 : data = 8'hff;
    7 : data = 8'h00;
	
	// Manufacturer  ID // JAZ
    8 : data = 8'h28;
    9 : data = 8'h3A;
		
    //product code
	10 : data = 8'h00;
    11 : data = 8'h00;
    
	// serial no
	12 : data = 8'h00;
    13 : data = 8'h00;
    14 : data = 8'h00;
    15 : data = 8'h00;
	
	// week and year of manufacture
	16 : data = 8'h01; //w=1
	17 : data = 8'h17; // y = 2013
	
	// EDID version
	18 : data = 8'h01;
	19 : data = 8'h03;
	
	// 20-24 display basic par
	20 : data = 8'b10000001;
	21 : data = 0; // for projector
	22 : data = 0; // for projector
	23 : data = 120; // gamma set to 2.2 
	24 : data = 8'b00001111; //b7=standby, b6=suspend, b5=off, b43=00 for rgb only, b2=Standard sRGB colour space b1=Preferred timing mode specified in descriptor block 1 b0=GTF
	
	// 25-34 Chromaticity coordinates
	25 : data = 8'h5e;
	26 : data = 8'hc0;
	27 : data = 8'ha4;
	28 : data = 8'h59;
	29 : data = 8'h4a;
	30 : data = 8'h98;
	31 : data = 8'h25;
	32 : data = 8'h20;
	33 : data = 8'h50;
	34 : data = 8'h54;
	
	// 35–37 timing common types
	35 : data = 8'h00;
	36 : data = 8'h08; // only supporint 1024x768 @ 60 Hz // need to include more later
	37 : data = 8'h00;
	
	// 38–53 Standard timing information
	38 : data = 97; //resolution
	39 : data = 8'b01000000; // aspect ration // vertical frequecny - 60
	// unused 
	40 : data = 8'h01;
	41 : data = 8'h01;
	42 : data = 8'h01;
	43 : data = 8'h01;
	44 : data = 8'h01;
	45 : data = 8'h01;
	46 : data = 8'h01;
	47 : data = 8'h01;
	48 : data = 8'h01;
	49 : data = 8'h01;
	50 : data = 8'h01;
	51 : data = 8'h01;
	52 : data = 8'h01;
	53 : data = 8'h01;
	
	
	// 54–71 Descriptor 1 EDID Detailed Timing Descriptor
	(54+0) : data = 8'h94; //lsB
	(54+1) : data = 8'h11; //msB
	(54+2) : data = 0; //Horizontal active pixels 8 lsbits (0–4095)
	(54+3) : data = 32; //Horizontal blanking 8 lsbits (0–4095)
	(54+4) : data = 8'h40;//4*2 msb s
	(54+5) : data = 0; //vertical active pixels 8 lsbits (0–4095)
	(54+6) : data = 32; //vertical blanking 8 lsbits (0–4095)
	(54+7) : data = 8'h30; //4*2 msb s
	(54+8) : data = 8;	//Horizontal sync offset pixels 8 lsbits (0–1023) From blanking start
	(54+9) : data = 8; //Horizontal sync pulse width pixels 8 lsbits (0–1023)
	(54+10): data = 8'h88; // 4*2 lsbs vertical
	(54+11): data = 0; //msbs of above 
	(54+12): data = 0; //h display size, mm
	(54+13): data = 0; // v, display size, mm
	(54+14): data = 0; // msb of above
	(54+15): data = 0; // border
	(54+16): data = 0; // border
	(54+17): data = 8'b00011110; // Features bitmap //
	
	// 72–89 Descriptor 2 // EDID Other Monitor Descriptors
	(72+0) : data = 0;
	(72+1) : data = 0;
	(72+2) : data = 0;
	(72+3) : data = 8'hFC; // Monitor Names
	(72+4) : data = 0; 
	(72+5) : data = 74; // J
	(72+6) : data = 65; // A
	(72+7) : data = 72; // H
	(72+8) : data = 65; // A
	(72+9) : data = 78; // N
	(72+10): data = 90; // Z
	(72+11): data = 69; // E
	(72+12): data = 66; // B
	(72+13): data = 65; // A
	(72+14): data = 72; // H
	(72+15): data = 77; // M
	(72+16): data = 65; // A
	(72+17): data = 68; // D
	
	
	// 90–107 Descriptor 3 
	(90+0) : data = 0;
	(90+1) : data = 0;
	(90+2) : data = 0;
	(90+3) : data = 8'hFE; // unspecified text
	(90+4) : data = 0; 
	(90+5) : data = 74; // J
	(90+6) : data = 65; // A
	(90+7) : data = 72; // H
	(90+8) : data = 65; // A
	(90+9) : data = 78; // N
	(90+10): data = 90; // Z
	(90+11): data = 69; // E
	(90+12): data = 66; // B
	(90+13): data = 65; // A
	(90+14): data = 72; // H
	(90+15): data = 77; // M
	(90+16): data = 65; // A
	(90+17): data = 68; // D
	
	// 108–125 Descriptor 4
	(108+0) : data = 0;
	(108+1) : data = 0;
	(108+2) : data = 0;
	(108+3) : data = 8'hFE; // unspecified text
	(108+4) : data = 0; 
	(108+5) : data = 74; // J
	(108+6) : data = 65; // A
	(108+7) : data = 72; // H
	(108+8) : data = 65; // A
	(108+9) : data = 78; // N
	(108+10): data = 90; // Z
	(108+11): data = 69; // E
	(108+12): data = 66; // B
	(108+13): data = 65; // A
	(108+14): data = 72; // H
	(108+15): data = 77; // M
	(108+16): data = 65; // A
	(108+17): data = 67; // D
	
	
	// no of extensions 
	126 : data = 0; // no extensions 
	
	//
	127 : data = 7;//CRC, Sum of all 128 bytes should equal 0

	default : data = 8'h00; // total is 143 at the moment
	
  endcase
end

endmodule
