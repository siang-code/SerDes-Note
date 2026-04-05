# CDR-L29-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L29-P1.jpg

---


---
## Jitter Generation (JG)

### 數學推導
本頁筆記的核心目標：證明**時域與頻域量測到的 RMS Jitter 是等價的**，並推導出如何從量測到的 Phase Noise 頻譜，計算出以 UI 為單位的 RMS Jitter 公式。

1. **時域均方根抖動 (RMS Jitter) 的定義**：
   在時域中，RMS Jitter ($\Delta t_{rms}$) 是無窮多個取樣點的時間偏差量 $\Delta t_j$ 平方的平均值之平方根：
   $$ \Delta t_{rms} \triangleq \left[ \lim_{N \to \infty} \frac{1}{N} \sum_{j=1}^{N} \Delta t_j^2 \right]^{\frac{1}{2}} $$

2. **時間偏差與相位偏差的轉換**：
   時間的偏差 $\Delta t_j$ 可以對應到相位的偏差 $\Delta \phi_j$。因為一個完整的 Clock 週期 $T_b$ 在相位上代表 $2\pi$ 弧度，所以可以建立比例關係：
   $$ \Delta t_j = \frac{\Delta \phi_j \cdot T_b}{2\pi} $$
   將此關係代入原來的 RMS 定義中，並將常數項提出：
   $$ \Delta t_{rms} = \left[ \lim_{N \to \infty} \frac{1}{N} \sum_{j=1}^{N} \left(\frac{\Delta \phi_j \cdot T_b}{2\pi}\right)^2 \right]^{\frac{1}{2}} = \frac{T_b}{2\pi} \left[ \lim_{N \to \infty} \frac{1}{N} \sum_{j=1}^{N} \Delta \phi_j^2 \right]^{\frac{1}{2}} $$

