
`include "synchronizer.v"
module D_FF(
	input D,
	input clk,
	input rst_n,
	output  logic Q
);
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) Q <= 0;
		else Q <= D;
	end
endmodule

module CDC(// Input signals
			clk_1,
			clk_2,
			in_valid,
			rst_n,
			in_a,
			mode,
			in_b,
		  //  Output signals
			out_valid,
			out
			);		
	input clk_1; 
	input clk_2;			
	input rst_n;
	input in_valid;
	input[3:0]in_a,in_b;
	input mode;
	output logic out_valid;
	output logic [7:0]out; 		

	logic [3:0] in_a_comb,in_b_comb,in_a_reg,in_b_reg;
	logic mode_comb,mode_reg;
	logic w1,w2,w3,w4;
	logic out_valid_comb;
	logic [7:0] out_comb;
//---------------------------------------------------------------------
//   your design  (Using synchronizer)       
// Example :
//logic P,Q,Y;
//synchronizer x5(.D(P),.Q(Y),.clk(clk_2),.rst_n(rst_n));           
//---------------------------------------------------------------------		
	//fsm state
	logic [1:0] cur_state,nxt_state;
	logic CDC_res;
	
	parameter IDLE = 2'd0; 
	parameter COMPUTE = 2'd1;
	parameter OUT = 2'd2;

	xor xor1(w1,in_valid,w2);
	D_FF D1(.D(w1),.clk(clk_1),.rst_n(rst_n),.Q(w2));
	synchronizer x5(.D(w2),.Q(w3),.clk(clk_2),.rst_n(rst_n));
	D_FF D2(.D(w3),.clk(clk_2),.rst_n(rst_n),.Q(w4));
	xor xor2(CDC_res,w3,w4);

	always@(posedge clk_2 or negedge rst_n) begin
		if(!rst_n) cur_state <= IDLE;
		else cur_state <= nxt_state;
	end
	
	//FSM part
	always@* begin
		//nxt state
		case(cur_state)
			IDLE: nxt_state = (CDC_res)?COMPUTE:IDLE;
			COMPUTE: nxt_state = OUT;
			OUT: nxt_state = IDLE;
			default: nxt_state =  cur_state;
		endcase
	end


	always@* begin
		if(in_valid) begin
			in_a_comb = in_a;
			in_b_comb = in_b;
			mode_comb = mode;
		end
		else begin
			in_a_comb = 0;
			in_b_comb = 0;
			mode_comb = 0;
		end
	end
	
	always@(posedge clk_1 or negedge rst_n) begin
		if(!rst_n) begin
			mode_reg <= 0;
			in_a_reg <= 0;
			in_b_reg <= 0;
		end
		else begin
			mode_reg <= mode_comb;
			in_a_reg <= in_a_comb;
			in_b_reg <= in_b_comb;
		end
	end
	
	always@* begin
		case(cur_state)
			IDLE: begin
				out_comb = 0;
				out_valid_comb = 0;
			end
			COMPUTE: begin 
				out_valid_comb = 1;
				if(!mode_reg) begin
					out_comb = in_a_reg + in_b_reg;
				end
				else begin //in_a * in_b
					out_comb = in_a_reg * in_b_reg;
				end
			end
			OUT: begin
				out_valid_comb = 0;
				out_comb = 0;
			end
			default: begin
				out_valid_comb = 0;
				out_comb = 0;
			end
		endcase
	end
	
	always@(posedge clk_2 or negedge rst_n) begin
		if(! rst_n) out_valid <= 0;
		else out_valid <= out_valid_comb;
	end
	
	always@(posedge clk_2 or negedge rst_n) begin
		if(! rst_n) out <= 0;
		else out <= out_comb;
	end		
endmodule