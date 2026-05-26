module uart_baud_tick(
	input clk,
	input rst_n,
	input start_edge,
	input rx_stable,
	output reg sample_now,
	output reg glitch_detected
);

	localparam CLK_PER_TICK = 325;

	reg[8:0] clk_cnt;
	reg[4:0] tick_cnt;
	reg	 is_running;

	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			is_running <= 1'b0;
		end else begin
			if(start_edge)begin
				is_running <= 1'b1;
			end else if(glitch_detected || (tick_cnt == 5'd16 && clk_cnt == CLK_PER_TICK-1))begin
				is_running <= 1'b0;
			end
		end
	end


	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			clk_cnt <= 9'd0;
			tick_cnt <= 5'd0;
			sample_now <= 1'b0;
			glitch_detected <= 1'b0;
		end else begin

			sample_now <= 1'b0;
			glitch_detected <= 1'b0;

			if(is_running)begin
				if(clk_cnt == CLK_PER_TICK - 1)begin
					clk_cnt <= 9'd0;
					tick_cnt <= tick_cnt + 1'b1;

					if(tick_cnt == 5'd7)begin
						if(rx_stable == 1'b1)begin
							glitch_detected <= 1'b1;
						end else begin
							sample_now <= 1'b1;
						end
					end
				end else begin
					clk_cnt <= clk_cnt + 1'b1;
				end
			end else begin
				clk_cnt <= 9'd0;
				tick_cnt <= 5'd0;
			end
		end
	end

endmodule
