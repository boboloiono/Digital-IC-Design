module BITONIC_S2(  number_in1, number_in2, number_in3, number_in4,
                    number_in5, number_in6, number_in7, number_in8,
                    number_out1, number_out2, number_out3, number_out4,
                    number_out5, number_out6, number_out7, number_out8);

input  [7:0] number_in1;
input  [7:0] number_in2;
input  [7:0] number_in3;
input  [7:0] number_in4;
input  [7:0] number_in5;
input  [7:0] number_in6;
input  [7:0] number_in7;
input  [7:0] number_in8;

output  [7:0] number_out1;
output  [7:0] number_out2;
output  [7:0] number_out3;
output  [7:0] number_out4;
output  [7:0] number_out5;
output  [7:0] number_out6;
output  [7:0] number_out7;
output  [7:0] number_out8;

wire [7:0] stage1_out1, stage1_out2, stage1_out3, stage1_out4, stage1_out5, stage1_out6, stage1_out7, stage1_out8;
wire [7:0] stage2_out1, stage2_out2, stage2_out3, stage2_out4, stage2_out5, stage2_out6, stage2_out7, stage2_out8;
wire [7:0] stage_out1, stage_out2, stage_out3, stage_out4, stage_out5, stage_out6, stage_out7, stage_out8;

BITONIC_S1 BITONIC_S1_1(number_in1, number_in2, number_in3, number_in4,
                    number_in5, number_in6, number_in7, number_in8,
                    stage1_out1, stage1_out2, stage1_out3, stage1_out4,
                    stage1_out5, stage1_out6, stage1_out7, stage1_out8);

/*STAGE 2*/
BITONIC_DS BITONIC_DS3(stage1_out1, stage1_out3, stage2_out1, stage2_out3);
BITONIC_DS BITONIC_DS4(stage1_out2, stage1_out4, stage2_out2, stage2_out4);
BITONIC_AS BITONIC_AS3(stage1_out5, stage1_out7, stage2_out5, stage2_out7);
BITONIC_AS BITONIC_AS4(stage1_out6, stage1_out8, stage2_out6, stage2_out8);

BITONIC_DS BITONIC_DS5(stage2_out1, stage2_out2, stage_out1, stage_out2);
BITONIC_DS BITONIC_DS6(stage2_out3, stage2_out4, stage_out3, stage_out4);
BITONIC_AS BITONIC_AS5(stage2_out5, stage2_out6, stage_out5, stage_out6);
BITONIC_AS BITONIC_AS6(stage2_out7, stage2_out8, stage_out7, stage_out8);

assign number_out1 = stage_out1;
assign number_out2 = stage_out2;
assign number_out3 = stage_out3;
assign number_out4 = stage_out4;
assign number_out5 = stage_out5;
assign number_out6 = stage_out6;
assign number_out7 = stage_out7;
assign number_out8 = stage_out8;

endmodule