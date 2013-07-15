

module hdmimatrix (
	input wire        rst_n,    //The pink reset button
	input wire [3:0]  RX0_TMDS,
	input wire [3:0]  RX0_TMDSB,
	input wire [3:0]  RX1_TMDS,
	input wire [3:0]  RX1_TMDSB,

	output wire [3:0] TX0_TMDS,
	output wire [3:0] TX0_TMDSB,
	output wire [3:0] TX1_TMDS,
	output wire [3:0] TX1_TMDSB,
	
	
	output wire rx0_de, rx1_de,

	output wire rx1_hsync, rx0_hsync,
	output wire rx1_vsync, rx0_vsync,
	output wire rx1_pclk,rx0_pclk,
	output wire rdy0, rdy1,
  
	output wire [23:0] rx0_rgb,rx1_rgb,
	input wire [23:0] tx_rgb,
	
  	input wire tx_de,
	input wire tx_hsync,
	input wire tx_vsync,
	input wire tx_pclk,
	
	input wire rst
   
  
);

  
  assign rdy0 = rx0_red_rdy | rx0_green_rdy | rx0_blue_rdy;
  assign rdy1 = rx1_red_rdy | rx1_green_rdy | rx1_blue_rdy;
  assign rx0_rgb = {rx0_blue , rx0_green, rx0_red};
  assign rx1_rgb = {rx1_blue , rx1_green, rx1_red};
  
  
    wire [7:0] rx1_blue, rx0_blue;
	wire [7:0] rx1_green, rx0_green;
	wire [7:0] rx1_red, rx0_red;
	
	wire [7:0] tx_blue;
	wire [7:0] tx_green;
	wire [7:0] tx_red;	
	
	assign tx_blue = tx_rgb[23:16];
	assign tx_green = tx_rgb[15:8];
	assign tx_red = tx_rgb[7:0];
  
  
  /////////////////////////
  //
  // Input Port 0
  //
  /////////////////////////
  wire rx0_pclkx2, rx0_pclkx10, rx0_pllclk0;
  wire rx0_plllckd;
  wire rx0_reset;
  wire rx0_serdesstrobe;
  wire rx0_psalgnerr;      // channel phase alignment error
  wire [29:0] rx0_sdata;
  wire rx0_blue_vld;
  wire rx0_green_vld;
  wire rx0_red_vld;
  wire rx0_blue_rdy;
  wire rx0_green_rdy;
  wire rx0_red_rdy;

  dvi_decoder dvi_rx0 (
    //These are input ports
    .tmdsclk_p   (RX0_TMDS[3]),
    .tmdsclk_n   (RX0_TMDSB[3]),
    .blue_p      (RX0_TMDS[0]),
    .green_p     (RX0_TMDS[1]),
    .red_p       (RX0_TMDS[2]),
    .blue_n      (RX0_TMDSB[0]),
    .green_n     (RX0_TMDSB[1]),
    .red_n       (RX0_TMDSB[2]),
    .exrst       (~rst_n),

    //These are output ports
    .reset       (rx0_reset),
    .pclk        (rx0_pclk),
    .pclkx2      (rx0_pclkx2),
    .pclkx10     (rx0_pclkx10),
    .pllclk0     (rx0_pllclk0), // PLL x10 output
    .pllclk1     (rx0_pllclk1), // PLL x1 output
    .pllclk2     (rx0_pllclk2), // PLL x2 output
    .pll_lckd    (rx0_plllckd),
    .tmdsclk     (rx0_tmdsclk),
    .serdesstrobe(rx0_serdesstrobe),
    .hsync       (rx0_hsync),
    .vsync       (rx0_vsync),
    .de          (rx0_de),

    .blue_vld    (rx0_blue_vld),
    .green_vld   (rx0_green_vld),
    .red_vld     (rx0_red_vld),
    .blue_rdy    (rx0_blue_rdy),
    .green_rdy   (rx0_green_rdy),
    .red_rdy     (rx0_red_rdy),

    .psalgnerr   (rx0_psalgnerr),

    .sdout       (rx0_sdata),
    .red         (rx0_red),
    .green       (rx0_green),
    .blue        (rx0_blue)); 

  /////////////////////////
  //
  // Input Port 1
  //
  /////////////////////////
  wire rx1_pclkx2, rx1_pclkx10, rx1_pllclk0;
  wire rx1_plllckd;
  wire rx1_reset;
  wire rx1_serdesstrobe;
  wire rx1_psalgnerr;      // channel phase alignment error
  wire [29:0] rx1_sdata;
  wire rx1_blue_vld;
  wire rx1_green_vld;
  wire rx1_red_vld;
  wire rx1_blue_rdy;
  wire rx1_green_rdy;
  wire rx1_red_rdy;

  dvi_decoder dvi_rx1 (
    //These are input ports
    .tmdsclk_p   (RX1_TMDS[3]),
    .tmdsclk_n   (RX1_TMDSB[3]),
    .blue_p      (RX1_TMDS[0]),
    .green_p     (RX1_TMDS[1]),
    .red_p       (RX1_TMDS[2]),
    .blue_n      (RX1_TMDSB[0]),
    .green_n     (RX1_TMDSB[1]),
    .red_n       (RX1_TMDSB[2]),
    .exrst       (~rst_n),

    //These are output ports
    .reset       (rx1_reset),
    .pclk        (rx1_pclk),
    .pclkx2      (rx1_pclkx2),
    .pclkx10     (rx1_pclkx10),
    .pllclk0     (rx1_pllclk0), // PLL x10 outptu
    .pllclk1     (rx1_pllclk1), // PLL x1 output
    .pllclk2     (rx1_pllclk2), // PLL x2 output
    .pll_lckd    (rx1_plllckd),
    .tmdsclk     (rx1_tmdsclk),
    .serdesstrobe(rx1_serdesstrobe),
    .hsync       (rx1_hsync),
    .vsync       (rx1_vsync),
    .de          (rx1_de),

    .blue_vld    (rx1_blue_vld),
    .green_vld   (rx1_green_vld),
    .red_vld     (rx1_red_vld),
    .blue_rdy    (rx1_blue_rdy),
    .green_rdy   (rx1_green_rdy),
    .red_rdy     (rx1_red_rdy),

    .psalgnerr   (rx1_psalgnerr),

    .sdout       (rx1_sdata),
    .red         (rx1_red),
    .green       (rx1_green),
    .blue        (rx1_blue)); 

  // TMDS output

  

  /////////////////
  //
  // Output 
  //
  /////////////////
  wire         tx_pclkx2;
  
