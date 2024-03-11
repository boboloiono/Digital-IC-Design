module MMS_4num(result, select, number0, number1, number2, number3);

input        select;
input  [7:0] number0;
input  [7:0] number1;
input  [7:0] number2;
input  [7:0] number3;
output [7:0] result; 

reg [7:0] result, mux1, mux2;
wire cmp1 = number0 < number1;
wire cmp2 = number2 < number3;
wire cmp3 = mux1 < mux2;

always @(*) begin
	case({select, cmp1})
		2'b00 : mux1 = number0;
		2'b01 : mux1 = number1;
		2'b10 : mux1 = number1;
		2'b11 : mux1 = number0;
	endcase
end

always @(*) begin
	case({select, cmp2})
		2'b00 : mux2 = number2;
		2'b01 : mux2 = number3;
		2'b10 : mux2 = number3;
		2'b11 : mux2 = number2;
	endcase
end

always @(*) begin
	case({select, cmp3})
		2'b00 : result = mux1;
		2'b01 : result = mux2;
		2'b10 : result = mux2;
		2'b11 : result = mux1;
	endcase
end

endmodule