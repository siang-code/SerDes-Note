# LA-L0-P1

> 分析日期：2026-04-06
> 原始圖片：images/done/LA-L0-P1.jpg

---


---
## [NRZ 功率譜密度與 8b/10b 編碼 (Baseline Wander 解決方案)]

### 數學推導
1. **NRZ 訊號的功率譜密度 (PSD)**
   隨機 NRZ (Non-Return-to-Zero) 訊號的功率譜密度公式為：
   $PSD(f) = V^2 \cdot T_b \cdot \text{sinc}^2(f \cdot T_b)$
   - **推導與變形**：其中 $\text{sinc}(x) = \frac{\sin(\pi x)}{\pi x}$。當頻率 $f \to 0$ (即 DC 頻率) 時，代入公式得到 $f \cdot T_b = 0$。根據極限原理 $\lim_{x \to 0}\text{sinc}(x) = 1$。
   - **結果**：$PSD(0) = V^2 \cdot T_b \cdot 1^2 = V^2 \cdot T_b$。這在數學上證明了：儘管隨機 NRZ 長期平均電壓為 0，但在 $f=0$ 處 (DC) 卻具有最大的頻譜能量。
   
2. **編碼的 Overhead (額外負擔) 計算**
   - **8b/10b 編碼**：每 8 bits 的真實資料 (Payload)，需要加上 2 bits 的保護/控制位元。
   - $\text{Overhead} = \frac{\text{多加的 bits}}{\text{原本的 bits}} = \frac{2}{8} = 0.25 = 25\%$
   - **頻寬代價**：若實際資料傳輸率需求為 10 Gbps，經過 8b/10b 編碼後，線路上的實際物理傳輸速率 (Baud Rate) 必須提升為：$10 \text{ Gbps} \times \frac{10}{8} = 12.5 \text{ Gbps}$。
   - **演進對比**：筆記右下角提到 PCIe Gen3 使用的 128b/130b 編碼，其 $\text{Overhead} = \frac{2}{128} \approx 1.56\%$，大幅節省了頻寬浪費。

### 單位解析
**公式單位消去：**
針對 PSD 公式：$PSD(f) = V^2 \cdot T_b \cdot \text{sinc}^2(f \cdot T_b)$
- 振幅平方 $V^2$ 的單位：$[\text{V}^2]$
- 位元週期 $T_b$ (Bit Period) 的單位：$[\text{s}]$ (秒)
- $\text{sinc}^2(f \cdot T_b)$ 為純數學函數，單位：無因次量 (Dimensionless, $[1]$)
- 相乘結果：$[\text{V}^2] \times [\text{s}] \times [1] = [\text{V}^2 \cdot \text{s}]$
- 由於頻率 $[\text{Hz}] = [\text{s}^{-1}]$，故 $[\text{s}] = [\text{Hz}^{-1}]$。
- 最終單位推導：$[\text{V}^2 \cdot \text{s}] = \mathbf{[\text{V}^2/\text{Hz}]}$。完全符合功率譜密度「單位頻率下的能量」之物理定義。

**圖表單位推斷：**
📈 右上角手繪 PSD 頻譜圖單位推斷：
- **X 軸**：頻率 $f$ $[\text{Hz}]$ 或 $[\text{GHz}]$。典型範圍：$0 \sim 2/T_b$ (例如 10Gbps 訊號，第一個 Null 點在 10GHz，範圍約為 $0 \sim 20\text{GHz}$)。
- **Y 軸**：功率譜密度 $PSD(f)$ $[\text{V}^2/\text{Hz}]$ 或 $[\text{dBm/Hz}]$。典型範圍：峰值出現在 DC ($f=0$) 處，隨後呈現波浪狀衰減。

### 白話物理意義
隨機 NRZ 訊號雖然「長期」來看 0 和 1 的數量相等，但「短期」內經常會出現連續的 0 或 1 (Run Length)，這些長串不變的電壓對電路來說就是「低頻 (DC) 訊號」；如果不做處理，這些訊號經過 AC coupling 電容或 DCOC (DC offset cancellation) 電路時，就會被當成直流雜訊給濾掉，導致接收端的判決基準線上下亂飄，這就是 Baseline Wander。

### 生活化比喻
想像你在一條水管裡傳送「紅水(1)」和「藍水(0)」，長期來看紅藍總量一樣多，但有時會連續送出一大桶紅水。如果水管中間裝了一個「只允許顏色快速交替通過的濾網（High Pass Filter / DCOC）」，這大桶連續的紅水就會被濾網擋住，導致水壓突然下降，後續的顏色判斷就全亂了（Baseline Wander）。8b/10b 編碼就像是規定「最多只能連送 5 小杯同一種顏色」，強迫顏色頻繁交替，讓濾網永遠不會堵塞，同時保證水流順暢。

### 面試必考點
1. **問題：為什麼隨機 NRZ 訊號的 PSD 在 DC 處能量最大？**
   → **答案：** 雖然隨機訊號的整體平均值為 0，但在時域中會出現隨機長度的連續 1 或連續 0 (Run length)。這些長時間保持不變的準位區段，在頻域中貢獻了大量的低頻與 DC 能量。
2. **問題：什麼是 Baseline Wander (基線漂移)？如何產生？**
   → **答案：** 當帶有豐富低頻能量的 NRZ 訊號通過具有高通特性 (High Pass Filter) 的通道（如 AC Coupling 電容或 DCOC 電路）時，訊號的低頻成分被濾除，導致接收端的電壓準位上下漂移，使得 Slicer (判決器) 失效並產生 Bit Error。
3. **問題：8b/10b Encoding 在 SerDes 中解決了哪兩個核心問題？**
   → **答案：** (1) **DC Balance (直流平衡)**：控制 Running Disparity (RD) 確保 0 和 1 總數相等，將 DC 處的頻譜能量挖空 (Null)，避免經過 AC Coupling 時發生 Baseline Wander。(2) **Transition Density (轉態密度)**：限制連續 0 或 1 的最大長度 (CID 最多 5 個)，確保訊號有足夠的轉態邊緣讓 CDR 能夠穩定鎖定相位。

**記憶口訣：**
「NRZ 帶 DC，過 AC 會 Wander；8b/10b 來救場，限長度、平直流，CDR 好快樂！」
