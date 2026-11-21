`timescale 1ns / 1ps
module div_tb;
    reg        clk = 0;
    reg        rstn;
    reg        cmd;
    reg  [7:0] a, b;
    wire [7:0] r;
    wire [7:0] q;
    wire       busy;

    div8 dut (.clk(clk), .rstn(rstn), .a(a), .b(b), .cmd(cmd),
             .q(q), .r(r), .busy(busy));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, div_tb);

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

        $display("255 / 255 = q : %0d, d : %0d", q,r);

        @(posedge clk); #1;
        a = 236; b = 0; cmd = 1;
        @(posedge clk); #1;
        cmd = 0;

        while (busy) begin
            @(posedge clk); #1;
        end

        $display("236 / 0 =  q : %0d, d : %0d", q,r);
        $finish;
    end
endmodule