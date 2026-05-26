## 📂 模組職責說明 (Module Description)

### 1. 2-FF 同步器 (`uart_sync`)
由於 UART 屬於非同步通訊（Asynchronous），外部輸入的 `rx_in` 與晶片內部的系統時脈不同源，會帶來亞穩態（Metastability）風險。此模組採用兩級 D 型正反器（D-FF）進行跨時脈域打拍，將訊號「解毒」洗白為安全的內部導線 `rx_stable`。

### 2. 起始邊緣偵測器 (`uart_edge_det`)
持續比對 `rx_stable` 當前拍與上一拍的狀態。當發現電位從 `1` 掉到 `0` 時，觸發一個持續僅一拍（20ns）的高電位脈衝 `start_edge`，作為全系統的「起跑點火訊號」。

### 3. 波特率 16 倍過取樣計時器 (`uart_baud_tick`)
負責將 9600 鮑率下的單個 bit 物理時間切分為 16 格（ticks）。
* 核心常數：`CLK_PER_TICK = 325` (50MHz / (9600 * 16))。
* **中點抽查機制（關鍵防禦）：** 內部計數器走到第 8 格（`tick_cnt == 7`）時（此時處於 Start Bit 的正中間），睜開眼睛抽查 `rx_stable`：
  * 若為 `1`：判定為突發短暫突波雜訊，噴出 `glitch_detected` 自動斷電清零，系統毫無波動。
  * 若為 `0`：判定為真貨資料，噴出 `sample_now` 通知狀態機。

### 4. 有限狀態機大腦 (`uart_rx_FSM`)
控制核心與資料路徑（Data Path）的實作。採用雙緩衝機制（Double Buffering），移位暫存器 `shift_reg` 在後台利用 `{rx_stable, shift_reg[7:1]}` 進行串列轉並列組裝，只有在 `STOP` 狀態確定定稿時，才一口氣拋給外部暫存器 `rx_data`，確保輸出端訊號絕不產生過渡跳變。

---

## 🔌 頂層接口訊號定義 (Top-Level Pin-out)

| 訊號名稱 | I/O 方向 | 位元寬度 | 物理功能說明 |
| :--- | :--- | :---: | :--- |
| `clk` | Input | 1 | 50MHz 系統主時脈輸入 |
| `rst_n` | Input | 1 | 非同步系統重置（低電位有效 0:Reset） |
| `rx_in` | Input | 1 | 連接硬體引腳的非同步 UART RX 實體訊號線 |
| `rx_data` | Output | 8 | 接收完成並組裝好的 8-bit 平行資料匯流排 |
| `rx_data_valid` | Output | 1 | 接收完成通知脈衝（亮起一拍 1 代表資料可以被抓取） |

---

## 🧪 模擬與驗證 (Simulation & Testbench)

本專案內建了兩套完整的模擬平台，分別用於進行**局部大腦體檢**與**全系統端到端驗證**。

### 1. 檔案清單
* `uart_rx_FSM.v`：核心狀態機與資料移位模組
* `uart_baud_tick.v`：計時與中點抽查防禦模組
* `uart_edge_det.v`：負沿起跑點火模組
* `uart_rx_top.v`：全積木合體頂層模組
* `tb_uart_rx_FSM.v`：大腦 FSM 單獨測試平台
* `tb_uart_top.v`：全系統端到端總測試平台

### 2. 使用 Icarus Verilog 與 GTKWave 進行模擬

請確保你的開發環境已安裝 `iverilog` 與 `gtkwave`。

#### 執行全系統總測試 (End-to-End Simulation)
```bash
# 1. 編譯頂層模組與總測試平台
iverilog -o sim_top.vvp uart_rx_top.v uart_edge_det.v uart_baud_tick.v uart_rx_FSM.v tb_uart_top.v

# 2. 執行硬體模擬
vvp sim_top.vvp

# 3. 開啟波形圖
gtkwave uart_top_wave.vcd &
