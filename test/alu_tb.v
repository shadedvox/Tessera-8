`timescale 1ns / 1ps
module alu_tb;
    reg [7:0] a, b;
    reg [3:0] op;
    wire [7:0] result;
    wire z, n, c, v;
    alu dut (.a(a), .b(b), .op(op), .result(result), .z(z), .c(c), .v(v), .n(n));

    //integer ia, ib, iop;
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, alu_tb);
        a = 0;
        b = 0;
        op = 0;
        #1
        a = 8'd200; b = 8'd100; op = 4'd0; #1; $display("%d + %d = %d, z=%b, n=%b, c=%b, v=%b", a, b, result, z, n, c, v);
        #5;
        a = 8'd5; b = 8'd3; op = 4'd1; #1; $display("%d - %d = %d, z=%b, n=%b, c=%b, v=%b", a, b, result, z, n, c, v);
        #5;
        a = 8'd6; b = 8'd3; op = 4'd2; #1; $display("%d & %d = %d, z=%b, n=%b, c=%b, v=%b", a, b, result, z, n, c, v);
        #5;
        a = 8'd212; b = 8'd3; op = 4'd9; #1; $display("-%d= %d, z=%b, n=%b, c=%b, v=%b", a, result, z, n, c, v);
        #5;
        a = 8'd5; b = 8'd3; op = 4'd11; #1; $display("dec %d= %d, z=%b, n=%b, c=%b, v=%b", a, result, z, n, c, v);
    end
endmodule

