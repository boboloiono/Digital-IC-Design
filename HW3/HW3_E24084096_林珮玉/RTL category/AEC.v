module AEC(clk, rst, ascii_in, ready, valid, result);

// Input signal
input clk;
input rst;
input ready;
input [7:0] ascii_in;

// Output signal
output reg valid;
output reg [6:0] result;


//-----Your design-----//

localparam IDLE = 3'd0;
localparam DATA_IN = 3'd1;
localparam POSTFIX = 3'd2;
localparam CALCULATOR = 3'd3;
localparam RESULT = 3'd4;

reg [2:0] state, nextState;

reg [3:0] index, out_index, stack_index;

reg [7:0] deAscii[15:0];
reg [7:0] outString[15:0];
reg [7:0] stack[15:0];
integer i;

always@(posedge clk)begin
	if(rst) state <= IDLE;
	else state <= nextState;		
end
always@(*)begin //state 
	case(state)
	
		IDLE:begin
			if(ready) nextState = DATA_IN;
			else nextState = IDLE;
		end
		DATA_IN:begin
			if(ascii_in == 61) nextState = POSTFIX;
			else nextState = DATA_IN;
		end
		POSTFIX:begin
			if((deAscii[index] == 134) && (stack_index == 0)) nextState = CALCULATOR;
			else nextState = POSTFIX;
		end
		CALCULATOR:begin
			if(outString[out_index] == 134) nextState = RESULT;
			else nextState = CALCULATOR;
		end
		RESULT:begin
			nextState = IDLE;
		end
		default:begin
			nextState = IDLE;
		end
	endcase
end

/* let ( = 129, ) = 130, * = 131, + = 132, - = 133, = = 134 */
always@(posedge rst or posedge clk)begin
	if(rst)begin
		for(i = 0; i<16; i=i+1)begin
			deAscii[i] <= 8'd0;
			outString[i] <= 8'd0;
			stack[i] <= 8'd0;
		end
		index <= 4'd0;
		out_index <= 4'd0;
		stack_index <= 4'd0;
	end
	else begin
		case(state)
			IDLE:begin
				valid <= 0;
				result <= 0;
				if(ready)begin
					if(ascii_in == 40)		deAscii[index] <= 8'd129;
					else if(ascii_in == 41) deAscii[index] <= 8'd130;
					else if(ascii_in > 96) 	deAscii[index] <= ascii_in - 8'd87;
					else deAscii[index] <= 	ascii_in - 8'd48;
					index <= index + 4'd1;
				end
			end
			DATA_IN:begin
				if(ascii_in == 61) index <= 0;
				else index <= index + 4'd1;
				
				if(ascii_in == 40)			deAscii[index] <= 8'd129;
				else if(ascii_in == 41)		deAscii[index] <= 8'd130;
				else if(ascii_in == 42)		deAscii[index] <= 8'd131;
				else if(ascii_in == 43)		deAscii[index] <= 8'd132;
				else if(ascii_in == 45)		deAscii[index] <= 8'd133;
				else if (ascii_in == 61)	deAscii[index] <= 8'd134;
				else if(ascii_in > 96)		deAscii[index] <= ascii_in - 8'd87;
				else 						deAscii[index] <= ascii_in - 8'd48;
			end
			POSTFIX:begin
				 //=
				if(deAscii[index] == 134)begin
					outString[out_index] <= stack[stack_index - 1];
					if(stack_index == 0)begin
						outString[out_index + 1] <= 8'd134;
						for(i = 0; i <16; i=i+1) deAscii[i] <= 0;
						index <= 4'd0;
						out_index <= 4'd0;
						stack_index <= 4'd0;
					end
					else begin
						//for(i = 0; i <16; i=i+1) deAscii[i] <= deAscii[i];
						//index <= index;
						out_index <= out_index + 4'd1;
						stack_index <= stack_index - 4'd1;
					end
				end
				 //(
				else if(deAscii[index] == 129)begin
					stack[stack_index] <= deAscii[index];
					stack_index <= stack_index + 4'd1;
					index <= index + 4'd1;
				end
				 //)
				else if(deAscii[index] == 130)begin
					if(stack[stack_index - 1] == 129)begin
						stack_index <= stack_index - 4'd1;
						index <= index + 4'd1;
					end
					else begin
						outString[out_index] <= stack[stack_index - 1];
						stack_index <= stack_index - 4'd1;
						out_index <= out_index + 4'd1;
					end
				end
				 //*
				else if(deAscii[index] == 131)begin
					if(stack[stack_index -1] == 131)begin
						outString[out_index] <= stack[stack_index - 1];
						stack_index <= stack_index - 4'd1;
						out_index <= out_index + 4'd1;
					end
					else begin
						stack[stack_index] = deAscii[index];
						stack_index <= stack_index + 4'd1;
						index <= index + 4'd1;
					end
				end
				 // + or -
				else if((deAscii[index] == 132) || (deAscii[index] == 133))begin
					if(stack[stack_index - 1] > 130)begin
						outString[out_index] <= stack[stack_index - 1];
						stack_index <= stack_index - 4'd1;
						out_index <= out_index + 4'd1;
					end
					else begin
						stack[stack_index] <= deAscii[index];
						stack_index <= stack_index + 4'd1;
						index <= index + 4'd1;
					end
				end
				 // number
				else begin
					outString[out_index] <= deAscii[index];
					out_index <= out_index + 4'd1;
					index <= index + 4'd1;
				end
			end
			CALCULATOR:begin
				if(outString[out_index] == 131)begin
					deAscii[index - 2] <= deAscii[index - 2] * deAscii[index - 1];
					index <= index - 4'd1;
					out_index <= out_index + 4'd1;
				end
				else if(outString[out_index] == 132)begin
					deAscii[index - 2] <= deAscii[index - 2] + deAscii[index - 1];
					index <= index - 4'd1;
					out_index <= out_index + 4'd1;
				end
				else if(outString[out_index] == 133)begin
					deAscii[index - 2] <= deAscii[index - 2] - deAscii[index - 1];
					index <= index - 4'd1;
					out_index <= out_index + 4'd1;
				end
				else if(outString[out_index] == 134)begin
					index <= index;
					out_index <= out_index;
				end
				else begin
					deAscii[index] <= outString[out_index];
					index <= index + 4'd1;
					out_index <= out_index + 4'd1;
				end
			end
			RESULT:begin
				valid <= 1'b1;
				result <= deAscii[0][6:0];
				for(i = 0; i<16; i=i+1)begin
					deAscii[i] <= 8'd0;
					outString[i] <= 8'd0;
					stack[i] <= 8'd0;
				end
				index <= 4'd0;
				out_index <= 4'd0; 
				stack_index <= 4'd0;
			end
			default:begin
				for(i = 0; i<16; i=i+1)begin
			    	deAscii[i] <= 8'd0;
			    	outString[i] <= 8'd0;
			    	stack[i] <= 8'd0;
			    end
			    index <= 4'd0;
			    out_index <= 4'd0;
			    stack_index <= 4'd0;
			end
		endcase
		
	
	end
end


endmodule