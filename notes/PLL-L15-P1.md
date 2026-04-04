# PLL-L15-P1

> 分析日期：2026-04-04
> 原始圖片：images/PLL-L15-P1.jpg

---

---
## Charge Pump PLL 之優點與雜訊轉移函數 (Noise Transfer Function of CP PLL)

### 數學推導
這頁筆記的核心在於推導並理解 PLL 系統對不同來源雜訊的**轉移函數 (Transfer Function)**。我們使用回授控制系統的標準模型來推導：

1. **定義開迴路轉移函數 (Open-Loop Gain, $L(s)$):**
   PLL 的順向路徑包含：Phase Detector/Charge Pump ($K_{PD} = \frac{I_P}{2\pi}$)、Loop Filter ($Z(s) = R_P + \frac{1}{sC_P}$)、以及 VCO ($K_{VCO}/s$)。回授路徑為除頻器 ($H(s) = \frac{1}{M}$)。
   $$L(s) = \left( \frac{I_P}{2\pi} \right) \cdot \left( \frac{sR_P C_P + 1}{sC_P} \right) \cdot \left( \frac{K_{VCO}}{s} \right) \cdot \left( \frac{1}{M} \right)$$
   整理後可得：
   $$L(s) = \frac{I_P K_{VCO} (sR_P C_P + 1)}{2\pi M C_P s^2}$$

2. **定義系統特徵參數 ($\omega_n$ 與 $\zeta$):**
   閉迴路系統的特徵方程式為 $1 + L(s) = 0$。將其分母整理成二階系統標準式 $s^2 + 2\zeta\omega_n s + \omega_n^2 = 0$：
   $$s^2 + \left( \frac{I_P K_{VCO} R_P}{2\pi M} \right)s + \left( \frac{I_P K_{VCO}}{2\pi M C_P} \right) = 0$$
   對照係數可得筆記上的兩個重要公式：
   - **自然頻率 (Natural Frequency):** $\omega_n^2 = \frac{I_P K_{VCO}}{2\pi M C_P} \implies \omega_n = \sqrt{\frac{I_P \cdot K_{VCO}}{2\pi M C_P}}$
   - **阻尼因數 (Damping Factor):** $2\zeta\omega_n = \frac{I_P K_{VCO} R_P}{2\pi M} \implies \zeta = \frac{R_P}{2} \sqrt{\frac{I_P C_P K_{VCO}}{2\pi M}}$

3. **推導輸入端雜訊轉移函數 (Input Noise to Output, Low-pass):**
   利用 Black's Formula: $H_{in}(s) = \frac{\phi_{out}}{\phi_{in}} = \frac{G(s)}{1 + L(s)} = M \cdot \frac{L(s)}{1 + L(s)}$
   將 $L(s)$ 代入並同乘分母，即可將分子分母整理成筆記中的形式：
   $$\frac{\phi_{out}}{\phi_{in}} = M \frac{2\zeta\omega_n s + \omega_n^2}{s^2 + 2\zeta\omega_n s + \omega_n^2}$$
   *(這是一個帶有左半平面零點的二階低通濾波器，DC 增益為 M)*

4. **推導 VCO 端雜訊轉移函數 (VCO Noise to Output, High-pass):**
   VCO 雜訊直接加在輸出端，此時順向路徑為 1，回授路徑為原本的 $L(s)$，故轉移函數為：
   $$H_{VCO}(s) = \frac{\phi_{out}}{\phi_{VCO}} = \frac{1}{1 + L(s)}$$
   代入整理後得到：
   $$\frac{\phi_{out}}{\phi_{VCO}} = \frac{s^2}{s^2 + 2\zeta\omega_n s + \omega_n^2}$$
   *(這是一個標準的二階高通濾波器)*

---

### 單位解析

**公式單位消去：**
針對 PLL 核心參數 $\omega_n$ 進行單位消去檢驗。
已知：
- $I_P$ (Charge Pump Current) = `[A]` (安培)
- $K_{VCO}$ (VCO Gain) = `[rad/s/V]` (每伏特產生多少角頻率變化)
- $C_P$ (Loop Filter Capacitor) = `[F]` = `[A·s/V]` (庫侖/伏特 = 安培·秒/伏特)
- $M$ (Divider Ratio) = 無單位

將單位代入 $\omega_n$ 公式中：
$$ \omega_n = \sqrt{ \frac{[A] \cdot [rad/s/V]}{[A \cdot s/V]} } = \sqrt{ \frac{[A] \cdot [rad] \cdot [V]}{[A] \cdot [s] \cdot [V] \cdot [s]} } = \sqrt{ \frac{rad}{s^2} } = [rad/s] $$
**驗證成功：** $\omega_n$ 的單位精準對應角頻率 `[rad/s]`。阻尼因數 $\zeta$ 若進行相似推演，結果會是無單位 (Dimensionless)，符合物理定義。

