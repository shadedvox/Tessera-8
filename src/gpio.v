`default_nettype none
module gpio (input clk , input rstn , input we , input [3:0] addr , input [7:0] wd , input [7:0] inp , output reg [7:0] rd , output reg [7:0] otp);
    reg [15:0] cyc;

    always @(posedge clk) begin
        if (~rstn) begin
            cyc <= 16'd0;
            otp <= 8'b0;
        end
        else begin
            cyc <= cyc + 16'd1;
            if (we & addr == 4'h2) begin
                otp <= wd;
            end
        end
    end
    always @(*) begin
        case (addr)
            4'h2 : rd = otp;
            4'h3 : rd = inp;
            4'h4 : rd = cyc[7:0];
            4'h5 : rd = cyc[15:8];
            default : rd = 8'b0;
        endcase
    end
endmodule
`default_nettype wire
