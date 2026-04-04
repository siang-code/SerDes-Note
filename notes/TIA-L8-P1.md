# TIA-L8-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/TIA-L8-P1.jpg

---


---
## Feedback TIA (轉阻放大器) 頻率響應與二階系統分析

### 數學推導
這份筆記詳盡分析了使用理想放大器模型（具備有限增益 $A_0$、主極點 $\omega_0$ 與輸出阻抗 $R_{out}$）所建構的 Feedback TIA 的直流特性與高頻二階響應。

**1. 直流/低頻特性推導：**
*   **轉阻增益 ($R_T$)**：
    依據節點電流定律 (KCL)。假設光電流 $I_{in}$ 流入輸入節點。因為運算放大器輸入阻抗無限大，電流全數流經 $R_F$。
    在輸出節點進行 KCL，離開節點的電流總和等於進入的電流：
    $$I_{in} = g_m V_{in} + \frac{V_{out}}{R_{out}}$$
    （這裡筆記等式 $I_{in} = \frac{V_{in} - V_{out}}{R_F}$ 代表流入 $R_F$ 的電流，以此代換可解出增益）
    將 $V_{in} = V_{out} + I_{in} R_F$ 代入上式：
    $$I_{in} = g_m(V_{out} + I_{in} R_F) + \frac{V_{out}}{R_{out}}$$
    $$I_{in}(1 - g_m R_F) = V_{out}\left(g_m + \frac{1}{R_{out}}\right)$$
    $$R_T = \frac{V_{out}}{I_{in}} = \frac{R_{out}(1 - g_m R_F)}{1 + g_m R_{out}}$$
    當放大器增益極大 ($g_m R_{out} \gg 1$ 且 $g_m R_F \gg 1$) 時，$R_T \approx -R_F$。

*   **輸入阻抗 ($R_{in}$)**：
    於輸入端施加測試電流 $I_t$，產生電壓 $V_t$。此時 $I_t$ 穿過 $R_F$ 進入輸出節點。
    輸出節點 KCL：$I_t = g_m V_t + \frac{V_{out}}{R_{out}}$
    又因為 $V_{out} = V_t - I_t R_F$，代入上式：
    $$I_t = g_m V_t + \frac{V_t - I_t R_F}{R_{out}}$$
    整理後得到：
    $$R_{in} = \frac{V_t}{I_t} = \frac{R_F + R_{out}}{1 + g_m R_{out}} \approx \frac{1}{g_m} \quad \text{(@ low f, 假設 } R_F, R_{out} \text{ 比例關係)}$$

