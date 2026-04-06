# LA-L4-P1

> 分析日期：2026-04-06
> 原始圖片：images/done/LA-L4-P1.jpg

---


---
## 寬頻技術：電感性峰化與堆疊電感佈局 (Inductive Peaking & Stacked Inductor Layout)

### 數學推導
筆記中展示了含有 Shunt Peaking (並聯峰化) 電感的 Common-Source 放大器頻率響應。我們來推導這個經典的轉移函數 (Transfer Function)。

1. **定義負載阻抗 $Z_{load}$**：
   輸出節點的總負載是 $(R_D + sL_P)$ 與寄生電容 $C_L$ 的並聯：
   $$Z_{load} = (R_D + sL_P) \parallel \left(\frac{1}{sC_L}\right) = \frac{(R_D + sL_P) \cdot \frac{1}{sC_L}}{R_D + sL_P + \frac{1}{sC_L}} = \frac{R_D + sL_P}{s^2 L_P C_L + s R_D C_L + 1}$$

2. **整理成標準二階系統形式**：
   將分子與分母同除以 $L_P C_L$：
   $$Z_{load} = \frac{\frac{R_D}{L_P C_L} + \frac{s}{C_L}}{s^2 + s\frac{R_D}{L_P} + \frac{1}{L_P C_L}} = R_D \frac{\frac{1}{L_P C_L} + s\frac{1}{R_D C_L}}{s^2 + s\frac{R_D}{L_P} + \frac{1}{L_P C_L}}$$

3. **代入自然頻率 $\omega_n$ 與品質因數 $Q$**：
   定義 $\omega_n^2 = \frac{1}{L_P C_L}$，以及 $Q = \frac{1}{R_D}\sqrt{\frac{L_P}{C_L}}$。
   由上述定義可推導出替換項：
   - 分母的 $s$ 項係數：$\frac{\omega_n}{Q} = \frac{1}{\sqrt{L_P C_L}} \cdot R_D\sqrt{\frac{C_L}{L_P}} = \frac{R_D}{L_P}$
   - 分子的 $s$ 項係數：$Q\omega_n = \frac{1}{R_D}\sqrt{\frac{L_P}{C_L}} \cdot \frac{1}{\sqrt{L_P C_L}} = \frac{1}{R_D C_L}$

4. **最終轉移函數**：
   放大器的增益 $A_v = \frac{V_{out}}{V_{in}} = -g_m \cdot Z_{load}$。代入替換項後完美得到筆記中的公式：
   $$\frac{V_{out}}{V_{in}} = -g_m R_D \cdot \frac{Q\omega_n \cdot s + \omega_n^2}{s^2 + \left(\frac{\omega_n}{Q}\right)s + \omega_n^2}$$
   *(註：筆記左上角寫著「快要產生 peaking 的 feel」，指的就是將 Q 值設計在接近產生頻率響應突起的臨界點，以獲得最大平坦頻寬。)*

### 單位解析
**公式單位消去：**
1. **自然頻率 $\omega_n$**：$\omega_n = \frac{1}{\sqrt{L_P C_L}}$
   - $L_P$ [H] = [V·s/A]
   - $C_L$ [F] = [A·s/V]
   - $\sqrt{L_P \cdot C_L} = \sqrt{[\frac{V \cdot s}{A}] \cdot [\frac{A \cdot s}{V}]} = \sqrt{[s^2]} = [s]$
   - 故 $\omega_n$ 單位為 $[s^{-1}]$ 或 [rad/s]（角頻率）。

2. **品質因數 $Q$**：$Q = \frac{1}{R_D}\sqrt{\frac{L_P}{C_L}}$
   - $R_D$ [Ω] = [V/A]
   - $\frac{L_P}{C_L} = \frac{[V \cdot s / A]}{[A \cdot s / V]} = [\frac{V^2}{A^2}] = [\Omega^2]$
   - $\sqrt{\frac{L_P}{C_L}} = [\Omega]$
   - $Q = [\frac{1}{\Omega}] \times [\Omega] = 1$ (無單位，Dimensionless)。

