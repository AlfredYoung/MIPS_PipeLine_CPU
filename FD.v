module FD(
    input clk,
	input rst,
	input En,
	input [31:0] N_Instr_D,
	input [31:0] N_PC4_D,
	input [31:0] N_PC8_D,
	output reg [31:0] Instr_D = 0,
	output reg [31:0] PC4_D = 0,
	output reg [31:0] PC8_D = 0
);

always @(posedge clk,posedge rst) begin
	if (rst) begin
		Instr_D = 0;
		PC4_D = 0;
		PC8_D = 0;
	end
	else if(En)begin
		Instr_D = N_Instr_D;
		PC4_D = N_PC4_D;
		PC8_D = N_PC8_D;
	end
end

endmodule
