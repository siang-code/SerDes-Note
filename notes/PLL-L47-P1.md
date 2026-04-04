# PLL-L47-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L47-P1.jpg

---


---
## ADPLL Phase Noise Analysis & TDC Architecture

### 數學推導
本頁筆記主要分析 ADPLL (All-Digital PLL) 中 TDC (Time-to-Digital Converter) 與 DCO (Digitally Controlled Oscillator) 對整體相位雜訊 (Phase Noise) 的貢獻。

**1. TDC 頻內相位雜訊貢獻 (TDC In-band Phase Noise)**
*   **參數設定**：DCO 輸出頻率 $f_{out} = 1.0\text{ GHz} \Rightarrow T_{vco} = 1\text{ ns} = 1000\text{ ps}$。參考頻率 $f_{ref} = 100\text{ MHz}$。TDC 解析度 $\Delta T = 10\text{ ps}$。
*   **定義 $N_p$**：定義 $N_p$ 為一個 DCO 週期內可以切出多少個 TDC 解析度（TDC bins per VCO period）。
    $$N_p = \frac{T_{vco}}{\Delta T} = \frac{1000\text{ ps}}{10\text{ ps}} = 100$$
*   **相位誤差變異數**：TDC 量化誤差 $\Delta t$ 為均勻分佈，時間誤差變異數為 $\sigma_t^2 = \frac{\Delta T^2}{12}$。在 ADPLL 中，這等效於鑑相器 (Phase Detector) 端的相位誤差，對應的相位變異數為：
    $$\sigma_{\phi, PD}^2 = \frac{1}{12} \left(2\pi \frac{\Delta T}{T_{vco}}\right)^2 = \frac{4\pi^2}{12 N_p^2} = \frac{\pi^2}{3 N_p^2}$$
*   **頻譜密度 (PSD)**：此雜訊在 $f_{ref}$ 的取樣率下均勻散佈於 Nyquist 頻帶，其單邊帶功率頻譜密度為：
    $$S_{\phi, TDC} = \frac{\sigma_{\phi, PD}^2}{f_{ref}} = \frac{\pi^2}{3 N_p^2 f_{ref}}$$
*   **輸出端雜訊**：在迴路頻寬內 ($f < 1\text{ MHz}$)，PLL 對參考端雜訊呈現低通特性，並放大 $M$ 倍（相位）或 $M^2$ 倍（功率），其中 $M = f_{out}/f_{ref} = 10$。
    $$S_{\phi, out} = S_{\phi, TDC} \cdot M^2 = \frac{\pi^2}{3 N_p^2 f_{ref}} M^2$$
    代入數值：
    $$S_{\phi, out} = \frac{\pi^2}{3 \cdot (100)^2 \cdot 10^8} \cdot 10^2 = \frac{\pi^2}{3 \cdot 10^{10}} \approx 3.289 \times 10^{-10} \text{ rad}^2\text{/Hz}$$
    換算成 dBc/Hz：$10 \log_{10}(3.289 \times 10^{-10}) = -94.8 \text{ dBc/Hz}$。（與筆記精準吻合）

**2. DCO 頻內相位雜訊貢獻 (DCO In-band Phase Noise)**
*   **開迴路雜訊**：DCO 開迴路相位雜訊在低頻呈現 $1/f^2$ (斜率 $-20\text{dB/dec}$)。已知在偏移頻率 $1\text{ MHz}$ 處為 $-125\text{ dBc/Hz}$，可設 $S_{\phi, DCO}(f) = \frac{K}{f^2}$。
*   **閉迴路高通濾波**：PLL 對 DCO 雜訊具有高通濾波 (HPF) 特性。因系統過阻尼 ($\zeta = 5$)，可近似為一階高通 $|H_{HPF}(f)|^2 \approx \frac{(f/f_c)^2}{1+(f/f_c)^2}$，轉角頻率 $f_c = 1\text{ MHz}$。
*   **閉迴路頻內雜訊**：將開迴路雜訊乘上濾波器轉移函數，當 $f \ll f_c$ 時：
    $$S_{\phi, out\_DCO}(f) \approx \frac{K}{f^2} \cdot \frac{f^2}{f_c^2} = \frac{K}{f_c^2} = S_{\phi, DCO}(f_c)$$
    這證明了 **DCO 經過 PLL 閉迴路後，頻內的雜訊會被「壓平」，且大小剛好等於開迴路在迴路頻寬 ($f_c$) 處的雜訊值**，即 $-125\text{ dBc/Hz}$。

