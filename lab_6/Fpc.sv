module Fpc(
// input signals
clk,
rst_n,
in_valid,
in_a,
in_b,
mode,
// output signals
out_valid,
out
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid, mode;
input [15:0] in_a, in_b;
output logic out_valid;
output logic [15:0] out;

//logic

//delete
logic [15:0] in_a_comb,in_b_comb;
logic [15:0] in_a_reg,in_b_reg;
logic [1:0] mode_comb,mode_reg;
logic signed [8:0] fra_acomb,fra_areg,fra_bcomb,fra_breg;
logic [15:0] mul_comb,mul_reg;
logic signed [9:0] sum_comb,sum_reg;
logic [8:0] float_comb,float_reg;
logic [7:0] shift;

logic [3:0] cnt,cnt_nxt;
logic out_valid_comb;
logic [15:0] out_comb;

//fsm state
logic [3:0] cur_state,nxt_state;
parameter IDLE = 4'd0; 
parameter IN = 4'd1;
parameter EXT = 4'd2;
parameter SHIFT = 4'd3;
parameter COMPLEMENT = 4'd4;
parameter ADD =4'd5;
parameter MUL =4'd6;
parameter CAL = 4'd7;
parameter DONE =4'd8;

logic [4:0] i = 0;

//---------------------------------------------------------------------
//   Your design                       
//---------------------------------------------------------------------
//FSM part
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) cur_state <= IDLE;
    else cur_state <= nxt_state;
end

always@* begin
	//nxt state
	case(cur_state)
		IDLE: nxt_state = in_valid?IN:IDLE;
		IN: nxt_state = EXT;
		EXT: nxt_state =mode_reg?MUL:SHIFT;
		SHIFT: nxt_state = COMPLEMENT;
		COMPLEMENT: nxt_state = ADD;
		ADD: nxt_state = CAL;
		MUL: nxt_state = DONE;
		CAL: nxt_state = DONE;
		DONE: nxt_state = IDLE;
		default: nxt_state = cur_state;
	endcase
end

//in_valid:readin data
//in_a_comb in_b_comb mode_comb
always@* begin
	case(in_valid)
		0: begin
			in_a_comb = in_a_reg;
			in_b_comb = in_b_reg;
			mode_comb = mode_reg;
		end
		1: begin
			in_a_comb = in_a;
			in_b_comb = in_b;
			mode_comb = mode;
		end
		default: begin
			in_a_comb = in_a_reg;
			in_b_comb = in_b_reg;
			mode_comb = mode_reg;
		end	
	endcase
end
//in_a_reg in_b_reg mode_reg
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
		in_a_reg <= 0;
		in_b_reg <= 0;
		mode_reg <= 0;
		fra_areg <= 0;
		fra_breg <= 0;
		sum_reg <= 0;
		float_reg <= 0;
		mul_reg <= 0;
	end
    else begin
		in_a_reg <= in_a_comb;
		in_b_reg <= in_b_comb;
		mode_reg  <= mode_comb;
		fra_areg <= fra_acomb;
		fra_breg <= fra_bcomb;
		sum_reg <= sum_comb;
		float_reg <= float_comb;
		mul_reg <= mul_comb;
	end
