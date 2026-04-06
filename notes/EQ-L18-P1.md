# EQ-L18-P1

> 分析日期：2026-04-06
> 原始圖片：images/done/EQ-L18-P1.jpg

---


---
## 最小均方誤差 (MMSE) 推導 DFE 最佳係數

### 數學推導
本頁筆記展示了如何從最小均方誤差 (Minimum Mean Square Error, MMSE) 的角度，嚴格推導出 DFE (Decision Feedback Equalizer) 的最佳 Tap 係數。

1. **定義通道脈衝響應 (Pulse Response)**：
   由圖左側的通道響應可知，取樣點的權重為：主游標 (Main cursor) $h_0 = 1.0$，第一後游標 (1st Post-cursor) $h_1 = 0.2$，第二後游標 (2nd Post-cursor) $h_2 = 0.1$。

2. **建立 DFE 接收端訊號模型**：
   在判決器 (Slicer) 輸入端，訊號 $y$ 等於接收到的通道訊號減去 DFE 的回授訊號。
   $$y_k = (h_0 d_k + h_1 d_{k-1} + h_2 d_{k-2}) - (\alpha_1 \hat{y}_{k-1} + \alpha_2 \hat{y}_{k-2})$$
   假設過去的決策完全正確（即 $\hat{y}_{k-i} = d_{k-i}$），則方程式可整理為：
   $$y_k = h_0 d_k + (h_1 - \alpha_1)d_{k-1} + (h_2 - \alpha_2)d_{k-2}$$

3. **計算目標值為 '0' 時的誤差平方期望值 ($e^2$)**：
   假設當前傳送的位元 $d_k = 0$，理想判決結果 $\hat{y} = 0$。此時 $h_0 d_k = 0$。
   過去兩個位元 $(d_{k-2}, d_{k-1})$ 有 4 種可能組合 $\{00, 01, 10, 11\}$，假設資料隨機，每種出現機率為 $1/4$。
   *   歷史序列 $\{1, 1\} \Rightarrow y = 0.1(1) + 0.2(1) - \alpha_1(1) - \alpha_2(1) + 0 = 0.1 + 0.2 - \alpha_1 - \alpha_2$
   *   歷史序列 $\{0, 1\} \Rightarrow y = 0.1(0) + 0.2(1) - \alpha_1(1) - \alpha_2(0) + 0 = 0 + 0.2 - \alpha_1 - 0$
   *   歷史序列 $\{1, 0\} \Rightarrow y = 0.1(1) + 0.2(0) - \alpha_1(0) - \alpha_2(1) + 0 = 0.1 + 0 - 0 - \alpha_2$
   *   歷史序列 $\{0, 0\} \Rightarrow y = 0.1(0) + 0.2(0) - \alpha_1(0) - \alpha_2(0) + 0 = 0 + 0 - 0 - 0$
   
   誤差定義為 $e = y - \hat{y} = y - 0 = y$。
   平均誤差功率 (Averaged error power) 為這四種情況的平方和取平均：
   $$e^2 = \frac{1}{4} \left[ (0.1+0.2-\alpha_1-\alpha_2)^2 + (0.2-\alpha_1)^2 + (0.1-\alpha_2)^2 + 0^2 \right]$$

4. **最小化誤差求最佳係數**：
   欲使系統誤差 $e^2$ 最小，將其對 $\alpha_1$ 與 $\alpha_2$ 取偏微分並設為 0：
   $$\frac{\partial e^2}{\partial \alpha_1} = 0 \Rightarrow 2(0.1+0.2-\alpha_1-\alpha_2)(-1) + 2(0.2-\alpha_1)(-1) = 0$$
   $$\frac{\partial e^2}{\partial \alpha_2} = 0 \Rightarrow 2(0.1+0.2-\alpha_1-\alpha_2)(-1) + 2(0.1-\alpha_2)(-1) = 0$$
   解此聯立方程式，直接推得 $\alpha_1 = 0.2$, $\alpha_2 = 0.1$。證明了最佳 DFE 係數正是通道後游標的 ISI 值 (As expected)。

5. **驗證目標值為 '1' 的情況**：
   若當前位元 $d_k = 1$，理想判決 $\hat{y} = 1$。主游標貢獻 $h_0(1) = 1.0$。
   誤差 $e = y - \hat{y} = y - 1$。
   以序列 $\{1, 1, 1\}$ 為例：$y = 0.1 + 0.2 - \alpha_1 - \alpha_2 + 1$。
   其誤差 $e = (0.1 + 0.2 - \alpha_1 - \alpha_2 + 1) - 1 = 0.1 + 0.2 - \alpha_1 - \alpha_2$。
   可見 "+1" (主游標) 與 "-1" (理想目標值) 互相完全抵消，最終的誤差方程式與目標值為 '0' 時完全相同。最佳化結果依然是 $\alpha_1 = 0.2, \alpha_2 = 0.1$。

