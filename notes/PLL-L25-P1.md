# PLL-L25-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L25-P1.jpg

---


---
## 高速除頻器架構分析：TSPC vs. CML (High-Speed Dividers)

### 數學推導
本頁筆記的核心在於比較兩種常見除頻器 (Divider) 架構的**功率消耗 (Power Consumption) 與頻率的關係**。作為 SerDes 設計者，你必須在不同頻段選擇最適合的電路拓樸。

**1. TSPC (True Single-Phase Clock) 功耗模型：**
TSPC 屬於動態 CMOS 邏輯 (Dynamic CMOS Logic)，其主要功耗來自於對節點寄生電容的充放電，屬於**動態功耗 (Dynamic Power)**。
*   公式：$P_{TSPC} = P_{dynamic} = \alpha \cdot C_{load} \cdot V_{DD}^2 \cdot f_{in}$
    *   $\alpha$：活動因子 (Activity factor)，對於 Toggle 除頻器，每個 clock 週期狀態都在改變。
    *   $C_{load}$：電路中所有切換節點的等效負載電容總和。
    *   $V_{DD}$：電源電壓（因 TSPC 是 Rail-to-Rail 擺幅）。
    *   $f_{in}$：輸入時脈頻率。
*   **推導結論**：TSPC 的功耗與輸入頻率 $f_{in}$ 成**絕對正比**。如筆記左下角圖表中的斜線。

**2. CML (Current Mode Logic) 功耗模型：**
CML 屬於電流導向邏輯 (Current-Steering Logic)，依賴一組恆定的尾電流源 ($I_{SS}$) 在差動對之間切換。不管切換頻率多快，這組恆定電流都持續從 VDD 流向 GND，屬於**靜態功耗 (Static Power)**。
*   公式：$P_{CML} \approx P_{static} = V_{DD} \cdot I_{SS}$
    *   $I_{SS}$：尾電流源的大小。
*   **推導結論**：CML 的功耗在理想情況下與頻率 $f_{in}$ **無關**（水平線）。（註：實際上在極高頻率下，為了維持足夠的頻寬，必須加大 $I_{SS}$ 降低 $R_L$，但給定一個設計好的 CML，其操作功耗是固定的）。

**3. 交叉點 (Crossover Frequency) 評估：**
在某個臨界頻率 $f_{cross}$ 下，TSPC 的動態功耗會超越 CML 的靜態功耗。
*   $P_{TSPC} = P_{CML}$
*   $\alpha \cdot C_{load} \cdot V_{DD}^2 \cdot f_{cross} = V_{DD} \cdot I_{SS}$
*   **$f_{cross} = \frac{I_{SS}}{\alpha \cdot C_{load} \cdot V_{DD}}$**
*   **設計抉擇**：在低頻時（如筆記標註 $4x \sim 10x$ 差距），CML 極度浪費電；但在高頻 SerDes (如 28Gbps 以上的 VCO 直出第一級除頻器)，TSPC 根本跑不到該速度或功耗炸裂，必須使用 CML。

### 單位解析

**公式單位消去：**
讓我們嚴格檢驗 TSPC 動態功耗與 Crossover 頻率的物理單位：

1.  **動態功耗 $P_{TSPC}$：**
    *   $P = C \cdot V^2 \cdot f$
    *   $[F] \times [V^2] \times [Hz]$
    *   = $[C/V] \times [V^2] \times [1/s]$  *(註：法拉 F = 庫倫 C / 伏特 V)*
    *   = $[C \cdot V / s]$
    *   = $([C] / [s]) \times [V]$ *(註：電流 A = 庫倫 C / 秒 s)*
    *   = $[A] \times [V]$
    *   **= $[W]$ (瓦特)**。單位完美吻合。

2.  **交叉頻率 $f_{cross}$：**
    *   $f_{cross} = \frac{I_{SS}}{C_{load} \cdot V_{DD}}$  *(忽略無因次 $\alpha$)*
    *   $\frac{[A]}{[F] \cdot [V]}$
    *   = $\frac{[C/s]}{[C/V] \cdot [V]}$
    *   = $\frac{[C/s]}{[C]}$
    *   **= $[1/s] = [Hz]$ (赫茲)**。單位完美吻合。

