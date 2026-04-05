# CDR-L19-P2

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L19-P2.jpg

---


---
## Capture Range & Lock Range (捕捉範圍與鎖定範圍)

### 數學推導
本頁筆記的核心在於推導「當輸入資料頻率發生瞬間跳變（Step）時，CDR 能保持不失鎖（Unlock）的最大頻率誤差（Capture Range）」。
1. **輸入條件設定：**
   假設輸入資料頻率 $\omega$ 發生一個大小為 $\Delta\omega$ 的步階變化（Step function）。
   以物理意義來說：轉速（頻率 $\omega$）的積分是距離（相位 $\phi$）。
   因此時域上的輸入相位為：$\phi_{in}(t) = \int \Delta\omega \cdot u(t) dt = \Delta\omega \cdot t$ （這是一個斜波 Ramp）。
2. **拉普拉斯轉換 (Laplace Transform)：**
   將時域相位轉換至 S 域，因 $t \xrightarrow{\mathcal{L}} \frac{1}{s^2}$，所以輸入相位為：
   $$ \phi_{in}(s) = \frac{\Delta\omega}{s^2} $$
3. **系統相位誤差轉移函數：**
   二階 PLL 的相位轉移函數為 $H(s) = \frac{\phi_{out}(s)}{\phi_{in}(s)} = \frac{2\zeta\omega_n s + \omega_n^2}{s^2 + 2\zeta\omega_n s + \omega_n^2}$。
   我們關心的是「相位誤差」 $\phi_e(s) = \phi_{in}(s) - \phi_{out}(s) = \phi_{in}(s) [1 - H(s)]$，因此誤差轉移函數 $E(s)$ 為：
   $$ E(s) = 1 - H(s) = \frac{s^2}{s^2 + 2\zeta\omega_n s + \omega_n^2} $$
   所以，S 域的相位誤差為：
   $$ \phi_e(s) = \phi_{in}(s) \cdot E(s) = \frac{\Delta\omega}{s^2} \cdot \frac{s^2}{s^2 + 2\zeta\omega_n s + \omega_n^2} = \frac{\Delta\omega}{s^2 + 2\zeta\omega_n s + \omega_n^2} $$
4. **求最大相位誤差發生的時間 $t_1$：**
   將 $\phi_e(s)$ 作反拉普拉斯轉換（Inverse Laplace Transform）得到時域函數 $\phi_e(t)$。對時間微分找極值（$\frac{d\phi_e(t)}{dt} = 0$），可解出最大誤差發生在時間 $t_1$：
   $$ t_1 = \frac{1}{2\omega_n\sqrt{\zeta^2-1}} \ln\left[ \frac{\zeta + \sqrt{\zeta^2-1}}{\zeta - \sqrt{\zeta^2-1}} \right] $$
5. **求最大相位誤差量 $\Delta\phi_{max}$：**
   將 $t_1$ 代回 $\phi_e(t)$ 中，得到系統會產生的最大相位飄移量：
   $$ \Delta\phi_{max} = \frac{\Delta\omega}{2\omega_n\sqrt{\zeta^2-1}} \left[ \frac{\zeta - \sqrt{\zeta^2-1}}{\zeta + \sqrt{\zeta^2-1}} \right]^{\frac{\zeta-\sqrt{\zeta^2-1}}{2\sqrt{\zeta^2-1}}} $$
   **維持鎖定的條件**：對於 Linear PD，最大的線性區間為 $\pm 2\pi$。要重新鎖定（relock），最大相位誤差必須小於 $2\pi$：
   $$ \Delta\phi_{max} < 2\pi $$
6. **高阻尼系統（Overdamped, $\zeta \gg 1$）之近似化簡：**
   當阻尼比 $\zeta$ 很大時，$\sqrt{\zeta^2-1} \approx \zeta - \frac{1}{2\zeta}$。
   指數項 $\frac{\zeta-\sqrt{\zeta^2-1}}{2\sqrt{\zeta^2-1}} \approx \frac{1/2\zeta}{2\zeta} \approx 0$。任何數的 0 次方趨近於 1。
   因此前面那一長串中括號的次方項會趨近於 1，公式大幅簡化為：
   $$ \Delta\phi_{max} \approx \frac{\Delta\omega}{2\omega_n \cdot \zeta} < 2\pi $$
   移項後得到 Capture Range (可容忍的最大 $\Delta\omega$)：
   $$ |\Delta\omega| < 2\pi \cdot 2\zeta\omega_n $$
   又因為在 $\zeta \gg 1$ 時，二階 PLL 的迴路頻寬 $\omega_{-3dB} \approx 2\zeta\omega_n$。
   最終結論：**$|\Delta\omega| < 2\pi \cdot \omega_{-3dB}$，代表 Capture Range 大約就是 Loop Bandwidth 的數量級。**

### 單位解析
**【公式單位消去法】**
- **自然頻率 $\omega_n$**：
  $$ \omega_n = \sqrt{ \frac{I_p K_{vco}}{2\pi C_p} } = \sqrt{ K_{PD} \frac{K_{vco}}{C_p} } $$
  * $K_{PD} = \frac{I_p}{2\pi}$ 單位：$[A / rad]$
  * $K_{vco}$ 單位：$[rad \cdot s^{-1} / V]$
  * $C_p$ 單位：$[F] = [A \cdot s / V]$
  * 消去過程：$\sqrt{ \frac{[A]}{[rad]} \times \frac{[rad / (s \cdot V)]}{[A \cdot s / V]} } = \sqrt{ \frac{1}{s^2} } = [rad/s]$ （角頻率單位，正確）。

