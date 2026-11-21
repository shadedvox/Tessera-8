`timescale 1ns / 1ps
module sram_wrap_tb;
    reg         clk = 0;
    reg         en, we;
    reg  [8:0]  addr;
    reg  [7:0]  wdata;
    wire [7:0]  rdata;

    sramw dut (.clk(clk), .ena(en), .we(we), .addr(addr),
                   .wd(wdata), .rd(rdata));

    always #50 clk = ~clk;
    integer i, errors;
    reg [7:0] got;

    function [7:0] pat(input integer ad);
        pat = (ad * 37 + 11 + (ad >> 8) * 101) & 255;
    endfunction

    task write(input [8:0] ad, input [7:0] d);
        begin
            @(posedge clk); #1;
            en = 1; we = 1; addr = ad; wdata = d;
            @(posedge clk); #1;
            en = 0; we = 0;
        end
    endtask

    task read(input [8:0] ad, output [7:0] d);
        begin
            @(posedge clk); #1;
            en = 1; we = 0; addr = ad;
            @(posedge clk);
            @(negedge clk);
            d = rdata;
            @(posedge clk); #1;
            en = 0;
        end
    endtask

    task check(input [8:0] ad, input [7:0] expv);
        begin
            read(ad, got);
            if (got !== expv) begin
                errors = errors + 1;
                if (errors <= 10)
                    $display("FAIL addr %0d: got %h, expected %h", ad, got, expv);
            end
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, sram_wrap_tb);
        errors = 0; en = 0; we = 0; addr = 0; wdata = 0;
        repeat (3) @(posedge clk);

        for (i = 0; i < 512; i = i + 1) write(i[8:0], pat(i));
        for (i = 511; i >= 0; i = i - 1) check(i[8:0], pat(i));

        write(9'd300, 8'hA5);
        check(9'd300, 8'hA5);
        check(9'd299, pat(299));
        check(9'd301, pat(301));
        check(9'd44,  pat(44));

        @(posedge clk); #1;
        en = 1; we = 1; addr = 9'd7; wdata = 8'h3C;
        @(posedge clk); #1;
        en = 1; we = 0; addr = 9'd7;
        @(posedge clk);
        @(negedge clk);
        if (rdata !== 8'h3C) begin
            errors = errors + 1;
            $display("FAIL back-to-back: got %h, expected 3c", rdata);
        end

        if (errors == 0) $display("SRAM TEST PASSED");
        else             $display("SRAM TEST FAILED: %0d errors", errors);
        $finish;
    end
endmodule