`default_nettype none
module uarttx ( input clk , input rstn , input txt , input txs , input [7:0] txd , output reg tx , output wire txr);
    localparam IDL = 2'd0, GO = 2'd1 , DAT = 2'd2 , STOP = 2'd3; 
    reg [1:0] s;
    reg [7:0] sr;
    reg [2:0] c;

    always @(posedge clk) begin
        if (~rstn) begin
            s <= IDL;
            sr <= 8'b0;
            c <= 3'd0;
            tx <= 1'b1;
        end
        else begin
            case (s)
                IDL : begin
                    tx <= 1'b1;
                    if (txs) begin
                        sr <= txd;
                        c <= 3'd0;
                        s <= GO;
                    end
                    else s <= IDL;
                end
                GO : begin
                    tx <= 1'b0;
                    if (txt) s <= DAT;
                    else s <= GO;
                end
                DAT : begin
                    tx <= sr[0];
                    if (txt) begin
                        sr <= {1'b0 , sr[7:1]};
                        if (c == 3'd7) s <= STOP;
                        else begin
                            s <= DAT;
                            c <= c + 3'd1;
                        end
                    end
                    else s <= DAT;
                end
                STOP : begin
                    tx <= 1'b1;
                    if (txt) s <= IDL;
                    else s <= STOP;
                end
            endcase
        end
    end
    assign txr = (s == IDL && ~txs);
endmodule
`default_nettype wire
