module imem#(parameter WIDTH=32,N=6)(input [WIDTH-1:0] addr,output [WIDTH-1:0]rd);
	reg [WIDTH-1:0]ram[2**N-1:0];
	
	initial
		$readmemh("F:/Code/MIPS_CPU/imemfile.dat",ram);
	
	assign rd = ram[addr[WIDTH-1:2]];
endmodule

module imem_tb;

	parameter M=32,N=6;
	reg [M-1:0] addr;
	wire [M-1:0] rd;
	
	imem #(M,N)DUT(.addr(addr),.rd(rd));
	
	initial begin
		addr = 0;#1;
		$display("%h",rd);
		
		addr = 4;#1;
		$display("%h",rd);
		
		addr = 8;#1;
		$display("%h",rd);
	end

endmodule