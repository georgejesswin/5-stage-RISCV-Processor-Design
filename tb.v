`timescale 1ns / 1ps

module top_module_tb;

    reg clk;
    reg reset;
    wire [31:0] pc,instruction,alu_result,write_back_data;
    //wire [31:0] alu_x,alu_y,x,y,imm_out,ex_target_pc;
    //wire  [1:0] forwardA, forwardB,idex_jalr_out;
    wire [31:0] registers [0:31];
    wire [31:0] mem [0:1023];
    

    // Instantiate the DUT (Device Under Test)
    top_module uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    // Access PC directly using hierarchical name (optional debug)
    assign pc = uut.pc_current;
    assign instruction =uut.instruction;
    assign alu_result=uut.alu_result;
    //assign ex_target_pc=uut.ex_target_pc;
    assign write_back_data=uut.write_back_data;
    //assign idex_jalr_out=uut.idex_jalr_out;
    genvar i;
    generate
     for (i = 0; i < 32; i = i + 1) begin : reg_loop
        assign registers[i] = uut.REGS.registers[i];
     end    
    endgenerate

   // assign x=uut.idex_read_data1_out;
    //assign y=uut.idex_read_data2_out; 
    //assign alu_x=uut.ALU.x;
   // assign alu_y=uut.ALU.y;
    //assign forwardA=uut.forwardA;
    //assign forwardB=uut.forwardB;
    genvar j;
    generate
    for (j = 0; j < 1024; j = j + 1) begin : mem_loop
        assign mem[j] = uut.DMEM.mem[j];
    end
    endgenerate

    // assign imm_out=uut.idex_imm_out;
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;

        // Display header
        $display("Time\tReset\tPC");
        $monitor("%0t\t%b\t%0d", $time, reset, pc);

        // Hold reset high for a few cycles
        #10 reset = 0;

        // Run simulation for a few clock cycles
        #150 $finish;
    end

endmodule
