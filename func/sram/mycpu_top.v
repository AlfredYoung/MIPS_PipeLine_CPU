module mycpu_top(
    input         clk,
    input         resetn,
	input [5:0]   ext_int,
    // inst sram interface
    output        inst_sram_en,
    output [ 3:0] inst_sram_wen,
    output [31:0] inst_sram_addr,
    output [31:0] inst_sram_wdata,
    input  [31:0] inst_sram_rdata,
    // data sram interface
    output        data_sram_en,
    output [ 3:0] data_sram_wen,
    output [31:0] data_sram_addr,
    output [31:0] data_sram_wdata,
    input  [31:0] data_sram_rdata,
    // trace debug interface
    output [31:0] debug_wb_pc,
    output [ 3:0] debug_wb_rf_wen,
    output [ 4:0] debug_wb_rf_wnum,
    output [31:0] debug_wb_rf_wdata
);
	wire rst;
	assign rst = !resetn;
	
   `define op 31:26
   `define funct 5:0
   `define imm26 25:0
   `define imm16 15:0
   `define rs 25:21
   `define rt 20:16
   `define rd 15:11
   `define s 10:6
   	wire [31: 0] PC;
  	wire [31: 0] NPC;
   	wire 		 PCWr;
	wire 		 PC_EXC_IF;
	wire 		 flush;

   	PC U_PC(
		   .clk			(clk			),		//时钟信号
		   .rst			(rst			),		//复位信号
		   .PCWr		(PCWr			),		//PCWr,程序计数器的写使能信号
		   .PC			(PC				),		//PC,取指用的地址
		   .NPC			(NPC			)		//NPC,下一条指令的地址
	); //程序计数器
	assign PC_EXC_IF = PC[0] | PC[1];			//地址错例外,AdEL
	assign inst_sram_en    = PCWr;				//取指使能
	assign inst_sram_wen   = 4'h0;				
	assign inst_sram_addr  = PC;				//取指地址
	assign inst_sram_wdata = 32'b0;
   	wire [31: 0] Instr;
	assign Instr = inst_sram_rdata & {32{!flush}};

   	wire [31: 0] PC_4 = PC + 4;
   	wire [31: 0] PC_8 = PC + 8;
	wire         delay;
   /******************************IF/ID级寄存器**********************************************/
	wire [31: 0] N_PC4_D = PC_4;
	wire [31: 0] N_PC8_D = PC_8;
	wire [31: 0] PC4_D;
	wire [31: 0] PC8_D;
	wire [31: 0] debug_pc_D;
	wire 		 FD_En;
	wire 		 inst_vaild;
	wire 		 Delay_Next;
	wire [31: 0] Instr_D = Instr & {32{!inst_vaild}};
   FD U_FD(	
	   		.clk			(clk			),		//时钟信号
		 	.rst			(rst			),		//复位信号
			.En				(FD_En			),		//FD级流水寄存器的使能信号
			.N_PC4_D		(N_PC4_D		),		//PC+4
			.N_PC8_D		(N_PC8_D		),		//PC+8
			.PC4_D			(PC4_D			),		//输出PC+4
			.PC8_D			(PC8_D			),		//输出PC+8
			.N_debug_pc_D	(PC				),		//用于测试的PC
			.debug_pc_D		(debug_pc_D		),		//输出用于测试的PC
			.PC_EXC_IF		(PC_EXC_IF		),		//IF级的例外，取指例外
			.PC_EXC_ID		(PC_EXC_ID		),		//ID级的输入例外，同上
			.flush			(flush			),		//flush信号，用于检测到例外后刷新流水线
			.inst_vaild		(inst_vaild		),		//inst_vaild信号用于检测到异常后，清除当前流水线指令
			.Delay_Next		(Delay_Next		),		//控制器产生的信号，用于标记j型指令和b型指令
			.delay			(delay			)		//延迟槽指令标记
	);

   	wire [ 2: 0] PC_Sel;
   	wire [ 1: 0] EXT_Sel;
   	wire [ 1: 0] RF_Sel;
   	wire [ 2: 0] NPC_Sel;
   	wire 		 syscall;
   	wire 		 break;
   	wire 		 reserve;
	wire 		 INT;
   	CTRL U_CTRL_D(	
		   	.Instr			(Instr_D		),		//ID级指令
	   		.PC_Sel			(PC_Sel			),		//PC_Sel信号，用以区分branch指令和jump指令
			.EXT_Sel		(EXT_Sel		),		//EXT_Sel信号，用以选择扩展器的功能
			.RF_Sel			(RF_Sel			),		//RF_Sel信号，用以选择写入寄存器号，0代表rd,1代表rt，2代表31
			.NPC_Sel		(NPC_Sel		),		//NPC_Sel信号，用以选择下一条指令地址
			.syscall		(syscall		),		//系统调用例外
			.break			(break			),		//断点例外
			.reserve		(reserve		),		//保留指令例外
			.Delay_Next		(Delay_Next		)		//j型指令和b型指令
	);
	wire [ 5: 0] ID_Out_EXC = {reserve,break,syscall,PC_EXC_ID,delay,INT};		//ID级例外
	wire [ 5: 0] EXE_In_EXC;

   	wire [ 4: 0] RF_A1 = Instr_D[`rs];
  	wire [ 4: 0] RF_A2 = Instr_D[`rt];
	wire [ 4: 0] RF_A3;
   	wire [31: 0] RF_WD;
   	wire [31: 0] RF_RD1;
   	wire [31: 0] RF_RD2;
   	wire RFWr;

	
   	RF U_RF(
		   .clk			(clk			),
		   .rst			(rst			),
		   .RFWr		(RFWr			),
		   .A1			(RF_A1			),
		   .A2			(RF_A2			),
		   .A3			(RF_A3			),
		   .WD			(RF_WD			),
		   .RD1			(RF_RD1			),
		   .RD2			(RF_RD2			)
	);
   	assign debug_wb_rf_wen = {4{RFWr}};
	assign debug_wb_rf_wnum = RF_A3;
    assign debug_wb_rf_wdata = RF_WD;
   	
	wire [31: 0] RS_D_MUX_In0 = RF_RD1;
	wire [31: 0] RS_D_MUX_In1;
	wire [31: 0] RS_D_MUX_In2;
	wire [31: 0] RS_D_MUX_In3;
	wire [31: 0] RS_D_MUX_In4;
	wire [31: 0] RS_D_MUX_In5;
	wire [31: 0] RS_D_MUX_In6;
	wire [ 2: 0] RS_D_MUX_Op;
	wire [31: 0] RS_D_MUX_Out;

   mux8 #(32) U_RS_D_MUX(
      	.In0			(RS_D_MUX_In0	),
		.In1			(RS_D_MUX_In1	),
		.In2			(RS_D_MUX_In2	),
		.In3			(RS_D_MUX_In3	),
		.In4			(RS_D_MUX_In4	),
		.In5			(RS_D_MUX_In5	),
		.In6			(RS_D_MUX_In6	),
		.Op				(RS_D_MUX_Op	),
		.Out			(RS_D_MUX_Out	)
   );

   	wire [31: 0] RT_D_MUX_In0 = RF_RD2;
	wire [31: 0] RT_D_MUX_In1;
	wire [31: 0] RT_D_MUX_In2;
	wire [31: 0] RT_D_MUX_In3;
	wire [31: 0] RT_D_MUX_In4;
	wire [31: 0] RT_D_MUX_In5;
	wire [31: 0] RT_D_MUX_In6;
	wire [ 2: 0] RT_D_MUX_Op;
	wire [31: 0] RT_D_MUX_Out;

   mux8 #(32) U_RT_D_MUX(
		.In0			(RT_D_MUX_In0	),
		.In1			(RT_D_MUX_In1	),
		.In2			(RT_D_MUX_In2	),
		.In3			(RT_D_MUX_In3	),
		.In4			(RT_D_MUX_In4	),
		.In5			(RT_D_MUX_In5	),
		.In6			(RT_D_MUX_In6	),
		.Op				(RT_D_MUX_Op	),
		.Out			(RT_D_MUX_Out	)
	);
   
   wire [15:0] EXT_In = Instr_D[`imm16];
   wire [31:0] EXT_Out;
   EXT U_EXT(
	   .In				(EXT_In			),
	   .Op				(EXT_Sel		),
	   .Out				(EXT_Out		)
	);

   wire [31: 0] Base = PC4_D;
   wire [31: 0] ImmB = EXT_Out;
   wire [25: 0] ImmJ = Instr_D[`imm26];
   wire [31: 0] Cmp1 = RS_D_MUX_Out;
   wire [31: 0] Cmp2 = RT_D_MUX_Out;
   wire [ 2: 0] CmpOp = PC_Sel;
   wire [31: 0] Branch;
   wire [31: 0] Jump;

   NPC U_NPC(
	   .PC				(Base			),
	   .ImmB			(ImmB			),
	   .ImmJ			(ImmJ			),
	   .Cmp1			(Cmp1			),
	   .Cmp2			(Cmp2			),
	   .CmpOp			(CmpOp			),
	   .Branch			(Branch			),
	   .Jump			(Jump			)
	);


    wire [ 4: 0] RF_A3_MUX_In0 = Instr_D[`rd];
	wire [ 4: 0] RF_A3_MUX_In1 = Instr_D[`rt];
	wire [ 4: 0] RF_A3_MUX_In2 = 31;
	wire [ 1: 0] RF_A3_MUX_Op  = RF_Sel;
	wire [ 4: 0] RF_A3_MUX_Out;

   mux4 #(5) U_RF_A3_MUX(
		.In0			(RF_A3_MUX_In0	),
		.In1			(RF_A3_MUX_In1	),
		.In2			(RF_A3_MUX_In2	),
		.Op				(RF_A3_MUX_Op	),
		.Out			(RF_A3_MUX_Out	)
	);
   
    wire [31: 0] PC_MUX_In0 = PC_4;
	wire [31: 0] PC_MUX_In1 = Branch;
	wire [31: 0] PC_MUX_In2 = Jump;
	wire [31: 0] PC_MUX_In3 = RS_D_MUX_Out;
	wire [ 2: 0] PC_MUX_Op  = NPC_Sel;
	wire [31: 0] PC_MUX_Out;

   	mux8 #(32) U_PC_MUX(
		.In0			(PC_MUX_In0		),
		.In1			(PC_MUX_In1		),
		.In2			(PC_MUX_In2		),
		.In3			(PC_MUX_In3		),
		.Op				(PC_MUX_Op		),
		.Out			(PC_MUX_Out		)
	);
	wire [31: 0]PC_WB_Out;
	mux2 #(32) U_NPC_MUX(
		.In0			(PC_MUX_Out		),
		.In1			(PC_WB_Out		),
		.Op				(flush			),
		.Out			(NPC			)
	);

   /*************************ID/EXE级寄存器*********************************/
    wire 		 DE_clear;
	wire [31: 0] N_Instr_E	= Instr_D;
	wire [31: 0] N_RS_E 	= RS_D_MUX_Out;
	wire [31: 0] N_RT_E 	= RT_D_MUX_Out;
	wire [31: 0] N_EXT_E 	= EXT_Out;
	wire [31: 0] N_PC8_E 	= PC8_D;
	wire [ 4: 0] N_WBA_E 	= RF_A3_MUX_Out;
	wire [31: 0] N_s_E 		= Instr_D[`s];
	wire [31: 0] Instr_E;
	wire [31: 0] RS_E;
	wire [31: 0] RT_E;
	wire [31: 0] EXT_E;
	wire [31: 0] PC8_E;
	wire [ 4: 0] WBA_E;
	wire [31: 0] s_E;
	wire [31: 0] debug_pc_E;
   	DE U_DE(
		.clk			(clk			),		//时钟信号
		.rst			(rst			),		//复位信号
		.clear			(DE_clear		),		//clear信号，当阻塞时清空ID_EX级流水寄存器的值
		.N_Instr_E		(N_Instr_E		),		//ID级指令
		.N_RS_E			(N_RS_E			),		//ID级RS输入
		.N_RT_E			(N_RT_E			),		//ID级RT输入
		.N_EXT_E		(N_EXT_E		),		//ID级符号扩展的结果
		.N_PC8_E		(N_PC8_E		),		//ID级的PC+8
		.N_WBA_E		(N_WBA_E		),		//ID级写入寄存器的编号
		.N_s_E			(N_s_E			),		//ID级指令的shamt字段
		.Instr_E		(Instr_E		),		//EX级指令
		.RS_E			(RS_E			),		//EX级RS输出
		.RT_E			(RT_E			),		//EX级RT输出
		.EXT_E			(EXT_E			),		//EX级符号扩展结果
		.PC8_E			(PC8_E			),		//EX级PC+8
		.WBA_E			(WBA_E			),		//EX级写入寄存器号
		.s_E			(s_E			),		//EX级shamt字段
		.N_debug_pc_E	(debug_pc_D		),		//ID级的PC
		.debug_pc_E		(debug_pc_E		),		//EX级的PC
		.ID_Out_EXC		(ID_Out_EXC		),		//ID级输出的例外
		.EXE_In_EXC		(EXE_In_EXC		),		//EX级输入的例外
		.flush			(flush			)		//flush信号，异常时清空流水线
	);
   	
    wire [ 3: 0] ALU_Sel;
	wire 		 ALU_A_Sel;
	wire 		 ALU_B_Sel;
	wire [ 2: 0] MDU_Sel;
	wire 		 Start;
	wire 		 MDU_RD_Sel;
	wire 		 ALU_MDU_Sel;
	wire 		 DM_wen;
	wire 		 DMWr;
	wire [ 1: 0] StoreType;
	wire 	 	 sign;
   	CTRL U_CTRL_E(
      .Instr			(Instr_E		),		//EX级指令
      .ALU_Sel			(ALU_Sel		),		//ALU_Sel,ALU功能选择信号
      .ALU_A_Sel		(ALU_A_Sel		),		//ALU_A_Sel,ALU的第一个操作数选择信号
      .ALU_B_Sel		(ALU_B_Sel		),		//ALU_B_Sel,ALU的第二个操作数的选择信号
	  .MDU_Sel			(MDU_Sel		),		//MDU_Sel,MDU的功能选择信号
	  .Start			(Start			),		//Start,标志MDU开始工作
	  .MDU_RD_Sel		(MDU_RD_Sel		),		//MDU_RD_Sel,MDU的读选择信号
	  .ALU_MDU_Sel		(ALU_MDU_Sel	),		//ALU_MDU_Sel,ALU和MDU的功能选择信号
	  .DMWr				(DM_wen			),		//数据存储器的写使能（指令决定部分）
	  .StoreType		(StoreType		),		//存储类型
	  .sign				(sign			)		//是否为有符号运算，用于判断溢出
   	);

   	wire [31: 0] RS_E_MUX_In0 = RS_E;
	wire [31: 0] RS_E_MUX_In1;
	wire [31: 0] RS_E_MUX_In2;
	wire [31: 0] RS_E_MUX_In3;
	wire [31: 0] RS_E_MUX_In4;
	wire [ 2: 0] RS_E_MUX_Op;
	wire [31: 0] RS_E_MUX_Out;

   mux8 #(32) U_RS_E_MUX(
		.In0			(RS_E_MUX_In0	),
		.In1			(RS_E_MUX_In1	),
		.In2			(RS_E_MUX_In2	),
		.In3			(RS_E_MUX_In3	),
		.In4			(RS_E_MUX_In4	),
		.Op				(RS_E_MUX_Op	),
		.Out			(RS_E_MUX_Out	)
	);

   	wire [31: 0] RT_E_MUX_In0 = RT_E;
	wire [31: 0] RT_E_MUX_In1;
	wire [31: 0] RT_E_MUX_In2;
	wire [31: 0] RT_E_MUX_In3;
	wire [31: 0] RT_E_MUX_In4;
	wire [ 2: 0] RT_E_MUX_Op;
	wire [31: 0] RT_E_MUX_Out;

   mux8 #(32) U_RT_E_MUX(
		.In0			(RT_E_MUX_In0	),
		.In1			(RT_E_MUX_In1	),
		.In2			(RT_E_MUX_In2	),
		.In3			(RT_E_MUX_In3	),
		.In4			(RT_E_MUX_In4	),
		.Op				(RT_E_MUX_Op	),
		.Out			(RT_E_MUX_Out	)
	);

    wire [31: 0] ALU_A_MUX_In0 = RS_E_MUX_Out;
	wire [31: 0] ALU_A_MUX_In1 = s_E;
	wire 		 ALU_A_MUX_Op  = ALU_A_Sel;
	wire [31: 0] ALU_A_MUX_Out;

   mux2 #(32) U_ALU_A_MUX(
		.In0			(ALU_A_MUX_In0	),
		.In1			(ALU_A_MUX_In1	),
		.Op				(ALU_A_MUX_Op	),
		.Out			(ALU_A_MUX_Out	)
	);

   	wire [31: 0] ALU_B_MUX_In0 = RT_E_MUX_Out;
	wire [31: 0] ALU_B_MUX_In1 = EXT_E;
	wire 		 ALU_B_MUX_Op  = ALU_B_Sel;
	wire [31: 0] ALU_B_MUX_Out;

   mux2 #(32) U_ALU_B_MUX(
		.In0			(ALU_B_MUX_In0	),
		.In1			(ALU_B_MUX_In1	),
		.Op				(ALU_B_MUX_Op	),
		.Out			(ALU_B_MUX_Out	)
	);

   /*ALU*/
    wire [31: 0] A 		= ALU_A_MUX_Out;
	wire [31: 0] B 		= ALU_B_MUX_Out;
	wire [ 3: 0] ALU_Op = ALU_Sel;
	wire [31: 0] ALU_Out;
	wire overflow;
   	ALU U_ALU(
		.A				(A				),
		.B				(B				),
		.Op				(ALU_Op			),
		.sign			(sign			),
		.Out			(ALU_Out		),
		.overflow		(overflow		)
	);

	wire [ 2: 0] MDU_Op = MDU_Sel;
	wire [31: 0] MDU_Out;
	wire		 Busy;
	wire [ 8: 0] MEM_Out_EXC;
	MDU MDU(
		.clk			(clk			),
		.rst			(rst			),
		.Start			(Start			),
		.Sel			(MDU_RD_Sel		),
		.A				(RS_E_MUX_Out	),
		.B				(RT_E_MUX_Out	),
		.Op				(MDU_Op			),
		.MEM_Out_EXC	(MEM_Out_EXC[7:0]),		//检测是否有例外，有例外则不将结果送入HI/LO寄存器
		.Out			(MDU_Out		),
		.Busy			(Busy			)
	);

	wire [31: 0] ALU_MDU_MUX_In0 = ALU_Out;
	wire [31: 0] ALU_MDU_MUX_In1 = MDU_Out;
	wire 		 ALU_MDU_MUX_Op  = ALU_MDU_Sel;
	wire [31: 0] ALU_MDU_MUX_Out;
	
	mux2 #(32) ALU_MDU_MUX(
		.In0			(ALU_MDU_MUX_In0),
		.In1			(ALU_MDU_MUX_In1),
		.Op				(ALU_MDU_MUX_Op	),
		.Out			(ALU_MDU_MUX_Out)
	);

	
	
	wire [31: 0] RT_M_MUX_In0 = RT_E_MUX_Out;
	wire [31: 0] RT_M_MUX_In1;
	wire 		 RT_M_MUX_Op;
	wire [31: 0] RT_M_MUX_Out;
	wire [31: 0] DM_A 		  = ALU_Out;
	wire [31: 0] DM_WD 		  = RT_M_MUX_Out;
	wire [31: 0] DM_RD;

	store_unit U_store_unit(
		.StoreType		(StoreType		),
		.addr			(DM_A			),
		.DMWr			(DMWr			),
		.MEM_Out_EXC	(MEM_Out_EXC[7:0]),
		.wdata			(RT_M_MUX_Out	),
		.sram_wen		(data_sram_wen	),
		.sram_wdata		(data_sram_wdata)
	);
	wire [ 1: 0] MEM_EXC;
	wire EXE_EXC = 	((Instr_E[`op] == 6'b101011) & DM_A[1:0] != 2'b00) | 
					((Instr_E[`op] == 6'b101001) & DM_A[0]   != 1'b0 );
	wire ERET;
	assign DMWr = DM_wen & !EXE_EXC & !ERET;	//数据存储器的写使能信号由指令、
												//WB级是否发生是ERET指令、
												//EX级的store指令是否发生例外决定
	assign data_sram_en   = 1'b1;
    assign data_sram_addr = {3'b0,DM_A[28:0]};
   	mux2 #(32) U_RT_M_MUX(
		.In0			(RT_M_MUX_In0	),
		.In1			(RT_M_MUX_In1	),
		.Op				(RT_M_MUX_Op	),
		.Out			(RT_M_MUX_Out	)
	);

	wire [6:0]EXE_Out_EXC = {overflow,EXE_In_EXC};	//EX新增溢出例外
	wire [6:0]MEM_In_EXC;
   /*************************************EXE/MEM级寄存器************************************/
	wire [31: 0] N_Instr_M 	= Instr_E;
	wire [31: 0] N_RT_M 	= RT_M_MUX_Out;
	wire [31: 0] N_ALU_M 	= ALU_MDU_MUX_Out;
	wire [31: 0] N_EXT_M 	= EXT_E;
	wire [31: 0] N_PC8_M 	= PC8_E;
	wire [ 4: 0] N_WBA_M 	= WBA_E;
	wire [31: 0] Instr_M;
	wire [31: 0] RT_M;
	wire [31: 0] ALU_M;
	wire [31: 0] EXT_M;
	wire [31: 0] PC8_M;
	wire [ 4: 0] WBA_M;
	wire [31: 0] debug_pc_M;
   	EM U_EM(
		.clk			(clk			),		//时钟信号
		.rst			(rst			),		//复位信号
		.N_Instr_M		(N_Instr_M		),		//E级指令
		.N_RT_M			(N_RT_M			),		//E级RT寄存器
		.N_ALU_M		(N_ALU_M		),		//E级ALU结果
		.N_EXT_M		(N_EXT_M		),		//E级符号扩展器结果
		.N_PC8_M		(N_PC8_M		),		//E级PC+8
		.N_WBA_M		(N_WBA_M		),		//E级写入寄存器编号
		.Instr_M		(Instr_M		),		//M级指令
		.RT_M			(RT_M			),		//M级RT
		.ALU_M			(ALU_M			),		//M级ALU结果
		.EXT_M			(EXT_M			),		//M级符号扩展结果
		.PC8_M			(PC8_M			),		//M级PC+8
		.WBA_M			(WBA_M			),		//M级写入寄存器编号
		.N_debug_pc_M	(debug_pc_E		),		//E级PC
		.debug_pc_M		(debug_pc_M		),		//M级PC
		.EXE_Out_EXC	(EXE_Out_EXC	),		//E级输出例外
		.MEM_In_EXC		(MEM_In_EXC		),		//M级输入例外
		.flush			(flush			)		//flush信号
	);
   
	wire [ 2: 0] LoadType;
   	wire [ 2: 0] RF_Data_Sel_M; 
	CTRL U_CTRL_M(
		.Instr			(Instr_M		),
		.LoadType		(LoadType		),
		.RF_Data_Sel	(RF_Data_Sel_M	)
	);

	load_unit U_load_unit(
		.LoadType		(LoadType		),
		.sram_rdata		(data_sram_rdata),
    	.addr			(ALU_M			),
    	.rdata			(DM_RD			)
	);
	assign MEM_EXC[0] = ((Instr_M[`op] == 6'b101011) & ALU_M[1:0] != 2'b00) | 
						((Instr_M[`op] == 6'b101001) & ALU_M[0] != 1'b0);
	assign MEM_EXC[1] = ((Instr_M[`op] == 6'b100011) & ALU_M[1:0] != 2'b00) |
						((Instr_M[`op] == 6'b100001 | Instr_M[`op] == 6'b100101) & ALU_M[0] != 1'b0);
	assign MEM_Out_EXC = {MEM_In_EXC[1],MEM_In_EXC[0],MEM_In_EXC[2],MEM_EXC,MEM_In_EXC[3],
							MEM_In_EXC[4],MEM_In_EXC[5],MEM_In_EXC[6]};
	assign ERET = (Instr_M == 32'b01000010000000000000000000011000);
	/*
	MEM_In_EXC[6] overflow
	MEM_In_EXC[5] reserve,
	MEM_IN_EXC[4] break,
	MEM_In_EXC[3] syscall,
	MEM_In_EXC[2] PC_EXC_ID,
	MEM_In_EXC[1] delay,
	MEM_In_EXC[0] INT
	*/
	/*
	MEM_Out_EXC[7] 延迟槽指令
	MEM_Out_EXC[6] PC取指错
	MEM_Out_EXC[5] Load地址错
	MEM_Out_EXC[4] Store地址错
	MEM_Out_EXC[3] syscall
	MEM_Out_EXC[2] break
	MEM_Out_EXC[1] 保留指令例外
	MEM_Out_EXC[0] overflow
	*/
	wire [31: 0] CP0_OUT;
	wire [31: 0] RF_WD_In0 = ALU_M;
	wire [31: 0] RF_WD_In1 = DM_RD;
	wire [31: 0] RF_WD_In2 = EXT_M;
	wire [31: 0] RF_WD_In3 = PC8_M;
	wire [ 2: 0] RF_WD_Op  = RF_Data_Sel_M;
	wire [31: 0] RF_WD_Out;

	mux8 #(32) RF_WD_MUX(
		.In0			(RF_WD_In0		),
		.In1			(RF_WD_In1		),
		.In2			(RF_WD_In2		),
		.In3			(RF_WD_In3		),
		.Op				(RF_WD_Op		),
		.Out			(RF_WD_Out		)
	);
   /*************************************MEM/WB级寄存器******************************************/

    wire [31: 0] N_Instr_W 	= Instr_M;
	wire [31: 0] N_ALU_W 	= ALU_M;
	wire [31: 0] N_DM_W 	= DM_RD;
	wire [31: 0] N_EXT_W 	= EXT_M;
	wire [31: 0] N_PC8_W 	= PC8_M;
	wire [ 4: 0] N_WBA_W 	= WBA_M;
	wire [31: 0] N_RT_W 	= RT_M;
	wire [31: 0] Instr_W;
	wire [31: 0] ALU_W;
	wire [31: 0] DM_W;
	wire [31: 0] EXT_W;
	wire [31: 0] PC8_W;
	wire [ 4: 0] WBA_W;
	wire [31: 0] debug_pc_W;
	wire [ 8: 0] WB_In_EXC;
	wire [31: 0] RT_W;
    MW U_MW(
		.clk			(clk			),		//时钟信号
		.rst			(rst			),		//复位信号
		.N_Instr_W		(N_Instr_W		),		//M级指令
		.N_ALU_W		(N_ALU_W		),		//M级ALU结果
		.N_DM_W			(N_DM_W			),		//M级读到的数据存储器内容
		.N_EXT_W		(N_EXT_W		),		//M级符号扩展器内容
		.N_PC8_W		(N_PC8_W		),		//M级PC+8
		.N_WBA_W		(N_WBA_W		),		//M级写回寄存器编号
		.Instr_W		(Instr_W		),		//W级指令
		.ALU_W			(ALU_W			),		//W级ALU结果
		.DM_W			(DM_W			),		//W级数据存储器内容
		.EXT_W			(EXT_W			),		//W级符号扩展器结果
		.PC8_W			(PC8_W			),		//W级PC+8
		.WBA_W			(WBA_W			),		//W级写回寄存器编号
		.N_debug_pc_W	(debug_pc_M		),		//M级PC
		.debug_pc_W		(debug_pc_W		),		//W级PC
		.MEM_Out_EXC	(MEM_Out_EXC	),		//M级输出例外
		.WB_In_EXC		(WB_In_EXC		),		//W级输入例外
		.N_RT_W			(N_RT_W			),		//M级RT寄存器
		.RT_W			(RT_W			),		//W级RT寄存器
		.flush			(flush			)		//flush信号
	);
   	wire [ 2: 0] RF_Data_Sel;
	wire 		 RF_wen;
	assign debug_wb_pc = debug_pc_W;
   	CTRL U_CTRL_W(
		.Instr			(Instr_W		),
		.RF_Data_Sel	(RF_Data_Sel	),
		.RFWr			(RF_wen			)
	);
	assign RFWr = (WB_In_EXC[7:0] == 8'b00000000) & RF_wen;
	/*CP0相关寄存器*/
	wire [15: 0] CP0_CONTROL;
	wire [31: 0] CP0D;
    wire [31: 0] CAUSE_OUT;
    wire [31: 0] BADADDR_OUT;
    wire [31: 0] STATUS_OUT;
    wire [31: 0] EPC_OUT;
	wire [31: 0] Count_OUT;
	wire [31: 0] Compare_OUT;
	wire 		 PC_Sel_W;
	wire 		 CP0DSel;
    wire[ 2: 0]  CP0OSel;
	wire 		 eret_flush;

   	wire [31: 0] RF_WD_MUX_In0 = ALU_W;
	wire [31: 0] RF_WD_MUX_In1 = DM_W;
	wire [31: 0] RF_WD_MUX_In2 = EXT_W;
	wire [31: 0] RF_WD_MUX_In3 = PC8_W;
	wire [31: 0] RF_WD_MUX_In4 = CP0_OUT;
	wire [ 2: 0] RF_WD_MUX_Op  = RF_Data_Sel;
	wire [31: 0] RF_WD_MUX_Out;

	mux8 #(32) GRF_WD_MUX(
		.In0			(RF_WD_MUX_In0	),
		.In1			(RF_WD_MUX_In1	),
		.In2			(RF_WD_MUX_In2	),
		.In3			(RF_WD_MUX_In3	),
		.In4			(RF_WD_MUX_In4	),
		.Op				(RF_WD_MUX_Op	),
		.Out			(RF_WD_MUX_Out	)
	);

   	assign RF_A3 = WBA_W;
	assign RF_WD = RF_WD_MUX_Out;

	/******************************CP0相关*************************************/
	//wire INT;
	mux2 U_CPOD_MUX(
		.In0				(ALU_W			),
		.In1				(RT_W			),
		.Op					(CP0DSel		),
		.Out				(CP0D			)
	);

	CP0_Control U_CP0_Control(
    	.inst_W				(Instr_W		),
    	.exception_reg		(WB_In_EXC		),
    	.CP0_CONTROL_BUS	(CP0_CONTROL	),
    	.flush				(flush			),	
    	.PC_Sel_W			(PC_Sel_W		),
		.CP0DSel			(CP0DSel		),
		.CP0OSel			(CP0OSel		)
	);
	
	CP0 U_CP0(
		.clk				(clk			),
    	.rst				(rst			),
    	.CP0_DATA_IN		(CP0D			),           
    	.CP0_PC_IN			(debug_pc_W		),             
    	.CP0_CONTROL		(CP0_CONTROL	),           
    	.Status_OUT			(STATUS_OUT		),          
    	.Cause_OUT			(CAUSE_OUT		),
    	.BadAddr_OUT		(BADADDR_OUT	),
    	.EPC_OUT			(EPC_OUT		),
		.Count_OUT			(Count_OUT		),
		.Compare_OUT		(Compare_OUT	),
		.INT 				(INT			)
	);

	mux8 U_CP0_O (
        .In0   				(EPC_OUT        ),            // Wire
        .In1   				(STATUS_OUT     ),            // Wire
        .In2   				(CAUSE_OUT      ),            // Wire
        .In3   				(BADADDR_OUT    ),            // Wire
		.In4				(Count_OUT		),
		.In5				(Compare_OUT    ),
        .Op        			(CP0OSel 		),            // CP0OSel
        .Out 				(CP0_OUT        )             // Wire : CP0_OUT
    );
	mux2 U_PC_WB(
		.In0				(32'hbfc00380	),
		.In1				(CP0_OUT		),
		.Op 				(PC_Sel_W		),
		.Out				(PC_WB_Out		)
	);
   /*******************************冒险检测单元******************************/
    wire [2:0] RS_D_MUXsel;
	wire [2:0] RT_D_MUXsel;
	wire [2:0] RS_E_MUXsel;
	wire [2:0] RT_E_MUXsel;
	wire RT_M_MUXsel;
	wire Stall;
   HZD U_HZD(
		.Instr_D			(Instr_D		),
		.Instr_E			(Instr_E		),
		.Instr_M			(Instr_M		),
		.Instr_W			(Instr_W		),
		.Busy				(Busy			),
		.Start				(Start			),
		.RS_D_Sel			(RS_D_MUXsel	),
		.RT_D_Sel			(RT_D_MUXsel	),
		.RS_E_Sel			(RS_E_MUXsel	),
		.RT_E_Sel			(RT_E_MUXsel	),
		.RT_M_Sel			(RT_M_MUXsel	),
		.Stall				(Stall			)
	);

    assign RS_D_MUX_In1 = EXT_E;
	assign RS_D_MUX_In2 = PC8_E;
	assign RS_D_MUX_In3 = ALU_M;
	assign RS_D_MUX_In4 = EXT_M;
	assign RS_D_MUX_In5 = PC8_M;
	assign RS_D_MUX_In6 = RF_WD_MUX_Out;
	assign RS_D_MUX_Op  = RS_D_MUXsel;
	
	//RT_D_MUX forward
	assign RT_D_MUX_In1 = EXT_E;
	assign RT_D_MUX_In2 = PC8_E;
	assign RT_D_MUX_In3 = ALU_M;
	assign RT_D_MUX_In4 = EXT_M;
	assign RT_D_MUX_In5 = PC8_M;
	assign RT_D_MUX_In6 = RF_WD_MUX_Out;
	assign RT_D_MUX_Op  = RT_D_MUXsel;
	
	//RS_E_MUX forward
	assign RS_E_MUX_In1 = ALU_M;
	assign RS_E_MUX_In2 = EXT_M;
	assign RS_E_MUX_In3 = PC8_M;
	assign RS_E_MUX_In4 = RF_WD_MUX_Out;
	assign RS_E_MUX_Op  = RS_E_MUXsel;
	
	//RT_E_MUX forward
	assign RT_E_MUX_In1 = ALU_M;
	assign RT_E_MUX_In2 = EXT_M;
	assign RT_E_MUX_In3 = PC8_M;
	assign RT_E_MUX_In4 = RF_WD_MUX_Out;
	assign RT_E_MUX_Op  = RT_E_MUXsel;
	
	//RT_M_MUX forward
	assign RT_M_MUX_In1 = RF_WD_Out;
	assign RT_M_MUX_Op  = RT_M_MUXsel;
	
	//stall
	assign PCWr = !Stall & !rst;
	assign FD_En = !Stall;
	assign DE_clear = Stall;

endmodule