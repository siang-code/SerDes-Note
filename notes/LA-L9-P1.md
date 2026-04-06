# LA-L9-P1

> 分析日期：2026-04-06
> 原始圖片：images/done/LA-L9-P1.jpg

---


---
## NRZ PRBS 訊號頻譜分析 (Power Spectral Density)

### 數學推導
本頁筆記主要推導無編碼的數位 NRZ (Non-Return-to-Zero) 訊號，也就是 PAM2，在傳送 PRBS (Pseudo-Random Binary Sequence) 時的功率頻譜密度 (PSD)。

1. **訊號模型定義：**
   時域訊號表示為一連串的脈衝疊加：
   $$x_1(t) = \sum b_k \cdot p(t - kT_b)$$
   - $b_k \in \{0, 1\}$：代表傳送的資料位元。
   - $p(t)$：為理想的矩形脈衝 (ideal pulse)，寬度為一個位元週期 $T_b$。

2. **統計特性計算：**
   假設 0 和 1 出現機率各半 (PRBS 特性)：
   - 平均振幅 (Mean amplitude, DC 值)：
     $$m = E[b_k] = 0 \times \frac{1}{2} + 1 \times \frac{1}{2} = \frac{1}{2}$$
   - 脈衝變異數 (Pulse variance, AC 能量)：
     $$\Delta^2 = E[b_k^2] - m^2 = (0^2 \times \frac{1}{2} + 1^2 \times \frac{1}{2}) - (\frac{1}{2})^2 = \frac{1}{2} - \frac{1}{4} = \frac{1}{4}$$

3. **代入通式求 PSD：**
   隨機脈衝串列的 PSD 通式為：
   $$S(w) = \frac{\Delta^2}{T_b} |P(w)|^2 + \frac{m^2}{T_b^2} \sum_k |P(\frac{2\pi k}{T_b})|^2 \delta(w - \frac{2\pi k}{T_b})$$
   其中 $P(w)$ 是脈衝 $p(t)$ 的傅立葉轉換。對於寬度 $T_b$ 振幅 1 的矩形脈衝，其 $|P(w)| = |\frac{2\sin(wT_b/2)}{w}| = \left| \frac{\sin(wT_b/2)}{w/2} \right|$。

   - **計算 AC 項 (連續頻譜)：**
     $$\frac{\Delta^2}{T_b} |P(w)|^2 = \frac{1/4}{T_b} \left[ \frac{\sin(wT_b/2)}{w/2} \right]^2 = \frac{T_b}{4} \left[ \frac{\sin(wT_b/2)}{wT_b/2} \right]^2$$
     （這裡利用上下同乘 $T_b$ 將括號內化為標準 sinc 形式）
   
   - **計算 DC 項 (離散頻譜)：**
     當 $k=0$ (即 $w=0$ DC 處)，$|P(0)| = T_b$。
     $$\frac{m^2}{T_b^2} |P(0)|^2 \delta(w) = \frac{(1/2)^2}{T_b^2} (T_b)^2 \delta(w) = \frac{1}{4}\delta(w)$$
     當 $k \neq 0$ 的諧波處，$w = 2\pi k/T_b$，因為 $|P(w)|$ 包含 $\sin(\pi k)$ 項必為 0，所以沒有高次諧波的 delta function。

4. **最終 PSD 公式與總功率：**
   $$S_{x1}(w) = \frac{T_b}{4} \left[ \frac{\sin(wT_b/2)}{wT_b/2} \right]^2 + \frac{1}{4}\delta(w)$$
   對頻率 $f$ 積分求總功率 (Power)：
   $$\int_{-\infty}^\infty S_{x1}(f) df = \underbrace{\int_{-\infty}^\infty \frac{T_b}{4} \text{sinc}^2(\pi f T_b) df}_{\text{AC Power} = 1/4} + \underbrace{\int_{-\infty}^\infty \frac{1}{4} \delta(f) df}_{\text{DC Power} = 1/4} = \frac{1}{2}$$
   筆記指出，主瓣 (Main lobe, $-1/T_b$ 到 $1/T_b$) 約佔了 90% 的 AC 訊號能量。

