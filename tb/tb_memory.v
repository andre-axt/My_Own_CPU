module tb_memory;
  
    // Inputs
    reg clk;
    reg [7:0] addr;
    reg [7:0] data_in;
    reg write_en;

    // Outputs
    wire [7:0] data_out;

    // Instantiate the memory module
    memory uut (
        .clk(clk),
        .addr(addr),
        .data_in(data_in),
        .write_en(write_en),
        .data_out(data_out)
    );

    // Clock generation: 10 ns period
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        $dumpfile("memory.vcd");
        $dumpvars(0, memory_tb);

        // Initialize signals
        clk = 0;
        addr = 8'b0;
        data_in = 8'b0;
        write_en = 0;

        // Wait a few cycles for stability
        #10;

        // Test 1: Write to address 0x10, read back
        $display("Test 1: Write 0xAA to addr 0x10");
        addr = 8'h10;
        data_in = 8'hAA;
        write_en = 1;
        #10;
        write_en = 0;
        #10;
        // Read back
        addr = 8'h10;
        #10;
        if (data_out === 8'hAA)
            $display("PASS: data_out = %h", data_out);
        else
            $display("FAIL: expected %h, got %h", 8'hAA, data_out);

        // Test 2: Write to address 0x20, read back
        $display("Test 2: Write 0x55 to addr 0x20");
        addr = 8'h20;
        data_in = 8'h55;
        write_en = 1;
        #10;
        write_en = 0;
        #10;
        addr = 8'h20;
        #10;
        if (data_out === 8'h55)
            $display("PASS: data_out = %h", data_out);
        else
            $display("FAIL: expected %h, got %h", 8'h55, data_out);

        // Test 3: Overwrite address 0x10 with new value
        $display("Test 3: Overwrite addr 0x10 with 0xBB");
        addr = 8'h10;
        data_in = 8'hBB;
        write_en = 1;
        #10;
        write_en = 0;
        #10;
        addr = 8'h10;
        #10;
        if (data_out === 8'hBB)
            $display("PASS: data_out = %h", data_out);
        else
            $display("FAIL: expected %h, got %h", 8'hBB, data_out);

        // Test 4: Read an unwritten address (should be X)
        $display("Test 4: Read unwritten addr 0x30");
        addr = 8'h30;
        #10;
        if (data_out === 8'hxx)
            $display("PASS: data_out is X as expected");
        else
            $display("FAIL: expected X, got %h", data_out);

        // Test 5: Write to address 0xFF and read
        $display("Test 5: Write 0x12 to addr 0xFF");
        addr = 8'hFF;
        data_in = 8'h12;
        write_en = 1;
        #10;
        write_en = 0;
        #10;
        addr = 8'hFF;
        #10;
        if (data_out === 8'h12)
            $display("PASS: data_out = %h", data_out);
        else
            $display("FAIL: expected %h, got %h", 8'h12, data_out);

        $display("All tests completed.");
        $finish;
    end

endmodule
