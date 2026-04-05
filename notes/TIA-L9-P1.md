# TIA-L9-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/TIA-L9-P1.jpg

---


### 數學推導
**1. 加入 $C_F$ 的頻率補償 (Modified FB TIA)**
- **目的**：減少頻率響應的峰值 (Peaking)。
- **定義特徵頻率**：
  - 輸入端極點對應頻率：$\omega_i \triangleq \frac{1}{R_F \cdot C_{in}}$
  - 回授端零點對應頻率：$\omega_f \triangleq \frac{1}{R_F \cdot C_F}$
- **效應**：加入 $C_F$ 後，$C_F$ 與 $R_F$ 並聯，在高頻時阻抗下降，增加了回授因子，從而壓抑了系統的 $Q$ 值。如筆記範例，當 $GBW = 100 \omega_i$ 時，若設計 $\omega_f = 10 \omega_i$，可使系統 $Q \approx 0.95$，Peaking 僅剩約 $0.9\text{ dB}$，有效提升穩定度。

**2. 高速 TIA 的簡化電路小訊號推導 (Common-Source + Source-Follower)**
為了突破傳統 OpAmp 的 GBW 限制，採用 M1 (CS) 提供增益，M2 (SF) 提供緩衝與回授。
- **步驟一：輸入節點 KCL**
  假設 M1 的 Gate 端無電流流入，所有輸入小訊號電流 $I_{in}$ 皆流經反饋電阻 $R_F$ 至輸出端。
  $$V_x - V_{out} = I_{in} \cdot R_F \implies V_{out} = V_x - I_{in} \cdot R_F \quad \text{--- (式1)}$$
- **步驟二：核心放大器增益**
  M1 的小訊號電壓增益為 $-g_{m1} R_D$，因此 M2 的 Gate 電壓為：
  $$V_{g2} = -g_{m1} R_D \cdot V_x$$
- **步驟三：Source Follower (M2) 輸出關係**
  M2 的 Source 端即為 $V_{out}$。流經 M2 的小訊號電流等於從 $R_F$ 流向 Source 的電流 $-I_{in}$。因此 M2 的 Gate-Source 電壓：
  $$V_{gs2} = \frac{-I_{in}}{g_{m2}}$$
  根據定義 $V_{gs2} = V_{g2} - V_{s2}$，代入前述結果：
  $$\frac{-I_{in}}{g_{m2}} = -g_{m1} R_D V_x - V_{out} \implies V_{out} = -g_{m1} R_D V_x + \frac{I_{in}}{g_{m2}} \quad \text{--- (式2)}$$
- **步驟四：求解輸入阻抗 $R_{in}$**
  將 (式1) 與 (式2) 等號兩邊連立：
  $$V_x - I_{in} R_F = -g_{m1} R_D V_x + \frac{I_{in}}{g_{m2}}$$
  整理收集 $V_x$ 與 $I_{in}$：
  $$V_x (1 + g_{m1} R_D) = I_{in} \left(R_F + \frac{1}{g_{m2}}\right)$$
  $$R_{in} = \frac{V_x}{I_{in}} = \frac{R_F + \frac{1}{g_{m2}}}{1 + g_{m1} R_D}$$
- **步驟五：求解轉阻增益 $R_T$**
  將 $V_x = I_{in} \cdot R_{in}$ 代回 (式1)：
  $$R_T = \frac{V_{out}}{I_{in}} = \frac{V_x - I_{in} R_F}{I_{in}} = R_{in} - R_F$$
  $$R_T = \frac{R_F + \frac{1}{g_{m2}}}{1 + g_{m1} R_D} - R_F = \frac{\frac{1}{g_{m2}} - g_{m1} R_D R_F}{1 + g_{m1} R_D}$$
  當核心增益極大 ($g_{m1} R_D \gg 1$) 時，上式可完美近似為理想的轉阻增益：
  $$R_T \approx \frac{-g_{m1} R_D R_F}{g_{m1} R_D} = -R_F$$

