module inter(
  // Input signals
  clk,
  rst_n,
  in_valid_1,
  in_valid_2,
  in_valid_3,
  data_in_1,
  data_in_2,
  data_in_3,
  ready_slave1,
  ready_slave2,
  // Output signals
  valid_slave1,
  valid_slave2,
  addr_out,
  value_out,
  handshake_slave1,
  handshake_slave2
);


//---------------------------------------------------------------------
//   PORT DECLARATION
//---------------------------------------------------------------------

input clk, rst_n, in_valid_1, in_valid_2, in_valid_3;
input [6:0] data_in_1, data_in_2, data_in_3; 
input ready_slave1, ready_slave2;
output logic valid_slave1, valid_slave2;
output logic [2:0] addr_out, value_out;
output logic handshake_slave1, handshake_slave2;
//---------------------------------------------------------------------
//   YOUR DESIGN
//---------------------------------------------------------------------


//---------------------------------------------------------------------
//   FSM state                      
//---------------------------------------------------------------------
parameter S_idle = 3'd0; 
parameter S_master1 = 3'd1;
parameter S_master2 = 3'd2;
parameter S_master3 = 3'd3;
parameter S_handshake = 3'd4;  

//---------------------------------------------------------------------
//   Your design                       
//---------------------------------------------------------------------
  logic [2:0] nxt_state;
  logic [2:0] out_cur_state;
  logic valid_slave1_comb,valid_slave2_comb;
  logic handshake_slave1_comb,handshake_slave2_comb;
  logic [2:0] addr_out_comb,value_out_comb;
  
  logic in1,in2,in3;
  logic slave1,slave2,slave3;
  logic [2:0] add1,add2,add3,data1,data2,data3;
  
  
  //FSM state
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
    	out_cur_state <= S_idle;
    end
    else begin
     	out_cur_state <= nxt_state;
    end
  end
  
  //for data record FF
  always@(posedge clk) begin
    case(out_cur_state)
    	S_idle: begin    
          slave1 <= data_in_1[6];
          add1 <= data_in_1[5:3];
          data1 <= data_in_1[2:0];
          slave2 <= data_in_2[6];
          add2 <= data_in_2[5:3];
          data2 <= data_in_2[2:0];
          slave3 <= data_in_3[6];
          add3 <= data_in_3[5:3];
          data3 <= data_in_3[2:0];
        end
        default: begin
          slave1 <= slave1;
          add1 <= add1;
          data1 <= data1;
          slave2 <= slave2;
          add2 <= add2;
          data2 <= data2;
          slave3 <= slave3;
          add3 <= add3;
          data3 <= data3;
        end	
    endcase 
  end
  
  //handshake
  always@(*) begin
  	case(out_cur_state)
    	S_idle: begin
        	handshake_slave1_comb = 0;
          	handshake_slave2_comb = 0;
        end
      	S_master1: begin
        	handshake_slave1_comb = 0;
          	handshake_slave2_comb = 0;
        end
        S_master2: begin
        	handshake_slave1_comb = 0;
          	handshake_slave2_comb = 0;
        end
        S_master3: begin
        	handshake_slave1_comb = 0;
          	handshake_slave2_comb = 0;
        end 
       	S_handshake: begin
        	if( valid_slave1_comb) begin
				handshake_slave1_comb = 1;
				handshake_slave2_comb = 0;
			end
          	else begin
				handshake_slave1_comb = 0;
				handshake_slave2_comb = 1;
			end
        end	
      	default: begin
        	handshake_slave1_comb = 0;
          	handshake_slave2_comb = 0;
        end
    endcase  
  end
  
  //load data
  always@(*) begin
  	case(out_cur_state)
    	S_idle: begin
        	addr_out_comb = 0;
          	value_out_comb = 0;       
        end
      	S_master1: begin
        	addr_out_comb = add1;
          	value_out_comb = data1;
        end
        S_master2: begin
        	addr_out_comb = add2;
          	value_out_comb = data2;
        end
        S_master3: begin
        	addr_out_comb = add3;
          	value_out_comb = data3;
        end 
       	S_handshake: begin
        	addr_out_comb = 0;
          	value_out_comb = 0;
        end	
      	default: begin
        	addr_out_comb = 0;
          	value_out_comb = 0;
        end
    endcase  
  end
  
  
  //change valid
  always@(*) begin
    case(out_cur_state)
    	S_idle: begin
        	valid_slave1_comb=0;
          	valid_slave2_comb=0;
        end
      	S_master1: begin
          if(slave1==0) begin 
			valid_slave1_comb=1;
			valid_slave2_comb=0;
		  end
      	  else begin
			valid_slave1_comb=0;
			valid_slave2_comb=1;
		  end
        end
        S_master2: begin
          if(slave2==0) begin 
			valid_slave1_comb=1;
			valid_slave2_comb=0;
		  end
      	  else  begin
			valid_slave1_comb=0;
			valid_slave2_comb=1;
		  end
        end
        S_master3: begin
          if(slave3==0) begin 
			valid_slave1_comb=1;
			valid_slave2_comb=0;
		  end
      	  else begin
			valid_slave1_comb=0;
			valid_slave2_comb=1;
		  end
        end 
       	S_handshake: begin
			valid_slave1_comb = 0;
			valid_slave2_comb = 0;
        end	
      	default: begin
        	valid_slave1_comb=0;
          	valid_slave2_comb=0;
        end
    endcase  
  end
  
  //in FF
  always@(posedge clk) begin
    case(out_cur_state)
    	S_idle: begin
        	in1 <= in_valid_1;
          	in2 <= in_valid_2;
          	in3 <= in_valid_3;
        end
      	S_master1: begin
          in1 <= 0;
          in2 <= in2;
          in3 <= in3;
        end
        S_master2: begin
          in1 <= 0;
          in2 <= 0;
          in3 <= in3;
        end
        S_master3: begin
          in1 <= 0;
          in2 <= 0;
          in3 <= 0;
        end 
       	S_handshake: begin
          in1 <= in1;
          in2 <= in2;
          in3 <= in3;
        end	
    endcase  
  end
  
  
  
  //just for state
  always@* begin
      case(out_cur_state)
    	S_idle: begin
          if(in_valid_1) begin
          	nxt_state =  S_master1;
          end
          else if(in_valid_2) begin
            nxt_state =  S_master2;
          end
          else if(in_valid_3) begin
          	nxt_state =  S_master3;
          end
          else nxt_state = S_idle;
        end
        S_master1: begin 
          if(valid_slave1_comb && ready_slave1) begin
            nxt_state = S_handshake;
          end
          else if(valid_slave2_comb && ready_slave2) begin
            nxt_state = S_handshake;
          end
          else	nxt_state = S_master1;
        end
        S_master2: begin 
          if(valid_slave1_comb && ready_slave1) begin 
            nxt_state = S_handshake;
          end
          else if(valid_slave2_comb  && ready_slave2) begin
            nxt_state = S_handshake;
          end
          else	nxt_state =S_master2;
        end
    	S_master3: begin 
          if(valid_slave1_comb && ready_slave1) begin 
            nxt_state = S_handshake;
          end
          else if(valid_slave2_comb  && ready_slave2) begin
            nxt_state = S_handshake;
          end
          else	nxt_state =S_master3;
        end
    	S_handshake: begin
            if(in2) begin
            	nxt_state =  S_master2;
          	end
            else if(in3) begin
            	nxt_state =  S_master3;
            end
            else nxt_state = S_idle;
        end
		default: nxt_state = out_cur_state;
      endcase
    end
  
  
  //output filp flop
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
    	valid_slave1 <= 0;
    end
    else begin
    	valid_slave1 <= valid_slave1_comb;
    end
  end
  
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
   		valid_slave2 <= 0;
    end
    else begin
    	valid_slave2 <= valid_slave2_comb;
    end
  end
  
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
    	handshake_slave1 <= 0;
    end
    else begin
    	handshake_slave1 <= handshake_slave1_comb;
    end
  end
  
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
    	handshake_slave2 <= 0;
    end
    else begin
    	handshake_slave2 <= handshake_slave2_comb;
    end
  end
  
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
   		addr_out <= 0;
    end
    else begin
       addr_out <=  addr_out_comb;
    end
  end
  
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
    	value_out <= 0;
    end
    else begin
      value_out <= value_out_comb;
    end
  end
endmodule
