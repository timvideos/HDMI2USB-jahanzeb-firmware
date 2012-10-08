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
///    POSSIBILITY OF SUCH DAMAGE.
//
//////////////////////////////////////////////////////////////////////////////
/**
 HDMI 2 USB(jpeg) converter top leve module.
 this file contains all the necessare mobules needed.
 discription of each module is given in its top level file.

 Usefull links are
 
 http://www.xilinx.com/support/documentation/application_notes/xapp495_S6TMDS_Video_Interface.pdf
 http://www.xilinx.com/support/documentation/spartan-6.htm
 http://www.evernew.com.tw/HDMISpecification13a.pdf
 http://read.pudn.com/downloads110/ebook/456020/E-EDID%20Standard.pdf
 http://www.nxp.com/documents/user_manual/UM10204.pdf
 http://www.digilentinc.com/Products/Detail.cfm?NavPath=2,400,836&Prod=ATLYS
 
 http://en.wikipedia.org/wiki/Extended_display_identification_data
 http://en.wikipedia.org/wiki/I%C2%B2C
 http://en.wikipedia.org/wiki/Hdmi
 
*/

module hdmi2usb(
input wire rst_n,    //The pink reset button
input wire clk,      //100 MHz osicallator
input wire [3:0]  RX0_TMDS,
input wire [3:0]  RX0_TMDSB,
output wire [3:0] TX0_TMDS,
output wire [3:0] TX0_TMDSB,
input  wire [1:0] SW,
output wire [7:0] LED,
input wire scl_pc,
output wire scl_lcd,
inout wire sda_pc,
inout wire sda_lcd,
//////////
inout [7:0] pdb,
input astb,
input dstb,
input pwr,
output pwait,
output [15:0] reX,reY
);

wire [15:0] resX,resY;
wire rgb_de,hsync,vsync,pclk;
wire clk10x;

assign reX = resX;
assign reY = resY;

edid_master_slave_hack edid_master_slave_hack(
.rst_n(rst_n),
.clk(clk),
.sda_lcd(sda_lcd),
.scl_lcd(scl_lcd),
.sda_pc(sda_pc),
.scl_pc(scl_pc),
.hpd_lcd(SW[0]),
.hpd_pc(LED[2])
);

  
dvi_demo dvi_demo0(
.rst_n(rst_n),    //The pink reset button
.clk(clk),      //100 MHz osicallator  
.RX0_TMDS(RX0_TMDS),
.RX0_TMDSB(RX0_TMDSB),
.TX0_TMDS(TX0_TMDS),
.TX0_TMDSB(TX0_TMDSB),  
.rgb(rgb), // raw RGB 
.rgb_de(rgb_de), //  RGB en
.hsync(hsync),
.vsync(vsync),
.pclk(pclk),
.SW(SW[1]),	
.LED(LED[7:3]),
.clk10x(clk10x)
);

calc_res calc_res(
.clk(clk10x),      //100 MHz osicallatorsa
.rst_n(rst_n),
.de(rgb_de),
.hsync(hsync),
.vsync(vsync),
.resX(resX),
.resY(resY),
.pclk(pclk)
);


dpimref dpimref(
.mclk(clk),
.pdb(pdb),
.astb(astb),
.dstb(dstb),
.pwr(pwr),
.pwait(pwait),
.resX(resX),
.resY(resY)
);

endmodule
