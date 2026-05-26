module uart_edge_det(
	input clk,
	input rst_n,
	input rx_sync1,
	output start_edge
);

	reg rx_reg;

	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			rx_reg <= 1'b1;
		end else begin
			rx_reg <= rx_sync1;
		end
	end

	assign start_edge = (rx_sync1 ==0) && (rx_reg ==1);

endmodule
