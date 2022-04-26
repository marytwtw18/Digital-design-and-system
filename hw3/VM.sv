// Code your design here
module VM(
    //Input 
    input clk,
    input rst_n,
    input in_item_valid,
    input in_coin_valid,
  	input [5:0] in_coin,
    input in_rtn_coin,
  	input [2:0] in_buy_item,
  	input [4:0] in_item_price,
    //OUTPUT
    output logic [8:0] out_monitor,
    output logic out_valid,
  	output logic [3:0] out_consumer,
  	output logic [5:0] out_sell_num
);

//logic
logic in_rtn_coin_reg,in_rtn_coin_comb;
logic [2:0] in_buy_item_reg,in_buy_item_comb;
logic [2:0] in_buy_item_reg2,in_buy_item_comb2;
logic [4:0] product_cost_in [0:6];
logic [4:0] product_cost [0:6]; //product 1~6 cost

logic [3:0] con_comb[0:6];
logic [3:0] con[0:6];
logic [5:0] sell[0:6];
logic [5:0] sell_comb [0:6];
logic [5:0] out_sell_num_comb;
logic [8:0] out_monitor_reg,out_monitor_reg_comb,out_monitor_comb;

//parameter
logic [2:0] i = 0,i_nxt = 0;
logic [2:0] count = 0,count_nxt;
logic [2:0] cnt = 0,cnt_nxt;
logic [3:0] idx = 0;
logic [8:0] temp;
logic flag1,flag2,flag3,flag4,flag5,flag6;

//fsm state
logic [2:0] cur_state,nxt_state;
parameter IDLE = 3'd0; 
parameter SET = 3'd1;
parameter COIN = 3'd2;
parameter RET = 3'd3;
parameter BUY = 3'd4;
parameter CAL = 3'd5;
parameter DONE = 3'd6; 

//---------------------------------------------------------------------
//  Your design(Using FSM)                            
//---------------------------------------------------------------------
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) cur_state = IDLE;
    else cur_state = nxt_state;
end

//FSM part
always@* begin
	//nxt state
	case(cur_state)
      	IDLE: nxt_state = (in_item_valid?SET:(in_coin_valid?COIN:IDLE));
		SET: nxt_state = in_coin_valid?COIN:SET;
		COIN: 
		begin
			if(in_rtn_coin)	nxt_state = RET;
			else if(in_buy_item) nxt_state = BUY;
			else nxt_state = COIN;
		end		
		RET: nxt_state = CAL;
		BUY: nxt_state = CAL;
		CAL: nxt_state = (cnt==2)?DONE:CAL;
		DONE: nxt_state = (count==5)?IDLE:DONE;
		default: nxt_state =  cur_state;
	endcase
end

always@* begin
	case(cur_state)
		CAL: cnt_nxt = cnt+1; 
		default: cnt_nxt = 0;
	endcase
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) cnt <= 0;
	else cnt <= cnt_nxt;
end
 
//product_cost set
always@* begin
	if(in_item_valid) i_nxt = i+1;
	else  i_nxt = 0;
end
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) i <= 0;
	else i <= i_nxt;
end
always@* begin
	if(in_item_valid) begin
		case(i)
			0: product_cost_in[0] = in_item_price;
			default: product_cost_in[0] = product_cost[0];
		endcase
	end
	else  product_cost_in[0] = product_cost[0];
end
always@* begin
	if(in_item_valid) begin
		case(i)
			1: product_cost_in[1] = in_item_price;
			default: product_cost_in[1] = product_cost[1];
		endcase
	end
	else  product_cost_in[1] = product_cost[1];
end
always@* begin
	if(in_item_valid) begin
		case(i)
			2: product_cost_in[2] = in_item_price;
			default: product_cost_in[2] = product_cost[2];
		endcase
	end
	else  product_cost_in[2] = product_cost[2];
end
always@* begin
	if(in_item_valid) begin
		case(i)
			3: product_cost_in[3] = in_item_price;
			default: product_cost_in[3] = product_cost[3];
		endcase
	end
	else  product_cost_in[3] = product_cost[3];
