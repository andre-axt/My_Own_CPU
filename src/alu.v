module alu(
	input wire clk,
	input wire rst,
	input wire [3:0] opcode,
	input wire [3:0] operand,
	input wire [7:0] data_in,
	input wire [7:0] reg_a,
	input wire [7:0] reg_b,
	input wire is_extended,

	output reg [7:0] alu_result,
	output reg zero_flag,
	output reg carry_flag,
	output reg negative_flag	

);

	reg [8:0] extended_result;

	localparam OP_ADD   = 4'b0000;
	localparam OP_SUB   = 4'b0001;
	localparam OP_AND   = 4'b0010;
	localparam OP_OR    = 4'b0011;
	localparam OP_XOR   = 4'b0100;
	localparam OP_PUSH   = 4'b0101;
	localparam OP_SHL   = 4'b0110;
	localparam OP_SHR   = 4'b0111;
	localparam OP_LOAD  = 4'b1000;
	localparam OP_STORE = 4'b1001;
	localparam OP_JMP   = 4'b1010;
	localparam OP_JZ    = 4'b1011;
	localparam OP_JNZ   = 4'b1100;
	localparam OP_JC    = 4'b1101;
	localparam OP_JNC   = 4'b1110;
	localparam OP_POP   = 4'b1111;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			alu_result <= 8'b0;
            zero_flag <= 1'b0;
            carry_flag <= 1'b0;
            negative_flag <= 1'b0;
            extended_result <= 9'b0;
		end 
		else begin
			zero_flag <= 1'b0;
			carry_flag <= 1'b0;
			negative_flag <= 1'b0;

			case (opcode)
				OP_ADD: begin
					extended_result = {1'b0, reg_a} + {1'b0, reg_b};
	                alu_result <= extended_result[7:0];
					carry_flag <= extended_result[8];
					zero_flag <= (extended_result[7:0] == 8'b0);
					negative_flag <= extended_result[7];

				end

				OP_SUB: begin
					extended_result = {1'b0, reg_a} - {1'b0, reg_b};
					alu_result <= extended_result[7:0];
					carry_flag <= ~extended_result[8]; 
					zero_flag <= (extended_result[7:0] == 8'b0);
					negative_flag <= extended_result[7];
				end

				OP_AND: begin 
					alu_result <= reg_a & reg_b;
					zero_flag <= ((reg_a & reg_b) == 8'b0);
					negative_flag <= reg_a[7] & reg_b[7];
				end
					
				OP_OR: begin 
					alu_result <= reg_a | reg_b;
					zero_flag <= ((reg_a | reg_b) == 8'b0);
					negative_flag <= reg_a[7] | reg_b[7];
				end

				OP_XOR: begin 
					alu_result <= reg_a ^ reg_b;
					zero_flag <= ((reg_a ^ reg_b) == 8'b0);
					negative_flag <= reg_a[7] ^ reg_b[7];
				end

				OP_PUSH: begin
					alu_result <= reg_a;
                    zero_flag <= (reg_a == 8'b0);
                    negative_flag <= reg_a[7];
                    carry_flag <= 1'b0;
				end

				OP_SHL: begin 
					alu_result <= reg_a << 1;
					carry_flag <= reg_a[7]; 
					zero_flag <= ((reg_a << 1) == 8'b0);
					negative_flag <= reg_a[6];
				end

				OP_SHR: begin 
					alu_result <= reg_a >> 1;
					carry_flag <= reg_a[0]; 
					zero_flag <= ((reg_a >> 1) == 8'b0);
					negative_flag <= 1'b0;
				end

				OP_LOAD: begin 
					if (is_extended) begin
						alu_result <= data_in; 
					end 
					else begin
						alu_result <= {4'b0, operand}; 
					end
					zero_flag <= (alu_result == 8'b0);
					negative_flag <= alu_result[7];
				end

				OP_STORE: begin 
					alu_result <= reg_a; 
					zero_flag <= (reg_a == 8'b0);
					negative_flag <= reg_a[7];
				end

				OP_JMP, OP_JZ, OP_JNZ, OP_JC, OP_JNC: begin
					alu_result <= reg_a; 
					zero_flag <= (reg_a == 8'b0);
					negative_flag <= reg_a[7];
				end

				OP_POP: begin
					alu_result <= data_in;
                    zero_flag <= (data_in == 8'b0);
                    negative_flag <= data_in[7];
                    carry_flag <= 1'b0;
				end
				
				default: begin
					alu_result <= 8'b0;
				end
				
			endcase
		end
	end
			
endmodule
