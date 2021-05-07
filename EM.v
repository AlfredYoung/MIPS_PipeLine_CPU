module EM(
	input clk,
	input rst,
	input [31:0] N_Instr_M,
	input [31:0] N_RT_M,
	input [31:0] N_ALU_M,
	input [31:0] N_EXT_M,
	input [31:0] N_PC8_M,
	input [4:0] N_WBA_M,
	output reg [31:0] Instr_M = 0,
	output reg [31:0] RT_M = 0,
	output reg [31:0] ALU_M = 0,
	output reg [31:0] EXT_M = 0,
	output reg [31:0] PC8_M = 0,
	output reg [4:0] WBA_M = 0
);  

always @(posedge clk,posedge rst) begin
	if (rst) begin
		Instr_M = 0;
		RT_M = 0;
		ALU_M = 0;
		EXT_M = 0;
		PC8_M = 0;
		WBA_M = 0;
	end
	else begin
		Instr_M = N_Instr_M;
		RT_M = N_RT_M;
		ALU_M = N_ALU_M;
		EXT_M = N_EXT_M;
		PC8_M = N_PC8_M;
		WBA_M = N_WBA_M;
	end
end
endmodule