module datapath#(parameter WIDTH=32,INST_WIDTH=32,REG_COUNT_BITS=5)
					(input clk,input reset,output [WIDTH-1:0]pc,input [INST_WIDTH-1:0]inst,output [INST_WIDTH-1:0]inst_decode,
					input [2:0]alu_control_decode,output [WIDTH-1:0] mem_addr,input [WIDTH-1:0] read_data,input reg_write_decode,
					input mem_write_decode,output mem_write,
					output [WIDTH-1:0]write_data,
					input reg_dst_decode,
					input alu_src_decode,
					input mem_to_reg_decode,
					input beq_inst_decode,
					input j_inst_decode);

	wire [WIDTH-1:0]write_data_decode,write_data_execute,write_data_mem;
	reg [WIDTH-1:0]pc_branch;
	wire [WIDTH-1:0]pc_next;
	reg pc_jump;
	wire [WIDTH-1:0]pc_plus4,pc_plus4_decode,pc_plus4_execute;
	wire [WIDTH-1:0]rd1,rd2;
	wire [WIDTH-1:0]sign_imm;
	wire [WIDTH-1:0]alu_src_a_decode,alu_src_b_decode,alu_src_a_execute,alu_src_b_execute,alu_result_mem,alu_result_wb,read_data_wb;
	wire [WIDTH-1:0]alu_result;
	wire [REG_COUNT_BITS-1:0]dst_reg_decode,dst_reg_execute,dst_reg_mem,dst_reg_wb;//dst_reg --> register number;reg_dst --> mux select
	wire [WIDTH-1:0]wd3;
	wire [2:0]alu_control_execute;
	wire reg_write_execute,reg_write_mem,reg_write_wb;
	wire mem_write_execute,mem_write_mem;
	wire mem_to_reg_execute,mem_to_reg_mem,mem_to_reg_wb;
	wire [INST_WIDTH-1:0]inst_execute,inst_mem,inst_wb;
	reg [WIDTH-1:0]alu_src_a,alu_src_b;
	
	wire j_inst_execute,beq_inst_execute;
	reg fetch_enable,decode_enable,decode_clear,execute_clear,execute_clear1;
	
	reg forward_a_mem_decode,forward_a_wb_decode;
	reg forward_b_mem_decode,forward_b_wb_decode;
	
	wire forward_a_mem_execute,forward_a_wb_execute;
	wire forward_b_mem_execute,forward_b_wb_execute;
	
	adder #(WIDTH)addr_pc_plus4(.a(pc),.b(32'd4),.cin(1'b0),.s(pc_plus4));
	mux2 #(WIDTH)pc_next_mux(.d0(pc_plus4),.d1(pc_branch),.sel(pc_jump),.y(pc_next));
	//fetch pipeline register
	flopenrc #(WIDTH)pc_register(.clk(clk),.reset(reset),.clear(1'b0),.en(fetch_enable),.d(pc_next),.q(pc));
	
	//decode pipeline register
	flopenrc #(INST_WIDTH)inst_decode_ff(.clk(clk),.reset(reset),.clear(decode_clear),.en(decode_enable),.d(inst),.q(inst_decode));
	flopenrc #(WIDTH)pc_plus4_decode_ff(.clk(clk),.reset(reset),.clear(decode_clear),.en(decode_enable),.d(pc_plus4),.q(pc_plus4_decode));
	
	regfile #(REG_COUNT_BITS,WIDTH)rf(.clk(clk),.a1(inst_decode[25:21]),.a2(inst_decode[20:16]),.a3(dst_reg_wb),.wd3(wd3),.we3(reg_write_wb),.rd1(rd1),.rd2(rd2));
	signextend #(16,WIDTH)sign_extend(.a(inst_decode[15:0]),.y(sign_imm));
	assign alu_src_a_decode = rd1;
	mux2 #(32)alu_src_b_mux(.d0(rd2),.d1(sign_imm),.sel(alu_src_decode),.y(alu_src_b_decode));
	mux2 #(5)dst_reg_mux(.d0(inst_decode[20:16]),.d1(inst_decode[15:11]),.sel(reg_dst_decode),.y(dst_reg_decode));
	assign write_data_decode = rd2;
	//hazard
	always @(*)
	begin
		//data hazard(forward)
		if(reg_write_execute && dst_reg_execute == inst_decode[25:21] && inst_decode[25:21]!= 0 && mem_to_reg_execute == 0)begin		// mem -> exe,forward
			forward_a_mem_decode = 1'b1;
			forward_a_wb_decode  = 1'b0;
		end
		else if(reg_write_mem && dst_reg_mem == inst_decode[25:21] && inst_decode[25:21]!= 0)begin   //wb --> exe,forward
			forward_a_mem_decode = 1'b0;
			forward_a_wb_decode  = 1'b1;
		end
		else begin
			forward_a_mem_decode = 1'b0;
			forward_a_wb_decode  = 1'b0;
		end
		
		if(reg_write_execute && dst_reg_execute == inst_decode[20:16] && alu_src_decode == 0 && inst_decode[20:16] != 0 && mem_to_reg_execute == 0)begin// mem -> exe,forward
			forward_b_mem_decode = 1'b1;
			forward_b_wb_decode  = 1'b0;
		end
		else if(reg_write_mem && dst_reg_mem == inst_decode[20:16] && alu_src_decode == 0 && inst_decode[20:16]!= 0)begin   //wb --> exe,forward
			forward_b_mem_decode = 1'b0;
			forward_b_wb_decode  = 1'b1;
		end
		else begin
			forward_b_mem_decode = 1'b0;
			forward_b_wb_decode  = 1'b0;
		end
		//data hazard(stall)
		if((reg_write_execute && dst_reg_execute == inst_decode[25:21] && inst_decode[25:21]!= 0 && mem_to_reg_execute == 1)||
			(reg_write_execute && dst_reg_execute == inst_decode[20:16] && alu_src_decode == 0 && inst_decode[20:16] != 0 && mem_to_reg_execute == 1))begin
			fetch_enable = 1'b0;
			decode_enable = 1'b0;
			execute_clear = 1'b1;
		end
		else begin
			fetch_enable = 1'b1;
			decode_enable = 1'b1;
			execute_clear = 1'b0;		
		end
	end
	//execute pipeline register
	flopenrc #(WIDTH)pc_plus4_ex_ff(.clk(clk),.reset(reset),.clear(execute_clear || execute_clear1),.en(1'b1),.d(pc_plus4_decode),.q(pc_plus4_execute));
	flopenrc #(1)j_inst_mem_ex_ff(.clk(clk),.reset(reset),.clear(execute_clear|| execute_clear1),.en(1'b1),.d(j_inst_decode),.q(j_inst_execute));
	flopenrc #(1)beq_inst_mem_ex_ff(.clk(clk),.reset(reset),.clear(execute_clear|| execute_clear1),.en(1'b1),.d(beq_inst_decode),.q(beq_inst_execute));
	flopenrc #(1)forward_a_mem_ex_ff(.clk(clk),.reset(reset),.clear(execute_clear|| execute_clear1),.en(1'b1),.d(forward_a_mem_decode),.q(forward_a_mem_execute));
	flopenrc #(1)forward_b_mem_ex_ff(.clk(clk),.reset(reset),.clear(execute_clear|| execute_clear1),.en(1'b1),.d(forward_b_mem_decode),.q(forward_b_mem_execute));
	flopenrc #(1)forward_a_wb_ex_ff(.clk(clk),.reset(reset),.clear(execute_clear|| execute_clear1),.en(1'b1),.d(forward_a_wb_decode),.q(forward_a_wb_execute));
	flopenrc #(1)forward_b_wb_ex_ff(.clk(clk),.reset(reset),.clear(execute_clear|| execute_clear1),.en(1'b1),.d(forward_b_wb_decode),.q(forward_b_wb_execute));
	flopenrc #(INST_WIDTH)inst_ex_ff(.clk(clk),.reset(reset),.clear(execute_clear|| execute_clear1),.en(1'b1),.d(inst_decode),.q(inst_execute));
	flopenrc #(3)alu_control_ex_ff(.clk(clk),.reset(reset),.clear(execute_clear|| execute_clear1),.en(1'b1),.d(alu_control_decode),.q(alu_control_execute));
	flopenrc #(1)reg_write_ex_ff(.clk(clk),.reset(reset),.clear(execute_clear|| execute_clear1),.en(1'b1),.d(reg_write_decode),.q(reg_write_execute));
	flopenrc #(1)mem_write_ex_ff(.clk(clk),.reset(reset),.clear(execute_clear|| execute_clear1),.en(1'b1),.d(mem_write_decode),.q(mem_write_execute));
	flopenrc #(1)mem_to_reg_ex_ff(.clk(clk),.reset(reset),.clear(execute_clear|| execute_clear1),.en(1'b1),.d(mem_to_reg_decode),.q(mem_to_reg_execute));
	flopenrc #(WIDTH)alu_src_a_ex_ff(.clk(clk),.reset(reset),.clear(execute_clear|| execute_clear1),.en(1'b1),.d(alu_src_a_decode),.q(alu_src_a_execute));
	flopenrc #(WIDTH)alu_src_b_ex_ff(.clk(clk),.reset(reset),.clear(execute_clear|| execute_clear1),.en(1'b1),.d(alu_src_b_decode),.q(alu_src_b_execute));
	flopenrc #(WIDTH)write_data_ex_ff(.clk(clk),.reset(reset),.clear(execute_clear|| execute_clear1),.en(1'b1),.d(write_data_decode),.q(write_data_execute));
	flopenrc #(REG_COUNT_BITS)dst_reg_ex_ff(.clk(clk),.reset(reset),.clear(execute_clear|| execute_clear1),.en(1'b1),.d(dst_reg_decode),.q(dst_reg_execute));
	
	always @(*)
	begin
		//data hazard(forward)
		if(forward_a_mem_execute == 1'b1)begin
			alu_src_a = alu_result_mem;
		end
		else if(forward_a_wb_execute == 1'b1)begin
			alu_src_a = wd3;
		end
		else begin
			alu_src_a = alu_src_a_execute;
		end
		
		if(forward_b_mem_execute == 1'b1)begin
			alu_src_b = alu_result_mem;
		end
		else if(forward_b_wb_execute == 1'b1)begin
			alu_src_b = wd3;
		end
		else begin
			alu_src_b = alu_src_b_execute;
		end
		
		//control hazard(flush)
		if(j_inst_execute)begin
			pc_branch = {pc_plus4_execute[31:28],inst_execute[25:0],1'b0,1'b0};
			pc_jump = 1'b1;
		end
		else if(beq_inst_execute && alu_src_b == alu_src_a)begin
			pc_branch = ({{16{inst_execute[15]}},inst_execute[15:0]}<<2) + pc_plus4_execute;
			pc_jump = 1'b1;
		end
		else begin
			pc_branch = 0;
			pc_jump = 1'b0;
		end

		if(pc_jump == 1'b1)begin
			decode_clear = 1'b1;
			execute_clear1 = 1'b1;
		end
		else begin
			decode_clear = 1'b0;
			execute_clear1 = 1'b0;
		end
	end
	alu #(WIDTH)alu(.a(alu_src_a),.b(alu_src_b),.f(alu_control_execute),.y(alu_result));

	//memory pipeline register
	flopenrc #(INST_WIDTH)inst_mem_ff(.clk(clk),.reset(reset),.clear(1'b0),.en(1'b1),.d(inst_execute),.q(inst_mem));
	flopenrc #(WIDTH)alu_result_mem_ff(.clk(clk),.reset(reset),.clear(1'b0),.en(1'b1),.d(alu_result),.q(alu_result_mem));
	flopenrc #(1)reg_write_mem_ff(.clk(clk),.reset(reset),.clear(1'b0),.en(1'b1),.d(reg_write_execute),.q(reg_write_mem));
	flopenrc #(1)mem_write_mem_ff(.clk(clk),.reset(reset),.clear(1'b0),.en(1'b1),.d(mem_write_execute),.q(mem_write_mem));
	flopenrc #(1)mem_to_reg_mem_ff(.clk(clk),.reset(reset),.clear(1'b0),.en(1'b1),.d(mem_to_reg_execute),.q(mem_to_reg_mem));
	flopenrc #(REG_COUNT_BITS)dst_reg_mem_ff(.clk(clk),.reset(reset),.clear(1'b0),.en(1'b1),.d(dst_reg_execute),.q(dst_reg_mem));
	flopenrc #(WIDTH)write_data_mem_ff(.clk(clk),.reset(reset),.clear(1'b0),.en(1'b1),.d(write_data_execute),.q(write_data_mem));
	assign mem_addr = alu_result_mem;
	assign write_data = write_data_mem;
	assign mem_write = mem_write_mem;
	
	//writeback pipeline register
	flopenrc #(INST_WIDTH)inst_wb_ff(.clk(clk),.reset(reset),.clear(1'b0),.en(1'b1),.d(inst_mem),.q(inst_wb));
	flopenrc #(WIDTH)alu_result_wb_ff(.clk(clk),.reset(reset),.clear(1'b0),.en(1'b1),.d(alu_result_mem),.q(alu_result_wb));
	flopenrc #(WIDTH)read_data_wb_ff(.clk(clk),.reset(reset),.clear(1'b0),.en(1'b1),.d(read_data),.q(read_data_wb));
	flopenrc #(1)reg_write_wb_ff(.clk(clk),.reset(reset),.clear(1'b0),.en(1'b1),.d(reg_write_mem),.q(reg_write_wb));
	flopenrc #(1)mem_to_reg_wb_ff(.clk(clk),.reset(reset),.clear(1'b0),.en(1'b1),.d(mem_to_reg_mem),.q(mem_to_reg_wb));
	flopenrc #(REG_COUNT_BITS)dst_reg_wb_ff(.clk(clk),.reset(reset),.clear(1'b0),.en(1'b1),.d(dst_reg_mem),.q(dst_reg_wb));
	
	mux2 #(32)mem_to_reg_mux(.d0(alu_result_wb),.d1(read_data_wb),.sel(mem_to_reg_wb),.y(wd3));
endmodule

