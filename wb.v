module write_back(
    input [31:0] alu_result,     // From EX/MEM or MEM/WB
    input [31:0] mem_data,       // Data read from memory
    input mem_to_reg,            // Control signal: 1 = mem_data, 0 = alu_result
    output [31:0] write_back_data // Final data to write to register
);

assign write_back_data = (mem_to_reg) ? mem_data : alu_result;

endmodule
