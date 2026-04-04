# PLL-L24-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L24-P1.jpg

---


---
## [頻率除法器 (Frequency Dividers) 與靜態除2電路 (Static ÷2 Circuit)]

### 數學推導
靜態除 2 電路 (Static ÷2 Circuit) 利用 Master-Slave D-Flip-Flop (DFF) 配合反相回授實現：
1. **頻率關係推導：**
   輸入時脈週期為 $T_{in}$，頻率為 $f_{in} = \frac{1}{T_{in}}$。
   Master Latch 和 Slave Latch 輪流在輸入時脈的高電位與低電位導通。訊號繞行整個迴路（經過兩個 Latch 與一次反相）需要經過兩個輸入時脈週期，因此輸出週期 $T_{out}$ 為：
   $T_{out} = 2 \cdot T_{in}$
   $f_{out} = \frac{1}{T_{out}} = \frac{1}{2 \cdot T_{in}} = \frac{f_{in}}{2}$
2. **I/Q 相位差推導：**
   I (In-phase) 和 Q (Quadrature) 訊號分別從 Master Latch 和 Slave Latch 取出。
   因為這兩個 Latch 分別由時脈的上升沿與下降沿觸發，它們在時間上的更新差了半個輸入時脈週期：
   $\Delta t = \frac{T_{in}}{2} = \frac{1}{2f_{in}}$
   將這個時間差換算成輸出訊號（週期為 $T_{out}$）的相位差 $\Delta \Phi$：
   $\Delta \Phi = \frac{\Delta t}{T_{out}} \times 360^\circ = \frac{\frac{T_{in}}{2}}{2 \cdot T_{in}} \times 360^\circ = \frac{1}{4} \times 360^\circ = 90^\circ$
3. **最高工作頻率限制：**
   為了讓 Latch 有足夠時間正確鎖存資料，Latch 的 Data-to-Q 延遲時間 ($t_{D \rightarrow Q}$) 必須小於等於半個時脈週期（即時脈處於一個準位的時間）：
   $t_{D \rightarrow Q} \leq \frac{T_{in}}{2} \Rightarrow f_{in, max} \approx \frac{1}{2 \cdot t_{D \rightarrow Q}}$

### 單位解析
**公式單位消去：**
- 頻率轉換：$f_{out} [Hz] = f_{in} [Hz] / 2 \Rightarrow [s^{-1}] = [s^{-1}]$
- 相位差轉換：$\Delta \Phi [^\circ] = \frac{\Delta t [s]}{T_{out} [s]} \times 360 [^\circ] \Rightarrow [^\circ] = \frac{[s]}{[s]} \times [^\circ] = [^\circ]$

**圖表單位推斷：**
1. **時序波形圖 (Timing Diagram)**
   - X 軸：時間 $t$ [ps] 或 [ns]，典型範圍為幾個時脈週期（例如 0~1000 ps）。
   - Y 軸：電壓 [V]，典型範圍 0~1 V (或 VDD，標準 CMOS 邏輯準位)。
2. **靈敏度曲線 (Sensitivity Curve)**
   - X 軸：輸入頻率 $f_{in}$ [GHz]，典型範圍依製程而定，例如 1~50 GHz。
   - Y 軸：輸入功率 Input Power [dBm] (或電壓擺幅 mVpp)，典型範圍 -20~0 dBm。V型曲線谷底代表靈敏度最高（只需極小振幅就能推動除頻）。

### 白話物理意義
除 2 電路就是用兩個「半拍子」的開關（Master/Slave Latch）接力傳遞訊號，因為要兩個半拍（一整個輸入週期）加上一次反相，才能讓輸出翻轉一次，所以輸出的步調（頻率）就變成了輸入的一半；而且兩個開關剛好錯開半拍，在輸出端看起來就形成了精準的 90 度時間差（正交訊號）。

### 生活化比喻
就像是工廠生產線上的「雙人接力裝箱機制」。
輸送帶速度是輸入頻率（$f_{in}$）。第一位員工（Master Latch）在輸送帶「動」的時候把產品放進箱子（I 訊號更新），第二位員工（Slave Latch）在輸送帶「停」的時候把箱子封上並送出（Q 訊號更新）。
因為要兩個人接力做完才算產出一個完整產品，所以最終產出速度只有輸送帶速度的「一半」。而且因為兩位員工的動作永遠錯開「半個輸送帶週期」，這換算成「產品產出週期」剛好是四分之一，也就是 90 度的時間差。

### 面試必考點
1. **問題：Static Divider (如 DFF based) 產生 I/Q 訊號的相位差為何是精準的 90 度？有什麼隱含條件？**
   → **答案：** I 和 Q 訊號分別由輸入時脈的上升沿與下降沿觸發，時間差為輸入時脈的半個週期（$T_{in}/2$）。由於輸出週期是輸入週期的兩倍（$T_{out} = 2T_{in}$），這個時間差佔了輸出週期的 1/4，即 $360^\circ \times (1/4) = 90^\circ$。**隱含條件：** 輸入時脈的 Duty Cycle 必須是非常精準的 50%，否則時間差不會剛好是 $T_{in}/2$，I/Q 之間就會產生相位誤差 (Phase Error)。
2. **問題：請解釋 Divider Sensitivity Curve (靈敏度曲線) 為何呈現 V 型？谷底 (Self-resonance frequency) 的物理意義是什麼？**
   → **答案：** 谷底稱為自共振頻率 (Self-resonance frequency)。在此頻率下，Latch 內部的寄生電容與電阻形成的延遲剛好滿足震盪條件，整個 Divider 本身就像一個環形振盪器（Ring Oscillator）在亞穩態邊緣。因此，只需要極小的輸入功率 (Clock swing) 就能推動狀態翻轉。當頻率偏離自共振點時，就需要更大的輸入能量來強迫內部節點電壓轉換，導致所需 Input Power 上升。
3. **問題：在自共振頻率 (Self-resonance frequency) 時，每個 Latch 貢獻的相位移是多少？為什麼？**
   → **答案：** 每個 Latch 貢獻 90 度的相位移。因為在自共振時，Divider 等同於一個發生震盪的系統，必須滿足 Barkhausen criterion。迴路中有一次反相接線（提供 -180 度），所以兩個 Latch 必須提供額外 180 度的相位移才能達成總相位 360 度的正回授條件。這表示平均每個 Latch 恰好提供 90 度的相位延遲，其主因來自於 regenerative pair 的遲滯效應 (Hysteresis)。

**記憶口訣：**
除二接力分兩拍，輸出減半九十差；
靈敏度圖看V底，自共振點最省力；
要出精準正交角，輸入Duty需一半。
---