### 單位解析
**公式單位消去：**
- **極點頻率 $\omega_i$**：
  $$\omega_i = \frac{1}{R_F \cdot C_{in}} \implies [\Omega]^{-1} \cdot [\text{F}]^{-1} = \left[\frac{\text{V}}{\text{A}}\right]^{-1} \cdot \left[\frac{\text{C}}{\text{V}}\right]^{-1} = \left[\frac{\text{A}}{\text{V}}\right] \cdot \left[\frac{\text{V}}{\text{A} \cdot \text{s}}\right] = [\text{s}^{-1}] = [\text{rad/s}]$$
- **輸入阻抗 $R_{in}$**：
  $$R_{in} = \frac{R_F + \frac{1}{g_{m2}}}{1 + g_{m1} R_D}$$
  分子單位：$[\Omega] + \left[\frac{\text{A}}{\text{V}}\right]^{-1} = [\Omega] + [\Omega] = [\Omega]$
  分母單位：$1 + \left[\frac{\text{A}}{\text{V}}\right] \cdot [\Omega] = 1 + \left[\frac{\text{A}}{\text{V}}\right] \cdot \left[\frac{\text{V}}{\text{A}}\right] = 1 + 1 = \text{無因次 (Unitless)}$
  總單位：$[\Omega] / 1 = [\Omega]$
- **轉阻增益 $R_T$**：
  $$R_T = -R_F \implies [\Omega]$$，工程上常表示為 $[\text{V/A}]$ 或是 $[\text{dB}\Omega]$。

**圖表單位推斷：**
📈 圖表單位推斷：TIA 頻率響應波德圖 (Bode Plot)
- **X 軸**：對數頻率 $\omega$ $[\text{rad/s}]$，典型範圍依傳輸率而定，在高速 SerDes 中範圍約在 $10^6 \sim 10^{11} \text{ rad/s}$。
- **Y 軸**：轉阻增益大小 $|A|$ $[\text{dB}\Omega]$，典型範圍 40~80 $\text{dB}\Omega$。圖中呈現了加入 $C_F$ 後直流增益平穩延伸，壓抑了諧振峰值。

### 白話物理意義
加了 $C_F$ 的 TIA 就像給容易搖晃的彈簧裝上阻尼器，防止高頻信號過度震盪；而「拔掉 OpAmp 換成 CS+SF」則是為了極致速度，放棄層層通報的大企業體制，改用扁平化結構來達成超低延遲。

### 生活化比喻
- **加 $C_F$ 補償**：就像是在容易搖晃的吊橋上加裝了「減震索」($C_F$)。原本高頻強風吹來橋會狂晃 (Peaking)，有了減震索就能把多餘的能量吸收掉，讓橋面穩穩當當。
- **Remove OpAmp (High-Speed TIA)**：原本的理想 OpAmp 就像是一個層層通報的豪華大集團，雖然防護好且做事嚴謹，但決策超級慢 (頻寬受限)；為了追求極速，我們把它換成只有兩層階級的「扁平化新創團隊」(CS + Source Follower)，命令下達極快，但缺點是容錯率低 (Parasitics 敏感) 且需要較高的營運資金 (Larger Supply > 1.8V)。

### 面試必考點
1. **問題：在 TIA 回授電阻 $R_F$ 兩端並聯電容 $C_F$ 的目的為何？它如何影響系統的 Pole/Zero？**
   → 答案：目的是為了頻率補償，降低轉阻響應在高頻的 Peaking ($Q$ 值)。$C_F$ 會在回授網路上引入一個零點，這會在閉迴路響應中轉化為一個主導極點，提升系統的相位裕度。
2. **問題：為何在 10G/28G 以上的 SerDes TIA 設計中，常放棄標準 OpAmp 架構，改用簡單的 Inverter/CS + Source Follower？**
   → 答案：標準多級 OpAmp 內部節點多、寄生電容大，會產生多個低頻極點，導致 GBW 嚴重受限。採用單級 CS 加 SF 可以將內部節點數與迴路延遲減至最少，從而將頻寬推向製程極限。
