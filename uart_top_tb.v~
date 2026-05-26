`timescale 1ns / 1ps

module tb_uart_top();

    // 1. 宣告連接到 Top 模組的訊號
    reg        clk;
    reg        rst_n;
    reg        rx_in;
    wire [7:0] rx_data;
    wire       rx_data_valid;

    // 2. 實例化你的頂層合體模組 (Top Module)
    uart_rx_FSM u_uart_rx (
        .clk           (clk),
        .rst_n         (rst_n),
        .rx_in         (rx_in),
        .rx_data       (rx_data),
        .rx_data_valid (rx_data_valid) // 修正：確保結尾語法乾淨
    );

    // 3. 產生 50MHz 系統時脈 (週期 20ns)
    always #10 clk = ~clk;

    // 4. 定義一個實體 bit 在 9600 鮑率下的持續時間
    localparam BIT_PERIOD = 104167; 

    // 5. 模擬發送一個完整 UART Byte 的任務 (Task)
    task send_uart_byte;
        input [7:0] data;
        integer i;
        begin
            $display("[%0t ns] ---> 開始傳送 Byte: 8'h%h", $time, data);
            
            // ===== A. 傳送 Start Bit (低電位 0) =====
            rx_in = 1'b0;
            #BIT_PERIOD;
            
            // ===== B. 傳送 8-bit Data =====
            for (i = 0; i < 8; i = i + 1) begin  // 修正：修正迴圈語法
                rx_in = data[i]; 
                #BIT_PERIOD;
            end                                  // 修正：正確的 end 結尾
            
            // ===== C. 傳送 Stop Bit (高電位 1) =====
            rx_in = 1'b1;
            #BIT_PERIOD;
            
            $display("[%0t ns] ---> Byte 傳送完畢並回到閒置狀態", $time);
        end
    endtask

    // 6. 主要測試流程
    initial begin
        // 設定 GTKWave 輸出檔案
        $dumpfile("uart_top_wave.vcd");
        $dumpvars(0, tb_uart_top);

        // 初始狀態
        clk   = 0;
        rst_n = 0;
        rx_in = 1'b1;

        // 執行系統重置
        #100;
        rst_n = 1;
        #200; 

        // 傳送字元 'A' (8'h41)
        send_uart_byte(8'h41);

        #50000; 

        // 傳送字元 'B' (8'h42)
        send_uart_byte(8'h42);

        #100000;
        $display("[%0t ns] 全系統總模擬測試結束！", $time);
        $finish;
    end

    // 7. 監聽螢幕輸出
    always @(posedge clk) begin
        if (rx_data_valid) begin
            $display("==================================================");
            $display("[%0t ns] 🎉 晶片成功接收到資料！", $time);
            $display("         收到數值 rx_data = 8'h%h (ASCII 字母: %c)", rx_data, rx_data);
            $display("==================================================");
        end
    end

endmodule
