# LA-L11-P1

> 分析日期：2026-04-06
> 原始圖片：images/done/LA-L11-P1.jpg

---


---
## PRBS 產生器與其頻譜特性 (PRBS Generation and Spectrum)

### 數學推導
1. **PRBS 序列長度 (Sequence Length)**：
   - 使用線性回饋移位暫存器 (LFSR, Linear Feedback Shift Register) 搭配本原多項式 (Primitive Polynomial) 產生的虛擬隨機二進位序列 (PRBS)。
   - 序列週期長度 $L = 2^n - 1$，其中 $n$ 為移位暫存器的級數。
   - 為什麼減 1？因為必須排除「全 0 狀態」(All-Zero State)。若所有 D 型正反器 (DFF) 皆為 0，經過 XOR 邏輯閘回饋的結果仍為 0，系統會卡死在全 0 狀態無法逃脫 (Lock-up)。
2. **時域訊號表示法**：
   - 一個 NRZ (Non-Return-to-Zero) 的 PRBS 訊號可以看作是「週期性脈衝序列 (Impulse Train)」與「單位方波 $p(t)$」的摺積 (Convolution)。
   - $y(t) = \left( \sum_{k} a_k \cdot \delta(t - k T_b) \right) * p(t)$
   - 其中 $a_k$ 為 PRBS 序列 ($\pm 1$)，$T_b$ 為一個 Bit 的時間長度 (Bit Period)。$p(t)$ 是一個寬度為 $T_b$、高度為 1 的矩形脈衝。
3. **頻域頻譜分析 (傅立葉轉換)**：
   - 根據摺積定理，時域的摺積等於頻域的相乘：$Y(f) = \mathcal{F}\{\text{Impulse Train}\} \times \mathcal{F}\{p(t)\}$
   - 因為 PRBS 是週期為 $T = (2^n - 1)T_b$ 的訊號，其脈衝序列的頻譜是一系列離散的頻譜線 (Spurs/Tones)，間距為 $\Delta f = \frac{1}{T} = \frac{1}{(2^n - 1)T_b}$。
   - 方波 $p(t)$ 的傅立葉轉換為 Sinc 函數：$P(f) = T_b \cdot \text{sinc}(f T_b) = T_b \cdot \frac{\sin(\pi f T_b)}{\pi f T_b}$。
   - 最終 PRBS 的頻譜是一個被 Sinc 函數包絡線 (Envelope) 塑形的離散梳狀頻譜。在主瓣 (Main lobe，即 $0 \sim \frac{1}{T_b}$ 之間) 內，總共有 $2^n - 1$ 根頻譜線。

### 單位解析
**公式單位消去：**
- **頻譜線間距 (Resolution / Tone Spacing) $\Delta f = \frac{1}{(2^n - 1) T_b}$**
  - $T_b$: 位元週期，單位 [s]
  - $2^n - 1$: 狀態數量，無單位
  - $\Delta f = \frac{1}{[s]} = [\text{Hz}]$
- **Sinc 包絡線零點頻率 $f_{null} = \frac{1}{T_b}$**
  - $f_{null} = \frac{1}{[s]} = [\text{Hz}]$ （這剛好對應 Data Rate，例如 $T_b = 100\text{ps}$，則 Data Rate = 10Gbps，零點在 10GHz）

**圖表單位推斷：**
1. 📈 **時域波形圖 (LFSR 輸出與方波)**：
   - X 軸：時間 $t$ [s] 或 [UI] (Unit Interval)，典型範圍 $0 \sim 10$ UI。
   - Y 軸：電壓 [V] 或邏輯準位，典型範圍 0 ~ VDD 或 -1 ~ +1 (Differential)。
2. 📈 **頻域頻譜圖 (Spectrum of PRBS)**：
   - X 軸：頻率 $f$ [Hz]，標記點為 $\frac{1}{(2^n-1)T_b}$ (Tone 間距), $\frac{1}{T_b}$ (第一零點), $\frac{2}{T_b}$ (第二零點)。典型範圍 DC ~ 數倍 Data Rate。
   - Y 軸：功率譜密度 (PSD) 或振幅大小 [dBm] 或 [V/Hz]。呈現離散的箭頭 (Delta functions) 且受 Sinc 形狀限制。

### 白話物理意義
PRBS 看似隨機，其實會不斷重複；所以它的頻譜不是連續的實心板，而是一根一根離散的「梳子齒」，被裝在一個叫做 Sinc 函數的圓弧形「套子」裡。PRBS 的階數 $n$ 越大，重複週期越長，這把梳子的齒就越密，越接近真實隨機資料。

### 生活化比喻
想像你要畫一片「連綿不斷的草皮 (真實隨機訊號的連續頻譜)」。
如果你用 $n=3$ 的 PRBS，你就是在地上每隔 1 公尺插一根草 (頻譜線很稀疏)。
如果你用 $n=31$ 的 PRBS，你就是在地上每隔 0.001 毫米插一根草 (頻譜線極度密集)。
退到遠處看，插得極密的草看起來就像是一整片真實的連續草皮，這就是為什麼高等級的 PRBS 能用來逼真地模擬真實的資料流。

### 面試必考點
1. **問題：LFSR (Linear Feedback Shift Register) 為什麼會發生「全 0 死結 (Lock-up)」？在 IC 設計中如何解決？**
   → **答案：** 因為由 XOR 閘構成的回饋網路，輸入全 0 則輸出為 0，下一個 Clock 狀態仍為全 0，無法跳脫。解法是在硬體設計上加入偵測邏輯（例如把前 $n-1$ 個 bit 接到 NOR 閘，當全是 0 時，強迫向最後一個 DFF 塞入 1），確保系統能自動從死結中恢復。
2. **問題：在測試 High-Speed SerDes 時，為什麼規格常要求使用 PRBS31 而不是 PRBS7？兩者在頻譜上有何差異？**
   → **答案：** PRBS31 的頻譜線間距極小，在主瓣內有 $2^{31}-1$ 根頻率成分，包含極低頻的成分。這對於測試系統的「低頻極限」非常關鍵，例如 AC Coupling 電容造成的 Baseline Wander (基線漂移)，或是 PLL/CDR 對於極低頻 Jitter 的追蹤能力。PRBS7 頻率成分太稀疏，無法激發出這些 Low-frequency pattern dependent 的問題。
3. **問題：NRZ 訊號的頻譜為什麼在等於 Data Rate ($1/T_b$) 的地方會有一個 Null (零點)？**
   → **答案：** 因為 NRZ 訊號在時域的本質上是「理想脈衝」與「寬度為 $T_b$ 的方波」的摺積。時域的摺積等於頻域的相乘。寬度 $T_b$ 的方波經過傅立葉轉換後是 $\text{sinc}(fT_b)$ 函數，$\text{sinc}$ 函數的零點正好就落在 $1/T_b$ 及其整數倍的位置。

**記憶口訣：**
「全零死結加 NOR 解，階數越高齒越密，Sinc 包絡定輪廓，零點就在 Data Rate。」
