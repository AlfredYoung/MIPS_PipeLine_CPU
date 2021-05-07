module PC(
    input clk,              //时钟信号
    input rst,              //复位信号
    input PCWr,             //使能信号
    input [31:0]NPC,        //下一条指令地址
    output reg[31:0] PC     //当前指令地址
);
always @(posedge clk,posedge rst) begin
    if(rst)
        PC <= 32'h0000_3000;
    else if(PCWr)
        PC <= NPC;
end
endmodule
