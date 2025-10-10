module register_bank (
    input clk,
    input  reset,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] write_data,
    input reg_write,
    output  [31:0] read_data1,
    output  [31:0] read_data2
);
reg [31:0] registers [0:31];
integer i;
assign read_data1 = registers[rs1];
assign read_data2 = registers[rs2];
always @(negedge clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] <= 32'b0;
        end
    end
    else if(reg_write && rd!=5'b0) begin
        registers[rd] <= write_data;
    end
    end
endmodule