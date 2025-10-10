module alu(
    input [31:0] x,
    input [31:0] y,
    input [3:0] alu_op,
    output reg [31:0] result
);
always @(*) begin
    case (alu_op)
        4'b0000: result = x + y; // Addition
        4'b0001: result = x - y; // Subtraction
        4'b0010: result = x ^ y; // Bitwise XOR
        4'b0011: result = x | y; // Bitwise OR
        4'b0100: result = x & y; // Bitwise AND
        4'b0101: result = x << y[4:0]; // Shift left Logical
        4'b0110: result = x >> y[4:0]; // Shift right Logical
        4'b0111: result = $signed(x) >>> y[4:0]; // Shift right Arithmetic
        4'b1000: result = ($signed(x) < $signed(y)) ? 1 : 0; // Less than
        4'b1001: result = x < y ? 1 : 0; // Less than unsigned
        4'b1010: result = (x == y) ? 1 : 0; // Equality
        4'b1011: result = (x != y) ? 1 : 0; // Inequality   
        4'b1100: result = ($signed(x) >= $signed(y)) ? 1 : 0; // Greater than or equal signed
        4'b1101: result = (x >= y) ? 1 : 0; // Greater than or equal unsigned
        default: result = 32'b0; // Default case
        
    endcase
end
endmodule