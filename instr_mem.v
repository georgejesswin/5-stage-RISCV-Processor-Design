module instruction_memory(
    input [31:0] address,
    output [31:0] instruction
);

    reg [31:0] inst_mem [0:1023];  // 4KB memory

    assign instruction = inst_mem[address[11:2]];

    // NOTE: Memory content should be initialized manually or by testbench for simulation
    // This block is removed for synthesis
    
    initial begin
        $readmemh("instruction_memory.hex", inst_mem); // REMOVE this in final synthesis
    end
    

endmodule
