module tb_program_counter;

    // Inputs
    reg clk;
    reg rst;
    reg pc_en;
    reg load_pc;
    reg [7:0] pc_in;

    // Outputs
    wire [7:0] pc_out;

    // Instantiate the program_counter module
    program_counter uut (
        .clk(clk),
        .rst(rst),
        .pc_en(pc_en),
        .load_pc(load_pc),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    // Clock generation: 10 ns period
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        $dumpfile("program_counter.vcd");
      $dumpvars(0, tb_program_counter);

        // Initialize inputs
        clk = 0;
        rst = 0;
        pc_en = 0;
        load_pc = 0;
        pc_in = 8'b0;

        // Apply reset and check
        $display("Test 1: Reset");
        rst = 1;
        #10;
        rst = 0;
        #10;
        if (pc_out === 8'b0)
            $display("PASS: pc_out = %h after reset", pc_out);
        else
            $display("FAIL: expected 00, got %h", pc_out);

        // Test 2: Increment with pc_en
        $display("Test 2: Increment");
        pc_en = 1;
        #10; // should become 1
        #10; // should become 2
        #10; // should become 3
        pc_en = 0;
        #10;
        if (pc_out === 8'h03)
            $display("PASS: pc_out = %h after 3 increments", pc_out);
        else
            $display("FAIL: expected 03, got %h", pc_out);

        // Test 3: Load a new value
        $display("Test 3: Load 0xAA");
        load_pc = 1;
        pc_in = 8'hAA;
        #10;
        load_pc = 0;
        #10;
        if (pc_out === 8'hAA)
            $display("PASS: pc_out = %h after load", pc_out);
        else
            $display("FAIL: expected AA, got %h", pc_out);

        // Test 4: Increment after load
        $display("Test 4: Increment after load");
        pc_en = 1;
        #10; // should become AB
        #10; // should become AC
        pc_en = 0;
        #10;
        if (pc_out === 8'hAC)
            $display("PASS: pc_out = %h after 2 increments", pc_out);
        else
            $display("FAIL: expected AC, got %h", pc_out);

        // Test 5: Load takes priority over increment (simultaneous)
        $display("Test 5: Load with pc_en also asserted");
        pc_en = 1;
        load_pc = 1;
        pc_in = 8'h55;
        #10;
        load_pc = 0;
        #10;
        if (pc_out === 8'h55)
            $display("PASS: pc_out = %h (load priority)", pc_out);
        else
            $display("FAIL: expected 55, got %h", pc_out);

        // Test 6: Reset during operation
        $display("Test 6: Reset while incrementing");
        pc_en = 1;
        #10; // becomes 56
        rst = 1;
        #10;
        rst = 0;
        #10;
        if (pc_out === 8'b0)
            $display("PASS: pc_out = %h after reset", pc_out);
        else
            $display("FAIL: expected 00, got %h", pc_out);

        $display("All tests completed.");
        $finish;
    end

endmodule