end
always@* begin
	if(in_item_valid) begin
		case(i)
			4: product_cost_in[4] = in_item_price;
			default: product_cost_in[4] = product_cost[4];
		endcase
	end
	else  product_cost_in[4] = product_cost[4];
end
always@* begin
	if(in_item_valid) begin
		case(i)
			5: product_cost_in[5] = in_item_price;
			default: product_cost_in[5] = product_cost[5];
		endcase
	end
	else  product_cost_in[5] = product_cost[5];
end

//product_cost reg
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) for(idx=0;idx<=6;++idx) product_cost[idx] <= 0;
	else begin
		for(idx=0;idx<=5;++idx) product_cost[idx] <= product_cost_in[idx];
		product_cost[6] <= 0;
	end
end

//out_monitor_reg_comb
always@* begin
	case(cur_state)
		COIN: out_monitor_reg_comb = out_monitor;
		BUY: begin
			if(out_monitor_reg == 0) out_monitor_reg_comb = out_monitor;
			else out_monitor_reg_comb = out_monitor_reg;
		end
		RET: begin 
			if(out_monitor_reg == 0) out_monitor_reg_comb = out_monitor;
			else out_monitor_reg_comb = out_monitor_reg;
		end
		default: out_monitor_reg_comb = out_monitor_reg; 
	endcase
end

//out_monitor_reg
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)  out_monitor_reg  <= 0;
	else  out_monitor_reg  <= out_monitor_reg_comb;
end

//out_monitor_comb
always@* begin
	case(cur_state)
		IDLE: out_monitor_comb = out_monitor+in_coin;
		SET: out_monitor_comb = out_monitor+in_coin;
		COIN: begin
			if(in_buy_item) begin
				case(in_buy_item)
					0: out_monitor_comb = 0;
					1: out_monitor_comb =(product_cost[0] > out_monitor)?out_monitor:0;
					2: out_monitor_comb =(product_cost[1] > out_monitor)?out_monitor:0;
					3: out_monitor_comb =(product_cost[2] > out_monitor)?out_monitor:0;
					4: out_monitor_comb =(product_cost[3] > out_monitor)?out_monitor:0;
					5: out_monitor_comb =(product_cost[4] > out_monitor)?out_monitor:0;
					6:  out_monitor_comb =(product_cost[5] > out_monitor)?out_monitor:0;
					default: out_monitor_comb = 0;
				endcase
			end
			else if(in_rtn_coin) out_monitor_comb = 0;
			else out_monitor_comb = out_monitor+in_coin;
		end
		BUY: begin
			if(in_buy_item) begin
				case(in_buy_item)
					0: out_monitor_comb = 0;
					1: out_monitor_comb =(product_cost[0] > out_monitor)?out_monitor:0;
					2: out_monitor_comb =(product_cost[1] > out_monitor)?out_monitor:0;
					3: out_monitor_comb =(product_cost[2] > out_monitor)?out_monitor:0;
					4: out_monitor_comb =(product_cost[3] > out_monitor)?out_monitor:0;
					5: out_monitor_comb =(product_cost[4] > out_monitor)?out_monitor:0;
					6:  out_monitor_comb =(product_cost[5] > out_monitor)?out_monitor:0;
					default out_monitor_comb = 0;
				endcase
			end
			else begin
				case(in_buy_item_reg)
					0: out_monitor_comb = 0;
					1: out_monitor_comb =(product_cost[0] > out_monitor)?out_monitor:0;
					2: out_monitor_comb =(product_cost[1] > out_monitor)?out_monitor:0;
					3: out_monitor_comb =(product_cost[2] > out_monitor)?out_monitor:0;
					4: out_monitor_comb =(product_cost[3] > out_monitor)?out_monitor:0;
					5: out_monitor_comb =(product_cost[4] > out_monitor)?out_monitor:0;
					6:  out_monitor_comb =(product_cost[5] > out_monitor)?out_monitor:0;
					default out_monitor_comb = 0;
				endcase
			end
		end
		RET: out_monitor_comb = 0;
		default: begin
			case(in_buy_item_reg)
				0: out_monitor_comb = 0;
				1: out_monitor_comb =(product_cost[0] > out_monitor)?out_monitor:0;
				2: out_monitor_comb =(product_cost[1] > out_monitor)?out_monitor:0;
				3: out_monitor_comb =(product_cost[2] > out_monitor)?out_monitor:0;
				4: out_monitor_comb =(product_cost[3] > out_monitor)?out_monitor:0;
				5: out_monitor_comb =(product_cost[4] > out_monitor)?out_monitor:0;
				6:  out_monitor_comb =(product_cost[5] > out_monitor)?out_monitor:0;
				default: out_monitor_comb = 0;
			endcase
        end
	endcase
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n) out_monitor <= 0;
	else out_monitor <= out_monitor_comb;
