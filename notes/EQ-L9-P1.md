# EQ-L9-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/EQ-L9-P1.jpg

---

TITLE: EQ-L9-P1

### 數學推導
Zero-Forcing (ZF) 等化器的核心目標是求出一組權重，使得 FFE 輸出 $y(t)$ 符合理想的目標脈衝響應 (Target Pulse Response)。
對於圖中的 $T/2$-spaced FFE (Fractionally-Spaced FFE)，抽頭 (Tap) 的時間間距為 $\Delta t = T/2$。
其等化後輸出可表示為輸入波形 $x(t)$ 與權重 $w_k$ 的摺積：
$y(n\frac{T}{2}) = \sum_{k} w_k \cdot x((n-k)\frac{T}{2})$

寫成矩陣形式：
$\mathbf{X} \mathbf{w} = \mathbf{y}_{target}$
其中：
- $\mathbf{X}$ 是輸入波形 $x(t)$ 在 $T/2$ 取樣點的摺積矩陣。
- $\mathbf{w}$ 是 FFE 的權重係數向量 $[w_{-1}, w_0, w_1, \dots]^T$。
- $\mathbf{y}_{target}$ 是目標脈衝響應向量。

為了將 Crossover point 完美校準到 $50\%$（即 $1/2$ UI 處電壓為峰值一半，確保眼圖對稱），我們在設定目標向量時，不僅要求整數倍 UI 處無 ISI ($y(0) = 1, y(\pm T) = 0$)，還可以利用 $T/2$ 取樣的自由度，強迫半整數 UI (邊緣點) 處的值為 $1/2$：
$y(\pm \frac{T}{2}) = \frac{1}{2}$

因此，筆記右側的矩陣等式目標可完整寫為：
$\begin{bmatrix} \vdots \\ x(-T) \\ x(-\frac{T}{2}) \\ x(0) \\ x(\frac{T}{2}) \\ x(T) \\ \vdots \end{bmatrix} \times \begin{bmatrix} \vdots \\ w_{-1} \\ w_0 \\ w_1 \\ \vdots \end{bmatrix} = \begin{bmatrix} 0 \\ 1/2 \\ 1 \\ 1/2 \\ 0 \end{bmatrix}$
只要透過 $\mathbf{w} = (\mathbf{X}^T \mathbf{X})^{-1} \mathbf{X}^T \mathbf{y}_{target}$ (MMSE 演算法) 求解，就能迫使眼圖的交界點精準落在 $1/2$ 處。

### 單位解析
**公式單位消去：**
$y(t)[V] = \sum w_k[-] \cdot x(t - k\cdot \frac{T}{2})[V]$
- $x(t)$：輸入訊號電壓，單位 $[V]$
- $w_k$：FFE 乘法器權重，物理上為電流/電壓增益比例 $[A/V] \cdot [V/A]$ 或純無因次 $[-]$
- $\mathbf{X}[V] \cdot \mathbf{w}[-] = \mathbf{y}_{target}[V]$：等式兩邊單位皆為 $[V]$，推導合理。

**圖表單位推推斷：**
📈 **脈衝響應波形圖 (左下 Pulse Response)**：
- **X 軸**：時間 $[UI]$，典型範圍 $-1.5 UI \sim +1.5 UI$ (圖中紅點標示 $x[-1], x[-0.5], x[0], x[0.5], x[1], x[1.5]$，對應 $T/2$ 的取樣間距)
- **Y 軸**：電壓幅度 $[V]$，典型範圍 $0 \sim 1 V$ (將主游標 Main-cursor 峰值歸一化為 $1$)

📈 **眼圖 (中下 Eye Diagram)**：
- **X 軸**：時間 $[UI]$，典型範圍 $0 \sim 2 UI$
- **Y 軸**：電壓幅度 $[V]$，典型範圍 $0 \sim V_{DD}$ (箭頭指向的 Edge Crossover point 藉由上述等式被強制校準於 $0.5 V_{DD}$ 與 $0.5 UI$ 處)

### 白話物理意義
傳統 FFE 只能控制「資料中心點」的電壓，不管交界處死活；把 Delay cell 換成半週期的 Latch (變成 $T/2$-spaced FFE) 後，我們就能直接對「眼圖交界處 (Edge)」下指令，強迫它精準對齊 50% 的完美高度，消除相位偏移與 DCD。

