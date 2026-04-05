# CDR-L8-P2

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L8-P2.jpg

---


---
## [Bang-Bang Phase Detector 與 CDR 系統模型]

### 數學推導
（逐步推導，每步說明）

1. **相位誤差定義**：
   由圖下方的 `BB PD/CDR Model` 方塊圖可知，輸入資料相位 $\Phi_{in}$ 與 VCO 輸出的時脈相位 $\Phi_{out}$ 的差值定義為相位誤差：
   $$\Delta \Phi = \Phi_{out} - \Phi_{in}$$ 
   （或 $\Phi_{in} - \Phi_{out}$，取決於定義，此處依轉移曲線判定正負關係）

2. **Bang-Bang PD (Alexander PD) 轉移函數**：
   觀察左下角的 BBPD 轉移曲線，這是一個非線性的步階函數（Signum Function）。
   當 $\Delta \Phi > 0$（Clock Late，時脈太晚）時，Charge Pump 需要抽載電流以降低頻率，故平均輸出電流 $I_{av} = -I_p$。
   當 $\Delta \Phi < 0$（Clock Early，時脈太早）時，Charge Pump 需要充載電流以提升頻率，故 $I_{av} = I_p$。
   可寫成數學式：
   $$I_{av} = -I_p \cdot \text{sgn}(\Delta \Phi)$$

3. **Loop Filter (迴路濾波器) 轉換**：
   圖中 Charge Pump 之後接了 $R_p$ 與 $C_p$ 串聯的濾波器，電流流經濾波器轉為控制電壓 $V_{ctrl}$：
   $$V_{ctrl}(s) = I_{av}(s) \cdot \left( R_p + \frac{1}{s \cdot C_p} \right)$$
   （這裡展示了 Proportional path 比例路徑 $R_p$ 與 Integral path 積分路徑 $C_p$ 的阻抗轉換）

4. **VCO 頻率與相位關係**：
   觀察右下角的 VCO 轉移曲線，振盪頻率與控制電壓呈線性關係，斜率為 $K_{vco}$：
   $$\omega_{vco}(t) = \omega_0 + K_{vco} \cdot V_{ctrl}(t)$$
   因為相位是頻率的積分，在 s 域可寫為：
   $$\Phi_{out}(s) = \frac{\omega_{vco}(s)}{s} = \frac{K_{vco} \cdot V_{ctrl}(s)}{s}$$

5. **系統線性化 (等效增益)**：
   因為 BBPD 是無限大斜率的非線性系統，為了做 Bode Plot 分析，通常會匯入輸入 Jitter 的統計特性（常態分佈，標準差為 $\sigma_{\Delta \Phi}$）來推導等效增益 $K_{pd,eq}$：
   $$K_{pd,eq} \approx \frac{2 I_p}{\sqrt{2\pi} \sigma_{\Delta \Phi}}$$
   （這表示輸入訊號越乾淨、Jitter 越小，等效 Loop Gain 反而越大，系統越容易不穩定震盪）

### 單位解析
**公式單位消去：**
- $I_{av} = -I_p \cdot \text{sgn}(\Delta \Phi)$
  $[\text{A}] = [\text{A}] \times [1]$ 
- $V_{ctrl}(s) = I_{av}(s) \cdot Z_{filter}$
  $[\text{V}] = [\text{A}] \times [\Omega]$
- $\omega_{vco} = \omega_0 + K_{vco} \cdot V_{ctrl}$
  $[\text{rad/s}] \text{或} [\text{Hz}] = [\text{Hz}] + \left[\frac{\text{Hz}}{\text{V}}\right] \times [\text{V}]$
- $\Phi_{out}(s) = \frac{\omega_{vco}(s)}{s}$
  $[\text{rad}] \text{或} [\text{UI}] = \frac{[\text{rad/s}]}{[\text{s}^{-1}]}$

**圖表單位推斷：**
1. 📈 **時序圖 (Ck late / Ck Early 波形)**
   - X 軸：時間 $t$ [ps] 或 [UI]，典型範圍 0 ~ 10 UI。
   - Y 軸：電壓 [V]，典型範圍為 CMOS 邏輯準位 0V ~ 1V。
2. 📈 **BBPD 轉移曲線 (左下角紅黑十字圖)**
   - X 軸：相位誤差 $\Delta \Phi$ [UI] 或 [rad]，典型範圍 -0.5 UI ~ +0.5 UI。
   - Y 軸：平均電流 $I_{av}$ [μA]，典型範圍 $\pm I_p$ (如 $\pm 50 \mu\text{A}$)。
3. 📈 **VCO 轉移曲線 (右下角斜線圖)**
   - X 軸：控制電壓 $V_{ctrl}$ [V]，典型範圍 0.2V ~ 1.0V。
   - Y 軸：振盪頻率 $\omega_{vco}$ [GHz] 或 [rad/s]，典型範圍如 10 GHz ~ 14 GHz。

### 白話物理意義
Bang-Bang Phase Detector 就像一個極端的控制狂，它不管時脈跟資料到底差了幾皮秒，只要發現時脈「稍微早一點點」就全踩油門加速，發現「稍微晚一點點」就猛踩煞車減速。

### 生活化比喻
想像你開車跟著前車（Data），但你的車子沒有線性油門，只有「地板油（$+I_p$）」和「煞車踩死（$-I_p$）」兩個按鈕。只要你落後前車一公分，你就按地板油；一超車，你就煞車踩死。結果就是你的車會一直在前車旁邊前後瘋狂抽搐（這就是 Bang-Bang CDR 系統中無可避免的 Limit Cycle / Dithering Jitter）。

### 面試必考點
1. **問題：Alexander PD 是如何判斷 Clock 是 Early 還是 Late 的？**
   - **答案：** 對連續三個 Clock Edge 提取三個連續的 Data 取樣點 (S1, S2, S3)。如果資料有轉態（S1 $\neq$ S3），則檢查中間點 S2：若 S1 = S2 且 S2 $\neq$ S3，代表 Clock 取樣太早 (Early)；若 S1 $\neq$ S2 且 S2 = S3，代表 Clock 取樣太晚 (Late)。
2. **問題：為什麼在高速 28Gbps+ SerDes 中，通常選擇 Bang-Bang PD 而不選 Linear PD (如 Hogge PD)？**
   - **答案：** 高頻下 Linear PD 需要產生極短且精確的脈衝寬度來代表相差，極易受寄生電容影響而失真，且容易產生 Static Phase Offset。而 BBPD 只需要純數位邏輯的 D-Flip Flop (取樣) 和 XOR 閘，在高頻下極容易用 CML 或 CMOS 實現。
3. **問題：Bang-Bang CDR 的致命缺點是什麼？在電路上如何減輕這個副作用？**
   - **答案：** 最大缺點是會產生「極限環 (Limit Cycle)」，導致過大的 Deterministic Jitter (DJ)。減輕的方法包含：減小 Charge Pump 電流 $I_p$、減小迴路濾波器的電阻 $R_p$（降低 Proportional path 的強度），或是增加系統內部的 Latency 以平滑控制。

**記憶口訣：**
「亞歷山大取三點，一二同為早，二三同為晚；Bang-Bang 只有死油門和死煞車，高頻好做但會抖。」
