`default_nettype none
module sramw ( input clk , input ena , input we , input wire [8:0] addr , input wire [7:0] wd , output wire [7:0] rd);
    wire [7:0] sram_q;
    assign rd = sram_q;

`ifdef SYNTH
    reg [7:0] fpga_mem [0:511];
    reg [7:0] fpga_q;
    always @(posedge clk) begin
        if (ena) begin
            if (we) fpga_mem[addr] <= wd;
            else    fpga_q <= fpga_mem[addr];
        end
    end
    assign sram_q = fpga_q;

`elsif __pnr__
    wire VPWR;
    wire VGND;
    gf180mcu_fd_ip_sram__sram512x8m8wm1 u_sram (
        .VDD(VPWR), .VSS(VGND), .CLK(clk),
        .CEN(~(ena)), .GWEN(~we), .WEN(8'h00),
        .A(addr), .D(wd), .Q(sram_q)
    );

`else
    wire model_vdd = 1'b1;
    wire model_vss = 1'b0;
    gf180mcu_fd_ip_sram__sram512x8m8wm1 u_sram (
        .CLK(clk), .CEN(~(ena)), .GWEN(~we), .WEN(8'h00),
        .A(addr), .D(wd), .Q(sram_q),
        .VDD(model_vdd), .VSS(model_vss)
    );
`endif
endmodule
`default_nettype wire
