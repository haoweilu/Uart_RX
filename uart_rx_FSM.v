module uart_rx_FSM(
	input            clk,
	input            rst_n,
	input            rx_stable,
	input            sample_now,
	input            glitch_detected,
	output reg [7:0] rx_data,
	output reg       rx_data_valid
);
	parameter idle   = 2'd0;
	parameter start  = 2'd1;
        parameter data   = 2'd2; 
        parameter stop   = 2'd3;



	reg[2:0] state, next_state;
	reg[2:0] cnt;
	reg[7:0] shift_reg;

	wire  start_pluse = (rx_stable == 1'b0);
	wire  last_data   = (sample_now && (cnt == 3'd7));
	always @(*)begin
		next_state = state;
		case(state)
			idle:  if      (state_start    ) begin
		                         next_state = start;
                               end
			       else begin
                                         next_state = idle;
                               end
			start:
                               if      (glitch_detected) begin
                                         next_state = idle;
                               end 
                               else if (sample_now     ) begin
			     	         next_state = data;
                               end
			data:
                               if      (last_data      ) begin
       	                                 next_state = stop;
                               end
			stop:
                               if      (sample_now     ) begin
                                         next_state = idle;
                               end	
			default:         next_state = idle;
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
		end  else begin
			if      (cur_idle    ) begin
			end 
			else if (cur_start   ) begin
			    
			end
			else if (cur_data && sample_now) begin
			end
			else if (cur_stop && sample_now) begin
			end
			
		end
	end

	
       always @(posedge clk or negedge rst_n)begin
              if(!rst_n)                    begin 
		         shift_reg	        <= 8'd0                      ;
	      end 
	      else if (cur_idle)            begin
	                 shift_reg             <= 8'd0                       ;
	      end
	      else if (data_shift)          begin
	                 shift_reg             <= {rx_stable, shift_reg[7:1]};
	      end
       end	


       always @(posedge clk or negedge rst_n)begin
              if(!rst_n)begin
			rx_data		<= 8'd0                              ;
	      end 
	      else if (data_out_pulse) begin
	                rx_data         <= shift_reg                         ;
	      end
       end	


       always @(posedge clk or negedge rst_n)begin
              if(!rst_n)begin
			rx_data_valid	<= 1'd0                       ;
	      end 
              else if (data_out_pulse) begin
              		rx_data_valid   <= 1'd1                       ;
	      end
	      else begin
	                rx_data_valid   <= 1'd0                       ;
	      end
       end	

//       always @(posedge clk or negedge rst_n)begin
//
//		if(!rst_n)begin
//			shift_reg	<= 8'd0;
//			rx_data		<= 8'd0;
//			rx_data_valid	<= 1'd0;
//		end  else begin
//			rx_data_valid	<= 1'd0;
//			if      (cur_idle    ) begin
//			         shift_reg    <= 8'd0                       ;
//			end 
//			else if (cur_start   ) begin
//			    
//			end
//			else if (cur_data && sample_now) begin
//			        shift_reg     <= {rx_stable, shift_reg[7:1]};
//			end
//			else if (cur_stop && sample_now) begin
//				rx_data       <= shift_reg                  ;
//				rx_data_valid <= 1'b1                       ;
//			end
//			
//		end
//	end
	
//       always @(posedge clk or negedge rst_n)begin
//		if(!rst_n)begin
//			shift_reg	<= 8'd0;
//			rx_data		<= 8'd0;
//			rx_data_valid	<= 1'd0;
//		end  else begin
//			rx_data_valid	<= 1'd0;
//			case(state)
//			idle: shift_reg <= 8'd0;
//
//			data:begin
//				if(sample_now)begin
//					shift_reg	<={rx_stable, shift_reg[7:1]};
//				end
//			end
//			stop:begin
//				if(sample_now)begin
//					rx_data		<= shift_reg;
//					rx_data_valid	<= 1'b1;
//				end		
//			end
//			endcase
//		end
//	end
        
        wire cur_idle                                  ; 
        wire cur_start                                 ;
        wire cur_data                                  ;
        wire cur_stop                                  ;
        wire data_shift                                ;
        wire data_out_pulse                            ;

       assign cur_idle       = (state == idle )        ;
       assign cur_start      = (state == start)        ;
       assign cur_data       = (state == data )        ;
       assign cur_stop       = (state == stop )        ;
       assign data_shift     = (cur_data && sample_now);
       assign data_out_pulse = (cur_stop && sample_now);

	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			        cnt <= 3'd0            ;
		end 
		else if(cur_stop)begin
				cnt <= 3'd0            ;
		end 
		else if(data_shift)begin
				cnt <= cnt + 1'b1      ;
		end


	end

//	always @(posedge clk or negedge rst_n)begin
//		if(!rst_n)begin
//			cnt <= 3'd0;
//		end else begin
//			if(state==data)begin
//				if(sample_now)begin
//					if(cnt==3'd7)begin
//						cnt <= 3'd0;
//					end else begin
//						cnt <= cnt + 1'b1;
//					end
//				end
//			end else begin
//				cnt <= 3'd0;
//			end
//		end
//	end
endmodule
