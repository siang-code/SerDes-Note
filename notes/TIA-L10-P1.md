# TIA-L10-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/TIA-L10-P1.jpg

---


---
## Direct Feedback TIA (Inverter-based TIA)

### 數學推導
這頁筆記主要分析 Direct Feedback TIA (以單級 NMOS 共源極放大器加上 $R_F$ 負回授構成) 的 DC 工作點、輸入/輸出阻抗，以及**輸出雜訊電壓頻譜密度**。

**1. DC Analysis (直流分析)**
*   **筆記關鍵句**：「DC 過來時沒有電流流過 $R_F$, $V_g = V_{out} \Rightarrow$ 保持 Saturation」
*   **推導說明**：光二極體 (Photodiode) 在未受光照（或僅考慮偏壓）時，可視為開路或極小電流源。因為閘極 (Gate) 絕緣，沒有 DC 電流流經回授電阻 $R_F$。
*   根據歐姆定律：$V_{out} - V_g = I_{RF} \times R_F = 0 \times R_F = 0 \Rightarrow V_{out} = V_g$。
*   對於 NMOS 而言，當 $V_{ds} = V_{gs}$ 時，$V_{ds} > V_{gs} - V_{th}$ 恆成立，因此電路天然確保電晶體 $M_1$ 工作在**飽和區 (Saturation Region)**，這也是筆記註明 "Good for low supply (~1V)" 的原因，因為不需要額外疊代電晶體浪費 Headroom。

**2. 轉阻增益與阻抗 (Transimpedance & Impedance)**
*   **$R_T$ (轉阻增益)**：$R_T = \frac{V_{out}}{I_{in}} = -R_D \cdot \frac{g_{m1}R_F - 1}{1 + g_{m1}R_D}$
    *   *助教推導*：若在輸入端灌入小訊號電流 $i_{in}$，假設節點電壓為 $v_g$ 與 $v_{out}$。
        *   KCL @ Gate: $i_{in} + \frac{v_{out} - v_g}{R_F} = 0 \Rightarrow v_g = v_{out} + i_{in}R_F$
        *   KCL @ Drain: $g_{m1}v_g + \frac{v_{out}}{R_D} + \frac{v_{out} - v_g}{R_F} = 0$
        *   將 $v_g$ 代入 Drain KCL 並整理，即可得到筆記上的精確解。
    *   **近似**：如果 $g_{m1}R_F \gg 1$ 且 $g_{m1}R_D \gg 1$（Loop gain 夠大），則 $R_T \approx -R_D \frac{g_{m1}R_F}{g_{m1}R_D} = -R_F$。回授電阻直接決定了理想的轉阻增益。
*   **$R_{in}$ (輸入阻抗)**：$R_{in} = \frac{R_F + R_D}{1 + g_{m1}R_D}$
*   **$R_{out}$ (輸出阻抗)**：$R_{out} \approx R_D // \frac{1}{g_{m1}} = \frac{R_D}{1 + g_{m1}R_D}$

**3. Noise Analysis (雜訊分析)**
這段是筆記的精華，使用小訊號模型推導輸出電壓雜訊 $\overline{V_{n,out}^2}$。
*   **定義雜訊電流源**：$R_D$ 產生 $I_{n,RD}$、$M_1$ 產生 $I_{n,M1}$、$R_F$ 產生 $I_{n,RF}$。
*   **KCL @ Drain Node**:
    $I_{n,RD} + \frac{0 - V_{n,out}}{R_D} = V_x \cdot g_{m1} + I_{n,M1}$
    *(助教嚴格點評：這裡筆記做了一個常見的工程近似，省略了流過 $R_F$ 的小訊號電流 $(V_{n,out}-V_x)/R_F$。這是在假設 $R_F$ 阻值極大，且 $g_{m1} \gg 1/R_F$ 的前提下所做的合理簡化。)*
*   **KVL 尋找 $V_x$ (Gate 電壓)**:
    $V_x = I_{n,RF} \cdot R_F + V_{n,out}$ (這裡定義 $I_{n,RF}$ 方向由 Output 流向 Input)
*   **代入求解**：
    將 $V_x$ 代入 KCL 方程式中：
    $I_{n,RD} - \frac{V_{n,out}}{R_D} = g_{m1}(I_{n,RF} \cdot R_F + V_{n,out}) + I_{n,M1}$
    移項整理出 $V_{n,out}$：
    $I_{n,RD} - I_{n,M1} - g_{m1} R_F I_{n,RF} = V_{n,out} (g_{m1} + \frac{1}{R_D})$
*   **取均方值 (Mean Square) 且假設雜訊不相關**：
    $\overline{V_{n,out}^2} = \frac{\overline{I_{n,RD}^2} + \overline{I_{n,M1}^2} + g_{m1}^2 R_F^2 \overline{I_{n,RF}^2}}{(g_{m1} + 1/R_D)^2}$
*   **工程近似**：假設 $g_{m1} \gg 1/R_D$，分母簡化為 $g_{m1}^2$：
    $\overline{V_{n,out}^2} \approx \frac{\overline{I_{n,RD}^2}}{g_{m1}^2} + \frac{\overline{I_{n,M1}^2}}{g_{m1}^2} + R_F^2 \overline{I_{n,RF}^2}$
    *(完美切分出三個元件對輸出雜訊的貢獻)*

