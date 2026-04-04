# TIA-L4-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/TIA-L4-P1.jpg

---


---
## 光接收前端整體增益與雜訊評估 (Optical Frontend Gain and Noise Budget)

### 數學推導
本頁筆記展示了如何從光纖接收端的光功率規格，反推 TIA 與 LA (Limiting Amplifier) 所需的整體增益與容許的最大輸入雜訊。

1. **平均光功率轉換為線性值**：
   已知平均光功率 $\bar{P} = -12 \text{ dBm}$。
   $\bar{P} = 10^{\frac{-12}{10}} \text{ mW} = 10^{-1.2} \text{ mW} \approx 0.063 \text{ mW} = 63 \text{ \mu W}$
   *(前提假設：傳輸的資料 '0' 與 '1' 出現機率相等且完全隨機)*

2. **利用消光比 (Extinction Ratio, ER) 計算 $P_1$ 與 $P_0$**：
   已知 $ER = 6 \text{ dB}$，這代表光功率 '1' 和 '0' 的比例。
   $ER = 10 \log_{10}\left(\frac{P_1}{P_0}\right) = 6 \text{ dB} \Rightarrow \frac{P_1}{P_0} = 10^{0.6} \approx 4 \Rightarrow P_1 = 4P_0$
   將其代入平均功率公式：$\bar{P} = \frac{1}{2}(P_1 + P_0) = \frac{1}{2}(4P_0 + P_0) = 2.5P_0$
   $2.5P_0 = 63 \text{ \mu W} \Rightarrow P_0 = 25.2 \text{ \mu W}$
   $P_1 = 4 \times 25.2 \text{ \mu W} = 100.8 \text{ \mu W}$

3. **計算光電流擺幅 (Photocurrent Swing, $I_{pp}$)**：
   已知光電二極體響應度 (Responsivity) $R = 0.9 \text{ A/W}$。
   $I_1 = R \times P_1 = 0.9 \times 100.8 \text{ \mu W} = 90.72 \text{ \mu A} \approx 90.7 \text{ \mu A}$
   $I_0 = R \times P_0 = 0.9 \times 25.2 \text{ \mu W} = 22.68 \text{ \mu A} \approx 22.7 \text{ \mu A}$
   $I_{pp} = I_1 - I_0 = 90.72 - 22.68 = 68.04 \text{ \mu A} \approx 68 \text{ \mu A}$

4. **計算整體增益 (Total Gain)**：
   後端要求輸出電壓擺幅 $D_{out} \ge 600 \text{ mV}_{p-p}$。
   $\text{Total Gain} = \frac{V_{out,pp}}{I_{in,pp}} = \frac{600 \text{ mV}}{68 \text{ \mu A}} \approx 8.82 \text{ k\Omega}$
   轉換為 dB$\Omega$ 刻度：$20 \log_{10}(8820) \approx 78.9 \text{ dB\Omega} \approx 79 \text{ dB\Omega}$
   *(筆記舉例：可將這 79 dB$\Omega$ 分配給 TIA (46 dB$\Omega$) 與 LA (約等於電壓增益的 40dB，實際需換算阻抗匹配))*

5. **計算最大容許輸入參考雜訊 ($I_{n,rms}$)**：
   為了達到誤碼率 $BER < 10^{-12}$，訊號雜訊比必須滿足特定條件。
   根據高斯雜訊分佈，要求 $\frac{I_{pp}}{I_{n,rms}} \ge 14$ （此為 $Q \ge 7$ 的變形，因 $I_{pp} = 2 I_{sig}$）。
   $I_{n,rms} \le \frac{I_{pp}}{14} = \frac{68 \text{ \mu A}}{14} \approx 4.85 \text{ \mu A}_{rms}$ (筆記估算為 $4.8 \text{ \mu A}_{rms}$)
   這代表整個前端電路等效到 TIA 輸入端的積分雜訊電流 $\sqrt{\overline{I_{n,in}^2}}$ 不能超過這個值。