### 單位解析
**公式單位消去：**
- $T_b$: 位元週期，單位為秒 $\text{[s]}$。
- $w$: 角頻率，單位為 $\text{[rad/s]}$。
- $\text{sinc}$ 函數項 $\left[ \frac{\sin(wT_b/2)}{wT_b/2} \right]$：純數字比例，無單位 $\text{[-]}$。
- 假設傳輸的是電壓訊號 $x(t)$ $\text{[V]}$，功率頻譜密度 $S(w)$ 的物理意義應為 $\text{[V}^2\text{/Hz]}$。
  - **AC 項解析：** $\frac{T_b}{4} \times \text{[無單位]}^2$。若原始公式中隱含振幅單位 $\text{[V]}$ 的平方，則此項單位為 $\text{[V}^2 \cdot s]$，即 $\text{[V}^2\text{/Hz]}$。
  - **DC 項解析：** $\delta(w)$ (或 $\delta(f)$) 的單位是頻率的倒數，即 $\text{[1/Hz]} = \text{[s]}$。係數 $1/4$ 帶有電壓平方 $\text{[V}^2]$，相乘後為 $\text{[V}^2 \cdot s] = \text{[V}^2\text{/Hz]}$。兩項單位一致，可相加。

**圖表單位推斷：**
- **X 軸：** 角頻率 $w$，單位推斷為 $\text{[rad/s]}$。刻度標示為 $\pi/T_b, 2\pi/T_b \dots$，實務上若 Data Rate 為 10 Gbps ($T_b = 100 \text{ ps}$)，第一個 Null ($2\pi/T_b$) 對應的頻率 $f$ 即為 10 GHz。典型範圍是 DC 到數倍的 Data Rate 頻率。
- **Y 軸：** 功率頻譜密度 $S_{x1}(w)$，單位推斷為 $\text{[V}^2\text{/Hz]}$ 或 $\text{[W/Hz]}$ (假設 $1\Omega$ 負載)。典型值在 DC 處為無限大 (Delta function)，AC 峰值為 $T_b/4$。第一旁波瓣 (Sidelobe) 的峰值比主瓣峰值低了約 $13\text{ dB}$ (即 $10\log_{10}(4/9\pi^2)$)。

### 白話物理意義
未編碼的 NRZ 訊號，其能量宛如一座大山集中在低頻主瓣（且含有一半的死直流能量），但在你傳輸資料的最快速度（Data Rate）上，能量反而完全抵消歸零。

### 生活化比喻
想像你在漆黑的房間裡用手電筒隨機打摩斯密碼 (0=關, 1=開)。因為手電筒有一半時間是亮著的，房間平均會有一種基礎亮度（這就是巨大的 **DC 能量**）。你閃爍的節奏構成連續的光波能量，主要都集中在較慢的閃爍頻率（**主瓣能量**）。但如果你試著用你手動開關的最快極限速度（**Data Rate**）去觀察，你會發現找不到那個單一頻率的閃爍，因為你的開關是「隨機」的，正負剛好互相抵消了（**Nulls**）。

### 面試必考點
1. **問題：未編碼的 PRBS NRZ 訊號，其頻譜在 Data Rate 處的能量為何？對 CDR (Clock and Data Recovery) 有何致命影響？** 
   → 答案：能量為零 (Null)。這代表線性的 CDR 無法直接用帶通濾波器 (Bandpass filter) 在 Data Rate 處「撈」出時脈信號。必須加上非線性電路（例如 Edge Detector / 絕對值電路）來產生 Clock tone。
2. **問題：圖中為何會有一個巨大的 $\frac{1}{4}\delta(w)$ DC 能量？在實際高速 SerDes 系統中會造成什麼問題？** 
   → 答案：因為資料位準是 $\{0, 1\}$，平均值不為零 ($m=1/2$)。實務上若通道有 AC Coupling 電容，這個龐大的 DC 能量會被濾除，導致「基線飄移 (Baseline Wander)」，使得接收端眼圖閉合誤判。解法是改用差動訊號 (等效 $\{-1, 1\}$) 或使用 8b/10b 等 DC-balanced 編碼。
3. **問題：圖中標示的 Nyquist frequency ($\frac{\pi}{T_b}$ 或 $\frac{1}{2T_b}$) 對於 RX 端的 EQ (Equalizer) 設計有何指導意義？** 
   → 答案：Nyquist 頻率是無 ISI (Inter-Symbol Interference) 傳輸的理論最低頻寬。筆記強調「保持一半的能量」，代表 EQ 必須補償通道的高頻損耗，至少要在 Nyquist 頻率處提供足夠的增益（通常要將整體通道響應補償到 Nyquist 頻率處衰減不大於 -3dB），才能確保眼圖順利打開。

**記憶口訣：**
**「零一編碼半直流，能量集中低頻走；Data Rate 是大缺口，沒有 Edge 抓不到鐘。」**