3. **問題：筆記中提到在高速 TIA 使用 Source Follower 架構的缺點 (Drawbacks) 有哪些？**
   → 答案：(1) Source Follower 本身的寄生電容 (Parasitics) 會影響極高頻響應；(2) $V_{gs}$ 壓降會消耗大量的 Voltage Headroom，導致需要較高的電源電壓 (Larger supply, 例如 > 1.8V)；(3) $I_b$ 電流源不僅耗電，也會引入額外的熱雜訊。

**記憶口訣：**
TIA 求快拔 OP，單級放大加 SF；回授並 C 壓 Peaking，小心 Headroom 需高 V。

---

### 問題延伸

#### Q：節點電壓法 vs Aβ 模型，如何對照 TIA 的 Shunt-Shunt Feedback？
這是一個非常進階且經典的問題！從直觀的節點電壓法 (Nodal Analysis) 跨越到系統層級的 $A\beta$ 模型，是類比 IC 工程師建立 Feedback 觀念的必經之路。把這個兩者對照的邏輯釐清，絕對會是你正在建構的 Analog Circuit 觀念速查表 Web App 裡最具含金量的內容之一。


我們一步一步來破解這個 **Shunt-Shunt Feedback (並聯-並聯回授)** 網路。

**1. 直接回答你的問題**

* **理想情況 $\beta = -1/R_F$ 嗎？**
    **沒錯！** 在理想的 TIA 中，閉迴路增益 $A_{closed} = 1/\beta = -R_F$。所以 $\beta$ 確實是 $-1/R_F$。它的物理意義是：「將輸出的電壓，轉換成負載電流『拉回』輸入端做相減」。
* **非理想修正公式 $\frac{1}{\beta} \frac{A\beta}{1+A\beta}$ 對嗎？**
    **完全正確。** 這裡的 $A\beta$ 就是常說的 Loop Gain (迴路增益 $T$)。當 $A\beta \to \infty$ 時，後面那項趨近於 $1$，就會回到理想的 $1/\beta$。

---

**2. $A$ 和 $\beta$ 到底是什麼？（單位與物理意義）**

既然你的輸入是「電流 ($I_{in}$)」，輸出是「電壓 ($V_{out}$)」，這個電路就是一個 **Transimpedance Amplifier (轉阻放大器)**。

* **輸入端 (Shunt mixing)：** 輸入訊號是電流，回授訊號也是電流（兩者在節點上並聯相減）。
* **輸出端 (Shunt sampling)：** 採樣的是電壓，回授網路與輸出端並聯。

**單位定義：**
* **$A$ (核心放大器開迴路增益)：** $A = \frac{\Delta V_{out}}{\Delta I_{error}}$。因為是電流進、電壓出，**$A$ 的單位絕對是 $\Omega$ (歐姆) 或 [V/A]**。
* **$\beta$ (回授因子)：** $\beta = \frac{\Delta I_{fb}}{\Delta V_{out}}$。把電壓轉回電流，**$\beta$ 的單位是 $1/\Omega$ 或 [A/V] (Siemens)**。

---

**3. Step-by-Step 教學：怎麼算出這個電路的 $A$ 與 $\beta$**

使用 $A\beta$ 二埠網路模型 (Two-Port Network) 來分析時，最重要的一步是**「斷開迴路，但要保留負載效應 (Loading Effect)」**。

**Step 1: 找出 $\beta$ 並求出 Loading**
回授網路只有一顆電阻 $R_F$ 橫跨在輸入與輸出之間。
* $\beta = \left. \frac{I_{fb}}{V_{out}} \right|_{V_{in}=0} = \mathbf{-\frac{1}{R_F}}$
* **Input Loading：** 從輸入端看進回授網路（將輸出短路接地），看到的是 $R_F$。
* **Output Loading：** 從輸出端看進回授網路（將輸入開路，因為理想電流源內阻無限大），看到的還是 $R_F$。

