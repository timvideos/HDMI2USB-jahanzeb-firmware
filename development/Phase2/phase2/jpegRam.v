module jpegRam(raddr, clk, q);
output [7:0] q;
input[15:0] raddr;
input clk;


reg [15:0] read_addr;
reg[7:0] mem [65535:0] /* synthesis syn_ramstyle="block_ram" */;

initial $readmemh("D:\\Dropbox\\vWorker\\phase2\\matlab\\img.hex", mem);
 
assign q = mem[read_addr];

always @(posedge clk) begin

read_addr <= raddr;
end 

endmodule
