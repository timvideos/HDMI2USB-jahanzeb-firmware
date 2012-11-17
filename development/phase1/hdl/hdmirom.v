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
 HDMI rom for storing edid structure. This structure has one extenstion block contains the HDMI resolutions.
*/
module hdmirom (clk,adr,data);

input clk;
input [7:0] adr;
output [7:0] data;


reg [7:0] data ;
       
always @ (posedge clk)
begin
  case (adr)

0: data = 8'h00;
1: data = 8'hFF;
2: data = 8'hFF;
3: data = 8'hFF;
4: data = 8'hFF;
5: data = 8'hFF;
6: data = 8'hFF;
7: data = 8'h00;
8: data = 8'h28;
9: data = 8'h3A;
10: data = 8'h00;
11: data = 8'h00;
12: data = 8'h00;
13: data = 8'h00;
14: data = 8'h00;
15: data = 8'h00;

16: data = 8'h35;
17: data = 8'h16;
18: data = 8'h01;
19: data = 8'h03;
20: data = 8'h80;
21: data = 8'h00;
22: data = 8'h00;
23: data = 8'h78;
24: data = 8'h0E;
25: data = 8'h35;
26: data = 8'h85;
27: data = 8'hA6;
28: data = 8'h56;
29: data = 8'h48;
30: data = 8'h9A;
31: data = 8'h24;

32: data = 8'h12;
33: data = 8'h50;
34: data = 8'h54;
35: data = 8'h25;
36: data = 8'h4A;
37: data = 8'h00;
38: data = 8'h81;
39: data = 8'hC0;
40: data = 8'h01;
41: data = 8'h01;
42: data = 8'h01;
43: data = 8'h01;
44: data = 8'h01;
45: data = 8'h01;
46: data = 8'h01;
47: data = 8'h01;

48: data = 8'h01;
49: data = 8'h01;
50: data = 8'h01;
51: data = 8'h01;
52: data = 8'h01;
53: data = 8'h01;
54: data = 8'h01;
55: data = 8'h1D;
56: data = 8'h00;
57: data = 8'h08;
58: data = 8'h50;
59: data = 8'hD0;
60: data = 8'h08;
61: data = 8'h20;
62: data = 8'h08;
63: data = 8'h08;

64: data = 8'h88;
65: data = 8'h00;

66: data = 8'h00;
67: data = 8'h00;
68: data = 8'h00;
69: data = 8'h00;
70: data = 8'h00;
71: data = 8'h1E;
72: data = 8'h00;
73: data = 8'h00;
74: data = 8'h00;
75: data = 8'hFC;
76: data = 8'h00;
77: data = 8'h4A;
78: data = 8'h41;
79: data = 8'h48;

80: data = 8'h41;
81: data = 8'h4E;
82: data = 8'h5A;
83: data = 8'h45;
84: data = 8'h42;
85: data = 8'h41;
86: data = 8'h48;
87: data = 8'h4D;
88: data = 8'h41;
89: data = 8'h44;
90: data = 8'h00;
91: data = 8'h00;
92: data = 8'h00;
93: data = 8'hFC;
94: data = 8'h00;
95: data = 8'h4A;

96: data = 8'h41;
97: data = 8'h48;
98: data = 8'h41;
99: data = 8'h4E;
100: data = 8'h5A;
101: data = 8'h45;
102: data = 8'h42;
103: data = 8'h41;
104: data = 8'h48;
105: data = 8'h4D;
106: data = 8'h41;
107: data = 8'h44;
108: data = 8'h00;
109: data = 8'h00;
110: data = 8'h00;
111: data = 8'hFC;

112: data = 8'h00;
113: data = 8'h4A;
114: data = 8'h41;
115: data = 8'h48;
116: data = 8'h41;
117: data = 8'h4E;
118: data = 8'h5A;
119: data = 8'h45;
120: data = 8'h42;
121: data = 8'h41;
122: data = 8'h48;
123: data = 8'h4D;
124: data = 8'h41;
125: data = 8'h44;
126: data = 8'h01;
127: data = 8'h2C;

	
/// HDMI extension

	128: data = 2;	
	129: data = 1;	
	
	130: data = 4;	
	131: data = 0;
	132 : data = 1;
	133 : data = 29;
	134 : data = 0;
	135 : data = 114;
	136 : data = 81;
	137 : data = 208;
	138 : data = 30;
	139 : data = 32;

	140 : data = 110;
	141 : data = 40;
	142 : data = 85;
	143 : data = 0;
	144 : data = 32;
	145 : data = 194;
	146 : data = 49;
	147 : data = 0;
	148 : data = 0;
	149 : data = 30;
	
	150 : data = 140;
	151 : data = 0;
	152 : data = 160;
	153 : data = 20;
	154 : data = 81;
	155 : data = 240;
	156 : data = 22;
	157 : data = 0;
	158 : data = 38;
	159 : data = 124;
	
	160 : data = 67;
	161 : data = 0;
	162 : data = 88;
	163 : data = 194;
	164 : data = 33;
	165 : data = 0;
	166 : data = 0;
	167 : data = 152;
	168 : data = 0;
	169 : data = 0;
	
	170 : data = 0;
	171 : data = 1;
	172 : data = 0;
	173 : data = 82;
	174 : data = 69;
	175 : data = 86;
	176 : data = 49;
	177 : data = 46;
	178 : data = 48;
	179 : data = 48;
	
	180 : data = 10;
	181 : data = 0;
	182 : data = 0;
	183 : data = 0;
	184 : data = 0;
	185 : data = 0;
	186 : data = 0;
	187 : data = 0;
	188 : data = 0;
	189 : data = 255;
	
	190 : data = 0;
	191 : data = 57;
	192 : data = 57;
	193 : data = 70;
	194 : data = 67;
	195 : data = 53;
	196 : data = 48;
	197 : data = 48;
	198 : data = 48;
	199 : data = 49;
	
	200 : data = 10;
	201 : data = 32;
	202 : data = 32;
	203 : data = 32;
	
	255 : data = 132;	
	
	default : data = 8'h00; // total is 143 at the moment
	
  endcase
end

endmodule
