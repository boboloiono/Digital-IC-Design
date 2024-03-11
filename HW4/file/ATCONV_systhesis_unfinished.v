`timescale 1ns/10ps
module  ATCONV(
	input		clk,
	input		reset,
	output	reg	busy,	
	input		ready,	
			
	output reg	[12:0]	iaddr, // +1
	input signed [12:0]	idata,
	
	output	reg 	cwr,
	output  reg	[12:0]	caddr_wr, // +1
	output reg 	[12:0] 	cdata_wr,
	
	output	reg 	crd,
	output reg	[12:0] 	caddr_rd, // +1
	input 	[12:0] 	cdata_rd,
	
	output reg 	csel
	);

//=================================================
//            write your design below
//=================================================
reg [4:0] state, nextState;

reg [12:0] layer0 [4095:0];	// data {9,4}, size 64*64
reg [12:0] layer0_ [4623:0];	// data {9,4}, size 68*68
reg [12:0] layer1 [1023:0];	// data {9,4}, size 32*32
reg [12:0] index,temp;			// for size 64*64
reg [6:0] idx, idy;
reg en , en1;

integer i, j;

parameter	READY = 4'd0, IMAGE_MEM = 4'd1, PADDING = 4'd2, PADDING2 = 4'd3, PADDING3 = 4'd4,
			CONVOLUTION = 4'd5, RELU = 4'd6, LAYER_1_WRITE = 4'd7, MAX_POOLING = 4'd8, 
			ROUND_UP = 4'd9, LAYER_2_WRITE = 4'd10, WAIT = 4'd11;
			
parameter bias = 13'h1FF4;

always @(posedge clk or posedge reset) begin
	if(reset) begin
		busy <= 1'd0;
		iaddr <= 13'd0;
		caddr_rd <= 13'd0;
		caddr_wr <= 13'd0;
		cdata_wr <= 13'd0;
		crd <= 0; cwr <= 0;
		index <= 13'd0;
		temp <= 13'd0;
		idx <= 7'd0; idy <= 7'd0;
		en <= 1'd0;
		for(i=0; i<4096; i=i+1) layer0[i] <= 13'd0;
		for(i=0; i<4624; i=i+1) layer0_[i] <= 13'd0;
		for(i=0; i<1024; i=i+1) layer1[i] <= 13'd0;
	end
	else begin
		case(state)
			READY: begin
				if(ready) begin
					busy <= 1;
				end
			end
			IMAGE_MEM : begin	// store imgData into IMAGE_MEM
				if(!en)begin
					iaddr <= temp;
					temp <= temp +13'd1;
					if(temp < 13'd2)begin
						index <= 13'd1;
						layer0[0] <= idata ;
					end
					else begin
						index <= index +13'd1;
						layer0[index] <= idata ;
						if(index==13'd4095)begin
							en <= 1;
							index <= 0;
						end
					end
				end
			end
			PADDING : begin
				en <= 0;
				// ---------------- PADDING ---------------
				layer0_[0] <= layer0[0];		layer0_[1] <= layer0[0];		layer0_[68] <= layer0[0];	 	layer0_[69] <= layer0[0];	// NORTH_WEST
				layer0_[66] <= layer0[63];		layer0_[67] <= layer0[63];		layer0_[134] <= layer0[63];	 	layer0_[135] <= layer0[63]; // NORTH_EAST
				layer0_[4488] <= layer0[4032];	layer0_[4489] <= layer0[4032];	layer0_[4556] <= layer0[4032];	layer0_[4557] <= layer0[4032]; // SOUTH_WEST
				layer0_[4554] <= layer0[4095];	layer0_[4555] <= layer0[4095];	layer0_[4622] <= layer0[4095];	layer0_[4623] <= layer0[4095]; // SOUTH_EAST

				/*
				for(i = 0; i < 64; i = i + 1) begin
					layer0_[2+i]	<= layer0[i];			layer0_[70+i] <= layer0[i];			// NORTH
					layer0_[4490+i] <= layer0[4032+i];		layer0_[4558+i] <= layer0[4032+i];	// SOUTH
					layer0_[68*i+136] <= layer0[64*i];		layer0_[68*i+137] <= layer0[64*i];	// WEST
					layer0_[68*i+202] <= layer0[64*i+63];	layer0_[68*i+203] <= layer0[64*i+63];	// EAST
				end
				for(i = 0; i < 64; i = i + 1) begin
					for(j = 0; j < 64; j = j + 1) begin
						layer0_[(68*i)+(j+2)+136] <= layer0[64*i+j];
					end
				end
				*/
			end
			PADDING2: begin
				layer0_[(68*idx)+(idy+2)+ 136] <= layer0[64*idx+idy];
				if(idy == 7'd63) begin
					if(idx==7'd63 && idy==7'd63) begin
						idx <= 7'd0; idy <= 7'd0;
					end
					else begin
						idy <= 7'd0;
						idx <= idx + 7'd1;
					end
				end
				else begin
					idy <= idy + 7'd1;
					idx <= idx;
				end
			end
			PADDING3: begin
				layer0_[2+index]	<= layer0[index];			layer0_[70+index] <= layer0[index];			// NORTH
				layer0_[4490+index] <= layer0[4032+index];		layer0_[4558+index] <= layer0[4032+index];	// SOUTH
				layer0_[68*index+136] <= layer0[64*index];		layer0_[68*index+137] <= layer0[64*index];	// WEST
				layer0_[68*index+202] <= layer0[64*index+63];	layer0_[68*index+203] <= layer0[64*index+63];	// EAST
				index <= (index==7'd63) ? 7'd0 : index + 7'd1;
			end
			CONVOLUTION: begin
				// ------------- CONVOLUTION --------------
				layer0[index] <=	(~(layer0_[(68*idx)+ idy ] >> 4) + 13'b0000000000001)
								+	(~(layer0_[(68*idx)+(2+idy)] >> 3) + 13'b0000000000001)
								+	(~(layer0_[(68*idx)+(4+idy)] >> 4) + 13'b0000000000001)
								+	(~(layer0_[(68*idx)+(136+idy)] >> 2) + 13'b0000000000001)
								+	layer0_[(68*idx)+(138+idy)]
								+	(~(layer0_[(68*idx)+(140+idy)] >> 2) + 13'b0000000000001)
								+	(~(layer0_[(68*idx)+(272+idy)] >> 4) + 13'b0000000000001)
								+	(~(layer0_[(68*idx)+(274+idy)] >> 3) + 13'b0000000000001)
								+	(~(layer0_[(68*idx)+(276+idy)] >> 4) + 13'b0000000000001)
								+	bias;
				index <= (index == 13'd4095) ? 13'd0 : index + 13'd1;
				
				if(idy == 7'd63) begin
					if(idx == 7'd63) begin
						idx <= 7'd0; idy <= 7'd0;
					end
					else begin
						idy <= 7'd0;
						idx <= idx + 7'd1;
					end
				end
				else begin
					idy <= idy + 7'd1;
					idx <= idx;
				end
			end
			RELU: begin
				// ---------------- RELU -----------------
				if (layer0[index][12] == 1'd0) layer0[index] <= layer0[index];
				else layer0[index] <= 13'd0;
				index <= index + 13'd1;
				if (index == 13'd4095) begin
					csel <= 0;
					cwr <= 1;
					caddr_wr <= 0;
					cdata_wr <= layer0[0];
					index <= 0;
					idx <= 0; idy <= 0;
				end
				else csel <= 0;
			end
			LAYER_1_WRITE : begin	// store data into Layer0_Mem
				if(!en)begin
					caddr_wr <= caddr_wr + 13'd1;
					cdata_wr <= layer0[caddr_wr + 13'd1];
					if(caddr_wr == 13'd4095)begin
						en <= 1;
						cwr <= 0;
						crd <= 1;
					end
				end
			end
			MAX_POOLING: begin
				en <= 0;
				cwr <= 0;
				caddr_wr <= 13'd0;
				// ------------- MAX POOLING --------------
				layer1[index] <= (((layer0[(64*idx)+(   idy)] > layer0[(64*idx)+(1 +idy)]) ? layer0[(64*idx)+(    idy)] : layer0[(64*idx)+(1 +idy)])
								> ((layer0[(64*idx)+(64+idy)] > layer0[(64*idx)+(65+idy)]) ? layer0[(64*idx)+(64+idy)] : layer0[(64*idx)+(65+idy)]))
								? ((layer0[(64*idx)+(   idy)] > layer0[(64*idx)+(1 +idy)]) ? layer0[(64*idx)+(    idy)] : layer0[(64*idx)+(1 +idy)])
								: ((layer0[(64*idx)+(64+idy)] > layer0[(64*idx)+(65+idy)]) ? layer0[(64*idx)+(64+idy)] : layer0[(64*idx)+(65+idy)]);
				
				index <= (index == 13'd1023) ? 13'd0 : index + 13'd1;
				
				if (idy == 7'd62) begin
					idy <= 7'd0;
					idx <= (idx == 7'd62) ? 7'd0 : idx + 7'd2;
				end
				else begin
					idy = idy + 7'd2;
					idx = idx;
				end
			end
			ROUND_UP: begin
				// ------------- ROUND UP --------------
				layer1[index] <= (layer1[index][3:0] > 4'd0) ? {layer1[index][12:4] + 9'd1, 4'd0} : layer1[index];
				index <= index + 13'd1;
				if (index == 13'd1023) begin
					csel <= 1;
					cwr <= 1;
					caddr_wr <= 13'd0;
					cdata_wr <= layer1[0];
				end
				else csel <= 1;
			end
			LAYER_2_WRITE : begin	// store data into Layer1_Mem
				if(!en)begin
					caddr_wr <= caddr_wr + 13'd1;
					cdata_wr <= layer1[caddr_wr + 13'd1];
					if(caddr_wr == 13'd1023)begin
						en <= 1;
						cwr <= 0 ;
					end
				end
			end
			WAIT: begin
				busy <= 1'd0;
				iaddr <= 13'd0;
				caddr_rd <= 13'd0;
				caddr_wr <= 13'd0;
				cdata_wr <= 13'd0;
				crd <= 0; cwr <= 0;
				index <= 13'd0;
				idx <= 7'd0; idy <= 7'd0;
				en <= 1'd0;
			end
		endcase
	end
end

// always@(negedge clk) begin // generate the stimulus input data
	// if (busy == 1) begin
		// // when a variable assigns to two or more always blocks at the same time, syntheses would not pass.
		// // So, we need to add "state==IMAGE_MEM" to avoid layer0 assigning to diff always blocks sychronously.
		// if(state == IMAGE_MEM) layer0[temp] <= (temp < 13'd4097) ? idata : 13'd0;
	// end
// end

always @(posedge clk) begin
	if(reset) state <= READY;
	else begin
		//crd <= (en==0) ? 1 : 0;
		state <= nextState;
	end
end

always @(*) begin
	case(state)
		READY: nextState = IMAGE_MEM ;
		IMAGE_MEM:	nextState = (index==13'd4095) ? PADDING : IMAGE_MEM;
		PADDING: nextState = PADDING2;
		PADDING2: nextState = (idx==7'd63 && idy==7'd63) ? PADDING3 : PADDING2;
		PADDING3: nextState = (idx==7'd63) ? CONVOLUTION : PADDING3;
		CONVOLUTION: nextState = (index == 13'd4095) ? RELU : CONVOLUTION;
		RELU: nextState = (index == 13'd4095) ? LAYER_1_WRITE : RELU;
		LAYER_1_WRITE: nextState = (caddr_wr == 13'd4095) ? MAX_POOLING : LAYER_1_WRITE;
		MAX_POOLING: nextState = (index == 13'd1023) ? ROUND_UP : MAX_POOLING;
		ROUND_UP: nextState = (index == 13'd1023) ? LAYER_2_WRITE : ROUND_UP;
		LAYER_2_WRITE: nextState = (caddr_wr == 13'd1023) ? WAIT : LAYER_2_WRITE;
		WAIT: nextState = READY;
	endcase
end

endmodule