# PLL-L46-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L46-P1.jpg

---


---
## TDC 量化雜訊與 ADPLL 相位雜訊貢獻分析

### 數學推導
在全數位鎖相迴路 (ADPLL) 中，Time-to-Digital Converter (TDC) 會將時間差轉換為數位訊號，這個「數位化」過程會產生量化誤差。
1. **量化誤差的模型化**：
   - 假設 TDC 的相位解析度為 $\Delta\phi = \frac{2\pi}{N_p}$ （其中 $N_p$ 為一個週期內可解析的階數）。
   - 量化誤差 $x$ 被假設為均勻分佈 (Uniform Distribution)，範圍落在 $[-\frac{\pi}{N_p}, \frac{\pi}{N_p}]$。
   - 機率密度函數 $f(x) = \frac{N_p}{2\pi}$，滿足 $\int_{-\infty}^{\infty} f(x)dx = 1$。
2. **量化雜訊的變異數 (Variance, 即雜訊功率)**：
   - $\sigma^2 = \int_{-\infty}^{\infty} x^2 f(x) dx = \int_{-\frac{\pi}{N_p}}^{\frac{\pi}{N_p}} x^2 \left(\frac{N_p}{2\pi}\right) dx$
   - $\sigma^2 = \frac{N_p}{2\pi} \left[ \frac{x^3}{3} \right]_{-\pi/N_p}^{\pi/N_p} = \frac{N_p}{2\pi} \cdot \frac{2}{3} \left(\frac{\pi}{N_p}\right)^3 = \frac{\pi^2}{3N_p^2}$
3. **TDC 量化雜訊的功率頻譜密度 (PSD)**：
   - TDC 在每個參考週期 $T$ (或 $T_{ref}$) 進行一次取樣與保持 (Zero-Order Hold)。在低頻下 (Sinc 函數效應 $\approx 1$)，其等效白雜訊 PSD 為變異數乘上更新週期 $T$：
   - $S_{\phi, TDC}(\omega) \approx \sigma^2 \cdot T = \frac{T \pi^2}{3 N_p^2}$
4. **ADPLL 輸出端的總相位雜訊疊加**：
   - 輸出端雜訊 $S_{\phi, out}(\omega)$ 主要來自兩大部分：TDC 雜訊與 DCO 雜訊。
   - $S_{\phi, out}(\omega) = S_{\phi, TDC} \cdot \left| \frac{\phi_{out}}{\phi_{in}} \right|^2 + S_{\phi, DCO}(\omega) \cdot \left| \frac{\phi_{out}}{\phi_{DCO}} \right|^2$
   - TDC 雜訊視為參考輸入端雜訊，經過閉迴路呈 **低通特性 (Low-pass)**，並乘上除數 $M$。
   - DCO 雜訊從輸出端注入，經過閉迴路呈 **高通特性 (High-pass)**。
   - 代入轉移函數：
     $S_{\phi, out}(\omega) = \frac{T \pi^2}{3 N_p^2} \cdot \left| M \frac{2\zeta\omega_n s + \omega_n^2}{s^2 + 2\zeta\omega_n s + \omega_n^2} \right|^2 + S_{\phi, DCO}(\omega_0)\frac{\omega_0^2}{\omega^2} \cdot \left| \frac{s^2}{s^2 + 2\zeta\omega_n s + \omega_n^2} \right|^2$

### 單位解析
**公式單位消去：**
- $f(x) = \frac{N_p}{2\pi}$：$[1/rad]$ （機率密度，對相位積分後為無因次機率）
- 量化變異數 $\sigma^2 = \int x^2 f(x) dx$：$[rad^2] \times [1/rad] \times [rad] = [rad^2]$
- $S_{\phi, TDC} = \sigma^2 \cdot T$：$[rad^2] \times [s] = [rad^2/Hz]$ （在工程上通常取 $10 \log_{10}$ 轉換為 $dBc/Hz$）
- DCO 雜訊模型 $S_{\phi, DCO}(\omega) = S_{\phi, DCO}(\omega_0) \cdot \frac{\omega_0^2}{\omega^2}$：$[rad^2/Hz] \times \frac{[rad/s]^2}{[rad/s]^2} = [rad^2/Hz]$

**圖表單位推斷：**
- 📈 圖表 1（均勻分佈 PDF）：
  - X 軸：相位量化誤差 $x$ $[rad]$，典型範圍 $-\frac{\pi}{N_p} \sim \frac{\pi}{N_p}$
  - Y 軸：機率密度 $f(x)$ $[1/rad]$，恆定值為 $\frac{N_p}{2\pi}$
- 📈 圖表 2（DCO 自由震盪相位雜訊頻譜）：
  - X 軸：頻率偏移 (Offset Frequency) $\omega$ $[rad/s]$ 或 $[Hz]$，對數座標 (Log scale)
  - Y 軸：相位雜訊 PSD $S_{\phi, DCO}(\omega)$ $[dBc/Hz]$，呈現 $\propto 1/\omega^2$（即 -20dB/dec）的斜率下降

### 白話物理意義
TDC 就像一把刻度不夠精細的尺，每次測量時差都會有「四捨五入」的誤差。這個誤差在頻譜上會變成均勻的白雜訊，經過 PLL 的迴路後，低頻的部分會被放大並傳遞到輸出端，造成輸出的 Jitter。

### 生活化比喻
想像你要用一把「最小刻度是公分」的尺，去量測「公釐」等級的精細物體。每次量測你都只能估計或進位，產生約 $\pm 0.5$ 公分的誤差。雖然長期平均下來你沒有多算或少算（平均值為 0），但如果你根據每一次「帶有隨機誤差的讀數」去微調一台機器的運轉，機器就會因為這些微小的判斷誤差而產生持續的抖動。這就是 TDC 量化雜訊對 PLL 造成的影響。

### 面試必考點
1. **問題：在 ADPLL 中，TDC 的量化雜訊在輸出端呈現什麼樣的頻率響應特性？**
   - 答案：TDC 雜訊等效於參考輸入雜訊，經過 PLL 閉迴路後呈現**低通響應 (Low-pass)**，低頻區段的雜訊會無衰減地傳遞到輸出端並乘上 $M^2$（除數的平方），高頻區段則會被濾除。
2. **問題：如果要降低 TDC 量化雜訊對整體的影響，系統設計上可以調整哪些參數？**
   - 答案：(1) 提高 TDC 解析度（減小 $\Delta t$ 或增加 $N_p$）；(2) 降低 PLL 的迴路頻寬 $\omega_n$（讓更少的 TDC 低頻雜訊通過）；(3) 提高參考時脈頻率 $f_{ref}$（減小更新週期 $T$，使雜訊能量更分散於高頻）。
3. **問題：在決定 ADPLL 的迴路頻寬 (Loop Bandwidth) 時，你該如何權衡 TDC 雜訊與 DCO 雜訊？**
   - 答案：TDC 雜訊具低通特性（頻寬越窄，雜訊越小）；DCO 雜訊具高通特性（頻寬越寬，抑制 DCO 自身雜訊的能力越強）。因此必須找到一個「最佳迴路頻寬 (Optimal Loop Bandwidth)」，使得兩者交會點的總積分雜訊（Jitter 面積）達到最小。

**記憶口訣：**
「**TDC 像白紙被低通壓，DCO 像溜滑梯被高通擋，兩者打架找最佳頻寬。**」
