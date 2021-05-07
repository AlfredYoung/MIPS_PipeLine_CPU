module im_4k( addr, dout );
    
    input [31:0] addr;
    output [31:0] dout;
    
    reg [31:0] imem[1023:0];
    integer i;
    initial begin
        for(i = 0;i < 1024;i = i + 1)
            imem[i] = 0;
    end
    assign dout = imem[addr[11:2]];
    
endmodule    
