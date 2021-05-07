module MW(
	input clk,
	input rst,
	input [31:0] N_Instr_W,
	input [31:0] N_ALU_W,
	input [31:0] N_DM_W,
	input [31:0] N_EXT_W,
	input [31:0] N_PC8_W,
	input [4:0] N_WBA_W,
	output reg [31:0] Instr_W = 0,
	output reg [31:0] ALU_W = 0,
	output reg [31:0] DM_W = 0,
	output reg [31:0] EXT_W = 0,
	output reg [31:0] PC8_W = 0,
	output reg [4:0] WBA_W = 0
);

always @(posedge clk) begin
	if (rst) begin
		Instr_W = 0;
		ALU_W = 0;
		DM_W = 0;
		EXT_W = 0;
		PC8_W = 0;
		WBA_W = 0;
	end
	else begin
		Instr_W = N_Instr_W;
		ALU_W = N_ALU_W;
		DM_W = N_DM_W;
		EXT_W = N_EXT_W;
		PC8_W = N_PC8_W;
		WBA_W = N_WBA_W;
	end
end
endmodule