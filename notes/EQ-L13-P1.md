# EQ-L13-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/EQ-L13-P1.jpg

---

---
## [Spectrum Balancing] 適應性等化器 (Adaptive CTLE) 的頻譜平衡法

### 數學推導
本頁筆記探討的是如何在不知道通道 (Channel) 實際衰減量的情況下，自動調整等化器 (CTLE) 的參數。這裡使用的是 **頻譜平衡法 (Spectrum Balancing)**，核心精神是拿 Slicer (判決器) 輸出的理想數位訊號作為「頻譜黃金標準」。

**步驟 1：建立參考基準 (Reference)**
Slicer 的作用是將微弱、失真的類比訊號轉換為乾淨的數位訊號 ($D_{out}$)。一個理想的數位方波，其頻譜 $S_{ideal}(f)$ 是確定的（如筆記中較高的 $S(f)$ 曲線）。我們將 $D_{out}$ 視為完美的訊號源。

**步驟 2：低頻/振幅對齊 (DC/Low-freq Alignment)**
首先，必須確保 Slicer 之前的訊號 $V_{EQ}(t)$（待調整）與 Slicer 之後的訊號 $V_{SL}(t)$（參考標準）在低頻能量上是一致的。
透過低通濾波器 (LPF) 取出低頻成分，並計算其整流後的平均振幅（代表低頻能量或 DC swing）：
*   $P_{EQ, low} = \frac{1}{T} \int_{0}^{T} |V_{EQ}(t) * h_{LPF}(t)| dt$
*   $P_{SL, low} = \frac{1}{T} \int_{0}^{T} |V_{SL}(t) * h_{LPF}(t)| dt$
*   產生低頻誤差訊號：$E_{DC} = P_{SL, low} - P_{EQ, low}$
迴路會根據 $E_{DC}$ 調整等化器的 DC Gain (或 Slicer threshold)，強迫 $E_{DC} \rightarrow 0$。此時對應筆記圖中 $f$ 趨近於 0 時的 **A = A'** 點。

**步驟 3：高頻/峰值補償 (AC/High-freq Boosting)**
在低頻振幅對齊的基礎上，我們接著比較奈奎斯特頻率 (Nyquist frequency, $1/2T_b$) 附近的高頻能量。
透過高通濾波器 (HPF) 取出高頻成分：
*   $P_{EQ, high} = \frac{1}{T} \int_{0}^{T} |V_{EQ}(t) * h_{HPF}(t)| dt$
*   $P_{SL, high} = \frac{1}{T} \int_{0}^{T} |V_{SL}(t) * h_{HPF}(t)| dt$
*   產生高頻誤差訊號：$E_{AC} = P_{SL, high} - P_{EQ, high}$
迴路會將 $E_{AC}$ 積分後去控制 CTLE 的高頻提升量 (Boosting Filter)，強迫 $E_{AC} \rightarrow 0$。這對應筆記圖中在 Nyquist freq 時的 **B = B'** 點。

### 單位解析
**公式單位消去：**
我們來驗證上述 Adaptation Loop 中積分器 (Error Amp) 更新控制電壓 $V_{ctrl, boost}$ 的過程。假設 Error Amp 為一轉導放大器 ($g_m$) 充放電容 ($C_{int}$)。
*   公式：$V_{ctrl, boost} = \frac{g_m}{C_{int}} \int E_{AC} dt$
*   已知單位：
    *   $E_{AC}$ (誤差電壓振幅) = [V]
    *   $g_m$ (轉導) = [A/V]
    *   $C_{int}$ (電容) = [F] = [A·s/V]
    *   $dt$ (時間微分) = [s]
*   消去過程：
    $V_{ctrl, boost} = \frac{[A/V]}{[A \cdot s / V]} \times \int [V] \cdot [s]$
    $V_{ctrl, boost} = \left[ \frac{1}{s} \right] \times [V \cdot s] = \mathbf{[V]}$
*   **物理意義：** 積分器將輸入的電壓誤差，經過時間累積後，轉換為一個穩定的直流電壓 [V]，用來控制 CTLE 的 Varactor 或偏壓電流，以改變 Boosting 增益。

