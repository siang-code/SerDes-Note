# TIA-L5-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/TIA-L5-P1.jpg

---


---
## 光接收前端：Photodiode (PD) 雜訊計算與為何需要 TIA

### 數學推導
這份筆記的核心在於：**從系統規格 (BER, Data Rate, Sensitivity) 逆推 TIA 的雜訊預算 (Noise Budget)。** 身為一個稱職的 IC Designer，你不能只會設計電路，你要知道你的 Spec 是怎麼來的。

**步驟一：計算光電流與訊號擺幅 ($I_{pp}$)**
已知條件：平均光功率 $\overline{P} = -12\text{dBm}$，消光比 $ER = 6\text{dB}$，PD 響應度 $R = 0.9\text{ A/W}$。
1. 將 $\text{dBm}$ 轉為線性功率：$\overline{P} = 10^{(-12/10)}\text{ mW} \approx 63\mu\text{W}$。
2. 平均功率由 $P_1$ (光為1) 與 $P_0$ (光為0) 決定：$\overline{P} = \frac{P_1 + P_0}{2} = 63\mu\text{W}$。
3. 由消光比 $ER = 6\text{dB}$ 可知：$10 \log_{10}(\frac{P_1}{P_0}) = 6 \Rightarrow \frac{P_1}{P_0} \approx 10^{0.6} \approx 3.98 \approx 4$。
4. 聯立方程式：$P_1 = 4P_0$ 且 $P_1 + P_0 = 126\mu\text{W}$ $\Rightarrow P_1 = 100.8\mu\text{W}$, $P_0 = 25.2\mu\text{W}$。
5. 轉換為光電流 (透過響應度 $R$)：
   - $I_1 = P_1 \times R = 100.8\mu\text{W} \times 0.9\text{ A/W} \approx 90.7\mu\text{A}$
   - $I_0 = P_0 \times R = 25.2\mu\text{W} \times 0.9\text{ A/W} \approx 22.7\mu\text{A}$
   - 訊號峰對峰電流 $I_{pp} = I_1 - I_0 = 68\mu\text{A}$。

**步驟二：由系統 BER 決定總雜訊容忍度**
1. 為了達到 $BER = 10^{-12}$，訊號雜訊比 (以 Q factor 表示) 需要達到 $Q \approx 7$ (單端考量) 或 peak-to-peak SNR 概念下 $\frac{I_{pp}}{I_{n,rms}} = 14$。
2. 總系統允許的最大均方根雜訊電流：$I_{n,rms} = \frac{I_{pp}}{14} = \frac{68\mu\text{A}}{14} \approx 4.8\mu\text{A,rms}$。這代表整個接收端 (PD + TIA + 後級) 不能超過這個雜訊量。

**步驟三：計算 PD 本身的散粒雜訊 (Shot Noise)**
光電流是量子化的光子打出來的，具有泊松分佈特性，會產生 Shot Noise。
1. 雜訊功率頻譜密度 (PSD)：$\overline{I_n^2}/\Delta f = 2qI$。
2. 總雜訊功率需要對頻寬積分。在此以最差情況 ($I_1$) 評估 PD 貢獻的雜訊：
   - $\overline{I_{n,PD1}^2} = \int_{0}^{BW} 2qI_1 \,df = 2 \cdot (1.6 \times 10^{-19}) \cdot (90.7\mu\text{A}) \cdot (10\text{GHz}) = 2.9 \times 10^{-13}\text{ A}^2$
3. 均方根值：$I_{n,PD1,rms} = \sqrt{2.9 \times 10^{-13}} \approx 0.54\mu\text{A,rms}$。
   *(註：若算 $I_0$ 的雜訊則是 $0.27\mu\text{A,rms}$)*

**步驟四：結算 TIA 的雜訊預算 (Noise Budget)**
因為 PD 雜訊與 TIA 雜訊是不相關 (uncorrelated) 的獨立事件，它們的雜訊是在**功率上相加 (平方和)**。
1. $(總雜訊 I_{n,rms})^2 = (PD 雜訊 I_{n,PD1})^2 + (TIA 雜訊 I_{n,TIA})^2$
2. $(4.8\mu\text{A})^2 = (0.54\mu\text{A})^2 + I_{n,TIA}^2 \Rightarrow I_{n,TIA} = \sqrt{23.04 - 0.29} \approx 4.76\mu\text{A,rms}$。
3. **結論：** TIA 佔據了整個系統近 90% 的雜訊預算。所以 TIA 的低雜訊設計是光接收機的成敗關鍵。

