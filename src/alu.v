module alu(
	input clk,
	input rst,
	input [7:0] in_x, in_y,
	input [2:0] in_op,
	output reg [7:0] axy, bxy, //axy(LSB) bxy(MSB)
	output reg c // Carry flag 

);

	wire [8:0] sum, sub;
	wire [15:0] mul;
	wire [7:0] and_op, or_op, xor_op;

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
					axy <= sum[7:0];
					bxy <= {7'b0000000,	sum[8]};
					c <= sum[8];
				end
				3'b001: begin
					axy <= sub[7:0];
					bxy <= {7'b0000000, sub[8]};
					c <= sub[8];
				end
				3'b010: begin
					axy <= mul[7:0];	
					bxy <= mul[15:8];
					c <= 1'b0;
				end
				3'b011: begin
					axy <= and_op;
					bxy <= 8'b00000000;
					c <= 1'b0;
				end
				3'b100:	begin
					axy <= or_op;
					bxy <= 8'b00000000;
					c <= 1'b0;
				end
				3'b101: begin
					axy <= xor_op;
					bxy <= 8'b00000000;
					c <= 1'b0;
				end
				default: begin
					axy <= 0;
					bxy <= 0;
					c <= 0;
				end
			endcase
		end
	end

endmodule
