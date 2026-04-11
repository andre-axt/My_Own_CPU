module alu(
	input [3:0] x, y,
	input [1:0] op,
	output reg [3:0] axy, bxy, //axy(LSB) bxy(MSB)
	output reg c // Carry flag 

);

	wire [4:0] sum, sub;
	wire [7:0] mul;
	wire [3:0] and, or, xor;

	assign sum = {1'b0, x} + {1'b0, y};
	assign sub = {1'b0, x} - {1'b0, y};
	assign mul = x * y;
	assign and = x & y;
	assign or = x | y;
	assign xor = x ^ y;	 
			
		
