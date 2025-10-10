module data_memory(
    input clk,
    input reset,
    input [31:0] address,
    input [31:0] write_data,
    input mem_write,
    input mem_read,
    output reg [31:0] read_data
);

reg [31:0] mem [0:1023]; // 4KB Memory

// Memory Initialization on Reset
integer i;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i < 1024; i = i + 1) begin
            mem[i] <= 32'b0;
        end
    end else if (mem_write) begin
        mem[address[11:2]] <= write_data; // Word-aligned write
    end
end

// Combinational Read
always @(*) begin
    if (mem_read)
        read_data = mem[address[11:2]]; // Word-aligned read
    else
        read_data = 32'b0;
end

endmodule
