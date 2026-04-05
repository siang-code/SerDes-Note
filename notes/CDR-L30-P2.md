# CDR-L30-P2

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L30-P2.jpg

---


---
## [PLL-Based BB CDR] Jitter Generation (J_G) 於線性區之行為分析

### 數學推導
本頁筆記主要探討當 PLL-based Bang-Bang CDR (BB-CDR) 接收到極度乾淨的訊號時，系統產生的固有抖動 (Jitter Generation, $J_G$) 該如何分析。

1. **線性化假設 (Linear Approximation)**：
   對於一個極度乾淨的輸入 (extremely clear input)，系統追蹤的相位誤差極小。
   假設 BB-PD 的線性區間為 $\phi_m = \pm 0.03 \text{ UI}$，而系統的 RMS 抖動 $J_{rms} = 0.01 \text{ UI}$。
   根據常態分佈，$\pm 3\sigma$ (即 $\pm 0.03 \text{ UI}$) 包含了 99.9% 的機率分佈。這意味著高達 99.9% 的取樣相位誤差都落在 BB-PD 的線性區間內 (Linear region)。因此，原本非線性的 BB-CDR 可以被近似為一個純線性 PLL 來分析。

2. **轉移函數與主導雜訊 (Transfer Function & Dominant Noise)**：
   在線性區操作下，來自 PD 與 CP 的雜訊相對微小可忽略 (Negligible)。
   因此，大部分的抖動雜訊來自 VCO 本身 (Most noise comes from VCO)。
   VCO 雜訊到輸出端的轉移函數為一個高通濾波器 (High-Pass Filter, HPF)：
   $$ \frac{\phi_{out}}{\phi_{vco}} \cong \frac{s}{s + 2\xi\omega_n} $$
   *(註：此處為單極點高通之簡化模型，強調在頻寬附近的衰減特性)*

3. **迴路參數推導 (Loop Parameters)**：
   在線性區，等效 PD 增益為 $\frac{I_p}{\phi_m}$。代入標準二階 PLL 公式：
   - 自然頻率：$\omega_n = \sqrt{\frac{I_p K_{vco}}{\phi_m C_p}}$
   - 阻尼因數：$\xi = \frac{R_p}{2}\sqrt{\frac{I_p C_p K_{vco}}{\phi_m}}$
   - 迴路頻寬：由於通常設計為過阻尼 ($\xi \ge 1$)，頻寬可近似為 $\omega_{BW} = 2\xi\omega_n$。
   $$ \omega_{BW,BB} = 2\pi f_{BW,BB} = 2 \left( \frac{R_p}{2}\sqrt{\frac{I_p C_p K_{vco}}{\phi_m}} \right) \left( \sqrt{\frac{I_p K_{vco}}{\phi_m C_p}} \right) = \frac{I_p R_p K_{vco}}{\phi_m} $$
   *(註：若使用 JTRAN 模擬分析 slew 效應，頻寬模型會引入係數變為 $\frac{2 I_p R_p K_{vco}}{\pi \phi_m}$)*

4. **Jitter Generation 計算公式**：
   將 VCO 的 $1/f^2$ 相位雜訊頻譜對此 HPF 進行積分，可得出 RMS 抖動的工程近似公式：
   $$ J_{rms,BB} \cong \frac{f_0}{2} \sqrt{\frac{S_{\phi,vco}(f_0)}{\pi f_{BW,BB}}} \text{ (UI)} $$
   *(其中 $f_0$ 為評估相位雜訊的參考偏移頻率)*

### 單位解析
**公式單位消去：**
- **迴路頻寬 $\omega_{BW,BB}$**：
  $$ \frac{I_p \times R_p \times K_{vco}}{\phi_m} \Rightarrow \frac{\text{[A]} \times \text{[V/A]} \times \text{[rad/(s} \cdot \text{V)]}}{\text{[rad]}} = \frac{\text{[V]} \times \text{[rad/(s} \cdot \text{V)]}}{\text{[rad]}} = \frac{\text{[rad/s]}}{\text{[rad]}} = \text{[1/s]} = \text{[rad/s]} $$
  （嚴格來說，$\omega$ 為角頻率，單位為 rad/s，物理量綱為 $1/s$，單位消去完美吻合）

