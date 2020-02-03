module control_unit

 #(parameter FLAGS_size = 6)

 (input logic [6:0] opcode,input logic clk,state_flag_bit,init,
 
 output logic wrmem,ioe,intreq,decodeinstr,we3,rst,hlt,wrpc,prefix,jump,ch,ret,wrflags,seladdr,
 
 output logic [FLAGS_size-1:0] Jcc,output logic [4:0] func,output logic [3:0] stwr,
 
 output logic [1:0] spc_a,output logic [2:0] spc_b);
 

 typedef enum logic [5:0] {LDW = 6'b0,STW,MOV,
 
			HLT,RST,INT,IN,OUT,CH,RET,
			
			ADD,SUB,MUL,DIV,
			
			MVN,OR,AND,ORN,ANDN,EOR,EON,LSL,
			
			LSR,ASR,REV,
			
			J,JZ,JNZ,JC,JNC,JO,JNO,JP,JNP,JG,JL,JNG,JNL,CMP,MOD} instr;

	typedef enum logic [4:0] {ADD_OP = 5'b0,SUB_OP,MUL_OP,DIV_OP,MOD_OP,
			
			MVN_OP,OR_OP,AND_OP,ORN_OP,ANDN_OP,EOR_OP,EON_OP,REV_OP,
			
			LSL_OP,LSR_OP,ASR_OP,
			
			NOP_OP,CMP_OP} alu;
			
 typedef enum logic {r=1'b0,i} prefx;
 
 instr command;

 alu alu_op;
 
 prefx ext;
 
 logic [2:0] state;

 assign {command,ext} = opcode;
 
 always_ff @(posedge clk,posedge init) begin
 
	if (init) begin
		func <= NOP_OP;
		wrmem <= 0;
		ioe <= 0;
		intreq <= 0;
		decodeinstr <= 1; 
		stwr <= 'b0;
		we3 <= 0;
		rst <= 1;
		wrpc <= 0;
		prefix <= 0;
		jump <= 0;
		ch <= 0;
		hlt <= 0;
		ret <= 0;
		spc_a <= 'b0;
		spc_b <= 'b0;
		wrflags <= 0;
		Jcc <= 'b0;
		seladdr <= 0;
		
		state <= 0;
	end

	else begin

		if (hlt) state <= state;

		else begin 

			hlt <= 0;
			state <= state + 3'b001;
		
		end
		
		case(state)
		
			0: begin // fetch
		
				func <= NOP_OP;
				wrmem <= 0;
				ioe <= 0;
				intreq <= 0;
				decodeinstr <= 1;
				stwr <= 'b0;
				we3 <= 0;
				rst <= 0;
				wrpc <= 0; 
				
				prefix <= 0;
				jump <= 0;
				ch <= 0;
				hlt <= 0;
				ret <= 0;
				spc_a <= 'b0;
				spc_b <= 'b0;
				wrflags <= 0;
				Jcc <= 'b0;
				seladdr <= 0;
			   end
			   
			 1: begin // decode
			 
				spc_a <= 1;
				spc_b <= 2;
				func <= ADD_OP;
				decodeinstr <= 0;
			   end
			 
			2: begin
				wrpc <= 1;
				
			  end 
			
			3: begin // exec
			
				case(command)
				
					LDW: begin //ldw
					
						seladdr <= 1;
						wrpc <= 0;
						
						func <= NOP_OP;
					   end
					STW: begin //stw
					
						wrpc <= 0;
						
						func <= NOP_OP;
						seladdr <= 1;
					   end
					 MOV: begin //mov
					 
						
						func <= NOP_OP;
						wrpc <= 0;
						we3 <= 1;
						
						if (ext == r) stwr <= 2;
						else stwr <= 1;
						
						state <= 0;
					   end
					 
					  RST: begin //rst
					  
						rst <= 1;
						
						state <= 0;
					  
					  end
					  
					  HLT: begin // hlt
					  
						hlt <= 1;
						wrpc <= 0;

						state <= 7;
						
					  end
					  
					  IN: begin // in
					  
						wrpc <= 0;
						func <= NOP_OP;
						seladdr <= 1;
					   end
					   
					   OUT: begin // out
					   
						wrpc <= 0;
						func <= NOP_OP;
						seladdr <= 1;
					  
					  end
					  
					  INT: begin // int
					  
						wrpc <= 0;
						func <= NOP_OP;
						seladdr <= 1;
					   end
					   
					  CH: begin // ch
					  
						wrpc <= 0;
						ch <= 1;
						
						if (ext == r) prefix <= 0;
						else prefix <= i;
						
						jump <= 1;
						stwr <= 0;
					   end
					   
					   RET: begin // ret
					   
						wrpc <= 0;
						func <= NOP_OP;
						ret <= 1;
						prefix <= 0;
						jump <= 1;
						
					   end
					   CMP: begin

						   spc_a <=0;
						   func <= CMP_OP;
						   wrflags <= 1;
						   wrpc <= 0;
						   state <= 0;
					     end
					   ADD: begin // ADD
					   
						spc_a <= 0;
						alu_op <= ADD_OP;
						func <= alu_op;
						wrflags <= 1;
						wrpc <= 0;
						stwr <= 0;
						we3 <= 1;
						state <= 0;
						
						if (ext == r) spc_b <= 0;
						else spc_b <= 1;
					    end
					   
					   SUB: begin // SUB

						spc_a <= 0;
						func <= SUB_OP;
						wrflags <= 1;
						wrpc <= 0;
						stwr <= 0;
						we3 <= 1;
						state <= 0;
						
						if (ext == r) spc_b <= 0;
						else spc_b <= 1;
					    end
					   
					   MUL: begin // mul

						spc_a <= 0;
						func <= MUL_OP;
						wrflags <= 1;
						wrpc <= 0;
						stwr <= 0;
						we3 <= 1;
						state <= 0;
						
						if (ext == r) spc_b <= 0;
						else spc_b <= 1;
					    end
					    
					    DIV: begin // DIV

						spc_a <= 0;
						func <= DIV_OP;			
						wrflags <= 1;
						wrpc <= 0;
						stwr <= 0;
						we3 <= 1;
						state <= 0;
						
						if (ext == r) spc_b <= 0;
						else spc_b <= 1;
					    end
					    
					    MOD: begin // MOD

						spc_a <= 0;
						func <= MOD_OP;
						wrflags <= 1;
						wrpc <= 0;
						stwr <= 0;
						we3 <= 1;
						state <= 0;
						
						if (ext == r) spc_b <= 0;
						else spc_b <= 1;
					    end
					  
					   MVN: begin // mvn

						spc_a <= 0;
						func <= MVN_OP;
						
						wrflags <= 1;
						wrpc <= 0;
						stwr <= 0;
						we3 <= 1;
						state <= 0;
						
						if (ext == r) spc_b <= 0;
						else spc_b <= 1;
					    end
					    
					    OR: begin // or

						spc_a <= 0;
						func <= OR_OP;
						wrflags <= 1;
						wrpc <= 0;
						stwr <= 0;
						we3 <= 1;
						state <= 0;
						
						if (ext == r) spc_b <= 0;
						else spc_b <= 1;
					    end
					    
					    AND: begin // and

						spc_a <= 0;
						func <= AND_OP;
						wrflags <= 1;
						wrpc <= 0;
						stwr <= 0;
						we3 <= 1;
						state <= 0;
						
						if (ext == r) spc_b <= 0;
						else spc_b <= 1;
					    end
					    
					   ANDN: begin // andn

						spc_a <= 0;
						func <= ANDN_OP;
						wrflags <= 1;
						wrpc <= 0;
						stwr <= 0;
						we3 <= 1;
						state <= 0;
						
						if (ext == r) spc_b <= 0;
						else spc_b <= 1;
					    end
					    
					    ORN: begin // orn

						spc_a <= 0;
						func <= ORN_OP;
						wrflags <= 1;
						wrpc <= 0;
						stwr <= 0;
						we3 <= 1;
						state <= 0;
						
						if (ext == r) spc_b <= 0;
						else spc_b <= 1;
					    end
					    
						EOR: begin // EOR

						spc_a <= 0;
						func <= EOR_OP;
						wrflags <= 1;
						wrpc <= 0;
						stwr <= 0;
						we3 <= 1;
						state <= 0;
						
						if (ext == r) spc_b <= 0;
						else spc_b <= 1;
					    end
					    
					    EON: begin // EON

						spc_a <= 0;
						func <= EON_OP;
						
						wrflags <= 1;
						wrpc <= 0;
						stwr <= 0;
						we3 <= 1;
						state <= 0;
						
						if (ext == r) spc_b <= 0;
						else spc_b <= 1;
					    end
					    
					    REV: begin // rev

						spc_a <= 0;
						
						func <= REV_OP;
						wrflags <= 1;
						wrpc <= 0;
						stwr <= 0;
						we3 <= 1;
						state <= 0;
						
						if (ext == r) spc_b <= 0;
						else spc_b <= 1;
					    end
					    LSL: begin // lsl

						spc_a <= 0;
						func <= LSL_OP;
						
						wrflags <= 1;
						wrpc <= 0;
						stwr <= 0;
						we3 <= 1;
						state <= 0;
						
						if (ext == r) spc_b <= 0;
						else spc_b <= 1;
					    end
					    
					    LSR: begin // lsr

						spc_a <= 0;
						func <= LSR_OP;
						
						wrflags <= 1;
						wrpc <= 0;
						stwr <= 0;
						we3 <= 1;
						state <= 0;
						
						if (ext == r) spc_b <= 0;
						else spc_b <= 1;
					    end
					    
					    ASR: begin // asr

						
						spc_a <= 0;
						func <= ASR_OP;
						
						wrflags <= 1;
						wrpc <= 0;
						stwr <= 0;
						we3 <= 1;
						state <= 0;
						
						if (ext == r) spc_b <= 0;
						else spc_b <= 1;
					    end
					    
					    J: begin // J
					    
						if (ext == r) prefix <= 0;
						else prefix <= 1;
					
						jump <= 1;
						func <= NOP_OP;
						
						end
						
						JZ: begin // JZ
					    
						if (ext == r) prefix <= 0;
						else prefix <= 1;
						Jcc <= 5;
						jump <= 1;
						func <= NOP_OP;
						wrpc <= 0;
						end
						
						JNZ: begin // JNZ
					    
						if (ext == r) prefix <= 0;
						else prefix <= 1;
						Jcc <= 5;
						jump <= 1;
						func <= NOP_OP;
						wrpc <= 0;
						end
						
						JC: begin // JC
					    
						if (ext == r) prefix <= 0;
						else prefix <= 1;
						Jcc <= 3;
						jump <= 1;
						func <= NOP_OP;
						wrpc <= 0;
						end
						JNC: begin // JNC
					    
						if (ext == r) prefix <= 0;
						else prefix <= 1;
						Jcc <= 3;
						jump <= 1;
						func <= NOP_OP;
						wrpc <= 0;
						end
						
						JO: begin // JO
					    
						if (ext == r) prefix <= 0;
						else prefix <= 1;
						Jcc <= 4;
						jump <= 1;
						func <= NOP_OP;
						wrpc <= 0;
						end
						
						JNO: begin // JNO
					    
						if (ext == r) prefix <= 0;
						else prefix <= 1;
						Jcc <= 4;
						jump <= 1;
						func <= NOP_OP;
						wrpc <= 0;
						end
						
						JP: begin // JP
					    
						if (ext == r) prefix <= 0;
						else prefix <= 1;
						Jcc <= 2;
						jump <= 1;
						func <= NOP_OP;
						wrpc <= 0;
						end
						
						JNP: begin // JNP
					    
						if (ext == r) prefix <= 0;
						else prefix <= 1;
						Jcc <= 2;
						jump <= 1;
						func <= NOP_OP;
						wrpc <= 0;
						end
						
						JG: begin // JG
					    
						if (ext == r) prefix <= 0;
						else prefix <= 1;
						Jcc <= 1;
						jump <= 1;
						func <= NOP_OP;
						wrpc <= 0;
						end
						
						JL: begin // JL
					    
						if (ext == r) prefix <= 0;
						else prefix <= 1;
						Jcc <= 0;
						jump <= 1;
						func <= NOP_OP;
						wrpc <= 0;
						end
						
						JNG: begin // JNG
					    
						if (ext == r) prefix <= 0;
						else prefix <= 1;
						Jcc <= 1;
						jump <= 1;
						func <= NOP_OP;
						
						wrpc <= 0;
						end
						
						JNL: begin // JNL
					    
						if (ext == r) prefix <= 0;
						else prefix <= 1;
						Jcc <= 0;
						jump <= 1;
						func <= NOP_OP;
						wrpc <= 0;
						end
					    
					    default: state <= 0;
				endcase
				
				
			   end
				
			4: begin // wrdata
				
				case(command)
				
					LDW: begin // ldw
					
						stwr <= 3;
						we3 <= 1;
						seladdr <= 0;
						
						state <= 0;
					   end
					
					STW: begin // stw
					
						wrmem <= 1;
						
						state <= 0;
					   end
					IN: begin // in
		
							ioe <= 1;
					end
					OUT: begin // out
					
							ioe <= 1;
							
							state <= 0;
					end
					
					INT: begin // int
					
							intreq <= 1;
							
							state <= 0;
					end
					
					CH: begin // ch
					
						we3 <= 1;
						ch <= 0;
					 end
					RET: begin // ret
					
						wrpc <= 1;
						
						state <= 0;
					
					end
					
					JZ: begin //JZ
						state <= 0;
						wrpc <= state_flag_bit;
					end
					
					JNZ: begin //JNZ
						state <= 0;
						wrpc <= ~state_flag_bit;
					end
					
					JC: begin //JC
						state <= 0;
						wrpc <= state_flag_bit;
					end
					
					JNC: begin //JNC
						state <= 0;
						wrpc <= ~state_flag_bit;
					end
					
					JO: begin //JO
						state <= 0;
						wrpc <= state_flag_bit;
					end
					
					JNO: begin //JNO
						state <= 0;
						wrpc <= ~state_flag_bit;
					end

					JP: begin //JP
						state <= 0;
						wrpc <= state_flag_bit;
					end

					JNP: begin //JNP
						state <= 0;
						wrpc <= ~state_flag_bit;
					end

					JG: begin //JG
						state <= 0;
						wrpc <= state_flag_bit;
					end

					JL: begin //JL
						state <= 0;
						wrpc <= state_flag_bit;
					end

					JNG: begin //JNG
						state <= 0;
						wrpc <= ~state_flag_bit;
					end

					JNL: begin //JNL
						state <= 0;
						wrpc <= ~state_flag_bit;
					end				
				endcase
			end
			    5: begin // ch
					
					if(command == CH) begin

						wrpc <= 1;
					
						state <= 0;
					end

					else if(command == IN) begin

						stwr <= 4;
						we3 <= 1;

						state <= 0;
					end

				end 
			endcase	
			 
		end
	
 end
 
endmodule