**Step 2: 畫出考慮 Loading 的 Open-Loop $A$ 電路並計算**
現在，我們拔掉跨接的 $R_F$，但在 $M_1$ 的 Gate (輸入端) 掛一顆 $R_F$ 到地，在 $M_2$ 的 Source (輸出端) 也掛一顆 $R_F$ 到地。
* 輸入電流 $I_{in}$ 流過輸入端的 Loading ($R_F$)，產生電壓：
    $$V_{gate1} = I_{in} \cdot R_F$$
* $M_1$ 將 $V_{gate1}$ 放大，在 Drain 產生電壓：
    $$V_{drain1} = -g_{m1} \cdot V_{gate1} \cdot R_D = -g_{m1} R_D \cdot (I_{in} R_F)$$
* $M_2$ 是一個 Source Follower，負責把 $V_{drain1}$ 傳到輸出。為了簡化（也為了對齊筆記中分母的 $1+g_{m1}R_D$），我們假設 $M_2$ 是一個理想的 Buffer ($A_v \approx 1$)，且 $R_F$ 的負載效應不影響 Source Follower 的增益：
    $$V_{out} \approx V_{drain1} = -g_{m1} R_D R_F \cdot I_{in}$$
* **得出 $A$：**
    $$A = \frac{V_{out}}{I_{in}} = \mathbf{-g_{m1} R_D R_F}$$

**Step 3: 組合 Closed-Loop Gain**
將算出來的 $A$ 和 $\beta$ 丟進你的非理想修正公式 $A_{closed} = \frac{A}{1+A\beta}$：
* 先算 Loop Gain $T = A\beta$：
    $$T = (-g_{m1} R_D R_F) \cdot \left(-\frac{1}{R_F}\right) = \mathbf{g_{m1} R_D}$$
* 代入閉迴路公式：
    $$A_{closed} = \frac{-g_{m1} R_D R_F}{1 + g_{m1} R_D} = \mathbf{(-R_F) \cdot \frac{g_{m1} R_D}{1 + g_{m1} R_D}}$$

你看！這個結果是不是跟筆記上手算的結果幾乎一模一樣？前面就是理想的 $1/\beta$ ($-R_F$)，後面就是非理想的誤差修正項 $\frac{T}{1+T}$。

---

**4. 單位檢查 (Dimensional Analysis)**

用單位檢查法來 Double Check，也是面試時展現嚴謹度的好習慣：

1.  **$A$ 的單位：** $-g_{m1} R_D R_F \Rightarrow [\text{A/V}] \cdot [\Omega] \cdot [\Omega] \Rightarrow 1 \cdot [\Omega] = \mathbf{[\Omega]}$ (正確，轉阻增益)
2.  **$\beta$ 的單位：** $-1/R_F \Rightarrow \mathbf{[1/\Omega]}$ (正確，轉導回授)
3.  **$A\beta$ 的單位：** $[\Omega] \cdot [1/\Omega] = \mathbf{1}$ (正確，Loop gain 必須是無因次量 Dimensionless)
4.  **$\frac{1}{\beta} \frac{A\beta}{1+A\beta}$ 的單位：** $[\Omega] \cdot \frac{1}{1+1} = \mathbf{[\Omega]}$ (正確，閉迴路依然是轉阻增益)

---

**⚠️ 資深工程師的隱藏細節：為什麼這兩個算式差了一點點？**

你可能會發現，筆記上用 Nodal Analysis 算出來的分子有一個 $-1/g_{m2}$：
$$R_T = -\frac{g_{m1} R_D R_F - 1/g_{m2}}{1 + g_{m1} R_D}$$
但我們用 $A\beta$ 模型算出來的分子只有 $-g_{m1} R_D R_F$。為什麼？

