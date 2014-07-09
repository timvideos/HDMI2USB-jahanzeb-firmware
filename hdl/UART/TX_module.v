module uart_tx
   #(
     parameter DBIT = 8,     // # data bits
               SB_tck = 16  // # tcks for stop bits
   )
   (
    input wire clk, reset,
    input wire tx_start, s_tck,
    input wire [7:0] din,
    output reg tx_done_tck,
    output wire tx
   );

   
   localparam [1:0]init_state  = 2'b00,start = 2'b01,data  = 2'b10,stop  = 2'b11;

   
   reg [1:0] state, state_next;
   reg [3:0] s, s_next;
   reg [2:0] n, n_next;
   reg [7:0] b, b_next;
   reg tx_reg, tx_next;

   
   always @(posedge clk)
      if (reset)
         begin
            state <= init_state;
            s <= 0;
            n <= 0;
            b <= 0;
            tx_reg <= 1'b1;
         end
      else
         begin
            state <= state_next;
            s <= s_next;
            n <= n_next;
            b <= b_next;
            tx_reg <= tx_next;
         end

  
   always @*
   begin
      state_next = state;
      tx_done_tck = 1'b0;
      s_next = s;
      n_next = n;
      b_next = b;
      tx_next = tx_reg ;
      if(state==init_state)
            begin
               tx_next = 1'b1;
               if (tx_start)
                  begin
                     state_next = start;
                     s_next = 0;
                     b_next = din;
                  end
            end
        else if(state==start)
            begin
               tx_next = 1'b0;
               if (s_tck)
                  if (s==15)
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
               tx_next = b[0];
               if (s_tck)
                  if (s==15)
                     begin
                        s_next = 0;
                        b_next = b >> 1;
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
               tx_next = 1'b1;
               if (s_tck)
                  if (s==(SB_tck-1))
                     begin
                        state_next = init_state;
                        tx_done_tck = 1'b1;
                     end
                  else
                     s_next = s + 1;
            end
   end

   assign tx = tx_reg;

endmodule
