module top#(parameter WIDTH=32,INST_WIDTH=32,REG_COUNT_BITS=5)(input clk,input reset,output [WIDTH-1:0] pc,output [INST_WIDTH-1:0] inst,
																					output [WIDTH-1:0] mem_addr,output [WIDTH-1:0] read_data,output [WIDTH-1:0] write_data);

//	wire [WIDTH-1:0] pc;
//	wire [INST_WIDTH-1:0] inst;
//	wire [WIDTH-1:0] mem_addr;
//	wire [WIDTH-1:0] read_data;
	wire mem_write;
	
	mips #(WIDTH,INST_WIDTH,REG_COUNT_BITS)mips(.clk(clk),
															  .reset(reset),
															  .pc(pc),
															  .inst(inst),
															  .mem_addr(mem_addr),
															  .read_data(read_data),
															  .mem_write(mem_write),
															  .write_data(write_data));
	imem imem(.addr(pc),.rd(inst));
	
	dmem dmem(.clk(clk),.addr(mem_addr),.rd(read_data),.we(mem_write),.wd(write_data));

endmodule

module top_tb;

	parameter WIDTH=32,INST_WIDTH=32,REG_COUNT_BITS=5;
	
	reg clk,reset;
	wire [WIDTH-1:0] pc,read_data,mem_addr;
	wire [INST_WIDTH-1:0] inst;
	
	top #(WIDTH,INST_WIDTH,REG_COUNT_BITS)top(.reset(reset),
															.clk(clk),
															.pc(pc),
															.read_data(read_data),
															.mem_addr(mem_addr),
															.inst(inst));
	
	initial
	begin
		reset = 0;#1;
		reset = 1;#1;
		reset = 0;#1;
	end
	
	always begin
		clk = 0;#1;
		clk = 1;#1;
	end
	

endmodule

