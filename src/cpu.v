module cpu (
    input wire clk,
    input wire rst,
    input wire [7:0] mem_data_out,  
    output wire [7:0] mem_addr,     
    output wire [7:0] mem_data_in, 
    output wire mem_write_en       
);

    wire [7:0] pc_out;
    wire pc_en;
    wire load_pc;
    wire [7:0] pc_in;

    wire [2:0] reg_sel;
    wire reg_write;
    wire [7:0] reg_data_out;
    wire [7:0] reg_a;
    wire [7:0] reg_b;

    wire [3:0] alu_opcode;
    wire [3:0] alu_operand;
    wire [7:0] alu_data_in;
    wire alu_is_extended;
    wire [7:0] alu_result;
    wire zero_flag;
    wire carry_flag;
    wire negative_flag;


    program_counter pc_inst (
        .clk(clk),
        .rst(rst),
        .pc_en(pc_en),
        .load_pc(load_pc),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    registers reg_inst (
        .clk(clk),
        .rst(rst),
        .reg_sel(reg_sel),
        .reg_write(reg_write),
        .data_in(alu_result), 
        .data_out(reg_data_out),
        .reg_a(reg_a),
        .reg_b(reg_b)
    );

    alu alu_inst (
        .clk(clk),
        .rst(rst),
        .opcode(alu_opcode),
        .operand(alu_operand),
        .data_in(alu_data_in),
        .reg_a(reg_a),
        .reg_b(reg_b),
        .is_extended(alu_is_extended),
        .alu_result(alu_result),
        .zero_flag(zero_flag),
        .carry_flag(carry_flag),
        .negative_flag(negative_flag)
    );

    control_unit cu_inst (
        .clk(clk),
        .rst(rst),
        .pc_out(pc_out),
        .reg_a(reg_a),
        .reg_b(reg_b),
        .alu_result(alu_result),
        .mem_data_out(mem_data_out),
        .zero_flag(zero_flag),
        .carry_flag(carry_flag),
        .negative_flag(negative_flag),
        .mem_addr(mem_addr),
        .mem_data_in(mem_data_in),
        .mem_write_en(mem_write_en),
        .pc_en(pc_en),
        .load_pc(load_pc),
        .pc_in(pc_in),
        .reg_sel(reg_sel),
        .reg_write(reg_write),
        .alu_opcode(alu_opcode),
        .alu_operand(alu_operand),
        .alu_data_in(alu_data_in),
        .alu_is_extended(alu_is_extended)
    );

endmodule
