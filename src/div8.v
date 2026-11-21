`default_nettype none
module div8 (input clk, input rstn, input [7:0] a, input [7:0] b, input cmd, output wire [7:0] q, output wire [7:0] r, output wire busy);
    reg [7:0] bs;
    reg [15:0] res;
    wire qb;
    wire [7:0] rem;
    reg s, ns;
    reg [2:0] st;
    always @(posedge clk) begin
        if (~rstn) begin
            bs <= 8'd0;
            st <= 3'd0;
            s <= 1'd0;
            res <= 16'd0;
        end
        else begin
            bs <= cmd & (s==1'b0) ? b : bs;
            res <= (s==1'b0) ? (cmd ? {{8{1'b0}} , a} : res) : {rem[7:0],res[6:0],qb};
            s <= ns;
            st <= s==1'b1 ? st + 3'd1 : 3'd0;
        end
    end

    always @(*) begin
        case (s)
            1'b0 : ns = cmd ? 1'b1 : 1'b0;
            1'b1 : ns = st==3'd7 ? 1'b0 : 1'b1;
            default : ns = 1'b0;
        endcase
    end
    assign rem = qb ? res[14:7] - bs : res[14:7];
    assign qb = res[15:7] >= {1'b0,bs};
    assign busy = s==1'b1;
    assign q = res[7:0];
    assign r = res[15:8];
endmodule
`default_nettype wire
