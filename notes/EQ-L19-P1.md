# EQ-L19-P1

> 分析日期：2026-04-06
> 原始圖片：images/done/EQ-L19-P1.jpg

---


---
## 1-Tap DFE 於存在多個 Post-cursor 時的 MMSE 最佳化

### 數學推導
本頁筆記探討了一個非常進階且經典的面試題：「當通道存在多個 post-cursor ISI，但我們硬體上只能使用 1-tap DFE 時，這個 tap 的係數該怎麼設定？」
直覺上，如果第一個 post-cursor $h_1 = 0.2$，1-tap DFE 的權重 $\alpha_1$ 就該設為 0.2（這稱為 Zero-Forcing，ZF）。但在真實世界中，為了讓整體誤差最小（Minimum Mean Square Error, MMSE），答案並非如此。

**1. 定義系統參數**
- 通道脈衝響應 (Pulse Response)：
  - Main-cursor: $h_0 = 1$
  - 1st Post-cursor: $h_1 = 0.2$
  - 2nd Post-cursor: $h_2 = 0.1$
- 假設輸入資料序列 $x[n] \in \{0, 1\}$
- 1-tap DFE 輸出方程式：$y[n] = (x[n]h_0 + x[n-1]h_1 + x[n-2]h_2) - \alpha_1 \hat{x}[n-1]$
- 目標：最小化誤差平方的期望值 $\min E[e^2]$，其中 $e = y[n] - \hat{y}[n]$

**2. 窮舉所有歷史資料組合以計算期望值**
以當前要接收的資料為 "0" ($x[n]=0, \hat{y}[n]=0$) 為例，前兩筆資料 $\{x[n-2], x[n-1], x[n]\}$ 有 4 種可能（發生機率各 $1/4$）：
- $\{1, 1, 0\}$: $y[n] = (0\times1 + 1\times0.2 + 1\times0.1) - \alpha_1(1) = 0.3 - \alpha_1$
- $\{0, 1, 0\}$: $y[n] = (0\times1 + 1\times0.2 + 0\times0.1) - \alpha_1(1) = 0.2 - \alpha_1$
- $\{1, 0, 0\}$: $y[n] = (0\times1 + 0\times0.2 + 1\times0.1) - \alpha_1(0) = 0.1$
- $\{0, 0, 0\}$: $y[n] = (0\times1 + 0\times0.2 + 0\times0.1) - \alpha_1(0) = 0$

**3. 微分求極小值 (MMSE)**
將誤差平方相加並對 $\alpha_1$ 偏微分找極值：
$$E[e^2] = \frac{1}{4} \left[ (0.3-\alpha_1)^2 + (0.2-\alpha_1)^2 + (0.1)^2 + (0)^2 \right]$$
$$\frac{\partial E[e^2]}{\partial \alpha_1} = \frac{1}{4} \left[ 2(0.3-\alpha_1)(-1) + 2(0.2-\alpha_1)(-1) \right] = 0$$
$$-(0.3 - \alpha_1) - (0.2 - \alpha_1) = 0 \Rightarrow -0.5 + 2\alpha_1 = 0 \Rightarrow \boldsymbol{\alpha_1 = 0.25}$$

**結論：** 即便 $h_1$ 只有 0.2，為了「平均掉」無法被消除的 $h_2 = 0.1$ 所造成的影響，$\alpha_1$ 必須稍微**超補 (Over-equalize)** 到 0.25，這就是 MMSE 與 ZF 最大的差異！

---

### 單位解析
**公式單位消去：**
- 假設通道傳輸的訊號為電壓 $[V]$。
- $y[n] = x[n][V] \cdot h_0[V/V] + x[n-1][V] \cdot h_1[V/V] + x[n-2][V] \cdot h_2[V/V] - \hat{x}[n-1][V] \cdot \alpha_1[V/V]$
- 等式右邊每一項單位皆為 $[V] \times [無因次] = [V]$，與左邊的 $y[n]$ 單位 $[V]$ 相符。
- 誤差函數 $e^2 = (y - \hat{y})^2$，單位為 $[V^2]$。
- 對 $\alpha_1$ 取偏微分：$\frac{\partial e^2}{\partial \alpha_1} \Rightarrow \frac{[V^2]}{[V/V]} = [V^2]$，等式右邊設為 0，單位合理。

