`default_nettype none
module cpu ( input clk , input rstn , input wire [15:0] rstvec , input [7:0] rd , output reg [15:0] addr , output reg rdr , output reg wdr , output reg [7:0] wd , output halt);
    // ISA OPCODES
    localparam [7:0] OP_NOP = 8'h00, OP_HLT = 8'h01, OP_ADD = 8'h20, OP_SUB = 8'h21, OP_AND = 8'h22, OP_OR = 8'h23, OP_XOR = 8'h24, OP_CMP = 8'h25, OP_ADDI = 8'h28, OP_CMPI = 8'h29, OP_ADC = 8'h26, OP_SBC = 8'h27, OP_INC_A = 8'h30, OP_DEC_A = 8'h31, OP_NOT_A = 8'h32, OP_SHL_A = 8'h33, OP_SHR_A = 8'h34, OP_NEG_A = 8'h35, OP_SAR_A = 8'h36, OP_MUL = 8'h38, OP_DIV = 8'h39, OP_LD_ABS = 8'h50, OP_ST_ABS = 8'h51, OP_LD_HL = 8'h52, OP_ST_HL = 8'h53, OP_INC_HL = 8'h54, OP_DEC_HL = 8'h55, OP_PUSH_A = 8'h58, OP_POP_A = 8'h59, OP_CALL = 8'h5A, OP_RET = 8'h5B, OP_JMP = 8'h60, OP_JZ = 8'h61, OP_JNZ = 8'h62, OP_JC = 8'h63, OP_JNC = 8'h64, OP_JLT = 8'h65, OP_JGE = 8'h66, OP_LDI_BASE = 8'h10, OP_MOV_BASE = 8'h40;
        
    // STATES
    localparam [4:0] F0 = 5'd0, F1 = 5'd1, DCD = 5'd2, OP10 = 5'd3, OP11 = 5'd4, OP20 = 5'd5, OP21 = 5'd6, IMME = 5'd7, LD0 = 5'd8, LD1 = 5'd9, ST0 = 5'd10, PUSH = 5'd11, POP = 5'd12, CL0 = 5'd13, CL1 = 5'd14, CL2 = 5'd15, RET0 = 5'd16, RET1 = 5'd17, RET2 = 5'd18, RET3 = 5'd19, RET4 = 5'd20, RET5 = 5'd21, JUMP = 5'd22, MDST = 5'd23, MDWT = 5'd24, MDWB = 5'd25, MSG1 = 5'd26, MSG2 = 5'd27, MSG3 = 5'd28, HALT = 5'd29;

    // ALU OP
    localparam [3:0] ADD = 4'd0, SUB = 4'd1, AND = 4'd2, OR = 4'd3, XOR = 4'd4, NOT = 4'd5, SHL = 4'd6, SHR = 4'd7, SAR = 4'd8, NEG = 4'd9, INC = 4'd10, DEC = 4'd11, ADCI = 4'd12, SBCI = 4'd13;


    reg [7:0] ra, rb, rh, rl, ir, tl, th;
    reg [15:0] pc, sp;
    reg fc, fz, fn, fv;
    reg [4:0] s;
    reg [3:0] msg_idx;
    reg [7:0] msg;

    wire [7:0] alu_res, div_q, div_r;
    reg [7:0] alu_b;
    reg [3:0] alu_op;
    wire alu_c, alu_v, alu_n, alu_z, mul_bz, div_bz;
    reg mul_cmd, div_cmd;
    wire [15:0] mul_res;

    alu dut1( .a(ra) , .b(alu_b) , .cin(fc) , .op(alu_op) , .result(alu_res) , .c(alu_c) , .z(alu_z) , .n(alu_n) , .v(alu_v) );
    mul8 dut2( .clk(clk) , .rstn(rstn) , .a(ra) , .b(rb) , .cmd(mul_cmd) , .result(mul_res) , .busy(mul_bz) );
    div8 dut3( .clk(clk) , .rstn(rstn) , .a(ra) , .b(rb) , .cmd(div_cmd) , .q(div_q) , .r(div_r) , .busy(div_bz) );

    always @(posedge clk) begin
        if (~rstn) begin
            s <= F0;
            pc <= rstvec;
            sp <= 16'h01FF;
            ra <= 8'b0;
            rb <= 8'b0;
            rh <= 8'b0;
            rl <= 8'b0;
            ir <= 8'b0;
            tl <= 8'b0;
            th <= 8'b0;
            fc <= 1'b0;
            fz <= 1'b0;
            fn <= 1'b0;
            fv <= 1'b0;
            msg_idx <= 4'b0;
        end
        else begin
            case (s)
                F0 : s <= F1;
                F1 : begin
                    ir <= rd;
                    pc <= pc + 16'd1;
                    s <= DCD;
                end
                DCD : begin
                    casez (ir)
                        OP_HLT : s <= HALT;
                        8'b0100???? : begin
                            case (ir[3:2])
                                2'd0 : 
                                    begin
                                        case (ir[1:0])
                                            2'd0 : ra <= ra;
                                            2'd1 : ra <= rb;
                                            2'd2 : ra <= rh;
                                            2'd3 : ra <= rl;
                                        endcase
                                    end
                                2'd1 : 
                                    begin
                                        case (ir[1:0])
                                            2'd0 : rb <= ra;
                                            2'd1 : rb <= rb;
                                            2'd2 : rb <= rh;
                                            2'd3 : rb <= rl;
                                        endcase
                                    end
                                2'd2 : 
                                    begin
                                        case (ir[1:0])
                                            2'd0 : rh <= ra;
                                            2'd1 : rh <= rb;
                                            2'd2 : rh <= rh;
                                            2'd3 : rh <= rl;
                                        endcase
                                    end
                                2'd3 : 
                                    begin
                                        case (ir[1:0])
                                            2'd0 : rl <= ra;
                                            2'd1 : rl <= rb;
                                            2'd2 : rl <= rh;
                                            2'd3 : rl <= rl;
                                        endcase
                                    end
                            endcase
                            s <= F0;
                        end
                        8'b000100?? : s <= OP10;
                        OP_ADD , OP_SUB , OP_AND , OP_OR , OP_XOR , OP_CMP , OP_ADC , OP_SBC , OP_INC_A , OP_DEC_A , OP_NOT_A , OP_SHL_A , OP_SHR_A , OP_NEG_A , OP_SAR_A : 
                        begin
                            fc <= alu_c;
                            fz <= alu_z;
                            fn <= alu_n;
                            fv <= alu_v;
                            ra <= ir == OP_CMP ? ra : alu_res;
                            s <= F0;
                        end
                        OP_ADDI , OP_CMPI : s <= OP10;
                        OP_JMP , OP_JZ , OP_JNZ , OP_JC , OP_JNC , OP_JLT , OP_JGE , OP_LD_ABS , OP_ST_ABS : s <= OP10;
                        OP_LD_HL : s <= LD0;
                        OP_ST_HL : s <= ST0;
                        OP_INC_HL : begin
                            {rh, rl} <= {rh, rl} + 16'd1;
                            s <= F0;
                        end
                        OP_DEC_HL : begin
                            {rh, rl} <= {rh, rl} - 16'd1;
                            s <= F0;
                        end
                        OP_PUSH_A : begin
                            sp <= sp - 16'd1;
                            s <= PUSH;
                        end
                        OP_POP_A : s <= POP;
                        OP_CALL : s <= OP10;
                        OP_RET : s <= RET0;
                        OP_MUL , OP_DIV : s <= MDST;
                        default : s <= F0;
                    endcase
                end
                OP10 : s <= OP11;
                OP11 : begin
                    tl <= rd;
                    pc <= pc + 16'd1;
                    s <= (ir[7:2] == 6'b000100 || ir == OP_ADDI || ir == OP_CMPI) ? IMME : OP20;
                end
                OP20 : s <= OP21;
                OP21 : begin
                    th <= rd;
                    pc <= pc + 16'd1;
                    case (ir)
                        OP_JMP , OP_JZ , OP_JNZ , OP_JC , OP_JNC , OP_JLT , OP_JGE : s <= JUMP;
                        OP_LD_ABS : s <= LD0;
                        OP_ST_ABS : s <= ST0;
                        OP_CALL : begin
                            sp <= sp - 16'd1;
                            s <= CL0;
                        end
                        default : s <= F0;
                    endcase
                end
                CL0 : begin
                    sp <= sp - 16'd1;
                    s <= CL1;
                end
                CL1 : s <= CL2;
                CL2 : begin
                    pc <= {th, tl};
                    s <= F0;
                end
                JUMP : begin
                    case (ir)
                        OP_JMP : begin
                            pc <= {th, tl};
                            s <= F0;
                        end
                        OP_JZ : begin
                            pc <= fz ? {th, tl} : pc;
                            s <= F0;
                        end
                        OP_JNZ : begin
                            pc <= fz ? pc : {th, tl};
                            s <= F0;
                        end
                        OP_JC : begin
                            pc <= fc ? {th, tl} : pc;
                            s <= F0;
                        end
                        OP_JNC : begin
                            pc <= fc ? pc : {th, tl};
                            s <= F0;
                        end
                        OP_JLT : begin
                            pc <= fn == fv ? pc : {th, tl};
                            s <= F0;
                        end
                        OP_JGE : begin
                            pc <= fn == fv ? {th, tl} : pc;
                            s <= F0;
                        end
                        default : s <= F0;
                    endcase
                end
                LD0 : s <= LD1;
                LD1 : begin
                    ra <= rd;
                    s <= F0;
                end 
                ST0 : s <= F0;
                PUSH : s <= F0;
                POP : s <= RET5;
                RET0 : begin
                    s <= RET1;
                end
                RET1 : begin
                    sp <= sp + 16'd1;
                    tl <= rd;
                    s <= RET2;
                end
                RET2 : begin
                    s <= RET3;
                end
                RET3 : begin
                    sp <= sp + 16'd1;
                    th <= rd;
                    s <= RET4;
                end
                RET4 : begin
                    pc <= {th, tl};
                    s <= F0;
                end 
                RET5 : begin
                    sp <= sp + 16'd1;
                    ra <= rd;
                    s <= F0;
                end
                MDST : s <= MDWT;
                MDWT : s <= (mul_bz | div_bz) ? MDWT : MDWB;
                MDWB : begin
                    rl <= (ir == OP_MUL) ? mul_res[7:0] : div_q;
                    rh <= (ir == OP_MUL) ? mul_res[15:8] : div_r;
                    fz <= (ir == OP_MUL) ? (mul_res == 16'd0) : (div_q == 8'd0);
                    fn <= (ir == OP_MUL) ? (mul_res[15]) : (div_q[7]);
                    fc <= (ir == OP_MUL) ? (mul_res[15:8] != 8'd0) : (rb == 8'd0);
                    fv <= 1'b0;
                    if ((ir == OP_DIV) && (rb == 8'd0)) begin
                        msg_idx <= 4'd0;
                        s <= MSG1;
                    end
                    else s <= F0;
                end
                MSG1 : s <= MSG2;
                MSG2 : begin
                    if (rd[0]) s <= MSG3;
                    else s <= MSG1;
                end
                MSG3 : begin
                    if (msg_idx == 4'd8) begin
                        s <= F0;
                    end else begin
                        msg_idx <= msg_idx + 4'd1;
                        s <= MSG1;
                    end
                end
                IMME : begin
                    if (ir[7:2] == 6'b000100) begin
                        case (ir[1:0])
                            2'd0 : ra <= tl;
                            2'd1 : rb <= tl;
                            2'd2 : rh <= tl;
                            2'd3 : rl <= tl;
                        endcase
                    end
                    if (ir == OP_ADDI || ir == OP_CMPI) begin
                        fc <= alu_c;
                        fz <= alu_z;
                        fn <= alu_n;
                        fv <= alu_v;
                        if (ir == OP_ADDI) ra <= alu_res;
                    end
                    s <= F0;
                end
                HALT : s <= HALT;
                default : s <= F0;
            endcase
        end
    end

    always @(*) begin
        addr = 16'h0000;
        rdr = 1'b0;
        wdr = 1'b0;
        wd = 8'h00;
        alu_b = s == IMME ? tl : rb;
        mul_cmd = 1'b0;
        div_cmd = 1'b0;
        case (s)
            F0 , OP10 , OP20 : begin
                addr = pc;
                rdr = 1'b1;
            end
            LD0 : begin
                rdr = 1'b1;
                addr = (ir == OP_LD_ABS) ? {th, tl} : {rh, rl};
            end
            ST0 : begin
                wdr = 1'b1;
                addr = (ir == OP_ST_ABS) ? {th, tl} : {rh, rl};
                wd = ra;
            end
            PUSH : begin
                wdr = 1'b1;
                addr = sp;
                wd = ra;
            end
            POP , RET0 , RET2 : begin
                addr = sp;
                rdr = 1'b1;
            end
            CL0 : begin
                wdr = 1'b1;
                addr = sp;
                wd = pc[15:8];
            end
            CL1 : begin
                wdr = 1'b1;
                addr = sp;
                wd = pc[7:0];
            end
            MSG1 : begin
                addr = 16'hFF01;
                rdr = 1'b1;
            end
            MSG2 : begin
                if (rd[0]) begin
                    addr = 16'hFF00;
                    wd = msg;
                    wdr = 1'b1;
                end
            end
            default : addr = 16'h0;
        endcase
        case (ir)
            OP_ADD, OP_ADDI : alu_op = ADD;
            OP_SUB, OP_CMP, OP_CMPI : alu_op = SUB;
            OP_AND : alu_op = AND;
            OP_OR : alu_op = OR;
            OP_XOR : alu_op = XOR;
            OP_ADC : alu_op = ADCI;
            OP_SBC : alu_op = SBCI;
            OP_INC_A : alu_op = INC;
            OP_DEC_A : alu_op = DEC;
            OP_NOT_A : alu_op = NOT;
            OP_SHL_A : alu_op = SHL;
            OP_SHR_A : alu_op = SHR;
            OP_SAR_A : alu_op = SAR;
            OP_NEG_A : alu_op = NEG;
            default : alu_op = AND;
        endcase
        case (msg_idx)
            4'd0 : msg = 8'h64;
            4'd1 : msg = 8'h75;
            4'd2 : msg = 8'h6D;
            4'd3 : msg = 8'h62;
            4'd4 : msg = 8'h61;
            4'd5 : msg = 8'h73;
            4'd6 : msg = 8'h73;
            4'd7 : msg = 8'h0D;
            4'd8 : msg = 8'h0A;
            default: msg = 8'h00;
        endcase
        mul_cmd = (s == MDST) && (ir == OP_MUL);
        div_cmd = (s == MDST) && (ir == OP_DIV);
    end

    assign halt = (s == HALT);
    wire _unused = &{1'b0, OP_LDI_BASE, OP_MOV_BASE, OP_NOP};
endmodule
`default_nettype wire

// python3 tools/asm.py tools/prog.asm test/p.hex
// iverilog -g2012 -o test/sim_build/cpu.vvp src/cpu.v src/alu.v src/mul8.v src/div8.v test/cpu_tb.v
// vvp test/sim_build/cpu.vvp +prog=test/p.hex