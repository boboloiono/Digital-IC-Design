/*module BOE(clk, rst, data_num, data_in, result);
input clk;
input rst;
input [2:0] data_num;
input [7:0] data_in;
output [10:0] result;

reg [1:0] curt_state;
reg [1:0] next_state;
reg [7:0] value_array [0:5];
reg [2:0] data_num_reg;
reg [2:0] array_pointer;
reg [7:0] max;
reg [10:0] sum;
reg [10:0] result;
parameter [1:0] read_data = 0, output_max = 1, output_sum = 2, output_sort = 3; 

always@(posedge clk or posedge rst) begin
    if(rst) begin
	    curt_state <= read_data;
	end
	else begin
	    curt_state <= next_state;
	end
end

always@(*) begin
    case(curt_state)
	    read_data: 
		    next_state = (array_pointer == data_num_reg)? output_max : read_data;
		output_max: 
		    next_state = output_sum;
		output_sum:
		    next_state = output_sort;
		output_sort:
		    next_state = (array_pointer == data_num_reg)? read_data : output_sort;
	endcase
end

always@(posedge clk or posedge rst) begin
    if(rst) begin
	    value_array[0] <= 255;
		value_array[1] <= 255;
		value_array[2] <= 255;
		value_array[3] <= 255;
		value_array[4] <= 255;
		value_array[5] <= 255;
		data_num_reg <= 7;
		array_pointer <= 0;
		sum <= 0;
		max <= 0;
		result <= 0;
	end
	else begin
	    case(curt_state)
		    read_data: begin
			    data_num_reg <= (data_num != 0)? data_num - 1 : data_num_reg;
				array_pointer <= (array_pointer == data_num_reg)? 0 : array_pointer + 1 ;
				// calculate sum
				sum <= sum + data_in;   
				// calculate max
				if(data_in > max) begin
				    max <= data_in;
				end   		
                // sorting				
				if(data_in <= value_array[0]) begin
				    value_array[0] <= data_in;
					value_array[1] <= value_array[0];
					value_array[2] <= value_array[1];
					value_array[3] <= value_array[2];
					value_array[4] <= value_array[3];
					value_array[5] <= value_array[4];
				end
				else if(data_in <= value_array[1]) begin
					value_array[1] <= data_in;
					value_array[2] <= value_array[1];
					value_array[3] <= value_array[2];
					value_array[4] <= value_array[3];
					value_array[5] <= value_array[4];
				end
				else if(data_in <= value_array[2]) begin
					value_array[2] <= data_in;
					value_array[3] <= value_array[2];
					value_array[4] <= value_array[3];
					value_array[5] <= value_array[4];
				end
				else if(data_in <= value_array[3]) begin
					value_array[3] <= data_in;
					value_array[4] <= value_array[3];
					value_array[5] <= value_array[4];
				end
				else if(data_in <= value_array[4]) begin
					value_array[4] <= data_in;
					value_array[5] <= value_array[4];
				end
				else begin
				
				    value_array[5] <= data_in;
				end
				
			end
			output_max: begin
			    result <= max;
			end
			output_sum: begin
			    result <= sum;
			end
			output_sort: begin
			    result <= value_array[array_pointer];
				array_pointer <= (array_pointer == data_num_reg)? 0 : array_pointer + 1;
				value_array[0] <= (array_pointer == data_num_reg)? 255 : value_array[0];
				value_array[1] <= (array_pointer == data_num_reg)? 255 : value_array[1];
				value_array[2] <= (array_pointer == data_num_reg)? 255 : value_array[2];
				value_array[3] <= (array_pointer == data_num_reg)? 255 : value_array[3];
				value_array[4] <= (array_pointer == data_num_reg)? 255 : value_array[4];
				value_array[5] <= (array_pointer == data_num_reg)? 255 : value_array[5];
				sum <= 0;
				max <= 0;
			end
		endcase
	end
end

endmodule
*/
module BOE(clk, rst, data_num, data_in, result);
input clk;
input rst;
input [2:0] data_num;
input [7:0] data_in;
output [10:0] result;

parameter DATA_IN=3'd0, OUT_MAX=3'd1, OUT_SUM=3'd2, OUT_SORT=3'd3;
reg [2:0] state, next_state;
reg [7:0] count;
reg [2:0] index;
reg [2:0] order [7:0];
reg [3:0] stack_index;
reg [3:0] stack [7:0];
reg [7:0] sum;
reg [7:0] max;

integer i;

always @(*) begin
	case(state)
		DATA_IN: begin
			if(index == count - 1) next_state <= OUT_MAX;
			else next_state <= DATA_IN;
		end
		OUT_MAX: begin
			next_state <= OUT_SUM;
		end
		OUT_SUM: begin
			next_state <= OUT_SORT;
		end
		OUT_SORT: begin
			if(stack_index == count + 2) next_state <= DATA_IN;
			else if next_state <= OUT_SORT;
		end
	endcase
end

always @(posedge clk) begin
	if(rst) state <= DATA_IN;
	else state <= next_state;
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		for(i=0; i<8; i++) stack <= 3'd111;
		count <= 0;
		index <= 0;
		stack_index <= 0;
	end
	else begin
		DATA_IN: begin
			count <= data_num;
			temp <= data_in;
			order[index] <= data_in;
			if(index == count-1) index <=0;
			else index <= index + 1;
			sum <= sum + order[index];
			if(index==0 && stack_index==0) max <= order[index];
			else if(index>0 && order[index]>order[index-1]) begin
				max <= order[index];
				stack_index <= stack_index + 1;
			end
			else begin
				max <=  max;
			end
		end
		end
		OUT_MAX: begin
			stack_index = stack_index + 1;
			result <= max;
		end
		OUT_SUM: begin
			stack_index = stack_index + 1;
			result <= sum;
		end
		OUT_SORT: begin
			index = index - 1;
			result <= stack[index];
			index <= index + 1;
		end
	end
end

endmodule