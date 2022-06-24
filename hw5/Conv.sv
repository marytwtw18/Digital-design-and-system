module Conv(
  // Input signals
  clk,
  rst_n,
  image_valid,
  filter_valid,
  in_data,
  // Output signals
  out_valid,
  out_data
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
	input clk, rst_n, image_valid, filter_valid;
	input [3:0] in_data;
	output logic [15:0] out_data;
	output logic out_valid;

//---------------------------------------------------------------------
//   Your design                       
//---------------------------------------------------------------------
	logic out_valid_comb;
	logic signed [15:0] out_data_comb;
	
	logic signed [3:0] filter1 [5] ,filter1_reg [5]; //1*5
	logic signed [3:0] filter2 [5] ,filter2_reg [5]; //5*1
	logic signed [3:0] image[64] ,image_reg [64];
	logic signed [15:0] cov1[32] ,cov1_reg [32];
	logic signed [15:0] cov_final [16],cov_final_reg [16];
	
	integer i = 0;
	logic [7:0] cnt_reg = 0 ,cnt = 0;
//---------------------------------------------------------------------
//   State DECLARATION                         
//---------------------------------------------------------------------	
	
	logic [2:0] cur_state,nxt_state;
	parameter IDLE = 3'd0; 
	parameter INPUT= 3'd1;
	parameter COV1 = 3'd2;
	parameter COV2 = 3'd3;
	parameter OUT = 3'd4;
	
	
	//fsms
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) cur_state <= IDLE;
		else cur_state <= nxt_state;
	end
	
	//FSM part
	always@* begin
		//nxt state
		case(cur_state)
			IDLE: nxt_state = (image_valid || filter_valid)?INPUT:IDLE;
			INPUT: nxt_state = ((!image_valid) &&(!filter_valid))?COV1:INPUT;
			COV1: nxt_state = COV2;
			COV2: nxt_state = OUT;
			OUT: nxt_state = (cnt == 16)?IDLE:OUT;
			default: nxt_state =  cur_state;
		endcase
	end
	
	always@* begin
		case(cur_state)
			INPUT: cnt = cnt_reg + 1;
			OUT: cnt = cnt_reg + 1;
			default: cnt = 0;
		endcase
	end
	
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) cnt_reg <= 0;
		else cnt_reg <= cnt;
	end
	
	//filter1 filter2
	always@* begin
		case(cur_state)
			IDLE: begin
				if(filter_valid) begin
					for(i = 0;i < 5;i = i + 1) begin
						if(cnt == i) filter1[i] = in_data;
						else filter1[i] = 0;
						filter2[i] = 0;
					end
					for(i = 0;i < 64;i = i + 1) image[i] = 0;
				end
				else begin
					for(i = 0;i < 5;i = i + 1) begin
						filter1[i] = 0;
						filter2[i] = 0;
					end
					for(i = 0;i < 64;i = i + 1) image[i] = 0;
				end
			end
			INPUT: begin
				for(i = 0;i < 5;i = i + 1) begin
					if(cnt == i) filter1[i] = in_data;
					else filter1[i] = filter1_reg[i];
				end
				for(i = 0;i < 5;i = i + 1) begin
					if(cnt == i+5) filter2[i] = in_data;
					else filter2[i] = filter2_reg[i];
				end
				for(i = 0;i < 64;i = i + 1) begin
					if(cnt == i+10) image[i] = in_data;
					else image[i] = image_reg[i];	
				end
			end
			default: begin
				for(i = 0;i < 5;i = i + 1) begin
					filter1[i] = filter1_reg[i];
					filter2[i] = filter2_reg[i];
				end
				for(i = 0;i < 64;i = i + 1) image[i] = image_reg[i];
			end
		endcase
	end
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			for(i = 0;i < 5;i = i + 1) begin
				filter1_reg[i] <= 0;
				filter2_reg[i] <= 0;
			end
			for(i = 0;i < 64;i = i + 1) image_reg[i] <= 0;
		end
		else begin
			for(i = 0;i < 5;i = i + 1) begin
				filter1_reg[i] <= filter1[i];
				filter2_reg[i] <= filter2[i];
			end
			for(i = 0;i < 64;i = i + 1) image_reg[i] <= image[i];
		end
	end
	
	//second stage pipeline cov1
	always@* begin
		//nxt state
		case(cur_state)
			IDLE: begin
				for(i = 0;i < 32;i = i + 1) begin
					cov1[i] = 0;
				end
			end
			INPUT: begin
				for(i = 0;i < 32;i = i + 1) begin
					cov1[i] = 0;
				end
			end
			COV1: begin
				for(i = 0;i < 32;i = i + 1) begin
					cov1[i] = image_reg[((i/4)*8)+i % 4]*filter1_reg[0]+image_reg[((i/4)*8)+i % 4+1]*filter1_reg[1]+image_reg[((i/4)*8)+i % 4+2]*filter1_reg[2]+image_reg[((i/4)*8)+i % 4+3]*filter1_reg[3]+image_reg[((i/4)*8)+i % 4+4]*filter1_reg[4];
				end
			end
			
			COV2:begin
				for(i = 0;i < 32;i = i + 1) begin
					cov1[i] = cov1_reg[i];
				end
			end
			OUT: begin
				for(i = 0;i < 32;i = i + 1) begin
					cov1[i] = cov1_reg[i];
				end
			end
			default: begin
				for(i = 0;i < 32;i = i + 1) begin
					cov1[i] = 0;
				end
			end
		endcase
	end
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) for(i = 0;i < 32;i = i + 1) cov1_reg[i] <= 0;
		else for(i = 0;i < 32;i = i + 1) cov1_reg[i] <= cov1[i];
	end
	
	//third stage :cov final
	always@* begin
		//nxt state
		case(cur_state)
			IDLE: begin
				for(i = 0;i < 16;i = i + 1) begin
					cov_final[i] = 0;
				end
			end
			INPUT: begin
				for(i = 0;i < 16;i = i + 1) begin
					cov_final[i] = 0;
				end
			end
			COV1: begin
				for(i = 0;i < 16;i = i + 1) begin
					cov_final[i] = 0;
				end
			end
			COV2:begin
				for(i = 0;i < 16;i = i + 1) begin
					cov_final[i] = cov1_reg[((i/4)*4)+i % 4]*filter2_reg[0]+cov1_reg[((i/4)*4)+i%4+4]*filter2_reg[1]+cov1_reg[((i/4)*4)+i % 4+8]*filter2_reg[2]+cov1_reg[((i/4)*4)+i % 4+12]*filter2_reg[3]+cov1_reg[((i/4)*4)+i % 4+16]*filter2_reg[4];
				end
			end
			OUT: begin
				for(i = 0;i < 16;i = i + 1) begin
					cov_final[i] = cov_final_reg[i];
				end
			end
			default: begin
				for(i = 0;i < 16;i = i + 1) begin
					cov_final[i] = 0; //1s
				end
			end
		endcase
	end
	
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) for(i = 0;i < 16;i = i + 1) cov_final_reg[i] <= 0;
		else for(i = 0;i < 16;i = i + 1) cov_final_reg[i] <= cov_final[i];
	end
	
	//final output stage
	always@* begin
		case(cur_state)
			OUT: begin
				out_valid_comb = 1;
				out_data_comb = cov_final_reg[cnt_reg];
			end
			default: begin
				out_valid_comb = 0;
				out_data_comb = 0;
			end
		endcase
	end
	
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			out_data <= 0;
			out_valid <= 0;
		end
		else begin
			out_data <= out_data_comb;
			out_valid <= out_valid_comb;
		end
	end
endmodule
