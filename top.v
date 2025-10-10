module top_module (
    input clk,
    input reset
);

    // === IF Stage ===
    wire [31:0] pc_current, pc_next;
    wire [31:0] instruction;

    // === IF/ID Pipeline Wires ===
    wire [31:0] ifid_pc_out;
    wire [31:0] ifid_instruction_out;

    // === ID Stage ===
    wire [6:0] opcode;
    wire [4:0] rd, rs1, rs2;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [31:0] immI, immS, immB, immU, immJ;
    wire [10:0] optype;

    wire [31:0] read_data1, read_data2;

    wire [3:0] alu_op;
    wire alu_src, reg_write, mem_read, mem_write, mem_to_reg, branch, jump,jalr;
    wire [31:0] x, y;

    // === ID/EX Pipeline Wires ===
    wire [31:0] idex_pc_out, idex_read_data1_out, idex_read_data2_out, idex_imm_out;
    wire [4:0] idex_rs1_out, idex_rs2_out, idex_rd_out;
    wire [3:0] idex_alu_op_out;
    wire idex_mem_read_out, idex_mem_write_out, idex_reg_write_out, idex_alu_src_out;
    wire idex_mem_to_reg_out, idex_branch_out, idex_jump_out,idex_jalr_out;

    // === EX Stage ===
    wire [31:0] alu_input_y, alu_result;

    // === EX/MEM Pipeline Wires ===
    wire [31:0] exmem_alu_result_out, exmem_write_data_out;
    wire [4:0] exmem_rd_out;
    wire exmem_mem_read_out, exmem_mem_write_out, exmem_reg_write_out, exmem_mem_to_reg_out;

    // === MEM Stage ===
    wire [31:0] mem_data;

    // === MEM/WB Pipeline Wires ===
    wire [31:0] memwb_mem_data_out, memwb_alu_result_out;
    wire [4:0] memwb_rd_out;
    wire memwb_reg_write_out, memwb_mem_to_reg_out;

    // === WB Stage ===
    wire [31:0] write_back_data;

    // === Writeback to Register Bank ===
    wire [4:0] write_back_rd = memwb_rd_out;
    wire [31:0] write_data_to_reg = write_back_data;
    wire write_enable = memwb_reg_write_out;
    wire ex_branch_taken;
    wire [31:0] ex_target_pc;
    wire branch_event = ex_branch_taken;
    wire [31:0] pc_plus_4 = pc_current + 4;
  
    assign pc_next = branch_event ? ex_target_pc : pc_plus_4;

    // === PC and IF ===
    //assign pc_next = pc_current + 4;
    wire if_id_flush = ex_branch_taken;   // flush IF/ID when branch resolved
    wire id_ex_flush = ex_branch_taken;
    program_counter PC (
        .clk(clk),
        .reset(reset),
        .next_pc(pc_next),
        .pc(pc_current)
    );

    instruction_memory IMEM (
        .address(pc_current),
        .instruction(instruction)
    );

    if_id_pipeline_register IF_ID (
        .clk(clk),
        .reset(reset),
        .stall(1'b0),
        .flush(if_id_flush),
        .pc_in(pc_current),
        .instruction_in(instruction),
        .pc_out(ifid_pc_out),
        .instruction_out(ifid_instruction_out)
    );

    // === Instruction Decode ===
    instruction_decoder DEC (
        .instruct(ifid_instruction_out),
        .opcode(opcode),
        .rd(rd),
        .funct3(funct3),
        .rs1(rs1),
        .rs2(rs2),
        .immI(immI),
        .immS(immS),
        .immB(immB),
        .immU(immU),
        .immJ(immJ),
        .funct7(funct7),
        .optype(optype)
    );

    register_bank REGS (
        .clk(clk),
        .reset(reset),
        .rs1(rs1),
        .rs2(rs2),
        .rd(write_back_rd),
        .write_data(write_data_to_reg),
        .reg_write(write_enable),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );
    wire [32:0] write_data,idex_write_data;
    wire [32:0] imm_out;
    control CTRL (
        .optype(optype),
        .funct3(funct3),
        .funct7(funct7),
        .data_1(read_data1),
        .data_2(read_data2),
        .pc(ifid_pc_out),
        .immI(immI),
        .immS(immS),
        .immB(immB),
        .immU(immU),
        .immJ(immJ),
        .alu_op(alu_op),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .jump(jump),
        .jalr(jalr),
        .x(x),
        .y(y),
        .write_data(write_data),
        .imm_out(imm_out)
    );
    wire [2:0] id_ex_funct3,ex_mem_funct3;
    // === ID/EX Register ===
    id_ex_pipeline_register ID_EX (
        .clk(clk),
        .reset(reset),
        .stall(1'b0),
        .flush(id_ex_flush),
        .pc_in(ifid_pc_out),
        .read_data1_in(x),
        .read_data2_in(y),
        .rs1_in(rs1),
        .rs2_in(rs2),
        .rd_in(rd),
        .alu_op_in(alu_op),
        .mem_read_in(mem_read),
        .mem_write_in(mem_write),
        .reg_write_in(reg_write),
        .alu_src_in(alu_src),
        .mem_to_reg_in(mem_to_reg),
        .branch_in(branch),
        .jump_in(jump),
        .jalr_in(jalr),
        .imm_in(imm_out),
        .write_data_in(write_data),
        .funct3_in(funct3),  // You may switch imm type depending on instruction

        .pc_out(idex_pc_out),
        .read_data1_out(idex_read_data1_out),
        .read_data2_out(idex_read_data2_out),
        .rs1_out(idex_rs1_out),
        .rs2_out(idex_rs2_out),
        .rd_out(idex_rd_out),
        .alu_op_out(idex_alu_op_out),
        .mem_read_out(idex_mem_read_out),
        .mem_write_out(idex_mem_write_out),
        .reg_write_out(idex_reg_write_out),
        .alu_src_out(idex_alu_src_out),
        .mem_to_reg_out(idex_mem_to_reg_out),
        .branch_out(idex_branch_out),
        .jump_out(idex_jump_out),
        .jalr_out(idex_jalr_out),
        .imm_out(idex_imm_out),
        .write_data_out(idex_write_data),
        .funct3_out(id_ex_funct3)
    );

    // === ALU Execution ===
//    assign alu_input_y = idex_alu_src_out ? idex_imm_out : idex_read_data2_out;

wire [1:0] forwardA, forwardB;

forwarding_unit FU (
    .ID_EX_rs1(idex_rs1_out),
    .ID_EX_rs2(idex_rs2_out),
    .EX_MEM_rd(exmem_rd_out),
    .MEM_WB_rd(memwb_rd_out),
    .EX_MEM_RegWrite(exmem_reg_write_out),
    .MEM_WB_RegWrite(memwb_reg_write_out),
    .forwardA(forwardA),
    .forwardB(forwardB)
);

wire [31:0] forwardA_result;
wire [31:0] forwardB_result;



assign forwardA_result = 
    (forwardA == 2'b10) ? (exmem_mem_to_reg_out ) ? mem_data : exmem_alu_result_out :
    (forwardA == 2'b01) ? write_back_data: // You must mux correctly in MEM/WB
    idex_read_data1_out;

assign forwardB_result = 
    (forwardB == 2'b10) ? (exmem_mem_to_reg_out ) ? mem_data : exmem_alu_result_out :
    (forwardB == 2'b01) ? write_back_data :
    idex_read_data2_out;
assign alu_input_y = idex_alu_src_out ? idex_imm_out  : forwardB_result;


    alu ALU (
        .x(forwardA_result),
        .y(alu_input_y),
        .alu_op(idex_alu_op_out),
        .result(alu_result)
    );
    assign ex_branch_taken = (alu_result && idex_branch_out)|| idex_jump_out;
    wire [31:0] branch_target_b = idex_pc_out + idex_imm_out; // B-type / J-type
    wire [31:0] jalr_target = (forwardA_result + idex_imm_out) & 32'hfffffffe;
    assign ex_target_pc = idex_jump_out && idex_jalr_out ? jalr_target : branch_target_b;

    ex_mem_pipeline_register EX_MEM (
        .clk(clk),
        .reset(reset),
        .stall(1'b0),
        .flush(1'b0),
        .alu_result_in(alu_result),
        .write_data_in(forwardB_result),
        .rd_in(idex_rd_out),
        .mem_read_in(idex_mem_read_out),
        .mem_write_in(idex_mem_write_out),
        .reg_write_in(idex_reg_write_out),
        .mem_to_reg_in(idex_mem_to_reg_out),
        .funct3_in(id_ex_funct3),

        .alu_result_out(exmem_alu_result_out),
        .write_data_out(exmem_write_data_out),
        .rd_out(exmem_rd_out),
        .mem_read_out(exmem_mem_read_out),
        .mem_write_out(exmem_mem_write_out),
        .reg_write_out(exmem_reg_write_out),
        .mem_to_reg_out(exmem_mem_to_reg_out),
        .funct3_out(ex_mem_funct3)
    );

    data_memory DMEM (
        .clk(clk),
        .reset(reset),
        .address(exmem_alu_result_out),
        .write_data(exmem_write_data_out),
        .mem_write(exmem_mem_write_out),
        .mem_read(exmem_mem_read_out),
        .read_data(mem_data)
    );

    mem_wb_pipeline_register MEM_WB (
        .clk(clk),
        .reset(reset),
        .stall(1'b0),
        .flush(1'b0),
        .mem_data_in(mem_data),
        .alu_result_in(exmem_alu_result_out),
        .rd_in(exmem_rd_out),
        .reg_write_in(exmem_reg_write_out),
        .mem_to_reg_in(exmem_mem_to_reg_out),

        .mem_data_out(memwb_mem_data_out),
        .alu_result_out(memwb_alu_result_out),
        .rd_out(memwb_rd_out),
        .reg_write_out(memwb_reg_write_out),
        .mem_to_reg_out(memwb_mem_to_reg_out)
    );

    write_back WB (
        .alu_result(memwb_alu_result_out),
        .mem_data(memwb_mem_data_out),
        .mem_to_reg(memwb_mem_to_reg_out),
        .write_back_data(write_back_data)
    );

endmodule