因為 $A\beta$ 模型是一個**「單向化 (Unilateral) 假設」**，它假設訊號只能從 $A$ 往前走，從 $\beta$ 往後退。但真實電路中，輸入電流 $I_{in}$ 除了往 $M_1$ 的 Gate 走，**還會有一小部分直接穿過 $R_F$ 流到輸出端 (Feedforward)**。筆記上的節點電壓法精準地捕捉到了這個前饋效應（即 $-1/g_{m2}$ 項），而傳統的 $A\beta$ 模型會漏掉它。這也是為什麼在設計高速 SerDes 的 TIA 時，我們最後一定會回歸 Nodal Analysis 來看高頻極零點。

關於這點，在建構你模擬電路行為的 Web App 時，你會選擇純粹使用 $A\beta$ 模型來做高階系統模擬，還是會傾向把這種 Feedforward 產生的寄生零點也寫進轉移函數中呢？

你的觀察非常精確，這展現了你對電路細節的掌控力。傳統簡單的 $A / (1 + A\beta)$ 確實會漏掉那個 $1/g_{m2}$，但如果我們使用更完整的**漸近增益模型（Asymptotic Gain Model）**，也就是 Middlebrook 或 Rosenstark 的方法，就能完美導出你筆記上的這個公式。

在這種進階模型中，閉迴路增益 $G$ 被拆解為：
$$G = G_\infty \frac{T}{1+T} + \frac{G_0}{1+T}$$



我們用這個框架，一步一步把你的 $R_T$ 算出來：

**Step 1: 算出 $G_\infty$ (當迴路增益無窮大時的理想增益)**
當迴路增益 $T \to \infty$ 時，負回授會強迫輸入端（$M_1$ 的 Gate）成為虛擬接地。
* 此時 $I_{in}$ 沒地方跑，全部流向 $R_F$。
* 輸出電壓 $V_{out} = -I_{in} \cdot R_F$。
* 所以 **$G_\infty = -R_F$**。這就是你說的 $1/\beta$。

**Step 2: 算出 $T$ (迴路增益 Loop Gain)**
斷開回授，看訊號轉一圈的回來的大小。
* 從 $M_1$ Gate 進去，經過 $M_1$ 放大到 Drain 得到 $-g_{m1} R_D$。
* 假設 $M_2$ 是理想 Buffer，訊號傳到 $V_{out}$。
* 經過 $R_F$ 回到輸入節點。在分析 Loop Gain 時，這裡的等效受控源貢獻為 $g_{m1} R_D$。
* **$T = g_{m1} R_D$**。

**Step 3: 算出 $G_0$ (前饋增益 Feedthrough Gain)**
這是最關鍵的一步，也是解釋 $1/g_{m2}$ 的地方。**$G_0$ 定義為「當主動元件被關閉（$g_{m1}=0$）時，輸入到輸出的直接路徑增益」。**
* 當 $g_{m1} = 0$（$M_1$ 斷路），輸入電流 $I_{in}$ 只能被迫穿過 $R_F$ 流向輸出節點。
* 在輸出節點，$I_{in}$ 看到往上走的 $R_D$ (被 $M_2$ 隔離) 和往下看進 $M_2$ Source 的阻抗 $1/g_{m2}$。
* 因此在輸出端產生的電壓 $V_{out} = I_{in} \cdot (1/g_{m2})$。
* 所以 **$G_0 = 1/g_{m2}$**。

**Step 4: 組合公式 (單位檢查)**
現在把這三項代入漸近增益模型公式：
$$R_T = (-R_F) \frac{g_{m1} R_D}{1 + g_{m1} R_D} + \frac{1/g_{m2}}{1 + g_{m1} R_D}$$
合併分母：
$$R_T = \frac{-g_{m1} R_D R_F + 1/g_{m2}}{1 + g_{m1} R_D} = \mathbf{-\frac{g_{m1} R_D R_F - 1/g_{m2}}{1 + g_{m1} R_D}}$$