*   **輸出阻抗 ($R_{out}'$)**：
    輸入端開路 ($I_{in}=0$)，於輸出端施加測試電壓 $V_t$。
    因無電流流過 $R_F$，$V_{in} = V_{out} = V_t$。
    測試電流 $I_t$ 分流至 $R_{out}$ 與相依電流源：
    $$I_t = \frac{V_t}{R_{out}} + g_m V_{in} = V_t \left( \frac{1}{R_{out}} + g_m \right)$$
    $$R_{out}' = \frac{V_t}{I_t} = \frac{1}{1/R_{out} + g_m} \approx \frac{1}{g_m}$$

**2. 高頻二階響應推導：**
*   **輸入極點**：$\omega_i = \frac{1}{C_{in} R_F}$。筆記特別註明這單獨存在時「沒物理意義」，因為閉迴路會讓極點互相耦合。
*   **放大器轉移函數**：$A(s) = \frac{A_0}{1 + s/\omega_0}$，其中 $GBW = A_0 \cdot \omega_0$。
*   **閉迴路轉移函數 $R_T(s)$**：
    綜合 $C_{in}$ 效應與 $A(s)$，系統形成二階響應：
    $$R_T(s) = \frac{-R_F A_0 \omega_0 \omega_i}{s^2 + (\omega_0 + \omega_i)s + (A_0 + 1)\omega_0\omega_i} \equiv \frac{K_1}{s^2 + (\frac{\omega_n}{Q})s + \omega_n^2}$$
*   **重要參數萃取**：
    對比係數，我們能求出自然頻率 $\omega_n$ 與品質因子 $Q$：
    $$\omega_n^2 = (A_0 + 1)\omega_0\omega_i \approx A_0\omega_0\omega_i = GBW \cdot \omega_i \Rightarrow \omega_n = \sqrt{GBW \cdot \omega_i}$$
    $$\frac{\omega_n}{Q} = \omega_0 + \omega_i \Rightarrow Q = \frac{\omega_n}{\omega_0 + \omega_i} \approx \frac{\sqrt{GBW \cdot \omega_i}}{\omega_i} \quad \text{(@ } \omega_0 \ll \omega_i \text{)}$$
    $$Q \approx \sqrt{\frac{GBW}{\omega_i}}$$

*   **Peaking 分析**：
    當 $Q > 1/\sqrt{2}$ 時，二階系統會在頻域出現共振峰 (Peaking)。
    共振峰值為：$\text{Peak Value} = \frac{R_F Q}{\sqrt{1 - 1/(4Q^2)}}$
    共振頻率：$\omega_{max} = \omega_n \sqrt{1 - \frac{1}{2Q^2}}$

### 單位解析
**公式單位消去：**
*   **$GBW$**：$A_0 \cdot \omega_0 \rightarrow [V/V] \times [\text{rad}/s] = [\text{rad}/s]$ (或以 Hz 表示，除以 $2\pi$)
*   **$\omega_n$**：$\sqrt{GBW \cdot \omega_i} \rightarrow \sqrt{[\text{rad}/s] \times [\text{rad}/s]} = [\text{rad}/s]$
*   **$Q$**：$\sqrt{\frac{GBW}{\omega_i}} \rightarrow \sqrt{\frac{[\text{rad}/s]}{[\text{rad}/s]}} = [\text{無單位}]$ (Dimensionless，品質因子)

**圖表單位推斷：**
*   **圖 1：Op-amp Bode Plot (中段)**
    *   X 軸：頻率 (Frequency) [rad/s] 或 [Hz] (對數刻度)，典型範圍 $10^3 \sim 10^{10}$ rad/s。
    *   Y 軸：增益大小 $|A|$ [dB]，典型範圍 0 ~ 80 dB。
*   **圖 2：s-plane Pole Locations (右上)**
    *   X 軸：實部 $\sigma$ [rad/s]。
    *   Y 軸：虛部 $j\omega$ [rad/s]。
    *   標示：共軛複數極點，落在左半平面，顯示系統二階特性。
*   **圖 3：TIA 頻率響應與 Peaking (下段)**
    *   X 軸：頻率 $\omega$ [rad/s] (對數刻度)。
    *   Y 軸：轉阻增益大小 $|R_T|$ [dB$\Omega$] 或 [$\Omega$]，典型範圍 $1\text{k}\Omega \sim 100\text{k}\Omega$。
    *   標示：$\omega_{max}$ (peak frequency) 和 $\omega_n$ (natural frequency)。

### 白話物理意義
將放大器加上回授電阻做成 TIA 後，原本各自獨立的「輸入端 RC 極點」與「放大器內部極點」會互相耦合形成一個二階系統；當放大器頻寬 ($GBW$) 過大而輸入電容 ($C_{in}$) 很大時，反而會造成閉迴路增益產生劇烈的高頻突波 (Peaking)。

### 生活化比喻
想像你開著一台大馬力跑車 (Op-amp) 拖著一台裝滿貨物的笨重尾車 ($C_{in}$ 代表負載)。連接跑車與尾車的拖車桿是彈簧做的 ($R_F$)。如果你開得太快、方向盤打得太猛 (GBW 過高，系統反應太快)，尾車的巨大慣性會讓彈簧來回拉扯，導致整輛車失控般左右搖晃 (Peaking/Ringing)。要避免搖晃，你只能開慢一點 (降低 GBW) 或者換一個更粗的彈簧/減輕尾車重量 (提高 $\omega_i$)。

### 面試必考點
1. **問題：在設計 TIA 時，為什麼光電二極體寄生電容 ($C_{in}$) 會造成頻率響應的 Peaking？**
   * **答案：** $C_{in}$ 與回授電阻 $R_F$ 會產生一個極點 $\omega_i$。在閉迴路中，這個極點會與 Op-amp 內部的主極點 $\omega_0$ 耦合形成二階系統。由於品質因子 $Q \approx \sqrt{GBW/\omega_i}$，當 $C_{in}$ 很大導致 $\omega_i$ 變小時，$Q$ 值會變大（超過 $1/\sqrt{2}$），進而在頻域響應產生突波 (Peaking)，並在時域產生震盪 (Ringing)。
2. **問題：為了減少 TIA 的 Peaking，工程師通常會調整哪兩個參數？代價是什麼？**
   * **答案：** (1) 降低放大器的 GBW，代價是系統整體頻寬 $\omega_n$ 變小，影響資料傳輸率；(2) 提高 $\omega_i$（例如減小 $R_F$ 或使用更小面積的二極體以減小 $C_{in}$），代價是減小轉阻增益（若動 $R_F$）或 SNR 變差。這呼應了筆記中 "Bandwidth extends in a cost of Peaking" 的核心 trade-off。
3. **問題：在推導中，為何 TIA 的輸入阻抗 $R_{in}$ 在低頻時會大幅下降至近似 $1/g_m$？這對電路有何幫助？**
   * **答案：** 這是因為採用了 shunt-shunt 負回授架構。回授機制會將原本的阻抗 ($R_F$) 減小 $1+A$ 倍。極低的輸入阻抗不僅能將光電流更有效地吸入 TIA 中，還能將由 $C_{in}$ 造成的輸入端極點往高頻推，有助於擴展整體系統頻寬。

**記憶口訣：**
"大C生小ω，小ω養大Q，大Q必起秋 (Peaking)！" (大 $C_{in}$ 造成小 $\omega_i$，小 $\omega_i$ 養出大 $Q$，大 $Q$ 必然導致 Peaking！)
