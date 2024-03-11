module demosaic(clk, reset, in_en, data_in, wr_r, addr_r, wdata_r, rdata_r, wr_g, addr_g, wdata_g, rdata_g, wr_b, addr_b, wdata_b, rdata_b, done);
input clk;
input reset;
input in_en;
input [7:0] data_in;
output reg wr_r;
output reg [13:0] addr_r;
output reg unsigned [7:0] wdata_r;
input [7:0] rdata_r;
output reg wr_g;
output reg [13:0] addr_g;
output reg unsigned [7:0] wdata_g;
input [7:0] rdata_g;
output reg wr_b;
output reg [13:0] addr_b;
output reg unsigned [7:0] wdata_b;
input [7:0] rdata_b;
output reg done;

localparam DATA_IN = 2'd0, BILINEAR = 2'd1, RESULT = 2'd2;
reg [1:0] state, nextState;
reg [13:0] len;
reg unsigned [9:0] red, green, blue;
reg [4:0] count;

always @(posedge clk or posedge reset) begin
	if(reset) begin
		addr_r	<= 14'd0;
		wdata_r	<= 8'd0;
		wr_g	<= 1'd0;
		addr_g	<= 14'd0;
		wdata_g	<= 8'd0;
		wr_b	<= 1'd0;
		addr_r	<= 14'd0;
		wdata_r	<= 8'd0;
		done	<= 1'd0;
		len		<= 14'd0;
		count <= 3'd0;
		red <= 10'd0;
		green <= 10'd0;
		blue <= 10'd0;
	end
	else begin
		case(state)
			DATA_IN: begin	// 把所有的pixel分別存到單色的momery
				if (in_en) begin
					if(len[7]) begin			// 奇數的row
						if(len[0]) begin		// 奇數的column
							wr_g <= 1'd1;
							addr_g <= len;
							wdata_g <= data_in;
						end
						else begin				// 偶數的column
							wr_b <= 1'd1;
							addr_b <= len;
							wdata_b <= data_in;
						end
					end
					else begin					// 偶數的row
						if(len[0]) begin		// 奇數的column
							wr_r <= 1'd1;
							addr_r <= len;
							wdata_r <= data_in;
						end
						else begin				// 偶數的column
							wr_g <= 1'd1;
							addr_g <= len;
							wdata_g <= data_in;
						end
					end
					if(len == 14'd16383) begin
						len <= 14'd129;
					end
					else begin
						len <= len + 14'd1;
					end
				end
			end
			BILINEAR: begin
				wr_r <= 1'd0;
				wr_g <= 1'd0;
				wr_b <= 1'd0;
				wdata_r <= 8'd0;
				wdata_g <= 8'd0;
				wdata_b <= 8'd0;
				if((len%128==14'd0) || (len%128==14'd127)) begin
					count <= 3'd0;
					len <=  (len == 14'd16383) ? 14'd0 : (len + 14'd1);
				end
				else begin
					if(len[7] && len[0]) begin	// 奇數row，奇數column -> case A: missing B, R on G
						case(count)
							3'd0: begin
								addr_r <= len - 14'd128;	// 上
								addr_b <= len - 14'd1;		// 左
							end
							3'd1: begin
								addr_r <= len + 14'd128;	// 下
								red <= red + rdata_r;
								addr_b <= len + 14'd1;		// 右
								blue <= blue + rdata_b;
							end
							3'd2: begin
								wr_r <= 1'd1;
								addr_r <= len;
								wdata_r <= (red + rdata_r) >> 1;
								
								wr_b <= 1'd1;
								addr_b <= len;
								wdata_b <= (blue + rdata_b) >> 1;
								
								red <= 10'd0;
								blue <= 10'd0;
								len <=  (len == 14'd16383) ? 14'd0 : (len + 14'd1);
							end
						endcase
						count <= (count == 3'd2) ? 3'd0 : count + 3'd1;
					end
					else if(len[7] && !len[0]) begin // 奇數row，偶數column -> case B: missing G, R on B
						case(count)
							3'd0: begin
								addr_g <= len - 14'd128;	// 上
								addr_r <= len - 14'd129;	// 左上
							end
							3'd1: begin
								addr_g <= len - 14'd1;		// 左
								green <= green + rdata_g;
								addr_r <= len - 14'd127;	// 右上
								red <= red + rdata_r;
							end
							3'd2: begin
								addr_g <= len + 14'd128;	// 下
								green <= green + rdata_g;
								addr_r <= len + 14'd127;	// 左下
								red <= red + rdata_r;
							end
							3'd3: begin
								addr_g <= len + 14'd1;		// 右
								green <= green + rdata_g;
								addr_r <= len + 14'd129;	// 右下
								red <= red + rdata_r;
							end
							3'd4: begin
								wr_r <= 1'd1;
								addr_r <= len;
								wdata_r <= (red + rdata_r) >> 2;
								
								wr_g <= 1'd1;
								addr_g <= len;
								wdata_g <= (green + rdata_g) >> 2;
								
								red <= 10'd0;
								green <= 10'd0;
								len <=  (len == 14'd16383) ? 14'd0 : (len + 14'd1);
							end
						endcase
						count <= (count == 3'd4) ? 3'd0 : count + 3'd1;
					end
					else if(!len[7] && len[0]) begin // 偶數row，奇數column -> case C: missing G, B on R
						case(count)
							3'd0: begin
								addr_g <= len - 14'd128;	// 上
								addr_b <= len - 14'd129;	// 左上
							end
							3'd1: begin
								addr_g <= len - 14'd1;		// 左
								green <= green + rdata_g;
								addr_b <= len - 14'd127;	// 右上
								blue <= blue + rdata_b;
							end
							3'd2: begin
								addr_g <= len + 14'd128;	// 下
								green <= green + rdata_g;
								addr_b <= len + 14'd127;	// 左下
								blue <= blue + rdata_b;
							end
							3'd3: begin
								addr_g <= len + 14'd1;		// 右
								green <= green + rdata_g;
								addr_b <= len + 14'd129;	// 右下
								blue <= blue + rdata_b;
							end
							3'd4: begin
								wr_g <= 1'd1;
								addr_g <= len;
								wdata_g <= (green + rdata_g) >> 2;
								
								wr_b <= 1'd1;
								addr_b <= len;
								wdata_b <= (blue + rdata_b) >> 2;
								
								green <= 10'd0;
								blue <= 10'd0;
								len <=  (len == 14'd16383) ? 14'd0 : (len + 14'd1);
							end
						endcase
						count <= (count == 3'd4) ? 3'd0 : count + 3'd1;
					end
					else if(!len[7] && !len[0])  begin // 偶數row，偶數column -> case D: missing B, R on G
						case(count)
							3'd0: begin
								addr_b <= len - 14'd128;	// 上
								addr_r <= len - 14'd1;		// 左
							end
							3'd1: begin
								addr_b <= len + 14'd128;	// 下
								blue <= blue + rdata_b;
								addr_r <= len + 14'd1;		// 右
								red <= red + rdata_r;
							end
							3'd2: begin
								wr_r <= 1'd1;
								addr_r <= len;
								wdata_b <= (blue + rdata_b) >> 1;
								
								wr_b <= 1'd1;
								addr_b <= len;
								wdata_r <= (red + rdata_r) >> 1;
								
								red <= 10'd0;
								blue <= 10'd0;
								len <=  (len == 14'd16383) ? 14'd0 : (len + 14'd1);
							end
						endcase
						count <= (count == 3'd2) ? 3'd0 : count + 3'd1;
					end
					else begin
						red <= 0;
						blue <= 0;
					end
				end	

			end
			RESULT: begin
				done <= 1'd1;
			end
		endcase
	end
end

always @(posedge clk or posedge reset) begin
	if(reset) state <= DATA_IN;
	else state <= nextState;
end

always @(*) begin
	case(state)
		DATA_IN: begin
			nextState = (len == 14'd16383) ? BILINEAR : DATA_IN;
		end
		BILINEAR: begin	// 周圍不需要再重讀，所以從第二排讀到倒數第二排
			nextState = (len == 14'd16254) ? RESULT : BILINEAR;
		end
		RESULT: begin
			nextState = DATA_IN;
		end
	endcase
end
endmodule
