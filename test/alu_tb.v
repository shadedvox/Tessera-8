`timescale 1ns / 1ps
module alu_tb;
    reg [7:0] a, b;
    reg cin;
    reg [3:0] op;
    wire [7:0] result;
    wire z, n, c, v;

    alu dut (.a(a), .b(b), .cin(cin), .op(op), .result(result), .z(z), .c(c), .v(v), .n(n));

    reg [15:0] op_a, op_b;
    reg [7:0] res_lo;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, alu_tb);
        a = 0; b = 0; cin = 0; op = 0;
        #1;

        op_a = 16'd30291;
        op_b = 16'd40228;

        a = op_a[7:0]; b = op_b[7:0]; cin = 1'b0; op = 4'd0;  #1;
        res_lo = result;
        a = op_a[15:8]; b = op_b[15:8]; cin = c; op = 4'd12; #1;
        $display("%d + %d = %d (c=%b, v=%b, n=%b, z=%b)", op_a, op_b, {result, res_lo}, c, v, n, z);
        #5;

        op_a = 16'd2290;
        op_b = 16'd5032;

        a = op_a[7:0];  b = op_b[7:0];  cin = 1'b0; op = 4'd1;  #1;
        res_lo = result;
        a = op_a[15:8]; b = op_b[15:8]; cin = c;    op = 4'd13; #1;
        $display("%d - %d = %d (c=%b, v=%b, n=%b, z=%b)", op_a, op_b, {result, res_lo}, c, v, n, z);
        #5;
        a = 8'd200; b = 8'd100; cin = 0; op = 4'd0; #1; $display("%d + %d = %d, z=%b, n=%b, c=%b, v=%b", a, b, result, z, n, c, v);
        #5;
        a = 8'd5; b = 8'd3; cin = 0; op = 4'd1; #1; $display("%d - %d = %d, z=%b, n=%b, c=%b, v=%b", a, b, result, z, n, c, v);
        #5;
        a = 8'd6; b = 8'd3; op = 4'd2; #1; $display("%d & %d = %d, z=%b, n=%b, c=%b, v=%b", a, b, result, z, n, c, v);
        #5;
        a = 8'd212; b = 8'd3; op = 4'd9; #1; $display("-%d= %d, z=%b, n=%b, c=%b, v=%b", a, result, z, n, c, v);
        #5;
        a = 8'd5; b = 8'd3; op = 4'd11; #1; $display("dec %d= %d, z=%b, n=%b, c=%b, v=%b", a, result, z, n, c, v);
        #5;
        a = 8'd3; b = 8'd3; cin = 1; op = 4'd13; #1; $display("%d - %d -%d = %d, z=%b, n=%b, c=%b, v=%b", a, b, cin, result, z, n, c, v);

        $finish;
    end
endmodule