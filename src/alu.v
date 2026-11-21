`default_nettype none
module alu (input [7:0] a, input [7:0] b, input cin, input [3:0] op, output reg [7:0] result, output wire z, output reg c, output reg v, output wire n);
    localparam ADD = 4'd0, SUB = 4'd1, AND = 4'd2, OR = 4'd3, XOR = 4'd4, NOT = 4'd5, SHL = 4'd6, SHR = 4'd7, SAR = 4'd8, NEG = 4'd9, INC = 4'd10, DEC = 4'd11, ADCI = 4'd12, SBCI = 4'd13;

    wire op_sub = (op == SUB | op == NEG | op == DEC | op == SBCI);
    reg [7:0] ada, adb;
    always @(*) begin
        ada = (op == NEG) ? 8'd0 : a;
        adb = (op == INC || op == DEC) ? 8'd1 : b;
    end

    wire [7:0] ad_x = (op == NEG) ? ~a : adb ^ {8{op_sub}};
    wire car = (op == ADCI) ? cin : (op == SBCI) ? ~cin : op_sub;
    wire [8:0] sum = {1'b0, ada} + {1'b0, ad_x} + {8'd0, car};
    wire adc = op_sub ? ~sum[8] : sum[8];
    wire adv = (ada[7] == ad_x[7]) && (sum[7] != ada[7]);

    always @(*) begin
        result = 8'd0;
        c = 1'b0;
        v = 1'b0;
        case (op)
            ADD,SUB,NEG,DEC,INC,ADCI,SBCI: begin
                result = sum[7:0];
                c = adc;
                v = adv;
            end
            AND : result = a & b;
            OR : result = a | b;
            XOR : result = a ^ b;
            NOT : result = ~a;
            SHL : begin
                result = {a[6:0], 1'b0};
                c = a[7];
            end
            SHR : begin
                result = {1'b0, a[7:1]};
                c = a[0];
            end
            SAR : begin
                result = {a[7], a[7:1]};
                c = a[0];
            end
            default : begin result = 8'd0; c = 0; v = 0; end
        endcase
    end

    assign z = (result == 8'd0);
    assign n = result[7];
endmodule
`default_nettype wire
//iverilog -g2012 -o test/sim_build/alu.vvp src/alu.v test/alu_tb.v && vvp test/sim_build/alu.vvp
