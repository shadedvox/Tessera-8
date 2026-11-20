`timescale 1ns / 1ps
module mul_tb;
    reg        clk = 0;
    reg        rstn;
    reg        cmd;
    reg  [7:0] a, b;
    wire [15:0] result;
    wire       busy;

    mul8 dut (.clk(clk), .rstn(rstn), .a(a), .b(b), .cmd(cmd),
             .result(result), .busy(busy));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, mul_tb);

        rstn = 0; cmd = 0; a = 0; b = 0;
        repeat (3) @(posedge clk);
        #1 rstn = 1;

        @(posedge clk); #1;
        a = 255; b = 255; cmd = 1;
        @(posedge clk); #1;
        cmd = 0;

        while (busy) begin
            @(posedge clk); #1;
        end

        $display("255 x 255 = %0d", result);

        @(posedge clk); #1;
        a = 232; b = 142; cmd = 1;
        @(posedge clk); #1;
        cmd = 0;

        while (busy) begin
            @(posedge clk); #1;
        end

        $display("232 x 142 = %0d", result);
        $finish;
    end
endmodule