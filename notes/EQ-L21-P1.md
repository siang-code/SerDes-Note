# EQ-L21-P1

> 分析日期：2026-04-06
> 原始圖片：images/done/EQ-L21-P1.jpg

---


---
## [高速 DFE 架構：Loop Unrolling 與 Half-Rate DFE]

### 數學推導
1. **傳統 DFE 的 Critical Path (時序限制):**
   在傳統 1-tap DFE 中，必須在一個 bit period ($T_b$ 或 1 UI) 內完成以下所有動作：
   $T_b \ge t_{ck-q} + t_{mult} + t_{sum} + t_{slicer} + t_{setup}$
   隨著資料率上升（例如 32Gbps，1 UI $\approx 31.25$ ps），要將上述所有延遲塞進 31.25ps 內幾乎是不可能的物理極限。

2. **1-Tap Loop Unrolling DFE (Speculation 推測式 DFE):**
   - 傳統判決方程式：$y[n] = \text{sgn}(x[n] - \alpha \cdot y[n-1])$
   - 核心思想：既然 $y[n-1]$ 的結果只能是 $+1$ 或 $-1$（數位訊號），我們不要等它算完再做減法，直接**同時計算兩種可能**。
   - 分支 1 (假設前一筆為 $+1$): $y_{+}[n] = \text{sgn}(x[n] - \alpha)$
   - 分支 2 (假設前一筆為 $-1$): $y_{-}[n] = \text{sgn}(x[n] + \alpha)$
   - 最後使用一個 MUX (多工器)，利用真實算出的 $y[n-1]$ 作為選擇訊號 (Selector)，挑選正確的分支：
     $y[n] = y_{+}[n] \cdot \frac{1+y[n-1]}{2} + y_{-}[n] \cdot \frac{1-y[n-1]}{2}$
   - **時序限制改變：** 加法器 ($t_{sum}$) 和乘法器 ($t_{mult}$) 被移出回授迴路外！新的迴路只剩下：
     $T_b \ge t_{ck-q} + t_{mux} + t_{setup}$
     這大幅放寬了設計難度。

3. **2-Tap Loop Unrolling DFE:**
   - 考慮前兩筆歷史資料 $y[n-1]$ 與 $y[n-2]$，總共有 $2^2 = 4$ 種組合。
   - 預先設定 4 個 Slicer 的比較閾值：
     $V_{th1} = -\alpha_1 - \alpha_2$
     $V_{th2} = -\alpha_1 + \alpha_2$
     $V_{th3} = +\alpha_1 - \alpha_2$
     $V_{th4} = +\alpha_1 + \alpha_2$
   - 接著用 $y[n-1]$ 和 $y[n-2]$ 去控制 MUX Tree 來選出正確答案。

4. **Half-Rate DFE (半速率 DFE):**
   - 將輸入切成 Even 與 Odd 兩條路徑，時脈頻率減半（例如 32Gbps 用 16GHz Clock）。
   - 每一條路徑有 $2T_b$ 的時間可以運算。筆記提到「一個 Latch 就是一個 $T_b$ delay」，利用正負緣交錯觸發，自然完成了 1:2 的 Demuxing。

### 單位解析
**公式單位消去：**
- **時序不等式：** $T_b[s] \ge t_{ck-q}[s] + t_{mux}[s] + t_{setup}[s]$
  - 等號兩側皆為時間單位秒 $[s]$（在高速電路中通常用 $[ps]$）。以 32Gbps 為例，限制為 $31.25\text{ps} \ge 10\text{ps} + 15\text{ps} + 5\text{ps}$，時間預算極度緊繃。
- **Slicer 判決：** $y_{+}[n][\text{V}] = \text{sgn}(x[n][\text{V}] - \alpha[\text{V}])$
  - 類比輸入訊號 $x[n]$ 為電壓 $[V]$，回授權重 $\alpha$ 乘上參考準位後亦為電壓 $[V]$。兩電壓相減後進入 Slicer (Comparator)，輸出飽和的數位電壓準位 $[V]$。

**圖表單位推斷：**
📈 時序波形方格圖 (在 2-tap 右側)：
- X 軸：時間 [UI] 或 [$T_b$]，典型範圍 0 ~ 4 $T_b$。
- Y 軸：邏輯狀態 [N/A] 或 Clock 準位 [V]，典型範圍 $0 \sim V_{DD}$。

### 白話物理意義
**Loop Unrolling** 就是「不要等前一個人算完再做加減，我們直接把所有可能的答案都先算好（猜），等前一個人的結果一出來，直接『挑』對的那個」，用硬體面積（多顆 Slicer）來換取極致的速度。

### 生活化比喻
這就像去買潛艇堡，傳統做法（一般 DFE）是：你前面那個人點完餐，店員才開始看冰箱剩什麼料，然後才幫你做，超級慢。
Loop Unrolling 則是：店員預先知道你們通常只點「牛排」或「雞肉」，所以他提早把這兩種都做好拿在手上。等你前面的客人結帳完，你只要喊一聲「我要牛！」，店員零秒直接把牛排堡塞給你。速度飛快，但缺點是店員手要夠大（Slicer 變多、功耗變大），而且沒被選到的那個堡就浪費了。

### 面試必考點
1. **問題：為什麼在 >10Gbps 的 SerDes 中，第一個 Tap 的 DFE 通常必須使用 Loop Unrolling（Speculation）架構？**
   → **答案：** 因為在極高速下，1 UI 的時間太短。傳統 DFE 迴路包含 Clock-to-Q、DAC乘法、加法器、Slicer 與 Setup time，總延遲必然大於 1 UI，導致時序違規無法收斂。Loop Unrolling 把最耗時的加減法移出 Critical Path，改用 MUX 選擇，大幅縮短迴路延遲。
2. **問題：Loop Unrolling DFE 有什麼致命缺點？為什麼不能把 10 個 Tap 都 Unroll？**
   → **答案：** Slicer 的數量會隨 Tap 數呈 $2^N$ 幾何級數成長（例如 3-tap 要 8 個 Slicer）。這會導致：(1) Slicer 功耗與面積暴增；(2) 前端輸入節點的寄生電容 (Input Capacitance) 巨大化，直接扼殺前端頻寬 (Bandwidth penalty)。因此通常只對最緊迫的 1st Tap 或 2nd Tap 做 Unrolling。
3. **問題：筆記中提到 Half-rate DFE 可以「Relax clock distribution / power consumption」，為什麼？**
   → **答案：** 因為 Half-rate 架構讓 Clock 頻率減半（例如 32Gbps 資料只需 16GHz 時脈）。較低頻的時鐘在繞線時的衰減較小，Buffer 不需要推那麼用力，整體 Clock tree 的功耗大幅下降；同時，電路利用正負半週交替工作，內建了 1:2 解多工 (Demux) 的效果。

**記憶口訣：**
Unroll 猜答案，空間換時 MUX 撿；
Tap 多擠爆 Input 端，Slicer 倍增功耗險；
Half-rate 降半速，Even Odd 兩路分。
