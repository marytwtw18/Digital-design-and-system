module Maxmin(
    // input signals
	in_num,
	in_valid,
	rst_n,
	clk,
	
    // output signals
    out_valid,
	out_max,
	out_min
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input [7:0] in_num;
input in_valid, rst_n, clk;
output logic out_valid;
output logic [7:0] out_max, out_min;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
	logic [3:0] cycle_reg;
	logic flag,flag2;
	logic [7:0] max_reg,min_reg;

//---------------------------------------------------------------------
//   Your design                        
//--------------------------------------------------------------------
	always@* begin
    if(in_valid) begin 
      if(in_num >out_max) begin
        max_reg = in_num;
      end
	  else max_reg = out_max;
    end
    else begin
       max_reg = 0;
    end
    
  end
  
   always@* begin
     if(in_valid) begin
       if(in_num < out_min) begin
         min_reg = in_num;
       end
	   else min_reg = out_min;
     end
     else begin
       min_reg = 255;
     end
  end
  
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      out_valid <= 0;
      out_max <= 0;
      out_min <= 255;
      cycle_reg<=14;
      flag <= 0;
      flag2 <= 0;
    end
    else begin
	  out_max <= max_reg;
	  out_min <= min_reg;
	  
      if(in_valid && !flag) begin
        cycle_reg<=13;	//15 cycle out_valid=1
        flag <= 1;
        flag2 <= 0;
      end
      else begin
        if(cycle_reg == 0) begin
          if(!out_valid && !flag2) out_valid <= 1;
          else begin 
            out_valid <= 0;
            flag2 <= 1;
          end
          flag <= 0;
        end
        else cycle_reg <= cycle_reg-1;
      end
      
    end
  end
  

endmodule