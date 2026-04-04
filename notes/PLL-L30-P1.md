# PLL-L30-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L30-P1.jpg

---


---
## 再生式除頻器 (Regenerative/Miller Divider) 與 LC BPF 諧波抑制分析

### 數學推導
這份筆記探討的是高速 SerDes 中常用的**米勒除頻器 (Miller Divider)**，並解釋為何在先進製程 CMOS 中，我們傾向用帶通濾波器 (BPF, 也就是 LC Tank) 來取代傳統的低通濾波器 (LPF)。

**1. 傳統 LPF 版本的操作範圍 (Operation Range)**
*   **混頻器 (Mixer) 輸出：** 假設輸入訊號為 $x(t) \propto \cos(\omega_{in}t)$，迴授的除頻訊號為 $y(t) \propto \cos(\frac{\omega_{in}}{2}t)$。
*   經過 Mixer 相乘後，輸出 $W = x \cdot y = \cos(\omega_{in}t) \cdot \cos(\frac{\omega_{in}}{2}t)$。
*   利用積化和差：$W = \frac{1}{2}\cos(\frac{\omega_{in}}{2}t) + \frac{1}{2}\cos(\frac{3\omega_{in}}{2}t)$。產生了期望的基頻 $\frac{\omega_{in}}{2}$ 與不要的諧波 $\frac{3\omega_{in}}{2}$。
*   **LPF 的限制：** LPF 必須讓基頻通過，並擋掉諧波。假設 LPF 截止頻率為 $\omega_c$。
    *   通過基頻：$\frac{\omega_{in}}{2} \le \omega_c \Rightarrow \omega_{in} \le 2\omega_c$
    *   擋掉諧波：$\frac{3\omega_{in}}{2} \ge \omega_c \Rightarrow \omega_{in} \ge \frac{2\omega_c}{3}$
*   **結論：** 操作頻率範圍被嚴格限制在 $\frac{2\omega_c}{3} \le \omega_{in} \le 2\omega_c$。

**2. CMOS BPF 版本與諧波造成的波形扭曲 (Wiggles)**
*   筆記指出 LPF 版本 "does not form a self-resonating loop" (無法形成自激振盪，需要較大輸入才能動)，在高速 CMOS 設計中，寬頻放大器難做，因此改用 **LC Tank 作為 BPF** 提供共振增益。
*   **理想無相移情況 (波形分析)：** 假設濾波器只衰減諧波，沒有相移。
    *   $y(t) \propto \cos(\frac{\omega_{in}}{2}t) + \alpha \cos(\frac{3\omega_{in}}{2}t)$，其中 $\alpha$ 是諧波衰減係數。
    *   為了讓下一級數位電路正常工作（不會發生 double-triggering），波形在過零點 (Zero-crossing, $\theta = \frac{\pi}{2}$) 時必須是單調下降的，也就是斜率必須小於 0。
    *   令 $\theta = \frac{\omega_{in}}{2}t$，對 $\theta$ 微分：$\frac{dy}{d\theta} = -\sin\theta - 3\alpha\sin3\theta$。
    *   代入 $\theta = \frac{\pi}{2}$，要求斜率為負：$-1 - 3\alpha(-1) < 0 \Rightarrow 3\alpha - 1 < 0 \Rightarrow \mathbf{\alpha < \frac{1}{3}}$。
    *   這對應了筆記中 $0 < \alpha < \frac{1}{3}$ 的條件。

**3. 真實 LC Tank 的相移效應 (The "Actually" 條件)**
*   **物理考量：** 真實的並聯 LC Tank 在共振頻率 $\omega_0 = \frac{\omega_{in}}{2}$ 時呈現純電阻性（無相移）。但在 $3\omega_0$ 的高頻處，電容阻抗遠小於電感，LC Tank **呈現電容性**，會貢獻約 **$-90^\circ$ 的相移**。
*   **方程式修正：** 原本的 $\cos(\frac{3\omega_{in}}{2}t)$ 經過 $-90^\circ$ 相移後，變成了 $\sin(\frac{3\omega_{in}}{2}t)$。
*   **結果：** $y \propto \cos(\frac{\omega_{in}}{2}t) + \alpha \sin(\frac{3\omega_{in}}{2}t)$。
*   因為這 $90^\circ$ 的相移，諧波造成波形扭曲的最嚴重位置**錯開了**原本的過零點。經過推導（尋找不產生額外極值的條件），這使得我們對諧波衰減的容忍度稍微放寬到了 $\mathbf{0 < \alpha < \frac{2}{3\sqrt{3}}}$ （約 0.385，大於原先的 0.333）。

