#include<iostream>
#include<string>
#include<vector>
#include<fstream>
#include<ctime>

using namespace std;

//reg generate
string decoder_reg(int reg){
	string return_index;
	if(reg == 0){
		return_index = "10001";
	}
	else if(reg == 1){
		return_index = "10010";
	}
	else if(reg == 2){
		return_index = "01000";
	}
	else if(reg == 3){
		return_index = "10111";
	}
	else if(reg == 4){
		return_index = "11111";
	}
	else if(reg == 5){
		return_index = "10000";
	}
	else if(reg == 6){
		return_index = "10100";
	}
	
	return return_index;
}
string decoder_func(int func){
	string return_index;
	if(func == 0){
		return_index = "100000";
	}
	else if(func == 1){
		return_index = "100100";
	}
	else if(func == 2){
		return_index = "100101";
	}
	else if(func == 3){
		return_index = "100111";
	}
	else if(func == 4){
		return_index = "000000";
	}
	else if(func == 5){
		return_index = "000010";
	}
	else if(func == 6){
		return_index = "101011";
	}
	
	return return_index;
}
string shift_or_imm(int num,bool shamt_or_imm){
	string str,str2;
	int size,parameter;
	while(num != 0){
		if(num % 2==1){
			str +='1';	
		}
		else{
			str +='0';	
		}
		num/=2;
	}
	size = str.size();
	if(shamt_or_imm){
		parameter = 5;
	}
	else{
		parameter = 16;
	}
	for(int i=size;i<parameter;++i){
		str +='0';	
	}
	for(int i=str.size()-1;i>=0;--i){
		str2 += str[i];
	}
	return str2;
}


int main(int argc,char* argv[]){
	ofstream outfile;
	outfile.open(argv[1]);
	srand ((unsigned) time (NULL));
	int type,func,rs,rt,rd,ran,shamt,imm;
	//int out1,out2,out3;
	outfile<<"2000"<<endl;
	for(int i=0;i<1000;++i){
		type = rand()%5;
		if((type == 0) || (type == 1)){ //op = 000000
			func = rand()%7;
			rs = rand()%7;
			rt = rand()%7;
			rd = rand()%7;
			ran = rand()%7;
			shamt = rand()%32;
			cout << shamt << ":"<<shift_or_imm(shamt,1)<<endl;
			outfile<<"000000"<<decoder_reg(rs)<<decoder_reg(rt)<<decoder_reg(rd)<<shift_or_imm(shamt,1)<<decoder_func(func)<<" ";
			outfile<<decoder_reg(rd)<<decoder_reg(rs)<<decoder_reg(rt)<<decoder_reg(ran)<<endl;
		}
		
		else if((type == 2) || (type == 3)){ //op = 001000
			rs = rand()%7;
			rt = rand()%7;
			ran = rand()%7;
			imm = rand()%65536;
			cout << imm << ":"<<shift_or_imm(imm,0)<<endl;
			outfile<<"001000"<<decoder_reg(rs)<<decoder_reg(rt)<<shift_or_imm(imm,0)<<" ";
			outfile<<decoder_reg(rt)<<decoder_reg(rs)<<decoder_reg(ran)<<decoder_reg(ran)<<endl;
		}
		else{ //error
			outfile<<"11100111111111111111111111111111"<<" "<<"10001100011000110001"<<endl;
		}
		
		//instruction fail
		outfile<<"11111111111111111111111111111111"<<" "<<"10001100011000110001"<<endl;
	}
	return 0;
}