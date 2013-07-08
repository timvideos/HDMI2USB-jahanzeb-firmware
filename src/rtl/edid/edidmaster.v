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
 EDID master for reading edid structure from monitor.
 the output is in byte format in "sdadata" on the rising edge of out_en
*/

module edidmaster (rst_n,clk,sda,scl,stop_reading,address_w,start,address_r,reg0,sdadata,out_en);
input clk;
input stop_reading;
input rst_n;
output reg scl;
inout sda;
input start;
input [7:0] address_w;
input [7:0] address_r;
input [7:0] reg0;
output reg [7:0] sdadata;
output reg out_en;

wire sdain;
reg sdaout;
assign sda = (sdaout == 1'b0) ? 1'b0 : 1'bz;
assign sdain = sda;

//% state machine states
parameter INI = 0;
parameter WAIT_FOR_START = 1;
parameter GEN_START = 2;
parameter WRITE_BYTE_ADD_W = 3;
parameter FREE_SDA_ADD_W = 4;
parameter WAIT_WRITE_BYTE_ACK_ADD = 5;
parameter WRITE_BYTE_REG = 6;
parameter FREE_SDA_REG = 7;
parameter WAIT_WRITE_BYTE_ACK_REG = 8;
parameter WRITE_BYTE_ADD_R = 9;
parameter FREE_SDA_ADD_R = 10;
parameter WAIT_WRITE_BYTE_ACK_ADD_R = 11;
parameter READ_DATA = 12;
parameter SEND_READ_ACK = 13;
parameter RELESASE_ACK = 14;
parameter GEN_START2 = 15;
parameter SKIP1 = 16;

reg [4:0] state;
reg [8:0] scl_counter;
reg scl_q,middle_scl;
reg [2:0] bitcount;

assign scl_risingedge = (scl_q ^ scl) & scl;
assign scl_fallingedge = (scl_q ^ scl) & (~scl);

always @(posedge clk) begin
	
	if (~rst_n) begin		
		scl_counter <=0;
		scl <= 0;
		middle_scl <= 0;
		scl_q <= 0;
		state <= INI;
		bitcount <= 7;
		sdadata <=0;
		sdaout <= 1;			
		out_en <=0;
	end else begin // clk 
	
	out_en <=0;
	scl_counter <= scl_counter +1;
	
	if (scl_counter == 499) begin
		scl <= ~ scl;
		scl_counter <= 0;
	end
	
	scl_q <= scl;
	
	middle_scl <= 0;
	if ((scl_counter == 256) & scl) begin
		middle_scl <= 1;
	end
	
	case (state)
			
			INI: begin //ini all signals //0
				state <= WAIT_FOR_START;
				scl_q <= 0;
				bitcount <=7;
				sdadata <=0;
				sdaout <= 1;	
			end
			
			WAIT_FOR_START: begin //1
				if (start) begin
					state <= GEN_START;
				end
			end
			
			GEN_START : begin //2
				if (middle_scl) begin
					sdaout <= 0;
					scl_counter <= 0;
					state <= WRITE_BYTE_ADD_W;
				end
			end

			WRITE_BYTE_ADD_W: begin//3
				if (scl_fallingedge) begin
					bitcount <= bitcount -1;
					sdaout <= address_w[bitcount];
					if (bitcount==0) begin
						state <= FREE_SDA_ADD_W;
					end 

				end				
			end
			
			FREE_SDA_ADD_W: begin//4
				if (scl_fallingedge) begin
					sdaout <= 1;
					state <= WAIT_WRITE_BYTE_ACK_ADD;
				end
			end
			
			WAIT_WRITE_BYTE_ACK_ADD: begin//5
				if (scl_risingedge) begin
					if (~sdain) begin
						state <= WRITE_BYTE_REG;
					end else begin
						state <= INI;
					end
				end
			end

			WRITE_BYTE_REG: begin//6
				if (scl_fallingedge) begin
					bitcount <= bitcount -1;
					sdaout <= reg0[bitcount];
					if (bitcount==0) begin
						state <= FREE_SDA_REG;
					end 

				end				
			end
			
			FREE_SDA_REG: begin//7
				if (scl_fallingedge) begin
					sdaout <= 1;
					state <= WAIT_WRITE_BYTE_ACK_REG;
				end
			end
			
			WAIT_WRITE_BYTE_ACK_REG: begin//8
				if (scl_risingedge) begin
					if (~sdain) begin
						state <= SKIP1;
					end else begin
						state <= INI;
					end
				end
			end

			SKIP1 : begin
				if (scl_risingedge) begin
					state <= GEN_START2;
				end
			end
			
			GEN_START2 : begin //15
				if (middle_scl) begin
					sdaout <= 0;
					scl_counter <= 0;
					state <= WRITE_BYTE_ADD_R;
				end
			end						

			WRITE_BYTE_ADD_R: begin//9
				if (scl_fallingedge) begin
					bitcount <= bitcount -1;
					sdaout <= address_r[bitcount];
					if (bitcount==0) begin
						state <= FREE_SDA_ADD_R;
					end 

				end				
			end
			
			FREE_SDA_ADD_R: begin//10
				if (scl_fallingedge) begin
					sdaout <= 1;
					state <= WAIT_WRITE_BYTE_ACK_ADD_R;
				end
			end
			
			WAIT_WRITE_BYTE_ACK_ADD_R: begin//11
				if (scl_risingedge) begin
					if (~sdain) begin
						state <= READ_DATA;
					end else begin
						state <= INI;
					end
				end
			end
	
			READ_DATA: begin //12
				if (scl_risingedge) begin
					bitcount <= bitcount -1;
					sdadata[bitcount] <= sdain;
					if (bitcount==0) begin
						out_en <= 1;
						state <= SEND_READ_ACK;
					end 
				end 
			end
			
			SEND_READ_ACK: begin//13
				if (scl_fallingedge) begin
					if (stop_reading) begin
						state <= INI;
						sdaout <= 1; // negeative ack
					end else begin
						sdaout <= 0;
						state <= RELESASE_ACK;
					end
				end
			end
			
			RELESASE_ACK: begin//14
				if (scl_fallingedge) begin
					sdaout <= 1;
					state <= READ_DATA;
				end
			end

			default : begin
				state <= INI;
			end
				
		endcase		
	end
end


endmodule
