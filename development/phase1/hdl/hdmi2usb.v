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
///  * http://opensource.org/licenses/MIT
///  * http://copyfree.org/licenses/mit/license.txt
///
//////////////////////////////////////////////////////////////////////////////
/*!
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
input wire rst_n,    //% The pink reset button
input wire clk,      //% 100 MHz osicallator
input wire [3:0]  RX0_TMDS, //% HDMI RX
input wire [3:0]  RX0_TMDSB, //% HDMI RX
output wire [3:0] TX0_TMDS, //% HDMI TX
output wire [3:0] TX0_TMDSB, //% HDMI TX
input  wire [1:0] SW,
output wire [7:0] LED,
input wire scl_pc, //% DDC scl connected with PC
output wire scl_lcd, //% DDC scl connected with LCD
inout wire sda_pc, //% DDC sda connected with PC
inout wire sda_lcd, //% DDC sda connected with LCD
inout [7:0] pdb, //% data bus from register read. will only work with ATLYS
input astb, //% for register read. will only work with ATLYS
input dstb, //% fro register read. will only work with ATLYS
input pwr, //% fro register read. will only work with ATLYS
output pwait, //% fro register read. will only work with ATLYS
output [15:0] reX, //% Resolution of image in x-axis, might be removed in later stage.
output [15:0] reY  //% Resolution of image in y-axis, might be removed in later stage.
);

wire [15:0] resX,resY;
wire rgb_de,hsync,vsync,pclk;
wire clk10x;
wire [23:0] rgb,rgb0;

assign reX = resX;
assign reY = resY;

//% EDID hack unit, master slave based design
edid_master_slave_hack edid_hack(
.rst_n(rst_n),
.clk(clk),
.sda_lcd(sda_lcd),
.scl_lcd(scl_lcd),
.sda_pc(sda_pc),
.scl_pc(scl_pc),
.hpd_lcd(SW[0]),
.hpd_pc(LED[2])
);

//% HDMI decoder and encoder  
dvi_demo hdmi_RX_TX(
.rst_n(rst_n),    
.clk(clk),      
.RX0_TMDS(RX0_TMDS),
.RX0_TMDSB(RX0_TMDSB),
.TX0_TMDS(TX0_TMDS),
.TX0_TMDSB(TX0_TMDSB),  
.rgb(rgb), //% raw RGB 
.rgb_de(rgb_de), //%  RGB en
.hsync(hsync),
.vsync(vsync),
.pclk(pclk),
.SW(SW[1]),	
.LED(LED[7:3]),
.clk10x(clk10x)
);

//% resolution calculator
calc_res calcres(
.clk(clk10x),      //% pixel clk x 10
.rst_n(rst_n),
.de(rgb_de),
.hsync(hsync),
.vsync(vsync),
.resX(resX),
.resY(resY),
.pclk(pclk)
);

//% register transfer unit
dpimref regtransfer(
.mclk(clk),
.pdb(pdb),
.astb(astb),
.dstb(dstb),
.pwr(pwr),
.pwait(pwait),
.resX(resX),
.resY(resY),
.rgb(rgb0)
);

//% generates start of frame.
gen_start genstart(
.rst_n(rst_n),   
.clk(clk),      
.de(rgb_de),
.hsync(hsync),
.vsync(vsync),
.pclk(pclk),
.rgb(rgb),
.rgb0(rgb0),
.start(rgb_start)
);

endmodule