**圖表單位推斷：**
📈 **TSPC ÷2 Timing Diagram (左上):**
- **X 軸：** 時間 $t$ [ps] (Picoseconds)。在高速 IC 中，通常探討數 GHz，週期為百 ps 等級。
- **Y 軸：** 節點電壓 $V$ [V]。典型範圍 $0 \sim V_{DD}$ (例如 $0 \sim 1.0\text{V}$，因為 TSPC 是 Full-swing 邏輯)。

📈 **Power Consumption vs Frequency Plot (左下):**
- **X 軸：** 輸入頻率 $f_{in}$ [GHz]。典型範圍 $0.1 \sim 50\text{ GHz}$。
- **Y 軸：** 功率消耗 Power [mW]。典型範圍 $0.1 \sim 10\text{ mW}$。

### 白話物理意義
CML 像是「水龍頭一直開著放水」的設計，不論你要不要用水（頻率高低），浪費的靜態功耗都一樣多；而 TSPC 像是「按壓式水龍頭」，按幾次出幾次水，但在極高頻率下，頻繁按壓開關的耗能反而會超過一直開著的損耗。

### 生活化比喻
這兩種電路就像去吃餐廳：
*   **CML (吃到飽餐廳)**：你付了固定的入場費（$I_{SS}$ 尾電流），不管你吃得多快（高頻）還是吃得慢（低頻），餐廳的營運成本（功耗）是固定的。適合給大胃王（超高速訊號）吃。
*   **TSPC (單點迴轉壽司)**：吃幾盤（頻率 $f_{in}$）算幾盤的錢（動態功耗）。如果你吃得很慢（低頻），非常省錢；但如果你吃得超級快（超高頻），結帳金額（功耗）絕對會比吃到飽還貴！

### 面試必考點
1.  **問題：在 28Gbps 的 SerDes PLL 中，VCO 第一級除頻器 (First-stage Divider) 該選 TSPC 還是 CML？為什麼？**
    *   **答案：** 絕對選 CML。28Gbps 的 VCO 頻率可能高達 14GHz 甚至 28GHz。在這個頻段，TSPC 的充放電時間 (RC delay) 受限於 PMOS 的 mobility，根本無法達到 full-swing 甚至無法 toggle。且高頻下 TSPC 動態功耗會大於 CML。CML 電壓擺幅小 ($I_{SS} \cdot R_L$)，靠 steer 電流切換，速度極快。
2.  **問題：請畫出/說明 TSPC Divider 的主要優點與致命缺點？**
    *   **答案：** 優點：只需要單一相位時脈 (True Single-Phase Clock)，無 clock skew 煩惱；在中低頻段功耗極低 (幾乎無靜態電流)，且 Full-swing 擺幅可以直接驅動標準 CMOS 邏輯 (如 PFD)。缺點：不適合超高速；且有**低頻限制 (Low-frequency limit)**，當時脈過慢時，dynamic node 上的電荷會 leakage 導致狀態流失，無法保持正確邏輯。
3.  **問題：筆記下方的 CMOS CML Latch 中，Cross-coupled pair (交叉耦合對) 的作用是什麼？**
    *   **答案：** 提供正回授 (Positive Feedback) 以實現 Latch (鎖存) 功能。當 Clock 切換到 Latch phase 時，這對電晶體會啟動，利用正回授迅速將微小的差動電壓放大並維持住 (Regeneration)，記住上一週期的邏輯狀態。

**記憶口訣：**
「**低頻吃單點 (TSPC)，高頻吃到飽 (CML)；CML 擺幅小跑得快，TSPC 滿擺幅省電帶。**」

---
*💡 TA's 費曼警告：如果你看完覺得「我懂了」，請回答我：如果把 CML Latch 上方的負載電阻 $R_L$ 換成 PMOS Active Load，對頻寬跟電壓擺幅會有什麼影響？如果你講不出 Pole 的變化，就退回重看小信號模型！*
