# PLL-L18-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L18-P1.jpg

---


---
## 高速積體電路被動元件與傳輸線實務 (T-line, Varactor, Cap & Res)

身為你的嚴格助教，我必須提醒你：在先進製程做 SerDes，主動元件（Transistor）的特性大家都懂，但真正區分出工程師等級的，是對於「被動元件（Passive）」與「互連線（Interconnect）」寄生效應的掌握度。這頁筆記滿滿都是佈局與硬體設計的精華，不要只死背數字！

### 數學推導

**1. A-MOS Varactor (Accumulation-mode MOS 可變電容) 的電容值變化**
在 VCO (Voltage-Controlled Oscillator) 中，我們需要電容隨控制電壓改變以調整頻率。
*   **物理結構**：N-well 中的 NMOS 結構，但 Source/Drain 都是 $N^+$，並接在一起作為控制端 $V_S$。Gate 為另一端 $V_G$。
*   **累積區 (Accumulation Region, $V_{GS} > 0$)**：
    當閘極電壓高於 N-well，電子被吸引到閘極氧化層 (Oxide) 下方積聚。
    此時極板間距只有氧化層厚度 $t_{ox}$。
    $$C_{max} \approx C_{ox} = \frac{\epsilon_{ox} \cdot W \cdot L}{t_{ox}}$$
    *(推導：平行板電容公式，介電係數乘上面積除以距離。)*
*   **空乏區 (Depletion Region, $V_{GS} < 0$)**：
    當閘極電壓低於 N-well，氧化層下方的電子被推開，形成缺乏載子的空乏區，寬度為 $W_d$。
    此時等效為兩個電容串聯：氧化層電容 $C_{ox}$ 與空乏區電容 $C_{dep}$。
    $$C_{min} = C_{ox} // C_{dep} = \frac{C_{ox} \cdot C_{dep}}{C_{ox} + C_{dep}}$$
    其中 $C_{dep} = \frac{\epsilon_{Si} \cdot W \cdot L}{W_d}$。因為分母變大（$t_{ox} + 串聯效應$），整體電容值下降。
*   **動態範圍 (Dynamic Range)**：筆記標示為 $2 \sim 3\times$，即 $\frac{C_{max}}{C_{min}} \approx 2 \sim 3$。

**2. 電阻溫度係數 (Temperature Coefficient, TC)**
電阻值會隨溫度漂移，公式可一階近似為：
$$R(T) = R(T_0) \cdot [1 + TC \cdot (T - T_0)]$$
*   推導：將溫度變化 $\Delta T$ 乘上變化率 $TC$ (每度C變化的百分比)，再加上原本的阻值比例 $1$。
*   筆記指出 Unsilicide Poly (未矽化多晶矽) 的 $TC = -0.02\%/^\circ\text{C}$，這是一個極小的負值，代表溫度上升 100 度，阻值才下降 2%。

### 單位解析

**公式單位消去：**
1.  **A-MOS 串聯電容計算：**
    $$C_{min} = \frac{C_{ox}[\text{F}] \cdot C_{dep}[\text{F}]}{C_{ox}[\text{F}] + C_{dep}[\text{F}]} = \frac{[\text{F}^2]}{[\text{F}]} = [\text{F}]$$
2.  **方塊電阻與總阻值：**
    $$R = R_{\square} \left[\frac{\Omega}{\square}\right] \times \frac{L [\mu\text{m}]}{W [\mu\text{m}]} = [\Omega] \times [\text{無單位比例}] = [\Omega]$$
    *(注意：$\square$ (square) 不是物理單位，而是長寬比的無因次量。)*
3.  **電阻溫度變化：**
    $$R(T) = R_0[\Omega] \times \left(1 + TC \left[\frac{1}{^\circ\text{C}}\right] \times \Delta T [^\circ\text{C}]\right) = [\Omega] \times (1 + [\text{無因次}]) = [\Omega]$$

**圖表單位推斷：**
📈 **圖表單位推斷：Monolithic Varactor C-V Curve**
*   **X 軸**：閘極與源極跨壓 $V_{GS}$ (Gate-to-Source Voltage) $[\text{V}]$，典型範圍 $-V_{DD}$ 到 $+V_{DD}$（例如：-1.2V ~ +1.2V，筆記標示 $V_S$ 可從 $0 \sim V_{DD}$，而 $V_G$ 偏置在 $\frac{1}{2}V_{DD}$，創造正負跨壓）。
*   **Y 軸**：電容值 $C_{GS}$ $[\text{fF}]$ 或 $[\text{pF}]$，典型範圍視元件面積而定，通常在數十 fF 到數 pF 之間。

