module data_memory(
    input clk,
    input reset,
    input [31:0] address,
    input [31:0] write_data,
    input mem_write,
    input mem_read,
    input [2:0] funct3,           
    output reg [31:0] read_data
);

    reg [31:0] mem [0:1023]; // 4KB memory

    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 1024; i = i + 1)
                mem[i] <= 32'b0;
        end else if (mem_write) begin
            case(funct3)
                3'b000: begin // SB - store byte
                    mem[address[11:2]][8*address[1:0] +: 8] <= write_data[7:0];
                end
                3'b001: begin // SH - store half-word
                    mem[address[11:2]][16*address[1] +: 16] <= write_data[15:0];
                end
                3'b010: begin // SW - store word
                    mem[address[11:2]] <= write_data;
                end
                default: ; 
            endcase
        end
    end

    always @(*) begin
        if (mem_read) begin
            case(funct3)
                3'b000: read_data = {{24{mem[address[11:2]][8*address[1:0]+7]}}, mem[address[11:2]][8*address[1:0] +: 8]}; // LB
                3'b001: read_data = {{16{mem[address[11:2]][16*address[1]+15]}}, mem[address[11:2]][16*address[1] +: 16]}; // LH
                3'b010: read_data = mem[address[11:2]]; // LW
                3'b100: read_data = {24'b0, mem[address[11:2]][8*address[1:0] +: 8]}; // LBU
                3'b101: read_data = {16'b0, mem[address[11:2]][16*address[1] +: 16]}; // LHU
                default: read_data = 32'b0;
            endcase
        end else begin
            read_data = 32'b0;
        end
    end

endmodule
