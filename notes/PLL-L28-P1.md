# PLL-L28-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L28-P1.jpg

---


---
## Pulse-Swallow Divider (脈衝吞噬除頻器)

### 數學推導
目標：推導出整個 Pulse-Swallow Divider 的總除頻比 (Divide Ratio)，證明其輸出頻率關係。
設定變數：
- $N$: 預除頻器 (Prescaler) 的基礎除頻比。Prescaler 可以切換除以 $N$ 或除以 $N+1$。
- $P$: 程式計數器 (Program Counter) 的計數值 (固定值，控制總週期長度)。
- $S$: 吞噬計數器 (Swallow Counter) 的計數值 (可變值，用來調整小範圍的除頻比)，且必須滿足 $S < P$。

推導步驟：
1. **初始狀態 (Start from reset)**：
   當系統重置後，Prescaler 被設定為除以 $(N+1)$。
   這段時間內，Prescaler 每收到 $(N+1)$ 個輸入時脈 (Ckin) 邊緣，才會輸出一個脈衝給後級的 Counter。
2. **Swallow Counter 數滿 (until swallow counter is full)**：
   Swallow Counter 和 Program Counter 同時接收並計算 Prescaler 的輸出脈衝。
   當經過 $S$ 個 Prescaler 輸出脈衝時，Swallow Counter 數滿並輸出控制訊號，將 Prescaler 的除頻比從 $(N+1)$ 切換回 $N$。
   在這個階段，輸入端總共經過的 Ckin 週期數為：
   $$Cycles_1 = (N+1) \times S$$
3. **Program Counter 繼續數滿 (keep counting until Program counter is full)**：
   此時 Prescaler 的除頻比變成 $N$。
   Program Counter 總共需要數 $P$ 個脈衝才會重置整個系統。因為剛才已經數了 $S$ 個脈衝，所以還剩下 $(P-S)$ 個脈衝要數。
   在這個階段，輸入端總共經過的 Ckin 週期數為：
   $$Cycles_2 = N \times (P-S)$$
4. **計算總除頻比 (Overall Divide Ratio)**：
   總輸入週期數 $Total\_Cycles = Cycles_1 + Cycles_2$
   $$Total\_Cycles = (N+1)S + N(P-S)$$
   展開式子：
   $$Total\_Cycles = NS + S + NP - NS$$
   消去 $NS$：
   $$Total\_Cycles = NP + S$$
   所以總除頻比 $M = NP + S$。
   輸出頻率 $f_{out}$ 與輸入頻率 $f_{in}$ 的關係為：
   $$f_{out} = \frac{f_{in}}{NP+S}$$

### 單位解析
**公式單位消去：**
- 總除頻比公式：$M = NP+S$
  - $N, P, S$ 皆為計數器的計數次數，為無因次量 (dimensionless)，單位可視為 [cycles]。
  - $[cycles] \times [cycles] + [cycles] = [cycles]$（此處的 cycles 代表輸入端需要幾個週期才能換取輸出端一個週期）。
- 頻率公式：$f_{out} = \frac{f_{in}}{M}$
  - $f_{in}$ 單位：[Hz] 或 [cycles/s]
  - $M$ 單位：[無因次] 或 [input_cycles / output_cycle]
  - $f_{out}$ [Hz] = $f_{in}$ [Hz] / $M$ [無因次] = [Hz]。單位一致。

**圖表單位推斷：**
📈 本頁無波形或 XY 關係圖表，僅含電路方塊圖。針對方塊圖節點進行推斷：
- $f_{REF}$ (CKRef，參考時脈)：頻率 [MHz]，典型值 1 MHz。
- $f_{VCO}$ (Ckout，VCO 輸出時脈)：頻率 [MHz]，典型範圍 2400 ~ 2527 MHz (涵蓋 Bluetooth 頻段)。
- Channel Sel (頻道選擇)：無因次 [整數]，對應不同的 $S$ 值 (0~127)，以微調總除頻比 (2400~2527)。

### 白話物理意義
透過「先偷吃步多數幾拍(除以N+1)，次數夠了(S次)再恢復正常(除以N)」的兩階段機制，讓高頻電路可以用較低速、便宜的計數器，組合出可以「連續微調（步進為1）」的大除頻比。

### 生活化比喻
想像你在工廠包裝糖果，目標是每包要有 $NP+S$ 顆。
你有一個「快速分裝漏斗 (Prescaler)」，它可以設定每次漏出 $N$ 顆或 $N+1$ 顆。
-$P$ 是你規定一包總共要漏幾次。
-$S$ 是你需要「多加一顆」的次數。
開始裝袋時，你先設定漏斗每次漏 $N+1$ 顆糖果。當你裝了 $S$ 次之後（多給了 $S$ 顆），你把漏斗切換回正常的 $N$ 顆。
接下來剩下的 $(P-S)$ 次，每次都只漏 $N$ 顆。
當你總共裝滿 $P$ 次時，袋子裡的糖果總數就是 $(N+1) \times S + N \times (P-S) = NP + S$ 顆。
這樣你只需要一個能快速切換 N 和 N+1 的漏斗，配上旁邊慢慢數 S 和 P 次的低速計數員，就能精準控制任意大數量的總顆數。

### 面試必考點
1. **問題：為什麼需要 Pulse-Swallow Divider，而不直接用一個巨大的 Programmable Divider 來除頻？**
   → 答案：因為在 GHz 等級的高頻下，如果所有的計數器都要做成 Programmable (可程式化)，其複雜的組合邏輯會導致過大的傳遞延遲 (Propagation Delay)，無法滿足時序要求且功耗極高。Pulse-Swallow 架構讓真正跑在高頻的只有 Prescaler (Dual-modulus，只做 N/N+1 切換，架構簡單速度快)，而龐大複雜的 Program / Swallow Counter 則工作在經過預除頻後的低頻區，大幅降低了設計難度與功耗。
2. **問題：在 Pulse-Swallow 架構中，S (Swallow) 和 P (Program) 的大小關係有限制嗎？為什麼？**
   → 答案：有，必須嚴格滿足 $S < P$。因為 Swallow Counter 和 Program Counter 是同步接收 Prescaler 訊號開始計數的，當 Program Counter 數滿 $P$ 次時就會 Reset 整個除頻器。如果 $S \ge P$，Swallow Counter 永遠等不到數滿 $S$ 的那一刻系統就已經重置了，這樣「先除以 N+1」的狀態就無法正確結束，總除頻比 $NP+S$ 的公式就會失效。
3. **問題：如何決定 N 的大小，以確保除頻比可以連續無縫地變化 (Continuous Division Range)？**
   → 答案：為了讓除頻比 $NP+S$ 能以 1 為步進值連續變化，當 P 增加 1 時，總數會增加 N。因此 S 的可調範圍必須能夠填補這 N 個空隙，亦即 S 必須能從 0 變動到 $N-1$。如果我們需要連續的除頻比，系統的最小連續除頻比極限會發生在 $P_{min} = S_{max} = N-1$ 時，此時最小連續除頻比為 $N(N-1) + (N-1) = N^2 - 1$。所以 N 不能選太大，否則會導致無法實現較小的連續除頻比。

**記憶口訣：**
吞嚥(Swallow)多吃一拍(N+1)，數滿S次就停；剩下(P-S)次正常吃(N)，總共吃下 NP+S。
---
