module memory(
    input wire clk,
    input wire [7:0] addr,   
    input wire [7:0] data_in,
    input wire write_en,  // 1 = write, 0 = read       
    output wire [7:0] data_out 
);

    reg [7:0] ram [0:255];     

    assign data_out = ram[addr];

    always @(posedge clk) begin
        if (write_en) begin
            ram[addr] <= data_in;
        end
    end

endmodule
