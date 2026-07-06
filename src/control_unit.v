module control_unit(
    input wire clk,
    input wire rst,
    input wire [7:0] pc_out,        
    input wire [7:0] reg_a,         
    input wire [7:0] reg_b,       
    input wire [7:0] alu_result,    
    input wire [7:0] mem_data_out, 
    input wire zero_flag,
    input wire carry_flag,
    input wire negative_flag,
    output reg [7:0] mem_addr,
    output reg [7:0] mem_data_in,
    output reg mem_write_en,
    output reg pc_en,
    output reg load_pc,
    output reg [7:0] pc_in,
    output reg [2:0] reg_sel,
    output reg reg_write,
    output reg [3:0] alu_opcode,
    output reg [3:0] alu_operand,
    output reg [7:0] alu_data_in,
    output reg alu_is_extended
);

    reg [7:0] instr_reg;
  
    localparam FETCH  = 2'b00,
               EXECUTE = 2'b01,
               JUMP    = 2'b10;

    reg [1:0] state, next_state;
    reg jump_taken;

    localparam OP_ADD   = 4'b0000,
               OP_SUB   = 4'b0001,
               OP_AND   = 4'b0010,
               OP_OR    = 4'b0011,
               OP_XOR   = 4'b0100,
               OP_PUSH  = 4'b0101,
               OP_SHL   = 4'b0110,
               OP_SHR   = 4'b0111,
               OP_LOAD  = 4'b1000,
               OP_STORE = 4'b1001,
               OP_JMP   = 4'b1010,
               OP_JZ    = 4'b1011,
               OP_JNZ   = 4'b1100,
               OP_JC    = 4'b1101,
               OP_JNC   = 4'b1110,
               OP_POP   = 4'b1111;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= FETCH;
            next_state <= FETCH;
            instr_reg <= 8'b0;
            mem_addr <= 8'b0;
            mem_data_in <= 8'b0;
            mem_write_en <= 1'b0;
            pc_en <= 1'b0;
            load_pc <= 1'b0;
            pc_in <= 8'b0;
            reg_sel <= 3'b0;
            reg_write <= 1'b0;
            alu_opcode <= 4'b0;
            alu_operand <= 4'b0;
            alu_data_in <= 8'b0;
            alu_is_extended <= 1'b0;
            jump_taken <= 1'b0;
        end else begin
            case (state)
                FETCH: begin
                    mem_addr <= pc_out;
                    mem_write_en <= 1'b0;
                    pc_en <= 1'b1;          
                    load_pc <= 1'b0;
                    instr_reg <= mem_data_out;
                    next_state <= EXECUTE;
                end

                EXECUTE: begin
                    mem_write_en <= 1'b0;
                    pc_en <= 1'b0;
                    load_pc <= 1'b0;
                    reg_write <= 1'b0;
                    alu_is_extended <= 1'b0;
                    alu_operand <= 4'b0;
                    alu_data_in <= 8'b0;
                    jump_taken <= 1'b0;

                    case (instr_reg[7:4])
                        OP_ADD: begin
                            alu_opcode <= OP_ADD;
                            reg_sel <= 3'b001;   
                            reg_write <= 1'b1;
                            next_state <= FETCH;
                        end
                        OP_SUB: begin
                            alu_opcode <= OP_SUB;
                            reg_sel <= 3'b001;
                            reg_write <= 1'b1;
                            next_state <= FETCH;
                        end
                        OP_AND: begin
                            alu_opcode <= OP_AND;
                            reg_sel <= 3'b001;
                            reg_write <= 1'b1;
                            next_state <= FETCH;
                        end
                        OP_OR: begin
                            alu_opcode <= OP_OR;
                            reg_sel <= 3'b001;
                            reg_write <= 1'b1;
                            next_state <= FETCH;
                        end
                        OP_XOR: begin
                            alu_opcode <= OP_XOR;
                            reg_sel <= 3'b001;
                            reg_write <= 1'b1;
                            next_state <= FETCH;
                        end
                        OP_PUSH: begin
                            alu_opcode <= OP_PUSH;
                            next_state <= FETCH;
                        end
                        OP_SHL: begin
                            alu_opcode <= OP_SHL;
                            reg_sel <= 3'b001;
                            reg_write <= 1'b1;
                            next_state <= FETCH;
                        end
                        OP_SHR: begin
                            alu_opcode <= OP_SHR;
                            reg_sel <= 3'b001;
                            reg_write <= 1'b1;
                            next_state <= FETCH;
                        end
                        OP_LOAD: begin
                            mem_addr <= reg_b;
                            mem_write_en <= 1'b0;
                            alu_opcode <= OP_LOAD;
                            alu_data_in <= mem_data_out; 
                            alu_is_extended <= 1'b1;     
                            reg_sel <= 3'b001;
                            reg_write <= 1'b1;
                            next_state <= FETCH;
                        end
                        OP_STORE: begin
                            mem_addr <= reg_b;
                            mem_data_in <= reg_a;
                            mem_write_en <= 1'b1;
                            alu_opcode <= OP_STORE;      
                            next_state <= FETCH;
                        end
                        OP_JMP: begin
                            alu_opcode <= OP_JMP;         
                            jump_taken <= 1'b1;         
                            next_state <= JUMP;
                        end
                        OP_JZ: begin
                            alu_opcode <= OP_JZ;
                            jump_taken <= zero_flag;
                            next_state <= JUMP;
                        end
                        OP_JNZ: begin
                            alu_opcode <= OP_JNZ;
                            jump_taken <= ~zero_flag;
                            next_state <= JUMP;
                        end
                        OP_JC: begin
                            alu_opcode <= OP_JC;
                            jump_taken <= carry_flag;
                            next_state <= JUMP;
                        end
                        OP_JNC: begin
                            alu_opcode <= OP_JNC;
                            jump_taken <= ~carry_flag;
                            next_state <= JUMP;
                        end
                        OP_POP: begin
                            alu_opcode <= OP_POP;
                            next_state <= FETCH;
                        end
                        default: begin
                            alu_opcode <= 4'b0;
                            next_state <= FETCH;
                        end
                    endcase
                end

                JUMP: begin
                    load_pc <= jump_taken;
                    pc_in <= alu_result;     
                    pc_en <= 1'b0;
                    mem_write_en <= 1'b0;
                    reg_write <= 1'b0;
                    next_state <= FETCH;
                end

                default: next_state <= FETCH;
            endcase

            state <= next_state;
        end
    end

endmodule
