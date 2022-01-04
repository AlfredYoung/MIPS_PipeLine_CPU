module MW(
	input clk,
	input rst,
	input flush,
	input [31:0] N_Instr_W,
	input [31:0] N_ALU_W,
	input [31:0] N_DM_W,
	input [31:0] N_EXT_W,
	input [31:0] N_PC8_W,
	input [4:0] N_WBA_W,
	input [31:0] N_debug_pc_W,
	input [8:0] MEM_Out_EXC,
	input [31:0] N_RT_W,
	output reg [31:0] Instr_W = 0,
	output reg [31:0] ALU_W = 0,
	output reg [31:0] DM_W = 0,
	output reg [31:0] EXT_W = 0,
	output reg [31:0] PC8_W = 0,
	output reg [4:0] WBA_W = 0,
	output reg [31:0] debug_pc_W,
	output reg [8:0] WB_In_EXC,
	output reg [31:0] RT_W
);

always @(posedge clk) begin
	if (rst || flush) begin
		Instr_W <= 0;
		ALU_W <= 0;
		DM_W <= 0;
		EXT_W <= 0;
		PC8_W <= 0;
		WBA_W <= 0;
		debug_pc_W <= 0;
		WB_In_EXC <= 0;
		RT_W <= 0;
	end
	else begin
		Instr_W = N_Instr_W;
		ALU_W = N_ALU_W;
		DM_W = N_DM_W;
		EXT_W = N_EXT_W;
		PC8_W = N_PC8_W;
		WBA_W = N_WBA_W;
		debug_pc_W <= N_debug_pc_W;
		WB_In_EXC <= MEM_Out_EXC;
		RT_W <= N_RT_W;
	end
end
endmodule