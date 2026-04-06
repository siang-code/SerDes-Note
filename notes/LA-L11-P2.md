# LA-L11-P2

> 分析日期：2026-04-06
> 原始圖片：images/done/LA-L11-P2.jpg

---


---
## 高速 PRBS 產生器設計瓶頸與眼圖頻寬效應 (LFSR Feedback Delay & Bandwidth limits)

### 數學推導
筆記中探討了線性回饋移位暫存器（LFSR）在實作 PRBS（偽隨機二進位數列）時的硬體極限。
給定多項式 $P(x) = x^{16} + x^{14} + x^{13} + x^{11} + 1$，這代表我們需要將第 16、14、13、11 級的暫存器輸出進行 XOR 運算，再回饋到第一級。

1. **Full-Rate 系統的時序限制 (Timing Constraint):**
   在一個同步系統中，時脈週期 $T_{clk}$ 必須大於資料路徑上的總延遲，才能避免 Setup Time Violation。
   $$T_{clk} \ge T_{cq} + T_{logic} + T_{setup} + T_{routing}$$
   其中：
   * $T_{cq}$ = Flip-Flop 的 Clock-to-Q 延遲
   * $T_{logic}$ = 組合邏輯延遲，此處為回授路徑上的 XOR Gate 延遲總和。
   * $T_{setup}$ = Flip-Flop 的 Setup Time

2. **XOR 串聯造成的 Critical Path:**
   如筆記圖示，4 個 Tap 需要 3 個 XOR gate 串聯來完成加總（GF(2) 加法）。
   $$T_{logic} = 3 \times T_{XOR}$$
   因此，系統的最高操作頻率 $f_{max}$ 被嚴重限制：
   $$f_{max} = \frac{1}{T_{clk, min}} \le \frac{1}{T_{cq} + 3 \cdot T_{XOR} + T_{setup}}$$
   當我們設計 28Gbps 或更高的 SerDes 時，$T_{clk}$ 只有約 35.7ps，光是 3 個 XOR 的延遲就可能吃光所有的 Timing Margin。

3. **解法：Half-Rate 架構:**
   如果採用 Half-Rate (半速率) 架構，內部電路以資料速率的一半運行，最後再透過 2:1 MUX 組合。
   $$T_{clk, internal} = 2 \times T_{clk, data}$$
   這時 Critical path 獲得了雙倍的時間裕度：
   $$2 \times T_{clk, data} \ge T_{cq} + 3 \cdot T_{XOR} + T_{setup}$$
   大大降低了高速電路的設計難度。

### 單位解析
**公式單位消去：**
* 頻率與週期的倒數關係：$f_{max} \text{ [Hz]} = \frac{1}{T_{clk} \text{ [s]}}$
* 單位展開：$\text{[Hz]} = \text{[s]}^{-1} = \frac{1}{\text{[s]} + \text{[s]} + \text{[s]}}$。在高速 IC 中，時間單位通常代入 $\text{[ps]} (10^{-12}\text{s})$，頻率單位會自然對應到 $\text{[THz]}$，但習慣上以 $\text{[GHz]} (10^9\text{Hz})$ 表示。例如 $T=100\text{ps}$，則 $f = \frac{1}{100\times 10^{-12}} = 10\times 10^9\text{Hz} = 10\text{GHz}$。

**圖表單位推斷：**
* **左側眼圖 (Eye Diagrams)：**
  * **X 軸：** 時間 (Time) $\text{[UI]}$ (Unit Interval) 或 $\text{[ps]}$。典型範圍：$1 \sim 2 \text{ UI}$。
  * **Y 軸：** 電壓幅值 (Voltage Swing) $\text{[mV]}$ 或 $\text{[V]}$。對於差動訊號 (Differential)，典型範圍在 $\pm300\text{mV} \sim \pm1\text{V}$ 之間。
* **物理意義對應：** 從 `Input` (完美方波) 到 `Main lobes only`，X 軸的時間抖動 (Jitter) 增加導致交會點變粗；Y 軸的轉態時間 (Rise/Fall time) 變慢導致波形變圓，這反映了系統的高頻頻寬受限。

### 白話物理意義
完美方波需要無限的頻寬，頻寬不夠（高頻被砍掉）方波就會變「圓」；而在電路實作中，XOR 邏輯閘串聯太多會造成嚴重的「塞車」（Gate Delay），導致晶片跑不到高速，必須拓寬車道（平行處理：Half-rate）。

### 生活化比喻
想像一個傳話遊戲（Shift Register），最後一個人要把密碼傳給隊伍第一個人（回饋）。
如果中間還要經過三個人（3個 XOR gate）幫忙翻譯加密，傳遞速度一定快不起來，這就是 **Gate Delay 限制**。
怎麼解決？
1. **不要那麼多翻譯員**：換一個只需要翻譯一次的密碼規則（只用 1 個 XOR 的多項式）。
2. **兩班制輪流算**：不要大家擠在同一秒鐘傳遞，我們分成單雙號兩組人馬，給每一組多一倍的時間去翻譯（Half-Rate 架構），最後再把結果合併，這樣就不會超時了。

### 面試必考點
1. **問題：在設計高速 SerDes BIST (Built-In Self-Test) 時，為什麼業界愛用 PRBS-7 或 PRBS-31，而盡量避免使用 PRBS-16 等某些特定長度的數列？**
   * **答案：** 從電路實現（Timing closure）角度來看，PRBS-7 ($x^7+x^6+1$) 和 PRBS-31 ($x^{31}+x^{28}+1$) 的特徵多項式只有三個項（兩個 Tap），這意味著回授路徑只需要「1個 XOR gate」。如筆記所述，XOR 串聯越多，Gate delay 越長，會嚴重限制系統的最高操作頻率。PRBS-16 這種需要多個 XOR 串聯的架構，在 Full-rate 極高頻下難以滿足 Setup time requirement。
2. **問題：當你的 PRBS 產生器因為 XOR gate delay 太長，導致時序違規 (Timing Violation) 時，架構上可以如何改良？**
   * **答案：** 筆記中明確指出兩個方向：(1) **減少邏輯深度 (不要超過一個 XOR)**：重新評估是否能用 Pipeline 分解邏輯，或替換多項式。(2) **採用平行化架構 (降頻)**：改用 Half-rate 或 Quarter-rate 架構。利用較慢的時脈（$f_{clk}/2$ 或 $f_{clk}/4$）來運算複雜的回授邏輯，最後再利用高速 2:1 或 4:1 Multiplexer 將多路低速資料組合出全速 (Full-rate) 的資料流。
3. **問題：觀察筆記左側的眼圖演進，為何濾除高頻成份（Main lobes only）後，眼圖的線條會「更圓」？這在通訊上會造成什麼問題？**
   * **答案：** 理想方波在頻域上是 Sinc function，包含無限多個高頻的 side lobes。當系統頻寬不足（如同一個 Low-pass filter），高頻的諧波被衰減，時域上的表現就是訊號無法瞬間轉態，Rise/Fall time 變長，邊緣變得圓滑。這會嚴重引入 ISI (Inter-Symbol Interference，符元間干擾)，導致眼圖的眼高（Voltage margin）與眼寬（Timing margin）縮小，增加 Bit Error Rate (BER)。

**記憶口訣：**
**「高速 PRBS 三原則：XOR 挑單個、跑不動就 Half-Rate、頻寬不夠眼變圓」**
