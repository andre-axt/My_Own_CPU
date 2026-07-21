`timescale 1ns / 1ps

module tb_control_unit;

    reg clk;
    reg rst;
    reg [7:0] pc_out;
    reg [7:0] reg_a;
    reg [7:0] reg_b;
    reg [7:0] alu_result;
    reg [7:0] mem_data_out;
    reg zero_flag;
    reg carry_flag;
    reg negative_flag;

    wire [7:0] mem_addr;
    wire [7:0] mem_data_in;
    wire mem_write_en;
    wire pc_en;
    wire load_pc;
    wire [7:0] pc_in;
    wire [2:0] reg_sel;
    wire reg_write;
    wire [3:0] alu_opcode;
    wire [3:0] alu_operand;
    wire [7:0] alu_data_in;
    wire alu_is_extended;

    // Instantiate Control Unit
    control_unit uut (
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

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        pc_out = 8'h00;
        reg_a = 8'hAA;
        reg_b = 8'h05;
        alu_result = 8'h20;
        mem_data_out = 8'h00;
        zero_flag = 0;
        carry_flag = 0;
        negative_flag = 0;

        #15 rst = 0;

        // --- Test 1: Fetch and Execute ADD Instruction (0x00) ---
        mem_data_out = 8'h00; // OP_ADD
        #10; // State -> EXECUTE
        $display("[CU] State EXECUTE (ADD) -> reg_write=%b, alu_opcode=%b", reg_write, alu_opcode);
        #10; // State -> FETCH

        // --- Test 2: Fetch and Execute STORE Instruction (0x90) ---
        mem_data_out = 8'h90; // OP_STORE
        #10; // State -> EXECUTE
        #10; // State -> FETCH
        $display("[CU] State EXECUTE (STORE) -> mem_write_en=%b, mem_addr=0x%h, mem_data_in=0x%h", 
                 mem_write_en, mem_addr, mem_data_in);

        // --- Test 3: Unconditional Jump JMP (0xA0) ---
        mem_data_out = 8'hA0; // OP_JMP
        #10; // State -> EXECUTE
        #10; // State -> JUMP
        $display("[CU] State JUMP -> load_pc=%b, pc_in=0x%h", load_pc, pc_in);
        #10; // State -> FETCH

        $display("Control Unit Testbench completed successfully!");
        $finish;
    end

endmodule
