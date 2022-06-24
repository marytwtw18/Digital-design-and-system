module JAM(
  // Input signals
	clk,
	rst_n,
    in_valid,
    in_cost,
  // Output signals
	out_valid,
    out_job,
	out_cost
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
	input clk, rst_n, in_valid;
	input [6:0] in_cost;
	output logic out_valid;
	output logic [3:0] out_job; //output 8 cycles:8 values
	output logic [9:0] out_cost; //output 8 cycles:1 values
 
//---------------------------------------------------------------------
//   LOGIC and parameter DECLARATION
//---------------------------------------------------------------------
	logic [6:0] in[64],in_reg[64];
	logic [9:0] cost_comb,best_cost_comb,best_cost_reg;
	logic [2:0] dic_list_comb [8],dic_list_reg [8],best_list_comb[8], best_list_reg[8]; //output need to ++
	logic en;
	logic out_valid_comb;
	logic [3:0] out_job_comb;
	logic [9:0] out_cost_comb;
	integer i = 0;
	logic [5:0] cnt_reg = 0 ,cnt = 0;
	logic [2:0] pivot,temp,temp2,temp3;
	logic [2:0] swapnum,swapnum_index;
//---------------------------------------------------------------------
//   State DECLARATION                         
//---------------------------------------------------------------------	
	logic [1:0] cur_state,nxt_state;
	parameter IDLE = 2'd0; 
	parameter INPUT= 2'd1;
	parameter DIC = 2'd2;
	parameter OUT = 2'd3;
	
//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
	assign en = (((dic_list_reg[0] == 3'd7 && dic_list_reg[1] == 3'd6)&&(dic_list_reg[2] == 3'd5 && dic_list_reg[3] == 3'd4)) && ((dic_list_reg[4] == 3'd3 && dic_list_reg[5] == 3'd2)&&(dic_list_reg[6] == 3'd1 && dic_list_reg[7] == 3'd0)))?1:0;
	
	//fsms
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) cur_state <= IDLE;
		else cur_state <= nxt_state;
	end
	
	//FSM part
	always@* begin
		//nxt state
		case(cur_state)
			IDLE: nxt_state = in_valid?INPUT:IDLE;
			INPUT: nxt_state = (cnt == 63)?DIC:INPUT;
			DIC: nxt_state = en?OUT:DIC; //dic algo need 40320 cycles
			OUT: nxt_state = (cnt == 8)?IDLE:OUT;
			default: nxt_state =  cur_state;
		endcase
	end
	
	always@* begin
		case(cur_state)
			INPUT:cnt = cnt_reg + 1;
			OUT: cnt = cnt_reg + 1;
			default: cnt = 0;
		endcase
	end
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) cnt_reg <= 0;
		else cnt_reg <= cnt;
	end
	
	//input part: integer in[7:0][7:0],in_reg[7:0][7:0];
	always@* begin
		case(cur_state)
			IDLE: begin
				if(in_valid) begin
					for(i = 0;i < 64;i = i + 1) begin
						if(i == 0) in[i] = in_cost; //the first element
						else in[i] = 0;
					end
				end
				else for(i = 0;i < 64;i = i + 1) in[i] = 0;
			end
			INPUT: begin
				for(i = 0;i < 64;i = i + 1) begin
					if(cnt == i)  in[i] = in_cost;
					else in[i] = in_reg[i];
				end
			end
			default: begin
				for(i = 0;i < 64;i = i + 1) in[i] = in_reg[i];
			end
		endcase
	end
	
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) for(i = 0;i < 64;i = i + 1) in_reg[i] <= 0;
		else for(i = 0;i < 64;i = i + 1) in_reg[i] <= in[i];
	end
	
	//DIC ALGO part
	//logic [9:0] cost_comb,cost_reg,best_cost_comb,best_cost_reg;
	//logic [2:0] dic_list_comb [2:0],dic_list_reg [2:0],best_list_comb[2:0], best_list_reg[2:0]; //output need to ++
	//logic [2:0] pivot,right,tail;
	//logic [2:0] swapnum,swapnum_index;
	always@* begin
		//initial value(prevent latch)
		pivot = 7;
		swapnum = 7;
		swapnum_index = 7;
		temp = 0;
		temp2 = 0;
		temp3 = 0;
		case(cur_state)	
			IDLE: begin
				cost_comb = 0;
				best_cost_comb = 1023;
				for(i = 0;i < 8;i = i + 1)  begin
					dic_list_comb[i] = i;
					best_list_comb[i] = i; 
				end
			end
			DIC: begin
				for(i = 0;i < 8;i = i + 1)  begin
					dic_list_comb[i] = dic_list_reg[i];
					best_list_comb[i] = best_list_reg[i]; 
				end
				cost_comb = ((in_reg[dic_list_reg[0]]+in_reg[8+dic_list_reg[1]])+(in_reg[16+dic_list_reg[2]]+in_reg[24+dic_list_reg[3]]))+((in_reg[32+dic_list_reg[4]]+in_reg[40+dic_list_reg[5]])+(in_reg[48+dic_list_reg[6]]+in_reg[56+dic_list_reg[7]]));
				best_cost_comb = best_cost_reg;
				if(cost_comb < best_cost_reg) begin
					best_cost_comb = cost_comb;
					for(i = 0;i < 8;i = i + 1)  begin
						best_list_comb[i] = dic_list_reg[i];
					end
				end
				//find next dic order
				
				//find pivot
				if(dic_list_reg[6]<dic_list_reg[7]) pivot = 6;
				else if(dic_list_reg[5]<dic_list_reg[6]) pivot = 5;
				else if(dic_list_reg[4]<dic_list_reg[5]) pivot = 4;
				else if(dic_list_reg[3]<dic_list_reg[4]) pivot = 3;
				else if(dic_list_reg[2]<dic_list_reg[3]) pivot = 2;
				else if(dic_list_reg[1]<dic_list_reg[2]) pivot = 1;
				else if(dic_list_reg[0]<dic_list_reg[1]) pivot = 0;
				
				//find swapnum,swapnum_index
				case(pivot)
					7: begin
						swapnum = 7;
						swapnum_index = 7;
					end
					6:begin
						if(dic_list_reg[7]<=swapnum && dic_list_reg[7] > dic_list_reg[6]) begin
							swapnum = dic_list_reg[7];
							swapnum_index = 7;
						end
					end
					5:begin
						if(dic_list_reg[6]<=swapnum && dic_list_reg[6] > dic_list_reg[5]) begin
							swapnum = dic_list_comb[6];
							swapnum_index = 6;
							if(dic_list_reg[7]<=swapnum && dic_list_reg[7] > dic_list_reg[5]) begin
								swapnum = dic_list_reg[7];
								swapnum_index = 7;
							end
						end 
					end
					4:begin
						if(dic_list_reg[5]<=swapnum && dic_list_reg[5] > dic_list_reg[4]) begin
							swapnum = dic_list_reg[5];
							swapnum_index = 5;
							if(dic_list_reg[6]<=swapnum && dic_list_reg[6] > dic_list_reg[4]) begin
								swapnum = dic_list_comb[6];
								swapnum_index = 6;
								if(dic_list_reg[7]<=swapnum && dic_list_reg[7] > dic_list_reg[4]) begin
									swapnum = dic_list_reg[7];
									swapnum_index = 7;
								end
							end
						end
					end
					3:begin
						if(dic_list_reg[4]<=swapnum && dic_list_reg[4] > dic_list_reg[3]) begin
							swapnum = dic_list_reg[4];
							swapnum_index = 4;
							if(dic_list_reg[5]<=swapnum && dic_list_reg[5] > dic_list_reg[3]) begin
								swapnum = dic_list_reg[5];
								swapnum_index = 5;
								if(dic_list_reg[6]<=swapnum && dic_list_reg[6] > dic_list_reg[3]) begin
									swapnum = dic_list_reg[6];
									swapnum_index = 6;
									if(dic_list_reg[7]<=swapnum && dic_list_reg[7] > dic_list_reg[3]) begin
										swapnum = dic_list_reg[7];
										swapnum_index = 7;
									end
								end
							end
						end
					end
					2:begin
						if(dic_list_reg[3]<=swapnum && dic_list_reg[3] > dic_list_reg[2]) begin
							swapnum = dic_list_reg[3];
							swapnum_index = 3;
							if(dic_list_reg[4]<=swapnum && dic_list_reg[4] > dic_list_reg[2]) begin
								swapnum = dic_list_reg[4];
								swapnum_index = 4;
								if(dic_list_reg[5]<=swapnum && dic_list_reg[5] > dic_list_reg[2]) begin
									swapnum = dic_list_reg[5];
									swapnum_index = 5;
									if(dic_list_reg[6]<=swapnum && dic_list_reg[6] > dic_list_reg[2]) begin
										swapnum = dic_list_reg[6];
										swapnum_index = 6;
										if(dic_list_reg[7]<=swapnum && dic_list_reg[7] > dic_list_reg[2]) begin
											swapnum = dic_list_reg[7];
											swapnum_index = 7;
										end
									end
								end
							end
						end
					end
					1:begin
						if(dic_list_reg[2]<=swapnum && dic_list_reg[2] > dic_list_reg[1]) begin
							swapnum = dic_list_reg[2];
							swapnum_index = 2;
							if(dic_list_reg[3]<=swapnum && dic_list_reg[3] > dic_list_reg[1]) begin
								swapnum = dic_list_reg[3];
								swapnum_index = 3;
								if(dic_list_reg[4]<=swapnum && dic_list_reg[4] > dic_list_reg[1]) begin
									swapnum = dic_list_reg[4];
									swapnum_index = 4;
									if(dic_list_reg[5]<=swapnum && dic_list_reg[5] > dic_list_reg[1]) begin
										swapnum = dic_list_reg[5];
										swapnum_index = 5;
										if(dic_list_reg[6]<=swapnum && dic_list_reg[6] > dic_list_reg[1]) begin
											swapnum = dic_list_reg[6];
											swapnum_index = 6;
											if(dic_list_reg[7]<=swapnum && dic_list_reg[7] > dic_list_reg[1]) begin
												swapnum = dic_list_reg[7];
												swapnum_index = 7;
											end
										end
									end
								end
							end
						end
					end
					0:begin
						if(dic_list_reg[1]<=swapnum && dic_list_reg[1] > dic_list_reg[0]) begin
							swapnum = dic_list_reg[1];
							swapnum_index = 1;
							if(dic_list_reg[2]<=swapnum && dic_list_reg[2] > dic_list_reg[0]) begin
								swapnum = dic_list_reg[2];
								swapnum_index = 2;
								if(dic_list_reg[3]<=swapnum && dic_list_reg[3] > dic_list_comb[0]) begin
									swapnum = dic_list_reg[3];
									swapnum_index = 3;
									if(dic_list_reg[4]<=swapnum && dic_list_reg[4] > dic_list_reg[0]) begin
										swapnum = dic_list_reg[4];
										swapnum_index = 4;
										if(dic_list_reg[5]<=swapnum && dic_list_reg[5] > dic_list_reg[0]) begin
											swapnum = dic_list_reg[5];
											swapnum_index = 5;
											if(dic_list_reg[6]<=swapnum && dic_list_reg[6] > dic_list_reg[0]) begin
												swapnum = dic_list_reg[6];
												swapnum_index = 6;
												if(dic_list_reg[7]<=swapnum && dic_list_reg[7] > dic_list_reg[0]) begin
													swapnum = dic_list_reg[7];
													swapnum_index = 7;
												end
											end
										end
									end
								end
							end
						end
					end
				
				endcase
				
				//exchange
				temp = dic_list_comb[pivot];
				dic_list_comb[pivot] = dic_list_comb[swapnum_index];
				dic_list_comb[swapnum_index] = temp;
				
				//reorder
				case(pivot)
					5:begin
						temp = dic_list_comb[7];
						dic_list_comb[7] = dic_list_comb[6];
						dic_list_comb[6] = temp;
					end
					4:begin
						temp = dic_list_comb[7];
						dic_list_comb[7] = dic_list_comb[5];
						dic_list_comb[5] = temp;
					end
					3:begin
						temp = dic_list_comb[7];
						temp2 = dic_list_comb[6];
						dic_list_comb[7] = dic_list_comb[4];
						dic_list_comb[6] = dic_list_comb[5];
						dic_list_comb[5] = temp2;
						dic_list_comb[4] = temp;
					end
					2:begin
						temp = dic_list_comb[7];
						temp2 = dic_list_comb[6];
						dic_list_comb[7] = dic_list_comb[3];
						dic_list_comb[6] = dic_list_comb[4];
						dic_list_comb[4] = temp2;
						dic_list_comb[3] = temp;
					end
					1:begin
						temp = dic_list_comb[7];
						temp2 = dic_list_comb[6];
						temp3 = dic_list_comb[5];
						dic_list_comb[7] = dic_list_comb[2];
						dic_list_comb[6] = dic_list_comb[3];
						dic_list_comb[5] = dic_list_comb[4];
						dic_list_comb[4] = temp3;
						dic_list_comb[3] = temp2;
						dic_list_comb[2] = temp;
					end
					0: begin
						temp = dic_list_comb[7];
						temp2 = dic_list_comb[6];
						temp3 = dic_list_comb[5];
						dic_list_comb[7] = dic_list_comb[1];
						dic_list_comb[6] = dic_list_comb[2];
						dic_list_comb[5] = dic_list_comb[3];
						dic_list_comb[3] = temp3;
						dic_list_comb[2] = temp2;
						dic_list_comb[1] = temp;
					end
				endcase
			end
			default: begin
				cost_comb = 0;
				best_cost_comb = best_cost_reg;
				for(i = 0;i < 8;i = i + 1)  begin
					dic_list_comb[i] = dic_list_reg[i];
					best_list_comb[i] = best_list_reg[i]; 
				end
			end
		endcase
	end
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			best_cost_reg <= 1023;
			//cost_reg <= 0;
			for(i = 0;i < 8;i = i + 1)  begin
				dic_list_reg[i] <= i;
				best_list_reg[i] <= i; 
			end
		end
		else begin
			best_cost_reg <= best_cost_comb;
			//cost_reg <= cost_comb;
			for(i = 0;i < 8;i = i + 1)  begin
				dic_list_reg[i] <= dic_list_comb[i];
				best_list_reg[i] <= best_list_comb[i]; 
			end
		end
	end
	
	//final output part
	always@* begin
		case(cur_state)
			OUT: begin
				out_valid_comb = 1;
				out_cost_comb = best_cost_reg;
				out_job_comb = best_list_reg[cnt_reg]+1;
			end
			default: begin
				out_valid_comb = 0;
				out_cost_comb = 0;
				out_job_comb = 0;
			end
		endcase
	end
	
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			out_cost <= 0;
			out_valid <= 0;
			out_job <= 0;
		end
		else begin
			out_cost <= out_cost_comb;
			out_valid <= out_valid_comb;
			out_job <= out_job_comb;
		end
	end
	
endmodule