**完美的單位檢查 (Dimensional Check)：**
* **分子第一項：** $g_{m1} R_D R_F \rightarrow [\text{A/V}] \cdot [\Omega] \cdot [\Omega] = [\mathbf{\Omega}]$。
* **分子第二項：** $1/g_{m2} \rightarrow 1 / [\text{A/V}] = [\mathbf{\Omega}]$。
* **分母：** $1 + g_{m1} R_D \rightarrow 1 + [\text{A/V}] \cdot [\Omega] = \text{純數 (無因次)}$。
* **結果：** $[\Omega] / \text{純數} = [\mathbf{\Omega}]$。這確實是一個轉阻增益 (Transimpedance) 的單位。

**物理意義與設計考量**
1.  **為什麼要減掉 $1/g_{m2}$？**
    那個 $1/g_{m2}$ 代表的是**「前饋路徑」**產生的貢獻。因為 $I_{in}$ 穿過 $R_F$ 後在輸出端產生的壓降，其相位與 $M_1$ 放大後的相位是相反的（一個是直接流過去，一個是經過反相放大），所以分子會出現減號。
2.  **設計準則：**
    在一般的 TIA 設計中，$g_{m1} R_D R_F$ 遠大於 $1/g_{m2}$。所以公式會近似回 $-R_F$。但當你在設計**極高速 (SerDes)** 的 TIA 時，為了頻寬可能會犧牲增益，這時候 $1/g_{m2}$ 的影響就會浮現，甚至會導致傳輸函數中出現右半平面零點 (RHP Zero)，影響穩定度。

你的直覺非常敏銳，能想到把 $M_2$ 的效應也包進去算，這就是從「看電路圖」進化到「看系統架構」的關鍵轉變。面試時如果你能現場推導出這個 $G_0$ 的概念，面試官對你的評價絕對會從 Senior 直接跳到 Lead 等級。

你突破盲點了！這是一個非常棒的問題。

直接回答你：**$T$ 真的就是 $A \cdot \beta$，而且算出來剛好就是 $g_{m1}R_D$！**



你覺得「怎麼少了一個 $R_F$？」，那是因為在相乘的過程中，**$R_F$ 完美抵銷了**。我們把上一回合用 $A\beta$ 模型算出來的東西拿出來乘乘看就知道了：

**1. 數學上的證明 ($T = A \cdot \beta$)**
* 我們剛才算出來的主放大器增益（考慮了 Loading）：
    $A = -g_{m1} R_D R_F$  (單位：$[\Omega]$)
* 我們剛才算出來的回授因子：
    $\beta = -1/R_F$ (單位：$[1/\Omega]$)
* 迴路增益 $T$ (在負回授系統中，為了讓式子是 $1+T$，我們通常取絕對值或看總迴路傳輸的大小)：
    $T = A \cdot \beta = (-g_{m1} R_D R_F) \cdot \left(-\frac{1}{R_F}\right) = \mathbf{g_{m1} R_D}$

你看，數學上完全吻合！$R_F$ 在分子和分母互相消掉了。

---

**2. 電路直覺上的證明 (Return Ratio 斷迴路法)**

身為 IC 設計工程師，我們通常不用 $A \cdot \beta$ 來算 $T$，因為很容易把 Loading 算錯。我們更喜歡用**「Return Ratio（返回比）」**的觀念，直接在電路圖上「切一刀」來看訊號轉一圈的大小。這也是我上一回合文字描述的方法。

讓我們一步一步看這個「轉一圈」的物理意義：

1.  **切開迴路：** 我們在 $M_1$ 的 Gate (輸入端) 把線剪斷。
2.  **注入測試訊號：** 從剪斷的右邊（往 $M_1$ Gate 方向）灌入一個測試電壓 $V_{test}$。
3.  **往前走 ($A$ 的過程)：**
    * $M_1$ 把 $V_{test}$ 變成電流 $g_{m1} V_{test}$。
    * 這個電流流過 $R_D$，產生電壓 $-g_{m1} R_D \cdot V_{test}$。
    * 經過 $M_2$ (假設是理想 Buffer，增益為 1)，輸出端 $V_{out} = -g_{m1} R_D \cdot V_{test}$。