📈 **圖表單位推斷：T-line Cross-section (Micro strip / Coplaner)**
*   **X/Y 軸**：實體空間尺寸 $[\mu\text{m}]$。金屬線寬通常在數微米等級（以降低 Skin effect 與 DCR），金屬層間距由製程 DRC 決定。

### 白話物理意義
**A-MOS Varactor**：就是一個「用電壓控制兩塊金屬板距離」的虛擬彈簧電容，電壓正的時候把電子吸過來（距離近、電容大），電壓負的時候把電子推開留出空乏區（距離遠、電容小）。

### 生活化比喻
**電阻材料與溫度係數 (TC)**：
設計電路就像蓋房子挑建材。
*   **N-well 電阻**就像「普通的木材」，天氣一熱就明顯膨脹變長（正溫度係數 $0.3\%/^\circ\text{C}$，阻值變大很多）。
*   **Unsilicide Poly 電阻**就像「特製的碳纖維複合材料」，不管春夏秋冬，長度幾乎不改變（極低的溫度係數 $-0.02\%/^\circ\text{C}$）。所以當你要打造一個精密的「標準尺」（Bandgap Reference 參考電壓源）時，當然要選不受溫度影響的材料！

### 面試必考點

1.  **問題：為什麼在 GHz 等級的 LC-VCO 中，我們強烈偏好使用 A-MOS (Accumulation-mode) 而不是一般的 Inversion-mode NMOS 來做 Varactor？**
    *   **答案**：一般 NMOS 作為電容時，從 Accumulation 跨越 Depletion 到 Inversion 的過程中，C-V 曲線會有一個非單調的劇烈下陷（凹谷），且依賴少數載子（電子在 p-sub 中）的生成，在高頻下反應太慢。A-MOS 在 N-well 中操作，主要依賴多數載子（電子），不僅高頻響應極佳（Q 值較高），且其 C-V 曲線平滑單調，讓 VCO 的 $K_{VCO}$ 變化較為線性，有助於 PLL 的穩定度。
2.  **問題：觀察筆記，Unsilicide Poly 的 Sheet Resistance ($400\ \Omega/\square$) 比一般 Poly ($1\sim6\ \Omega/\square$) 大很多。請解釋 Silicide (矽化鎢/鈦等) 的作用？為何 Bandgap 中要刻意使用 "Unsilicide" (SAB) 的 Poly？**
    *   **答案**：Silicide 製程是在 Poly 或 Active 區表面覆蓋一層低阻抗金屬合金，目的是極大化降低邏輯閘連線的 RC delay（所以一般 Poly 只有 $1\sim6\ \Omega/\square$）。但在類比電路中，我們常需要幾十 $k\Omega$ 的電阻，如果用 Silicide Poly，長度會太長導致寄生電容過大且面積浪費。使用 Unsilicide (加上 Salicide Block, SAB 光罩擋住不鍍金屬) 可以獲得高阻值（$400\ \Omega/\square$），且最重要的是其晶格散射特性帶來**極低的溫度漂移 (Low TC)**，這對於需要消除溫度變異的 Bandgap 電路是不可或缺的。
3.  **問題：在傳輸線 (T-line) 設計中，Microstrip (微帶線) 和 Coplanar Waveguide (CPW, 共面導波管) 的電場分佈有何不同？如果我要跑 56Gbps PAM4 訊號，你會怎麼選擇？**
    *   **答案**：從筆記上的紅線可以看出，Microstrip 的電場主要集中在頂層訊號線向下指向底層 Ground；而 CPW 的電場除了向下，還有很大部分是指向**同層兩側**的 Ground。對於 56Gbps 極高速訊號，我會傾向考慮 (Grounded) CPW。因為它同層有接地屏蔽，對相鄰訊號線的 Crosstalk (串擾) 隔離度更好；且可以藉由調整同層訊號與地線的間距 (Gap) 來精細 Tuning 特性阻抗 $Z_0$，給佈局工程師更大的設計彈性。

**記憶口訣：**
> **"A-MOS 平滑不反轉，Bandgap 穩重靠未矽化 (Unsilicide)，高速防干擾選 CPW。"**

---
*(助教的凝視：如果你覺得「我懂了」，試著回答我：如果今天製程只有 P-sub，沒有 Deep N-well，你的 A-MOS 還能隔離 substrate noise 嗎？好好想想！)*