end
always@* begin
	//fra_acomb fra_bcomb shift
	case(cur_state)
		EXT: begin
			fra_acomb[8:7] = 1;
			fra_bcomb[8:7] = 1;
			fra_acomb[6:0] = in_a_reg[6:0];
			fra_bcomb[6:0] = in_b_reg[6:0];
			shift = 0;
		end
		SHIFT: begin
			if(in_a_reg[14:7] >= in_b_reg[14:7]) begin
				shift = in_a_reg[14:7] - in_b_reg[14:7];
				fra_bcomb = (fra_breg >> shift);
				fra_acomb = fra_areg;
			end
			else begin
				shift = in_b_reg[14:7] - in_a_reg[14:7];
				fra_acomb = (fra_areg >> shift);
				fra_bcomb = fra_breg;
			end
		end
		COMPLEMENT: begin
			//negative
			if(in_a_reg[15] || in_b_reg[15]) begin
				if(in_a_reg[15] && in_b_reg[15])begin 
					fra_acomb = ~fra_areg+1;
					fra_bcomb = ~fra_breg+1;
					shift =0;
				end
				else if(in_b_reg[15])begin
					fra_acomb = fra_areg;
					fra_bcomb = ~fra_breg+1;
					shift = 0;
				end
				else begin
					fra_acomb = ~fra_areg+1;
					fra_bcomb = fra_breg;
					shift =0;
				end
			end
			//sign all 0 
			else begin
				fra_acomb = fra_areg;
				fra_bcomb = fra_breg;
				shift = 0;
			end
		end
		default: begin
			fra_acomb = fra_areg;
			fra_bcomb = fra_breg;
			shift = 0;
		end
	endcase
	
	//mul_comb
	case(cur_state)
		MUL: mul_comb = fra_acomb * fra_bcomb;
		DONE: mul_comb = mul_reg;
		default: mul_comb = 0;
	endcase
	
	//sum_comb
	case(cur_state)
		ADD: sum_comb = fra_acomb + fra_bcomb;
		CAL: sum_comb = sum_reg;
		DONE: sum_comb = sum_reg;
		default:sum_comb = 0;
	endcase
	case(cur_state)
		CAL: begin
			if(sum_comb[9]) float_comb = ~sum_comb[8:0]+1;
			else float_comb = sum_comb[8:0];
			
		end
		default: float_comb = float_reg;
	endcase
	case(cur_state)
		DONE: begin
			if(!mode_reg) begin
				out_comb[15] = sum_reg[9];
				if(float_comb[8]) begin
					out_comb[14:7] = ((in_a_reg[14:7]>in_b_reg[14:7])?in_a_reg[14:7]:in_b_reg[14:7])+1;
					out_comb[6:0] = float_comb[7:1];
				end
				else if(float_comb[7]) begin
					out_comb[14:7] = ((in_a_reg[14:7]>in_b_reg[14:7])?in_a_reg[14:7]:in_b_reg[14:7]);
					out_comb[6:0] = float_comb[6:0];
				end
				else if(float_comb[6]) begin
					out_comb[14:7] = ((in_a_reg[14:7]>in_b_reg[14:7])?in_a_reg[14:7]:in_b_reg[14:7])-1;
					out_comb[6:0] = float_comb[5:0] << 1;
				end
				else if(float_comb[5]) begin
					out_comb[14:7] = ((in_a_reg[14:7]>in_b_reg[14:7])?in_a_reg[14:7]:in_b_reg[14:7])-2;
					out_comb[6:0] = float_comb[4:0] << 2;
				end
				else if(float_comb[4]) begin
					out_comb[14:7] = ((in_a_reg[14:7]>in_b_reg[14:7])?in_a_reg[14:7]:in_b_reg[14:7])-3;
					out_comb[6:0] = float_comb[3:0] << 3;
				end
				else if(float_comb[3]) begin
					out_comb[14:7] = ((in_a_reg[14:7]>in_b_reg[14:7])?in_a_reg[14:7]:in_b_reg[14:7])-4;
					out_comb[6:0] = float_comb[2:0] << 4;
				end
				else if(float_comb[2]) begin
					out_comb[14:7] = ((in_a_reg[14:7]>in_b_reg[14:7])?in_a_reg[14:7]:in_b_reg[14:7])-5;
					out_comb[6:0] = float_comb[1:0] << 5;
				end
				else begin
					out_comb[14:7] = ((in_a_reg[14:7]>in_b_reg[14:7])?in_a_reg[14:7]:in_b_reg[14:7])-6;
					out_comb[6:0] = float_comb[0] << 6;
				end
			end
			else begin
				out_comb[15] = ((in_a_reg[15]*~in_b_reg[15])|(~in_a_reg[15]*in_b_reg[15]));
				if(mul_comb[15]) begin
					out_comb[14:7] =  in_a_reg[14:7] + in_b_reg[14:7] - 126;
					out_comb[6:0] =  mul_comb[14:8];
				end
				else if(mul_comb[14]) begin
					out_comb[14:7] =  in_a_reg[14:7] + in_b_reg[14:7] - 127;
					out_comb[6:0] =  mul_comb[13:7];
				end
				else begin
					out_comb[14:7] =  in_a_reg[14:7] + in_b_reg[14:7] - 128;
					out_comb[6:0] =  mul_comb[12:6];
				end
			end
		end
		default: begin
			out_comb = 0;
		end
			
	endcase
end

always@* begin
	case(cur_state)
		DONE: begin
			out_valid_comb = 1;
		end
		default: begin
			out_valid_comb = 0;
		end
	endcase
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)	out_valid <= 0;
	else	out_valid <= out_valid_comb;
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)	out <= 0;
	else	out <= out_comb;
end


endmodule