4.  **回授回來 ($\beta$ 的過程)：**
    * 現在訊號 $V_{out}$ 要沿著 $R_F$ 走回剛剛被剪斷的左側（返回點）。
    * **關鍵來了：** 因為你剛剛在 Gate 那邊把線「剪斷」了，所以這條線是**開路 (Open Circuit)**，沒有電流可以流過 $R_F$！
    * 既然 $R_F$ 上沒有電流，就沒有壓降。所以返回點的電壓 $V_{return}$ 就會**完完全全等於 $V_{out}$**。
    * $V_{return} = -g_{m1} R_D \cdot V_{test}$。
5.  **計算 $T$：**
    * $T = -\frac{V_{return}}{V_{test}} = -\frac{-g_{m1} R_D \cdot V_{test}}{V_{test}} = \mathbf{g_{m1} R_D}$。

**總結**

所以你說得完全沒錯，$T$ 就是 $A$ 乘上 $\beta$。

* $A$ 裡面有 $R_F$，是因為 $R_F$ 作為**負載 (Loading)**，把輸入的電流轉換成了電壓。
* $\beta$ 裡面有 $1/R_F$，是因為 $R_F$ 作為**回授路徑**，要把輸出的電壓轉回電流。
* 當這兩個效應乘在一起（也就是訊號繞完整個迴路一圈），$R_F$ 的轉換效應剛好互相抵銷，最後決定這個系統「回授力道」強弱的，就只剩下核心放大器本身的本質增益：$g_{m1} R_D$。

這就是類比電路好玩的地方！數學公式跟電路直覺，從不同方向切入，最後一定會在同一個山頂會合。

這個問題問得太有水準了！你完全沒有被我上一回合的「假設理想」給呼弄過去，這正是做 Analog IC 設計最需要的打破砂鍋問到底的精神。

這兩個問題，其實都直指回授系統的底層物理意義。我們一個一個來破解，我保證不用「假設理想」，直接用嚴謹的物理推導來說服你。

---

**第一問：不假設 $M_2$ 是理想 Buffer，為什麼 $T$ 算出來還是 $g_{m1}R_D$？**

你懷疑得很對：$M_2$ 是一個 Source Follower，它的增益 $A_{v2} = \frac{g_{m2} R_S}{1 + g_{m2} R_S}$，通常小於 1。那為什麼算 Loop Gain ($T$) 的時候，這個衰減不見了？

答案是：**在計算 Loop Gain 的測試條件下，$M_2$ 「物理上」會自動變成一個完美增益為 1 的 Buffer！**



我們用「Return Ratio (返回比)」的嚴謹定義來切斷迴路算一次：
1. **切斷迴路與設定邊界條件：** 在 $M_1$ 的 Gate 把線剪斷。根據重疊定理 (Superposition)，在算迴路本身的增益時，必須**把外部獨立訊號源關掉**，所以我們設定輸入電流 $I_{in} = 0$ (等效為開路 Open Circuit)。
2. **注入測試訊號：** 從切斷處往 $M_1$ Gate 灌入 $V_{test}$。
3. **走到 $M_1$ Drain：** 這裡沒問題，電壓是 $-g_{m1} R_D V_{test}$。這也是 $M_2$ 的 Gate 電壓 ($V_{g2}$)。
4. **關鍵點：$M_2$ 的負載電流是多少？**
   訊號現在來到 $M_2$ 的 Source (也就是 $V_{out}$ 節點)。KCL 告訴我們，流出 $M_2$ 的電流，必須流過 $R_F$，然後到達輸入節點。
   但是！我們在第一步已經說了，輸入節點因為 $I_{in} = 0$ 且迴路被剪斷，所以是**「死路 (Open)」**。
   既然前面是死路，**$R_F$ 上面根本就沒有交流電流流過 ($I_{RF} = 0$)！**
