# CDR-L12-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L12-P1.jpg

---


---
## Half-rate Bang-Bang Phase Detector (DFF-based BBPD)

### 數學推導
在高速 SerDes 中，傳統的 Alexander Phase Detector (Bang-Bang PD) 使用 XOR 閘來比對資料樣本與邊緣樣本。然而，當速度提升至高頻（如 28Gbps 以上）時，XOR 閘的延遲與非對稱性會吃掉時序餘裕（Timing Margin）。本頁筆記展示了一種**以 DFF 取代 XOR 閘**的 Half-rate BBPD 架構。

**1. 取樣時間點定義：**
*   令資料傳輸率為 $R_b$，則單位區間 $1 \text{ UI} = 1/R_b$。
*   Half-rate 架構下，時脈頻率 $f_{clk} = R_b / 2$（符合 Nyquist Sampling 定理）。
*   提供正交時脈 $ckI$ (In-phase, 取樣 Data) 與 $ckQ$ (Quadrature, 取樣 Edge)。
*   定義資料轉態時間為 $t_D$。
*   定義 $ckI$ 取樣時間點為 $t_{I}$，理想上位於資料眼圖正中央 ($t_D + 0.5 \text{ UI}$)。
*   定義 $ckQ$ 取樣時間點為 $t_{Q}$，理想上對齊資料轉態邊緣 ($t_D$)。

**2. 運作邏輯推導（使用 DFF 互相取樣）：**
電路中，前端 DFF 將輸入 $D_{in}$ 取樣出兩路訊號：
*   **X 訊號 (Data Sample)**：由 $ckI$ 觸發產生。
*   **Y 訊號 (Edge Sample)**：由 $ckQ$ 觸發產生。
後級電路將 $Y$ 作為時脈（Clock），去取樣 $X$（Data）。

**Case A: Clock Late (時脈太晚)**
*   時間關係：$t_D < t_Q$ （資料轉態先發生，$ckQ$ 邊緣晚到）。
*   物理現象：因為資料先轉態，$X$ 會先更新為「新資料值」（例如 0 $\to$ 1）。
*   取樣結果：當 $Y$ 發生轉態並觸發後級 DFF 時，$X$ 已經是 1。
*   數學判斷：$V_{PD} = X(t_Q) = \text{New Data} \implies$ 輸出高電位 (H)，指示 Charge Pump 降低 VCO 頻率。

**Case B: Clock Early (時脈太早)**
*   時間關係：$t_Q < t_D$ （$ckQ$ 邊緣先到，資料還沒轉態）。
*   物理現象：因為時脈先到，資料尚未轉態，$X$ 仍維持「舊資料值」（例如 0）。
*   取樣結果：當 $Y$ 發生轉態並觸發後級 DFF 時，$X$ 尚未更新，仍是 0。
*   數學判斷：$V_{PD} = X(t_Q) = \text{Old Data} \implies$ 輸出低電位 (L)，指示 Charge Pump 提高 VCO 頻率。

**3. Long Run (連續相同資料, CID) 推導：**
*   若 $D_{in}$ 長時間無轉態（例如連續的 1111...），則 $X$ 與 $Y$ 都不會發生轉態。
*   由於後級是 DFF，沒有新的 Clock ($Y$) 觸發，DFF 會**保持上一次的輸出狀態**（Hold State）。
*   結論：$V_{PD}(t) = V_{PD}(t-1)$。**不會進入 Tri-state (高阻抗)**，這會導致 VCO 在連續相同資料期間持續往同一個方向漂移（Drift）。

### 單位解析
**公式單位消去：**
Bang-Bang CDR 的迴路頻率步進（Frequency Step, $\Delta f_{VCO}$）由 Charge Pump 電流與 Loop Filter 電阻決定：
$$ \Delta f_{VCO} = \text{sgn}(\Delta \phi) \times I_{CP} \times R_{LF} \times K_{VCO} $$
*   $\text{sgn}(\Delta \phi)$：相位誤差符號（Late=+1, Early=-1），[無單位]
*   $I_{CP}$：Charge Pump 充放電電流，單位 [A]
*   $R_{LF}$：Loop Filter 比例端電阻，單位 [$\Omega$] 或 [V/A]
*   $K_{VCO}$：VCO 增益，單位 [Hz/V]
**單位消去過程：**
$[無單位] \times [\text{A}] \times \left[\frac{\text{V}}{\text{A}}\right] \times \left[\frac{\text{Hz}}{\text{V}}\right] = [\text{Hz}]$
（物理意義：每一次 Bang-Bang 判斷，都會讓 VCO 頻率產生一個固定大小的 $[\text{Hz}]$ 階躍變化，這正是 Bang-Bang CDR 抖動（Jitter）的來源。）

