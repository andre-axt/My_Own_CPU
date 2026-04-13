module alu(
	input clk,
	input rst,
	input [3:0] x, y,
	input [1:0] op,
	output reg [3:0] axy, bxy, //axy(LSB) bxy(MSB)
	output reg c // Carry flag 

);

	wire [4:0] sum, sub;
	wire [7:0] mul;
	wire [3:0] and_op, or_op, xor_op;

	assign sum = {1'b0, x} + {1'b0, y};
	assign sub = {1'b0, x} - {1'b0, y};
	assign mul = x * y;
	assign and_op = x & y;
	assign or_op = x | y;
	assign xor_op = x ^ y;	 
			
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			axy <= 0;
			bxy <= 0;
			c <= 0;
		end
		else begin
			case (op)
				3'b000:	begin
					axy <= sum[3:0];
					bxy <= {3'b000,	sum[4]};
					c <= sum[4];
				end
				3'b001: begin
					axy <= sub[3:0];
					bxy <= {3'b000, sub[4]};
					c <= sub[4];
				end
				3'b010: begin
					axy <= mul[3:0];	
					bxy <= mul[7:4];
					c <= mul[7:4];
				end
				3'b011: begin
					axy <= and_op;
					bxy <= 4'b0000;
					c <= 1'b0;
				end
				3'b100:	begin
					axy <= or_op;
					bxy <= 4'b0000;
					c <= 1'b0;
				end
				3'b101: begin
					axy <= xor_op;
					bxy <= 4'b0000;
					c <= 1'b0;
				end
			endcase
		end
	end

endmodule
