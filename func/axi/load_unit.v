module load_unit(
	input [2:0] LoadType,
	input [31:0] sram_rdata,
    input [31:0] addr,
    output [31:0] rdata
    );
    assign rdata =  (LoadType == 4 & addr[1:0] == 2'b00) ? {{24'b0},sram_rdata[7:0]}:
                    (LoadType == 4 & addr[1:0] == 2'b01) ? {{24'b0},sram_rdata[15:8]}:
                    (LoadType == 4 & addr[1:0] == 2'b10) ? {{24'b0},sram_rdata[23:16]}:
                    (LoadType == 4 & addr[1:0] == 2'b11) ? {{24'b0},sram_rdata[31:24]}:
                    (LoadType == 3 & addr[1:0] == 2'b00) ? {{24{sram_rdata[7]}},sram_rdata[7:0]}:
                    (LoadType == 3 & addr[1:0] == 2'b01) ? {{24{sram_rdata[15]}},sram_rdata[15:8]}:
                    (LoadType == 3 & addr[1:0] == 2'b10) ? {{24{sram_rdata[23]}},sram_rdata[23:16]}:
                    (LoadType == 3 & addr[1:0] == 2'b11) ? {{24{sram_rdata[31]}},sram_rdata[31:24]}:
                    (LoadType == 2 & addr[1] == 1'b0) ? {{16'b0},sram_rdata[15:0]}:
                    (LoadType == 2 & addr[1] == 1'b1) ? {{16'b0},sram_rdata[31:16]}:
                    (LoadType == 1 & addr[1] == 1'b0) ? {{16{sram_rdata[15]}},sram_rdata[15:0]}:
                    (LoadType == 1 & addr[1] == 1'b1) ? {{16{sram_rdata[31]}},sram_rdata[31:16]}:
                    sram_rdata;
endmodule