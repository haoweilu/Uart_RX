`timescale 1ns / 1ps

module tb_uart_rx_FSM();

    // 1. 宣告連接到被測 FSM 的訊號
    reg        clk;
    reg        rst_n;
    reg        rx_stable;
    reg        sample_now;
    reg        glitch_detected;
    
    wire [7:0] rx_data;
    wire       rx_data_valid;

    // 2. 實例化你的 FSM 模組
    uart_rx_FSM u_fsm (
        .clk             (clk),
        .rst_n           (rst_n),
        .rx_stable       (rx_stable),
        .sample_now      (sample_now),
        .glitch_detected (glitch_detected),
        .rx_data         (rx_data),
        .rx_data_valid   (rx_data_valid)
    );

    // 3. 產生 50MHz 系統時脈 (週期 20ns)
    always #10 clk = ~clk;

    // 4. 主要測試流程
    integer i;
    reg [7:0] test_pattern;

    initial begin
        // 設定波形輸出
        $dumpfile("fsm_wave.vcd");
        $dumpvars(0, tb_uart_rx_FSM);

        // 初始狀態：UART 閒置時為高電位，控制脈衝皆為 0
        clk             = 0;
        rst_n           = 0;
        rx_stable       = 1'b1;
        sample_now      = 1'b0;
        glitch_detected = 1'b0;

        // 執行系統重置
        #100;
        rst_n = 1;
        #40;

        // ========================================================
        // 實驗一：傳送真貨字元 8'h5A (二進制: 8'b0101_1010)
        // LSB 先傳順序: 0 -> 1 -> 0 -> 1 -> 0 -> 1 -> 0 -> 1
        // ========================================================
        $display("[%0t ns] ======= 實驗一：開始測試真貨接收 =======", $time);
        test_pattern = 8'h5A;

        // 【步驟 A】 降臨 Start Bit (rx_stable 變 0)
        // 這一拍大腦應該要從 idle 變 start
        rx_stable = 1'b0; 
        #20; 

        // 【步驟 B】 模擬計時器在第 8 格抽查通過，噴出 sample_now 脈衝
        // 這一拍大腦應該要從 start 變 data
        sample_now = 1'b1;
        #20;
        sample_now = 1'b0;
        #100; // 模擬格子中間的空白時間

        // 【步驟 C】 依序傳送 8 個 Data bits
        // 每隔一段時間，我們就換下一個 bit，並讓 sample_now 彈起來一拍
        for (i = 0; i < 8; i = i + 1) begin
            rx_stable = test_pattern[i]; // 把 bit 放到線路上
            #100;                         // 讓線路穩定一下
            
            sample_now = 1'b1;            // 模擬計時器在 bit 正中間高喊 sample_now!
            #20;
            sample_now = 1'b0;            // 脈衝放完
            #100;                         // 走完這個 bit 的剩餘時間
        end

        // 【步驟 D】 進到 Stop Bit 狀態 (rx_stable 彈回 1)
        rx_stable = 1'b1;
        #100;
        
        // 模擬計時器在 Stop bit 正中間發出最後一發 sample_now
        // 這一拍 rx_data 應該定稿，且 rx_data_valid 應該拉高一拍，大腦隨後回 idle
        sample_now = 1'b1;
        #20;
        sample_now = 1'b0;

        #200; // 讓大腦在 idle 休息一下下

        // ========================================================
        // 實驗二：測試「雜訊防禦」
        // ========================================================
        $display("[%0t ns] ======= 實驗二：開始測試雜訊防禦 =======", $time);
        
        // 模擬線路短暫掉到 0 (誤以為是 Start Bit)
        // 大腦從 idle 跳進 start
        rx_stable = 1'b0;
        #20;

        // 模擬計時器走到第 8 格發現是假貨，大喊 glitch_detected!
        // 這一拍大腦應該要乖乖跳回 idle，不能進 data
        glitch_detected = 1'b1;
        #20;
        glitch_detected = 1'b0;
        rx_stable = 1'b1; // 線路彈回高電位

        #200;
        $display("[%0t ns] FSM 專屬測試全部結束！", $time);
        $finish;
    end

    // 5. 監聽螢幕輸出
    always @(posedge clk) begin
        if (rx_data_valid) begin
            $display("--------------------------------------------------");
            $display("[%0t ns] 🎉 FSM 大腦成功解鎖並定稿輸出！", $time);
            $display("         解出數值 rx_data = 8'h%h", rx_data);
            $display("--------------------------------------------------");
        end
    end

endmodule
