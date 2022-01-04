module NPC(
    input [31:0]PC,         //当前指令地址
    input [31:0]ImmB,       //branch指令的低16位经符号扩展得到
    input [25:0]ImmJ,       //target指令的低26位
    input [31:0]Cmp1,       //branch指令的第1个操作数
    input [31:0]Cmp2,       //branch指令的第2个操作数
    input [2:0] CmpOp,      //branch指令对应的类型
    output [31:0]Jump,      //jump指令得到的地址
    output reg[31:0]Branch  //branch指令得到的地址
);

assign Jump = {PC[31:28],ImmJ,2'b00};

always @(*)begin
    case(CmpOp)
    	0: Branch = ($signed(Cmp1) == $signed(Cmp2)) ? (PC + (ImmB << 2)) : (PC + 4);		//beq
		1: Branch = ($signed(Cmp1) != $signed(Cmp2)) ? (PC + (ImmB << 2)) : (PC + 4);		//bne
		2: Branch = ($signed(Cmp1) <= 0) ? (PC + (ImmB << 2)) : (PC + 4);					//blez
		3: Branch = ($signed(Cmp1) > 0) ? (PC + (ImmB << 2)) : (PC + 4);					//bgtz
		4: Branch = ($signed(Cmp1) < 0) ? (PC + (ImmB << 2)) : (PC + 4);					//bltz
		5: Branch = ($signed(Cmp1) >= 0) ? (PC + (ImmB << 2)) : (PC + 4);					//bgez
    endcase
end
endmodule