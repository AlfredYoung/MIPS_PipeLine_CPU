module RF(
    input clk,      //时钟信号
    input rst,      //复位信号
    input RFWr,     //使能信号
    input [4:0]A1,  //读寄存器1的地址
    input [4:0]A2,  //读寄存器2的地址
    input [4:0]A3,  //写寄存器的地址
    input [31:0]WD, //写寄存器的数据
    output [31:0]RD1,//读寄存器1的内容   
    output [31:0]RD2 //读寄存器2的内容
);
integer i;
reg [31:0]RF[31:0];

assign RD1 = RF[A1];
assign RD2 = RF[A2];


always @(posedge clk) begin
    if(rst)
        for(i = 0;i < 32;i = i + 1)
            RF[i] = 32'h0;
    else if(RFWr)
        RF[A3] <= WD;
end
endmodule