module Timer(
    // Input signals
    in,
	in_valid,
	rst_n,
	clk,
    // Output signals
    out_valid
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [4:0] in;
input in_valid,	rst_n,	clk;
output logic out_valid;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [4:0] in_reg;
logic flag;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
always@(posedge clk or negedge rst_n) begin
	if(rst_n==0) begin
		out_valid<=0;
		in_reg <= 0;
		flag<= 0;
	end
	else begin
		if(in_valid) begin
			in_reg <= in-1;
			flag <= 1;
		end
		else begin
			
			if((in_reg==0) && flag) begin
				//in_reg<=31;
				out_valid <= 1;
				flag <= 0;
			end
			else begin
				if(in_reg != 0)	in_reg <= in_reg-1;
				else	in_reg <= 1'b0;
				out_valid <= 0;
			end
		end
	end
end



endmodule