**圖表單位推斷：**
📈 **1. 左上角 Pulse Response 圖**
- X 軸：時間 $t$ $[UI]$ (Unit Interval，位元週期)。
- Y 軸：訊號振幅 $x(t)$ $[V]$ 或歸一化振幅 (無因次)。
📈 **2. 下方 $x[n]$ (傳送端資料) 序列圖**
- X 軸：離散時間 index $n$ $[UI]$。
- Y 軸：邏輯準位振幅 $[V]$，圖中範圍為 0 到 1.0 $[V]$。
📈 **3. 下方 $y[n]$ (經過 DFE 後接收端) 序列圖**
- X 軸：離散時間 index $n$ $[UI]$。
- Y 軸：等化後振幅 $[V]$。觀察圖中數值如 0.95, 1.05, 0.05, -0.05，完美驗證了使用 $\alpha_1 = 0.25$ 等化後，眼圖的 inner eye opening 被最大化。

---

### 白話物理意義
當你手邊的武器（DFE tap）不夠多，無法消滅所有敵人（ISI）時，最聰明的策略不是「一對一精準打擊（Zero-Forcing）」，而是「擴大打擊範圍（MMSE）」，寧可對第一名敵人用力過猛，藉此波及並減弱第二名敵人造成的總體傷害。

---

### 生活化比喻
想像你要清理房間裡的漏水（ISI）。天花板有兩個洞，1 號洞每秒漏 0.2 公升，2 號洞每秒漏 0.1 公升。
但你只有一個塞子（1-tap DFE），且只能塞在 1 號洞。
如果你的目標是「讓地板最乾（MMSE）」，你不該只準備剛好吸收 0.2 公升的力道。你應該用 0.25 公升的力道去堵 1 號洞，讓水稍微反彈流走，藉由這種「超補償」來抵消掉 2 號洞滴下來的水，最終達到整體災情最小化。

---

### 面試必考點

1. **問題：如果通道的 post-cursor 為 $h_1 = 0.3, h_2 = 0.2$，但你只設計了 1-tap DFE，請問該 tap 的權重最佳值會大於、等於還是小於 0.3？為什麼？**
   - **答案：** 會大於 0.3。在 MMSE 準則下，為了最小化整體誤差，1-tap DFE 的係數必須「超補 (Over-equalize)」來平均掉未被消除的 $h_2$ 所帶來的殘餘 ISI。這也是 MMSE 演算法優於 Zero-Forcing (ZF) 的原因。

2. **問題：既然 DFE 可以完美消除 ISI 且不放大高頻雜訊 (noise enhancement)，為何我們不設計 20-tap 甚至更長的 DFE？**
   - **答案：** 有三大實體設計限制：
     1. **Stringent timing**：1st tap 必須在 1 個 UI 內完成「取樣 $\rightarrow$ 判斷 $\rightarrow$ 回饋相加」的 Loop 運算，高速下極難達成。
     2. **Capacitive loading**：太多的 tap 會並聯過多寄生電容在加法器節點上，嚴重限制頻寬 (Bandwidth limitation)。
     3. **Power consumption**：長 DFE 需要大量的 shift register 與 DAC，功耗極大。

3. **問題：針對長尾 ISI (Long-tail ISI)，如果不能用很長的 DFE 解決，系統通常怎麼設計？**
   - **答案：** 通常會將長尾 ISI (通常是低頻損耗引起的) 交給 RX CTLE (Continuous-Time Linear Equalizer) 或是 TX FFE (Feed-Forward Equalizer) 來處理，讓 DFE 只專注於消除最前面幾個最大、最難搞定的 post-cursor。

**記憶口訣：**
- **「MMSE 超補，ZF 剛好」**（用來記 1-tap 對抗多 post-cursor 的係數偏誤）
- **「DFE 變長要問石龍宮 (時容功)」** -> **時**間限制 (Timing loop)、電**容**負載 (Cap loading)、**功**耗 (Power consumption)
