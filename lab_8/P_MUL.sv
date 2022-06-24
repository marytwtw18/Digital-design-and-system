module P_MUL(
    // input signals
	in_1,
	in_2,
	in_3,
	in_valid,
	rst_n,
	clk,
	
    // output signals
    out_valid,
	out
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [46:0] in_1, in_2;
input [47:0] in_3;
input in_valid, rst_n, clk;
output logic out_valid;
output logic [95:0] out;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------

	logic [47:0] A,in_3_reg;
	logic [47:0] A_reg,B_reg;
	logic [46:0] in_1_reg,in_2_reg;
	logic [95:0] temp1,temp2,temp3;
	logic [95:0] out_comb;
	logic in1,in2,in3;

	//the first pipeline
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			in_1_reg <= 0;
			in_2_reg <= 0;
			in_3_reg <= 0;
			in1 <= 0;
		end
		else begin
			in_1_reg <= in_1;
			in_2_reg <= in_2;
			in_3_reg <= in_3;
			in1 <= in_valid;
		end
	end
	
	always@* begin
		A = in_1_reg + in_2_reg;
	end
	
	//the second pipeline
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			A_reg <= 0;
			B_reg <= 0;
			in2 <= 0;
		end
		else begin
			A_reg <= A;
			B_reg <= in_3_reg;
			in2 <= in1;
		end
	end
	
	//Mulpliexer:3 parts
	logic [31:0] P1,P2,P3,P4,P5,P6,P7,P8,P9;
	logic [31:0] P1_reg,P2_reg,P3_reg,P4_reg,P5_reg,P6_reg,P7_reg,P8_reg,P9_reg;
	
	always@* begin
		P1 = A_reg[15:0] * B_reg[15:0];
		P2 = A_reg[15:0] * B_reg[31:16]; //<<16
		P3 = A_reg[15:0] * B_reg[47:32]; // <<32
		P4 = A_reg[31:16] * B_reg[15:0]; // <<16
		P5 = A_reg[31:16] * B_reg[31:16]; // << 32
		P6 = A_reg[31:16] * B_reg[47:32]; // <<48
		P7 = A_reg[47:32] * B_reg[15:0]; //<<32
		P8 = A_reg[47:32] * B_reg[31:16]; //<<48
		P9 = A_reg[47:32] * B_reg[47:32]; //64
	end
	
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			P1_reg <= 0;
			P2_reg <= 0;
			P3_reg <= 0;
			P4_reg <= 0;
			P5_reg <= 0;
			P6_reg <= 0;
			P7_reg <= 0;
			P8_reg <= 0;
			P9_reg <= 0;
			in3 <= 0;
		end
		else begin
			P1_reg <= P1;
			P2_reg <= P2;
			P3_reg <= P3;
			P4_reg <= P4;
			P5_reg <= P5;
			P6_reg <= P6;
			P7_reg <= P7;
			P8_reg <= P8;
			P9_reg <= P9;
			in3 <= in2;
		end
	end
	
	
	//FORTH STAGE PIPELINE
	always@* begin
		temp1 = P1_reg + (P2_reg << 16) + (P3_reg << 32);
		temp2 = (P4_reg<<16) + (P5_reg << 32) + (P6_reg << 48);
		temp3 = (P7_reg << 32) + (P8_reg <<48) + (P9_reg << 64);
	    out_comb = temp1 + temp2 + temp3;
	end
	
	
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n)begin
			out <= 0;
			out_valid <= 0;
		end
		else begin
			out <= out_comb;
			out_valid <= in3;
		end
	end
endmodule