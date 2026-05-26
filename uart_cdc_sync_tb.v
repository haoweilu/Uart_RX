`timescale 1ns / 1ps

module tb_uart_sync();

	reg clk;
	reg rst_n;
	reg rx_in;

	wire rx_sync0;
	wire rx_sync1;



	uart_sync u_dut(
		clk,
		rst_n,
		rx_in,
		rx_sync0,
		rx_sync1
	);

	always #10 clk = ~clk;

	initial begin

		$dumpfile("sync_wave.vcd");
		$dumpvars(0, tb_uart_sync);
		
		clk	= 0;
		rst_n	= 0;
		rx_in	= 1;

		#35;
		rst_n	= 1;
		#25;

		#7;
		rx_in	= 0;

		#200;


		#3;
		rx_in	= 1;

		#100;
		$display("2-FF Sync Simluation Finished!");
		$finish;
	end
endmodule
