`default_nettype none
module baud ( input clk , input rstn , input [1:0] bsel , output reg rx16 , output reg tx1 );
    reg [8:0] lim;
    reg [8:0] osc;
    reg [3:0] txc;
    
    always @(posedge clk) begin
        if (~rstn) begin
            osc <= 9'd0;
            txc <= 4'd0;
            rx16 <= 1'b0;
            tx1 <= 1'b0;
        end
        else begin
            if (osc >= lim) begin
                if (txc == 4'd15) begin
                    tx1 <= 1'b1;
                    txc <= 4'd0;
                end
                else begin
                    tx1 <= 1'b0;
                    txc <= txc + 4'd1;
                end
                rx16 <= 1'b1;
                osc <= 9'd0;
            end
            else begin
                osc <= osc + 9'd1;
                rx16 <= 1'b0;
                tx1 <= 1'b0;
            end
        end
    end
    always @(*) begin
        case (bsel)
            2'd0 : lim = 9'd26;
            2'd1 : lim = 9'd53;
            2'd2 : lim = 9'd80;
            2'd3 : lim = 9'd325;
        endcase
    end
endmodule
`default_nettype wire
