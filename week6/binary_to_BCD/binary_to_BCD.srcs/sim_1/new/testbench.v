`timescale 1ns / 1ps

module testbench;

reg clk;
reg rst;
reg [3:0] bin;
wire [7:0] bcd;

bianry_to_BCD uut (
    .clk(clk),
    .rst(rst),
    .bin(bin),
    .bcd(bcd)
);

always begin
    #5 clk = ~clk;
end

initial begin
    clk = 0;
    rst = 0;
    bin = 0;

    #10 rst = 1;
    
    for (bin = 0; bin <= 15; bin = bin + 1) begin
        #30;
    end
end

endmodule