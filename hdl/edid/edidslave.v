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
 EDID Slave for communication with PC. dvi_only signal will select which rom to send to pc depending on the monitor connected.
 if no monitor is connected only dvi rom is transmitted. 
*/

module edidslave (rst_n,clk,sda,scl,dvi_only);
input clk;
input rst_n;
input scl;
inout sda;
input dvi_only;


// edid rom -------------------------------------------------------------------------
reg [7:0] adr;
wire [7:0] data;
edidrom edid_rom(clk,adr,data);

// hdmi rom -------------------------------------------------------------------------
wire [7:0] data_hdmi;
hdmirom hdmi_rom(clk,adr,data_hdmi);


// i2c slave signals ----------------------------------------------------------------
wire sdain;
reg sdaout;
assign sda = (sdaout == 1'b0) ? 1'b0 : 1'bz;
assign sdain = sda;



// state machine --------------------------------------------------------------------
parameter INI = 0;
parameter WAIT_FOR_START = 1;
parameter READ_ADDRESS = 2;
parameter SEND_ADDRESS_ACK = 3; // address A0
parameter READ_REGISTER_ADDRESS = 4;
parameter SEND_REGISTER_ADDRESS_ACK = 5;

parameter WAIT_FOR_START_AGAIN = 6;
parameter READ_ADDRESS_AGAIN = 7;
parameter SEND_ADDRESS_ACK_AGAIN = 8; // Address A1

parameter WRITE_BYTE = 9;
parameter FREE_SDA = 10;
parameter WAIT_WRITE_BYTE_ACK = 11; // also check for end of transmition // repeate etc etc

parameter RELEASE_SEND_REGISTER_ADDRESS_ACK = 12; 
parameter RELESASE_ADDRESS_ACK = 13; 
parameter RELEASE_SEND_ADDRESS_ACK_AGAIN = 14; 

//---------------------------------------------------------------------------------------
reg [3:0] state;
wire scl_risingedge,scl_fallingedge, start, stop;
reg [2:0] bitcount;
reg [7:0] sdadata; //% address confirmations is not implemeted yet // need to think about it in future. // before sending ack check the address
reg [7:0] scl_debounce;
//reg [15:0] sda_debounce;
reg scl_stable;
reg sdain_q,scl_q;

//---------------------------------------------------------------------------------------
assign scl_risingedge = (scl_q ^ scl_stable) & scl_stable;
assign scl_fallingedge = (scl_q ^ scl_stable) & (~scl_stable);
assign start = (sdain^sdain_q) & (~sdain) & scl_stable & scl_q;
// assign stop = (sdain^sdain_q) & (sdain) & scl_stable & scl_q;
assign stop = 1'b0;


//---------------------------------------------------------------------------------------
always @(posedge clk) begin
	
	if (~rst_n) begin		
		scl_q <= 0;
		sdain_q <= 0;
		state <= INI;
		bitcount <=7;
		sdadata <=0;
		sdaout <= 1;	
		adr	<= 0;
		scl_stable <=0;
		scl_debounce <=0;

	end else begin // clk 
		
		scl_debounce <= {scl_debounce[6:0],scl};// shift reg		
		if (scl_debounce == 8'd0) begin
			scl_stable <=0;
		end else if (scl_debounce == 8'b11111111 ) begin
			scl_stable <= 1;
		end
		scl_q <= scl_stable;
		// scl_q <= scl;
		
		sdain_q <= sdain;
		
		if (stop) begin
			state <= INI;
		end 
		
		case (state)
			
			INI: begin //ini all signals //0
				state <= WAIT_FOR_START;
				scl_q <= 0;
				sdain_q <= 0;
				bitcount <=7;
				sdadata <=0;
				sdaout <= 1;	
				adr	<= 0;				
				scl_stable <=0;
			end
			
			WAIT_FOR_START: begin //1
				if (start) begin
					state <= READ_ADDRESS;
				end
			end
			
			READ_ADDRESS: begin //2
				if (scl_risingedge) begin
					bitcount <= bitcount -1;
					sdadata[bitcount] <= sdain;
					if (bitcount==0) begin
						state <= SEND_ADDRESS_ACK;
					end 
				end 
			end
			
			SEND_ADDRESS_ACK: begin//3
				if (scl_fallingedge) begin
					sdaout <= 0;
					state <= RELESASE_ADDRESS_ACK;
				end
			end
			
			RELESASE_ADDRESS_ACK: begin
				if (scl_fallingedge) begin
					sdaout <= 1;
					state <= READ_REGISTER_ADDRESS;
				end
			end
			
			READ_REGISTER_ADDRESS: begin//4
				if (scl_risingedge) begin
					bitcount <= bitcount -1;
					sdadata[bitcount] <= sdain;
					if (bitcount==0) begin
						state <= SEND_REGISTER_ADDRESS_ACK;
					end 
				end 
			end
			
			SEND_REGISTER_ADDRESS_ACK: begin//5
				if (scl_fallingedge) begin
					sdaout <= 0;
					state <= RELEASE_SEND_REGISTER_ADDRESS_ACK;
				end
			end

			RELEASE_SEND_REGISTER_ADDRESS_ACK: begin
				if (scl_fallingedge) begin
					sdaout <= 1;
					state <= WAIT_FOR_START_AGAIN;
				end
			end
				
			WAIT_FOR_START_AGAIN: begin//6
				if (start) begin
					state <= READ_ADDRESS_AGAIN;
				end 
			end
			
			READ_ADDRESS_AGAIN: begin//7
				if (scl_risingedge) begin
					bitcount <= bitcount -1;
					sdadata[bitcount] <= sdain;
					if (bitcount==0) begin
						state <= SEND_ADDRESS_ACK_AGAIN;
					end 
				end 		
			end
			
			SEND_ADDRESS_ACK_AGAIN: begin//8
				if (scl_fallingedge) begin
					sdaout <= 0;
					state <= WRITE_BYTE;
				end
			end
						
			WRITE_BYTE: begin//9
				if (scl_fallingedge) begin
					bitcount <= bitcount -1;
					if (dvi_only) begin
						sdaout <= data[bitcount];
					end else begin
						sdaout <= data_hdmi[bitcount];
					end
					if (bitcount==0) begin
						state <= FREE_SDA;
						adr <= adr +1;
						if ((adr ==  127) & dvi_only) begin
							state <= INI;
						end else if (adr == 255) begin
							state <= INI;
						end
						
					end 
				end				
			end
			
			FREE_SDA: begin//10
				if (scl_fallingedge) begin
					sdaout <= 1;
					state <= WAIT_WRITE_BYTE_ACK;
				end
			end
			
			WAIT_WRITE_BYTE_ACK: begin//11
				if (scl_risingedge) begin
					if (~sdain) begin
						state <= WRITE_BYTE;
					end else begin
						state <= INI;
					end
				end
			end
			
			default : begin
				state <= INI;
			end
				
		endcase		

	end
end


endmodule
