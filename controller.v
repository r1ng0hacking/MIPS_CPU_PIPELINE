module controller#(parameter INST_WIDTH=32)(input [INST_WIDTH-1:0]inst,
											 output reg  [2:0]alu_control,
											 output reg reg_write,
											 output reg mem_write,
											 output reg reg_dst,
											 output reg alu_src,
											 output reg mem_to_reg,
											 output reg beq_inst,
											 output reg j_inst);
	always @(*)begin
		case(inst[31:26])
		6'b100011: begin//lw
			alu_control = 3'b010;
			reg_write = 1'b1;
			mem_write = 1'b0;
			reg_dst = 1'b0;
			alu_src = 1'b1;
			mem_to_reg  = 1'b1;
			beq_inst = 1'b0;
			j_inst = 1'b0;
		end
		6'b001000: begin//addi
			alu_control = 3'b010;
			reg_write = 1'b1;
			mem_write = 1'b0;
			reg_dst = 1'b0;
			alu_src = 1'b1;
			mem_to_reg  = 1'b0;
			beq_inst = 1'b0;
			j_inst = 1'b0;
		end
		6'b101011:begin//sw
			alu_control = 3'b010;
			reg_write = 1'b0;
			mem_write = 1'b1;
			reg_dst = 1'b0;
			alu_src = 1'b1;
			mem_to_reg  = 1'b0;
			beq_inst = 1'b0;
			j_inst = 1'b0;
		end
		6'b000000:begin //R-type
			case(inst[5:0])
			6'b100000:begin 
				alu_control = 3'b010;//add
				reg_write = 1'b1;
				mem_write = 1'b0;
				reg_dst = 1'b1;
				alu_src = 1'b0;
				mem_to_reg  = 1'b0;
				beq_inst = 1'b0;
				j_inst = 1'b0;
			end
			6'b100010:begin
				alu_control = 3'b110;//sub
				reg_write = 1'b1;
				mem_write = 1'b0;
				reg_dst = 1'b1;
				alu_src = 1'b0;
				mem_to_reg  = 1'b0;
				beq_inst = 1'b0;
				j_inst = 1'b0;
			end
			6'b100100:begin 
				alu_control = 3'b000;//and
				reg_write = 1'b1;
				mem_write = 1'b0;
				reg_dst = 1'b1;
				alu_src = 1'b0;
				mem_to_reg  = 1'b0;
				beq_inst = 1'b0;
				j_inst = 1'b0;
			end
			6'b100101:begin 
				alu_control = 3'b001;//or
				reg_write = 1'b1;
				mem_write = 1'b0;
				reg_dst = 1'b1;
				alu_src = 1'b0;
				mem_to_reg  = 1'b0;
				beq_inst = 1'b0;
				j_inst = 1'b0;
			end
			6'b101010:begin
				alu_control = 3'b111;//slt
				reg_write = 1'b1;
				mem_write = 1'b0;
				reg_dst = 1'b1;
				alu_src = 1'b0;
				mem_to_reg  = 1'b0;
				beq_inst = 1'b0;
				j_inst = 1'b0;
			end
			default:begin
				alu_control = 3'b010;
				reg_write = 1'b0;
				mem_write = 1'b0;
				reg_dst = 1'b0;
				alu_src = 1'b0;
				mem_to_reg  = 1'b0;
				beq_inst = 1'b0;
				j_inst = 1'b0;
			end
			endcase
		end
		6'b000100:begin //beq
			alu_control = 3'b110;//sub
			reg_write = 1'b0;
			mem_write = 1'b0;
			reg_dst = 1'b0;
			alu_src = 1'b0;
			mem_to_reg  = 1'b0;
			beq_inst = 1'b1;
			j_inst = 1'b0;
		end
		6'b000010:begin //j
			alu_control = 3'b010;//sub
			reg_write = 1'b0;
			mem_write = 1'b0;
			reg_dst = 1'b0;
			alu_src = 1'b0;
			mem_to_reg  = 1'b0;
			beq_inst = 1'b0;
			j_inst = 1'b1;
		end
		default:begin
			alu_control = 3'b010;
			reg_write = 1'b0;
			mem_write = 1'b0;
			reg_dst = 1'b0;
			alu_src = 1'b0;
			mem_to_reg  = 1'b0;
			beq_inst = 1'b0;
			j_inst = 1'b0;
		end
		endcase
	end
endmodule