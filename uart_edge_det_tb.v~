`timescale 1ns / 1ps

module uart_edge_det_tb();

	reg clk;
	reg rst_n;
	reg rx_sync1;

	wire start_edge;

	uart_edge_det u_dut(
		clk,
		rst_n,
		rx_sync1,
		start_edge
	);

	always #10 clk = ~clk;

	initial begin

		$dumpfile("edge_wave.vcd");
		$dumpvars(0, uart_edge_det_tb);


		clk		= 0;
		rst_n		= 0;
		rx_sync1 	= 1;

		#35;
		rst_n		= 1;
		#25;

		#15;
		rx_sync1	= 0;

		#65;

		rx_sync1	= 1;

		#45;

		$display("edge detector simlation finished");
		$finish;

	end

endmodule
