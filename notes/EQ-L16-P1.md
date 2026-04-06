# EQ-L16-P1

> 分析日期：2026-04-06
> 原始圖片：images/done/EQ-L16-P1.jpg

---

---
## [主題名稱] General DFE (Decision Feedback Equalizer) 架構與係數推導

### 數學推導
本頁筆記主要在推導 DFE 的係數與 Channel Pulse Response（通道脈衝響應）之間的關係，目標是消除 Post-cursor ISI。

1. **定義目標**：
   設計一個 DFE 來補償通道造成的脈衝響應失真 $x(t)$。
   目標是讓到達判決器（Slicer）輸入端的訊號 $y[n]$，在 Main cursor 之後的值皆為 0，也就是達到完全消除 Post-cursor 的理想狀態：
   $y[n] = \{\dots, x[0], 0, 0, 0, \dots\}$。已知 Main cursor $x[0] = 0.85$。
2. **假設條件**：
   假設判決器做出了完全正確的判斷，對於一個獨立的脈衝（Pulse），在 $T=0$ 取樣時，判決輸出 $\hat{y}[0] = 1$。
3. **逐步推導 Tap Coefficients $\alpha_k$**：
   在接收端，第 $n$ 個取樣點的電壓為：$y[n] = x[n] - \sum_{k=1}^{N} \alpha_k \cdot \hat{y}[n-k]$
   對於單一脈衝響應，我們只看 $\hat{y}[0] = 1$，其餘 $\hat{y}[k] = 0$。
   - **在 $T = T_b$ 時（第一個 Post-cursor，對應 $x[1] = -0.2$）**：
     為了讓 $y[1] = 0$，代入公式：
     $y(T_b) = -\alpha_1 \cdot \hat{y}[0] + x[1] = 0$
     $\Rightarrow -\alpha_1 \cdot (1) + (-0.2) = 0 \Rightarrow \alpha_1 = -0.2$，即 $\alpha_1 = x[1]$
   - **在 $T = 2T_b$ 時（第二個 Post-cursor，對應 $x[2] = 0.1$）**：
     為了讓 $y[2] = 0$，代入公式：
     $y(2T_b) = -\alpha_2 \cdot \hat{y}[0] + x[2] = 0$
     $\Rightarrow -\alpha_2 \cdot (1) + 0.1 = 0 \Rightarrow \alpha_2 = 0.1$，即 $\alpha_2 = x[2]$
   - **在 $T = 3T_b$ 時（第三個 Post-cursor，對應 $x[3] = 0.05$）**：
     為了讓 $y[3] = 0$，代入公式：
     $y(3T_b) = -\alpha_3 \cdot \hat{y}[0] + x[3] = 0$
     $\Rightarrow -\alpha_3 \cdot (1) + 0.05 = 0 \Rightarrow \alpha_3 = 0.05$，即 $\alpha_3 = x[3]$
4. **結論**：
   - DFE 的回授係數集合 $\{\alpha_1, \alpha_2, \alpha_3, \dots\}$ 實際上就等於通道脈衝響應的 Post-cursors 集合 $\{x[1], x[2], x[3], \dots\}$。
   - 筆記註明：`DFE is a IIR filter => May be subject to instability.`
     因為 DFE 包含反饋迴路（Feedback loop），數學模型上屬於無限脈衝響應（IIR）濾波器。如果判決錯誤產生，錯誤會進入迴路繼續影響未來的判決，導致 Error Propagation（錯誤傳播）或系統不穩定。

### 單位解析
**公式單位消去：**
- 核心等式：$y(kT_b) = x(kT_b) - \alpha_k \cdot \hat{y}(0)$
- 取樣點電壓 $y(kT_b)$ 與通道響應電壓 $x(kT_b)$ 的物理單位皆為伏特 [V]。
- Slicer 的判決輸出 $\hat{y}(0)$ 是數位邏輯準位，通常在數學模型中視為無因次常數（Dimensionless），值為 $+1$ 或 $-1$ [-]。
- 回授係數 $\alpha_k$ 在電路實現中，通常是由 DAC 提供的電流乘上電阻轉成電壓，所以其單位必須是 [V]。
- 單位消去結果：[V] = [V] - [V] × [-] $\Rightarrow$ [V] = [V]。等式兩邊單位一致，物理意義成立。

