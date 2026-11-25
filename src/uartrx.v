`default_nettype none
module uartrx (input clk , input rstn , input rx16 , input rx , input rxack , output reg [7:0] rxd , output reg rxr);
    localparam IDL = 2'd0, GO = 2'd1 , DAT = 2'd2 , STOP = 2'd3; 
    reg [1:0] s;
    reg [7:0] sr;
    reg [3:0] oc;
    reg [2:0] bc;

    always @(posedge clk) begin
        if (~rstn) begin
            s <= IDL;
            sr <= 8'b0;
            bc <= 3'd0;
            oc <= 4'd0;
            rxd <= 8'b0;
            rxr <= 1'b0;
        end
        else begin
            if (rxack) rxr <= 1'b0;
            case (s)
                IDL : begin
                    if (rx==0) begin
                        oc <= 4'd0;
                        s <= GO;
                    end
                    else s <= IDL;
                end
                GO : begin
                    if (rx16) begin
                        if (oc == 4'd7) begin
                            if (~rx) begin
                                oc <= 4'd0;
                                bc <= 3'd0;
                                s <= DAT;
                            end
                            else s <= IDL;
                        end
                        else begin
                        oc <= oc + 4'd1;
                        s <= GO; 
                        end
                    end
                end
                DAT : begin
                    if (rx16) begin
                        if (oc == 4'd15) begin
                            sr <= {rx,sr[7:1]};
                            oc <= 4'd0;
                            if (bc == 3'd7) s <= STOP;
                            else bc <= bc + 3'd1;
                        end
                        else oc <= oc + 4'd1;
                    end
                end
                STOP :  begin
                    if (rx16 == 1) begin
                        if (oc == 4'd15) begin
                            if (rx) begin
                                rxd <= sr;
                                rxr <= 1'b1;
                            end
                            else sr <= 8'b0;
                            s <= IDL;
                        end
                        else oc <= oc + 4'd1;
                    end
                end
            endcase
        end

    end
endmodule
`default_nettype wire