end

//in_rtn_coin_comb
always@* begin
	case(cur_state) 
		IDLE: in_rtn_coin_comb = 0;
		COIN: in_rtn_coin_comb = 0;
		RET: in_rtn_coin_comb = 1;
		default: in_rtn_coin_comb = in_rtn_coin_reg;
	endcase
end

//in_rtn_coin_reg
always@(posedge clk  or negedge rst_n) begin
	if(!rst_n) in_rtn_coin_reg <= 0;
	else in_rtn_coin_reg <= in_rtn_coin_comb;
end

//in_buy_item_comb
always@* begin
	case(cur_state) 
		//IDLE: in_buy_item_comb = 0;
		COIN: in_buy_item_comb = in_buy_item;
		BUY: in_buy_item_comb = in_buy_item;
		default: in_buy_item_comb = in_buy_item_reg;
	endcase
end

//in_buy_item_reg
always@(posedge clk  or negedge rst_n) begin
	if(!rst_n) in_buy_item_reg2 <= 0;
	else in_buy_item_reg2 <= in_buy_item_comb;
end
always@* begin
	case(cur_state) 
		//IDLE: in_buy_item_comb = 0;
		COIN: in_buy_item_comb2 = in_buy_item;
		BUY: in_buy_item_comb2 = in_buy_item_reg2;
		default: in_buy_item_comb2 = in_buy_item_reg;
	endcase
end
always@(posedge clk  or negedge rst_n) begin
	if(!rst_n) in_buy_item_reg <= 0;
	else in_buy_item_reg <= in_buy_item_comb2;
end

//out_valid_comb
/*
always@* begin
	case(cur_state)
		IDLE: out_valid_comb = 0;
		DONE: out_valid_comb = 1;
		default:  out_valid_comb = 0;
	endcase	
end    
//out_valid
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) out_valid <= 0;
    else out_valid <= out_valid_comb;
end
*/
always@* begin
	case(cur_state)
		IDLE: out_valid = 0;
		DONE: out_valid = 1;
		default:  out_valid = 0;
	endcase	
end  