### 單位解析
**公式單位消去：**
1. **Shot Noise (散粒雜訊) 變異數：**
   $\overline{I_{n}^2} = 2 \cdot q \cdot I \cdot BW$
   - $q$ (基本電荷)：Coulombs $[\text{C}]$ 也就是 $[\text{A}\cdot\text{s}]$
   - $I$ (直流電流)：Amperes $[\text{A}]$
   - $BW$ (頻寬)：Hertz $[\text{Hz}]$ 也就是 $[1/\text{s}]$
   - 單位消去：$[\text{A}\cdot\text{s}] \times [\text{A}] \times [1/\text{s}] = [\text{A}^2]$。開根號後即為 $[\text{A,rms}]$。

2. **Responsivity (響應度)：**
   $I = P \times R$
   - $P$ (光功率)：Watts $[\text{W}]$
   - $R$ (響應度)：$[\text{A/W}]$
   - 單位消去：$[\text{W}] \times [\text{A/W}] = [\text{A}]$。

**圖表單位推斷：**
📈 *本頁無典型 Y-X 波形圖。但有一張等效電路圖 (PD model + TIA input)。*
- **電流源 $I_{in}$**：物理量為微觀光電流，典型範圍數十至數百 $\mu\text{A}$。
- **寄生電容 $C_{\text{寄生}}$**：物理量為 PD 接面電容與 Pad 寄生電容，典型範圍 $0.1\text{pF} \sim 0.5\text{pF}$。若 TIA 輸入電阻 $R_{in}$ 很大，此處會產生一個極低頻的 Pole ($f_p = 1 / 2\pi R_{in} C_{pd}$)，吃掉所有高頻訊號。

### 白話物理意義
我們不直接用一顆簡單的電阻 ($R_T$) 把光電流轉成電壓，是因為 PD 本身自帶寄生電容；如果電阻太大，高頻電流會全部流進寄生電容裡（頻寬爆跌）；如果電阻太小，轉換出來的電壓又太小。因此我們需要 TIA（轉阻放大器），利用主動電路的回授機制，創造出一個**「虛擬接地 (Virtual Ground) 的超低輸入電阻」**把電流瞬間吸過來，同時又能提供足夠的增益 ($R_T$)。

### 生活化比喻
把 PD 想像成一根會滴水的管子（微弱的光電流），管子底下有一個水桶（PD 的寄生電容）。
- **簡單電阻**：就像在水桶底部開一個很小很小的排水孔。水滴進來，排水孔來不及排，水桶就積水了（訊號在電容上累積，高頻變慢了）。
- **TIA 轉阻放大器**：就像在管子底下直接接上一台「強力抽水馬達」。馬達的吸力極強（輸入電阻 $R_{in}$ 極低），水一滴下來瞬間就被抽走，水桶裡永遠不會積水（電流 100% 進入 TIA），同時馬達還能把水壓放大輸出。

### 面試必考點
1. **問題：在光接收系統中，總雜訊預算是如何分配的？各個雜訊源之間如何疊加？**
   → **答案：** 總雜訊等於各獨立雜訊源的**功率和（均方根的平方和）**。如 $I_{n,total}^2 = I_{n,PD}^2 + I_{n,TIA}^2$。通常 PD 的 Shot noise 佔比小，系統大部分的雜訊預算（約 90%）都會留給 TIA，因此 TIA 必須設計成 Low Noise Amplifier。
2. **問題：為什麼光接收前端必須使用 TIA，而不能只用一顆電阻把電流轉電壓？**
   → **答案：** 面臨「增益與頻寬的 Trade-off」。若只用電阻 $R$，增益與電阻成正比，但輸入極點 $f_{in} = 1 / (2\pi R C_{PD})$ 會隨 $R$ 變大而急遽下降，導致頻寬不足。TIA 利用主動放大器與負回授，將輸入電阻降低為 $R_{in} = R_T / (1+A)$，將極點推向高頻，打破了簡單電阻的增益-頻寬限制。
3. **問題：解釋什麼是消光比 (Extinction Ratio, ER)，它對 SNR 有什麼影響？**
   → **答案：** ER 是傳送端送出「邏輯 1 的光功率」與「邏輯 0 的光功率」的比值 ($P_1/P_0$)。若 ER 太小，$P_1$ 和 $P_0$ 靠得很近，導致 $I_{pp}$ 變小。在同樣的雜訊水平下，訊號擺幅縮小會直接導致 SNR 下降，BER 惡化。這也是為什麼筆記一開始要用 ER 來求 $I_{pp}$。

**記憶口訣：** 「PD 產雜訊算平方，TIA 吸電流降電阻。要 Gain 又要 BW，唯有回授 Virtual Ground。」
