# EQ-L8-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/EQ-L8-P1.jpg

---


---
## FFE 頻率響應與 Tap 數極限分析

### 數學推導
本頁筆記主要探討 Feed-Forward Equalizer (FFE) 中，Tap 數目對高頻補償能力（High-frequency Boosting）的影響。

1. **定義 FFE Z 轉換轉移函數**：
   設定 FFE 總權重歸一化為 1。主游標 (Main Cursor) 權重定義為 $1 - K$，而所有旁波 (Pre/Post Cursor) 權重的絕對值總和定義為 $K$。
   $$K \triangleq \sum_{k=1}^{N-1} |\alpha_k|$$
   為了保證主游標主導並實現高頻補償 (High-frequency boosting)，必須滿足 $0 < K < 1/2$。
   轉移函數可寫為：
   $$H(z) = \left( 1 - \sum_{k=1}^{N-1} |\alpha_k| \right) + \sum_{k=1}^{N-1} \alpha_k \cdot z^{-k}$$

2. **轉換至連續頻域**（代入 $z = e^{j\omega T_b}$）：
   $$H(j\omega) = (1 - K) + \sum_{k=1}^{N-1} \alpha_k e^{-j k \omega T_b}$$

3. **計算 DC Gain ($\omega = 0$)**：
   為了得到最大的高頻 Boosting 比例，我們希望 DC Gain 越小越好。當所有旁波權重 $\alpha_k$ 造成的貢獻皆為負時，DC Gain 達到極小值：
   $$H(j0) = (1 - K) + \sum_{k=1}^{N-1} \alpha_k \ge (1 - K) - K = 1 - 2K$$

4. **計算 Nyquist Frequency Gain ($\omega = \frac{\pi}{T_b}$)**：
   代入 Nyquist 頻率，延遲項變為 $e^{-j k \pi} = (-1)^k$。
   $$H\left(j\frac{\pi}{T_b}\right) = (1 - K) + \sum_{k=1}^{N-1} \alpha_k (-1)^k$$
   要讓高頻增益最大化，須使 $\alpha_k (-1)^k = |\alpha_k|$，此時：
   $$H\left(j\frac{\pi}{T_b}\right) \le (1 - K) + \sum_{k=1}^{N-1} |\alpha_k| = (1 - K) + K = 1$$

5. **計算最大 Boosting Ratio**：
   $$\text{Max Boosting} = \frac{H(j\frac{\pi}{T_b})}{H(j0)} \le \frac{1}{1 - 2K}$$
   **結論**：對於給定的 $K$ 值，最大的 Boosting 比例是固定的，與 Tap 數 $N$ 無關。更多的 Tap 數只能用來修飾頻響形狀 (shape the response better)。
   **舉例**：若 $K = 1/3$，則最大 Boosting 為 $\frac{1}{1 - 2(1/3)} = 3 = 9.54\text{ dB}$。

### 單位解析
**公式單位消去：**
- **轉移函數 $H(j\omega)$**：代表輸出入的電壓或電流比例，為無因次量 $[V/V]$ 或 $[A/A]$，常以 $1$ 表示。
- **相位延遲項 $e^{-j \omega T_b}$**：$\omega$ $[\text{rad}/s] \times T_b$ $[s] = [\text{rad}]$，指數項整體為無因次量。
- **Boosting Ratio**：$\frac{H(j\omega_{Nyquist})}{H(j0)}$ = $[V/V] / [V/V] = [無因次]$，通常取 $20\log_{10}$ 後單位為 $[\text{dB}]$。

**圖表單位推斷：**
📈 左下圖：頻寬與眼圖開度 vs Tap 數
- X 軸：Tap 數量 [無因次整數]，典型範圍 1~8 Taps。
- Y 軸 (左，藍線)：Bandwidth (頻寬) [GHz]，典型範圍 1~20 GHz（隨 Tap 數增加略微下降）。
- Y 軸 (右，紅線)：Eye opening (眼圖開度) [mV] 或 [UI]，典型範圍 50~200 mV（隨 Tap 數增加而上升並逐漸飽和）。

📈 中下圖：FFE 頻率響應 Bode Plot
- X 軸：角頻率 $W$ 或 $f$ [GHz]，關鍵點為 Nyquist freq $f_{Nyquist} = \frac{1}{2T_b}$。
- Y 軸：轉移函數大小 $|H|$ [dB] 或 [V/V]，典型範圍 $0 \sim 10$ dB，展示不同 Tap 組合改變了曲線形狀，但最高點 (Max Boosting) 被限制在 $\frac{1}{1-2K}$。

### 白話物理意義
在總電流（總權重）固定的情況下，FFE 增加 Tap 數可以把頻譜雕刻得更平滑細緻，但「高頻能被放大的極限倍數」已經被總權重死死卡住，再多 Tap 也無法突破極限。

### 生活化比喻
想像你在捏一塊固定體積的黏土（總電流或總權重 $K$）。增加 Tap 數就像給你更多把雕刻刀，讓你可以把黏土的表面雕刻得非常精細平滑（Shape the response better）；但是，因為黏土的總體積是固定的，所以這座雕像能堆疊出的「最高點」（Maximum Boosting）永遠無法超過體積所允許的物理極限，不管你用幾把刀去刮都一樣。

### 面試必考點
1. **問題：在設計 TX FFE 時，不斷增加 Tap 數是否能無上限地提高 Nyquist frequency 的 Boosting 值？**
   → 答案：不能。根據權重守恆原理，給定旁波總權重 $K$，最大 Boosting 被限制在 $\frac{1}{1-2K}$。增加 Tap 數只能用來更好修飾頻譜形狀（消除 ripple 或針對特定頻段等化），無法增加峰值補償量。
2. **問題：為了確保 FFE 正常運作，為什麼主游標 (Main Cursor) 的權重必須大於所有旁波權重的絕對值總和 ($K < 1/2$)？**
   → 答案：如果 $K \ge 1/2$，代表主游標權重 $1-K$ 將小於等於旁波。這會導致主訊號反而被自己產生的 ISI (Inter-Symbol Interference) 給淹沒，過度的微分效應會使眼圖無法正確打開，失去原本訊號的邏輯意義。
3. **問題：高速 SerDes 的 Current Combiner 是如何實現 Tap 權重的加減與極性控制的？**
   → 答案：如筆記左上方電路圖所示，每個 Tap 使用獨立的差動對，並透過底部的 Current DAC (IDAC) 來調控尾電流大小（即權重 $\alpha_k$）。極性控制則是透過 Sign bit 切換 Gilbert Cell 架構（Cross-coupled pair）來決定該電流是「加」還是「減」到 50 歐姆的負載電阻上。

**記憶口訣：**
「Tap 多只修形，不增 Boosting；總權重 $K$ 定生死，極限被卡 $1/(1-2K)$。」
