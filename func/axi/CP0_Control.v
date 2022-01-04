module CP0_Control(
    input [31:0] inst_W,
    input [8:0] exception_reg,
    output [15:0] CP0_CONTROL_BUS,
    output flush,
    output PC_Sel_W,
    output CP0DSel,
    output [2:0] CP0OSel
);
    `define rd 15 : 11
    //取指令操作码
        wire [5:0] op ;
        wire [4:0] sa ;
        wire [5:0] funct ;
        wire [4:0] rs ;
        wire [4:0] rt ;
        wire [4:0] rd ;
        assign op = inst_W[31:26] ;
        assign sa = inst_W[10:6] ;
        assign funct = inst_W[5:0] ;
        assign rs = inst_W[25:21] ;
        assign rt = inst_W[20:16] ;
        assign rd = inst_W[15:11] ;
        //实现指令列表
        wire inst_ADD , inst_ADDI , inst_ADDU , inst_ADDIU , inst_SUB , inst_SUBU ;
        wire inst_SLT , inst_SLTI , inst_SLTU , inst_SLTIU ;
        wire inst_DIV , inst_DIVU , inst_MULT , inst_MULTU ;
        wire inst_AND , inst_ANDI , inst_LUI , inst_NOR , inst_OR , inst_ORI , inst_XOR , inst_XORI ;
        wire inst_SLLV ,inst_SLL , inst_SRAV , inst_SRA , inst_SRLV , inst_SRL ;
        wire inst_BEQ , inst_BNE , inst_BGEZ , inst_BGTZ , inst_BLEZ , inst_BLTZ , inst_BGEZAL , inst_BLTZAL ;
        wire inst_J , inst_JAL , inst_JR , inst_JALR ;
        wire inst_MFHI , inst_MFLO , inst_MTHI , inst_MTLO ;
        wire inst_BREAK , inst_SYSCALL ;
        wire inst_LB , inst_LBU , inst_LH , inst_LHU , inst_LW , inst_SB , inst_SH ,inst_SW ;
        wire inst_ERET , inst_MFC0 , inst_MTC0 ;
        wire op_zero; // 操作码全 0
        wire sa_zero; // sa 域全 0
        assign op_zero = ~(|op);
        assign sa_zero = ~(|sa); 
        assign inst_ADD = op_zero & sa_zero & (funct == 6'b100000);//有符号加法（整形溢出例外）
        assign inst_ADDI = (op == 6'b001000);//有符号立即数加法（整形溢出例外）
        assign inst_ADDU = op_zero & sa_zero & (funct == 6'b100001);//无符号加法
        assign inst_ADDIU = (op == 6'b001001);//无符号立即数加法
        assign inst_SUB = op_zero & sa_zero & (funct == 6'b100010);//有符号减法（整形溢出例外）
        assign inst_SUBU = op_zero & sa_zero & (funct == 6'b100011);//无符号减法
        assign inst_SLT = op_zero & sa_zero & (funct == 6'b101010);//小于则置位
        assign inst_SLTI = (op == 6'b001010);//立即数小于置位
        assign inst_SLTU = op_zero & sa_zero & (funct == 6'b101011);//无符号小则置
        assign inst_SLTIU = (op == 6'b001011);//立即数无符号小于置位
        assign inst_DIV = op_zero & sa_zero & (funct == 6'b011010) & (rd == 5'b0);//有符号除法
        assign inst_DIVU = op_zero & sa_zero & (funct == 6'b011011) & (rd == 5'b0);//无符号除法
        assign inst_MULT = op_zero & sa_zero & (funct == 6'b011000) & (rd == 5'b0);//有符号乘法
        assign inst_MULTU = op_zero & sa_zero & (funct == 6'b011001) & (rd == 5'b0);//无符号乘法
        assign inst_AND = op_zero & sa_zero & (funct == 6'b100100);//与运算
        assign inst_ANDI = (op == 6'b001100);//立即数逻辑与
        assign inst_LUI = (op == 6'b001111) & (rs==5'd0);//立即数装载高半字节 
        assign inst_NOR = op_zero & sa_zero & (funct == 6'b100111);//或非运算
        assign inst_OR = op_zero & sa_zero & (funct == 6'b100101);//或运算
        assign inst_ORI = (op == 6'b001101);//立即数逻辑或
        assign inst_XOR = op_zero & sa_zero & (funct == 6'b100110);//异或运算
        assign inst_XORI = (op == 6'b001110);//立即数的逻辑异或
        assign inst_SLL = op_zero & (rs==5'd0) & (funct == 6'b000000);//逻辑左移
        assign inst_SLLV = op_zero & sa_zero & (funct == 6'b000100);//变量逻辑左移
        assign inst_SRA = op_zero & (rs==5'd0) & (funct == 6'b000011);//算术右移
        assign inst_SRAV = op_zero & sa_zero & (funct == 6'b000111);//变量算术右移
        assign inst_SRL = op_zero & (rs==5'd0) & (funct == 6'b000010);//逻辑右移
        assign inst_SRLV = op_zero & sa_zero & (funct == 6'b000110);//变量逻辑右移
        assign inst_BEQ = (op == 6'b000100); //判断相等跳转
        assign inst_BNE = (op == 6'b000101); //判断不等跳转
        assign inst_BGEZ = (op == 6'b000001) & (rt==5'd1);//大于等于 0 跳转
        assign inst_BGTZ = (op == 6'b000111) & (rt==5'd0);//大于 0 跳转
        assign inst_BLEZ = (op == 6'b000110) & (rt==5'd0);//小于等于 0 跳转
        assign inst_BLTZ = (op == 6'b000001) & (rt==5'd0);//小于 0 跳转
        assign inst_BGEZAL = (op == 6'b000001) & (rt == 5'b10001);//大于等于0跳转，并且保留PC+8
        assign inst_BLTZAL = (op == 6'b000001) & (rt == 5'b10000);//小于0跳转，并且保留PC+8
        assign inst_J = (op == 6'b000010);//无条件跳转
        assign inst_JAL = (op == 6'b000011);//无条件跳转，并保留PC+8
        assign inst_JALR = op_zero & (rt==5'd0) & (rd==5'd31)
         & sa_zero & (funct == 6'b001001); //跳转寄存器并链接
        assign inst_JR = op_zero & (rt==5'd0) & (rd==5'd0 )
         & sa_zero & (funct == 6'b001000); //跳转寄存器
        assign inst_MFLO = op_zero & (rs==5'd0) & (rt==5'd0)
         & sa_zero & (funct == 6'b010010); //从 LO 读取
        assign inst_MFHI = op_zero & (rs==5'd0) & (rt==5'd0)
         & sa_zero & (funct == 6'b010000); //从 HI 读取
        assign inst_MTLO = op_zero & (rt==5'd0) & (rd==5'd0)
         & sa_zero & (funct == 6'b010011); //向 LO 写数据
        assign inst_MTHI = op_zero & (rt==5'd0) & (rd==5'd0)
         & sa_zero & (funct == 6'b010001); //向 HI 写数据
        assign inst_BREAK = (op == 6'b000000) & (funct == 6'b001101);//系统自陷（断点例外）
        assign inst_SYSCALL = (op == 6'b000000) & (funct == 6'b001100);//SYSCALL（系统调用例外）
        assign inst_LB = (op == 6'b100000); //load 字节（符号扩展）
        assign inst_LBU = (op == 6'b100100); //load 字节（无符号扩展）
        assign inst_LH = (op == 6'b100001);//load半字（地址错例外）
        assign inst_LHU = (op == 6'b100101);//load半字（0拓展）（地址错例外）
        assign inst_LW = (op == 6'b100011); //从内存装载字（地址错例外）
        assign inst_SB = (op == 6'b101000); //向内存存储字节
        assign inst_SH = (op == 6'b101001);//向内存存储半字（地址错例外）
        assign inst_SW = (op == 6'b101011); //向内存存储字（地址错例外）
        assign inst_ERET = (op == 6'b010000) & (rs == 5'b10000) & (rt == 5'b0) & (rd == 5'b0) & sa_zero & (funct == 6'b011000);//ERET
        assign inst_MFC0 = (op == 6'b010000) & (rs == 5'b0) & sa_zero & (funct[5:3] == 3'b0);//向CP0取值
        assign inst_MTC0 = (op == 6'b010000) & (rs == 5'b00100) & sa_zero & (funct[5:3] == 3'b0);//向CP0存值 
        //指令分类
        wire cal_r ;//R型运算类指令
        wire cal_i ;//I型运算类指令）
        wire br_rs_al ;//跳转并链接（rs 31）
        wire jal_al ;//无条件跳转并链接(31)
        wire jalr_rs_al ;//无条件跳转并链接(rs 31)
        wire mfhi , mflo , mfc0  ;//数据转移指令
        wire load , store ;  //访存指令
        assign cal_r = inst_ADD | inst_ADDU | inst_SUB | inst_SUBU | inst_SLT | inst_SLTU | inst_AND | inst_NOR | inst_OR | inst_XOR | inst_SLLV
                     | inst_SLL | inst_SRAV | inst_SRA | inst_SRLV | inst_SRL ;
        assign cal_i = inst_ADDI | inst_ADDIU | inst_SLTI | inst_SLTIU | inst_ANDI | inst_ANDI | inst_LUI | inst_ORI | inst_XORI ;
        assign br_rs_al = inst_BGEZAL | inst_BLTZAL ;
        assign jal_al = inst_JAL ;
        assign jalr_rs_al = inst_JALR ;
        assign mfhi = inst_MFHI ;
        assign mflo = inst_MFLO ;
        assign mfc0 = inst_MFC0 ;
        assign load = inst_LB | inst_LBU | inst_LH | inst_LHU | inst_LW ;
        assign store = inst_SB | inst_SH | inst_SW ;  

    //六种例外信号
        wire BD ;//分支延迟槽指令例外信号
        wire  AdEL_PC ,AdEL_LD  , AdES , Sys , Bp , Rl ,Ov ,INT ,Exception_All;
        assign INT = exception_reg[7];
        assign BD = exception_reg[8] ;
        assign AdEL_PC = exception_reg[6] ; // 取指地址不对齐边界例外
        assign AdEL_LD = exception_reg[5] ; // 取指地址不对齐边界例外
        assign AdES = exception_reg[4] & (inst_SH | inst_SW);
        assign Sys = exception_reg[3] ;
        assign Bp = exception_reg[2] ;
        assign Rl = exception_reg[1] ;
        assign Ov = exception_reg[0] & (inst_ADD | inst_ADDI | inst_SUB ) ;
        assign Exception_All = AdEL_PC | AdEL_LD | AdES | Sys | Bp | Rl | Ov | INT;
        /*flush信号*/
        assign flush = (Exception_All | inst_ERET) ? 1 : 0;
       
        // CP0入口选择信号
        assign CP0DSel = inst_MTC0 ? 1'b1 : 1'b0 ;
        //CP0出口选择信号
        assign CP0OSel =  inst_W[`rd] == 5'b01011 ? 3'b101 :
                          inst_W[`rd] == 5'b01001 ? 3'b100 :
                          inst_W[`rd] == 5'b01000 ? 3'b011 :
                          inst_W[`rd] == 5'b01100 ? 3'b001 :
                          inst_W[`rd] == 5'b01101 ? 3'b010 :
                          (inst_W[`rd] == 5'b01110 | inst_ERET) ? 3'b000 :
                          3'b011 ;
        //CP0每个寄存器的使能信号 
        wire cp0_choice ;  
        wire badaddr_wden ;//虚地址写使能（只读）
        wire badaddr_choice ;
        wire Status_wden ;//status寄存器全局写使能（软件可读写）
        wire Status_EXL_wden ;//status寄存器EXL位硬件写使能
        wire Status_EXL_choice ;
        wire Cause_BD_wden ;
        wire Cause_BD_choice ;
        wire Cause_IP_10_wden ;
        wire Cause_ExcCode_wden ;
        wire [2:0] Cause_ExcCode_choice ;
        wire Epc_wden ;
        wire Count_wden;//Count寄存器的写使能
        wire Compare_wden;//Compare寄存器的写使能
        
        assign cp0_choice = Exception_All ? 1'b1 : 1'b0 ;
        assign badaddr_wden = AdEL_PC | AdEL_LD | AdES ;
        assign badaddr_choice = AdEL_LD | AdES ? 1'b1 : 1'b0 ;
        assign Status_wden = inst_MTC0 & inst_W[`rd] == 5'b01100 ;
        assign Status_EXL_choice = Exception_All ? 1'b1 : 1'b0 ; //例外选择进入例外级
        assign Status_EXL_wden = Exception_All | inst_ERET ;
        assign Cause_BD_wden = Exception_All ;
        //assign Status_IE_wden = interrupt ;//中断
        assign Cause_BD_choice = BD & Exception_All ? 1'b1 : 1'b0 ;
        assign Cause_IP_10_wden = inst_MTC0 & inst_W[`rd] == 5'b01101 ;
        assign Cause_ExcCode_wden = Exception_All ;
        assign Cause_ExcCode_choice = AdEL_PC | AdEL_LD ? 3'b001 :
                                      AdES ? 3'b010 :
                                      Sys ? 3'b011 :
                                      Bp ? 3'b100 :
                                      Rl ? 3'b101 :
                                      Ov ? 3'b110 : 3'b111 ;
        assign Epc_wden = inst_MTC0 & inst_W[`rd] == 5'b01110 | Exception_All ;
        assign Count_wden = inst_MTC0 & inst_W[`rd] == 5'b01001;
        assign Compare_wden = inst_MTC0 & inst_W[`rd] == 5'b01011;
        assign CP0_CONTROL_BUS = {Compare_wden,Count_wden,cp0_choice , badaddr_wden ,badaddr_choice ,Status_wden , Status_EXL_choice ,Status_EXL_wden ,Cause_BD_wden ,
                                  Cause_BD_choice ,Cause_IP_10_wden ,Cause_ExcCode_wden , Cause_ExcCode_choice[2:0] , Epc_wden};
        assign PC_Sel_W = inst_ERET ? 1'b1 : 1'b0 ;
        


endmodule