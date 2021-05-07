module mips( clk, rst );
   input   clk;
   input   rst;
	
   `define op 31:26
   `define funct 5:0
   `define imm26 25:0
   `define imm16 15:0
   `define rs 25:21
   `define rt 20:16
   `define rd 15:11
   `define s 10:6
   wire [31:0]PC;
   wire [31:0]NPC;
   wire PCWr;
	
   PC U_PC(.clk(clk),.rst(rst),.PCWr(PCWr),.PC(PC),.NPC(NPC)); //程序计数器

   wire [31:0]Instr;
   im_4k U_IM(.addr(PC),.dout(Instr));

   wire [31:0]PC_4 = PC + 4;
   wire [31:0]PC_8 = PC + 8;
	/*NPC*/
   /******************************IF/ID级寄存器**********************************************/
   wire [31:0] N_Instr_D = Instr;
	wire [31:0] N_PC4_D = PC_4;
	wire [31:0] N_PC8_D = PC_8;
	wire [31:0] Instr_D;
	wire [31:0] PC4_D;
	wire [31:0] PC8_D;
	wire FD_En;

   FD U_FD(.clk(clk),.rst(rst),.En(FD_En),.N_Instr_D(N_Instr_D),.N_PC4_D(N_PC4_D),.N_PC8_D(N_PC8_D),.Instr_D(Instr_D),.PC4_D(PC4_D),.PC8_D(PC8_D));

   wire [2:0]PC_Sel;
   wire [1:0]EXT_Sel;
   wire [1:0]RF_Sel;
   wire [2:0]NPC_Sel;
   CTRL U_CTRL_D(.Instr(Instr_D),.PC_Sel(PC_Sel),.EXT_Sel(EXT_Sel),.RF_Sel(RF_Sel),.NPC_Sel(NPC_Sel));

   wire[4:0] RF_A1 = Instr_D[`rs];
   wire[4:0] RF_A2 = Instr_D[`rt];
   wire[4:0] RF_A3;
   wire[31:0] RF_WD;
   wire[31:0] RF_RD1;
   wire[31:0] RF_RD2;
   wire RFWr;

   RF U_RF(.clk(clk),.rst(rst),.RFWr(RFWr),.A1(RF_A1),.A2(RF_A2),.A3(RF_A3),.WD(RF_WD),.RD1(RF_RD1),.RD2(RF_RD2));
   wire [31:0] RS_D_MUX_In0 = RF_RD1;
	wire [31:0] RS_D_MUX_In1;
	wire [31:0] RS_D_MUX_In2;
	wire [31:0] RS_D_MUX_In3;
	wire [31:0] RS_D_MUX_In4;
	wire [31:0] RS_D_MUX_In5;
	wire [31:0] RS_D_MUX_In6;
	wire [2:0] RS_D_MUX_Op;
	wire [31:0] RS_D_MUX_Out;

   mux8 #(32) U_RS_D_MUX(
      .In0(RS_D_MUX_In0),
		.In1(RS_D_MUX_In1),
		.In2(RS_D_MUX_In2),
		.In3(RS_D_MUX_In3),
		.In4(RS_D_MUX_In4),
		.In5(RS_D_MUX_In5),
		.In6(RS_D_MUX_In6),
		.Op(RS_D_MUX_Op),
		.Out(RS_D_MUX_Out)
   );

   wire [31:0] RT_D_MUX_In0 = RF_RD2;
	wire [31:0] RT_D_MUX_In1;
	wire [31:0] RT_D_MUX_In2;
	wire [31:0] RT_D_MUX_In3;
	wire [31:0] RT_D_MUX_In4;
	wire [31:0] RT_D_MUX_In5;
	wire [31:0] RT_D_MUX_In6;
	wire [2:0] RT_D_MUX_Op;
	wire [31:0] RT_D_MUX_Out;

   mux8 #(32) U_RT_D_MUX(
		.In0(RT_D_MUX_In0),
		.In1(RT_D_MUX_In1),
		.In2(RT_D_MUX_In2),
		.In3(RT_D_MUX_In3),
		.In4(RT_D_MUX_In4),
		.In5(RT_D_MUX_In5),
		.In6(RT_D_MUX_In6),
		.Op(RT_D_MUX_Op),
		.Out(RT_D_MUX_Out)
		);
   
   wire [15:0] EXT_In = Instr_D[`imm16];
   wire [31:0] EXT_Out;
   EXT U_EXT(.In(EXT_In),.Op(EXT_Sel),.Out(EXT_Out));

   wire [31:0]Base = PC4_D;
   wire [31:0]ImmB = EXT_Out;
   wire [25:0]ImmJ = Instr_D[`imm26];
   wire [31:0]Cmp1 = RS_D_MUX_Out;
   wire [31:0]Cmp2 = RT_D_MUX_Out;
   wire [2:0]CmpOp = PC_Sel;
   wire [31:0]Branch;
   wire [31:0]Jump;

   NPC U_NPC(.PC(Base),.ImmB(ImmB),.ImmJ(ImmJ),.Cmp1(Cmp1),.Cmp2(Cmp2),.CmpOp(CmpOp),.Branch(Branch),.Jump(Jump));


    wire [4:0] RF_A3_MUX_In0 = Instr_D[`rd];
	wire [4:0] RF_A3_MUX_In1 = Instr_D[`rt];
	wire [4:0] RF_A3_MUX_In2 = 31;
	wire [1:0] RF_A3_MUX_Op = RF_Sel;
	wire [4:0] RF_A3_MUX_Out;

   mux4 #(5) U_RF_A3_MUX(
		.In0(RF_A3_MUX_In0),
		.In1(RF_A3_MUX_In1),
		.In2(RF_A3_MUX_In2),
		.Op(RF_A3_MUX_Op),
		.Out(RF_A3_MUX_Out)
		);
   
    wire [31:0] PC_MUX_In0 = PC_4;
	wire [31:0] PC_MUX_In1 = Branch;
	wire [31:0] PC_MUX_In2 = Jump;
	wire [31:0] PC_MUX_In3 = RS_D_MUX_Out;
	wire [2:0] PC_MUX_Op = NPC_Sel;
	wire [31:0] PC_MUX_Out;

   mux8 #(32) U_PC_MUX(
		.In0(PC_MUX_In0),
		.In1(PC_MUX_In1),
		.In2(PC_MUX_In2),
		.In3(PC_MUX_In3),
		.Op(PC_MUX_Op),
		.Out(PC_MUX_Out)
		);
   assign NPC = PC_MUX_Out;

   /*************************ID/EXE级寄存器*********************************/
    wire DE_clear;
	wire [31:0] N_Instr_E = Instr_D;
	wire [31:0] N_RS_E = RS_D_MUX_Out;
	wire [31:0] N_RT_E = RT_D_MUX_Out;
	wire [31:0] N_EXT_E = EXT_Out;
	wire [31:0] N_PC8_E = PC8_D;
	wire [4:0] N_WBA_E = RF_A3_MUX_Out;
	wire [31:0] N_s_E = Instr_D[`s];
	wire [31:0] Instr_E;
	wire [31:0] RS_E;
	wire [31:0] RT_E;
	wire [31:0] EXT_E;
	wire [31:0] PC8_E;
	wire [4:0] WBA_E;
	wire [31:0] s_E;
   DE U_DE(
		.clk(clk),
		.rst(rst),
		.clear(DE_clear),
		.N_Instr_E(N_Instr_E),
		.N_RS_E(N_RS_E),
		.N_RT_E(N_RT_E),
		.N_EXT_E(N_EXT_E),
		.N_PC8_E(N_PC8_E),
		.N_WBA_E(N_WBA_E),
		.N_s_E(N_s_E),
		.Instr_E(Instr_E),
		.RS_E(RS_E),
		.RT_E(RT_E),
		.EXT_E(EXT_E),
		.PC8_E(PC8_E),
		.WBA_E(WBA_E),
		.s_E(s_E)
		);
   	
    wire [3:0] ALU_Sel;
	wire ALU_A_Sel;
	wire ALU_B_Sel;
	wire [2:0] MDU_Sel;
	wire Start;
	wire MDU_RD_Sel;
	wire ALU_MDU_Sel;
   CTRL U_CTRL_E(
      .Instr(Instr_E),
      .ALU_Sel(ALU_Sel),
      .ALU_A_Sel(ALU_A_Sel),
      .ALU_B_Sel(ALU_B_Sel),
	  .MDU_Sel(MDU_Sel),
	  .Start(Start),
	  .MDU_RD_Sel(MDU_RD_Sel),
	  .ALU_MDU_Sel(ALU_MDU_Sel)
   );

   wire [31:0] RS_E_MUX_In0 = RS_E;
	wire [31:0] RS_E_MUX_In1;
	wire [31:0] RS_E_MUX_In2;
	wire [31:0] RS_E_MUX_In3;
	wire [31:0] RS_E_MUX_In4;
	wire [2:0] RS_E_MUX_Op;
	wire [31:0] RS_E_MUX_Out;

   mux8 #(32) U_RS_E_MUX(
		.In0(RS_E_MUX_In0),
		.In1(RS_E_MUX_In1),
		.In2(RS_E_MUX_In2),
		.In3(RS_E_MUX_In3),
		.In4(RS_E_MUX_In4),
		.Op(RS_E_MUX_Op),
		.Out(RS_E_MUX_Out)
		);

   wire [31:0] RT_E_MUX_In0 = RT_E;
	wire [31:0] RT_E_MUX_In1;
	wire [31:0] RT_E_MUX_In2;
	wire [31:0] RT_E_MUX_In3;
	wire [31:0] RT_E_MUX_In4;
	wire [2:0] RT_E_MUX_Op;
	wire [31:0] RT_E_MUX_Out;

   mux8 #(32) U_RT_E_MUX(
		.In0(RT_E_MUX_In0),
		.In1(RT_E_MUX_In1),
		.In2(RT_E_MUX_In2),
		.In3(RT_E_MUX_In3),
		.In4(RT_E_MUX_In4),
		.Op(RT_E_MUX_Op),
		.Out(RT_E_MUX_Out)
		);

    wire [31:0] ALU_A_MUX_In0 = RS_E_MUX_Out;
	wire [31:0] ALU_A_MUX_In1 = s_E;
	wire ALU_A_MUX_Op = ALU_A_Sel;
	wire [31:0] ALU_A_MUX_Out;

   mux2 #(32) U_ALU_A_MUX(
		.In0(ALU_A_MUX_In0),
		.In1(ALU_A_MUX_In1),
		.Op(ALU_A_MUX_Op),
		.Out(ALU_A_MUX_Out)
		);

   wire [31:0] ALU_B_MUX_In0 = RT_E_MUX_Out;
	wire [31:0] ALU_B_MUX_In1 = EXT_E;
	wire ALU_B_MUX_Op = ALU_B_Sel;
	wire [31:0] ALU_B_MUX_Out;

   mux2 #(32) U_ALU_B_MUX(
		.In0(ALU_B_MUX_In0),
		.In1(ALU_B_MUX_In1),
		.Op(ALU_B_MUX_Op),
		.Out(ALU_B_MUX_Out)
		);

   /*ALU*/
    wire [31:0] A = ALU_A_MUX_Out;
	wire [31:0] B = ALU_B_MUX_Out;
	wire [3:0] ALU_Op = ALU_Sel;
	wire [31:0] ALU_Out;

   ALU U_ALU(
		.A(A),
		.B(B),
		.Op(ALU_Op),
		.Out(ALU_Out)
		);

	wire [2:0] MDU_Op = MDU_Sel;
	wire [31:0] MDU_Out;
	wire Busy;
	 
	MDU MDU(
		.clk(clk),
		.rst(rst),
		.Start(Start),
		.Sel(MDU_RD_Sel),
		.A(RS_E_MUX_Out),
		.B(RT_E_MUX_Out),
		.Op(MDU_Op),
		.Out(MDU_Out),
		.Busy(Busy)
		);

	wire [31:0] ALU_MDU_MUX_In0 = ALU_Out;
	wire [31:0] ALU_MDU_MUX_In1 = MDU_Out;
	wire ALU_MDU_MUX_Op = ALU_MDU_Sel;
	wire [31:0] ALU_MDU_MUX_Out;
	
	mux2 #(32) ALU_MDU_MUX(
		.In0(ALU_MDU_MUX_In0),
		.In1(ALU_MDU_MUX_In1),
		.Op(ALU_MDU_MUX_Op),
		.Out(ALU_MDU_MUX_Out)
		);
   
   /*************************************EXE/MEM级寄存器************************************/
	wire [31:0] N_Instr_M = Instr_E;
	wire [31:0] N_RT_M = RT_E_MUX_Out;
	wire [31:0] N_ALU_M = ALU_Out;
	wire [31:0] N_EXT_M = EXT_E;
	wire [31:0] N_PC8_M = PC8_E;
	wire [4:0] N_WBA_M = WBA_E;
	wire [31:0] Instr_M;
	wire [31:0] RT_M;
	wire [31:0] ALU_M;
	wire [31:0] EXT_M;
	wire [31:0] PC8_M;
	wire [4:0] WBA_M;

   EM U_EM(
		.clk(clk),
		.rst(rst),
		.N_Instr_M(N_Instr_M),
		.N_RT_M(N_RT_M),
		.N_ALU_M(N_ALU_M),
		.N_EXT_M(N_EXT_M),
		.N_PC8_M(N_PC8_M),
		.N_WBA_M(N_WBA_M),
		.Instr_M(Instr_M),
		.RT_M(RT_M),
		.ALU_M(ALU_M),
		.EXT_M(EXT_M),
		.PC8_M(PC8_M),
		.WBA_M(WBA_M)
		);
   
   wire DMWr;
	wire [1:0] StoreType;
	wire [2:0] LoadType;

   CTRL U_CTRL_M(
		.Instr(Instr_M),
		.DMWr(DMWr),
		.StoreType(StoreType),
		.LoadType(LoadType)
		);
   

   wire [31:0] RT_M_MUX_In0 = RT_M;
	wire [31:0] RT_M_MUX_In1;
	wire RT_M_MUX_Op;
	wire [31:0] RT_M_MUX_Out;
   
   mux2 #(32) U_RT_M_MUX(
		.In0(RT_M_MUX_In0),
		.In1(RT_M_MUX_In1),
		.Op(RT_M_MUX_Op),
		.Out(RT_M_MUX_Out)
		);
   
   
   wire [31:0] DM_A = ALU_M;
	wire [31:0] DM_WD = RT_M_MUX_Out;
	wire [31:0] DM_RD;
   dm_4k U_DM(
		.clk(clk),
		.DMWr(DMWr),
		.StoreType(StoreType),
		.LoadType(LoadType),
		.PC_M(PC8_M-8),
		.addr(DM_A),
		.din(DM_WD),
		.dout(DM_RD)
		);

   /*************************************EXE/WB级寄存器******************************************/

    wire [31:0] N_Instr_W = Instr_M;
	wire [31:0] N_ALU_W = ALU_M;
	wire [31:0] N_DM_W = DM_RD;
	wire [31:0] N_EXT_W = EXT_M;
	wire [31:0] N_PC8_W = PC8_M;
	wire [4:0] N_WBA_W = WBA_M;
	wire [31:0] Instr_W;
	wire [31:0] ALU_W;
	wire [31:0] DM_W;
	wire [31:0] EXT_W;
	wire [31:0] PC8_W;
	wire [4:0] WBA_W;

   MW U_MW(
		.clk(clk),
		.rst(rst),
		.N_Instr_W(N_Instr_W),
		.N_ALU_W(N_ALU_W),
		.N_DM_W(N_DM_W),
		.N_EXT_W(N_EXT_W),
		.N_PC8_W(N_PC8_W),
		.N_WBA_W(N_WBA_W),
		.Instr_W(Instr_W),
		.ALU_W(ALU_W),
		.DM_W(DM_W),
		.EXT_W(EXT_W),
		.PC8_W(PC8_W),
		.WBA_W(WBA_W)
		);
   
   assign PC_W = PC8_W - 8;
   wire [1:0] RF_Data_Sel;

   CTRL U_CTRL_W(
		.Instr(Instr_W),
		.RF_Data_Sel(RF_Data_Sel),
		.RFWr(RFWr)
		);

   wire [31:0] RF_WD_MUX_In0 = ALU_W;
	wire [31:0] RF_WD_MUX_In1 = DM_W;
	wire [31:0] RF_WD_MUX_In2 = EXT_W;
	wire [31:0] RF_WD_MUX_In3 = PC8_W;
	wire [1:0] RF_WD_MUX_Op = RF_Data_Sel;
	wire [31:0] RF_WD_MUX_Out;

	mux4 #(32) GRF_WD_MUX(
		.In0(RF_WD_MUX_In0),
		.In1(RF_WD_MUX_In1),
		.In2(RF_WD_MUX_In2),
		.In3(RF_WD_MUX_In3),
		.Op(RF_WD_MUX_Op),
		.Out(RF_WD_MUX_Out)
		);

   assign RF_A3 = WBA_W;
	assign RF_WD = RF_WD_MUX_Out;

   /*******************************冒险检测单元******************************/
    wire [2:0] RS_D_MUXsel;
	wire [2:0] RT_D_MUXsel;
	wire [2:0] RS_E_MUXsel;
	wire [2:0] RT_E_MUXsel;
	wire RT_M_MUXsel;
	wire Stall;
   HZD U_HZD(
		.Instr_D(Instr_D),
		.Instr_E(Instr_E),
		.Instr_M(Instr_M),
		.Instr_W(Instr_W),
		.Busy(Busy),
		.Start(Start),
		.RS_D_Sel(RS_D_MUXsel),
		.RT_D_Sel(RT_D_MUXsel),
		.RS_E_Sel(RS_E_MUXsel),
		.RT_E_Sel(RT_E_MUXsel),
		.RT_M_Sel(RT_M_MUXsel),
		.Stall(Stall)
		);

    assign RS_D_MUX_In1 = EXT_E;
	assign RS_D_MUX_In2 = PC8_E;
	assign RS_D_MUX_In3 = ALU_M;
	assign RS_D_MUX_In4 = EXT_M;
	assign RS_D_MUX_In5 = PC8_M;
	assign RS_D_MUX_In6 = RF_WD_MUX_Out;
	assign RS_D_MUX_Op = RS_D_MUXsel;
	
	//RT_D_MUX forward
	assign RT_D_MUX_In1 = EXT_E;
	assign RT_D_MUX_In2 = PC8_E;
	assign RT_D_MUX_In3 = ALU_M;
	assign RT_D_MUX_In4 = EXT_M;
	assign RT_D_MUX_In5 = PC8_M;
	assign RT_D_MUX_In6 = RF_WD_MUX_Out;
	assign RT_D_MUX_Op = RT_D_MUXsel;
	
	//RS_E_MUX forward
	assign RS_E_MUX_In1 = ALU_M;
	assign RS_E_MUX_In2 = EXT_M;
	assign RS_E_MUX_In3 = PC8_M;
	assign RS_E_MUX_In4 = RF_WD_MUX_Out;
	assign RS_E_MUX_Op = RS_E_MUXsel;
	
	//RT_E_MUX forward
	assign RT_E_MUX_In1 = ALU_M;
	assign RT_E_MUX_In2 = EXT_M;
	assign RT_E_MUX_In3 = PC8_M;
	assign RT_E_MUX_In4 = RF_WD_MUX_Out;
	assign RT_E_MUX_Op = RT_E_MUXsel;
	
	//RT_M_MUX forward
	assign RT_M_MUX_In1 = RF_WD_MUX_Out;
	assign RT_M_MUX_Op = RT_M_MUXsel;
	
	//stall
	assign PCWr = !Stall;
	assign FD_En = !Stall;
	assign DE_clear = Stall;

endmodule