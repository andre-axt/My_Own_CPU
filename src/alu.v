module alu(
	input clk,
	input rst,
	input [3:0] in_x, in_y,
	input [1:0] in_op,
	output reg [3:0] axy, bxy, //axy(LSB) bxy(MSB)
	output reg c // Carry flag 

);

	wire [4:0] sum, sub;
	wire [7:0] mul;
	wire [3:0] and_op, or_op, xor_op;

	assign sum = {1'b0, in_x} + {1'b0, in_y};
	assign sub = {1'b0, in_x} - {1'b0, in_y};
	assign mul = in_x * in_y;
	assign and_op = in_x & in_y;
	assign or_op = in_x | in_y;
	assign xor_op = in_x ^ in_y;	 
			
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			axy <= 0;
			bxy <= 0;
			c <= 0;
		end
		else begin
			case (in_op)
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
