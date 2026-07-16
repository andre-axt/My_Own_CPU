module system (
    input wire clk,
    input wire rst
);

    wire [7:0] bus_mem_addr;
    wire [7:0] bus_mem_data_to_mem;   
    wire [7:0] bus_mem_data_from_mem;
    wire bus_mem_write_en;

    cpu main_cpu (
        .clk(clk),
        .rst(rst),
        .mem_data_out(bus_mem_data_from_mem),
        .mem_addr(bus_mem_addr),
        .mem_data_in(bus_mem_data_to_mem),
        .mem_write_en(bus_mem_write_en)
    );

    memory main_memory (
        .clk(clk),
        .addr(bus_mem_addr),
        .data_in(bus_mem_data_to_mem),
        .write_en(bus_mem_write_en),
        .data_out(bus_mem_data_from_mem)
    );

endmodule
