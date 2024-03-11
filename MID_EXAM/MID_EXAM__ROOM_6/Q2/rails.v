module rails(clk, reset, number, data1, data2, valid, result1, result2);

input        clk;
input        reset;
input  [3:0] number;
input  [3:0] data1;
input  [3:0] data2;
output  reg     valid;
output  reg     result1; 
output  reg     result2;

assign valid = 1;
assign result1 = 0;
assign result2 = 0;
/*
  localparam NUMBER_IN = 4'd0;
  localparam DATA_IN = 4'd1;
  localparam STATION_POP_1 = 4'd2;
  localparam STATION_PUSH_1 = 4'd3;
  localparam OUT_1 = 4'd4;
  localparam WAIT_1 = 4'd5;
  localparam STATION_POP_2 = 4'd6;
  localparam STATION_PUSH_2 = 4'd7;
  localparam OUT_2 = 4'd8;
  localparam WAIT_2 = 4'd9;

  reg [3:0] state, nextState;
  reg [3:0] num;            // record the number of coming trains
  reg [3:0] index_1;          // index_1 of sequence of departure order_1
  reg [3:0] index_2;          // index_1 of sequence of departure order_1
  reg [3:0] order_1 [9:0];    // data array to store departure order_1
  reg [3:0] order_2 [9:0];    // data array to store departure order_1
  reg [3:0] station_index_1;  // index_1 of the stack
  reg [3:0] station_index_2;  // index_1 of the stack
  reg [3:0] station_1 [9:0];  // data array that acts as stack
  reg [3:0] station_2 [9:0];  // data array that acts as stack
  reg [3:0] sequence_index_1; // count of arrived trains
  reg [3:0] sequence_index_2; // count of arrived trains
  
  wire [3:0] station_index_1_minus_one = station_index_1-4'd1;
  wire [3:0] station_index_2_minus_one = station_index_2-4'd1;
  reg result1_reg;
*/
endmodule