//////////////////////////  
  wire         tx0_pclkx10;
  wire         tx0_serdesstrobe;
  wire 		   tx0_bufpll_lock;  
  wire         tx0_reset;
//////////////////////////  


//////////////////////////  
  wire         tx1_pclkx10;
  wire         tx1_serdesstrobe;
  wire 		   tx1_bufpll_lock;  
  wire         tx1_reset;
//////////////////////////  

  
  
  // wire [7:0]   tx_blue;
  // wire [7:0]   tx_green;
  // wire [7:0]   tx_red;
  // wire         tx_hsync;
  // wire         tx_vsync;
  wire         tx_pll_reset;
  
  
 
// tx_pclk
  // assign tx_de           = (HDMI_out_source) ? rx1_de    : rx0_de;
  // assign tx_blue         = (HDMI_out_source) ? rx1_blue  : rx0_blue;
  // assign tx_green        = (HDMI_out_source) ? rx1_green : rx0_green;
  // assign tx_red          = (HDMI_out_source) ? rx1_red   : rx0_red;
  // assign tx_hsync        = (HDMI_out_source) ? rx1_hsync : rx0_hsync;
  // assign tx_vsync        = (HDMI_out_source) ? rx1_vsync : rx0_vsync;
  // assign tx_pll_reset    = (HDMI_out_source) ? rx1_reset : rx0_reset;
  assign tx_pll_reset    = ~rst_n;
  
  
  

  //////////////////////////////////////////////////////////////////
  // Instantiate a dedicate PLL for output port
  //////////////////////////////////////////////////////////////////
  wire tx_clkfbout, tx_clkfbin, tx_plllckd;
  wire tx_pllclk0, tx_pllclk2;

  PLL_BASE # (
    .CLKIN_PERIOD(10),
    .CLKFBOUT_MULT(10), //set VCO to 10x of CLKIN
    .CLKOUT0_DIVIDE(1),
    .CLKOUT1_DIVIDE(10),
    .CLKOUT2_DIVIDE(5),
    .COMPENSATION("SOURCE_SYNCHRONOUS")
  ) PLL_OSERDES_0 (
    .CLKFBOUT(tx_clkfbout),
    .CLKOUT0(tx_pllclk0),
    .CLKOUT1(),
    .CLKOUT2(tx_pllclk2),
    .CLKOUT3(),
    .CLKOUT4(),
    .CLKOUT5(),
    .LOCKED(tx_plllckd),
    .CLKFBIN(tx_clkfbin),
    .CLKIN(tx_pclk),
    .RST(tx_pll_reset)
  );

  //
  // This BUFGMUX directly selects between two RX PLL pclk outputs
  // This way we have a matched skew between the RX pclk clocks and the TX pclk
  //
  // BUFGMUX tx_bufg_pclk (.S(HDMI_out_source), .I1(rx1_pllclk1), .I0(rx0_pllclk1), .O(tx_pclk));

  //
  // This BUFG is needed in order to deskew between PLL clkin and clkout
  // So the tx0 pclkx2 and pclkx10 will have the same phase as the pclk input
  //
  BUFG tx_clkfb_buf (.I(tx_clkfbout), .O(tx_clkfbin));

  //
  // regenerate pclkx2 for TX
  //
  BUFG tx_pclkx2_buf (.I(tx_pllclk2), .O(tx_pclkx2));

  //
  // regenerate pclkx10 for TX
  //

  BUFPLL #(.DIVIDE(5)) tx0_ioclk_buf (.PLLIN(tx_pllclk0), .GCLK(tx_pclkx2), .LOCKED(tx_plllckd),
           .IOCLK(tx0_pclkx10), .SERDESSTROBE(tx0_serdesstrobe), .LOCK(tx0_bufpll_lock));

  assign tx0_reset = ~tx0_bufpll_lock;

  dvi_encoder_top dvi_tx0 (
    .pclk        (tx_pclk),
    .pclkx2      (tx_pclkx2),
    .pclkx10     (tx0_pclkx10),
    .serdesstrobe(tx0_serdesstrobe),
    .rstin       (tx0_reset),
    .blue_din    (tx_blue),
    .green_din   (tx_green),
    .red_din     (tx_red),
    .hsync       (tx_hsync),
    .vsync       (tx_vsync),
    .de          (tx_de),
    .TMDS        (TX0_TMDS),
    .TMDSB       (TX0_TMDSB));



//////////////////////////////////////

  BUFPLL #(.DIVIDE(5)) tx1_ioclk_buf (.PLLIN(tx_pllclk0), .GCLK(tx_pclkx2), .LOCKED(tx_plllckd),
           .IOCLK(tx1_pclkx10), .SERDESSTROBE(tx1_serdesstrobe), .LOCK(tx1_bufpll_lock));

  assign tx1_reset = ~tx1_bufpll_lock;

  dvi_encoder_top dvi_tx1 (
    .pclk        (tx_pclk),
    .pclkx2      (tx_pclkx2),
    .pclkx10     (tx1_pclkx10),
    .serdesstrobe(tx1_serdesstrobe),
    .rstin       (tx1_reset),
    .blue_din    (tx_blue),
    .green_din   (tx_green),
    .red_din     (tx_red),
    .hsync       (tx_hsync),
    .vsync       (tx_vsync),
    .de          (tx_de),
    .TMDS        (TX1_TMDS),
    .TMDSB       (TX1_TMDSB));
	
	
endmodule