- **RMS Jitter $J_{rms,BB}$**（工程公式轉換）：
  等號右邊的根號內部為 $\frac{\text{[rad}^2\text{/Hz]}}{\text{[Hz]}} = \text{[rad}^2 \cdot \text{s}^2]$，開根號後為 $\text{[rad} \cdot \text{s]}$。乘上外面的頻率參數 $f_0 \text{ [1/s]}$ 後，得到 $\text{[rad]}$。公式中直接標註 (UI)，代表該工程公式已隱含了將弧度 (rad) 除以 $2\pi$ 轉換為 Unit Interval (UI) 的縮放常數。

**圖表單位推斷：**
📈 左上圖表 ($I_{av}$ vs $\Delta\phi$)：
- X 軸：相位誤差 $\Delta\phi \text{ [UI] 或 [rad]}$，典型範圍 $-\phi_m \sim +\phi_m$ (約 $\pm 0.03 \text{ UI}$)。
- Y 軸：平均充放電電流 $I_{av} \text{ [}\mu\text{A]}$，典型範圍 $\pm I_p$。

📈 右上圖表 ($S_{\phi,vco}$ vs $\omega$)：
- X 軸：偏移角頻率 $\omega \text{ [rad/s]}$（對數座標）。
- Y 軸：相位雜訊 PSD $S_{\phi,vco}(\omega) \text{ [rad}^2\text{/Hz]}$，呈現 $\propto 1/\omega^2$ 之斜率。

📈 下方圖表 (Phase Noise Profile $S_{\phi}(f)$ vs $f$)：
- X 軸：頻率 $f \text{ [Hz]}$（對數座標），典型範圍 100 kHz ~ 100 MHz。
- Y 軸：相位雜訊 $S_{\phi}(f) \text{ [dBc/Hz]}$ 或 $\text{[rad}^2\text{/Hz]}$，典型範圍 -80 ~ -120 dBc/Hz。
- 物理意義：展示 CDR 輸出 (ckout) 雜訊在 $f_{BW}$ 前面以 1:1 低通 (LPF) 跟隨輸入資料雜訊，在 $f_{BW}$ 後面以 1:1 高通 (HPF) 跟隨 VCO free-running 雜訊。

### 白話物理意義
當輸入訊號乾淨到幾乎沒有抖動時，BB-CDR 的相位追蹤會侷限在極小的線性微調區內；此時系統自己產生的抖動 (Jitter Generation) 幾乎全都是「VCO 本身在高頻抑制不掉的雜訊」所貢獻的。

### 生活化比喻
想像你是一個司機（CDR），開著一台引擎有點震動的車（VCO）跟著前面的引導車（Input Data）。如果引導車開得非常平穩（Clean input），你幾乎不需要猛打方向盤，只會在車道內極小幅度地微調方向（操作在線性區）。這時候，車子整體的晃動感（Jitter Generation），主要就是來自你這台車本身的引擎震動（VCO phase noise），而不是因為你跟錯車。

### 面試必考點
1. **問題：在量測 BB-CDR 的 Jitter Generation (J_G) 時，為何可以用線性 PLL 模型來分析？** 
   → 答案：因為量測 J_G 時會給予一個極度乾淨 (Jitter-free) 的輸入訊號。此時系統的相位誤差變異數極小，高達 99.9% 的時間都落在 BB-PD 狹窄的線性區間內，因此非線性行為被弱化，可視為線性系統。
2. **問題：BB-CDR 操作在線性區時，J_G 的主要雜訊貢獻來源是哪個 Block？為什麼？** 
   → 答案：是 VCO。因為輸入端乾淨且誤差小，PD/CP 貢獻的雜訊可忽略；而 VCO 的雜訊透過 High-Pass Filter 轉移函數傳遞到輸出端，頻寬外的低頻雜訊被壓抑，但高頻雜訊會直接漏到輸出端成為 J_G。
3. **問題：要如何從系統層級降低 CDR 的 Jitter Generation？** 
   → 答案：根據公式 $J_{rms} \propto 1/\sqrt{f_{BW}}$，可以透過增加迴路頻寬 ($f_{BW,BB}$) 來擴大 HPF 對 VCO 雜訊的抑制範圍；或者直接採用 Phase noise 更優良的 VCO ($S_{\phi,vco}$ 較小)。

**記憶口訣：**「輸入乾淨跑線性，雜訊全看 V C O，頻寬越寬壓越低。」
