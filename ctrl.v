module CTRL(
    /*IF/ID级寄存器*/
    input [31:0]Instr,              //32位指令
    output reg[2:0]NPC_Sel,          //PC的来源，0表示来自PC+4,1表示Beq,2表示来自Jump,3表示来自转发多选器
    output reg[1:0]EXT_Sel,         //EXT的扩展信号，0代表有符号扩展，1代表无符号扩展，2代表加载到高位
    output reg[1:0]RF_Data_Sel,          //RF写寄存器的地址来源，0表示rd字段，1表示rt字段，2表示常量31
    output reg[2:0]PC_Sel,         //0：beq,1：bne,2：blez,3：bgtz,4：bltz,5：bgez
    /*ID/EXE级寄存器*/
    output reg[3:0]ALU_Sel,         //ALU的选择信号
    output reg ALU_A_Sel,           //ALU第一个操作数的选择信号
    output reg ALU_B_Sel,           //ALU第二个操作数的选择信号
    /*EXE/MEM级寄存器*/
    output reg DMWr,                //数据寄存器DM的写使能信号
    output reg[1:0]StoreType,       //存储类型
    output reg[2:0]LoadType,        //加载类型
    /*MEM/WB*/
    output reg[1:0]RF_Sel,     //数据来源选择信号
    output reg RFWr,                //寄存器堆的写使能信号  
	/*MDU相关*/
	output reg [2:0] MDU_Sel,
	output reg Start,
	output reg MDU_RD_Sel,
	output reg ALU_MDU_Sel
);
    `define op 31:26
    `define funct 5:0
    `define imm26 25:0
    `define imm16 15:0
    `define rs 25:21
    `define rt 20:16
    `define rd 15:11
    `define s 10:6

