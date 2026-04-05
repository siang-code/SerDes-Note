# CDR-L5-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L5-P1.jpg

---


---
## Hogge Phase Detector (線性相位偵測器)

做為你們的高速 IC 設計助教，這張圖是 CDR (Clock and Data Recovery) 領域中非常經典的 **Hogge Phase Detector (1985年提出)**。別看它古老，它是所有 Linear PD 的祖師爺！它解決了 Bang-Bang PD (Alexander PD) 非線性的問題，讓系統可以用線性模型來分析（如筆記所寫 "Linear model applies"）。但天下沒有白吃的午餐，它的速度瓶頸也是面試的超級熱區。打起精神，我們一步步拆解！

### 數學推導
Hogge PD 的核心概念是**「脈波寬度比較」**。我們來推導它如何將相位誤差轉換為電荷量：
1. **定義週期與變數：** 假設系統為 Full-Rate，即時鐘週期 $T_{clk} = 1 \text{ UI}$ (Unit Interval)。令完美的取樣點在眼圖正中央，此時 Data 轉態到 Clock 邊緣的時間差應為 $0.5 \text{ UI}$。令實際的時間差為 $t_{actual} = 0.5 \text{ UI} + \Delta t$，其中 $\Delta t$ 就是時間誤差。
2. **分析 X 脈波 (Proportional Pulse)：**
   - $X = Din \oplus B$ (其中 B 是 Din 被 $CK_{in}$ 上緣觸發後的結果)。
   - 當 $Din$ 發生轉態，到下一個 $CK_{in}$ 上緣將 $B$ 更新為止，這段時間 $X$ 會是 High。
   - 因此 $X$ 的脈波寬度 $W_X = t_{actual} = 0.5 \text{ UI} + \Delta t$。它與相位誤差**成正比** (如筆記："X 寬可從 0 bit ~ 1 bit", "Pulse 寬 = Phase error 大小")。
3. **分析 Y 脈波 (Reference Pulse)：**
   - $Y = B \oplus A$ (其中 A 是 B 被 $CK_{in}$ 下緣觸發後的結果，延遲了半個週期)。
   - 當 $B$ 發生轉態，到半個週期後 $A$ 更新為止，這段時間 $Y$ 會是 High。
   - 因為正負緣時間差是固定的，所以 $Y$ 的脈波寬度恆定 $W_Y = 0.5 \text{ UI}$ (如筆記："Y 寬固定 0.5 bit")。
4. **Charge Pump 淨電荷輸出 ($Q_{net}$)：**
   - X 控制 Charge Pump 充入電流 $I_p$ (Up)，Y 控制抽出電流 $I_p$ (Down)。
   - 每次 Data 轉態產生的淨電荷：
     $Q_{net} = I_p \cdot W_X - I_p \cdot W_Y$
     $Q_{net} = I_p \cdot (0.5 \text{ UI} + \Delta t) - I_p \cdot (0.5 \text{ UI}) = I_p \cdot \Delta t$
5. **結論：** 輸出的電荷量 $Q_{net}$ 與時間誤差 $\Delta t$ 呈現**完美的線性關係**。當系統鎖定（$\Delta t = 0$），淨電荷為 0，VCO 頻率不變。

### 單位解析
**公式單位消去：**
- **淨電荷 $Q_{net}$ 公式：** $Q_{net} = I_p \times \Delta t$
  $[C] = [A] \times [s]$
- **平均輸出電流 $I_{avg}$ (考慮資料轉態密度 $D_T$ 及資料速率 $f_{data}$)：** 
  $I_{avg} = Q_{net} \times (f_{data} \times D_T) = I_p \times \Delta t \times f_{data} \times D_T$
  $[A] = [A \cdot s] \times [1/s] \times [\text{無單位}] = [A]$
- **相位偵測器增益 $K_{PD}$：** 若將 $\Delta t$ 轉換為相位誤差 $\Delta \phi$ (拉氏轉換常用)
  $K_{PD} = \frac{I_{avg}}{\Delta \phi}$
  $[A/rad] = [A] / [rad]$

**圖表單位推斷：**
📈 **時序波形圖 (右上)：**
- **X 軸：** 時間 $t$ [UI] 或 [ps]，典型範圍：顯示約 4 UI，若為 1Gbps 則為 4 ns。
- **Y 軸：** 電壓 $V$ [V]，典型範圍：數位邏輯準位 $0 \sim VDD$ (如 $0 \sim 1.2V$)。

