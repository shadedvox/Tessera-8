`timescale 1ns/1ps
module cpu_tb;
    reg clk = 0;
    reg rstn = 0;
    wire [15:0] addr;
    wire rdr, wdr, halt;
    wire [7:0] wd;
    reg [7:0] rd;

    cpu dut ( .clk(clk) , .rstn(rstn) , .rstvec(16'h0000) , .rd(rd) , .addr(addr) , .rdr(rdr) , .wdr(wdr) , .wd(wd) , .halt(halt));
    always #5 clk = ~clk;
    reg [7:0] mem [0:65535];
    always @(posedge clk) begin
        if (wdr) mem[addr] <= wd;
        if (rdr) rd <= mem[addr];
    end

    reg [255*8:1] fname;
    integer i, timeout;
    
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, cpu_tb);

        for (i = 0; i < 65536; i = i + 1) mem[i] = 8'h00;

        if (!$value$plusargs("prog=%s", fname)) begin
            $display("usage: vvp cpu.vvp +prog=test/prog1.hex");
            $finish;
        end

        $readmemh(fname, mem);

        rstn = 0;
        repeat (4) @(posedge clk);
        #1 rstn = 1;

        timeout = 0;
        while (!halt && timeout < 3000) begin
            @(posedge clk);
            timeout = timeout + 1;
        end
        if (!halt) $display("TIMEOUT: the CPU never halted");

        $display("A=%h B=%h H=%h L=%h  SP=%h PC=%h  Z=%b C=%b N=%b V=%b", dut.ra, dut.rb, dut.rh, dut.rl, dut.sp, dut.pc, dut.fz, dut.fc, dut.fn, dut.fv);
        $display("mem[0100]=%h mem[0101]=%h mem[01FE]=%h mem[01FF]=%h", mem[16'h0100], mem[16'h0101], mem[16'h01FE], mem[16'h01FF]);
        $finish;
    end
endmodule
