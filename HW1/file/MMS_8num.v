
module MMS_8num(result, select, number0, number1, number2, number3, number4, number5, number6, number7);

input        select;
input  [7:0] number0;
input  [7:0] number1;
input  [7:0] number2;
input  [7:0] number3;
input  [7:0] number4;
input  [7:0] number5;
input  [7:0] number6;
input  [7:0] number7;
output [7:0] result; 

reg [7:0] result, out1, out2;
wire cmp = out1 < out2;

MMS_4num MMS_4num1(out1, select, number0, number1, number2, number3);
MMS_4num MMS_4num2(out2, select, number4, number5, number6, number7);

always @(*) begin
	case({select, cmp})
		2'b00 : result = out1;
		2'b01 : result = out2;
		2'b10 : result = out2;
		2'b11 : result = out1;
	endcase
end

endmodule