📈 **PD 特性曲線圖 (右下)：**
- **X 軸：** 相位誤差 $\Delta \phi$ [rad] 或 [UI]，典型範圍：線性區間介於 $-\pi \sim \pi$ (對應 $-0.5 \text{ UI} \sim 0.5 \text{ UI}$)。
- **Y 軸：** 平均輸出電流 $\overline{I_{out}}$ [$\mu A$]，典型範圍：$-I_p \cdot D_T \sim +I_p \cdot D_T$。

### 白話物理意義
利用 XOR 閘產生一個「跟著實際時鐘飄移而變寬變窄」的 X 脈波，再減去一個「永遠死死固定是半個時鐘週期」的 Y 脈波，多退少補，算出時鐘該變快還是變慢。

### 生活化比喻
想像公司規定**「上班彈性緩衝時間固定是 30 分鐘」**(這就是 Y 脈波)。
今天你從家裡出發(Data轉態) 到 進公司打卡(Clock邊緣)，這段通勤時間就是 X 脈波。
- 如果你通勤花了 40 分鐘 ($X > Y$)：代表你太慢了，要扣錢 (Up訊號，促使時鐘加速)。
- 如果你通勤只花了 20 分鐘 ($X < Y$)：代表你提早到了，發獎金 (Down訊號，促使時鐘減速)。
- 如果你今天請假沒出門 (沒有 Data transition)：不扣錢也不發獎金 (Tri-state，VCO 保持頻率)。

### 面試必考點
1. **問題：Hogge PD 為什麼在連續相同碼 (CID, Consecutive Identical Digits) 時不會讓 VCO 頻率大飄移？**
   - **答案：** 因為它具有 Tri-state 特性。如筆記所寫 "Tri-state output during long runs"。當沒有 Data transition 時，XOR 閘不會產生 X 與 Y 脈波，Charge Pump 的上下開關皆為 OFF (Tri-state)，因此不會對 Loop Filter 充放電，VCO 端的控制電壓得以保持。
2. **問題：Hogge PD 最大的致命傷是什麼？為什麼筆記說 "Data Rate 上不去"？**
   - **答案：** 高速環境下的「脈波吞噬效應」。Hogge PD 極度依賴精準比較 X 和 Y 的「脈波寬度」。但在極高頻（如 28Gbps, UI < 36ps）下，邏輯閘 (XOR, DFF) 的 rise/fall time 以及寄生電容會讓太窄的脈波根本打不出來（"Pulse 寬度不可能無限小"）。這會導致嚴重的 Dead Zone (死區) 與非線性，因此它只適合 Low-to-mid speed (低至中速) 應用。
3. **問題：筆記中提到 "Static phase error may be left"，這個穩態相位誤差是從哪裡來的？**
   - **答案：** 來自電路實際佈局的「不對稱性」。產生 X 脈波只經過一個 XOR 閘；但產生 Y 脈波卻要經過 DFF 觸發再加上 XOR 閘。即使設計時盡量匹配，Clock-to-Q delay 和各種寄生 RC 仍會讓 $W_Y$ 不完全等於理想的 $0.5 \text{ UI}$，這會導致系統最終鎖定在一個偏離眼圖正中央的相位，形成 Static Phase Offset。

**記憶口訣：**
> **Hogge 測寬度，線性好對付；X 變 Y 基準，高速它會吐。**
> (解釋：Hogge 比對脈波寬度，線性模型好分析；X是變動量、Y是固定基準；但遇到高速率就會因為元件 delay 而無法運作)。

---
**💡 助教的費曼測試 (Feynman Test)：**
如果你覺得你已經懂 Hogge PD 了，請回答我：
*「如果我把第二個 DFF (產生A信號的那個) 的 Clock，不使用反相時鐘 (下緣觸發)，而是直接用一個實體的 Delay Line 把原本的 Clock 延遲 $0.5 \text{ UI}$，這樣電路還能正常運作嗎？這兩種做法（Opposite edge vs. Delay line）在 PVT (製程/電壓/溫度) 變異下，哪一種死得比較慘？為什麼？」* 
(好好想一想，下次上課前告訴我答案！)
