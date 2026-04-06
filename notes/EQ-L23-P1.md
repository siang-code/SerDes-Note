# EQ-L23-P1

> 分析日期：2026-04-06
> 原始圖片：images/done/EQ-L23-P1.jpg

---


### 數學推導
本頁筆記的核心在於 **動態準位追蹤 (Dynamic Level Tracking)**，特別是利用 SS-LMS (Sign-Sign Least Mean Square) 演算法來追蹤資料的振幅與共模電壓。為了讓 Slicer 能精準判斷 0 與 1，我們需要動態調整判斷門檻 $V_{cm}$ 以及誤差門檻 $V_{ref}^+$ 與 $V_{ref}^-$。

1. **共模電壓追蹤 (Common-Mode Tracking)：**
   透過右下的 `Ref Generator` 電路，我們利用運算放大器 (Op-amp) 建立一個共模回授 (CMFB) 迴路。
   首先，提取輸入訊號與參考電壓的共模值：
   - 輸入共模：$V_{y,cm} = \frac{y^+(t) + y^-(t)}{2}$ （透過兩個 $10k\Omega$ 電阻萃取）
   - 參考共模：$V_{ref,cm} = \frac{V_{ref}^+ + V_{ref}^-}{2}$ （同樣透過兩個 $10k\Omega$ 電阻萃取）
   
   Op-amp 比較這兩個電壓。若 $V_{ref,cm} > V_{y,cm}$（即正輸入端大於負輸入端），Op-amp 輸出電壓上升，使得下方的 NMOS 電流源 (標示為「電流 壓下來」) 汲取更多電流 $I_{CM}$。
   因為 $V_{ref}^+$ 與 $V_{ref}^-$ 是透過上拉電阻 $R$ 連接到 $V_{DD}$，增加的電流會產生更大的壓降：
   $V_{ref} = V_{DD} - (I_{bias} + I_{CM}) \cdot R$
   這會迫使 $V_{ref}^+$ 與 $V_{ref}^-$ 下降，連帶使 $V_{ref,cm}$ 下降，直到 $V_{ref,cm} = V_{y,cm}$，達成共模追蹤。

2. **參考振幅追蹤 (Reference Level Tracking)：**
   資料的「1」和「0」平均振幅（即主游標 $h_0$）會隨環境改變。我們需要 $V_{ref}^+$ 追蹤「1」的準位，$V_{ref}^-$ 追蹤「0」的準位。
   這透過 SS-LMS 引擎計算誤差，並轉換為數位碼去控制 $I_{DAC}$。$I_{DAC}$ 注入差動對 (M1, M2) 中，改變兩邊分支的電流差 $\Delta I$。
   - $V_{ref}^+ = V_{cm} + \frac{\Delta I \cdot R}{2}$
   - $V_{ref}^- = V_{cm} - \frac{\Delta I \cdot R}{2}$
   兩者的差值 $V_{ref}^+ - V_{ref}^- = \Delta I \cdot R$，這個差值會動態收斂到實際資料眼圖的平均張開幅度 ($2h_0$)。

### 單位解析
**公式單位消去：**
1. **共模壓降公式**：
   $\Delta V_{CM} [V] = I_{CM} [A] \times R [\Omega]$
   推導：$[A] \times [V/A] = [V]$，代表 NMOS 下拉電流在負載電阻上造成的電壓變化量。

2. **差模參考電壓公式**：
   $V_{ref}^+ - V_{ref}^- [V] = \Delta I_{DAC} [A] \times R [\Omega]$
   推導：$[A] \times [V/A] = [V]$，代表 DAC 輸出的差動電流決定了上下參考門檻的距離。

**圖表單位推斷：**
📈 圖表單位推斷：
- **Eye Diagram (左上眼圖)**：
  - X 軸：時間 [UI] (Unit Interval) 或 [ps]，典型範圍 1~2 UI
  - Y 軸：電壓幅度 [mV]，典型範圍 ±200 mV ~ ±500 mV (以 $V_{cm}$ 為中心浮動)
- **Block Diagram (中間系統圖)**：無具體波形，為 DFE 與 SS-LMS 引擎的系統方塊圖。
- **Schematic (右下電路圖)**：無具體波形，為動態追蹤電路圖。

### 白話物理意義
因為經過通道後的訊號會上下飄移（Vcm 不穩）且忽大忽小（Amplitude 變化），我們不能死板地用固定的尺來量，必須打造一把「中心點會跟著訊號浮動、刻度會跟著訊號伸縮」的動態標尺，才能精準切出 0 和 1。

### 生活化比喻
想像你在測量海浪的高度來判斷是「大浪(1)」還是「小浪(0)」。
如果遇到漲潮（Common-mode 升高），你的測量尺基準點（Vcm）必須跟著水面浮起來，否則所有波浪都會被誤判為大浪。同時，如果今天的風浪整體變強（Amplitude 變大），你用來定義大浪的紅線（Vref+）和小浪的藍線（Vref-）也要自動拉開距離。這個電路就是在做這套「自動漲跌幅與標尺伸縮系統」！

### 面試必考點
1. **問題：為什麼在高速 SerDes 中需要動態追蹤 Vcm (Dynamic Level Tracking)，而不直接給定一個固定的 Vcm bias？**
   → **答案：** 前級電路（如 CTLE 或 VGA）輸出的 DC 共模準位，容易受到製程變異 (PVT)、溫度漂移或 AC 耦合下的 Baseline Wander 影響。若使用固定 Vcm 作為 Slicer 門檻，會導致眼圖中心與判斷準位錯位，大幅吞噬垂直電壓容限 (Voltage Margin) 並增加 BER。
2. **問題：在筆記右下的 Ref Generator 電路中，Op-amp 的功用是什麼？它是正回授還是負回授？**
   → **答案：** 它是一個負回授的共模回授 (CMFB) 迴路。Op-amp 的負輸入端接輸入訊號的共模 ($y(t)_{cm}$)，正輸入端接產生的參考共模 ($V_{ref,cm}$)。當 $V_{ref,cm}$ 過高時，Op-amp 輸出上升，使下方的 NMOS 汲取更多電流，增加電阻 R 的壓降，把 $V_{ref,cm}$「壓下來」，強迫它鎖定輸入訊號的共模。
3. **問題：筆記中提到 Vref+ 和 Vref- 要「Move to average logic of 0 & 1」，這在 DFE / LMS 系統中的具體用途是什麼？**
   → **答案：** 這是在尋找資料的主游標振幅 ($h_0$)。$V_{ref}^+$ 和 $V_{ref}^-$ 是 Error Slicer 的判斷門檻。透過 SS-LMS 演算法追蹤，這兩個準位會收斂到眼圖「1」和「0」的平均高度。這不僅提供了精確的誤差訊號 ($e[n]$) 來更新 DFE 的 Tap 權重 ($-\alpha_1, -\alpha_2$ 等)，更是 PAM4 訊號解碼不可或缺的動態參考準位。

**記憶口訣：**
**「Vcm 跟著浪潮浮動（CMFB 回授），Vref 跟著浪高伸縮（LMS DAC 控制），動態標尺抓準才能切好 Data！」**
