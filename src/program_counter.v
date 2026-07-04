module program_counter(
    input wire clk,
    input wire rst,
    input wire pc_en,        
    input wire load_pc,      
    input wire [7:0] pc_in, 
    output wire [7:0] pc_out
);

    reg [7:0] pc_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_reg <= 8'b00000000;  
        end else if (load_pc) begin
            pc_reg <= pc_in;        
        end else if (pc_en) begin
            pc_reg <= pc_reg + 1'b1;
        end
    end

    assign pc_out = pc_reg;

endmodule
