module EXT(
    input [15:0]In,
    input [1:0]Op,
    output reg[31:0]Out
);always @(*) begin
    case(Op)
        0: Out = $signed(In);   //符号扩展
        1: Out = In;            //0扩展
        2: Out = {In,16'h0000}; //加载至高位
    endcase
end
endmodule