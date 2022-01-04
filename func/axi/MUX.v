module mux2
#(parameter width = 32)(
	input [width-1:0] In0,
	input [width-1:0] In1,
	input Op,
	output reg [width-1:0] Out
    );

	always @(*) begin
		case (Op)
			0: Out = In0;
			1: Out = In1;
		endcase
	end

endmodule
module mux4
#(parameter width = 32)(
	input [width-1:0] In0,
	input [width-1:0] In1,
	input [width-1:0] In2,
	input [width-1:0] In3,
	input [1:0] Op,
	output reg [width-1:0] Out
    );
	
	

	always @(*) begin
		case (Op)
			0: Out = In0;
			1: Out = In1;
			2: Out = In2;
			3: Out = In3;
		endcase
	end

endmodule
module mux8
#(parameter width = 32)(
	input [width-1:0] In0,
	input [width-1:0] In1,
	input [width-1:0] In2,
	input [width-1:0] In3,
	input [width-1:0] In4,
	input [width-1:0] In5,
	input [width-1:0] In6,
	input [width-1:0] In7,
	input [2:0] Op,
	output reg [width-1:0] Out
    );
	

	always @(*) begin
		case (Op)
			0: Out = In0;
			1: Out = In1;
			2: Out = In2;
			3: Out = In3;
			4: Out = In4;
			5: Out = In5;
			6: Out = In6;
			7: Out = In7;
		endcase
	end

endmodule
