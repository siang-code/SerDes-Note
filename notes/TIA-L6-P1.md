# TIA-L6-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/TIA-L6-P1.jpg

---


---
## [為什麼需要 TIA (Transimpedance Amplifier)？]

### 數學推導
本頁筆記的核心在於推導 Shunt-Shunt Feedback TIA 的閉迴路轉阻增益 (Closed-loop Transimpedance Gain, $R_T$)。
已知小訊號模型：輸入端電流源 $I_{in}$、核心放大器轉導 $G_m$、輸出阻抗 $R_{out}$、回授電阻 $R_F$。假設核心放大器具有無限大的輸入阻抗。

1. **節點電流定律 (KCL) @ 輸入端：**
   因為放大器輸入端不吃電流，所有光電流 $I_{in}$ 都必須流過回授電阻 $R_F$ 往輸出端走。
   $$I_{in} = \frac{V_{in} - V_{out}}{R_F}$$
   由此式可得輸入電壓與輸出電壓的關係：
   $$V_{in} = V_{out} + I_{in}R_F$$

2. **節點電流定律 (KCL) @ 輸出端：**
   從 $R_F$ 流過來的電流 ($I_{in}$) 在輸出節點分支，一部分流向轉導相依電流源 ($G_mV_{in}$)，一部分流向輸出電阻 ($R_{out}$)。筆記中直接把這兩條 KCL 寫在一起：
   $$I_{in} = G_mV_{in} + \frac{V_{out}}{R_{out}}$$

3. **代入化簡：**
   將步驟 1 得到的 $V_{in}$ 關係式代入步驟 2：
   $$I_{in} = G_m(V_{out} + I_{in}R_F) + \frac{V_{out}}{R_{out}}$$
   展開整理：
   $$I_{in} = G_mV_{out} + G_mR_FI_{in} + \frac{V_{out}}{R_{out}}$$
   將含有 $I_{in}$ 的項移到等號左邊，含有 $V_{out}$ 的項留在右邊：
   $$I_{in} - G_mR_FI_{in} = G_mV_{out} + \frac{V_{out}}{R_{out}}$$
   提出公因式：
   $$I_{in}(1 - G_mR_F) = V_{out}(G_m + \frac{1}{R_{out}})$$
   $$I_{in}(1 - G_mR_F) = V_{out}(\frac{G_mR_{out} + 1}{R_{out}})$$

4. **求得轉阻增益 $R_T$：**
   $$R_T = \frac{V_{out}}{I_{in}} = \frac{R_{out}(1 - G_mR_F)}{1 + G_mR_{out}}$$

5. **極限近似 (理想狀態)：**
   當核心放大器為理想或增益極大時，開迴路電壓增益 $A_v = G_mR_{out} \gg 1$，且 $G_mR_F \gg 1$。
   $$R_T \approx \frac{R_{out}(-G_mR_F)}{G_mR_{out}} = -R_F$$
   結論：在理想情況下，TIA 的轉阻增益完全由回授電阻 $R_F$ 決定。

### 單位解析
**公式單位消去：**
針對推導出的轉阻公式進行單位檢驗：$R_T = \frac{R_{out}(1 - G_mR_F)}{1 + G_mR_{out}}$
*   $G_m \times R_F \Rightarrow [\text{A/V}] \times [\Omega] = [\text{A/V}] \times [\text{V/A}] = 1$ (無單位)
*   $G_m \times R_{out} \Rightarrow [\text{A/V}] \times [\Omega] = 1$ (無單位)
*   分子單位為 $R_{out}$ 的單位 $[\Omega]$ 乘上無單位常數 $\Rightarrow [\Omega]$
*   分母單位為無單位常數
*   最終 $R_T$ 單位為 $[\Omega]$。這與 $R_T = V_{out} / I_{in} \Rightarrow [\text{V}] / [\text{A}] = [\Omega]$ 完全吻合，推導正確。

