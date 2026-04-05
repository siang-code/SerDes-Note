# EQ-L14-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/EQ-L14-P1.jpg

---


---
## Adaptive Equalization: Balanced Power Comparison

### 數學推導
適應性等化器 (Adaptive Equalizer) 中，為了找出最佳的補償量，可以使用 **Balanced Power Comparison (頻譜能量平衡法)**。此方法不依賴判斷具體每個 bit 是 0 還是 1，而是比較訊號的頻譜能量。

1. **定義總能量**：
   假設經過等化後的訊號其全頻帶的總能量（面積）正規化為 1：
   $$ \int_{-\infty}^{\infty} S_x(f) \, df = 1 $$

2. **單邊頻譜能量**：
   因為物理訊號的功率頻譜密度 (PSD) 是對稱的，所以大於零的正頻率部分總能量為一半：
   $$ \int_{0}^{\infty} S_x(f) \, df = \frac{1}{2} $$

3. **尋找能量平分點 ($f_m$)**：
   我們希望找到一個切割頻率 $f_m$，使得低頻段 ($0 \sim f_m$) 的能量等於高頻段 ($f_m \sim \infty$) 的能量。將單邊總能量再次平分：
   $$ \int_{0}^{f_m} S_x(f) \, df = \int_{f_m}^{\infty} S_x(f) \, df = \frac{1}{4} $$

4. **計算 $f_m$ 值**：
   對於隨機的 NRZ (Non-Return-to-Zero) 資料，其 PSD 形狀為 $S_x(f) \propto \operatorname{sinc}^2(f T_b)$。將此函數代入上述積分方程式求解，可得到讓能量對半切的頻率大約落在：
   $$ f_m \approx \frac{0.28}{T_b} $$
   控制迴路會利用 LPF 與 HPF (轉角頻率均設為 $f_m$) 萃取低頻與高頻能量，並動態調整等化器的強度 (Boosting Filter 的 $V_{ctrl}$)，直到兩邊能量相等。

### 單位解析
**公式單位消去：**
- **功率頻譜密度積分**：
  $S_x(f)$ 的單位為 $[\text{V}^2/\text{Hz}]$ 或 $[\text{W}/\text{Hz}]$
  $df$ 單位為 $[\text{Hz}]$
  $\int S_x(f) \, df \Rightarrow [\text{V}^2/\text{Hz}] \times [\text{Hz}] = [\text{V}^2]$ (表示訊號的功率或能量)
- **切割頻率公式**：
  $T_b$ (Bit Period) 單位為 $[\text{s}]$
  $f_m = \frac{0.28}{T_b} \Rightarrow \frac{1}{[\text{s}]} = [\text{Hz}]$ 

**圖表單位推斷：**
1. 📈 **頻譜 PSD 比較圖 (左上)**：
   - X 軸：頻率 $f$ $[\text{Hz}]$，關鍵座標點包含 $f_m$, $1/T_b$, $2/T_b$
   - Y 軸：功率頻譜密度 $S_x(f)$ $[\text{V}^2/\text{Hz}]$
2. 📈 **整流器 (Rectifier) 轉換曲線圖 (中下)**：
   - X 軸：輸入擺幅 (Input Swing) $A_{in}$ $[\text{V}]$，典型範圍 $0 \sim 500 \text{ mV}$
   - Y 軸：整流輸出電壓 $V_{out}$ $[\text{V}]$
   - *注意：圖中清楚標示出一般整流器在輸入小時「前半段是平的」(Dead Zone)，這代表電晶體尚未完全導通。*

### 白話物理意義
我們把收到的訊號分成「低頻」和「高頻」兩包來秤重。如果低頻比高頻重（訊號太糊），我們就叫等化器把高頻放大一點；如果高頻比低頻重（雜訊或高頻被放太大），就叫等化器減弱高頻。當兩包一樣重的時候，訊號的眼圖張得最開最漂亮。

### 生活化比喻
就像你在聽音響，如果聲音聽起來太悶（低音太多），你會去把 EQ 的高音旋鈕轉大；如果聲音太尖銳刺耳（高音太多），你會把高音轉小。直到「沉穩的低音」跟「清脆的高音」聽起來比例完美、互相平衡時，就是最佳的聆聽狀態。

### 面試必考點
1. **問題：Balanced Power Comparison 這種 Adaptation 機制最大的優勢是什麼？**
   → **答案：** 「No slicer required => Tend to operate at higher data rate」。因為它只看訊號的平均能量頻譜，不需要做 bit-by-bit 的精準取樣判斷（不用 Slicer）。在極高速的應用下，Slicer 的速度和時序往往是瓶頸，這方法完美避開了這個問題。
2. **問題：如何決定低頻與高頻的切割點 $f_m$？數值大約是多少？**
   → **答案：** 根據 NRZ 訊號 $\operatorname{sinc}^2(f T_b)$ 的頻譜特性，為了讓 $0 \sim f_m$ 與 $f_m \sim \infty$ 的能量各佔單邊頻譜的一半 (即總能量的 1/4)，經過積分計算後，$f_m$ 應設在約 $0.28 / T_b$ 的位置。
3. **問題：為什麼筆記特別提出 Class-AB Biasing 的 Rectifier 來取代傳統架構？**
   → **答案：** 傳統使用 Source Follower 架構的整流器，在訊號擺幅 (Input Swing) 很小時會有 Dead Zone（圖中寫「前半段是平的」），導致迴路靈敏度差。改用適當偏壓在導通邊緣的 Class-AB Rectifier，其輸出會正比於輸入擺幅的平方 ($V_{out\_swing} \sim A_{in}^2$)，能提供 3 到 4 倍大的輸出信號，大幅提升控制迴路在小訊號時的精準度。

**記憶口訣：**
「**能量對半切，點二八 ($0.28/T_b$) 來分界；免用 Slicer 跑得快，AB 整流沒死角。**」

---
