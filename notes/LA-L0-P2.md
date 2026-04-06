# LA-L0-P2

> 分析日期：2026-04-06
> 原始圖片：images/done/LA-L0-P2.jpg

---


---
## 訊號完整性基礎：Lone Pulse, ISI 與系統頻寬 (Bandwidth)

### 數學推導
本頁筆記涵蓋了高速 SerDes 領域最基礎且核心的訊號頻域特性與時域響應關係。

**1. 方波的頻譜本質 (Sinc 函數)**
*   在時域中，一個理想的孤立脈衝 (Lone Pulse) 可表示為寬度為 $T_b$ (Bit period) 的矩形函數：$x(t) = \text{rect}(\frac{t}{T_b})$
*   將其轉換至頻域 (Fourier Transform)，會得到一個 Sinc 函數：
    $$X(f) = T_b \cdot \text{sinc}(f T_b) = T_b \cdot \frac{\sin(\pi f T_b)}{\pi f T_b}$$
*   **DC 頻率 ($f = 0$)**：
    $$X(0) = T_b \cdot \lim_{x \to 0}\frac{\sin(x)}{x} = T_b \cdot 1 = T_b$$ （此為最大能量基準值）
*   **Nyquist 頻率 ($f = \frac{1}{2T_b}$)**：
    將 Nyquist 頻率代入公式：
    $$X\left(\frac{1}{2T_b}\right) = T_b \cdot \frac{\sin(\pi \cdot \frac{1}{2T_b} \cdot T_b)}{\pi \cdot \frac{1}{2T_b} \cdot T_b} = T_b \cdot \frac{\sin(\pi/2)}{\pi/2} = T_b \cdot \frac{1}{\pi/2} = T_b \cdot \frac{2}{\pi} \approx 0.636 T_b$$
    👉 **推導結論**：這是一個極重要的觀念！即使在**「完全沒有任何通道損耗 (0dB Channel Loss)」**的理想狀態下，方波在 Nyquist 頻率處的頻譜能量，天生就只剩下 DC 時的 $64\%$ (約 $-4\text{dB}$)。這不是衰減，是方波的物理本質！

**2. 通道損耗對時域波形的影響 (ISI 的產生)**
*   假設通道在 Nyquist 頻率有 $-10\text{dB}$ 的損耗：
    $$-10\text{dB} = 20 \log_{10}\left(\frac{V_{out}}{V_{in}}\right) \Rightarrow \frac{V_{out}}{V_{in}} = 10^{-0.5} \approx 0.316$$
*   此時 Nyquist 頻率成分只剩下原本的：$0.636 \times 0.316 \approx 0.201$
*   高頻成分大幅流失，等同於訊號經過一個低通濾波器 (Low Pass Filter)。在時域上，原本方正的脈衝會被「壓扁且拉長」。筆記中指出，主脈衝峰值降至約 $0.597 V_0$。
*   **能量守恆法則**：消失的 $\sim 40\%$ 能量 ($1.0 - 0.597 = 0.403$) 並沒有憑空蒸發，而是往後擴散，形成了拖延至下一個甚至下下個 Bit 週期 ($T_b, 2T_b...$) 的「長尾巴 (Tail)」。這些尾巴若疊加到相鄰的 Bit 上，就會造成嚴重的 **ISI (Inter-Symbol Interference，符碼間干擾)**。

**3. 頻寬 (BW) 與 上升時間 (Rise Time, $t_r$) 的經典公式推導**
*   **假設前提**：系統可近似為一階 (Single-Pole) RC 低通網路。
*   一階系統的步階響應 (Step Response) 公式：
    $$V_{out}(t) = V_{final}(1 - e^{-t/\tau}) \quad \text{(其中 } \tau = RC \text{)}$$