### 生活化比喻
一般的 T-spaced FFE 就像是「每公尺一根木樁」的吊橋，你只能確保踩在整數公尺（Data 取樣點）時橋面是平的，但兩根木樁中間（Edge 取樣點）可能會因為重量下凹。
$T/2$-spaced FFE 就是「每半公尺加一根木樁」，你不但能讓整數點平穩，還能直接把 0.5 公尺處的橋面高度精確鎖死在 50%，讓閉著眼睛走的人 (CDR Edge Sampler) 跨步時絕對不會踩空。

### 面試必考點
1. **問題：什麼是 Fractionally-Spaced FFE (FS-FFE)？它比 Baud-rate (T-spaced) FFE 好在哪？**
   - **答案：** FS-FFE 的 Tap 間距小於 $1 UI$ (通常為 $T/2$)。好處是它不僅能消除 Data 點的 ISI，還能獨立控制 Edge 點的波形 (如校準 Crossover point 到 1/2)。此外，它滿足 Nyquist 取樣定理，對前端取樣時脈的相位偏移 (Phase variation) 容忍度極高。
2. **問題：在電路設計上，如何用標準元件實現 $T/2$ 的 Delay？**
   - **答案：** 筆記圖中將一個 Flip-Flop (FF) 拆解為兩個 Latch (L)。由於 Latch 在 Full-rate clock 下是半週期透明、半週期鎖存，因此訊號經過一個 Latch 就剛好產生 $T/2$ (半個 UI) 的時間延遲。
3. **問題：筆記中提到 High-speed FS-FFE 有哪 TITLE: EQ-L9-P1

---
## 接收端半速率前饋等化器 (T/2 Fractionally Spaced Rx FFE)

### 數學推導
1. **FFE 轉移方程式 (FIR Filter)**：
   線性等化器的時域輸出可表示為卷積矩陣乘法 $Y = X \cdot W$。
   - $Y$：等化後的目標脈衝響應向量 (Target response vector)。
   - $X$：通道未等化的脈衝響應 (Channel pulse response) 取樣值所組成的 Toeplitz 矩陣。
   - $W$：FFE 的權重向量 (Tap weights, 即圖中的三角形增益 $\alpha, \beta, \dots$)。
2. **目標向量設定 (Target Vector Definition)**：
   從筆記中的矩陣可以看到，等式右邊的目標向量被設定為 $[\dots, 0, 1/2, 1/2, 0, \dots]^T$。
   - 傳統 Zero-Forcing (T-spaced) 的目標通常是 $[0, 0, 1, 0, 0]^T$，只保留主游標 (Main cursor)。
   - 這裡將相鄰兩個取樣點強制定為 `1/2`。由於架構使用 Latch (圖中標示 L，虛線框顯示兩個 L 組成一個 FF)，其延遲時間為 $T/2$。
   - 藉由迫使脈衝響應在 $y(-T/4) = 1/2$ 且 $y(+T/4) = 1/2$ (或是 $y(0)=1/2, y(T/2)=1/2$ 的相對位置)，保證了波形在跨越 0.5 UI 時具有完美的物理對稱性。
3. **校正交叉點 (Calibrates Crossover Point)**：
   當單一位元脈衝 $h(t)$ 滿足上述對稱性時，連續資料轉換（如 0 $\rightarrow$ 1）的重疊波形 $\sum a_k h(t-kT)$，其電壓交會點 (Crossover point) 必然會精準落在理想的 $1/2$ UI 邊界上（即圖中下方眼圖標示的 `1/2 edge`），這能消除系統性的 Data Dependent Jitter (DDJ)，極大化 CDR 的鎖定相位餘裕。

### 單位解析
**【公式單位消去法】**
針對 FFE 時域卷積公式 $y[n] = \sum_{k} w_k \cdot x[n-k]$：
- $x[n-k]$ 是輸入取樣電壓，單位為伏特 $[\text{V}]$。
- $w_k$ 是 Tap weight 乘法器的增益，若為電壓放大器則為無因次比例 $[\text{V/V}]$；若為高速電路常用的電流加總 (Current Summing) 架構，則為跨導 $[\text{A/V}]$。
- 假設為純電壓域運算，輸出電壓 $y[n]$：
  $$y[n] [\text{V}] = \sum \left( w_k [\text{V/V}] \times x [\text{V}] \right) = [\text{V}]$$
