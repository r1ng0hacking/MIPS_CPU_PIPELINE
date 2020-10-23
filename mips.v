module mips#(parameter WIDTH=32,INST_WIDTH=32,REG_COUNT_BITS=5)
				(input clk,input reset,output [WIDTH-1:0]pc,input [INST_WIDTH-1:0]inst,
				 output [WIDTH-1:0] mem_addr,input [WIDTH-1:0] read_data,output  mem_write,output [WIDTH-1:0]write_data);

	wire [2:0]alu_control_decode;
	wire reg_write_decode,reg_dst_decode,alu_src_decode,mem_to_reg_decode,beq_inst_decode,j_inst_decode;
	wire [INST_WIDTH-1:0] inst_decode;
	
	
	datapath #(WIDTH,INST_WIDTH,REG_COUNT_BITS)dp(.clk(clk),
																 .reset(reset),
																 .pc(pc),
																 .inst(inst),
																 .inst_decode(inst_decode),
																 .alu_control_decode(alu_control_decode),
																 .mem_addr(mem_addr),
																 .read_data(read_data),
																 .reg_write_decode(reg_write_decode),
																 .mem_write_decode(mem_write_decode),
																 .mem_write(mem_write),
																 .write_data(write_data),
																 .reg_dst_decode(reg_dst_decode),
																 .alu_src_decode(alu_src_decode),
																 .mem_to_reg_decode(mem_to_reg_decode),
																 .beq_inst_decode(beq_inst_decode),
																 .j_inst_decode(j_inst_decode));

	controller #(INST_WIDTH)ctl(.inst(inst_decode),
										 .alu_control(alu_control_decode),
										 .reg_write(reg_write_decode),
										 .mem_write(mem_write_decode),
										 .reg_dst(reg_dst_decode),
										 .alu_src(alu_src_decode),
										 .mem_to_reg(mem_to_reg_decode),
										 .beq_inst(beq_inst_decode),
										 .j_inst(j_inst_decode));
endmodule