*   計算 10% 到 90% 的上升時間 $t_r$：
    *   到達 10% 的時間 $t_{10\%}$：$0.1 = 1 - e^{-t_{10\%}/\tau} \Rightarrow e^{-t_{10\%}/\tau} = 0.9 \Rightarrow t_{10\%} = -\ln(0.9)\tau \approx 0.105\tau$
    *   到達 90% 的時間 $t_{90\%}$：$0.9 = 1 - e^{-t_{90\%}/\tau} \Rightarrow e^{-t_{90\%}/\tau} = 0.1 \Rightarrow t_{90\%} = -\ln(0.1)\tau \approx 2.303\tau$
    *   上升時間 $t_r = t_{90\%} - t_{10\%} \approx (2.303 - 0.105)\tau \approx 2.198\tau \approx 2.2\tau$
*   一階系統的 $-3\text{dB}$ 頻寬公式：
    $$f_{-3\text{dB}} = BW = \frac{1}{2\pi\tau} \Rightarrow \tau = \frac{1}{2\pi BW}$$
*   將 $\tau$ 代入 $t_r$ 方程式：
    $$t_r = 2.2 \cdot \left(\frac{1}{2\pi BW}\right) = \frac{2.2}{2\pi} \cdot \frac{1}{BW} \approx \frac{0.35}{BW}$$
    👉 **推導結論**：得到業界黃金經驗公式 **$BW \cdot t_r = 0.35$**。

**4. 系統頻寬設計準則**
*   為了讓眼圖 (Eye Diagram) 水平張開 (減少 Jitter)，我們希望訊號邊緣足夠陡峭。
*   工程上常設定目標：希望上升時間 $t_r$ 只佔半個 Bit 週期，即 $t_r = \frac{T_b}{2}$。
*   代入剛推導的公式：
    $$BW = \frac{0.35}{t_r} = \frac{0.35}{T_b/2} = \frac{0.7}{T_b}$$
    因為 Data Rate (DR) = $1/T_b$，所以得出 **$BW \approx 0.7 \times \text{Data Rate}$**。
*   若系統頻寬只等於 Nyquist 頻率 ($0.5 \text{ DR}$)，波形會變成純弦波，眼圖會呈現閉合。頻寬拉到 $0.7 \text{ DR}$ 能夠包含更多高頻諧波 (Harmonics)，使得轉態邊緣變陡，有效打開眼圖。

### 單位解析
**公式單位消去：**
*   **Nyquist 頻率：** $f_{nyq} = \frac{1}{2T_b}$
    *   $[1] / [\text{s}] = [\text{Hz}]$
*   **RC 時間常數：** $\tau = R_{eq}C_{eq}$
    *   $R$ 的單位是 $[\Omega] = [\text{V}/\text{A}]$， $C$ 的單位是 $[\text{F}] = [\text{A}\cdot\text{s}/\text{V}]$
    *   $[\text{V}/\text{A}] \times [\text{A}\cdot\text{s}/\text{V}] = [\text{s}]$
*   **頻寬與上升時間：** $BW \cdot t_r = 0.35$
    *   $[\text{Hz}] \times [\text{s}] = [1/\text{s}] \times [\text{s}] = [\text{無因次 Dimensionless}]$ (0.35 是一個常數比例)
*   **頻寬與資料傳輸率：** $BW = 0.7 \cdot \text{Data Rate}$
    *   Data Rate 單位是 $[\text{bps}] \approx [\text{bits}/\text{s}] \sim [1/\text{s}]$，所以 BW 單位是 $[1/\text{s}] = [\text{Hz}]$

**圖表單位推斷：**
*   📈 **圖表 1 (左上矩形波)：**
    *   X 軸：時間 [UI 或 ps]，典型範圍 $1$ UI (例如 28Gbps 下為 35.7ps)
    *   Y 軸：電壓 [V 或 mV]，典型範圍滿幅如 $800$mVppd
*   📈 **圖表 2 (右上 Sinc 頻譜)：**
    *   X 軸：頻率 [GHz]，標示了 $f = 1/(2T_b)$ 的 Nyquist 頻率位置
    *   Y 軸：振幅比例 [無因次或 V/Hz]