**圖表單位推斷：**
📈 **時序波形圖 (Timing Diagram) 隱藏單位推斷：**
*   **X 軸 (水平)**：時間 $t$，單位通常為 [UI] (Unit Interval) 或 [ps]。對於 10Gbps 訊號，典型範圍在 $0 \sim 400 \text{ ps}$ ($0 \sim 4 \text{ UI}$)。
*   **Y 軸 (垂直)**：數位電壓準位 $V$，單位為 [V]。在先進製程中，High (H) 通常為 $0.8\text{V} \sim 1.0\text{V}$，Low (L) 為 $0\text{V}$。

### 白話物理意義
用「邊緣樣本($Y$)」當作快門去拍「資料樣本($X$)」，如果拍到的是新資料，代表快門按太晚；拍到舊資料，代表快門按太早；如果目標一直不動，快門就不按，裁判直接延用上一次的判決。

### 生活化比喻
想像一場賽跑（Data $X$）與終點攝影機（Clock $Y$）。
*   **Clock Late (太晚)**：跑者已經衝過終點線了（$X$ 變成新狀態），攝影機才喀嚓拍照（$Y$ 觸發）。照片洗出來看到跑者在終點後，代表你拍「晚」了。
*   **Clock Early (太早)**：跑者還沒到終點線（$X$ 維持舊狀態），攝影機就喀嚓拍照。照片洗出來看到跑者在終點前，代表你拍「早」了。
*   **No Tri-state (沒三態)**：如果今天沒有比賽（Long Run 無轉態），這台攝影機的設計是「直接拿上一場比賽的判決報告來頂替」，而不是「不判決」（Tri-state）。這會導致如果是連續假期，裁判會一直發出「太早」或「太晚」的錯誤指令，讓系統慢慢走偏。

### 面試必考點
1. **問題：在高速 CDR 中，為什麼要用 DFF 來取代 Alexander PD 的 XOR 閘？**
   * **答案：** 當資料率極高（如 56Gb/s PAM4 或 28Gb/s NRZ）時，XOR 閘的電路延遲、上升/下降時間不對稱性會嚴重壓縮 Timing Margin。使用 DFF 架構（如 Hogge 或此處的 DFF-BBPD）可以直接利用正反器的 Setup/Hold time 特性進行相位比較，對於高速數位邏輯的物理佈局（Layout）更友善且精準。
2. **問題：這種 DFF-based BBPD 在遇到連續 0 或 1 (CID, Consecutive Identical Digits) 時，會發生什麼事？與傳統 Alexander PD 有何不同？**
   * **答案：** 傳統 Alexander PD 遇到 CID 時會進入 Tri-state（輸出 0），Charge Pump 不動作，VCO 靠 Loop Filter 電容保持頻率（只有漏電流導致微小漂移）。但此 DFF 架構**沒有 Tri-state**，遇到 CID 時會保持最後一次的 Early/Late 狀態，導致 Charge Pump 持續向同方向充放電，造成 VCO 頻率產生較大的頻率漂移（Frequency Drift）與圖案相依抖動（Pattern-Dependent Jitter）。
3. **問題：什麼是 Half-rate 架構？為什麼要付出產生多相位時脈（ckI, ckQ）的代價來換取它？**
   * **答案：** Half-rate 代表時脈頻率只有資料率的一半（例如 10Gbps 資料配 5GHz 時脈）。代價是需要 0°/90°/180°/270° 多相位時脈。好處是大幅放寬了 VCO 的設計難度（在高頻製程中，設計 5GHz VCO 比 10GHz VCO 容易得多，且 Tuning Range 與 Phase Noise 表現更好），同時降低 Clock Distribution Network 的動態功耗。

**記憶口訣：**
「**DFF 沒三態，長跑會飄移；晚拍抓新值，早拍抓舊值。**」

---
*(TA 備註：若你覺得「我懂了」，請接招：如果把 Half-rate 改成 Quarter-rate，你需要幾組 Clock？前端取樣的 DFF 數量會變多少？)*
