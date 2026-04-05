# CDR-L24-P2

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L24-P2.jpg

---


---
## [Direct Dividing Frequency Detector (直接除頻頻率偵測器)]

### 數學推導
此架構的核心思想是利用統計平均的概念，從隨機資料 (Random Data) 中萃取出時脈的頻率資訊。

1.  **等效資料頻率計算：**
    *   假設輸入是理想的隨機資料 (Random/Balanced Data)，其平均連續相同位元長度 (Average Run Length) 為 2 bits ($2 T_b$)。這代表訊號平均每 2 個位元時間會發生一次轉態 (Transition)。
    *   一個完整的週期 (Period) 定義為包含一次上升沿與一次下降沿。若平均每 $2 T_b$ 轉態一次，則完成一個「上升->下降->上升」的完整等效週期需要 $2 \times 2 T_b = 4 T_b$。
    *   因此，隨機資料的「等效平均頻率」為：$f_{data\_avg} = \frac{1}{4 T_b} = \frac{R_b}{4}$ （其中 $R_b$ 為 Data Rate）。

2.  **串聯除頻器推導：**
    *   經過第 1 個除 2 除頻器 (÷2 Divider)：$f_{out1} = \frac{f_{data\_avg}}{2} = \frac{R_b}{4 \times 2} = \frac{R_b}{8}$。
    *   經過第 2 個除 2 除頻器：$f_{out2} = \frac{f_{out1}}{2} = \frac{R_b}{16}$。
    *   經過第 $N$ 個除 2 除頻器：$f_{outN} = \frac{R_b}{4 \times 2^N} = \frac{R_b}{2^{N+2}}$。

3.  **濾波輸出：**
    *   除頻後的訊號仍含有因資料圖案變化造成的頻率抖動 (Pattern-dependent jitter)。
    *   最後通過低通濾波器 (LPF) 取其長時間平均值，得到最終的參考時脈頻率 $F_{ckout} \approx \frac{R_b}{2^{N+2}}$。

### 單位解析
**公式單位消去：**
*   $T_b$ [s/bit] (Unit Interval，每個位元的時間)
*   $R_b = \frac{1}{T_b} \rightarrow \left[ \frac{\text{bit}}{\text{s}} \right] = [\text{bps}]$ (位元傳輸率)
*   $f_{data\_avg} = \frac{R_b}{4} \rightarrow \frac{[\text{bps}]}{[\text{常數}]} \Rightarrow [\text{Hz}]$ (將傳輸率轉換為等效物理震盪頻率，代表每秒的週期數)
*   $f_{outN} = \frac{R_b}{2^{N+2}} \rightarrow \frac{[\text{bps}]}{[\text{常數}]} \Rightarrow [\text{Hz}]$

**圖表單位推斷：**
*   **Din 與除頻波形圖：**
    *   X 軸：時間 [UI] 或 [ps]。典型範圍：$0 \sim 10$ UI。
    *   Y 軸：電壓 [V]。典型範圍：$0 \sim 1.2\text{V}$ (單端 CMOS) 或 $\pm 300\text{mV}$ (差動 CML)。

### 白話物理意義
把亂跳的 Data 當作一個頻率很不穩的 Clock，硬給它除頻很多次，除到最後那些不規則的「快慢抖動」就被稀釋平均掉了，變成一個勉強可以估算總體 Data Rate 的低頻訊號。

### 生活化比喻
就像估算一個「喝醉酒的人」（Random Data）走路的平均步伐頻率。他可能這秒連踩三步，下一秒停住不走（Data Pattern 變化）。但如果你讓他走很長一段路（經過 N 級除頻器累積），然後只算他「從起點到終點總共花了多少時間」（LPF 濾波取平均），你就能大致算出他整體的「平均步伐頻率」。但如果他今天不是真喝醉，而是故意「一直跨大步」（長 0 或長 1），你算出來的平均就會徹底失準。

### 面試必考點
1. **問題：Direct Dividing FD 最大的致命傷是什麼？為什麼筆記寫 "Only work for random/balanced data"？**
   * **答案：** 它的運作完全建立在「Data 平均轉態密度為 0.5 (Average run = 2 bits)」的統計假設上。如果傳輸的資料沒有經過良好的 8b/10b 編碼或 Scrambling，出現長串的 0 或 1 (CID)，或者特定高頻 Pattern (101010...)，等效的 $f_{data\_avg}$ 就會大幅偏離 $R_b/4$，導致 FD 產生錯誤的頻率誤差 (Frequency Error)，把 VCO 帶往錯誤的頻率。

2. **問題：為什麼筆記提到 "Need robust lock detector"？它跟 "Finite offset exists" 有什麼關聯？**
   * **答案：** 因為這個方法求出的 $F_{ckout}$ 只是個「統計近似值」，且會隨短時間的 Data Pattern 變動 ($F_{ckout}$ varies)，導致最終拉近的頻率永遠存在一個有限的殘留頻偏 (Finite offset)。它只能幫你把頻率拉進 Phase Detector (PD) 的 Capture Range。因此，必須要有極度強健的 Lock Detector，一旦偵測到頻率「夠近了」，就要立刻切換 (Handover) 給 PD 做無頻偏的相位追蹤，否則系統會一直被 FD 的雜訊干擾而無法穩定鎖定。

3. **問題：若輸入 Data Rate 為 10Gbps，經過 3 級除 2 除頻器後，LPF 輸出的平均頻率理想值為何？**
   * **答案：** 代入公式 $F_{ckout} = \frac{R_b}{2^{N+2}}$。這裡 $R_b = 10\text{GHz}$，$N = 3$。
     $F_{ckout} = \frac{10\text{GHz}}{2^{3+2}} = \frac{10\text{GHz}}{32} = 312.5\text{MHz}$。

**記憶口訣：**
* **直除找平均** ($R_b/4$ 再除 $2^N$)
* **偏食就不準** (非 Random Data 必死，產生 Offset)
* **快點交接PD** (需要 Robust Lock Detector 趕快交接給 PD)