**圖表單位推斷：**
*本頁為純電路架構與小訊號模型圖，無特定波形或 XY 軸圖表。*
*(助教補充典型數值)*：
*   $I_{in}$ (光電流): $10\mu\text{A} \sim 1\text{mA}$
*   $R_F$ (回授電阻): $50\Omega \sim 5\text{k}\Omega$ (高速 SerDes 為了頻寬通常偏小)
*   $V_{out}$ (輸出擺幅): $100\text{mV}_{pp} \sim 500\text{mV}_{pp}$

### 白話物理意義
TIA 就是個「電流轉電壓的阻抗變壓器」，透過 Shunt-Shunt 負回授，主動把高阻抗微弱光電流，穩穩轉換成低阻抗電壓訊號，同時打破純電阻轉換時「增益與頻寬互斥」的死胡同。

### 生活化比喻
把光偵測器 (Photodiode) 想像成一個水壓極高但水流極小的「滴漏」。如果直接接一根細長水管（純電阻轉換），水流會被嚴重堵塞（RC Delay 大，頻寬極小）。
TIA 就像是裝了一個「帶有抽水馬達（核心放大器）與洩壓回流管（$R_F$）」的智慧水盆。它主動把接水口的水壓降到最低（Low input resistance，讓水滴順利全流進來），然後透過馬達的壓力轉換，從另一端用大口徑水管（Low output resistance）穩定輸出強勁的水流（電壓訊號）。

### 面試必考點
1. **問題：為什麼光通訊接收端第一級必須是 TIA，不能只用一顆電阻 $R$ 把電流轉電壓就好？**
   * 答案：若用純電阻 $R$，為了得到夠大的電壓增益，$R$ 必須很大。但輸入端有極大的 Photodiode 寄生電容 $C_{pd}$，這會導致輸入級極點 $\omega_p = \frac{1}{R \cdot C_{pd}}$ 變得很低，嚴重限制頻寬。TIA 透過負回授將輸入阻抗降低為 $R_{in} \approx \frac{R_F}{1+A}$，在維持高增益 ($R_F$) 的同時，將頻寬推展了 $(1+A)$ 倍。
2. **問題：筆記中提到 TIA 的重要性第 2 點是 Gain Control (AGC)，為什麼 TIA 需要可變增益？**
   * 答案：光纖傳輸距離或雷射功率不同，會造成接收端的光強度差異極大 (Dynamic Range 很大)。正如筆記所說「光強開弱 gain，光弱開強 gain」。如果沒有 AGC，當大訊號進來時，TIA 內部電晶體會進入 Triode region (線性區) 導致 Saturation，這會造成嚴重的 Pulse Width Distortion (PWD)，使後級 CDR 無法正確 Lock 資料。
3. **問題：在 Shunt-Shunt TIA 的推導中，$R_T \approx -R_F$ 的前提條件是什麼？在先進製程 (如 5nm) 的 112Gbps 設計中，這個條件還容易成立嗎？**
   * 答案：前提是核心放大器的開迴路增益要夠大 ($G_mR_{out} \gg 1$) 且跨導夠大 ($G_mR_F \gg 1$)。在 112Gbps 等極高速設計中，為了把寄生電容的影響降到最低以榨出頻寬，核心放大器通常只能使用極少級數（甚至單級）且 loading resistor 很小，導致開迴路增益 $A$ 往往只有 2~5 倍左右。當 $A$ 不夠大時，$R_T$ 會明顯小於 $R_F$，且輸入阻抗 $\frac{R_F}{1+A}$ 無法降到理想般低，這是高速 TIA 設計最頭痛的 trade-off。

**記憶口訣：**
TIA 五大黃金任務：「**低入、低出、大寬、小雜、控增益**」
(低輸入阻抗搶電流、低輸出阻抗推後級、大頻寬過高速訊號、小雜訊保 SNR、AGC 動態增益防飽和)
