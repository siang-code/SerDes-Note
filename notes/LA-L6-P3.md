# LA-L6-P3

> 分析日期：2026-04-06
> 原始圖片：images/done/LA-L6-P3.jpg

---


---
## Shunt-Shunt Feedback (並聯-並聯回授) 與 TIA 轉阻放大器

### 數學推導
本頁筆記主要推導 Shunt-Shunt Feedback 應用於轉阻放大器 (Transimpedance Amplifier, TIA) 時的迴路增益 (Loop Gain, $T$)。

1. **核心參數定義**：
   - 轉阻增益定義為輸出電壓與輸入電流之比：$R_T = \frac{V_{out}}{I_{in}}$。
   - 回授因數 $\beta$：負責將輸出電壓轉換為回授電流。根據負回授方向，$\beta = \frac{I_{fb}}{V_{out}} = -\frac{1}{R_F}$。

2. **開迴路增益 (Open-loop Gain, $A_{ol}$)**：
   - 假設切斷回授路徑（將 $R_F$ 視為對地負載 $R_{in,open}$），輸入電流 $I_{in}$ 全數流入 $R_{in,open}$，產生節點電壓 $V_x = I_{in} \cdot R_{in,open}$。
   - 此電壓 $V_x$ 經過核心電壓放大器（增益為 $-A_v$），得到輸出 $V_{out} = -A_v \cdot V_x$。
   - 故開迴路轉阻增益 $A_{ol} = \frac{V_{out}}{I_{in}} = -A_v \cdot R_{in,open}$。
   - *註：在 MOS 電路中，閘極不吃直流電流，故輸入端看進去的等效開路阻抗主要由回授電阻貢獻，即 $R_{in,open} \approx R_F$。*

3. **迴路增益 (Loop Gain, $T$)**：
   - 根據定義 $T = A_{ol} \cdot \beta$。
   - 代入上述推導：$T = (-A_v \cdot R_{in,open}) \cdot \left(-\frac{1}{R_F}\right) = A_v \cdot \frac{R_{in,open}}{R_F}$。
   - 因為 $R_{in,open} \approx R_F$，所以 $T \approx A_v$（迴路增益趨近於核心放大器的電壓增益）。

4. **與單級 CS TIA 的一致性**：
   - 若核心放大器為單級 Common-Source，且主要等效負載為 $R_F$，其本徵電壓增益 $A_v \approx g_m R_F$。
   - 故 $T \approx A_v \approx g_m R_F$，這與筆記最下方推論的「$T = g_m R_F$ 是一致的」完全吻合。

### 單位解析
**公式單位消去：**
- **轉阻增益 $R_T$**：$V_{out}\text{ [V]} \div I_{in}\text{ [A]} = \text{[V/A]} = \mathbf{[\Omega]}$ (歐姆)
- **開迴路增益 $A_{ol}$**：$(-A_v)\text{ [V/V]} \times R_{in,open}\text{ [\Omega]} = \text{[V/V]} \times \text{[V/A]} = \text{[V/A]} = \mathbf{[\Omega]}$
- **回授因數 $\beta$**：$I_{fb}\text{ [A]} \div V_{out}\text{ [V]} = \text{[A/V]} = \mathbf{[\Omega^{-1}]} = \mathbf{[S]}$ (西門子)
- **迴路增益 $T$**：$A_{ol}\text{ [\Omega]} \times \beta\text{ [S]} = \text{[V/A]} \times \text{[A/V]} = \mathbf{無單位\ (Dimensionless)}$
- **單級增益驗證**：$g_m\text{ [A/V]} \times R_F\text{ [V/A]} = \mathbf{無單位\ (Dimensionless)}$，與 $T$ 單位一致。

**圖表單位推斷：**
📈 圖表單位推斷：
本頁無 Y-X 關係圖表（僅有電晶體電路圖與小訊號模型）。

### 白話物理意義
並聯-並聯 (Shunt-Shunt) 回授就是一個「吃電流、吐電壓」的轉換器 (TIA)；它在輸入端用並聯「吸走」電流來降低輸入阻抗（讓電流更容易流進來），在輸出端用並聯「偵測」電壓來降低輸出阻抗（讓電壓輸出更穩固），確保微弱的電流訊號能順暢無阻地轉換為強健的電壓訊號。

### 生活化比喻
這就像是一個「水流轉水壓」的自動化幫浦系統。
輸入端（Shunt）是個寬大的入水口（低阻抗），負責收集微弱的涓涓細流（輸入電流）；輸出端（Shunt）則是一個穩壓出水口（低阻抗），提供強勁且穩定的水壓（輸出電壓）。中間有一條自動洩壓回流管（回授電阻 $R_F$），當輸出水壓太高時，就會把一部分水引回輸入端來減輕壓力（負回授），藉此維持整個系統「流進多少水，就輸出多少壓」的穩定轉換。

### 面試必考點
1. **問題：在 Shunt-Shunt Feedback (TIA) 中，回授網路對輸入與輸出阻抗的影響為何？為什麼？**
   - 答案：兩者皆**降低**。輸入並聯（電流相減）會降低輸入阻抗（$R_{in} / (1+T)$），使電路更接近理想電流計（易於接收前級電流）；輸出並聯（電壓取樣）會降低輸出阻抗（$R_{out} / (1+T)$），使電路更接近理想電壓源（驅動下一級能力變強）。
2. **問題：在單級放大器構成的 TIA 中，迴路增益 $T$ 的大小由哪些參數決定？**
   - 答案：根據推導 $T \approx A_v$，若核心為單級 CS 放大器且負載以 $R_F$ 為主，則 $T \approx g_m R_F$。因此迴路增益直接取決於放大器核心的跨導 ($g_m$) 與回授電阻 ($R_F$) 的乘積。
3. **問題：為什麼推導 $A_{ol}$ 時，筆記中特別提到「$R_{in,open}$ 通常就是 $R_F$ 本身」？這在什麼前提下成立？**
   - 答案：這在 **MOSFET 放大器**的前提下成立。因為 MOSFET 的閘極（Gate）輸入阻抗極大，沒有直流電流流入閘極。當切斷回授環路時，從輸入節點看進去的等效阻抗幾乎完全由回授電阻 $R_F$ 所主導（電流只能往 $R_F$ 走）。若是 BJT 電路則需考慮 $r_\pi$ 的分流效應。

**記憶口訣：**
**「並流並壓雙降阻，$R_F$ 牽手做 TIA」**
- 並流（輸入並聯）：電流相減，降輸入阻抗。
- 並壓（輸出並聯）：電壓取樣，降輸出阻抗。
- $R_F$ 牽手：用電阻連接頭尾，完成完美的轉阻 (Transimpedance) 轉換。