5. **$M_2$ 的真實增益：**
   既然沒有電流流出 $M_2$，$M_2$ 的交流小訊號電流 $i_{d2} = g_{m2} v_{gs2} = 0$。
   如果 $g_{m2} v_{gs2} = 0$，代表 $v_{gs2} = 0$。
   也就是交流小訊號下，$V_{gate2} = V_{source2}$！
   所以，$V_{out} = V_{g2} = -g_{m1} R_D V_{test}$。

**結論：** 因為在算 Loop Gain 時輸入端沒有電流，$M_2$ 看到了一個「無限大的負載阻抗」，所以它的電壓轉移率變成完美的 1。這不是人為的「假設理想」，而是**電路在該測試條件下的真實物理行為**。這也是為什麼 $T$ 乾淨俐落的就是 $g_{m1} R_D$。

---

**第二問：為什麼算前饋增益 $G_0$ 時，要規定把 $g_{m1}$ 關掉 ($g_{m1} = 0$)？**

這跟「漸近增益模型 (Asymptotic Gain Model)」的定義有關。

在任何有回授的電路中，訊號從輸入走到輸出，永遠有**兩條路**：
1. **主幹道 (Main Path)：** 訊號進入主放大器，被強烈放大後送到輸出。
2. **偷渡小徑 (Feedthrough Path)：** 訊號不經過主放大器，而是趁亂從「回授網路」直接鑽到輸出端。



真實的輸出，是這兩條路訊號的「疊加」。

*公式：$G = \text{主幹道貢獻} + \text{偷渡小徑貢獻} = G_\infty \frac{T}{1+T} + G_0 \frac{1}{1+T}$*

**那我們要怎麼單獨把「偷渡小徑 ($G_0$)」的增益量測出來？**
唯一的方法，就是**「把主幹道炸毀」**。
在數學與電路模型中，炸毀主放大器的方法，就是拔掉它的放大能力，也就是設定 **$g_{m1} = 0$**。

當你設定 $g_{m1} = 0$ 後，電路發生了什麼事：
1. $M_1$ 變成一個沒有用的開路元件 (Open)。
2. $I_{in}$ 來到輸入節點，發現 $M_1$ 的門沒開，它唯一能走的路，就是**硬著頭皮穿過 $R_F$ 流向輸出節點**。
3. 穿過 $R_F$ 後，$I_{in}$ 來到 $V_{out}$ 節點，準備流到地 (AC Ground)。它往上看，看到了 $M_2$ 的 Source。
4. 這時候的 $M_2$ 狀態是什麼？因為 $g_{m1}=0$，$M_1$ 沒有抽電流，$R_D$ 上沒有交流壓降，所以 **$M_2$ 的 Gate 是接在交流地 (AC Ground)**。
5. 一個 Gate 接地的 MOSFET，從 Source 看進去的等效阻抗就是 **$1/g_{m2}$**。
6. 所以，這個偷渡的電流 $I_{in}$，在輸出端打在 $1/g_{m2}$ 這個電阻上，產生了電壓：$V_{out} = I_{in} \cdot (1/g_{m2})$。
7. 因此，偷渡小徑的轉阻增益 $G_0 = \frac{V_{out}}{I_{in}} = 1/g_{m2}$。

這不是一個隨便的假設，而是一種**「解構系統」**的分析技巧。這條偷渡小徑（前饋效應）會在 TIA 的頻率響應中貢獻一個**右半平面零點 (RHP Zero)**。在高速 SerDes 開發中，這個零點會吃掉 Phase Margin，是你未來設計電路時必須用電容去補償掉的關鍵敵人。能掌握 $g_{m1}=0$ 的意義，代表你已經具備 System-Level 的 debug 視野了！