**圖表單位推斷：**
📈 圖表單位推斷：左下角的 Pulse Response 波形圖
- X 軸：時間 [$T_b$]（Bit Period / UI），典型範圍 $-1 T_b$ 到 $4 T_b$（例如 28Gbps 下，1 $T_b \approx 35.7$ ps）。
- Y 軸：訊號振幅（Amplitude）[V] 或 [mV]，典型範圍 $-0.5$ V 到 $+1.0$ V。圖中標示 main cursor 為 0.85，post-cursors 為 -0.2, 0.1, 0.05，這通常是已經對 TX 擺幅歸一化（Normalized）後的值 [-]。

### 白話物理意義
DFE 就像是個「事後諸葛」，它記住剛剛確認過的訊號是 0 還是 1，然後在下一個訊號進來時，把前一個訊號殘留下來的「尾巴（Post-cursor ISI）」精準地扣除，讓眼圖重新張開。

### 生活化比喻
想像你在一個回音很大的山谷裡聽人講話（Channel ISI）。當對方喊出第一個字「哈」，山谷會產生回音「...啊...啊」。當對方緊接著喊第二個字「囉」的時候，你的耳朵會同時聽到「囉」和第一個字的殘留回音「...啊」。
DFE 的機制就像是你大腦裡建了一個「回音消除器」：因為你大腦已經確信第一個字是「哈」了，所以當你聽第二個字時，大腦會主動把預期會出現的「...啊」回音從聽覺中減掉，這樣你就能聽清楚乾淨的「囉」了！但風險是，如果你第一個字聽錯了，你扣除的回音也會是錯的，導致後面的字全部聽錯（這就是 Error Propagation）。

### 面試必考點
1. **問題：理想情況下，DFE 的 Tap Coefficients 應該設為多少？物理意義為何？**
   → 答案：理想情況下，第 $k$ 個 Tap 的係數 $\alpha_k$ 就等於 Channel Pulse Response 在 $k \cdot T_b$ 時間點的殘值（即第 $k$ 個 Post-cursor 的大小）。物理意義是利用已經判決確定的訊號，乘上對應的權重，產生一個能完全抵銷通道 ISI 殘影的電壓來相減。
2. **問題：DFE 最大的缺點是什麼？為什麼說它有不穩定的風險（如筆記所述）？**
   → 答案：最大的缺點是**錯誤傳播（Error Propagation）**。因為 DFE 依賴「過去的判決結果 $\hat{y}$」來補償現在的訊號，一旦某個 bit 因為雜訊被判錯，這個錯誤的 $\hat{y}$ 就會乘上係數回授到輸入端，反而製造了額外的干擾，導致接下來連續幾個 bits 都被判錯。此外，第一階回授（1st Tap）有著極嚴苛的 Timing Constraint（必須在 1 UI 內完成 Slicer 判決與加法器回授）。
3. **問題：DFE 能不能用來補償 Pre-cursor ISI（前向干擾）？為什麼？**
   → 答案：**絕對不能**。DFE 是 Feedback equalization，它必須依賴已經通過 Slicer 判斷出來的「歷史資料」才能產生補償信號。Pre-cursor 是來自於「未來的 bit」對現在造成的干擾，未來的 bit 根本還沒進到 Slicer，無法被預測，因此 DFE 對 Pre-cursor 無能為力。要解決 Pre-cursor 必須靠 TX FFE 或 RX 的線性等化器（如 CTLE、RX FFE）。

**記憶口訣：**
DFE 抓尾巴（Post-cursor），係數照抄殘影值；
事後諸葛怕看錯，一錯跟著一路錯（Error Propagation）。
