// Code your design here
module Checkdigit(
    // Input signals
  	input [3:0] in_num,
	input in_valid,
	input rst_n,
	input clk,
    // Output signals
    output logic out_valid,
	output logic [3:0]out
);
//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [3:0] cnt = 0;
logic [5:0] in_temp;
logic [5:0] out_cal1,temp1,temp2;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
//deal with more than two bit
always@(*) begin
	if(in_num>= 5) in_temp = in_num *2-9; 
  	else in_temp =  in_num *2;
end
//multiply calculation

always@(posedge clk) begin
	temp1 <= out_cal1 + in_temp;
end
always@(posedge clk) begin
	temp2 <= out_cal1 + in_num;
end

always@(*) begin
	if(!rst_n) begin
		out_cal1 = 0;
	end
	else begin
		if(cnt == 0)	out_cal1 = 0;	
		else begin
			case(cnt[0])
				1'b0: out_cal1 = (temp2>=10)?(temp2-10):temp2;
				1'b1: out_cal1 = (temp1>=10)?(temp1-10):temp1;
			endcase
		end
	end
end
//output at the 15th rising clk
always@(*) begin
	if(!rst_n)	begin
		out_valid = 0;
		out = 0;
	end
	else if(cnt == 15) begin 
		out_valid = 1;
		if(out_cal1 == 0) out = 15;
		else	out = 10-out_cal1;
	end
	else begin	
		out_valid = 0;
		out = 0;
	end
end

//seq	//counter:count cycles
always@(posedge clk)begin
	if(in_valid) cnt <= cnt+1;
	else cnt <= 0;
end

endmodule