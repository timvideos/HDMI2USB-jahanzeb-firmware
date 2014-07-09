module uart
   #(
      parameter Data_Bits = 8,     
                StopBits_tick = 16, 
                DIVISOR = 326,    // divider circuit = 50M/(16*baud rate)
                DVSR_BIT = 9, // # bits of divider circuit
                FIFO_Add_Bit = 2
   )
   (
    input wire clk, reset,
    input wire rd_uart, wr_uart, rx,
    input wire [7:0] w_data,
    output wire tx_empty, rx_empty, tx,
    output wire [7:0] r_data
   );


   wire tck, rx_done_tck, tx_done_tck;
   wire tx_full, tx_fifo_not_empty;
   wire [7:0] tx_fifo_out, rx_data_out;
	
	

	assign clkout=clk;
   
   //body
   	counter #(.M(DIVISOR), .N(DVSR_BIT)) baud_gen_unit
      (.clk(clkout), .reset(reset), .q(), .max_tck(tck));

   uart_rx #(.DBIT(Data_Bits), .SB_tck(StopBits_tick)) uart_rx_unit
      (.clk(clkout), .reset(reset), .rx(rx), .s_tck(tck),
       .rx_done_tck(rx_done_tck), .dout(rx_data_out));

   fifo #(.B(Data_Bits), .W(FIFO_Add_Bit )) fifo_rx_unit
      (.clk(clkout), .reset(reset), .rd(rd_uart),
       .wr(rx_done_tck), .w_data(rx_data_out),
       .empty(rx_empty), .full(), .r_data(r_data));

   fifo #(.B(Data_Bits), .W(FIFO_Add_Bit )) fifo_tx_unit
      (.clk(clkout), .reset(reset), .rd(tx_done_tck),
       .wr(wr_uart), .w_data(w_data), .empty(tx_empty),
       .full(tx_full), .r_data(tx_fifo_out));

   uart_tx #(.DBIT(Data_Bits), .SB_tck(StopBits_tick)) uart_tx_unit
      (.clk(clkout), .reset(reset), .tx_start(tx_fifo_not_empty),
       .s_tck(tck), .din(tx_fifo_out),
       .tx_done_tck(tx_done_tck), .tx(tx));

   assign tx_fifo_not_empty = ~tx_empty;

endmodule