- **阻尼比 $\zeta$**：
  $$ \zeta = \frac{R_p}{2} \sqrt{ \frac{I_p C_p K_{vco}}{2\pi} } = \frac{R_p}{2} \sqrt{ K_{PD} \cdot C_p \cdot K_{vco} } $$
  * $R_p$ 單位：$[\Omega] = [V / A]$
  * 根號內單位：$[A / rad] \times [A \cdot s / V] \times [rad / (s \cdot V)] = [A^2 / V^2]$
  * 消去過程：$[V / A] \times \sqrt{[A^2 / V^2]} = [V / A] \times [A / V] = 1$ （無因次 Dimensionless，正確）。

**【圖表單位推斷】**
📈 **圖表單位推斷：**
1. **Locking Range vs Capture Range 示意圖 (左上)**：
   - X 軸：頻率範圍 $[\text{MHz 或 GHz}]$，標示出 Capture Range 遠小於 Locking Range。
   - Y 軸：無特定物理量，僅作為區塊標示。
2. **Linear PD 特性曲線 (左中)**：
   - X 軸：輸入與輸出的相位差 $\Delta\phi$ $[\text{rad}]$，典型範圍 $-2\pi \sim 2\pi$。
   - Y 軸：平均輸出電流 $I_{AV}$ $[A]$，典型範圍 $-I_p \sim I_p$（約數十至數百 $\mu A$）。
3. **Data Rate 步階變化圖 (中上)**：
   - X 軸：時間 $t$ $[\mu s]$。
   - Y 軸：資料傳輸頻率 Data Rate $[\text{rad/s 或 Gbps}]$，在 $t=0$ 時發生 $\Delta\omega$ 的跳變。
4. **相位追蹤圖 Phase Tracking (右上)**：
   - X 軸：時間 $t$ $[\mu s]$，標示最大誤差發生的時間 $t_1$。
   - Y 軸：累積相位 $\phi$ $[\text{rad}]$，藍線為輸入相位 $\phi_{in}(t)$（斜率增加），紅線為輸出相位 $\phi_{out}(t)$ 努力追趕的軌跡。若紅藍線垂直距離（相差） $> 2\pi$，則系統失鎖（Unlock）。

### 白話物理意義
Capture Range 就是「當輸入頻率突然瞬間暴衝改變時，CDR 靠著自身的頻寬還來得及追上，且不至於讓感測器（PD）因為看不到車尾燈（相位差 $>2\pi$）而直接放棄追蹤的最大容忍極限。」

### 生活化比喻
把 CDR 想像成一台**「自動跟車系統」**：
- **Locking Range (鎖定範圍)**：是你這台車引擎能開的「極速與怠速範圍」。只要前車是**「慢慢加速」**，你就能一路穩穩跟到極速。這範圍只受限於你的硬體 (VCO Tuning Range)。
- **Capture Range (捕捉範圍)**：是當前車**「瞬間重踩油門暴衝」**時，你的雷達反應速度（Loop Bandwidth）。如果前車瞬間加速太多，兩車距離瞬間拉大超過你雷達的可視範圍（超過 $2\pi$），你的系統就會判定「目標丟失 (Unlock)」。所以捕捉範圍很小，通常需要另一個遠程雷達 (FD, 頻率偵測器) 先把車速拉近，再交給精準的跟車雷達 (PD)。

### 面試必考點
1. **問題：在設計 CDR 時，Capture Range 和 Locking Range 哪一個通常比較大？分別受什麼限制？**
   → **答案**：Locking Range 遠大於 Capture Range。Locking Range 是靜態的，只受限於 VCO 的頻率可調範圍（Tuning Range）。Capture Range 是動態暫態的，受限於 CDR 系統的迴路頻寬（Loop Bandwidth），頻寬越大，反應越快，Capture Range 才越大。
2. **問題：在純資料傳輸的 CDR 中，為什麼我們總是需要兩個 Loop (FD loop 與 PD loop)？不能只用一個 Phase-Frequency Detector (PFD) 嗎？**
   → **答案**：因為 Random Data 會有很多連續的 0 或 1，缺少時鐘邊緣（Edge），傳統的 PFD 遇到 missing edge 會誤判，導致嚴重錯誤（這點筆記開頭寫到 unfortunately no "PFD" exists in CDR）。因此只能用單純的 PD，但單純 PD 的 Capture Range 太小，所以必須外加一個 Frequency Detector (FD) 迴路，先把頻率誤差拉近到 PD 的迴路頻寬內，再交接給 PD 去做精準相位對齊。
3. **問題：推導證明高度過阻尼（Highly Overdamped, $\zeta \gg 1$）二階 PLL 的 Capture Range 大致與什麼參數成正比？**
   → **答案**：與系統的 $-3dB$ 迴路頻寬（$\omega_{-3dB}$）成正比。從最大相位誤差公式推導可化簡為 $\Delta\phi_{max} \approx \frac{\Delta\omega}{2\zeta\omega_n} < 2\pi$。因為高阻尼下 $2\zeta\omega_n \approx \omega_{-3dB}$，所以可容忍的最大頻率步階 $|\Delta\omega| < 2\pi \cdot \omega_{-3dB}$。

**記憶口訣：**
「**鎖定**看**硬體極限**(VCO)，**捕捉**看**反應頻寬**(Loop BW)；**瞬間暴衝** PD 會瞎，要靠 **FD 先拉近**。」
