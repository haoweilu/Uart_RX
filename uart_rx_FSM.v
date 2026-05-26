module uart_rx_FSM(
	input clk,
	input rst_n,
	input rx_stable,
	input sample_now,
	input glitch_detected,
	output reg[7:0] rx_data,
	output reg rx_data_valid
);
	parameter idle = 0, start = 1, data = 2, stop = 3;
	reg[2:0] state, next_state;
	reg[2:0] cnt;
	reg[7:0] shift_reg;

	always @(*)begin
		next_state = state;
		case(state)
			idle: next_state = (rx_stable == 1'b0) ? start : idle;
			start:begin
					if(glitch_detected)begin
						next_state = idle;
					end else if(sample_now)begin
						next_state = data;
					end
				end
			data:begin
					if(sample_now && (cnt == 3'd7))begin
						next_state = stop;
					end
				end
			stop:begin
			     		if(sample_now)begin
						next_state = idle;
					end	
			end
				default: next_state = idle;
		endcase
	end



	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			state <= idle;
		end else begin
			state <= next_state;
		end
	end

	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			shift_reg	<= 8'd0;
			rx_data		<= 8'd0;
			rx_data_valid	<= 1'd0;
		end  else begin
			rx_data_valid	<= 1'd0;
			case(state)
			idle: shift_reg <= 8'd0;

			data:begin
				if(sample_now)begin
					shift_reg	<={rx_stable, shift_reg[7:1]};
				end
			end
			stop:begin
				if(sample_now)begin
					rx_data		<= shift_reg;
					rx_data_valid	<= 1'b1;
				end		
			end
			endcase
		end
	end

	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			cnt <= 3'd0;
		end else begin
			if(state==data)begin
				if(sample_now)begin
					if(cnt==3'd7)begin
						cnt <= 3'd0;
					end else begin
						cnt <= cnt + 1'b1;
					end
				end
			end else begin
				cnt <= 3'd0;
			end
		end
	end

endmodule
