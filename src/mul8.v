`default_nettype none
module mul8 (input clk, input rstn, input [7:0] a, input [7:0] b, input cmd, output reg [15:0] result, output wire busy);
    reg [7:0] as;
    wire [8:0] sum;
    reg s, ns;
    reg [2:0] st;
    always @(posedge clk) begin
        if (~rstn) begin
            as <= 0;
            result <= 0;
            st <= 0;
            s <= 0;
        end
        else begin
            as <= cmd & s==0 ? a : as;
            result <= s==0 ? (cmd ? {{8{1'b0}} , b} : result) : {sum, result[7:1]};
            s <= ns;
            st <= s==1 ? st + 1 : 0;
        end
    end

    always @(*) begin
        case (s)
            0 : ns = cmd ? 1 : 0;
            1 : ns = st==3'd7 ? 0 : 1;
            default : ns = 0;
        endcase
    end
    assign sum = result[0] ? result[15:8] + as : {1'b0,result[15:8]};
    assign busy = s==1;
endmodule
`default_nettype wire
