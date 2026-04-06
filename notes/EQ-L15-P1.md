# EQ-L15-P1

> 分析日期：2026-04-06
> 原始圖片：images/done/EQ-L15-P1.jpg

---


---
## Decision Feedback Equalizer (DFE) 基本概念與限制

### 數學推導
本頁筆記探討若將一階回授系統直接當作連續時間的類比等化器（即未加 Slicer 的 First-order IIR Filter）所面臨的數學特性與困境。

1. **時域差分方程式 (Time-Domain Equation):**
   輸入訊號 $x(t)$ 與延遲 $T_b$ 並乘上權重 $-\alpha_1$ 的輸出訊號 $y(t)$ 相加，得到現在的輸出 $y(t)$：
   $$x(t) - \alpha_1 y(t - T_b) = y(t)$$

2. **拉普拉斯轉換 (Laplace Transform):**
   將上式轉換至 s-domain，利用時間延遲特性 $y(t - T_b) \xrightarrow{\mathscr{L}} Y(s)e^{-sT_b}$：
   $$X(s) - \alpha_1 Y(s)e^{-sT_b} = Y(s)$$
   $$X(s) = Y(s) (1 + \alpha_1 e^{-sT_b})$$
   取得轉移函數 (Transfer Function)：
   $$H(s) = \frac{Y(s)}{X(s)} = \frac{1}{1 + \alpha_1 e^{-sT_b}}$$

3. **頻率響應 (Frequency Response) $s = j\omega$:**
   $$H(j\omega) = \frac{1}{1 + \alpha_1 e^{-j\omega T_b}} = \frac{1}{1 + \alpha_1 (\cos(\omega T_b) - j\sin(\omega T_b))}$$

4. **振幅響應 (Magnitude):**
   $$|H(j\omega)| = \frac{1}{\sqrt{(1 + \alpha_1 \cos(\omega T_b))^2 + (-\alpha_1 \sin(\omega T_b))^2}}$$
   展開分母：$1 + 2\alpha_1 \cos(\omega T_b) + \alpha_1^2 \cos^2(\omega T_b) + \alpha_1^2 \sin^2(\omega T_b) = 1 + \alpha_1^2 + 2\alpha_1 \cos(\omega T_b)$
   $$|H(j\omega)| = \frac{1}{\sqrt{1 + \alpha_1^2 + 2\alpha_1 \cos(\omega T_b)}}$$
   - 在 DC ($\omega = 0$): $\cos(0) = 1 \Rightarrow |H| = \frac{1}{1+\alpha_1}$
   - 在 Nyquist frequency ($\omega = \frac{\pi}{T_b}$): $\cos(\pi) = -1 \Rightarrow |H| = \frac{1}{|1-\alpha_1|}$ (假設 $\alpha_1 < 1$，則為 $\frac{1}{1-\alpha_1}$)
   結果顯示：此系統具有高頻增強（Peaking）特性，從 DC 單調遞增到 Nyquist 頻率，具備作為 EQ 的潛力。

5. **相位響應 (Phase):**
   分母的相位為 $\tan^{-1}\left(\frac{-\alpha_1 \sin(\omega T_b)}{1 + \alpha_1 \cos(\omega T_b)}\right)$。因為在分母，整體相位需加負號：
   $$\angle H(j\omega) = \tan^{-1}\left[\frac{\alpha_1 \sin(\omega T_b)}{1 + \alpha_1 \cos(\omega T_b)}\right]$$
   結果顯示：**相位與頻率呈高度非線性關係！** 這會導致群延遲 (Group Delay, $-\frac{d\angle H}{d\omega}$) 不固定，讓不同頻率成分的訊號發生不同程度的延遲，進而產生嚴重的資料相依抖動 (Data-Dependent Jitter, DDJ)。

### 單位解析
**公式單位消去：**
*   **延遲方程式** $y(t) = x(t) - \alpha_1 y(t - T_b)$：
    *   $x(t), y(t)$ 均為電壓訊號，單位 $[V]$。
    *   方程式：$[V] = [V] - [\alpha_1] \times [V]$，故權重因子 $\alpha_1$ 為**無因次量 (Unitless)** $[V/V]$。
    *   $T_b$ 為 Bit period，單位為時間 $[s]$。
*   **頻域轉移函數** $H(j\omega)$：
    *   $\omega$ 單位 $[rad/s]$，$T_b$ 單位 $[s]$。
    *   $\omega T_b = [rad/s] \times [s] = [rad]$，作為三角函數的輸入合理。
    *   $H(s)$ 代表電壓增益 $Y(s)/X(s)$，單位為 $[V/V]$。

