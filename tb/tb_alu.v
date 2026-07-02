`timescale 1ns / 1ps

module tb_alu();

    // Signals to connect to the ALU
    reg         clk;
    reg         rst;
    reg  [3:0]  opcode;
    reg  [3:0]  operand;
    reg  [7:0]  data_in;
    reg  [7:0]  reg_a;
    reg  [7:0]  reg_b;
    reg         is_extended;

    wire [7:0]  alu_result;
    wire        zero_flag;
    wire        carry_flag;
    wire        negative_flag;

    // Instantiate the ALU
    alu u_alu (
        .clk          (clk),
        .rst          (rst),
        .opcode       (opcode),
        .operand      (operand),
        .data_in      (data_in),
        .reg_a        (reg_a),
        .reg_b        (reg_b),
        .is_extended  (is_extended),
        .alu_result   (alu_result),
        .zero_flag    (zero_flag),
        .carry_flag   (carry_flag),
        .negative_flag(negative_flag)
    );

    // Clock generation: 10 ns period
    always #5 clk = ~clk;

    // Test procedure
    initial begin
        // Dump waveform for debugging
        $dumpfile("tb_alu.vcd");
        $dumpvars(0, tb_alu);

        // Initialize inputs
        clk = 0;
        rst = 1;
        opcode = 4'b0;
        operand = 4'b0;
        data_in = 8'b0;
        reg_a = 8'b0;
        reg_b = 8'b0;
        is_extended = 1'b0;

        // Apply reset for a few cycles
        repeat (2) @(posedge clk);
        rst = 0;
        @(posedge clk);

        $display("===== Starting ALU tests =====");
        $display("Time\tOp\tA\tB\tData\tResult\tZ\tC\tN");

        // -------------------- Test ADD --------------------
        // ADD: reg_a + reg_b
        test_add(8'h10, 8'h20, 8'h30, 0, 0);   // 0x10+0x20=0x30
        test_add(8'hFF, 8'h01, 8'h00, 1, 0);   // 0xFF+0x01=0x00, carry=1
        test_add(8'h80, 8'h80, 8'h00, 1, 1);   // 0x80+0x80=0x00, carry=1, neg=0
        test_add(8'h7F, 8'h01, 8'h80, 0, 0);   // 0x7F+0x01=0x80, neg=1

        // -------------------- Test SUB --------------------
        // SUB: reg_a - reg_b
        test_sub(8'h30, 8'h10, 8'h20, 0, 0);   // 0x30-0x10=0x20
        test_sub(8'h00, 8'h01, 8'hFF, 0, 1);   // 0x00-0x01=0xFF, borrow (carry=0)
        test_sub(8'h80, 8'h01, 8'h7F, 0, 0);   // 0x80-0x01=0x7F
        test_sub(8'h7F, 8'h80, 8'hFF, 0, 1);   // 0x7F-0x80=0xFF, borrow

        // -------------------- Test AND --------------------
        test_and(8'hA5, 8'h5A, 8'h00, 1, 0);   // 0xA5 & 0x5A = 0x00
        test_and(8'hFF, 8'h0F, 8'h0F, 0, 0);
        test_and(8'h80, 8'h80, 8'h80, 0, 1);   // negative flag

        // -------------------- Test OR --------------------
        test_or(8'hA5, 8'h5A, 8'hFF, 0, 1);
        test_or(8'h00, 8'h00, 8'h00, 1, 0);
        test_or(8'h80, 8'h00, 8'h80, 0, 1);

        // -------------------- Test XOR --------------------
        test_xor(8'hA5, 8'h5A, 8'hFF, 0, 1);
        test_xor(8'hA5, 8'hA5, 8'h00, 1, 0);
        test_xor(8'h80, 8'h00, 8'h80, 0, 1);

        // -------------------- Test CMP --------------------
        // CMP sets flags based on reg_a - reg_b, result = reg_a
        test_cmp(8'h30, 8'h10, 8'h30, 0, 0);   // 0x30-0x10=0x20 -> flags: Z=0, C=1, N=0
        test_cmp(8'h00, 8'h01, 8'h00, 0, 1);   // 0x00-0x01=0xFF -> Z=0, C=0, N=1
        test_cmp(8'h05, 8'h05, 8'h05, 1, 0);   // 0x05-0x05=0x00 -> Z=1, C=1, N=0

        // -------------------- Test SHL --------------------
        test_shl(8'h01, 8'h02, 0, 0);          // 0x01 << 1 = 0x02
        test_shl(8'h80, 8'h00, 1, 0);          // 0x80 << 1 = 0x00, carry=1
        test_shl(8'hFF, 8'hFE, 1, 1);          // 0xFF << 1 = 0xFE, carry=1, neg=1

        // -------------------- Test SHR --------------------
        test_shr(8'h02, 8'h01, 0, 0);          // 0x02 >> 1 = 0x01
        test_shr(8'h01, 8'h00, 1, 0);          // 0x01 >> 1 = 0x00, carry=1
        test_shr(8'h80, 8'h40, 0, 0);          // 0x80 >> 1 = 0x40, neg=0

        // -------------------- Test LOAD --------------------
        // LOAD immediate (is_extended=0): result = {4'b0, operand}
        test_load(4'hA, 8'h0A, 0, 0);           // operand=0xA -> 0x0A
        test_load(4'hF, 8'h0F, 0, 0);           // 0xF -> 0x0F
        // LOAD extended (is_extended=1): result = data_in
        test_load_ext(8'hAB, 8'hAB, 0, 1);      // data_in=0xAB -> 0xAB, neg=1
        test_load_ext(8'h00, 8'h00, 1, 0);      // 0x00 -> Z=1

        // -------------------- Test STORE --------------------
        // STORE just passes reg_a through, sets flags
        test_store(8'hAA, 8'hAA, 0, 1);         // reg_a=0xAA -> result=0xAA, neg=1
        test_store(8'h00, 8'h00, 1, 0);         // reg_a=0x00 -> Z=1

        // -------------------- Test JMP/JZ/JNZ/JC/JNC --------------------
        // All jump opcodes behave the same: result = reg_a, flags from reg_a
        test_jump(4'b1010, 8'h55, 8'h55, 0, 0); // JMP: no special flag changes
        test_jump(4'b1011, 8'h55, 8'h55, 0, 0);
        test_jump(4'b1100, 8'h55, 8'h55, 0, 0);
        test_jump(4'b1101, 8'h55, 8'h55, 0, 0);
        test_jump(4'b1110, 8'h55, 8'h55, 0, 0);
        test_jump(4'b1010, 8'h00, 8'h00, 1, 0); // Z=1

        // Test default (opcode not in list) – should result zero
        test_default();

        $display("===== All tests completed =====");
        $finish;
    end

    // ---------- Helper tasks ----------
    // Each task sets inputs, waits one clock, and checks outputs

    task test_add;
        input [7:0] a, b;
        input [7:0] exp_result;
        input exp_carry, exp_neg;
        reg [8:0] tmp;
        begin
            @(posedge clk);
            reg_a = a;
            reg_b = b;
            opcode = 4'b0000; // ADD
            is_extended = 0;
            @(posedge clk);
            #1; // small delay for signals to settle
            tmp = {1'b0, a} + {1'b0, b};
            check_result(exp_result, (tmp[7:0] == 8'b0), exp_carry, tmp[7], "ADD");
        end
    endtask

    task test_sub;
        input [7:0] a, b;
        input [7:0] exp_result;
        input exp_carry, exp_neg;
        reg [8:0] tmp;
        begin
            @(posedge clk);
            reg_a = a;
            reg_b = b;
            opcode = 4'b0001; // SUB
            is_extended = 0;
            @(posedge clk);
            #1;
            tmp = {1'b0, a} - {1'b0, b};
            check_result(exp_result, (tmp[7:0] == 8'b0), ~tmp[8], tmp[7], "SUB");
        end
    endtask

    task test_and;
        input [7:0] a, b;
        input [7:0] exp_result;
        input exp_zero, exp_neg;
        begin
            @(posedge clk);
            reg_a = a;
            reg_b = b;
            opcode = 4'b0010;
            is_extended = 0;
            @(posedge clk);
            #1;
            check_result(exp_result, exp_zero, 1'b0, exp_neg, "AND");
        end
    endtask

    task test_or;
        input [7:0] a, b;
        input [7:0] exp_result;
        input exp_zero, exp_neg;
        begin
            @(posedge clk);
            reg_a = a;
            reg_b = b;
            opcode = 4'b0011;
            is_extended = 0;
            @(posedge clk);
            #1;
            check_result(exp_result, exp_zero, 1'b0, exp_neg, "OR");
        end
    endtask

    task test_xor;
        input [7:0] a, b;
        input [7:0] exp_result;
        input exp_zero, exp_neg;
        begin
            @(posedge clk);
            reg_a = a;
            reg_b = b;
            opcode = 4'b0100;
            is_extended = 0;
            @(posedge clk);
            #1;
            check_result(exp_result, exp_zero, 1'b0, exp_neg, "XOR");
        end
    endtask

    task test_cmp;
        input [7:0] a, b;
        input [7:0] exp_result;
        input exp_zero, exp_neg;
        reg [8:0] tmp;
        begin
            @(posedge clk);
            reg_a = a;
            reg_b = b;
            opcode = 4'b0101; // CMP
            is_extended = 0;
            @(posedge clk);
            #1;
            tmp = {1'b0, a} - {1'b0, b};
            check_result(exp_result, exp_zero, ~tmp[8], exp_neg, "CMP");
        end
    endtask

    task test_shl;
        input [7:0] a;
        input [7:0] exp_result;
        input exp_carry, exp_neg;
        begin
            @(posedge clk);
            reg_a = a;
            reg_b = 8'b0;
            opcode = 4'b0110;
            is_extended = 0;
            @(posedge clk);
            #1;
            check_result(exp_result, (exp_result == 8'b0), exp_carry, exp_neg, "SHL");
        end
    endtask

    task test_shr;
        input [7:0] a;
        input [7:0] exp_result;
        input exp_carry, exp_neg;
        begin
            @(posedge clk);
            reg_a = a;
            reg_b = 8'b0;
            opcode = 4'b0111;
            is_extended = 0;
            @(posedge clk);
            #1;
            check_result(exp_result, (exp_result == 8'b0), exp_carry, 1'b0, "SHR");
        end
    endtask

    task test_load;
        input [3:0] imm;
        input [7:0] exp_result;
        input exp_zero, exp_neg;
        begin
            @(posedge clk);
            operand = imm;
            opcode = 4'b1000;
            is_extended = 0;
            data_in = 8'b0;
            @(posedge clk);
            #1;
            check_result(exp_result, exp_zero, 1'b0, exp_neg, "LOAD imm");
        end
    endtask

    task test_load_ext;
        input [7:0] din;
        input [7:0] exp_result;
        input exp_zero, exp_neg;
        begin
            @(posedge clk);
            data_in = din;
            opcode = 4'b1000;
            is_extended = 1;
            operand = 4'b0;
            @(posedge clk);
            #1;
            check_result(exp_result, exp_zero, 1'b0, exp_neg, "LOAD ext");
        end
    endtask

    task test_store;
        input [7:0] a;
        input [7:0] exp_result;
        input exp_zero, exp_neg;
        begin
            @(posedge clk);
            reg_a = a;
            opcode = 4'b1001;
            is_extended = 0;
            @(posedge clk);
            #1;
            check_result(exp_result, exp_zero, 1'b0, exp_neg, "STORE");
        end
    endtask

    task test_jump;
        input [3:0] op;
        input [7:0] a;
        input [7:0] exp_result;
        input exp_zero, exp_neg;
        begin
            @(posedge clk);
            reg_a = a;
            opcode = op;
            is_extended = 0;
            @(posedge clk);
            #1;
            check_result(exp_result, exp_zero, 1'b0, exp_neg, $sformatf("JUMP %h", op));
        end
    endtask

    task test_default;
        begin
            @(posedge clk);
            opcode = 4'b1111; // not used
            reg_a = 8'h55;
            @(posedge clk);
            #1;
            if (alu_result !== 8'b0)
                $display("ERROR: default opcode result should be 0, got %h", alu_result);
            else
                $display("PASS: default opcode");
        end
    endtask

    // Common checker
    task check_result;
        input [7:0] exp_res;
        input exp_z, exp_c, exp_n;
        input [31:0] opname;
        begin
            if (alu_result !== exp_res)
                $display("FAIL: %s result expected %h, got %h", opname, exp_res, alu_result);
            else if (zero_flag !== exp_z)
                $display("FAIL: %s Z flag expected %b, got %b", opname, exp_z, zero_flag);
            else if (carry_flag !== exp_c)
                $display("FAIL: %s C flag expected %b, got %b", opname, exp_c, carry_flag);
            else if (negative_flag !== exp_n)
                $display("FAIL: %s N flag expected %b, got %b", opname, exp_n, negative_flag);
            else
                $display("PASS: %s result=%h Z=%b C=%b N=%b", opname, alu_result, zero_flag, carry_flag, negative_flag);
        end
    endtask

endmodule
