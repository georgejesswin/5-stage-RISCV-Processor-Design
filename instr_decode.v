module instruction_decoder(
    input [31:0] instruct,
    output [6:0] opcode,
    output [4:0] rd,
    output [2:0] funct3,
    output [4:0] rs1,
    output [4:0] rs2,
    output [31:0] immI,
    output [31:0] immS,
    output [31:0] immB,
    output [31:0] immU,
    output [31:0] immJ,
    output [6:0] funct7,
    output reg [10:0] optype

);
assign opcode = instruct[6:0];
assign rd = instruct[11:7];
assign funct3 = instruct[14:12];
assign rs1 = instruct[19:15];
assign rs2 = instruct[24:20];
assign immI={{20{instruct[31]}} , instruct[30:20]};
assign immS={{20{instruct[31]}} , instruct[30:25], instruct[11:7]};
assign immB={{19{instruct[31]}} , instruct[7], instruct[30:25], instruct[11:8],1'b0};
assign immU={instruct[31:12], 12'b0};
assign immJ={{12{instruct[31]}} , instruct[19:12], instruct[20], instruct[30:21], 1'b0};
assign funct7 = instruct[31:25];
always @(*) begin
    case (opcode)
        7'b0110011: optype = 11'b00000000001; // R-type
        7'b0010011: optype = 11'b00000000010; // I-type Arithmetic
        7'b0000011: optype = 11'b00000000100; // I-type Load
        7'b0100011: optype = 11'b00000001000; // S-type Store
        7'b1100011: optype = 11'b00000010000; // B-type Branch
        7'b1101111: optype = 11'b00000100000; // J-type Jump
        7'b1100111: optype = 11'b00001000000; // I-type Jump
        7'b0110111: optype = 11'b00010000000; // U-type LUI
        7'b0010111: optype = 11'b00100000000; // U-type AUIPC
        7'b1110011: optype = 11'b01000000000; // System
        default: optype = 11'b11111111111; // Undefined
    endcase
   end
endmodule