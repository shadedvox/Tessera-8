`default_nettype none
module mul8 (input clk, input rstn, input [7:0] a, input [7:0] b, input cmd, output reg [15:0] result, output wire busy);
    reg [7:0] as;
    wire [8:0] sum;
    reg s, ns;
    reg [2:0] st;
    always @(posedge clk) begin
        if (~rstn) begin
            as <= 8'd0;
            result <= 16'd0;
            st <= 3'd0;
            s <= 1'd0;
        end
        else begin
            as <= cmd & s==1'b0 ? a : as;
            result <= s==1'b0 ? (cmd ? {{8{1'b0}} , b} : result) : {sum, result[7:1]};
            s <= ns;
            st <= s==1'b1 ? st + 3'd1 : 3'b0;
        end
    end

    always @(*) begin
        case (s)
            1'b0 : ns = cmd ? 1'b1 : 1'b0;
            1'b1 : ns = st==3'd7 ? 1'b0 : 1'b1;
            default : ns = 1'b0;
        endcase
    end
    assign sum = result[0] ? result[15:8] + as : {1'b0 , result[15:8]};
    assign busy = s==1'b1;
endmodule
`default_nettype wire
