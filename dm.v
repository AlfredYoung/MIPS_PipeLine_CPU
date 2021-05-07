module dm_4k(
	input clk,
	input rst,
	input DMWr,
	input [1:0] StoreType,
	input [2:0] LoadType,
	input [31:0] addr,
	input [31:0] din,
	input [31:0] PC_M,
	output reg [31:0] dout
    );
	
	integer i;
	
	reg [31:0] dmem[1023:0];
	initial begin
		for (i = 0; i < 1024; i = i + 1)
			dmem[i] = 0;
	end
	always @(posedge clk) begin
		if (DMWr) begin
			case (StoreType)
				0:	dmem[addr[11:2]] = din;							//sw
				1:	case (addr[1])									//sh
						1'b0: dmem[addr[11:2]][15:0] = din[15:0];
						1'b1: dmem[addr[11:2]][31:16] = din[15:0];
					endcase
				2:	case (addr[1:0])								//sb
						2'b00: dmem[addr[11:2]][7:0] = din[7:0];
						2'b01: dmem[addr[11:2]][15:8] = din[7:0];
						2'b10: dmem[addr[11:2]][23:16] = din[7:0];
						2'b11: dmem[addr[11:2]][31:24] = din[7:0];
					endcase		
			endcase
		end
	end
	
	always @(*) begin
		case (LoadType)
			0:	dout = dmem[addr[11:2]];							//lw
			1:	case (addr[1])									//lh
					1'b0: dout = $signed(dmem[addr[11:2]][15:0]);
					1'b1: dout = $signed(dmem[addr[11:2]][31:16]);
				endcase
			2: 	case (addr[1])									//lhu
					1'b0: dout = dmem[addr[11:2]][15:0];
					1'b1: dout = dmem[addr[11:2]][31:16];
				endcase
			3:	case (addr[1:0])								//lb
					2'b00: dout = $signed(dmem[addr[11:2]][7:0]);
					2'b01: dout = $signed(dmem[addr[11:2]][15:8]);
					2'b10: dout = $signed(dmem[addr[11:2]][23:16]);
					2'b11: dout = $signed(dmem[addr[11:2]][31:24]);
				endcase
			4:	case (addr[1:0])								//lbu						
					2'b00: dout = dmem[addr[11:2]][7:0];
					2'b01: dout = dmem[addr[11:2]][15:8];
					2'b10: dout = dmem[addr[11:2]][23:16];
					2'b11: dout = dmem[addr[11:2]][31:24];
				endcase
		endcase
	end
	
endmodule