### 單位解析
**公式單位消去：**
*   **轉阻增益 $R_T$**:
    $R_T = \frac{V_{out}}{I_{in}}$
    單位：$[V] / [A] = [\Omega]$ (轉阻放大器的本質就是將電流轉為電壓，單位必為歐姆)。
*   **輸出雜訊 PSD 中 $R_F$ 的貢獻項**：$R_F^2 \cdot \overline{I_{n,RF}^2}$
    已知電流 PSD $\overline{I_n^2}$ 單位為 $[A^2/Hz]$。
    單位：$[\Omega^2] \times [A^2/Hz] = [V^2/A^2] \times [A^2/Hz] = [V^2/Hz]$ (成功轉換為電壓雜訊 PSD)。
*   **輸出雜訊 PSD 中 $M_1$ 的貢獻項**：$\frac{\overline{I_{n,M1}^2}}{g_{m1}^2}$
    單位：$[A^2/Hz] / [A/V]^2 = [A^2/Hz] / ( [A^2]/[V^2] ) = [V^2/Hz]$。

**圖表單位推斷：**
📈 **輸出雜訊功率頻譜密度 (PSD) 頻率響應圖**
*   **X 軸**：角頻率 $\omega$ $[rad/s]$（對數尺度 Log Scale），典型範圍 $10^6 \sim 10^{11} \ rad/s$。
*   **Y 軸**：輸出電壓雜訊功率頻譜密度 $\overline{V_{n,out}^2}$ $[V^2/Hz]$，典型範圍在 $10^{-18} \sim 10^{-15} \ V^2/Hz$ 之間。
*   **圖表細節解析**：
    筆記圖中比較了三個平坦區段（低中頻）的雜訊強度，並在右下方列出不等式：$\frac{1}{R_D} \ll g_{m1}\gamma < g_{m1}^2 R_F$。
    這是因為將三項雜訊源除以共通常數 $\frac{4kT}{g_{m1}^2}$ 後，得到的比例關係。這告訴我們，**在中低頻段，回授電阻 $R_F$ 貢獻的雜訊 $R_F^2 \overline{I_{n,RF}^2}$ 絕對是佔據主導地位的 (Dominant)**，而 $R_D$ 的影響最小。圖中的高頻 Peak 和 -20dB/dec 滾降 (Roll-off) 則是受到電路極點 (Poles) 影響的結果（筆記標示為 H.W.）。

### 白話物理意義
Direct FB TIA 就像是給放大器裝上了一條名為 $R_F$ 的「強制穩定牽繩」，它不僅能自我調節偏壓讓電晶體乖乖待在飽和區（適合低電壓工作），還能把極點推向高頻換取極寬的頻寬，代價是這條牽繩本身就是最大的雜訊來源。

### 生活化比喻
想像一個有自動平衡系統的蹺蹺板。輸入端（光電流）想把蹺蹺板往下壓，輸出端透過一根強韌的彈簧（$R_F$）感知到變化，立刻反向拉扯，讓輸入端「看起來」幾乎沒動（虛擬地 / 降低輸入阻抗）。而這根彈簧被拉伸的長度，就精準代表了輸入力道的大小（輸出電壓）。因為結構簡單沒什麼多餘零件，所以反應速度超快（Wideband），在電力不足（Low Supply）的環境下也能運作自如。

### 面試必考點
1.  **問題：為什麼 Direct Feedback TIA 特別適合先進製程的 Low Supply Voltage (如 1V 或更低) 設計？**
    *   **答案**：因為它具備「自我偏壓 (Self-biased)」特性。在 DC 時，由於光二極體端沒有直流電流流過 $R_F$，導致 $V_g = V_d$。對於 NMOS 來說，$V_{ds} = V_{gs}$ 永遠大於 $V_{gs} - V_{th}$，這保證了電晶體必定操作在飽和區 (Saturation region)，不需要像 Cascode 架構那樣犧牲額外的 Voltage Headroom。
2.  **問題：請觀察你的雜訊推導公式，要如何降低 TIA 的「輸入參考雜訊電流 (Input-referred noise current)」？有什麼 Trade-off？**
    *   **答案**：由推導可知，主要的輸出雜訊來自 $R_F$ ($4kTR_F$)。若將其除以轉阻增益的平方 ($R_T^2 \approx R_F^2$) 換算回輸入端，輸入參考雜訊電流密度約為 $\frac{4kT}{R_F}$。因此，**必須盡可能增大 $R_F$ 來降低雜訊**。
    *   **Trade-off**：增大 $R_F$ 雖然能降噪並提高增益，但會導致主極點 $\omega_{p1} \approx \frac{1+g_m R_D}{R_F C_{in}}$ 往低頻移動，嚴重犧牲頻寬 (Bandwidth)。這就是經典的 Transimpedance Limit。
3.  **問題：筆記中提到 "No additional parasitic cap => Wideband"，請解釋這個架構為何頻寬較大？**
    *   **答案**：相比於 Common-Gate TIA 或 Regulated Cascode TIA，Direct FB 只有一級 Common-Source 加上電阻回授，內部節點極少。沒有額外的主動元件（如 Source Follower）引入額外的寄生電容 (Parasitic capacitance)。極點數量少且位置相對較高頻，因此能達到 Wideband 的特性。

**記憶口訣：**
「**直回 TIA 三大好：自偏壓、低電壓、頻寬高；唯獨 $R_F$ 雜訊吵，變大降噪頻寬少！**」