### 單位解析
**公式單位消去：**
*   **混頻器轉移函數**：$W(t) = K_{mixer} \times x(t) \times y(t)$
    *   $x(t), y(t)$ 為電壓訊號 $[V]$
    *   $K_{mixer}$ 為混頻器轉換增益，單位為 $[V^{-1}]$ (對於 Multiplier)
    *   $[V^{-1}] \times [V] \times [V] = [V]$，輸出 $W(t)$ 仍為電壓訊號。
*   **諧波衰減係數 $\alpha$**：
    *   $\alpha = \frac{V_{peak\_harmonic}}{V_{peak\_fundamental}}$ = $[V] / [V] = [無單位 (Dimensionless)]$ 或以 $[V/V]$ 表示。

**圖表單位推斷：**
*   📈 **左上頻譜圖 (Operation Range)：**
    *   X 軸：角頻率 $\omega$ $[rad/s]$ 或 $[GHz]$。
    *   Y 軸：振幅 (Magnitude) $[dBm]$ 或 $[V]$。
*   📈 **左下 Bode Plot (LC Tank 特性)：**
    *   X 軸：頻率 $[GHz]$。
    *   Y 軸 (上圖 $|Z|$)：阻抗大小 $[\Omega]$。在 $\frac{\omega_{in}}{2}$ 處達到峰值 $R_p$。
    *   Y 軸 (下圖 相位)：相位角 $[^\circ]$ 或 $[rad]$。範圍從 $+90^\circ$ (電感性) 經過 $0^\circ$ (共振) 到 $-90^\circ$ (電容性)。
*   📈 **右側時域波形圖 (Waveforms)：**
    *   X 軸：時間 $t$ $[ps]$ (高速 SerDes 典型單位)。
    *   Y 軸：電壓 $V$ $[mV]$。

### 白話物理意義
**用 LC Tank 做除頻器，不僅能放大我們想要的半頻訊號，它在高頻時天生自帶的「電容性延遲（90度相移）」，還能巧妙地把殘留高頻雜訊的破壞力從「最敏感的過零點」移開，讓除頻器的時脈輸出更穩定！**

### 生活化比喻
想像你在聽一場演唱會（Mixer 輸出），主唱的低音是你想要的（半頻），但旁邊有個尖銳的雜音（3倍頻諧波）。
傳統的 LPF 就像是戴上耳塞，硬把雜音音量壓小（必須壓到 1/3 以下才不干擾你抓節拍）。
而 LC Tank 就像是一個特殊的音樂廳，它不僅能完美共鳴主唱的低音，還能把尖銳的雜音**「迴音延遲」（90度相移）**。因為雜音被延遲了，它最大聲的時候剛好錯開了你抓節拍（過零點）的瞬間，所以就算雜音稍微大聲一點（放寬到 2/3√3），你依然能準確踩準拍子。

### 面試必考點
1. **問題：在高速 (例如 28Gbps+) Divider 設計中，為何常使用 LC 結構而非純 CMOS LPF 的 Miller Divider？**
   → 答案：高速下 CMOS 寬頻放大增益不足。LC Tank 可在共振頻率提供高阻抗 ($R_p$) 與高增益，且 LC Tank 本身具有帶通 (BPF) 特性，能有效濾除 Mixer 產生的 $3\omega_{in}/2$ 諧波，同時若 Loop Gain > 1 還能形成 Injection-Locked (ILFD) 行為，降低輸入功率需求。
2. **問題：經典 Miller Divider 的 locking range（操作範圍）極限是如何決定的？**
   → 答案：由 LPF/BPF 必須「通過 $\frac{\omega_{in}}{2}$ 且濾除 $\frac{3\omega_{in}}{2}$」的條件決定。理論上下限為 $\frac{2}{3}\omega_c \le \omega_{in} \le 2\omega_c$。
3. **問題：如果 LC Tank 對 3 倍頻的諧波濾波能力不夠（$\alpha$ 太大），對電路會有什麼致命影響？**
   → 答案：會在時域波形的「過零點 (Zero-crossing)」附近產生非單調的扭曲 (wiggles / local minima)。這會導致下一級的數位電路（如 CML to CMOS converter）發生 Double-triggering (誤觸發)，完全毀掉 Clock 的功能。

**記憶口訣：**
**「米勒相乘生三一 (3/2 & 1/2)，LC 共振擋高頻；九十相移錯零點，單調下降保 Clock (時脈)。」**
