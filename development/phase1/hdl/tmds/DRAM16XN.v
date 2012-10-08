//
// Module: 	DRAM16XN
//
// Description: Distributed SelectRAM example
//		Dual Port 16 x N-bit
//
// Device: 	Spartan-3 Family
//---------------------------------------------------------------------------------------

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
//
//////////////////////////////////////////////////////////////////////////////

module DRAM16XN #(parameter data_width = 20)
                 (
                  DATA_IN,
                  ADDRESS,
                  ADDRESS_DP,
                  WRITE_EN,
                  CLK,
                  O_DATA_OUT,
                  O_DATA_OUT_DP);

input [data_width-1:0]DATA_IN;
input [3:0] ADDRESS;
input [3:0] ADDRESS_DP;
input WRITE_EN;
input CLK;

output [data_width-1:0]O_DATA_OUT_DP;
output [data_width-1:0]O_DATA_OUT;

genvar i;
generate
  for(i = 0 ; i < data_width ; i = i + 1) begin : dram16s
    RAM16X1D i_RAM16X1D_U(  
      .D(DATA_IN[i]),        //insert input signal
      .WE(WRITE_EN),         //insert Write Enable signal
      .WCLK(CLK),            //insert Write Clock signal
      .A0(ADDRESS[0]),       //insert Address 0 signal port SPO
      .A1(ADDRESS[1]),       //insert Address 1 signal port SPO
      .A2(ADDRESS[2]),       //insert Address 2 signal port SPO
      .A3(ADDRESS[3]),       //insert Address 3 signal port SPO
      .DPRA0(ADDRESS_DP[0]), //insert Address 0 signal dual port DPO
      .DPRA1(ADDRESS_DP[1]), //insert Address 1 signal dual port DPO
      .DPRA2(ADDRESS_DP[2]), //insert Address 2 signal dual port DPO
      .DPRA3(ADDRESS_DP[3]), //insert Address 3 signal dual port DPO
      .SPO(O_DATA_OUT[i]),   //insert output signal SPO
      .DPO(O_DATA_OUT_DP[i]) //insert output signal DPO
    );
  end
endgenerate

endmodule

