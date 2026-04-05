# CDR-L24-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L24-P1.jpg

---


### 數學推導
此頁筆記主要推導 Pottbacker 相位頻率偵測器 (Phase/Frequency Detector, PFD/PD) 的正常操作範圍（Capture Range 或 Pull-in Range），並探討最差、最佳與極端情況。

核心概念：時脈週期 ($1/f_{ck}$) 與資料位元週期 ($1/R_b$) 存在微小的頻率誤差。在連續 $N$ 個相同 bit (Longest run) 的期間內，因為缺乏資料轉態來提供相位資訊，時脈與資料會產生**累積時間差**。此累積時間差必須小於特定的容忍極限，否則 PD 的狀態機將發生錯誤跳轉（例如筆記左中標示：從正確的狀態轉移 `(1,1) to (0,1) => ok`，變成錯誤的跨狀態跳躍 `(1,1) to (0,0) => NG`）。

**1. 最差情況 (Worst-case)**
假設 PRBS 資料長度為 $2^N-1$，則系統會遇到的最長連續相同位元數 (longest run) 為 $N$。
在 $N$ 個位元內累積的時間誤差為：$N \cdot \left| \frac{1}{f_{ck}} - \frac{1}{R_b} \right|$
最差情況下的容忍極限設為四分之一時脈週期：$\le \frac{1}{4 f_{ck}}$
- 展開不等式：
  $N \cdot \left| \frac{R_b - f_{ck}}{R_b \cdot f_{ck}} \right| \le \frac{1}{4 f_{ck}}$
- 兩邊同乘 $f_{ck}$ (因為在鎖定附近，假設 $f_{ck} \approx R_b$)：
  $N \cdot \frac{|R_b - f_{ck}|}{R_b} \le \frac{1}{4}$
- 定義頻率誤差 $\Delta f_1 \triangleq |R_b - f_{ck}|$，移項可得最差情況的 capture range：
  $\Delta f_1 = \frac{R_b}{4N}$

**2. 最佳情況 (Best-case)**
依循相同推導邏輯，但假設初始相位處在最理想的位置，能承受的相位飄移容忍度加倍：
$\Delta f_2 = 2 \Delta f_1 = \frac{R_b}{2N}$

**3. 極端情況 (Extreme case)**
基於資料的統計特性，計算平均連續相同位元數 (Average runs)：
- $\text{Average runs} = \sum_{k=1}^{\infty} k \left(\frac{1}{2}\right)^k = 2$ bits
- 若電路架構為單緣觸發 (Single-edge triggered)，等效盲跑長度視為 4 bit long ($N=4$)。
- 此時容忍極限放寬為半個時脈週期 ($\frac{1}{2 f_{ck}}$)：
  $4 \cdot \left| \frac{1}{f_{ck}} - \frac{1}{R_b} \right| \le \frac{1}{2 f_{ck}}$
  $4 \cdot \frac{\Delta f_3}{R_b \cdot f_{ck}} \le \frac{1}{2 f_{ck}} \Rightarrow \frac{4 \cdot \Delta f_3}{R_b} = \frac{1}{2}$
  $\Delta f_3 = \frac{1}{8} R_b$

針對 PRBS7 測試樣式 ($N=7$) 代入數值檢驗：
- $\Delta f_1 / R_b = 1 / (4 \times 7) = 1/28 \approx 3.6\%$
- $\Delta f_2 / R_b = 1 / (2 \times 7) = 1/14 \approx 7.2\%$
- $\Delta f_3 / R_b = 1 / 8 = 12.5\%$
(與筆記右下角圖表標示的數據完全吻合)

### 單位解析
**公式單位消去：**
- 累積時間誤差公式：$N \cdot \left| \frac{1}{f_{ck}} - \frac{1}{R_b} \right| \le \frac{1}{4 f_{ck}}$
  - $N$：數量 [無單位]
  - $f_{ck}, R_b$：頻率 [Hz] 或 [1/s]
  - $\frac{1}{f_{ck}}, \frac{1}{R_b}$：時間 [s]
  - 左式單位：[無單位] $\times$ [s] = [s]
  - 右式單位：$\frac{1}{4}$ [無單位] $\times$ [s] = [s]
  - 時間 $\le$ 時間，兩邊單位吻合。
