module uart_rx
   #(
     parameter DBIT = 8,     // No of data bits
               SB_tck = 16  // No of tcks for stop bits
   )
   (
    input wire clk, reset,
    input wire rx, s_tck,
    output reg rx_done_tck,
    output wire [7:0] dout
   );

   
   localparam [1:0] init_state  = 2'b00,start = 2'b01,data  = 2'b10,stop  = 2'b11;

   
   reg [1:0] state, state_next;
   reg [3:0] s, s_next;
   reg [2:0] n, n_next;
   reg [7:0] b, b_next;

  
   always @(posedge clk)
      if (reset)
         begin
            state <= init_state;
            s <= 0;
            n <= 0;
            b <= 0;
         end
      else
         begin
            state <= state_next;
            s <= s_next;
            n <= n_next;
            b <= b_next;
         end

  
   always @*
   begin
      
      s_next = s;
      n_next = n;
      b_next = b;
      state_next = state;
      rx_done_tck = 1'b0;
      if(state==init_state)
         begin
            if (~rx)
               begin
		  s_next = 0;
                  state_next = start;
               end
         end
      else if(state==start)
         begin
            if (s_tck)
               if (s==7)
                  begin
                     state_next = data;
                     s_next = 0;
                     n_next = 0;
                  end
               else
                  s_next = s + 1;
         end
      else if(state==data)
         begin
            if (s_tck)
               if (s==15)
                  begin
                     s_next = 0;
                     b_next = {rx, b[7:1]};
                     if (n==(DBIT-1))
                        state_next = stop ;
                      else
                        n_next = n + 1;
                   end
               else
                  s_next = s + 1;
         end
       else if(state==stop)
         begin
            if (s_tck)
               if (s==(SB_tck-1))
                  begin
                     state_next = init_state;
                     rx_done_tck =1'b1;
                  end
               else
                  s_next = s + 1;
         end
   end
   
   assign dout = b;

endmodule
