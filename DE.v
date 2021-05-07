module DE(      //D/E级流水寄存器
    input clk,
    input rst,
    input clear,
    input En,
    input [31:0]N_Instr_E,
    input [31:0]N_RS_E,
    input [31:0]N_RT_E,
    input [31:0]N_EXT_E,
    input [31:0]N_PC8_E,
    input [4:0]N_WBA_E,
    input [31:0]N_s_E,
    output reg [31:0]Instr_E,
    output reg [31:0]RS_E,
    output reg [31:0]RT_E,
    output reg [31:0]EXT_E,
    output reg [31:0]PC8_E,
    output reg [4:0]WBA_E,
    output reg [31:0]s_E
);

always @(posedge clk) begin
    if(rst || clear) begin
      Instr_E = 0;
      RS_E = 0;
      RT_E = 0;
      EXT_E = 0;
      PC8_E = 0;
      WBA_E = 0;
      s_E = 0;
    end
    else begin
      Instr_E = N_Instr_E;
      RS_E = N_RS_E;
      RT_E = N_RT_E;
      EXT_E = N_EXT_E;
      PC8_E = N_PC8_E;
      WBA_E = N_WBA_E;
      s_E = N_s_E;
end
end
endmodule