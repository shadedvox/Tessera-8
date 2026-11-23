`default_nettype none

module tt_um_Tessera8 (
    input  wire [7:0] ui_in,
    input  wire [7:0] uio_in,
    output wire [7:0] uo_out,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    wire [15:0] cpu_addr;
    wire [7:0]  cpu_wd;
    wire [7:0]  cpu_rd;
    wire        cpu_rdr;
    wire        cpu_wdr;
    wire        cpu_halt;
    // ui_in[7] = write enable, ui_in[6:0] = address, uio_in = write data
    assign uo_out  = {7'b0, cpu_halt};
    assign uio_out = 8'h00;
    assign uio_oe  = 8'h00;

    sramw sr( .clk(clk) , .ena(cpu_rdr | cpu_wdr) , .we(cpu_wdr) , .addr(cpu_addr[8:0]) , .wd(cpu_wd) , .rd(cpu_rd) );
    cpu ucpu( .clk(clk) , .rstn(rst_n) , .rstvec(16'h0000) , .rd(cpu_rd) , .addr(cpu_addr) , .rdr(cpu_rdr) , .wdr(cpu_wdr) , .wd(cpu_wd) , .halt(cpu_halt) );

    wire _unused = &{ena, ui_in, uio_in, cpu_addr[15:9], 1'b0};
endmodule

`default_nettype wire
