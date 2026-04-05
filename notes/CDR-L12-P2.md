# CDR-L12-P2

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L12-P2.jpg

---


---
## Quarter-Rate Bang-Bang Phase Detector (BBPD)

### 數學推導
1. **系統架構與頻率定義：** 
   Quarter-rate (四分之一速率) CDR 的操作時脈頻率為 $f_{clk} = \frac{1}{4} f_{data}$。
   其時脈週期 $T_{clk} = 4 T_b$，其中 $T_b$ 為一個位元的時間 (1 UI)。
2. **多相位時脈需求 (Multi-phase Ck)：** 
   為在一個時脈週期內覆蓋 4 個 data bits，且同時對 Data 眼圖中心與 Edge (轉緣) 進行取樣，我們需要 $4 \times 2 = 8$ 個取樣點。
   這對應到 8 個均勻分佈的時脈相位：$\phi_k = k \times 45^\circ$ ($k=0,1,...,7$)。
   相鄰相位的時間差為：$\Delta t = \frac{T_{clk}}{8} = \frac{4 T_b}{8} = \frac{T_b}{2} = 0.5 UI$。
3. **Bang-Bang PD (Alexander PD) 邏輯推導：**
   根據筆記定義，設定偶數相位（如 `clk0`, `clk90`）為**邊緣(Edge)**取樣，奇數相位（如 `clk45`, `clk135`）為**資料(Data)**取樣。
   定義三個連續取樣點：$E_1$ (Edge_1), $D_1$ (Data_1), $E_2$ (Edge_2)。
   對應的 XOR 邏輯閘：
   - $XOR_0 = E_1 \oplus D_1$
   - $XOR_1 = D_1 \oplus E_2$
   
   **情境 A：時脈過早 (Clock Early)**
   時脈取樣點相對於 Data 波形整體向左偏移。
   $E_1$ 往左偏，提早取樣到前一個資料 $D_{prev}$。
   $D_1$ 仍取樣到當前資料 $D_{curr}$。
   $E_2$ 往左偏，提早取樣到當前資料 $D_{curr}$。
   假設發生資料轉態 ($D_{prev} \neq D_{curr}$)，則：
   $XOR_0 = D_{prev} \oplus D_{curr} = 1$
   $XOR_1 = D_{curr} \oplus D_{curr} = 0$
   結果：$(XOR_0, XOR_1) = (1, 0) \Rightarrow$ **clk early** (完美符合筆記公式)。

   **情境 B：時脈過晚 (Clock Late)**
   時脈取樣點相對於 Data 波形整體向右偏移。
   $E_1$ 往右偏，延遲取樣到當前資料 $D_{curr}$。
   $D_1$ 仍取樣到當前資料 $D_{curr}$。
   $E_2$ 往右偏，延遲取樣到下一個資料 $D_{next}$。
   假設發生資料轉態 ($D_{curr} \neq D_{next}$)，則：
   $XOR_0 = D_{curr} \oplus D_{curr} = 0$
   $XOR_1 = D_{curr} \oplus D_{next} = 1$
   結果：$(XOR_0, XOR_1) = (0, 1) \Rightarrow$ **clk late**。

   **情境 C：無資料轉態 (Long Runs)**
   若連續幾個 bit 都相同，則所有取樣點皆得到相同值。
   $XOR_0 = 0$, $XOR_1 = 0 \Rightarrow (0, 0)$。此時 Charge Pump 應進入 Tri-state (高阻抗)，不輸出控制信號。

### 單位解析
**公式單位消去：**
- **時脈與位元週期關係：**
  $T_{clk} \text{ [s/cycle]} = 4 \times T_b \text{ [s/bit]}$
  $f_{clk} \text{ [Hz]} = \frac{1}{T_{clk} \text{ [s]}} = \frac{1}{4 \times T_b} = \frac{1}{4} f_{data} \text{ [bps]}$
- **相位差轉換時間差：**
  $\Delta t \text{ [s]} = \frac{\Delta \phi \text{ [^\circ]}}{360^\circ\text{/cycle}} \times T_{clk} \text{ [s/cycle]} = \frac{45^\circ}{360^\circ} \times 4 T_b \text{ [s]} = 0.5 T_b \text{ [s]}$

**圖表單位推斷：**
📈 **極座標相位圖 (左上)：**
- 圓周：代表一個完整的時脈週期 $T_{clk}$，對應 $360^\circ$ 相位。
- X/Y 軸：I (In-phase) 與 Q (Quadrature) 軸，無特定因次。圖中標示了 8 個時脈相位，相鄰間隔為 $45^\circ$。

📈 **取樣波形與邏輯圖 (中下)：**
- X 軸：時間 $\text{[UI]}$ 或 $\text{[s]}$，典型範圍為數個 UI (例如 0 ~ 4 UI)。相鄰紅點(取樣點)間距為 $0.5 UI$ ($T_b/2$)。
- Y 軸：電壓 $\text{[V]}$，代表 Data 信號的邏輯高低準位，典型範圍為 $V_{SS}$ 至 $V_{DD}$。

### 白話物理意義
用只有資料速度四分之一的慢時脈，切出 8 個不同相位，每隔半個資料寬度 ($T_b/2$) 就戳一下信號；藉由比對「交界點」和「中心點」的值一不一樣，就能精準判斷時脈是跑太快還是太慢。

### 生活化比喻
就像輸送帶每秒送來 4 個箱子（Data），但檢驗員（Clock）動作很慢每秒只能看一次。為了不錯過任何細節，你請了 8 個檢驗員排成一列，每個人精準錯開 0.125 秒（45度）。有的人負責看箱子正中間，有的人負責看箱子與箱子的接縫。只要看接縫的人發現眼前的顏色跟旁邊看中間的人不一樣，就知道輸送帶（Data）跟檢驗員（Clock）的速度對不上了；如果一連串箱子顏色都一樣（Long runs），大家就集體發呆休息（Tri-state）以免亂下指令。

### 面試必考點
1. **問題：Quarter-rate BBPD 需要幾個時脈相位？相鄰相位的時間差是多少？** 
   → 答案：需要 8 個相位 (0°, 45°, 90°, ..., 315°)。相鄰時間差為 $T_{clk}/8 = T_b/2 = 0.5 UI$。
2. **問題：為什麼在 Long runs (長連續相同 bits) 時，BBPD 必須輸出 Tri-state $(0,0)$？**
   → 答案：因為沒有資料轉態(Edge)就沒有相位誤差資訊。若不進入高阻抗態，電路可能會因為雜訊亂充放電，導致 VCO 發生嚴重的 Pattern-dependent jitter。
3. **問題：相較於 Full-rate，使用 Quarter-rate CDR 的主要優缺點為何？**
   → 答案：優點是大幅降低 Clock Tree 與 DFF 的操作頻率 (僅需 $f_{data}/4$)，省電且放寬先進製程下的電路速度瓶頸；缺點是需要產生多相位 (8 phases) 時脈，且 Phase spacing mismatch 會直接轉化為 CDR 的 Deterministic Jitter。

**記憶口訣：**
Quarter-rate 八相伴，半步 ($T_b/2$) 取樣看邊緣；01 太晚 10 早，00 裝死防飄移。

---
*(TA 備註：若對上述推導「我懂了」，請隨時讓我知道，我會立刻啟動費曼測試驗證你的觀念！)*
