# PLL-L7-P1

> 分析日期：2026-04-04
> 原始圖片：images/PLL-L7-P1.jpg

---

---
## Type IV Phase-Frequency Detector (PFD) 

### 數學推導
本頁筆記展示了以全諾閘（All NOR Gate）實現的 Type IV PFD（Phase-Frequency Detector）核心邏輯。我們透過布林代數與狀態機來推導其運作機制，並接續推導 PFD 與 Charge Pump (CP) 結合的轉移函數。

**1. 狀態機邏輯推導（對應筆記左下角步驟）：**
設 A 為參考時脈 (Ref)，B 為除頻器回授時脈 (Div)。
*   **步驟 ① 初始狀態：** 假設系統剛重置，$A=0, B=0, Reset=0$。
    *   觀察 Gate 1（輸入為 A 與 UP），此時輸出 $\overline{UP} = \text{NOR}(A, UP)$。若假設 $UP=0$，則 $\overline{UP} = \text{NOR}(0, 0) = \overline{0+0} = 1$。
    *   將 $\overline{UP}=1$ 代入 Gate 2：$UP = \text{NOR}(\overline{UP}, Reset, \dots) = \text{NOR}(1, 0, 0) = \overline{1+0+0} = 0$。此狀態穩態成立。
*   **步驟 ② A 發生升緣：** 當 $A$ 由 $0 \rightarrow 1$ 時。
    *   $\overline{UP} = \text{NOR}(1, UP) = \overline{1+0} = 0$。
    *   將 $\overline{UP}=0$ 代入 Gate 2：$UP = \text{NOR}(0, 0, 0) = \overline{0+0+0} = 1$。
    *   *(說明)* A 的升緣成功觸發了 $UP=1$（即 QA 變高）。
*   **步驟 ③ B 發生升緣：** 當 $B$ 由 $0 \rightarrow 1$ 時（下半部電路完全對稱）。
    *   $\overline{DN} = \text{NOR}(1, DN) = \overline{1+0} = 0$。
    *   將 $\overline{DN}=0$ 代入 Gate 6：$DN = \text{NOR}(0, 0, 0) = \overline{0+0+0} = 1$。
    *   *(說明)* B 的升緣觸發了 $DN=1$（即 QB 變高）。此時 UP=1 且 DN=1。
*   **步驟 ④ Reset 觸發：** 
    *   中間的 Gate 9 為 NOR Gate，輸入端為 $\overline{UP}$ 與 $\overline{DN}$。
    *   $Reset = \text{NOR}(\overline{UP}, \overline{DN}) = \overline{\overline{UP} + \overline{DN}}$
    *   根據笛摩根定律：$\overline{\overline{UP} + \overline{DN}} = UP \cdot DN$
    *   因為此時 $UP=1$ 且 $DN=1$，故 $Reset = 1 \cdot 1 = 1$。
    *   *(說明)* Reset=1 會回饋到 Gate 2 與 Gate 6，強制將 $UP$ 與 $DN$ 歸零。此回饋路徑約需要 1 個 gate delay 的時間。

**2. PFD+CP 轉移函數推導：**
*   將相位差轉為時間差：$\Delta t = \frac{\Delta \phi}{\omega_{ref}}$ 
*   一個參考週期為：$T_{ref} = \frac{2\pi}{\omega_{ref}}$
*   Charge Pump 輸出的平均電流 $I_{avg}$ 等於峰值電流 $I_{cp}$ 乘上工作週期 (Duty Cycle)：
    $I_{avg} = I_{cp} \cdot \frac{\Delta t}{T_{ref}}$ 
    $= I_{cp} \cdot \frac{\frac{\Delta \phi}{\omega_{ref}}}{\frac{2\pi}{\omega_{ref}}}$ *(代入時間差與週期)*
    $= I_{cp} \cdot \frac{\Delta \phi}{2\pi}$ *(將 $\omega_{ref}$ 上下消去)*
*   PFD 增益 (Gain) 定義為：$K_{pfd} = \frac{I_{avg}}{\Delta \phi} = \frac{I_{cp}}{2\pi}$