**圖表單位推斷：**
📈 筆記左下方的 $S(f)$ 頻譜圖 (Power Spectral Density)：
*   **X 軸**：頻率 $f$ **[Hz]** 或 **[GHz]**。筆記標示了 $\frac{1}{2T_b}, \frac{1}{T_b}$。假設是 10Gbps 的訊號，$T_b = 100$ps，則 Nyquist frequency $\frac{1}{2T_b} = 5$ GHz。典型範圍視資料傳輸率而定，通常關注 0 ~ $1/T_b$ 區間。
*   **Y 軸**：訊號功率頻譜密度 $S(f)$ **[V²/Hz]** 或是轉為對數刻度 **[dBm/Hz]**。代表不同頻率成分所含的能量多寡。

### 白話物理意義
既然不知道這條線讓訊號變多慘，我們就把 Slicer 吐出來的「完美數位方波」當作黃金標準，回頭去逼迫前面的等化器：「你的高低頻比例，必須調到跟這個完美方波一模一樣！」

### 生活化比喻
這就像是**自動修圖軟體**。
你拿到一張在陰暗又起大霧的地方拍的照片（衰減嚴重的接收訊號 $D_{in}$）。
Slicer 就像是一個「AI 算圖工具」，它不管你原來長多慘，直接猜測並畫出一張完美的標準美女圖（理想數位訊號 $D_{out}$）。
我們拿這張 AI 完美圖當參考：
1. **先調總體亮度 (LPF / DC power)**：把你的暗照片調亮，直到兩張圖平均亮度一樣 ($A = A'$)。
2. **再調銳利度 (HPF / AC power)**：對齊亮度後，比較兩張圖邊緣的清晰度。如果你的照片霧霧的，就增加「對比度/銳利度 (Boosting)」，直到兩張圖的邊緣一樣銳利 ($B = B'$)。
調完這兩步，你的等化器就成功還原訊號了！

### 面試必考點
1. **問題：在 Spectrum Balancing 適應性演算法中，為什麼一定要先對齊 Low-frequency (DC swing)，然後才去比較 High-frequency？可以反過來嗎？**
   * **答案：** 不行。因為我們是用「絕對能量/振幅」在比較。如果 DC swing（基礎振幅）不一樣大，高頻能量的絕對值大小就沒有比較基準。必須先 normalize DC (讓 $A = A'$ )，確立基準線後，再看高頻能量 ($B$ 相對 $B'$) 是衰減還是放大，才能給出正確的 Boosting 調整方向。
2. **問題：拿 Slicer 輸出的 $D_{out}$ 作為 Reference 有什麼致命的風險？**
   * **答案：** **Error Propagation (錯誤傳遞)**。如果初始通道極度惡劣，或者 EQ 設定太差，導致眼圖完全閉合，Slicer 會產生大量的 Bit Error (誤判)。此時 $D_{out}$ 根本不是理想的還原訊號，而是一堆垃圾。拿垃圾當黃金標準去 Train EQ，會導致演算法收斂到錯誤的值，甚至發散 (永遠調不回來)。這在業界稱為 "Deadlock"。
3. **問題：圖中的 LPF (低通) 與 HPF (高通) 濾波器，其 cutoff frequency 大約要怎麼設計？**
   * **答案：** HPF 的目的是萃取資料轉態時的高頻能量，因此 cutoff frequency 通常設定在訊號的奈奎斯特頻率 (Nyquist frequency, $1/2 T_b$) 附近。LPF 的目的是萃取連續同號 (連 0 或連 1) 的低頻直流準位，因此 cutoff frequency 必須設定在遠低於 Nyquist frequency 的地方 (例如 $1/10 T_b$ 或更低)，以濾除高頻轉態的干擾。

**💡 記憶口訣：**
**「先求有再求好，找對教練最重要。」**
先求有（對齊低頻 DC 基準），再求好（補償高頻 AC 衰減），找對教練（用 Slicer 當 Reference，但要小心教練別瞎了眼產生 Error Propagation）。