**圖表單位推斷：**
本頁筆記有多張關鍵圖表，其隱藏單位如下：
1. 📈 **左上 Eye Diagram (眼圖) 單位推斷：**
   - X 軸：時間 `[ps]` 或 `[UI]` (Unit Interval)。對於高速 SerDes，典型範圍約為 1 UI (例如 10Gbps 下為 100ps)。
   - Y 軸：差分電壓 `[mV]`，典型範圍約 $\pm 200 \text{ mV}$ 到 $\pm 400 \text{ mV}$。
2. 📈 **左中 Jitter Histogram (常態分佈圖) 單位推斷：**
   - X 軸：過零點時間偏差 $\Delta t$ `[ps]`，圖中的 $t_{rms}$ 即為 RMS Jitter，典型值在 $< 1 \text{ ps}$ 左右。
   - Y 軸：機率密度 (Probability Density)。
3. 📈 **右下 Bode Plots (Noise Transfer Function) 單位推斷：**
   - X 軸：頻率 $\omega$ `[rad/s]` 或 $f$ `[Hz]` (Logarithmic scale 對數尺度)。
   - Y 軸：轉移函數大小 $|H(s)|$ `[dB]`。例如左圖低頻平坦區的增益為 $0 \text{ dB}$ (表示經過除 $M$ 歸一化後為 $1$)，高頻以 $-20 \text{ dB/dec}$ 或 $-40 \text{ dB/dec}$ 衰減。

---

### 白話物理意義
**PLL 就像是一個「雙向濾波器」**：它是一個**低通濾波器**（負責把輸入 Reference Clock 的高頻雜訊濾掉不跟），同時也是一個**高通濾波器**（負責偵測並壓抑自己 VCO 產生的低頻飄移），最終確保輸出的時脈乾淨穩定。

---

### 生活化比喻
想像你（代表 VCO）在跟著一個節拍器（代表 Reference Clock）跳舞。
- **輸入端低通 (Input Low-pass):** 節拍器偶爾會因為故障，突然快慢閃爍一下（輸入端的高頻雜訊 Jitter）。因為你的反應沒有那麼快（迴路頻寬限制），你不會跟著那個神經質的閃爍亂跳，而是維持著平穩的平均舞步。這就是 PLL **過濾掉了輸入的高頻雜訊**。
- **VCO端高通 (VCO High-pass):** 但如果是你自己因為緊張，手腳發抖（VCO 內部產生的高頻雜訊），節拍器也來不及糾正你這麼快速的抖動，所以觀眾會直接看到你發抖（高頻雜訊直接輸出）。只有當你慢慢偏離節奏（VCO 產生的低頻飄移），你才會聽到節拍器的聲音並慢慢修正回來。這就是 PLL **只能壓抑 VCO 的低頻雜訊，而高頻雜訊會漏出去（高通特性）**。

---

### 面試必考點

1. **問題：為什麼 PLL 的 Input Phase Noise 是 Low-pass，而 VCO Phase Noise 是 High-pass？**
   - **答案：** 因為 Input 信號必須經過整個 Forward Path (包含 VCO 的 $1/s$ 積分) 才抵達輸出，高頻時這些元件的增益衰減，故呈現 Low-pass。而 VCO 雜訊直接在輸出端產生，其回授修正路徑 (Feedback Path) 對高頻來不及反應，雜訊直接流出 (High-pass)；低頻時迴路增益大，能有效偵測並扣除誤差，達到抑制效果。

2. **問題：觀察筆記右下角的 Bode Plot，當 $\zeta$ 太小 (例如 $\zeta=0.2$) 時會發生什麼事？這在 SerDes 中有何致命影響？**
   - **答案：** 當阻尼因數 $\zeta$ 太小 (Under-damped)，在頻寬 $\omega_n$ 附近會出現 **Jitter Peaking (雜訊突波)**，轉移增益會大於 0 dB (大於 1)。在 SerDes 系統中，若多個 PLL 或 CDR 串聯 (Cascaded)，這個 Peaking 會把特定頻段的 Jitter 指數級放大，導致眼圖完全閉合 (Eye Closure) 及誤碼率 (BER) 飆高。設計上通常要求 $\zeta \ge 0.707$ 以將 Peaking 控制在 0.1 dB 以內。

3. **問題：如果要降低 VCO 的「高頻」Phase Noise，增加 Loop Bandwidth ($\omega_n$) 有效嗎？**
   - **答案：** **無效。** 增加 Loop Bandwidth 只能把 High-pass 的 cut-off 頻率往右推，這意味著它只能抑制更多的「VCO 低頻雜訊」。高於頻寬的高頻雜訊仍然會直接輸出。要解決 VCO 高頻雜訊，只能從 VCO 本體的設計下手 (例如提高 LC Tank 的 Q 值、增加電流以降低熱雜訊貢獻)。

**記憶口訣：**
> **「入低出高，Peaking 糟糕，頻寬治標 VCO 治本。」**
> *(輸入低通、VCO高通；Peaking會放大雜訊很糟糕；改頻寬只能治低頻雜訊，高頻要改VCO本體)*