- 假設為電流加總架構，輸出電壓 $y[n]$ (需乘上負載電阻 $R_L [\Omega]$)：
  $$y[n] [\text{V}] = \sum \left( w_k [\text{A/V}] \times x [\text{V}] \right) \times R_L [\Omega] = [\text{A}] \times [\Omega] = [\text{V}]$$

**【圖表隱藏單位推斷】**
📈 圖表單位推斷：
- **脈衝響應圖 $x(t)$ (中左圖)**：
  - X 軸：時間 $[\text{UI}]$ (Unit Interval)，標籤明確標示 $x[-1], x[-0.5], x[0], \dots$，步進為 0.5 UI。
  - Y 軸：電壓 $[\text{mV}]$ 或 歸一化幅度 $[\text{V/V}]$，典型範圍 0~1 (歸一化) 或 $\pm 300\text{ mV}$。
- **眼圖 Eye Diagram (中下圖)**：
  - X 軸：時間 $[\text{UI}]$，圖中箭頭標示 `1/2 edge`，代表 UI 的一半。
  - Y 軸：差分電壓 $[\text{mV}]$，典型範圍 $\pm 200 \text{ mV} \sim \pm 400 \text{ mV}$。

### 白話物理意義
利用「每半拍就取樣一次」的超密集延遲線（T/2 FFE），像捏黏土一樣強迫波形在 0 與 1 的交界處完美對稱，讓眼圖的交叉點精準對齊正中央，確保後方的時脈還原電路 (CDR) 不會「看走眼」。

### 生活化比喻
想像你在做章魚燒。一般的全速率 (T-spaced) FFE 像是一次翻一整排，有時候邊緣接縫會歪掉；而半速率 (T/2 Fractionally Spaced) FFE 就像是你用兩支竹籤，每隔「半個模具」的距離就細微戳一下調整形狀（Latch delay）。雖然手很酸、很費力（高功耗），但可以確保每顆章魚燒的接合線（Crossover point）都完美置中，無可挑剔。

### 面試必考點
1. **問題：什麼是 Fractionally Spaced Equalizer (FSE)？為何筆記中的 Latch (L) 可以做到 T/2 延遲？**
   - 答案：FSE 是 Tap 間距小於 1 UI (通常為 T/2) 的等化器。一個標準的 Flip-Flop (FF) 由兩個 Latch 串聯組成（一個 Master、一個 Slave，分別在 Clock 的 High/Low 導通），所以在全速率時脈 (Full-rate clock) 驅動下，單一個 Latch 剛好能提供 $T/2$ 的資料保持與延遲。
2. **問題：筆記中提到 High-speed Rx FFE 有哪四大設計痛點 (Suffers from)？**
   - 答案：(1) **Clock distribution**：時脈分配困難，每個 Latch 都要吃高速時脈，Clock tree 負載極大。(2) **High power**：功耗極高，每個 Tap 都是耗電的高速電路。(3) **Difficult layout**：佈局困難，高速 delay line 與加總節點的走線需嚴格匹配。(4) **Insufficient bandwidth**：頻寬不足，所有 Tap 的放大器輸出在 Summing node ($\Sigma$) 並聯，導致寄生電容 $C_p$ 暴增，大幅拉低 RC 頻寬。
3. **問題：為何要設定 $[0, 1/2, 1/2, 0]^T$ 這種 Target Vector？對系統有何好處？**
   - 答案：這是在做「交叉點校準」(Calibrates crossover point to 1/2)。強迫等化後的脈衝響應在跨越點保持對稱，能讓資料轉換時的眼圖交叉點精準落於 0.5 UI 處。這消除了波形不對稱造成的系統性相位偏移 (Static Phase Offset)，讓後級 CDR 裡的 Phase Detector 能在最佳、最乾淨的相位進行取樣鎖定。

**記憶口訣：**
- 辨認 T/2 架構：「兩個 L 湊一個 FF，半步微調眼置中」。
- Rx FFE 四大痛點：「時・功・佈・頻」 (時脈難、功耗高、佈局煩、頻寬窄)。
