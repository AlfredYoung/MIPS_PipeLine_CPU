module ALU(
    input [31:0] A,
    input [31:0] B,
    input [3:0] Op,
    output reg [31:0] Out
);

always @(*) begin
    case(Op)
		0: Out = A + B;
		1: Out = A - B;
		2: Out = A & B;
		3: Out = A | B;
		4: Out = A ^ B;								//xor
		5: Out = ~(A | B);							//nor
		6: Out = B << A[4:0];						//sll
		7: Out = B >> A[4:0];						//srl
		8: Out = $signed(B) >>> A[4:0];				//sra
		9: Out = ($signed(A) < $signed(B)) ? 1 : 0;	//slt
		10: Out = (A < B) ? 1 : 0;					//sltu
    endcase	
end
endmodule