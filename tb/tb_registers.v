`timescale 1ns / 1ps

module tb_registers;
  
    // Inputs
    reg clk;
    reg rst;
    reg [2:0] reg_sel;
    reg reg_write;
    reg [7:0] data_in;
  
    // Outputs
    wire [7:0] data_out;
    wire [7:0] reg_a;
    wire [7:0] reg_b;
  
    // Instantiate the Unit Under Test (UUT)
    registers uut (
        .clk(clk),
        .rst(rst),
        .reg_sel(reg_sel),
        .reg_write(reg_write),
        .data_in(data_in),
        .data_out(data_out),
        .reg_a(reg_a),
        .reg_b(reg_b)
    );

    // Clock generation: 10 ns period
    always #5 clk = ~clk;

    // Test stimulus
    initial begin
        // Initialize inputs
        clk = 0;
        rst = 1;
        reg_sel = 0;
        reg_write = 0;
        data_in = 0;

        // Release reset after 20 ns
        #20 rst = 0;
        #10;

        // Test 1: Write and read each register
        $display("=== Test 1: Write and read each register ===");
        for (int i = 0; i < 8; i++) begin
            reg_sel = i;
            data_in = 8'hA0 + i;   // 0xA0, 0xA1, ...
            reg_write = 1;
            #10;
            reg_write = 0;
            // Read back from same register
            #10;
            $display("Register[%0d] = %h, data_out = %h (expected %h)", i, uut.registers[i], data_out, data_in);
            // Check data_out
            if (data_out !== data_in) $error("Mismatch for register %0d", i);
        end

        // Test 2: Verify reg_a always equals registers[1]
        $display("=== Test 2: Verify reg_a ===");
        reg_sel = 1;
        data_in = 8'h55;
        reg_write = 1;
        #10;
        reg_write = 0;
        #10;
        $display("reg_a = %h, registers[1] = %h", reg_a, uut.registers[1]);
        if (reg_a !== uut.registers[1]) $error("reg_a mismatch");

        // Test 3: Verify reg_b always equals registers[2]
        $display("=== Test 3: Verify reg_b ===");
        reg_sel = 2;
        data_in = 8'hAA;
        reg_write = 1;
        #10;
        reg_write = 0;
        #10;
        $display("reg_b = %h, registers[2] = %h", reg_b, uut.registers[2]);
        if (reg_b !== uut.registers[2]) $error("reg_b mismatch");

        // Test 4: Ensure write only happens when reg_write is 1
        $display("=== Test 4: Write enable check ===");
        reg_sel = 3;
        data_in = 8'hFF;
        reg_write = 0;
        #10;
        // Read register 3
        reg_sel = 3;
        #10;
        $display("After write disabled, register[3] = %h (should remain previous value)", uut.registers[3]);
        // Write with enable
        reg_write = 1;
        #10;
        reg_write = 0;
        #10;
        reg_sel = 3;
        #10;
        $display("After write enabled, register[3] = %h (should be FF)", uut.registers[3]);
        if (uut.registers[3] !== 8'hFF) $error("Write enable failed");

        // Test 5: Reset behavior
        $display("=== Test 5: Reset ===");
        rst = 1;
        #20;
        $display("After reset, registers[0] = %h, [1] = %h, [7] = %h", uut.registers[0], uut.registers[1], uut.registers[7]);
        for (int i = 0; i < 8; i++) begin
            if (uut.registers[i] !== 8'b0) $error("Register %0d not cleared after reset", i);
        end
        rst = 0;

        $display("=== All tests completed ===");
        $finish;
    end

    initial begin
        $dumpfile("tb_registers.vcd");
        $dumpvars(0, tb_registers);
    end

endmodule