3. **時域變異數與頻域積分的等價性 (Parseval's 定理概念)**：
   時域中相位偏差的變異數（即 Noise Power），等於其功率頻譜密度 (Power Spectral Density, PSD) $S_\phi(f)$ 在全頻帶的積分：
   $$ \lim_{N \to \infty} \frac{1}{N} \sum_{j=1}^{N} \Delta \phi_j^2 = \int_{-\infty}^{\infty} S_\phi(f) df $$
   在實務工程上，頻譜儀量測到的是單邊帶 (Single-sided) 頻譜，而且為了排除極低頻的儀器漂移以及極高頻的熱雜訊底床 (Noise Floor)，我們會限制積分範圍在特定頻帶 $[f_1, f_2]$。假設頻譜對稱，全頻帶積分等於單邊帶積分的兩倍：
   $$ \int_{-\infty}^{\infty} S_\phi(f) df \approx 2 \cdot \int_{f_1}^{f_2} S_\phi(f) df $$
   因此 $\Delta t_{rms}$ 在頻帶限制下可表示為：
   $$ \Delta t_{rms} (s) = \frac{T_b}{2\pi} \left[ 2 \int_{f_1}^{f_2} S_\phi(f) df \right]^{\frac{1}{2}} $$

4. **正規化為 UI (Unit Interval) 單位**：
   在高速 SerDes 領域，我們習慣用 UI 來表示抖動大小。將時間單位除以一個週期 $T_b$ 即可得到 UI 單位：
   $$ JG_{rms}(UI) = \frac{\Delta t_{rms}}{T_b} = \frac{1}{2\pi} \left[ 2 \int_{f_1}^{f_2} S_\phi(f) df \right]^{\frac{1}{2}} $$

5. **代入實測的 dBc/Hz 數值**：
   儀器量測的 Phase Noise 通常以對數單位 $\mathcal{L}(f)$ [dBc/Hz] 顯示。要進行積分，必須先轉回線性功率比例：
   $$ S_\phi(f) = 10^{\frac{\mathcal{L}(f)}{10}} $$
   最終實務計算公式為：
   $$ JG_{rms}(UI) = \frac{1}{2\pi} \left[ 2 \int_{f_1}^{f_2} 10^{\frac{\mathcal{L}(f)}{10}} df \right]^{\frac{1}{2}} $$

### 單位解析
**公式單位消去：**
1. **時間轉相位**：$\Delta t_j = \frac{\Delta \phi_j \cdot T_b}{2\pi}$
   $[\text{s}] = \frac{[\text{rad}] \cdot [\text{s}/\text{UI}]}{[\text{rad}/\text{UI}]} = [\text{s}]$
   *(註：$2\pi$ 的物理意義是一個週期的相位跨度，單位為 $[\text{rad}/\text{UI}]$)*
2. **Noise Power 積分**：$\int S_\phi(f) df$
   $S_\phi(f)$ 是相位的功率頻譜密度，單位為 $[\text{rad}^2/\text{Hz}]$；頻率 $f$ 單位為 $[\text{Hz}]$。
   積分結果單位：$[\text{rad}^2/\text{Hz}] \times [\text{Hz}] = [\text{rad}^2]$
3. **轉換為 UI 公式**：$JG_{rms}(UI) = \frac{1}{2\pi} \left[ \text{Noise Power} \right]^{\frac{1}{2}}$
   $[\text{UI}] = \frac{1}{[\text{rad}/\text{UI}]} \times \left( [\text{rad}^2] \right)^{\frac{1}{2}} = \frac{[\text{rad}]}{[\text{rad}/\text{UI}]} = [\text{UI}]$

**圖表單位推斷：**
📈 **時域抖動直方圖 (左下 Histogram)**：
- **X 軸**：時間差 $\Delta t$ [ps] 或 相對週期 [UI]，典型範圍 ±0.5 UI。
- **Y 軸**：發生次數 (Hits/Counts) [無單位]，典型範圍 $10^0 \sim 10^6$。
- **物理意義**：呈現 Jitter 的常態分佈 (Gaussian)，鐘形曲線的寬度代表 $JG_{rms}$，極端邊界的跨度代表 $JG_{pp}$ (Peak-to-Peak Jitter)。

📈 **頻域相位雜訊頻譜圖 (右上 Spectrum)**：
- **X 軸**：頻率偏差 $f$ (Offset frequency) [Hz]，通常是對數尺度，典型範圍 $1 \text{kHz} \sim 100 \text{MHz}$。
- **Y 軸**：相位雜訊功率頻譜密度 $S_\phi(f)$ [dBc/Hz]，典型範圍 $-80 \sim -150 \text{dBc/Hz}$。
- **物理意義**：顯示不同頻率成分的雜訊能量大小。低於 $f_1$ 的區域通常是低頻飄移 (Wander) 與訊號源干擾，高於 $f_2$ 的區域則是儀器的雜訊底床 (Noise floor) 與高頻寬頻雜訊。

### 白話物理意義
Jitter Generation 就是「在餵給 CDR 完美無瑕的訊號時，CDR 自己本身電路（如 VCO、Charge Pump）無中生有產生出來的抖動量」。

### 生活化比喻
這就像是測試一個**節拍器（CDR）**的品質。你把它放在一個絕對平穩、沒有任何震動的桌子上（提供 Jitter-free input），然後去聽它打出來的節拍。如果每次「滴答」的時間間隔都有微小的誤差，這個誤差就是節拍器內部齒輪不完美自己產生出來的（Jitter Generation）。你可以用碼表直接量測每次滴答的時間差（時域分析），也可以把它錄音下來丟進電腦分析頻率純不純（頻域分析），兩者殊途同歸。

### 面試必考點
1. **問題：在計算 Phase Noise 積分得到 RMS Jitter 時，為什麼不能從 0 積分到無限大，而要限定 $f_1$ 到 $f_2$？**
   - **答案**：因為在極低頻（趨近於 0）含有輸入源的 Wander 與低頻飄移，且 $1/f$ 雜訊會讓積分發散；而在極高頻（趨近無限大）主要是示波器/頻譜儀的雜訊底床 (Noise floor) 和與訊號無關的高頻干擾。限制 $f_1 \sim f_2$ （例如 OC-48 規範的 5kHz ~ 20MHz）才能真實反映 CDR 電路本身的抖動貢獻。
2. **問題：頻譜儀量測到的 Phase Noise 單位是 dBc/Hz，請說明如何手算或推導成 UI 單位的 Jitter？**
   - **答案**：先將 dBc/Hz 轉成線性比例 $10^{\frac{\mathcal{L}(f)}{10}}$，這代表單邊帶 PSD。接著在指定頻段內積分，並乘上 2 涵蓋雙邊頻帶能量。將此能量開根號得到相位的 RMS 誤差（單位為 radian），最後除以 $2\pi$ 即可轉換為 UI 單位。
3. **問題：在進行 Jitter Generation (JG) 測試時，儀器架設的最基本要求是什麼？**
   - **答案**：必須使用極度乾淨、理想的 Jitter-free 訊號源（如高品質的 BERT）作為輸入，並且量測儀器（Oscilloscope）必須具備 "Precision Timebase"（精密時基），以確保量測到的抖動全都是待測物 (DUT) 產生的，而非儀器本身的誤差。

**記憶口訣：**
> **JG測自己，時頻兩相宜；積分帶邊界，去底又除低；dB轉線性，積完除2Pi。**
