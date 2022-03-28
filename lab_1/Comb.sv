module Comb(
  // Input signals
	in_num0,
	in_num1,
	in_num2,
	in_num3,
  // Output signals
	out_num0,
	out_num1
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
    input [3:0] in_num0, in_num1, in_num2, in_num3;
    output logic [4:0] out_num0, out_num1;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------

    logic [3:0] gate_out0,gate_out1,gate_out2,gate_out3; //lab change to logic
    logic [4:0] adder1,adder2;
    
//---------------------------------------------------------------------
//   Your DESIGN                        
//---------------------------------------------------------------------
    assign gate_out0 = in_num0 ~^ in_num1;
    assign gate_out1 = in_num1 | in_num3;
    assign gate_out2 = in_num0 & in_num2;
    assign gate_out3 = in_num2 ^ in_num3;
    
    adder add1(gate_out0,gate_out1,adder1);
    adder add2(gate_out2,gate_out3,adder2);
    com_and_mux cam(adder1,adder2,out_num0,out_num1);
endmodule

module com_and_mux(
    input [4:0] in0,in1,
    output reg [4:0] out0,out1
);
    always@* begin
        if(in0 >= in1) begin
            out0 <= in1;
            out1 <= in0;
        end
        else  begin //to prevent latch
            out0 <= in0;
            out1 <= in1;
        end
    end
    
endmodule

module adder(
    input [3:0] in1,
    input [3:0] in2,
    output [4:0] out
);
    logic c0,c1,c2;//lab change to logic
    fu_adder fa0(in1[0],in2[0],1'b0,c0,out[0]);
    fu_adder fa1(in1[1],in2[1],c0,c1,out[1]);
    fu_adder fa2(in1[2],in2[2],c1,c2,out[2]);
    fu_adder fa3(in1[3],in2[3],c2,out[4],out[3]);
    
endmodule

module fu_adder(
    input a,b,cin,
    output cout,sum
);
    //assign sum = a ^ b ^ cin;
    //assign cout = (a & b) |  (a & cin) | (b & cin);
    assign {cout,sum} = cin + a + b;
endmodule