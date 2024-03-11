module rails(clk, reset, data, valid, result);

  input clk;
  input reset;
  input [3:0] data;
  output reg valid;
  output reg result;
  
  localparam NUMBER_IN = 3'd0;
  localparam DATA_IN = 3'd1;
  localparam STATION_POP = 3'd2;
  localparam STATION_PUSH = 3'd3;
  localparam OUT = 3'd4;
  localparam WAIT = 3'd5;

  reg [2:0] state, nextState;
  reg [3:0] num;            // record the number of coming trains
  reg [3:0] index;          // index of sequence of departure order
  reg [3:0] order [9:0];    // data array to store departure order
  reg [3:0] station_index;  // index of the stack
  reg [3:0] station [9:0];  // data array that acts as stack
  reg [3:0] sequence_index; // count of arrived trains
  
  wire [3:0] station_index_minus_one = station_index-4'd1;

  integer i;

  always @(*) begin
    case(state)
      NUMBER_IN: begin
        nextState = DATA_IN;
      end
      // All data had been read
      DATA_IN: begin
        if(index == num -1) nextState = STATION_PUSH;
        else nextState = DATA_IN;
      end
      STATION_POP: begin
        // TOP of stack == current departure number
        if(station_index>0 && station[station_index_minus_one] == order[index]) nextState = STATION_POP;
        else nextState = STATION_PUSH;
      end
      STATION_PUSH: begin
        // All trains have arrived at the station
        if(sequence_index == num+1) nextState <= OUT;
        else nextState = STATION_POP;
      end
      OUT: begin
        nextState = WAIT;
      end
      default: begin
        nextState = NUMBER_IN;
      end
    endcase
  end  

  always @(posedge clk) begin
    if(reset) state <= NUMBER_IN;
    else state <= nextState;
  end

  always @(posedge clk or posedge reset) begin
    if(reset) begin
      for(i=0; i<10; i=i+1) station[i] = 4'b1111;
      valid <= 0; result <= 0;
      num <= 0;
      index <= 0;
      station_index <= 0;
      sequence_index <= 1;
    end
    else begin
      case(state)
        NUMBER_IN: begin //read number of coming trains
          num <= data;
        end
        DATA_IN: begin //read data of departure order
          order[index] <= data;
          if(index == num - 1) index <= 4'd0;
          else index <= index + 1;
        end
        STATION_POP: begin //compare top with order
          if(station_index > 0 && station[station_index_minus_one] == order[index]) begin
            station_index <= station_index - 1;
            index <= index + 1;
          end
        end
        STATION_PUSH: begin //push data into stack
            station[station_index] <= sequence_index;
            station_index <= station_index + 1;
            sequence_index <= sequence_index + 1;
        end
        OUT: begin //output result
          valid <= 1;
          if(index == num) result <= 1;
        end
        WAIT: begin //reset register
          for(i=0; i<10; i=i+1) station[i] <= 4'b1111;
          valid <= 0;
          result <= 0;
          index <= 0;
          station_index <= 0;
          sequence_index <= 1;
        end
      endcase
    end
  end
endmodule
