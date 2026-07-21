`timescale 1ns / 1ps

module tb_cpu;

    reg clk;
    reg rst;
    reg [7:0] mem_data_out;

    wire [7:0] mem_addr;
    wire [7:0] mem_data_in;
    wire mem_write_en;

    // Instantiate CPU
    cpu uut (
        .clk(clk),
        .rst(rst),
        .mem_data_out(mem_data_out),
        .mem_addr(mem_addr),
        .mem_data_in(mem_data_in),
        .mem_write_en(mem_write_en)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        mem_data_out = 8'h00;

        #15 rst = 0;

        // Step 1: PC = 0x00, Fetch OP_ADD (0x00)
        mem_data_out = 8'h00;
        #20; 
        $display("[CPU] PC address output: 0x%h", mem_addr);

        // Step 2: Fetch OP_STORE (0x90)
        mem_data_out = 8'h90;
        #20;
        $display("[CPU] Store output data: 0x%h to address 0x%h (write_en=%b)", 
                 mem_data_in, mem_addr, mem_write_en);

        #20;
        $display("CPU Testbench completed successfully!");
        $finish;
    end

endmodule
