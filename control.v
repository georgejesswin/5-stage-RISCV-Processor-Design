module control (
    input [10:0] optype,
    input [2:0] funct3,
    input [6:0] funct7,
    input [31:0] data_1,
    input [31:0] data_2,
    input [31:0] pc,
    input [31:0] immI,
    input [31:0] immS,
    input [31:0] immB,
    input [31:0] immU,
    input [31:0] immJ,

    output reg [3:0] alu_op,
    output reg alu_src,
    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg,
    output reg branch,
    output reg jump,
    output reg jalr,
    output reg [31:0] x,
    output reg [31:0] y,
    output reg [31:0] write_data,
    output reg [31:0] imm_out
);

always @(*) begin
    // Default values
    alu_op      = 4'b0000;
    alu_src     = 0;
    reg_write   = 0;
    mem_read    = 0;
    mem_write   = 0;
    mem_to_reg  = 0;
    branch      = 0;
    jump        = 0;
    x           = data_1;
    y           = data_2;

    case (optype)
        // R-Type Arithmetic
        11'b00000000001: begin
            reg_write = 1;
            alu_src   = 0;
            case (funct7)
                7'b0000000: begin
                    case (funct3)
                        3'b000: alu_op = 4'b0000; // ADD
                        3'b001: alu_op = 4'b0101; // SLL
                        3'b010: alu_op = 4'b1000; // SLT
                        3'b011: alu_op = 4'b1001; // SLTU
                        3'b100: alu_op = 4'b0010; // XOR
                        3'b101: alu_op = 4'b0110; // SRL
                        3'b110: alu_op = 4'b0011; // OR
                        3'b111: alu_op = 4'b0100; // AND
                        default: alu_op = 4'b0000;
                    endcase
                end
                7'b0100000: begin
                    case (funct3)
                        3'b000: alu_op = 4'b0001; // SUB
                        3'b101: alu_op = 4'b0111; // SRA
                        default: alu_op = 4'b0000;
                    endcase
                end
            endcase
        end

        // I-Type Arithmetic
        11'b00000000010: begin
            reg_write = 1;
            alu_src   = 1;
           // y         = immI;
            imm_out=immI;
            case (funct3)
                3'b000: alu_op = 4'b0000; // ADDI
                3'b001: alu_op = 4'b0101; // SLLI
                3'b010: alu_op = 4'b1000; // SLTI
                3'b011: alu_op = 4'b1001; // SLTIU
                3'b100: alu_op = 4'b0010; // XORI
                3'b101: alu_op = (immI[11:5] == 7'b0100000) ? 4'b0111 : 4'b0110; // SRAI/SRLI
                3'b110: alu_op = 4'b0011; // ORI
                3'b111: alu_op = 4'b0100; // ANDI
                default: alu_op = 4'b0000;
            endcase
        end

        // I-Type Load
        11'b00000000100: begin
            reg_write   = 1;
            alu_src     = 1;
            mem_read    = 1;
            mem_to_reg  = 1;
           // y           = immI;
           imm_out=immI;
            alu_op      = 4'b0000; // ADD
        end

        // S-Type Store
        11'b00000001000: begin
            alu_src     = 1;
            mem_write   = 1;
            imm_out          = immS;
            write_data  = data_2;
            alu_op      = 4'b0000; // ADD
        end

        // B-Type Branch
        11'b00000010000: begin
            branch      = 1;
            alu_src     = 0;
            y           = data_2;
            imm_out = immB;
            case (funct3)
                3'b000: alu_op = 4'b1010; // BEQ
                3'b001: alu_op = 4'b1011; // BNE
                3'b100: alu_op = 4'b1000; // BLT
                3'b101: alu_op = 4'b1100; // BGE
                3'b110: alu_op = 4'b1001; // BLTU
                3'b111: alu_op = 4'b1101; // BGEU
                default: alu_op = 4'b0000;
            endcase
        end

        // J-Type (JAL)
        11'b00000100000: begin
            reg_write   = 1;
            jump        = 1;
            alu_src     = 1;
            imm_out          = immJ;
            alu_op      = 4'b0000;
        end

        // I-Type Jump (JALR)
        11'b00001000000: begin
            reg_write   = 1;
            jump        = 1;
            jalr=1;
            alu_src     = 1;
            imm_out          = immI;
            alu_op      = 4'b0000;
        end

        // U-Type LUI
        11'b00010000000: begin
            reg_write   = 1;
            alu_src     = 1;
            imm_out          = immU;
            alu_op      = 4'b0000;
        end

        // U-Type AUIPC
        11'b00100000000: begin
            reg_write   = 1;
            alu_src     = 1;
            x           = pc;
            imm_out         = immU;
            alu_op      = 4'b0000;
        end

        // System
        11'b01000000000: begin
            // You can expand this based on CSR or ECALL if required
            alu_op = 4'b0000;
        end

        default: begin
            alu_op      = 4'b0000;
        end
    endcase
end

endmodule