//count return money 
//con_comb
always@(*) begin
	case(cur_state)		
      	IDLE: begin
			temp = 0;
			for(idx=0;idx<=6;idx = idx+1) begin
          		con_comb[idx] = 0;
			end
		end
		RET: begin
			temp =0;
			con_comb[0] = 0;
			for(idx=1;idx<=6;++idx) begin
          		con_comb[idx] = 0;
          	end
		end
		BUY: begin
			temp =0;
			
			for(idx=1;idx<=6;++idx) begin
          		con_comb[idx] = 0;
          	end
			case(in_buy_item_reg)
				0: con_comb[0] = 0;
				1:  con_comb[0] = (out_monitor_reg >= product_cost[0])?in_buy_item_reg:0;
				2:  con_comb[0] = (out_monitor_reg >= product_cost[1])?in_buy_item_reg:0;
				3:  con_comb[0] = (out_monitor_reg >= product_cost[2])?in_buy_item_reg:0;
				4:  con_comb[0] = (out_monitor_reg >= product_cost[3])?in_buy_item_reg:0;
				5:  con_comb[0] = (out_monitor_reg >= product_cost[4])?in_buy_item_reg:0;
				6:  con_comb[0] = (out_monitor_reg >= product_cost[6])?in_buy_item_reg:0;
				default: con_comb[0] = 0;
			endcase
		end
		CAL: begin
			if(!(in_buy_item_reg)) begin //rtn in_buy_item_reg=0
				temp = out_monitor_reg;
				con_comb[0] = 0;
				con_comb[1] = (out_monitor_reg/50);
				con_comb[2] =  ((out_monitor_reg%50)/20);
				con_comb[3] = ((out_monitor_reg%50)%20)/10;
				con_comb[4] =  (((out_monitor_reg%50)%20)%10)/5 ;
				con_comb[5] = (((out_monitor_reg%50)%20)%10)%5;
				con_comb[6] = 0;
			end
			//in_buy_item_reg>=1
			//else if((out_monitor_reg >= product_cost[in_buy_item_comb2-1]) && (in_rtn_coin_reg == 0)) begin
			else if(in_rtn_coin_reg == 0) begin
				case(in_buy_item_comb2)
					1: begin
						temp = (out_monitor_reg >= product_cost[0])?(out_monitor_reg-product_cost[0]):0;
						con_comb[0] = (out_monitor_reg >= product_cost[0])?in_buy_item_reg:0;
						con_comb[1] = (out_monitor_reg >= product_cost[0])?(temp /50):0;
						con_comb[2] =  (out_monitor_reg >= product_cost[0])?((temp%50)/20):0;
						con_comb[3] = (out_monitor_reg >= product_cost[0])?(((temp%50)%20)/10):0;
						con_comb[4] = (out_monitor_reg >= product_cost[0])?((((temp%50)%20)%10)/5):0;
						con_comb[5] = (out_monitor_reg >= product_cost[0])?((((temp%50)%20)%10)%5):0;
						con_comb[6] = 0;
					end
					2: begin
						temp = (out_monitor_reg >= product_cost[1])?(out_monitor_reg-product_cost[1]):0;
						con_comb[0] = (out_monitor_reg >= product_cost[1])?in_buy_item_reg:0;
						con_comb[1] = (out_monitor_reg >= product_cost[1])?(temp /50):0;
						con_comb[2] =  (out_monitor_reg >= product_cost[1])?((temp%50)/20):0;
						con_comb[3] = (out_monitor_reg >= product_cost[1])?(((temp%50)%20)/10):0;
						con_comb[4] = (out_monitor_reg >= product_cost[1])?((((temp%50)%20)%10)/5):0;
						con_comb[5] = (out_monitor_reg >= product_cost[1])?((((temp%50)%20)%10)%5):0;
						con_comb[6] = 0;
					end
					3: begin
						temp = (out_monitor_reg >= product_cost[2])?(out_monitor_reg-product_cost[2]):0;
						con_comb[0] = (out_monitor_reg >= product_cost[2])?in_buy_item_reg:0;
						con_comb[1] = (out_monitor_reg >= product_cost[2])?(temp /50):0;
						con_comb[2] =  (out_monitor_reg >= product_cost[2])?((temp%50)/20):0;
						con_comb[3] = (out_monitor_reg >= product_cost[2])?(((temp%50)%20)/10):0;
						con_comb[4] = (out_monitor_reg >= product_cost[2])?((((temp%50)%20)%10)/5):0;
						con_comb[5] = (out_monitor_reg >= product_cost[2])?((((temp%50)%20)%10)%5):0;
						con_comb[6] = 0;
					end
					4: begin
						temp = (out_monitor_reg >= product_cost[3])?(out_monitor_reg-product_cost[3]):0;
						con_comb[0] = (out_monitor_reg >= product_cost[3])?in_buy_item_reg:0;
						con_comb[1] = (out_monitor_reg >= product_cost[3])?(temp /50):0;
						con_comb[2] =  (out_monitor_reg >= product_cost[3])?((temp%50)/20):0;
						con_comb[3] = (out_monitor_reg >= product_cost[3])?(((temp%50)%20)/10):0;
						con_comb[4] = (out_monitor_reg >= product_cost[3])?((((temp%50)%20)%10)/5):0;
						con_comb[5] = (out_monitor_reg >= product_cost[3])?((((temp%50)%20)%10)%5):0;
						con_comb[6] = 0;
					end
					5: begin
						temp = (out_monitor_reg >= product_cost[4])?(out_monitor_reg-product_cost[4]):0;
						con_comb[0] = (out_monitor_reg >= product_cost[4])?in_buy_item_reg:0;
						con_comb[1] = (out_monitor_reg >= product_cost[4])?(temp /50):0;
						con_comb[2] =  (out_monitor_reg >= product_cost[4])?((temp%50)/20):0;
						con_comb[3] = (out_monitor_reg >= product_cost[4])?(((temp%50)%20)/10):0;
						con_comb[4] = (out_monitor_reg >= product_cost[4])?((((temp%50)%20)%10)/5):0;
						con_comb[5] = (out_monitor_reg >= product_cost[4])?((((temp%50)%20)%10)%5):0;
						con_comb[6] = 0;
					end
					6: begin
						temp = (out_monitor_reg >= product_cost[5])?(out_monitor_reg-product_cost[5]):0;
						con_comb[0] = (out_monitor_reg >= product_cost[5])?in_buy_item_reg:0;
						con_comb[1] = (out_monitor_reg >= product_cost[5])?(temp /50):0;
						con_comb[2] =  (out_monitor_reg >= product_cost[5])?((temp%50)/20):0;
						con_comb[3] = (out_monitor_reg >= product_cost[5])?(((temp%50)%20)/10):0;
						con_comb[4] = (out_monitor_reg >= product_cost[5])?((((temp%50)%20)%10)/5):0;
						con_comb[5] = (out_monitor_reg >= product_cost[5])?((((temp%50)%20)%10)%5):0;
						con_comb[6] = 0;
					end
					default: begin
						temp = 0;
						for(idx=0;idx<=6;++idx) begin
							con_comb[idx] = 0;
						end
					end
				endcase
          	end
          	else begin
				temp = 0;
            	for(idx=0;idx<=6;++idx) begin
          			con_comb[idx] = 0;
          		end
            end
        end
		DONE: for(idx=0;idx<=6;++idx) con_comb[idx] = con[idx];
      	default: begin 
			temp = 0;
          	for(idx=0;idx<=6;++idx) begin
          		con_comb[idx] = 0;
          	end
        end
	endcase
