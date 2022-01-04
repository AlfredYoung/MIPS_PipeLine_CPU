module CP0(
    input clk,
    input rst,

    input [31:0] CP0_DATA_IN,           //数据输入端
    input [31:0] CP0_PC_IN,             //PC输入端
    input [15:0] CP0_CONTROL,           //CP0控制总线
    output [31: 0] Status_OUT,          
    output [31: 0] Cause_OUT,
    output [31: 0] BadAddr_OUT,
    output [31: 0] EPC_OUT,
    output [31: 0] Count_OUT,
    output [31: 0] Compare_OUT,
    output INT
);
    // EPC寄存器 32bit
    reg [31: 0] EPC;
    // BadVAddr寄存器 32bit
    reg [31: 0] BadVAddr;
    // Cause寄存器 14bit 其余全为0
    reg         Cause_BD;
    reg         Cause_TI;
    reg [5 : 0] Cause_IP_7_2;
    reg [1 : 0] Cause_IP_1_0;
    reg [4 : 0] Cause_ExcCode;
    // Status寄存器 10bit 其余全为0
    reg [7 : 0] Status_IM_7_0;
    reg         Status_EXL;
    reg         Status_IE;
    // Count寄存器，每两个周期自增1
    reg [31: 0] Count;
    reg         tick;
    // Compare寄存器，
    reg [31: 0] Compare; 

    // 读CP0
    assign Status_OUT  = { 9'b0, 1'b1,6'b0,Status_IM_7_0, 6'b0, Status_EXL, Status_IE };
    assign Cause_OUT   = { Cause_BD,15'b0, Cause_IP_7_2, Cause_IP_1_0, 1'b0, Cause_ExcCode, 2'b0 };
    assign BadAddr_OUT =   BadVAddr;
    assign EPC_OUT     =   EPC;
    assign Count_OUT   =   Count;
    assign Compare_OUT =   Compare;
    assign INT         =   ((Cause_IP_1_0 & Status_IM_7_0[1:0]) != 2'b00) & (Status_IE == 1'b1) & (Status_EXL == 1'b0);
    // 写CP0
    /*
        EPCINSel == 0   pc_in - 8
        EPCINSel == 1   data_in
    */
    wire [31: 0] CP0_IN;
    wire [31: 0] BadAddr_IN;
    wire [31: 0] BDPC;
    
    mux2 MBDPC (
        .In0        ( CP0_PC_IN          ),     // 当前指令的PC值
        .In1        ( CP0_PC_IN - 32'd4  ),     // 当前指令的前一PC值（延迟槽异常）
        .Op         ( CP0_CONTROL[6]     ),     // BD
        .Out        ( BDPC               )      // Wire : BDPC
    );
    
    mux2 MEPCIN (
        .In0        ( CP0_DATA_IN     ),        // Data
        .In1        ( BDPC            ),        // PC
        .Op         ( CP0_CONTROL[13] ),        // EPCINSel
        .Out        ( CP0_IN          )         // Wire : CP0_IN
    );
    
    mux2 MBADADDR (
        .In0    ( CP0_IN          ),
        .In1    ( CP0_DATA_IN     ),
        .Op     ( CP0_CONTROL[11] ),        // BADADDRINSel
        .Out    ( BadAddr_IN      )         // Wire : BadAddr_IN
    );
    
    
    always @(posedge clk)
    begin
        if(rst)
        begin
            EPC           <= 32'b0;
            BadVAddr      <= 32'b0;
            Cause_BD      <= 1'b0;
            Cause_TI      <= 1'b0;
            Cause_IP_7_2  <= 6'b0;
            Cause_IP_1_0  <= 2'b0;
            Cause_ExcCode <= 5'b0;
            Status_IM_7_0 <= 8'b0;
            //Status_EXL    <= 1'b0;
            Status_IE     <= 1'b0;
            Count         <= 32'b0;
            tick          <= 1'b0;
        end
        if(!rst)
            tick          <= ~tick;
        if (CP0_CONTROL[0])                     //  EPC_wen
        begin
            if(CP0_CONTROL[13] & Status_EXL)
                EPC <= EPC;
            else
                EPC <= CP0_IN;
        end
        if (CP0_CONTROL[12])                    //  BadAddr_wen
        begin
            BadVAddr <= BadAddr_IN;
        end
        if (CP0_CONTROL[10])                    // Status_wen
        begin
            Status_IM_7_0 <= CP0_IN[15: 8];
            //Status_EXL    <= CP0_IN[1];
            Status_IE     <= CP0_IN[0];
        end
        if (CP0_CONTROL[8])                     // Status_EXL_wen
        begin
            //Status_EXL    <= CP0_CONTROL[9];    // EXL_choice_Sel
        end
        if (CP0_CONTROL[5])                 // Cause_wen
        begin
            Cause_IP_1_0  <= CP0_IN[9 : 8];
        end
        if (CP0_CONTROL[7] & !Status_EXL)                 // Cause_BD_wen
        begin
            Cause_BD      <= CP0_CONTROL[6];     // cause_BD_Sel
        end
        if (CP0_CONTROL[4])                 // Cause_ExcCode_wen
        begin
            Cause_ExcCode <=    ( (Cause_IP_1_0 != 2'b00) & (Status_IE == 1'b1) & (Status_EXL == 1'b0)) ? 5'b00000 : 
                                ( CP0_CONTROL[3:1] == 3'b001) ? 5'b00100 :      // AdEL 0x04
                                ( CP0_CONTROL[3:1] == 3'b010) ? 5'b00101 :      // AdES 0x05
                                ( CP0_CONTROL[3:1] == 3'b011) ? 5'b01000 :      // Sys 0x08
                                ( CP0_CONTROL[3:1] == 3'b100) ? 5'b01001 :      // Bp 0x09
                                ( CP0_CONTROL[3:1] == 3'b101) ? 5'b01010 :      // RI 0x0a
                                ( CP0_CONTROL[3:1] == 3'b110) ? 5'b01100 :      // Ov 0x0c
                                5'b0;
        end
        if(CP0_CONTROL[14])
        begin
            Count          <= CP0_IN;  
        end
        if(!CP0_CONTROL[14] & tick)
        begin
            Count          <= Count + 1'b1;
        end
        if(CP0_CONTROL[15])
        begin
            Compare        <= CP0_IN; 
            Cause_TI       <= 1'b0;
        end
        if(!CP0_CONTROL[15] & Count == Compare)
        begin
            Cause_TI       <= 1'b1;
        end
    end
    always @(posedge clk) begin
        if(rst)
            Status_EXL     <= 1'b0;
        else if(CP0_CONTROL[8])
            Status_EXL     <= CP0_CONTROL[9];
        else if(CP0_CONTROL[10])
            Status_EXL     <= CP0_IN[1];
    end
endmodule