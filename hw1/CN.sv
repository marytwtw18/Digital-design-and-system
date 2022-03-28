module CN(
    // Input signals
    opcode,
	  in_n0,
  	in_n1,
  	in_n2,
  	in_n3,
  	in_n4,
  	in_n5,
    // Output signals
    out_n
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
    input [3:0] in_n0, in_n1, in_n2, in_n3, in_n4, in_n5;
    input [4:0] opcode;
    output logic [8:0] out_n;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
    //logic [5:0] value_0,value_1,value_2,value_3,value_4,value_5;
    logic [4:0] value [0:5];
    logic [4:0] valuen [0:5];

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------

    register_file reg1(in_n0,value[0]);
    register_file reg2(in_n1,value[1]);
    register_file reg3(in_n2,value[2]);
    register_file reg4(in_n3,value[3]);
    register_file reg5(in_n4,value[4]);
    register_file reg6(in_n5,value[5]);
    
    decode_op decoder(opcode,value,valuen);
    //assign out_n = valuen[4];
    
    alu_op alu(opcode,valuen,out_n);
    
endmodule


//module decoder
module decode_op(
    input [4:0] opcode,
    input [4:0] value [0:5],
    output logic [4:0] valuen [0:5]
);

    logic [4:0] temp [0:5];
    logic [4:0] w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w14,w15,w16,w17,w20,w21;
    
    
    //sort for small to big(faster)
    
    assign w1 = (value[0]<value[1])?value[0]:value[1];
    assign w2 = (value[0]<value[1])?value[1]:value[0];
    assign w3 = (value[2]<value[3])?value[2]:value[3];
    assign w4 = (value[2]<value[3])?value[3]:value[2];
    assign w5 = (value[4]<value[5])?value[4]:value[5];
    assign w6 = (value[4]<value[5])?value[5]:value[4];
    
    
    assign w7 = (w1<w3)?w1:w3;
    assign w8 = (w1<w3)?w3:w1;
    assign w9 = (w4<w6)?w4:w6;
    assign w10 = (w4<w6)?w6:w4;
    
    
    assign w11 = (w2<w5)?w2:w5;
    assign w12 = (w2<w5)?w5:w2;
    
    
    assign temp[0] = (w7<w11)?w7:w11;
    assign w14 = (w7<w11)?w11:w7;
    assign w15 = (w8<w9)?w8:w9;
    assign w16 = (w8<w9)?w9:w8;
    assign w17 = (w12<w10)?w12:w10;
    assign temp[5] = (w12<w10)?w10:w12;
   
   
    assign temp[1] = (w14<w15)?w14:w15;
    assign w20 = (w14<w15)?w15:w14;
    assign w21 = (w16<w17)?w16:w17;
    assign temp[4] = (w16<w17)?w17:w16;
    
    
    assign temp[2] = (w20<w21)?w20:w21;
    assign temp[3] = (w20<w21)?w21:w20;
    
    
    always@* begin
        case(opcode[4:3]) 
            2'b00:  
              begin
                  valuen[0] = value[0];
                  valuen[1] = value[1];
                  valuen[2] = value[2];
                  valuen[3] = value[3];
                  valuen[4] = value[4];
                  valuen[5] = value[5];
              end
            2'b01: 	
              begin
                  valuen[0] = value[5];
                  valuen[1] = value[4];
                  valuen[2] = value[3];
                  valuen[3] = value[2];
                  valuen[4] = value[1];
                  valuen[5] = value[0];
              end
			      2'b10: 	//big to small
              begin
                  valuen[0] = temp[5];
                  valuen[1] = temp[4];
                  valuen[2] = temp[3];
                  valuen[3] = temp[2];
                  valuen[4] = temp[1];
                  valuen[5] = temp[0];
              end
			      2'b11:	//small to big
              begin
                  valuen[0] = temp[0];
                  valuen[1] = temp[1];
                  valuen[2] = temp[2];
                  valuen[3] = temp[3];
                  valuen[4] = temp[4];
                  valuen[5] = temp[5];   
              end
			      default:	
              begin
                  valuen[0] = value[0];
                  valuen[1] = value[1];
                  valuen[2] = value[2];
                  valuen[3] = value[3];
                  valuen[4] = value[4];
                  valuen[5] = value[5];
              end
		    endcase
    end
endmodule

module alu_op(
    input [4:0] opcode,
    input [4:0] value [0:5],
    output logic [8:0] out_n
);
    always@* begin
        case(opcode[2:0])
            3'b000:  out_n = value[2]-value[1];
            3'b001:  out_n = value[0]+value[3];
            3'b010:  out_n = (value[3]*value[4])/2;
            3'b011:  out_n = value[1] + (value[5]*2);
            3'b100:  out_n = value[1] & value[2];
            3'b101:  out_n = ~value[0];
            3'b110:  out_n = value[3] ^ value[4];
            3'b111:  out_n = value[1] << 1;
            default:	out_n = out_n;
        endcase 
    end 

endmodule


//---------------------------------------------------------------------
//   Register design from TA (Do not modify, or demo fails)
//---------------------------------------------------------------------
module register_file(
    address,
    value
);
input [3:0] address;
output logic [4:0] value;

always_comb begin
    case(address)
    4'b0000:value = 5'd9;
    4'b0001:value = 5'd27;
    4'b0010:value = 5'd30;
    4'b0011:value = 5'd3;
    4'b0100:value = 5'd11;
    4'b0101:value = 5'd8;
    4'b0110:value = 5'd26;
    4'b0111:value = 5'd17;
    4'b1000:value = 5'd3;
    4'b1001:value = 5'd12;
    4'b1010:value = 5'd1;
    4'b1011:value = 5'd10;
    4'b1100:value = 5'd15;
    4'b1101:value = 5'd5;
    4'b1110:value = 5'd23;
    4'b1111:value = 5'd20;
    default: value = 0;
    endcase
end

endmodule