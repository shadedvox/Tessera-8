`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);
    // ui_in[7] = write enable, ui_in[6:0] = address, uio_in = write data
    wire [7:0] sram_q;
    wire       we   = ui_in[7];
    wire [8:0] addr = {2'b00, ui_in[6:0]};

    assign uio_out = 8'h00;
    assign uio_oe  = 8'h00;
    assign uo_out  = sram_q;

`ifdef SYNTH
    reg [7:0] fpga_mem [0:127];
    reg [7:0] fpga_q;
    always @(posedge clk) begin
        if (ena && rst_n) begin
            if (we) fpga_mem[ui_in[6:0]] <= uio_in;
            else    fpga_q <= fpga_mem[ui_in[6:0]];
        end
    end
    assign sram_q = fpga_q;

`elsif __pnr__
    wire VPWR;
    wire VGND;
    gf180mcu_fd_ip_sram__sram512x8m8wm1 u_sram (
        .VDD(VPWR), .VSS(VGND), .CLK(clk),
        .CEN(~(ena & rst_n)), .GWEN(~we), .WEN(8'h00),
        .A(addr), .D(uio_in), .Q(sram_q)
    );

`else
    wire model_vdd = 1'b1;
    wire model_vss = 1'b0;
    gf180mcu_fd_ip_sram__sram512x8m8wm1 u_sram (
        .CLK(clk), .CEN(~(ena & rst_n)), .GWEN(~we), .WEN(8'h00),
        .A(addr), .D(uio_in), .Q(sram_q),
        .VDD(model_vdd), .VSS(model_vss)
    );
`endif

endmodule
`default_nettype wire
