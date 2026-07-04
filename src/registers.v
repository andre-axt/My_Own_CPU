module registers(
    input wire clk,
    input wire rst,
    input wire [2:0] reg_sel,    
    input wire reg_write,    
    input wire [7:0] data_in,   
    output wire [7:0] data_out, 
    output wire [7:0] reg_a,   
    output wire [7:0] reg_b    
);

    reg [7:0] registers [0:7];  
    integer i; 

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 8; i = i + 1)
                register[i] <= 8'b0;
        end
        else if (reg_write) begin
            registers[reg_sel] <= data_in;
        end
    end
    
    assign reg_a = registers[1];   
    assign reg_b = registers[2];  
    assign data_out = registers[reg_sel];
    
endmodule
