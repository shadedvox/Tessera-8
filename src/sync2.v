`default_nettype none
module sync2 #(parameter w = 1,rstv = 1'b0)( input clk , input rstn , input wire [w-1 : 0] asyin , output reg [w-1 : 0] syout);
    reg [w-1 : 0] ff1;
    always @(posedge clk) begin
        if (~rstn) begin
            ff1 <= {w{rstv}};
            syout <= {w{rstv}};
        end
        else begin
            ff1 <= asyin;
            syout <= ff1;
        end
    end
endmodule
`default_nettype wire
