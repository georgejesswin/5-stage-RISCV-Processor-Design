module if_id_pipeline_register(
    input clk,
    input reset,
    input stall,
    input flush,  // optional: to pause pipeline
    input [31:0] pc_in,
    input [31:0] instruction_in,

    output reg [31:0] pc_out,
    output reg [31:0] instruction_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out <= 32'b0;
            instruction_out <= 32'b0;
        end
        else if (!stall) begin
         if (flush) begin
          pc_out <= 32'b0;
                    instruction_out <= 32'b0;
                    end
                    else begin
         
            pc_out <= pc_in;
            instruction_out <= instruction_in;
            end
        end
    end

endmodule
