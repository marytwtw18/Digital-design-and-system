#include<iostream>
#include<string>
#include<vector>
#include<fstream>

using namespace std;

void splitStr2Vec(string str, vector<string>& buf)
{
	int current = 0; //initial position
	int next;
 
	while (true)
	{
	    next = str.find_first_of(" ", current);
		if (next != current)
		{
			string tmp = str.substr(current, next - current);
			if (tmp.size() != 0)   buf.push_back(tmp);
        }
		if (next == string::npos) break;
		current = next + 1; 
    }
}
int decoder(string reg){
	int return_index;
	if(reg == "10001"){
		return_index = 0;
	}
	else if(reg == "10010"){
		return_index = 1;
	}
	else if(reg == "01000"){
		return_index = 2;
	}
	else if(reg == "10111"){
		return_index = 3;
	}
	else if(reg == "11111"){
		return_index = 4;
	}
	else if(reg == "10000"){
		return_index = 5;
	}
	else{
		return_index = 6;
	}
	
	return return_index;
}

int bin_to_dec(string bin){
	int dec = 0;
	for(int i=bin.size()-1;i>=0;--i){
		if(bin[i] == '1'){
			dec += (1<<(bin.size()-i-1));
		}
	}
	return dec;
}


int main(int argc,char* argv[]){
	ifstream infile;
    string instr; 
	infile.open(argv[1]);
    ofstream outfile;
	int count = 0;
	int case_count = 0;
	unsigned int reg[6];
	bool instruction_fail;
    
	outfile.open(argv[2]);  
	
	for(int i=0;i<6;++i) reg[i] = 0;
	
	/*------------------------read file-------------------------------------*/   
    if(!infile.is_open()){
        cout << "fail to open" << endl;
    }
    else{
        while(!infile.eof()){ //read in
            vector<string> new_vec;
			string substr,rs,rt,rd,shamt,imm;
			string out1,out2,out3,out4;
			unsigned int shamt_num,imm_num;
            getline(infile,instr);
            splitStr2Vec(instr,new_vec);
            cout << instr << endl;
			if(count == 0){
				case_count = stoi(new_vec[0]);
			}
			else if(count <= case_count){
				instruction_fail = false;
				//if(!new_vec.empty())cout <<"instruction:"<< new_vec[0][31] << endl;
				
				if(!new_vec.empty())substr = substr.assign(new_vec[0],0,6);
				cout << substr << endl;
				
				if(substr == "000000") {
					substr = substr.assign(new_vec[0],26,6);
					if(substr == "100000"){ //+
						rs = rs.assign(new_vec[0],6,5);
						rt = rt.assign(new_vec[0],11,5);
						rd = rd.assign(new_vec[0],16,5);
						if((decoder(rd)==6) || (decoder(rs)==6)||(decoder(rt)==6)){
							instruction_fail = true;
						}
						else{
							reg[decoder(rd)] = reg[decoder(rs)] + reg[decoder(rt)];
							cout << "result "<<rd <<":"<<reg[decoder(rd)]<<endl;
						}
						
					}
					else if(substr == "100100") {//and
						rs = rs.assign(new_vec[0],6,5);
						rt = rt.assign(new_vec[0],11,5);
						rd = rd.assign(new_vec[0],16,5);
						if((decoder(rd)==6) || (decoder(rs)==6)||(decoder(rt)==6)){
							instruction_fail = true;
						}
						else{
							reg[decoder(rd)] = reg[decoder(rs)] & reg[decoder(rt)];
							cout << "result " <<rd <<":"<<reg[decoder(rd)]<<endl;
						}
					}
					else if(substr == "100101"){ //or
						rs = rs.assign(new_vec[0],6,5);
						rt = rt.assign(new_vec[0],11,5);
						rd = rd.assign(new_vec[0],16,5);
						if((decoder(rd)==6) || (decoder(rs)==6)||(decoder(rt)==6)){
							instruction_fail = true;
						}
						else{
							reg[decoder(rd)] = reg[decoder(rs)] | reg[decoder(rt)];
							cout << "result " <<rd <<":"<<reg[decoder(rd)]<<endl;
						}
					}
					else if(substr == "100111"){ //nor
						rs = rs.assign(new_vec[0],6,5);
						rt = rt.assign(new_vec[0],11,5);
						rd = rd.assign(new_vec[0],16,5);
						if((decoder(rd)==6) || (decoder(rs)==6)||(decoder(rt)==6)){
							instruction_fail = true;
						}
						else{
							reg[decoder(rd)] = ~(reg[decoder(rs)] | reg[decoder(rt)]);
							cout << "result " <<rd <<":"<<reg[decoder(rd)]<<endl;
						}
					}
					else if(substr == "000000"){ //shift left shamt bits
						rs = rs.assign(new_vec[0],6,5);
						rt = rt.assign(new_vec[0],11,5);
						rd = rd.assign(new_vec[0],16,5);
						shamt = shamt.assign(new_vec[0],21,5);
						shamt_num = bin_to_dec(shamt);
						if((decoder(rd)==6) || (decoder(rs)==6)||(decoder(rt)==6)){
							instruction_fail = true;
						}
						else{
							reg[decoder(rd)] = reg[decoder(rt)] << shamt_num;
							cout << "result " <<rd <<":"<<reg[decoder(rd)]<<endl;
						}
					}
					else if(substr == "000010"){ //shift right shamt bits
						rs = rs.assign(new_vec[0],6,5);
						rt = rt.assign(new_vec[0],11,5);
						rd = rd.assign(new_vec[0],16,5);
						shamt = shamt.assign(new_vec[0],21,5);
						shamt_num = bin_to_dec(shamt);
						if((decoder(rd)==6) || (decoder(rs)==6)||(decoder(rt)==6)){
							instruction_fail = true;
						}
						else{
							reg[decoder(rd)] = reg[decoder(rt)] >> shamt_num;
							cout << "result " <<rd <<":"<<reg[decoder(rd)]<<endl;
						}
					}
					else{
						instruction_fail = true;
					}
				}
				else if(substr == "001000"){ 
					rs = rs.assign(new_vec[0],6,5);
					rt = rt.assign(new_vec[0],11,5);
					imm = imm.assign(new_vec[0],16,16);
					imm_num = bin_to_dec(imm);
					cout << imm <<" "<<imm_num <<endl;
					if((decoder(rs)==6)||(decoder(rt)==6)){
						instruction_fail = true;
					}
					else{
						cout << reg[decoder(rs)] << endl;
						reg[decoder(rt)] = reg[decoder(rs)] + imm_num;
						cout << "result " <<rt <<":"<<reg[decoder(rt)]<<endl;
					}
				}
				else{
					instruction_fail = true;
				}
				//instruction correct
				if(!instruction_fail){
					out4 = out4.assign(new_vec[1],0,5);
					out3 = out3.assign(new_vec[1],5,5);
					out2 = out2.assign(new_vec[1],10,5);
					out1 = out1.assign(new_vec[1],15,5);
					if((decoder(out1)==6)||(decoder(out2)==6)|| (decoder(out3)==6)|| (decoder(out4)==6)){
						outfile << 1 <<"\t\t0\t\t0\t\t0\t\t0"<<endl;
					}
					else{
						//reg[decoder(rt)] = reg[decoder(rs)] + imm_num;
						//cout << "result " <<rt <<":"<<reg[decoder(rt)]<<endl;
						outfile << 0 <<"\t\t"<<reg[decoder(out1)]<<"\t\t"<<reg[decoder(out2)]
						<<"\t\t"<<reg[decoder(out3)]<<"\t\t"<<reg[decoder(out4)]<<endl;
					}
				}
				else {
					outfile << 1 <<"\t\t0\t\t0\t\t0\t\t0"<<endl;
				}
			}
			count++;
        }
    }
	
}