### 單位解析
**公式單位消去：**
*   **平均電流公式：** $I_{avg} = I_{cp} \times \frac{\Delta \phi}{2\pi}$
    *   $I_{cp}$: [A] (安培)
    *   $\Delta \phi$: [rad] (弧度，無因次)
    *   $2\pi$: [rad] (弧度，無因次)
    *   $I_{avg} = [\text{A}] \times \frac{[\text{rad}]}{[\text{rad}]} = [\text{A}]$ (安培)
*   **PFD Gain ($K_{pfd}$):** $K_{pfd} = \frac{I_{cp}}{2\pi}$
    *   $K_{pfd} = \frac{[\text{A}]}{[\text{rad}]} = [\text{A/rad}]$ (安培/弧度)

**圖表單位推斷：**
📈 右側波形圖單位推斷：
*   **X 軸**：時間 [ns] 或 [UI] (Unit Interval)。對於典型高速 SerDes 參考時脈 (如 100MHz)，範圍約為 0 ~ 50 ns (幾個週期)。
*   **Y 軸**：數位邏輯電壓 [V]。典型為 CMOS 準位，範圍 0 ~ 1.0V (或 1.2V/1.8V 視製程節點而定)。

### 白話物理意義
Type IV PFD 就像是兩個田徑選手的計分板：誰先跑完一圈（升緣），誰的燈（UP/DN）就亮；直到兩人都跑完，燈才一起被主管（Reset）按掉；如果有人太快連跑兩圈，計分板會「吃掉（Swallow）」多出來的那圈，讓他的燈保持恆亮，藉此一眼看出誰跑得比較快（頻率偵測）。

### 生活化比喻
想像一個旋轉門，左右各有一個守衛（UP 和 DN）。
當左邊客人（A 時脈）來了，左邊守衛舉牌（UP=1）；當右邊客人（B 時脈）也來了，右邊守衛跟著舉牌（DN=1）。當兩邊都舉牌時，主管（Reset NOR Gate）就會按下按鈕，讓兩人同時放下牌子。
**Swallow 機制：** 如果左邊客人源源不絕一直來（頻率極快），左邊守衛的牌子會一直舉著放不下來，因為右邊客人還沒到，主管不會按 Reset。這樣就能輕易分辨出左邊的客流量（頻率）遠大於右邊。

### 面試必考點
1. **問題：為什麼這個電路被稱為「Phase and Frequency Detector」，它是如何偵測頻率的？** 
   → **答案：** 重點在於筆記中紅框標示的「Swallow」機制。當輸入頻率 $\Delta f$ 很大時，較快的一端會連續出現兩個升緣。此狀態機會「吞噬」第二個升緣，讓較快端的輸出（UP 或 DN）越過下一個週期持續維持在 High，使平均輸出電流強烈偏向較快的一方，進而把 VCO 頻率拉近 (Frequency Pull-in)。
2. **問題：筆記中提到 Reset 需要 $\sim 1$ gate delay，如果這個 Delay 太短會發生什麼事？如何解決？** 
   → **答案：** 如果 Reset 發生得太快，當 A 和 B 的相位差極小時，UP 和 DN 的脈波會非常窄，導致後級的 Charge Pump 開關來不及完全導通就關閉了，這會造成 **死區 (Dead Zone)**。解決方法是在 Reset 的回饋路徑上人為串接 Delay cell (例如幾個 Inverter)，確保 UP 和 DN 有一個最小脈波寬度 (Minimum pulse width)，消除死區。
3. **問題：相較於 XOR gate 或 Mixer 只能當 Phase Detector (PD)，使用 Type IV PFD 的最大優勢為何？** 
   → **答案：** 傳統 PD 在頻率未鎖定時，輸出平均值為零，無法協助 VCO 拉近頻率（Capture Range 積極限於 Loop Bandwidth）；而 Type IV PFD 擁有非線性的頻率偵測能力，理論上 Capture Range 為無限大，保證 PLL 無論初始頻率差多少都能鎖定。

**記憶口訣：**
PFD 抓頻率，吞噬週期是關鍵；
重置延遲防死區，全諾閘最經典。
