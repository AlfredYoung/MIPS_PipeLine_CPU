module FD(
    input clk,
	input rst,
	input En,
	input flush,
	input [31:0] N_PC4_D,
	input [31:0] N_PC8_D,
	input [31:0] N_debug_pc_D,
	input PC_EXC_IF,
	input Delay_Next,
	output reg [31:0] debug_pc_D,
	output reg [31:0] PC4_D = 0,
	output reg [31:0] PC8_D = 0,
	output reg  PC_EXC_ID,
	output reg inst_vaild,
	output reg delay
);

always @(posedge clk,posedge rst) begin
	if (rst) begin
		PC4_D <= 0;
		PC8_D <= 0;
		debug_pc_D <= 0;
		PC_EXC_ID <= 0;
		inst_vaild <= 0;
		delay <= 0;
	end
	else if (flush) begin
	  	PC4_D <= 0;
		PC8_D <= 0;
		debug_pc_D <= 0;
		PC_EXC_ID <= 0;
		inst_vaild <= 1;
		delay <= 0;
	end
	else if(En) begin
		PC4_D <= N_PC4_D;
		PC8_D <= N_PC8_D;
		debug_pc_D <= N_debug_pc_D;
		PC_EXC_ID <= PC_EXC_IF;
		inst_vaild <= 0;
		if(Delay_Next)
			delay <= 1;
		else
			delay <= 0;
	end
end

endmodule