wire [5:0]Op = Instr[`op];
wire [5:0]Funct = Instr[`funct];
wire [4:0]rt = Instr[`rt];
/*lui*/
always @(*) begin
		if (Op == 6'b000000 && Funct == 6'b100000) begin	//add
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			RFWr = 1;
			RF_Sel = 0;
			ALU_Sel = 0;
			ALU_A_Sel = 0;
			ALU_B_Sel = 0;
			DMWr = 0;
			RF_Data_Sel = 0;
		end
		else if (Op == 6'b000000 && Funct == 6'b100001) begin	//addu
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			RFWr = 1;
			RF_Sel = 0;
			ALU_Sel = 0;
			ALU_A_Sel = 0;
			ALU_B_Sel = 0;
			DMWr = 0;
			RF_Data_Sel = 0;
		end
		else if (Op == 6'b000000 && Funct == 6'b100010) begin	//sub
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			RFWr = 1;
			RF_Sel = 0;
			ALU_Sel = 1;
			ALU_A_Sel = 0;
			ALU_B_Sel = 0;
			DMWr = 0;
			RF_Data_Sel = 0;
		end
		else if (Op == 6'b000000 && Funct == 6'b100011) begin	//subu
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			RFWr = 1;
			RF_Sel = 0;
			ALU_Sel = 1;
			ALU_A_Sel = 0;
			ALU_B_Sel = 0;
			DMWr = 0;
			RF_Data_Sel = 0;
		end
		else if (Op == 6'b000000 && Funct == 6'b100100)	begin	//and
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			RF_Sel = 0;
			ALU_Sel = 2;
			ALU_A_Sel = 0;
			ALU_B_Sel = 0;
			DMWr = 0;
			RF_Data_Sel = 0;
			RFWr = 1;
		end
		else if (Op == 6'b000000 && Funct == 6'b100101)	begin	//or
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			RF_Sel = 0;
			ALU_Sel = 3;
			ALU_A_Sel = 0;
			ALU_B_Sel = 0;
			DMWr = 0;
			RF_Data_Sel = 0;
			RFWr = 1;
		end
		else if (Op == 6'b000000 && Funct == 6'b100110)	begin	//xor
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			RF_Sel = 0;
			ALU_Sel = 4;
			ALU_A_Sel = 0;
			ALU_B_Sel = 0;
			DMWr = 0;
			RF_Data_Sel = 0;
			RFWr = 1;
		end
		else if (Op == 6'b000000 && Funct == 6'b100111)	begin	//nor
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			RF_Sel = 0;
			ALU_Sel = 5;
			ALU_A_Sel = 0;
			ALU_B_Sel = 0;
			DMWr = 0;
			RF_Data_Sel = 0;
			RFWr = 1;
		end
		else if (Op == 6'b000000 && Funct == 6'b000100) begin	//sllv
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			RF_Sel = 0;
			ALU_Sel = 6;
			ALU_A_Sel = 0;
			ALU_B_Sel = 0;
			DMWr = 0;
			RF_Data_Sel = 0;
			RFWr = 1;	
		end
		else if (Op == 6'b000000 && Funct == 6'b000110) begin	//srlv
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			RF_Sel = 0;
			ALU_Sel = 7;
			ALU_A_Sel = 0;
			ALU_B_Sel = 0;
			DMWr = 0;
			RF_Data_Sel = 0;
			RFWr = 1;	
		end
		else if (Op == 6'b000000 && Funct == 6'b000111) begin	//srav
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			RF_Sel = 0;
			ALU_Sel = 8;
			ALU_A_Sel = 0;
			ALU_B_Sel = 0;
			DMWr = 0;
			RF_Data_Sel = 0;
			RFWr = 1;	
		end
		else if (Op == 6'b000000 && Funct == 6'b000000) begin	//sll
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			RF_Sel = 0;
			ALU_Sel = 6;
			ALU_A_Sel = 1;
			ALU_B_Sel = 0;
			DMWr = 0;
			RF_Data_Sel = 0;
			RFWr = 1;
		end
		else if (Op == 6'b000000 && Funct == 6'b000010) begin	//srl
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			RF_Sel = 0;
			ALU_Sel = 7;
			ALU_A_Sel = 1;
			ALU_B_Sel = 0;
			DMWr = 0;
			RF_Data_Sel = 0;
			RFWr = 1;
		end
		else if (Op == 6'b000000 && Funct == 6'b000011) begin	//sra
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			RF_Sel = 0;
			ALU_Sel = 8;
			ALU_A_Sel = 1;
			ALU_B_Sel = 0;
			DMWr = 0;
			RF_Data_Sel = 0;
			RFWr = 1;
		end
		else if (Op == 6'b001000) begin		//addi
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			EXT_Sel = 0;
			RF_Sel = 1;
			ALU_Sel = 0;
			ALU_A_Sel = 0;
			ALU_B_Sel = 1;
			DMWr = 0;
			RF_Data_Sel = 0;
			RFWr = 1;
		end
		else if (Op == 6'b001001) begin		//addiu
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			EXT_Sel = 0;
			RF_Sel = 1;
			ALU_Sel = 0;
			ALU_A_Sel = 0;
			ALU_B_Sel = 1;
			DMWr = 0;
			RF_Data_Sel = 0;
			RFWr = 1;
		end
		else if (Op == 6'b001100) begin		//andi
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			EXT_Sel = 1;
			RF_Sel = 1;
			ALU_Sel = 2;
			ALU_A_Sel = 0;
			ALU_B_Sel = 1;
			DMWr = 0;
			RF_Data_Sel = 0;
			RFWr = 1;
		end
		else if (Op == 6'b001101) begin		//ori
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			EXT_Sel = 1;
			RF_Sel = 1;
			ALU_Sel = 3;
			ALU_A_Sel = 0;
			ALU_B_Sel = 1;
			DMWr = 0;
			RF_Data_Sel = 0;
			RFWr = 1;
		end
		else if (Op == 6'b001110) begin		//xori
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			EXT_Sel = 1;
			RF_Sel = 1;
			ALU_Sel = 4;
			ALU_A_Sel = 0;
			ALU_B_Sel = 1;
			DMWr = 0;
			RF_Data_Sel = 0;
			RFWr = 1;
		end
		else if (Op == 6'b001111) begin		//lui
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			RFWr = 1;
			EXT_Sel = 2;
			RF_Sel = 1;
			DMWr = 0;
			RF_Data_Sel = 2;
		end
		else if (Op == 6'b000010) begin		//j
			NPC_Sel = 2;
			MDU_Sel = 0;
			Start = 0;
			RFWr = 0;
			DMWr = 0;
		end
		else if (Op == 6'b000011) begin		//jal
			NPC_Sel = 2;
			MDU_Sel = 0;
			Start = 0;
			RFWr = 1;
			RF_Sel = 2;
			DMWr = 0;
			RF_Data_Sel = 3;
		end
		else if (Op == 6'b000000 && Funct == 6'b001000) begin	//jr
			NPC_Sel = 3;
			MDU_Sel = 0;
			Start = 0;
			RFWr = 0;
			DMWr = 0;
		end
		else if (Op == 6'b000000 && Funct == 6'b001001) begin	//jalr
			NPC_Sel = 3;
			MDU_Sel = 0;
			Start = 0;
			RF_Sel = 0;
			DMWr = 0;
			RF_Data_Sel = 3;
			RFWr = 1;
		end
		else if (Op == 6'b000100) begin		//beq
			NPC_Sel = 1;
			MDU_Sel = 0;
			Start = 0;
			RFWr = 0;
			EXT_Sel = 0;
			PC_Sel = 0;
			DMWr = 0;
		end
		else if (Op == 6'b000101) begin		//bne
			NPC_Sel = 1;
			MDU_Sel = 0;
			Start = 0;
			RFWr = 0;
			EXT_Sel = 0;
			PC_Sel = 1;
			DMWr = 0;
		end
		else if (Op == 6'b000110) begin		//blez
			NPC_Sel = 1;
			MDU_Sel = 0;
			Start = 0;
			RFWr = 0;
			EXT_Sel = 0;
			PC_Sel = 2;
			DMWr = 0;
		end
		else if (Op == 6'b000111) begin		//bgtz
			NPC_Sel = 1;
			MDU_Sel = 0;
			Start = 0;
			RFWr = 0;
			EXT_Sel = 0;
			PC_Sel = 3;
			DMWr = 0;
		end
		else if (Op == 6'b000001 && rt == 5'b00000) begin	//bltz
			NPC_Sel = 1;
			MDU_Sel = 0;
			Start = 0;
			RFWr = 0;
			EXT_Sel = 0;
			PC_Sel = 4;
			DMWr = 0;
		end
		else if (Op == 6'b000001 && rt == 5'b00001) begin	//bgez
			NPC_Sel = 1;
			MDU_Sel = 0;
			Start = 0;
			RFWr = 0;
			EXT_Sel = 0;
			PC_Sel = 5;
			DMWr = 0;	
		end
		else if(Op == 6'b000001 && rt == 5'b10001) begin		//bgezal
		  NPC_Sel = 1;
		  MDU_Sel = 0;
		  Start = 0;
		  RFWr = 1;
		  EXT_Sel = 0;
		  PC_Sel = 5;
		  DMWr = 0;
		  RFWr = 1;
		  RF_Sel = 2;
		  RF_Data_Sel = 3;
		end
		else if(Op == 6'b000001 && rt == 5'b10000) begin		//bltzal
		  NPC_Sel = 1;
		  MDU_Sel = 0;
		  Start = 0;
		  RFWr = 1;
		  EXT_Sel = 0;
		  PC_Sel = 4;
		  DMWr = 0;
		  RFWr = 1;
		  RF_Sel = 2;
		  RF_Data_Sel = 3;
		end
		else if (Op == 6'b000000 && Funct == 6'b101010) begin	//slt
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			RF_Sel = 0;
			ALU_Sel = 9;
			ALU_A_Sel = 0;
			ALU_B_Sel = 0;
			DMWr = 0;
			RF_Data_Sel = 0;
			RFWr = 1;
		end//break
		else if (Op == 6'b000000 && Funct == 6'b101011) begin	//sltu
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			RF_Sel = 0;
			ALU_Sel = 10;
			ALU_A_Sel = 0;
			ALU_B_Sel = 0;
			DMWr = 0;
			RF_Data_Sel = 0;
			RFWr = 1;
		end
		else if (Op == 6'b001010) begin		//slti
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			EXT_Sel = 0;
			RF_Sel = 1;
			ALU_Sel = 9;
			ALU_A_Sel = 0;
			ALU_B_Sel = 1;
			DMWr = 0;
			RF_Data_Sel = 0;
			RFWr = 1;
		end
		else if (Op == 6'b001011) begin		//sltiu
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			EXT_Sel = 0;
			RF_Sel = 1;
			ALU_Sel = 10;
			ALU_A_Sel = 0;
			ALU_B_Sel = 1;
			DMWr = 0;
			RF_Data_Sel = 0;
			RFWr = 1;
		end
		else if (Op == 6'b101011) begin		//sw
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			RFWr = 0;
			EXT_Sel = 0;
			ALU_Sel = 0;
			ALU_A_Sel = 0;
			ALU_B_Sel = 1;
			DMWr = 1;
			StoreType = 0;
		end
		else if (Op == 6'b101001) begin		//sh
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			RFWr = 0;
			EXT_Sel = 0;
			ALU_Sel = 0;
			ALU_A_Sel = 0;
			ALU_B_Sel = 1;
			DMWr = 1;
			StoreType = 1;
		end
		else if (Op == 6'b101000) begin		//sb
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			RFWr = 0;
			EXT_Sel = 0;
			ALU_Sel = 0;
			ALU_A_Sel = 0;
			ALU_B_Sel = 1;
			DMWr = 1;
			StoreType = 2;
		end
		else if (Op == 6'b100011) begin		//lw
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			RFWr = 1;
			EXT_Sel = 0;
			RF_Sel = 1;
			ALU_Sel = 0;
			ALU_A_Sel = 0;
			ALU_B_Sel = 1;
			DMWr = 0;
			LoadType = 0;
			RF_Data_Sel = 1;
		end
		else if (Op == 6'b100001) begin		//lh
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			RFWr = 1;
			EXT_Sel = 0;
			RF_Sel = 1;
			ALU_Sel = 0;
			ALU_A_Sel = 0;
			ALU_B_Sel = 1;
			DMWr = 0;
			LoadType = 1;
			RF_Data_Sel = 1;
		end
		else if (Op == 6'b100101) begin		//lhu
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			RFWr = 1;
			EXT_Sel = 0;
			RF_Sel = 1;
			ALU_Sel = 0;
			ALU_A_Sel = 0;
			ALU_B_Sel = 1;
			DMWr = 0;
			LoadType = 2;
			RF_Data_Sel = 1;
		end
		else if (Op == 6'b100000) begin		//lb
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			RFWr = 1;
			EXT_Sel = 0;
			RF_Sel = 1;
			ALU_Sel = 0;
			ALU_A_Sel = 0;
			ALU_B_Sel = 1;
			DMWr = 0;
			LoadType = 3;
			RF_Data_Sel = 1;
		end
		else if (Op == 6'b100100) begin		//lbu
			NPC_Sel = 0;
			MDU_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 0;
			RFWr = 1;
			EXT_Sel = 0;
			RF_Sel = 1;
			ALU_Sel = 0;
			ALU_A_Sel = 0;
			ALU_B_Sel = 1;
			DMWr = 0;
			LoadType = 4;
			RF_Data_Sel = 1;
		end
		else if (Op == 6'b000000 && Funct == 6'b011000)	begin	//mult
			NPC_Sel = 0;
			MDU_Sel = 1;
			Start = 1;
			DMWr = 0;
			RFWr = 0;
		end
		else if (Op == 6'b000000 && Funct == 6'b011001)	begin	//multu
			NPC_Sel = 0;
			MDU_Sel = 2;
			Start = 1;
			DMWr = 0;
			RFWr = 0;
		end
		else if (Op == 6'b000000 && Funct == 6'b011010)	begin	//div
			NPC_Sel = 0;
			MDU_Sel = 3;
			Start = 1;
			DMWr = 0;
			RFWr = 0;
		end
		else if (Op == 6'b000000 && Funct == 6'b011011)	begin	//divu
			NPC_Sel = 0;
			MDU_Sel = 4;
			Start = 1;
			DMWr = 0;
			RFWr = 0;
		end
		else if (Op == 6'b000000 && Funct == 6'b010011)	begin	//mtlo
			NPC_Sel = 0;  
			MDU_Sel = 5;
			Start = 0;
			DMWr = 0;  
			RFWr = 0;
		end
		else if (Op == 6'b000000 && Funct == 6'b010001)	begin	//mthi
			NPC_Sel = 0;  
			MDU_Sel = 6;
			Start = 0;
			DMWr = 0;  
			RFWr = 0;
		end
		else if (Op == 6'b000000 && Funct == 6'b010010) begin	//mflo
			NPC_Sel = 0;
			RF_Sel = 0;
			MDU_Sel = 0;
			MDU_RD_Sel = 0;
			Start = 0;
			ALU_MDU_Sel = 1;
			DMWr = 0; 
			RF_Data_Sel = 0;
			RFWr = 1;
		end
		else if (Op == 6'b000000 && Funct == 6'b010000) begin	//mfhi
			NPC_Sel = 0;
			RF_Sel = 0;
			MDU_Sel = 0;
			MDU_RD_Sel = 1;
			Start = 0;
			ALU_MDU_Sel = 1;
			DMWr = 0; 
			RF_Data_Sel = 0;
			RFWr = 1;
		end
	end
endmodule