**圖表單位推斷：**
📈 右上角 Bode Plot 單位推斷：
- **X 軸**：角頻率 $\omega$ [rad/s] 或 頻率 $f$ [GHz]，在 SerDes LA 設計中，典型範圍約為 $1 \text{ GHz} \sim 50 \text{ GHz}$。
- **Y 軸**：電壓增益幅度 $|V_{out}/V_{in}|$ [V/V] 或 [dB]，對於單級 LA，典型範圍約為 $0 \text{ dB} \sim 15 \text{ dB}$。

### 白話物理意義
**Inductive Peaking** 就是在原本會讓高頻訊號衰減的 RC 負載中串聯一顆電感，利用電感「高頻阻抗變大」的特性，硬生生把掉下去的高頻增益給拉回來；而 **Stacked Inductor** 則是利用不同金屬層電流同向產生的「互感」效應，在極小的晶片面積內「榨」出好幾倍的電感量。

### 生活化比喻
- **Inductive Peaking (電感峰化)**：就像你開車過彎（高頻訊號）時速度原本會掉下來（增益衰減），這時候你開啟「Turbo 渦輪增壓（電感）」，在彎道補償動力，讓車子能以原速過彎（頻寬擴展）。但 Turbo 開太強會「甩尾失控（Peaking/Ringing）」，所以要控制在 `Q=0.7` 保持最佳抓地力。
- **Stacked Inductor (堆疊電感)**：就像是在寸土寸金的信義區蓋「立體機械停車塔」。平面（單層金屬）能停的車（電感量）有限，所以你往下挖 B1、B2（M9, M6, M3 三層疊加）。而且因為車子進出的方向都一樣產生了神奇的空間折疊（互感效應），原本 3 層樓只能停 3 倍的車，現在居然可以停到 7 到 9 倍的車！但代價是樓層間的天花板很低，限制了休旅車進出（層間寄生電容增加，導致自共振頻率 SRF 下降）。

### 面試必考點
1. **問題：Shunt Peaking 理論上能增加多少頻寬？實際上呢？為什麼？**
   → **答案**：理論上，設計在 Maximally Flat (Q ≈ 0.64 ~ 0.7) 時，頻寬可增加約 70% ~ 80% ($\sim 1.7 \times f_{-3dB}$)。但如筆記所寫，實際下線 (actual case) 通常只能增加 40% 左右，因為電感本身會帶來額外的寄生電容與串聯電阻，且 Layout 走線也會引入寄生效應。
2. **問題：請解釋 Bode Plot 中 Q 值過大與過小的影響？**
   → **答案**：Q 值過小 (Overdamped) 會導致頻寬擴展不夠，依然平緩下降；Q 約為 0.7 時響應最平坦且頻寬最大（較佳）；Q 值過大會產生明顯的 Peaking（不佳），這在頻域的突起會導致時域眼圖 (Eye Diagram) 出現嚴重的 Ringing（震盪）與 ISI；若 Q 大到極點，系統極點會跑到右半平面，變成振盪器 (OSC)。
3. **問題：Layout 使用 Stacked Inductor (例如 M9+M6+M3) 的優缺點是什麼？**
   → **答案**：**優點**是極度節省 Area。利用同向電流產生的正互感 (Mutual Inductance)，2 層理論上可達 4 倍電感 (實際約 3.5 倍)，3 層理論可達 9 倍 (實際約 7 倍)。**缺點**是金屬層重疊會產生巨大的平行板寄生電容 ($C_{ox}$)，這會大幅降低電感的自共振頻率 (SRF)，在高頻 SerDes 中必須小心確認 SRF 是否高於操作頻寬。

**記憶口訣：**
> 「電感補高頻，Q零點七最平；立體停車場，面積省寄生長。」

---
### 😈 TA 的靈魂拷問 (費曼測試)
*(如果你覺得你懂了，請嘗試回答以下問題)*
- **反事實**：如果我把筆記右下角 Layout 中的 Inductor 走線，從「同向旋轉」接成「反向旋轉」，總電感量會發生什麼事？對頻寬有何影響？
- **情境遷移**：這個 Inductive Peaking 技巧，除了用在 Linear Amplifier (LA)，在 112Gbps PAM4 的 CTLE (Continuous Time Linear Equalizer) 中可以用嗎？用途有何不同？
