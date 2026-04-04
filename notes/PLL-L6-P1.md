# PLL-L6-P1

> 分析日期：2026-04-04
> 原始圖片：images/PLL-L6-P1.jpg

---

這張筆記進入了 PLL 架構演進的核心：從 Type I 跨越到 **Type II Charge Pump PLL**，以及關鍵元件 **Type IV PFD (Phase Frequency Detector)** 的電路動作原理。這是業界 (如聯發科、瑞昱) 高速 SerDes 與 Clocking 團隊面試最愛考的基礎起手式。

以下是助教為你整理的深度解析：

---
## [Type II PLLs & Type IV PFD 架構與特性]

### 數學推導
（Type II PLL 中 PFD + Charge Pump 的平均輸出推導）

1. **定義輸入條件**：
   假設 Reference Clock (A) 超前 VCO Clock (B) 一個相位差 $\Delta \phi$。
   兩者的週期皆為 $T_{ref}$。
   
2. **計算時間差 $\Delta T$**：
   $\Delta T = \frac{\Delta \phi}{2\pi} \times T_{ref}$
   *(說明：將相位差 $\Delta \phi$ 映射到一個完整週期 $2\pi$ 內的比例，再乘上時間週期 $T_{ref}$)*

3. **分析 PFD 輸出脈衝寬度**：
   根據你筆記上的時序波形圖，當 A 發生 rising edge 時，$Q_A$ (對應 UP) 變為 High。
   經過 $\Delta T$ 時間後，B 發生 rising edge，$Q_B$ (對應 DOWN) 變為 High。
   此時 AND gate 條件滿足，啟動 Reset。但 Reset 訊號要生效，必須經過邏輯閘延遲 $T_{delay}$ (即筆記中提到的 $T_{and} + \text{DFF Delay}$)。
   因此：
   - $Q_A$ 處於 High 的總時間 = $\Delta T + T_{delay}$
   - $Q_B$ 處於 High 的總時間 = $T_{delay}$
   *(說明：筆記右側寫著「QB很窄，多窄？沿著 PFD loop 所需要的 Delay 總長」，這正是刻意設計來消除 Dead Zone 的 Minimum Pulse Width)*

4. **計算單週期 Charge Pump 總輸出淨電荷 $Q_{net}$**：
   $Q_{net} = I_{cp} \times (\text{Time } Q_A \text{ is high}) - I_{cp} \times (\text{Time } Q_B \text{ is high})$
   $Q_{net} = I_{cp} \times (\Delta T + T_{delay}) - I_{cp} \times (T_{delay})$
   $Q_{net} = I_{cp} \times \Delta T$
   *(說明：透過減法，將雙方都有的 $T_{delay}$ 完美抵銷，確保注入迴路的淨電荷僅與相位差時間 $\Delta T$ 嚴格成正比)*

5. **計算平均輸出電流 $\overline{I_{out}}$ 與 PFD 增益 $K_{PD}$**：
   $\overline{I_{out}} = \frac{Q_{net}}{T_{ref}} = I_{cp} \times \frac{\Delta T}{T_{ref}} = I_{cp} \times \frac{\Delta \phi}{2\pi}$
   $K_{PD} = \frac{\overline{I_{out}}}{\Delta \phi} = \frac{I_{cp}}{2\pi}$
   *(說明：證明了此架構在相差 $\pm 2\pi$ 範圍內是一個完美的線性相位偵測器)*

### 單位解析
**【公式單位消去法】**
- **相差時間 $\Delta T$ 計算**：
  $\Delta T[s] = \frac{\Delta \phi[\text{rad}]}{2\pi[\text{rad}]} \times T_{ref}[s] = [1] \times [s] = [s]$
- **單週期電荷 $Q_{net}$ 計算**：
  $Q_{net}[C] = I_{cp}[A] \times \Delta T[s] = [\frac{C}{s}] \times [s] = [C]$
- **平均電流與增益 $K_{PD}$**：
  $\overline{I_{out}}[A] = \frac{Q_{net}[C]}{T_{ref}[s]} = [\frac{C}{s}] = [A]$
  $K_{PD}[\frac{A}{\text{rad}}] = \frac{\overline{I_{out}}[A]}{\Delta \phi[\text{rad}]} = [\frac{A}{\text{rad}}]$

