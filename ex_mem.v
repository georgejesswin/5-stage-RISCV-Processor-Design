module ex_mem_pipeline_register(
    input clk,
    input reset,
    input stall,
    input flush,
    input [31:0] alu_result_in,
    input [31:0] write_data_in,
    input [4:0] rd_in,
    input mem_read_in,
    input mem_write_in,
    input reg_write_in,
    input mem_to_reg_in,
    input [2:0] funct3_in,
    output reg [31:0] alu_result_out,
    output reg [31:0] write_data_out,
    output reg [4:0] rd_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg reg_write_out,
    output reg mem_to_reg_out,
    output reg [2:0] funct3_out
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        alu_result_out <= 32'b0;
        write_data_out <= 32'b0;
        rd_out <= 5'b0;
        mem_read_out <= 1'b0;
        mem_write_out <= 1'b0;
        reg_write_out <= 1'b0;
        mem_to_reg_out <= 1'b0;
        funct3_out <= 3'b0;
    end else if (!stall) begin
        if (flush) begin
            alu_result_out <= 32'b0;
            write_data_out <= 32'b0;
            rd_out <= 5'b0;
            mem_read_out <= 1'b0;
            mem_write_out <= 1'b0;
            reg_write_out <= 1'b0;
            mem_to_reg_out <= 1'b0;
            funct3_out <= 3'b0;
        end else begin
            alu_result_out <= alu_result_in;
            write_data_out <= write_data_in;
            rd_out <= rd_in;
            mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in;
            reg_write_out <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            funct3_out <= funct3_in;
        end
    end
end

endmodule