### 單位解析
**公式單位消去：**
*   **$y_k = h_0 d_k + h_1 d_{k-1} + h_2 d_{k-2} - \alpha_1 \hat{y}_{k-1} - \alpha_2 \hat{y}_{k-2}$**
    通道脈衝響應 $h_i$ 常被視為實際接收電壓 $[\text{V}]$，位元資料 $d_i$ 與決策值 $\hat{y}_i$ 為邏輯狀態（視為無單位純數 $1$ 或 $0$）。
    故 $y_k$ 的單位為：$[\text{V}] \times 1 + [\text{V}] \times 1 - [\text{V}] \times 1 = [\text{V}]$。
    這證明了 DFE 係數 $\alpha_i$ 具有電壓 $[\text{V}]$ 的物理意義（代表要從訊號中減去的干擾電壓值）。
*   **均方誤差 $e^2 = \text{Average}( (y - \hat{y})^2 )$**
    $e^2$ 單位：$([\text{V}] - [\text{V}])^2 = [\text{V}^2]$，代表訊號的誤差功率。
*   **偏微分求極值 $\frac{\partial e^2}{\partial \alpha_i} = 0$**
    單位消去：$[\text{V}^2] / [\text{V}] = [\text{V}]$。

**圖表單位推斷：**
*   📈 **通道脈衝響應 (Pulse response) 圖 (左下)**：
    *   X 軸：時間 [UI (Unit Interval)]，整數 index。
    *   Y 軸：取樣點電壓振幅 [V] 或正規化振幅，典型範圍 0 ~ 1.0。
*   📈 **PRBS 序列與 Convolution 結果圖 (右上)**：
    *   X 軸：時間指數 [n]，代表第 n 個 UI。
    *   Y 軸：電壓振幅 [V]，顯示 ISI 疊加後的實際電壓位準。
*   📈 **Error Surface / Saddle point 示意圖 (右下)**：
    *   X/Y 軸：DFE 係數 $\alpha_1, \alpha_2$ [V]。
    *   Z 軸：均方誤差功率 $e^2$ $[\text{V}^2]$。

### 白話物理意義
尋找 DFE 最佳係數的過程，就是在數學上尋找能讓「接收到的混濁訊號」與「完美乾淨的 0/1 訊號」之間「誤差的平方和最小」的那一組減法權重，算出來的最佳權重，剛好就是通道本身的殘留尾巴 (ISI) 電壓值。

### 生活化比喻
想像你在一個回音很大的山洞裡聽朋友報數字（0或1）。因為回音（ISI），你聽到上一個數字的聲音會疊加在當前的數字上。DFE 就像是你大腦裡建構的「主動降噪系統」。為了聽得最清楚（即最小化誤差 $e^2$），你的大腦會根據「剛才確定聽到的數字」（過去的決策）以及「山洞的回音大小」（最佳係數 $\alpha$），在腦海中精準地扣除掉那個回音的音量，讓你聽到的聲音最接近朋友最原始的聲音。

### 面試必考點
1. **問題：為什麼 DFE 可以等效為一個以 MSE (Mean Square Error) 為最佳化目標的演算法？**
   → **答案**：因為 DFE 的最終目標是讓 Slicer 輸入端訊號 ($y$) 與理想訊號 ($\hat{y}$) 的誤差最小化。當我們對誤差平方取期望值，並對各 tap 係數求偏微分設為 0 時，求出的極值點 ($\alpha_i = h_i$) 即為能完美抵消 ISI 的最佳係數。現代 SerDes 接收端常用的 LMS (Least Mean Squares) 演算法，就是在硬體上實現這個 MMSE 最佳化過程。
2. **問題：筆記中畫了一個馬鞍面並問「會不會有 Saddle point (鞍點)？Why？」在 MMSE 空間中 Error surface 的形狀為何？**
   → **答案**：絕對不會有鞍點。因為 Error power $e^2$ 是一個關於 DFE 係數 $\alpha_i$ 的純二次函數 (Quadratic function)。在多維空間中，二次函數的 Error surface 是一個開口向上的多維拋物面 (Bowl-shaped)。它在數學上保證了只會有一個唯一的全域最小值 (Global minimum)，沒有區域最小值 (Local minimum) 或鞍點。這個特性保證了自適應演算法一定能穩定收斂。
3. **問題：在這份推導中，我們假設了什麼隱藏前提？如果這個前提被打破會發生什麼嚴重的連鎖反應？**
   → **答案**：推導的隱藏前提是「過去的決策完全正確 ($\hat{y}_{k-i} = d_{k-i}$)」。如果 Slicer 發生判決錯誤，DFE 不僅無法消除原有的 ISI，反而會減去極性相反的錯誤補償值，導致該 tap 的 ISI 惡化為原來的兩倍（以 PAM2 為例）。這會大幅增加後續幾個 bit 繼續判錯的機率，此現象稱為 Error Propagation (誤差傳播)。

**記憶口訣：**
**D**FE **M**inimizes **E**rrors: **D**FE 扣殘影 (推導出 $\alpha=h$) $\rightarrow$ **M**MSE 保證唯一解 (Bowl-shape 無鞍點必收斂) $\rightarrow$ **E**rror Propagation 是死穴 (一判錯就連鎖爆炸)。