- 捕獲範圍公式：$\Delta f_1 = \frac{R_b}{4N}$
  - $\Delta f_1$：頻率誤差 [Hz]
  - $R_b$：資料速率 [bps]，在物理因次上等同於 [Hz]
  - $N$：數量 [無單位]
  - [Hz] = [Hz] / [無單位]，單位吻合。

**圖表單位推斷：**
1. 📈 **右中：平均長度機率分佈圖**
   - X 軸：連續相同位元的長度 $t$ [bits 或 UI]，典型值 $1, 2, 3, 4, 5...$
   - Y 軸：發生機率 (Probability) [無單位]，典型值 $1/2, 1/4, 1/8, 1/16...$
2. 📈 **右下：FD Transfer Curve (頻率偵測器轉移曲線)**
   - X 軸：頻率誤差 $\Delta f$ [Hz] (或正規化表示為 $\Delta f / R_b$ [%])，典型範圍 $\pm 15\%$
   - Y 軸：頻率偵測器平均輸出電流 $FD's\ I_{avg}$ [$\mu A$]，視 Charge Pump 設計而定，典型範圍約 $\pm 50 \mu A$。

### 白話物理意義
Pottbacker PD 能把頻率抓回來的極限，取決於「當遇到一長串 0 或 1（沒有轉態可以對齊）時，時鐘跟資料的累積腳步誤差，不能大到讓取樣點跨越到下一個 bit 而發生誤判」。

### 生活化比喻
這就像蒙眼走直線。資料轉態就像有人喊「對齊！」讓你校正方向；當資料出現長串連續 1 或 0 時，就像你被蒙上眼睛連走 $N$ 步。如果你的步伐頻率（時脈）跟規定頻率（資料）有一點點誤差 $\Delta f$，走越遠累積的腳步偏差就越大。如果你在下一次聽到「對齊」前，累積偏差超過「四分之一步」，你就會徹底搞錯自己在哪個格子（發生 cycle slip 與狀態機誤判）。所以，蒙眼步數 $N$ 越多，你容許的單步誤差 $\Delta f$ 就必須越小。

### 面試必考點
1. **問題：Pottbacker Frequency Detector 的 Capture Range 跟 PRBS 長度有何關聯？**
   → **答案：** 呈現反比關係 ($\Delta f \propto \frac{R_b}{N}$)。PRBS 級數越高（$N$ 越大），代表最長連續無轉態的位元數越多，CDR 在這段期間處於「盲跑」狀態，累積的相位飄移越大，因此能容忍的頻率誤差 $\Delta f$ 就越小。
2. **問題：推導 worst-case capture range 時，為何累積時間誤差的極限是 $\frac{1}{4 f_{ck}}$？**
   → **答案：** 因為在基於狀態轉移序列的 PD（如 Pottbacker）或半速率/正交相位架構中，相鄰有效取樣點的間距往往是 $0.25$ UI (90度)。若累積誤差超過這個值，取樣時鐘就會跨越資料轉態邊界，導致狀態機漏掉邊緣，從正確序列 `(1,1)` 錯誤跳躍到 `(0,0)`，進而輸出錯誤極性的頻率控制電流。
3. **問題：若某系統規格要求通過 PRBS7 測試，其 Pottbacker PD 的極限 pull-in range 約為多少？**
   → **答案：** 根據 worst-case 理論推導，對於 PRBS7 ($N=7$)，極限範圍 $\Delta f / R_b = 1 / (4 \times 7) \approx 3.6\%$。實務上為了確保系統不發生 false lock，初始頻率誤差必須控制在這個範圍內。

**記憶口訣：**
「頻率捕獲看最長盲跑 (Longest run)，盲跑 $N$ 步不能超過四分之一步（$1/4 T_{ck}$），極限誤差 $\Delta f$ 就是 $R_b$ 除以 $4N$。」
