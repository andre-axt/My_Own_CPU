`timescale 1ns / 1ps

module tb_system;

    reg clk;
    reg rst;

    system uut (
        .clk(clk),
        .rst(rst)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;

        uut.main_memory.ram[0] = 8'h80; // OP_LOAD
        uut.main_memory.ram[1] = 8'h00; // OP_ADD
        uut.main_memory.ram[2] = 8'h90; // OP_STORE
        uut.main_memory.ram[5] = 8'h42; // Data to load

        #15 rst = 0;

        #120;

        $display("[SYSTEM] RAM[0x00] after execution = 0x%h", uut.main_memory.ram[0]);
        $display("System Testbench completed successfully!");
        $finish;
    end

endmodule