**【圖表隱藏單位推斷】**
📈 **PFD 時序波形圖 (A, B, QA, QB)**
- **X 軸**：時間 [ns]，典型範圍取決於參考時脈，若 Ref 為 100MHz 則週期為 10 ns。
- **Y 軸**：電壓 [V]，典型範圍為先進製程的數位邏輯準位（如 0V ~ 0.9V 或 1.2V）。

📈 **Non-periodic PD Characteristic (左下角轉移曲線)**
- **X 軸**：相位誤差 $\Delta \phi$ [rad]，典型範圍 $\pm 4\pi$ (展示其超越一般 PD $\pm \pi$ 的限制)。
- **Y 軸**：平均輸出電壓 $\overline{V_{out}}$ [V] (或接 CP 後的 $\overline{I_{out}}$)。在 PFD 中，超過 $2\pi$ 會發生 Cycle Slip，但平均輸出仍保持與頻率誤差同號的 DC 值，這正是它「具有頻率偵測功能」的由來。

### 白話物理意義
Type II PLL 加了 Charge Pump，就像給水池（Loop Filter 電容）裝了精準的雙向抽水馬達；而 PFD 是個聰明的監工，不只看兩個人誰跑得前面（相位），還能看出誰跑得比較快（頻率），確保最終兩人的距離與速度誤差都能完全歸零 (Zero Phase Error)。

### 生活化比喻
**Type I PLL** 像是一台「用彈簧連著前車」的後車。彈簧必須拉長 (形變) 才能產生拉力，所以兩車之間永遠會有一個固定的距離落差 (**Finite Phase Error**)。
**Type II PLL** (加了 PFD+CP) 就像後車司機升級了。他會看著前車，只要有距離落差，他就「持續踩油門或煞車並累積起來」(積分器)。只有當兩車距離「完全為零」時，他才會保持當前油門深度。而且就算一開始前車是用飆的 (頻率差很多)，這位司機也能察覺並死命加速追上 (**Infinite Acquisition Range**)，不會像彈簧那樣一開始扯斷就追不到了。

### 面試必考點
1. **問題：筆記中提到 Type II 有 "Zero phase error"，為什麼 Type I 做不到？**
   → **答案**：因為 Type II 的 Charge Pump 搭配 Loop Filter 中的電容，在系統傳遞函數中形成了一個「完美積分器」(Perfect Integrator, $1/s$)。這使得系統在 DC (頻率為0，即穩態) 時的 Loop Gain 為無限大。根據回授控制理論，DC gain 無限大代表穩態誤差必然為零。Type I 只有比例控制，必須維持有限的相位差來維持 VCO 的控制電壓。
2. **問題：PFD 電路中 AND gate 後面的 Reset 為什麼必須要有 Delay？如果 Delay 太短或沒有會發生什麼事？**
   → **答案**：為了消除 **Dead Zone (死區)**。當相差 $\Delta \phi$ 極小時，如果沒有 Delay，UP 和 DOWN 的脈衝會窄到 Charge Pump 的電晶體來不及完全打開 (Turn-on time 限制) 就被關閉了。這會導致 PLL 對微小的相位誤差「視而不見」，使 VCO 在死區內自由漂移，大幅增加 Jitter。
3. **問題：筆記上寫 Type IV PFD 具有「Non-periodic PD characteristic, 有頻率偵測功能」，具體物理機制為何？**
   → **答案**：因為 PFD 是邊緣觸發 (Edge-triggered) 的循序邏輯 (Sequential logic)。當兩信號頻率不同時，高頻信號會週期性地連續出現兩次 Rising edge，導致對應的輸出 (如 UP) 持續保持在高準位，而低頻信號的邊緣根本來不及去 Reset 它。這會產生一個極大的 DC 偏移電流去推動 VCO，因此不受傳統 Multiplier/XOR PD 有限 Lock range 的限制。

**記憶口訣：**
> **「二型零差靠積分，PFD 延遲防死區，頻寬破表抓頻率。」**

---
### 👨‍🏫 助教的費曼測試 (等你說「我懂了」就來接招)：
1. **反事實**：如果我把圖中 DFF 的 D 端不接 VDD，而是把 $Q_A$ 接回 D 端，這電路還能當 PFD 嗎？會變成什麼？
2. **情境遷移**：在 112Gbps 的 PAM4 SerDes 中，RX CDR 還會用這種基於 DFF 的 Type IV PFD 嗎？為什麼？(提示：速度極限與 Bang-Bang PD)
3. **禁語令**：不准用「Charge Pump」跟「積分器」這兩個詞，重新跟我解釋一次為什麼 Type II PLL 的穩態相位誤差是 0？