### 單位解析
**公式單位消去：**
TDC 輸出相位雜訊 PSD：
$$S_{\phi, out} = \frac{\pi^2}{3 N_p^2 f_{ref}} M^2$$
- $N_p, M$：皆為比例值，無單位 $[-]$。
- $\pi^2/3$：隱含相位平方單位 $[\text{rad}^2]$。
- $f_{ref}$：頻率單位 $[\text{Hz}] = [1/\text{s}]$。
消去過程：
$[S_{\phi, out}] = \frac{[\text{rad}^2]}{[-] \cdot [1/\text{s}]} \cdot [-] = [\text{rad}^2 \cdot \text{s}] = [\text{rad}^2\text{/Hz}]$
對數轉換後即為面試與規格書常用的 $[\text{dBc/Hz}]$。

**圖表單位推斷：**
📈 右上圖（DCO 開迴路 Phase Noise）：
- X 軸：Offset Frequency $f$ $[\text{Hz}]$（對數尺度），典型範圍 $100\text{ kHz} \sim 10\text{ MHz}$。
- Y 軸：Phase Noise $\mathcal{L}(f)$ $[\text{dBc/Hz}]$，典型範圍 $-105 \sim -125\text{ dBc/Hz}$。
📈 左下圖（閉迴路 Phase Noise 貢獻）：
- X 軸：Offset Frequency $f$ $[\text{Hz}]$（對數尺度）。
- Y 軸：Phase Noise PSD $[\text{dBc/Hz}]$。
- 顯示 TDC（低頻平坦於 $-94.8$ 後滾降）與 DCO（低頻平坦於 $-125$ 後滾降）各自的貢獻曲線。
📈 右下圖（TDC 波形時序）：
- X 軸：Time $[\text{ps}]$ 或 $[\text{ns}]$。
- Y 軸：Voltage $[\text{V}]$（邏輯準位 High/Low）。

### 白話物理意義
TDC 把連續的時間差「四捨五入」成數位刻度所產生的誤差，在低頻時會被 PLL 放大並直接呈現在輸出端；而 DCO 本身亂飄的低頻雜訊，則會被 PLL 強力拉回（負回授），壓制到一個平坦的水位。

### 生活化比喻
- **TDC 雜訊 (Low-Pass)**：TDC 就像你用「最小刻度 1 公分」的尺去量布料（解析度 $\Delta T$）。量不準的誤差，經過工廠（PLL 放大 $M$ 倍）做成衣服後，尺寸公差就固定在那裡。要縮小公差，只能換一把「最小刻度 1 毫米」的尺（增加 $N_p$）。
- **DCO 濾波 (High-Pass)**：DCO 就像一個酒醉容易偏離車道的司機（低頻雜訊大）。PLL 就像副駕駛，只要司機慢慢偏離（低頻），副駕就能拉回方向盤（壓平雜訊）；但如果司機手抖得太快（超過副駕反應頻寬 $1\text{MHz}$），副駕來不及拉，車子就只能跟著抖（高頻雜訊不濾波）。

### 面試必考點
1. **問題：在 ADPLL 中，如何降低 TDC quantization noise 造成的 in-band phase noise？**
   → **答案**：(1) 提高 TDC 解析度（減小 $\Delta T$，即筆記所寫 $N_p \uparrow$），例如從 Conventional TDC 改用 Vernier TDC 架構。 (2) 提高參考時脈頻率 $f_{ref}$（透過 Oversampling 將雜訊功率均攤到更寬的頻帶）。
2. **問題：請證明 DCO 經過 PLL 閉迴路後，頻內的相位雜訊（in-band noise）剛好等於它在開迴路時於頻寬 $f_c$ 處的值。**
   → **答案**：DCO 的開迴路雜訊正比於 $1/f^2$。PLL 對 DCO 呈現高通濾波（HPF），在頻寬內轉移函數正比於 $f^2/f_c^2$。兩者相乘後 $f^2$ 抵銷，留下常數項，其大小恰等於開迴路在 $f_c$ 的雜訊值。
3. **問題：Conventional TDC 跟 Vernier TDC 的極限解析度各由什麼決定？**
   → **答案**：Conventional TDC 解析度受限於單一邏輯閘的絕對延遲時間（$\Delta t_1$），有物理製程極限。Vernier TDC 透過兩條延遲線並行，解析度由兩個邏輯閘的「延遲差」決定（$|\Delta t_1 - \Delta t_2|$），可突破單一閘極限達到 sub-picosecond 級別。

**記憶口訣：**
- **TDC 看解析**：尺越細（$N_p$ 大），誤差越小；低通跟著走。
- **DCO 壓低頻**：低頻被壓平，高度看頻寬（$f_c$）。
- **Vernier 算差值**：龜兔賽跑，追的是時間差（$|\Delta t_1 - \Delta t_2|$）。