*   📈 **圖表 3 (左下單一脈衝衰減與拖尾)：**
    *   X 軸：時間 [$T_b$]，展示了 $0, T_b, 2T_b$ 區間
    *   Y 軸：電壓 [V]，標示了能量從理想 $V_0$ 掉到 $0.597V_0$
*   📈 **圖表 4 (中下波形交疊與 worst case eye)：**
    *   X 軸：時間 [UI]，展示多個 Bit 週期的波形疊加
    *   Y 軸：電壓 [V]，標示主標籤 $h_0$ 與 ISI 成分 $h_{-1}, h_1...$
*   📈 **圖表 5 (右下步階響應)：**
    *   X 軸：時間 [s 或 ps]，標示了 $10\%$ 到 $90\%$ 的時間差 $t_r$
    *   Y 軸：電壓百分比 [% 或 V]，從 $0$ 爬升至 $1\text{V}$

### 白話物理意義
數位方波是由無數高頻弦波組合而成，當通道像濾波器一樣砍掉這些高頻時，方波的直角邊緣就會變鈍，原本該在自己週期內結束的能量就會往後「拖泥帶水」，干擾到下一個訊號，這就是 ISI。

### 生活化比喻
把傳輸數位訊號想像成用卡車在高速公路上運送「完美的正方形果凍」。
這條高速公路有一段限高的「狹窄隧道」(這就是通道頻寬限制)。
當正方形果凍硬擠過限高隧道時（高頻成分被濾除），果凍方正的直角會被磨平，整顆果凍被向後拉長變形（Edge 變緩）。
因為果凍被拉長了，它的「尾巴」就會黏到後面那一顆果凍的「頭上」。當你站在終點想要分辨每一顆果凍的界線時，就會發現它們全部糊在一起了，這就是 ISI（符碼間干擾）。
工程師要做的，就是設計 EQ (等化器)，像刀子一樣把黏在一起的部分切掉，讓你重新看清楚（張開眼睛 / Eye Opening）每一顆獨立的果凍。

### 面試必考點
1. **問題：在無損耗 (Lossless) 的通道下傳輸方波，在 Nyquist 頻率處量測到的訊號振幅會是原本 DC 的多少？為什麼？**
   * **答案：** 約 63.6%。這是一個經典陷阱題。這不是因為通道衰減，而是因為方波在頻域的數學轉換是 Sinc 函數。Sinc 函數在第一 Nyquist 頻率 ($f = 1/2T_b$) 處的值天生就是 $2/\pi \approx 0.636$。
2. **問題：請推導 $BW \times t_r = 0.35$ 這個公式，並說明它的限制。**
   * **答案：** 這個公式是基於「一階 (Single-Pole) 系統」的假設。透過 RC 電路的步階響應公式 $1-e^{-t/\tau}$，計算出電壓從 10% 上升到 90% 所需的時間約為 $2.2\tau$。再將一階系統頻寬 $BW = 1/(2\pi\tau)$ 移項代入，即可得到 $BW \times t_r \approx 2.2 / 2\pi \approx 0.35$。若系統存在多個極點 (Multi-pole) 產生 peaking 等效應，此常數會改變。
3. **問題：Lone Pulse Pattern (如 00100) 和 Clock-like Pattern (如 010101)，哪一種圖案受 ISI 的影響更難處理？**
   * **答案：** Lone Pulse 通常更難處理且代表 Worst Case。對於 010101 這種高頻交替圖案，前後 bit 產生的 ISI 能量會因為極性相反（一正一負）而互相抵消。但對於連續多個 0 之後突然出現的單一 1 (00100)，其能量的拖尾 (Tail) 會在同一方向不斷疊加累積，嚴重侵蝕電壓餘裕 (Voltage Margin)，造成最小的眼高 (Worst Eye Height)。

**記憶口訣：**
> **「方波本質六三六，零點三五求頻寬。孤立脈衝尾巴長，疊加干擾最慘狀。」**
（解釋：方波在 Nyquist 天生剩 63.6%，用 $0.35$ 公式推估頻寬需求。Lone pulse 的長尾巴會產生同向疊加的 ISI，造成最糟的傳輸狀態。）