### 單位解析
**公式單位消去：**
1. **光功率轉電流**：$I_{1,0} \text{ [A]} = R \text{ [A/W]} \times P_{1,0} \text{ [W]} = \text{[A/W]} \times \text{[W]} = \text{[A]}$
2. **跨阻增益**：$\text{Total Gain [}\Omega\text{]} = \frac{V_{out,pp} \text{ [V]}}{I_{in,pp} \text{ [A]}} = \text{[V]} / \text{[A]} = \text{[}\Omega\text{]}$
3. **SNR 條件求雜訊**：$I_{n,rms} \text{ [A]} = \frac{I_{pp} \text{ [A]}}{14 \text{ [-]}} = \text{[A]}$ (分母 14 為無單位比例常數)

**圖表單位推斷：**
📈 **圖表單位推斷 (左下角眼圖)：**
- **X 軸**：時間 [UI (Unit Interval) 或 ps]，典型範圍為 1~2 UI (顯示一個或多個完整資料週期)。
- **Y 軸**：電壓 [mV]，此處標示了 $V_{pp}$，典型範圍依據題目要求為 $\ge 600 \text{ mV}_{p-p}$。

### 白話物理意義
我們從光纖收到微弱的光訊號，先用光電二極體轉成微小的電流變化 ($68\mu A$)，接著計算需要多大倍率的放大器（約 $8.8k\Omega$），才能把這個微小電流放大成數位電路能看懂的電壓 ($600mV$)；同時，為確保我們讀錯資料的機率極低（低於一兆分之一），我們電路本身的底噪不能超過訊號強度的十四分之一。

### 生活化比喻
這就像你在遠處看朋友用手電筒打摩斯密碼（光訊號），手電筒有亮（$P_1$）和暗（$P_0$）兩種狀態。你的眼睛（Photodiode）把光轉換成腦神經信號（光電流）。因為信號太微弱，你需要戴上助聽擴大機（TIA + LA）把它放大到能清楚聽見的音量（$600mV_{p-p}$）。但擴大機本身會有嘶嘶的底噪（$I_{n,rms}$），為了保證你幾乎不會聽錯（BER < $10^{-12}$），信號的音量差距必須至少是底噪的 14 倍大。

### 面試必考點
1. **問題：為什麼要求 $I_{pp} / I_{n,rms} \ge 14$ 才能達成 $BER < 10^{-12}$？**
   → **答案**：BER 是由高斯雜訊分佈的尾部面積決定，近似公式為 $BER \approx \frac{1}{\sqrt{2\pi}Q} e^{-Q^2/2}$。當要求 BER 為 $10^{-12}$ 時，查表可得所需的 $Q$ 值約為 7。而 $Q = \frac{I_1 - I_0}{2 \sigma_{noise}} = \frac{I_{pp}}{2 I_{n,rms}}$，將 $Q=7$ 代入即可推導出 $I_{pp} / I_{n,rms} \ge 14$。
2. **問題：消光比 (Extinction Ratio, ER) 如果太小，對系統有什麼致命影響？**
   → **答案**：ER 太小代表光訊號 '1' 和 '0' 的功率非常接近（對比度差）。在相同的「平均光功率」限制下，轉換出來的有效訊號電流擺幅 ($I_{pp}$) 會急遽縮小，導致 SNR 降低，系統更容易受到 TIA 內部雜訊干擾而產生誤碼。這時所謂的 "Power Penalty" 就會增加。
3. **問題：在設計 TIA 時，為了滿足筆記中的低雜訊要求 ($<4.8\mu A$)，我們可以直接無限放大回授電阻 ($R_F$) 嗎？**
   → **答案**：不行。雖然增大 $R_F$ 可以降低輸入參考熱雜訊電流 ($\overline{i_{n,RF}^2} = 4kT/R_F$) 並增加增益，但 TIA 的主極點頻寬近似為 $\omega_p \approx \frac{A_0}{R_F C_{in}}$。$R_F$ 太大會導致頻寬縮減，造成嚴重的 ISI (Inter-Symbol Interference) 使得眼圖閉合，最終反而會讓實際的 BER 惡化。這是經典的 Gain-Noise-Bandwidth trade-off。

**記憶口訣：**
光端機設計三步曲：「消光轉流求Ipp，十四倍底噪保平安，電壓除流得增益」。
