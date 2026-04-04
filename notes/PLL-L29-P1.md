# PLL-L29-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L29-P1.jpg

---


---
## 高頻除頻器替代方案：Miller Divider (Regenerative Divider) 與延遲效應

### 數學推導
傳統的 Static Divider (如使用 CML Flip-Flop 搭配 Inductive Peaking) 在極高頻 (20~40GHz) 下會遇到效能瓶頸，因此需要替代方案，如 Injection Locked Divider 或本頁介紹的 **Miller Divider (Regenerative Divider)**。

我們來推導一個只有 Mixer 和 Low Pass Filter (LPF) 的理想 Miller Divider 為什麼**無法運作**：
1. **建立 LPF 微分方程式：**
   假設 LPF 由 $R_1, C_1$ 組成，輸入為 Mixer 的輸出，輸出為 $y(t)$。
   $$V_{mix\_out}(t) = y(t) + R_1 C_1 \frac{dy(t)}{dt}$$
2. **代入 Mixer 的行為：**
   Mixer 將外部輸入 $x(t)$ 與回授信號 $y(t)$ 相乘，並有一個轉換增益 $\beta$。
   $$V_{mix\_out}(t) = \beta \cdot x(t) \cdot y(t)$$
3. **假設輸入為弦波：**
   令 $x(t) = A\cos(\omega_{in}t)$，代入方程式中：
   $$R_1 C_1 \frac{dy(t)}{dt} + y(t) = \beta \cdot A\cos(\omega_{in}t) \cdot y(t)$$
4. **分離變數進行積分：**
   將 $y$ 移到等式左邊，$t$ 移到右邊：
   $$\frac{dy}{y} = \frac{\beta A \cos(\omega_{in}t) - 1}{R_1 C_1} dt$$
   兩邊同時對時間從 $0$ 積到 $t$：
   $$\int_{y(0)}^{y(t)} \frac{1}{y} dy = \int_0^t \left( \frac{\beta A \cos(\omega_{in}\tau)}{R_1 C_1} - \frac{1}{R_1 C_1} \right) d\tau$$
   $$\ln\left(\frac{y(t)}{y(0)}\right) = \left[ \frac{\beta A}{R_1 C_1 \omega_{in}} \sin(\omega_{in}\tau) - \frac{\tau}{R_1 C_1} \right]_0^t$$
   $$\ln\left(\frac{y(t)}{y(0)}\right) = \frac{\beta A}{R_1 C_1 \omega_{in}} \sin(\omega_{in}t) - \frac{t}{R_1 C_1}$$
5. **取指數得到 $y(t)$ 的時間函數：**
   $$y(t) = y(0) \cdot \exp\left[ \frac{\beta A}{R_1 C_1 \omega_{in}} \sin(\omega_{in}t) - \frac{t}{R_1 C_1} \right]$$
6. **結論：**
   觀察指數項，$\sin(\omega_{in}t)$ 是有界的週期函數，但 $- \frac{t}{R_1 C_1}$ 是一個隨時間線性遞減的項。這意味著隨著時間 $t \to \infty$，整體指數會趨向 $-\infty$，導致 $y(t)$ 衰減為 $0$ (decay to 0)。
   **因此，單純的 Mixer + LPF 是無法維持振盪的，必須加入一個額外的相位平移（Delay $\Delta T = \frac{\pi}{\omega_{in}}$）來確保回授信號的相位能產生正回授（滿足 Barkhausen criterion）。**

### 單位解析
**公式單位消去：**
- $R_1 C_1 \frac{dy}{dt}$：$[\Omega] \times [\text{F}] \times \frac{[\text{V}]}{[\text{s}]} = [\text{s}] \times [\text{V/s}] = [\text{V}]$ （符合電壓方程式）
- $V_{mix\_out} = \beta \cdot x(t) \cdot y(t)$：$[\text{V}] = \beta \times [\text{V}] \times [\text{V}]$，故推導出轉換增益 $\beta$ 的單位為 $[\text{V}^{-1}]$
- 指數內部 $\frac{t}{R_1 C_1}$：$\frac{[\text{s}]}{[\Omega \cdot \text{F}]} = \frac{[\text{s}]}{[\text{s}]} = [\text{Dimensionless}]$ （指數內部必須無單位）
- 指數內部 $\frac{\beta A}{R_1 C_1 \omega_{in}}$：$\frac{[\text{V}^{-1}] \cdot [\text{V}]}{[\text{s}] \cdot [\text{rad/s}]} = \frac{1}{1} = [\text{Dimensionless}]$ （完全正確）

**圖表單位推斷：**
📈 波形圖（方波）單位推斷：
- X 軸：時間 $t$ $[\text{ps}]$，考慮到 40GHz 輸入，週期為 25ps，X 軸典型範圍約為 0 ~ 100 ps。
- Y 軸：邏輯準位 Voltage $[\text{V}]$，圖中標示 $+1, -1$ 代表正規化的擺幅，實際在 CML 電路中可能為 $\pm 300\text{mV}$。

### 白話物理意義
把高頻訊號跟除頻後的自己相乘，如果時間沒對準（沒有 delay），能量會被低通濾波器一點一滴吃掉直到歸零；加上剛好半個週期的延遲，就能讓訊號「自我增強」，成功變成除以二的頻率。

### 生活化比喻
想像你在推一個盪鞦韆（LPF 的慣性）。Mixer 就是你推的動作，如果你不看鞦韆的位置，只是一直盲目地出力（沒有 Delay 控制相位），你的力量有時幫忙推、有時反而擋住鞦韆，最後鞦韆因為摩擦力就停下來了（Decay to 0）。你必須「延遲」你的動作，看準鞦韆盪回來的那一瞬間推下去（加入 $\Delta T$），才能維持鞦韆規律的擺動。

### 面試必考點
1. **問題：為什麼高頻 Divider 要從 Static (CML FF) 換成 Miller Divider？** 
   → 答案：因為 DFF 迴路內有兩個 Latch 組成的回授，其內部的寄生 RC delay 會限制最高操作頻率（即使加了 Inductor Peaking 到了 40GHz 也是極限）。Miller Divider 迴路只有 Mixer 和 LPF，延遲少，適合毫米波等極高頻應用。
2. **問題：如果一個 Miller Divider 只有理想的 Multiplier 和一個單極點 LPF，它能震盪嗎？為什麼？** 
   → 答案：不能。從微分方程推導可知，其響應包含一個 $e^{-t/RC}$ 的包絡線，信號最終會衰減至零。必須在迴路中引入足夠的額外 Delay（提供相移），使其在目標除頻頻率滿足 Barkhausen 振盪條件。
3. **問題：在實體電路中，Miller Divider 的 Mixer 通常用什麼電路實現？Delay 從哪裡來？** 
   → 答案：通常使用 Gilbert Cell 實現 Mixer（如筆記下方的 Bipolar 與 CMOS 電路圖）。Delay 通常來自於 LPF 本身的高階極點，或是電晶體的寄生電容與佈線延遲，有時也會刻意加入一個 Delay Cell 或使用多階 LPF。

**記憶口訣：**
**「Miller 除頻靠相乘，沒加 Delay 會歸零」**（Mixer相乘、LPF濾波、必須有Delay才能自我維持振盪）。
