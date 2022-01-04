module store_unit(
    input [1:0] StoreType,
    input [31:0] addr,
    input DMWr,
    input [6:0]MEM_Out_EXC,
    input [31:0] wdata,
    output [31:0] sram_wen,
    output [31:0] sram_wdata
);
    wire [3:0]wen;
    wire cancel = (MEM_Out_EXC != 7'b0);
    assign wen =    (StoreType == 2 && addr[1:0] == 2'b00) ? {4'b0001}:
                    (StoreType == 2 && addr[1:0] == 2'b01) ? {4'b0010}:
                    (StoreType == 2 && addr[1:0] == 2'b10) ? {4'b0100}:
                    (StoreType == 2 && addr[1:0] == 2'b11) ? {4'b1000}:
                    (StoreType == 1 && addr[1] == 1'b0) ? {4'b0011}:
                    (StoreType == 1 && addr[1] == 1'b1) ? {4'b1100}:
                    {4'b1111};
    assign sram_wen = wen & {4{DMWr}} & {4{!cancel}};

    assign sram_wdata =     (StoreType == 2 && addr[1:0] == 2'b01) ? wdata << 8:
                            (StoreType == 2 && addr[1:0] == 2'b10) ? wdata << 16:
                            (StoreType == 2 && addr[1:0] == 2'b11) ? wdata << 24:
                            (StoreType == 1 && addr[1] == 1'b1) ? wdata << 16:
                            wdata;



endmodule