**圖表單位推斷：**
*   **振幅響應圖 ($|H(s)|$ vs $f$)：**
    *   X 軸：頻率 $f$，單位 $[Hz]$。典型範圍為 $0 \sim 1/T_b$ (Baud rate，例如 10Gbps 對應 10GHz)。
    *   Y 軸：電壓增益幅度 $|H(s)|$，單位 $[V/V]$ (線性比例)。典型數值在 DC 為 $\frac{1}{1+\alpha_1}$，在 Nyquist $f = \frac{1}{2T_b}$ 達峰值 $\frac{1}{1-\alpha_1}$。
*   **相位響應圖 ($\angle H$ vs $f$)：**
    *   X 軸：頻率 $f$，單位 $[Hz]$。典型範圍為 $0 \sim 1/T_b$。
    *   Y 軸：相位角 $\angle H$，單位 $[rad]$ 或 $[Degree]$。典型範圍為 $-\pi/2 \sim \pi/2$。

### 白話物理意義
如果只用類比電路把訊號延遲相減來做 EQ（IIR濾波器），雖然可以補償高頻衰減，但會把波形推擠變形（相位非線性），造成嚴重的 Jitter；**真正的 DFE 必須加上 Slicer（判斷器），把歷史訊號變成乾淨的數位「1 或 0」後再回授去減，這樣才能精準消除干擾且不放大雜訊！**

### 生活化比喻
這就像在回音很大的房間裡聽演講。
如果用純類比 EQ（IIR filter），就像你試圖發出反向的聲波來抵銷回音，但因為空間反射太複雜（相位非線性），抵銷的聲音跟原本的聲音糊在一起，反而讓你聽不懂（Jitter）。
加上 Slicer 的 DFE 則是你的「大腦」，大腦一旦「確定」剛才講者說了「你好」（Slicer 判斷為1），大腦就會自動在心裡把預期的「你好」回音扣除，這是一個純粹的邏輯運算，不會憑空製造其他噪音，所以你能聽清楚現在這句話。

### 面試必考點
1. **問題：為什麼筆記特別強調 "Need to digitize the summation results... Slicer"？如果不用 Slicer 會有什麼後果？**
   → **答案**：如果不用 Slicer 將訊號數位化，它就是一個純類比的連續時間 IIR 濾波器。正如筆記推導，其相位響應高度非線性，會產生嚴重的 Group Delay Variation，導致資料相依抖動 (Data-Dependent Jitter, DDJ)。加入 Slicer 後，回授的是離散且無雜訊的理想訊號 (1 或 -1/0)，巧妙避開了連續濾波器的相位問題。
2. **問題：DFE 與 CTLE 最大的差異是什麼？為什麼高速 SerDes RX 端除了 CTLE 還需要 DFE？**
   → **答案**：最大差異在於「雜訊放大 (Noise Amplification)」。CTLE 是線性濾波器，在放大高頻訊號的同時也會等比例放大高頻雜訊 (如 Crosstalk, Thermal noise)。DFE 因為有 Slicer，回授路徑上的訊號是「乾淨的數位值」，只扣除 ISI 而不會引入或放大雜訊 (No noise amplification)。在通道損耗極大時，單靠 CTLE 會使 SNR 嚴重惡化，因此需要 DFE 輔助消除剩餘的 ISI。
3. **問題：DFE 有什麼先天上的致命傷？能處理 Pre-cursor 嗎？**
   → **答案**：
   - 無法處理 Pre-cursor ISI：因為它是用「過去」的判決結果去消除對「現在」的干擾，未來的訊號還沒進來（Slicer 輸出為 0），無從回授扣除。
   - Error Propagation (錯誤蔓延)：如果 Slicer 判斷錯一個 bit，回授的扣除值就會變成加重干擾，導致接下來連續幾個 bits 都更容易判斷錯誤。
   - Timing constraint 嚴苛：1-tap 運算（加法 $\rightarrow$ Slicer $\rightarrow$ Latch $\rightarrow$ 乘法 $\rightarrow$ 回饋到加法器）必須在 1 UI (Unit Interval) 的時間內完成，是極高頻設計的最大挑戰。

**記憶口訣：**
**D**FE 記仇扣歷史 (只能解 Post-cursor)
**F**ree of 雜訊不放大 (Slicer 大功臣)
**E**rror 蔓延且極限速 (Timing constraint是 Critical Path)
---