end


//con
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(idx=0;idx<=6;++idx) begin
          	con[idx] <= 0;
        end
	end
	else begin
		for(idx=0;idx<=6;++idx) begin
          	con[idx] <= con_comb[idx];
        end
	end
end

//out_consumer
always@* begin
	case(cur_state)
		IDLE: out_consumer = 0;
		DONE: begin
			case(count)
				0:out_consumer = con[0];
				1:out_consumer = con[1];
				2:out_consumer = con[2];
				3:out_consumer = con[3];
				4:out_consumer = con[4];
				5: out_consumer = con[5];
				default:out_consumer = 0;
			endcase
		end
		default:  out_consumer = 0;
	endcase	
end

//sell_comb
always@* begin
	case(cur_state) 
		SET: begin
			sell_comb[0] = 0;
			flag1 = 0;
		end
		CAL: begin
			case(in_buy_item_reg)
				1: begin
					sell_comb[0] = (!flag1)?((product_cost[0] <= out_monitor_reg)?(sell[0]+1):sell[0]):sell[0];
					flag1 = 1;
				end
				default: begin 
					sell_comb[0] =  sell[0];
					flag1 = 0;
				end
			endcase
		end
		default: begin
			sell_comb[0] =  sell[0];
			flag1 = 0;
		end
	endcase
	case(cur_state) 
		SET: begin
			sell_comb[1] = 0;
			flag2 = 0;
		end
		CAL: begin
			case(in_buy_item_reg)
				2: begin
					sell_comb[1] = (!flag2)?((product_cost[1] <= out_monitor_reg)?(sell[1]+1):sell[1]):sell[1];
					flag2 = 1;
				end
				default: begin 
					sell_comb[1] =  sell[1];
					flag2 = 0;
				end
			endcase
		end
		default: begin
			sell_comb[1] =  sell[1];
			flag2 = 0;
		end
	endcase
	case(cur_state) 
		SET: begin
			sell_comb[2] = 0;
			flag3 = 0;
		end
		CAL: begin
			case(in_buy_item_reg)
				3: begin
					sell_comb[2] = (!flag3)?((product_cost[2] <= out_monitor_reg)?(sell[2]+1):sell[2]):sell[2];
					flag3 = 1;
				end
				default: begin
					sell_comb[2] =  sell[2];
					flag3 = 0;
				end
			endcase
		end
		default: begin
			sell_comb[2] =  sell[2];
			flag3 = 0;
		end
	endcase
	case(cur_state) 
		SET: begin
			sell_comb[3] = 0;
			flag4 = 0;
		end
		CAL: begin
			case(in_buy_item_reg)
				4: begin
					sell_comb[3] = (!flag4)?((product_cost[3] <= out_monitor_reg)?(sell[3]+1):sell[3]):sell[3];
					flag4 = 1;
				end
				default: begin
					sell_comb[3] =  sell[3];
					flag4 = 0;
				end
			endcase
		end
		default: begin
			sell_comb[3] =  sell[3];
			flag4 = 0;
		end
	endcase
	case(cur_state) 
		SET: begin
			sell_comb[4] = 0;
			flag5 = 0;
		end
		CAL: begin
			case(in_buy_item_reg)
				5: begin
					sell_comb[4] = (!flag5)?((product_cost[4] <= out_monitor_reg)?(sell[4]+1):sell[4]):sell[4];
					flag5 = 1;
				end
				default: begin
					sell_comb[4] =  sell[4];
					flag5 = 0;
				end
			endcase
		end
		default: begin
			sell_comb[4] =  sell[4];
			flag5 = 0;
		end
	endcase
	case(cur_state) 
		SET: begin
			sell_comb[5] = 0;
			flag6 = 0;
		end
		CAL: begin
			case(in_buy_item_reg)
				6: begin
					sell_comb[5] = (!flag6)?((product_cost[5] <= out_monitor_reg)?(sell[5]+1):sell[5]):sell[5];
					flag6 = 1;
				end
				default: begin
					sell_comb[5] =  sell[5];
					flag6 = 0;
				end
			endcase
		end
		default: begin
			sell_comb[5] =  sell[5];
			flag6 = 0;
		end
	endcase
end

//sell
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) for(idx=0;idx<=6;++idx) sell[idx] <= 0;
	else for(idx=0;idx<=5;++idx) sell[idx] <= sell_comb[idx];
end

//counter comb
always@* begin
	case(cur_state)
		DONE: count_nxt = count+1; 
		default: count_nxt = 0;
	endcase
end
always@* begin
	case(cur_state)
		CAL: out_sell_num_comb = sell_comb[0];
		DONE: begin
			case(count)
				0: out_sell_num_comb = sell_comb[1];
				1: out_sell_num_comb = sell_comb[2];
				2: out_sell_num_comb = sell_comb[3];
				3: out_sell_num_comb = sell_comb[4];
				4: out_sell_num_comb = sell_comb[5];
				5: out_sell_num_comb = 0;
				default: out_sell_num_comb = 0;
			endcase
		end
		default: out_sell_num_comb = 0;
	endcase
end
//out_sell_num
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
		count <= 0;
		out_sell_num <= 0;
	end
    else begin
		count <= count_nxt;
		out_sell_num <= out_sell_num_comb;
    end
end 

endmodule