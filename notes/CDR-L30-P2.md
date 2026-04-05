# CDR-L30-P2

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L30-P2.jpg

---


---
## [PLL-Based BB CDR] Jitter Generation (J_G) 於線性區之行為分析

### 數學推導
本頁筆記主要探討當 PLL-based Bang-Bang CDR (BB-CDR) 接收到極度乾淨的訊號時，系統產生的固有抖動 (Jitter Generation, $J_G$) 該如何分析。

1. **線性化假設 (Linear Approximation)**：
   對於一個極度乾淨的輸入 (extremely clear input)，系統追蹤的相位誤差極小。
   假設 BB-PD 的線性區間為 $\phi_m = \pm 0.03 \text{ UI}$，而系統的 RMS 抖動 $J_{rms} = 0.01 \text{ UI}$。
   根據常態分佈，$\pm 3\sigma$ (即 $\pm 0.03 \text{ UI}$) 包含了 99.9% 的機率分佈。這意味著高達 99.9% 的取樣相位誤差都落在 BB-PD 的線性區間內 (Linear region)。因此，原本非線性的 BB-CDR 可以被近似為一個純線性 PLL 來分析。

2. **轉移函數與主導雜訊 (Transfer Function & Dominant Noise)**：
   在線性區操作下，來自 PD 與 CP 的雜訊相對微小可忽略 (Negligible)。
   因此，大部分的抖動雜訊來自 VCO 本身 (Most noise comes from VCO)。
   VCO 雜訊到輸出端的轉移函數為一個高通濾波器 (High-Pass Filter, HPF)：
   $$ \frac{\phi_{out}}{\phi_{vco}} \cong \frac{s}{s + 2\xi\omega_n} $$
   *(註：此處為單極點高通之簡化模型，強調在頻寬附近的衰減特性)*

3. **迴路參數推導 (Loop Parameters)**：
   在線性區，等效 PD 增益為 $\frac{I_p}{\phi_m}$。代入標準二階 PLL 公式：
   - 自然頻率：$\omega_n = \sqrt{\frac{I_p K_{vco}}{\phi_m C_p}}$
   - 阻尼因數：$\xi = \frac{R_p}{2}\sqrt{\frac{I_p C_p K_{vco}}{\phi_m}}$
   - 迴路頻寬：由於通常設計為過阻尼 ($\xi \ge 1$)，頻寬可近似為 $\omega_{BW} = 2\xi\omega_n$。
   $$ \omega_{BW,BB} = 2\pi f_{BW,BB} = 2 \left( \frac{R_p}{2}\sqrt{\frac{I_p C_p K_{vco}}{\phi_m}} \right) \left( \sqrt{\frac{I_p K_{vco}}{\phi_m C_p}} \right) = \frac{I_p R_p K_{vco}}{\phi_m} $$
   *(註：若使用 JTRAN 模擬分析 slew 效應，頻寬模型會引入係數變為 $\frac{2 I_p R_p K_{vco}}{\pi \phi_m}$)*

4. **Jitter Generation 計算公式**：
   將 VCO 的 $1/f^2$ 相位雜訊頻譜對此 HPF 進行積分，可得出 RMS 抖動的工程近似公式：
   $$ J_{rms,BB} \cong \frac{f_0}{2} \sqrt{\frac{S_{\phi,vco}(f_0)}{\pi f_{BW,BB}}} \text{ (UI)} $$
   *(其中 $f_0$ 為評估相位雜訊的參考偏移頻率)*

### 單位解析
**公式單位消去：**
- **迴路頻寬 $\omega_{BW,BB}$**：
  $$ \frac{I_p \times R_p \times K_{vco}}{\phi_m} \Rightarrow \frac{\text{[A]} \times \text{[V/A]} \times \text{[rad/(s} \cdot \text{V)]}}{\text{[rad]}} = \frac{\text{[V]} \times \text{[rad/(s} \cdot \text{V)]}}{\text{[rad]}} = \frac{\text{[rad/s]}}{\text{[rad]}} = \text{[1/s]} = \text{[rad/s]} $$
  （嚴格來說，$\omega$ 為角頻率，單位為 rad/s，物理量綱為 $1/s$，單位消去完美吻合）

這是一個非常經典、無數類比與射頻工程師（包含我菜鳥時期）都踩過的坑！你的推導在物理跟數學上**完全正確**，但它在工程直覺上隱藏著一個致命的「$2\pi$ 陷阱」。

**直接回答問題**
單位本身**沒有錯**。問題出在：**Radian（弧度）在物理學上是「無因次量」（Dimensionless, $[\text{rad}] = 1$）**。

因為弧度的定義是「弧長除以半徑」（$\frac{\text{m}}{\text{m}}$），所以它是一個純比例。在單位推導時，分子跟分母的 $[\text{rad}]$ 互消，得到 $[1/\text{s}]$ 是非常合理的。**真正的問題在於：這算出來的 $[1/\text{s}]$，到底是指 $\omega_{BW}$ (角頻率) 還是 $f_{BW}$ (一般頻率)？**

---

**物理意義與電路設計考量拆解**

讓我們用設計 BB-CDR (Bang-Bang CDR) 迴路頻寬的視角，把這個單位的來龍去脈拆解清楚：

**1. 為什麼 $[\text{rad}]$ 會不見？**
這條公式本質上是在算開迴路增益 $L(s) = K_{PD} \cdot R_p \cdot \frac{K_{vco}}{s}$ 等於 1 的地方。
* **$K_{PD, eq}$ (等效相位偵測器增益)：** $\frac{I_p}{\phi_m}$。意思是「每單位相位誤差 $[\text{rad}]$，Charge Pump 會打出多少電流 $[\text{A}]$」。單位是 $[\text{A/rad}]$。
* **$K_{vco}$ (壓控振盪器增益)：** 意思是「每單位控制電壓 $[\text{V}]$，能改變多少角頻率 $[\text{rad/s}]$」。單位是 $[\text{rad/(s}\cdot\text{V)}]$。
* **相乘的結果：** 當這兩者與濾波器電阻 $R_p$ 乘在一起，PD 分母的 $[\text{rad}]$ 與 VCO 分子的 $[\text{rad}]$ **互相抵銷了**。
    * $[\text{A/rad}] \times [\text{V/A}] \times [\text{rad/(s}\cdot\text{V)}] = [1/\text{s}]$

**2. 工程上的「死亡陷阱」**
算出 $[1/\text{s}]$ 後，很多工程師會直覺認為：「單位是 $1/\text{s}$，那就是 $\text{Hz}$，所以算出來的數字是 $f_{BW}$。」**大錯特錯！**

在控制系統中，積分器 $\frac{1}{s}$ 的 $s$ 是複變頻率 ($s = j\omega$)，它的隱含單位是角頻率 $[\text{rad/s}]$。當我們解 $|L(j\omega_{BW})| = 1$ 時：
$$\omega_{BW} = \frac{I_p \cdot R_p \cdot K_{vco}}{\phi_m}$$

因為等式左邊是 $\omega_{BW}$，算出來的這個數字本質上是**角頻率**。為了避免搞混，資深工程師在算出這個數值後，會**「手動把 $[\text{rad}]$ 貼回去」**，寫成 $[\text{rad/s}]$。

**3. 實務設計的 Rule of Thumb**
在做 SerDes 系統架構評估 (System Architecture) 時，客戶或標準（如 PCIe, USB）開出來的 Jitter Tolerance 頻寬規格，一律都是給 **$f_{BW}$ (單位 $\text{Hz}$)**。

如果你用上述公式算出了 $\omega_{BW}$ 卻忘了除以 $2\pi$，你會以為你的頻寬已經夠大了，但實際上你設計出來的 CDR 頻寬比預期**窄了整整 6.28 倍**！這會導致你的 CDR 根本追不上 Data 的 Jitter，眼圖直接閉合，晶片回來量測時就會動不起來。

**總結這筆記的單位糾結：**
你寫的 $[1/\text{s}] = [\text{rad/s}]$ 在物理因次上是絕對成立的。只要在心裡默念三遍：**「公式拆解出來的 $[1/\text{s}]$ 是 $\omega$ 不是 $f$，要對應系統規格必須再除以 $2\pi$」**，你就徹底跨過這個設計陷阱了。

這頁筆記非常精彩！它完美展示了如何將非線性的 Bang-Bang CDR (BB-CDR) 在特定條件下，簡化成可以用線性系統分析的模型。

既然你正在建構用來模擬 PLL/CDR 行為的 Web App，這段推導與單位的邏輯絕對是你底層程式碼的核心，變數一寫錯，模擬出來的抖動與眼圖就會完全失真。我們直接來拆解這張圖的推導邏輯，並解答你對單位的疑惑。

---

**第一部分：神之公式的推導教學**

筆記中 $\omega_{BW} = \frac{I_p \cdot R_p \cdot K_{vco}}{\phi_m}$ 是怎麼來的？

**核心假設：Bang-Bang PD 的「線性化」**
看圖片左邊的 $I_{av}$ 與 $\Delta\phi$ 關係圖。BB-CDR 的 Phase Detector 正常來說是「非線性」的（超過 $\phi_m$ 電流就飽和在 $I_p$）。
但筆記上寫了一個關鍵條件：`for extremely clear input, the loop operates at linear region`。
因為我們現在算的是 **Jitter Generation (JG)**，假設輸入端完全沒有雜訊 ($\phi_{in}=0$)，系統抖動很小（例如 $J_{rms} = 0.01\text{ UI}$），所以超過 99.9% 的相位誤差都會落在中間那個斜坡上。
因此，我們可以將 BBPD 視為一個**線性等效增益**：
$$K_{PD} = \text{斜率} = \frac{I_p}{\phi_m} \quad \text{[A/rad]}$$

**代入二階 PLL 標準公式**
將等效的 $K_{PD}$ 代入經典的 Charge-Pump PLL 二階參數公式中：
* **自然頻率 (Natural Frequency)：** $\omega_n = \sqrt{\frac{K_{PD} K_{vco}}{C_p}} = \sqrt{\frac{I_p K_{vco}}{\phi_m C_p}}$
* **阻尼係數 (Damping Factor)：** $\zeta = \frac{R_p}{2} \sqrt{K_{PD} K_{vco} C_p} = \frac{R_p}{2} \sqrt{\frac{I_p C_p K_{vco}}{\phi_m}}$

**頻寬近似推導**
在設計這類 CDR 時，為了確保穩定度，通常會設計成**過阻尼 (Over-damped, $\zeta \gg 1$)**。在 $\zeta$ 很大的情況下，系統的閉迴路頻寬 $\omega_{BW}$ 會由零點 (Zero) 主導，其近似值為 $2\zeta\omega_n$。
現在把上面的 $\zeta$ 和 $\omega_n$ 乘起來：
$$\omega_{BW} \approx 2\zeta\omega_n = 2 \cdot \left( \frac{R_p}{2} \sqrt{\frac{I_p C_p K_{vco}}{\phi_m}} \right) \cdot \left( \sqrt{\frac{I_p K_{vco}}{\phi_m C_p}} \right)$$
把括號拆開，根號內的 $C_p$ 互相消掉：
$$\omega_{BW} \approx R_p \cdot \frac{I_p K_{vco}}{\phi_m} = \mathbf{\frac{I_p \cdot R_p \cdot K_{vco}}{\phi_m}}$$
推導完成！

---

**第二部分：單位到底哪裡有問題？**

直接回答你：**你的單位消去過程，在「數學上」完全正確，沒有任何問題！**
$[A] \times [V/A] \times [\text{rad/(s}\cdot\text{V)}] / [\text{rad}] = [1/\text{s}]$。

**那為什麼我之前說這是個「陷阱」？**
問題出在物理因次 (Dimension) 的解讀。在國際單位制 (SI) 中，**「弧度 (rad)」和「週期 (cycle)」都是無因次量 (Dimensionless)**。這代表它們在方程式消去後，都會變成隱形的 `1`。

這就導致了工程上最容易出錯的盲點：
* 角頻率 $\omega$ 的單位是 $[\text{rad/s}]$，消掉 rad 後，因次是 $\mathbf{[1/\text{s}]}$。
* 頻率 $f$ 的單位是 $\text{Hz}$ 或 $[\text{cycles/s}]$，消掉 cycle 後，因次也是 $\mathbf{[1/\text{s}]}$。

這兩者的數學因次一模一樣，但在物理世界上差了 $2\pi$ 倍。

**實務上的風險：**
當你在程式碼裡寫下 `let bandwidth = (Ip * Rp * Kvco) / phi_m;`，系統算出來一個數值（例如 $6.28 \times 10^7$）。
因為你做過單位消去，心裡想著「單位是 $1/\text{s}$，那就是 $\text{Hz}$ 囉」，然後就把它當成 $62.8\text{ MHz}$ 的頻寬去跟系統規格 (Specification) 比對。
但實際上，因為公式源頭的 $K_{vco}$ 帶有 $[\text{rad}]$，這個算出來的數值其實是 $\omega_{BW}$ (角頻率)。真正的頻寬 $f_{BW}$ 只有 $10\text{ MHz}$！

**總結：**
你的消去法完全正確。但身為 IC 設計工程師，我們習慣在心裡強制把那個被消掉的 $[\text{rad}]$ 給「補回來」，寫成 $[\text{rad/s}]$。這不是為了滿足數學，而是為了保護自己不在驗證規格時，被那該死的 $2\pi$ 給衝康。盲點其實出在**「物理因次（Dimension）與工程單位（Unit）的混淆」**。

在國際單位制 (SI) 的底層邏輯裡，數學是不管「形狀」的。不論是「每秒轉多少**圈 (cycles)**」還是「每秒轉多少**弧度 (radians)**」，因為「圈」和「弧度」都是純粹的比例（無因次量），在數學消去後，它們統統都會變成 `[1/s]`。

你的盲點在於：**看到消去後剩下 `[1/s]`，大腦就自動把它跟 $\text{Hz}$ 畫上等號。** 要避免這個坑，在推導電路或寫 Web App 模擬器底層程式碼時，你必須在以下三個地方「提早修正」並建立防呆機制：

**提早修正點一：確認 $K_{vco}$ 的「出生證明」**
這是最常翻車的地方。當你拿到一顆 VCO，或者在模擬器裡宣告變數時，第一步就是搞清楚它的單位：
* **學術派 / 控制理論 (你筆記上的)：** $K_{vco}$ 定義為 $K_{vco,\omega}$，單位是 **$[\text{rad/(s}\cdot\text{V)}]$**。
    * 代入公式 $\frac{I_p R_p K_{vco}}{\phi_m}$ 算出來的結果是 **角頻率 $\omega_{BW}$**。
* **業界實務 / VCO Designer 給的 spec：** $K_{vco}$ 通常定義為 $K_{vco,f}$，單位是 **$[\text{Hz/V}]$** 或 **$[\text{MHz/V}]$**（因為沒有人量測時看示波器會去讀 rad/s）。
    * 這兩者的關係是：$K_{vco,\omega} = 2\pi \cdot K_{vco,f}$。

**提早修正點二：公式左邊 (LHS) 絕對不只寫 Bandwidth**
在筆記或黑板上推導時，嚴格區分變數名稱。
* 永遠不要只寫 $BW = \dots$
* 一定要明確寫出 $\omega_{BW} = \dots$ 或 $f_{BW} = \dots$

如果你的前提是使用學術派的 $K_{vco,\omega}$ $[\text{rad/(s}\cdot\text{V)}]$，那你的公式推導第一行就應該長這樣，把 $2\pi$ 的橋樑直接寫死：
$$f_{BW} = \frac{\omega_{BW}}{2\pi} = \mathbf{\frac{I_p \cdot R_p \cdot K_{vco,\omega}}{2\pi \cdot \phi_m}}$$
只要你一開始就把左邊定為 $f_{BW}$ 並補上 $2\pi$ 分母，後面代數字就絕對不會錯。

**提早修正點三：業界超好用的「單位直通捷徑」**
如果今天 VCO 設計師給你的規格是實務上的 $K_{vco,f} [\text{Hz/V}]$，你可以直接用一個超爽的捷徑。
把 $K_{vco,\omega} = 2\pi \cdot K_{vco,f}$ 代入剛才的公式：
$$f_{BW} = \frac{I_p \cdot R_p \cdot (2\pi \cdot K_{vco,f})}{2\pi \cdot \phi_m}$$
上下 $2\pi$ 完美消掉！
$$f_{BW} = \mathbf{\frac{I_p \cdot R_p \cdot K_{vco,f}}{\phi_m}}$$

**發現了嗎？** 只要你確認帶入的 $K_{vco}$ 是 $\text{Hz/V}$，算出來的數字**直接就是 $f_{BW} (\text{Hz})$**，完全不用再去除以 $2\pi$！

**總結你的 Action Item**
下次面試被問到或是自己在刻 Web App 的行為模型時，只要遇到 $K_{vco}$，先問自己（或面試官）一句：**「請問這裡的 $K_{vco}$ 單位是 $\text{rad/s/V}$ 還是 $\text{Hz/V}$？」**

* 如果是 $\text{rad/s/V}$ $\rightarrow$ 算出來是 $\omega_{BW}$，要轉 $\text{Hz}$ 記得**除以 $2\pi$**。
* 如果是 $\text{Hz/V}$ $\rightarrow$ 算出來直接就是 $f_{BW}$，**不用動**。

這句話問出來，不僅能提早避開計算盲點，更能展現你銜接「課本理論」與「業界實務」的 Senior 工程師直覺。

---

- **RMS Jitter $J_{rms,BB}$**（工程公式轉換）：
  等號右邊的根號內部為 $\frac{\text{[rad}^2\text{/Hz]}}{\text{[Hz]}} = \text{[rad}^2 \cdot \text{s}^2]$，開根號後為 $\text{[rad} \cdot \text{s]}$。乘上外面的頻率參數 $f_0 \text{ [1/s]}$ 後，得到 $\text{[rad]}$。公式中直接標註 (UI)，代表該工程公式已隱含了將弧度 (rad) 除以 $2\pi$ 轉換為 Unit Interval (UI) 的縮放常數。

**圖表單位推斷：**
📈 左上圖表 ($I_{av}$ vs $\Delta\phi$)：
- X 軸：相位誤差 $\Delta\phi \text{ [UI] 或 [rad]}$，典型範圍 $-\phi_m \sim +\phi_m$ (約 $\pm 0.03 \text{ UI}$)。
- Y 軸：平均充放電電流 $I_{av} \text{ [}\mu\text{A]}$，典型範圍 $\pm I_p$。

📈 右上圖表 ($S_{\phi,vco}$ vs $\omega$)：
- X 軸：偏移角頻率 $\omega \text{ [rad/s]}$（對數座標）。
- Y 軸：相位雜訊 PSD $S_{\phi,vco}(\omega) \text{ [rad}^2\text{/Hz]}$，呈現 $\propto 1/\omega^2$ 之斜率。

📈 下方圖表 (Phase Noise Profile $S_{\phi}(f)$ vs $f$)：
- X 軸：頻率 $f \text{ [Hz]}$（對數座標），典型範圍 100 kHz ~ 100 MHz。
- Y 軸：相位雜訊 $S_{\phi}(f) \text{ [dBc/Hz]}$ 或 $\text{[rad}^2\text{/Hz]}$，典型範圍 -80 ~ -120 dBc/Hz。
- 物理意義：展示 CDR 輸出 (ckout) 雜訊在 $f_{BW}$ 前面以 1:1 低通 (LPF) 跟隨輸入資料雜訊，在 $f_{BW}$ 後面以 1:1 高通 (HPF) 跟隨 VCO free-running 雜訊。

### 白話物理意義
當輸入訊號乾淨到幾乎沒有抖動時，BB-CDR 的相位追蹤會侷限在極小的線性微調區內；此時系統自己產生的抖動 (Jitter Generation) 幾乎全都是「VCO 本身在高頻抑制不掉的雜訊」所貢獻的。

### 生活化比喻
想像你是一個司機（CDR），開著一台引擎有點震動的車（VCO）跟著前面的引導車（Input Data）。如果引導車開得非常平穩（Clean input），你幾乎不需要猛打方向盤，只會在車道內極小幅度地微調方向（操作在線性區）。這時候，車子整體的晃動感（Jitter Generation），主要就是來自你這台車本身的引擎震動（VCO phase noise），而不是因為你跟錯車。

### 面試必考點
1. **問題：在量測 BB-CDR 的 Jitter Generation (J_G) 時，為何可以用線性 PLL 模型來分析？** 
   → 答案：因為量測 J_G 時會給予一個極度乾淨 (Jitter-free) 的輸入訊號。此時系統的相位誤差變異數極小，高達 99.9% 的時間都落在 BB-PD 狹窄的線性區間內，因此非線性行為被弱化，可視為線性系統。
2. **問題：BB-CDR 操作在線性區時，J_G 的主要雜訊貢獻來源是哪個 Block？為什麼？** 
   → 答案：是 VCO。因為輸入端乾淨且誤差小，PD/CP 貢獻的雜訊可忽略；而 VCO 的雜訊透過 High-Pass Filter 轉移函數傳遞到輸出端，頻寬外的低頻雜訊被壓抑，但高頻雜訊會直接漏到輸出端成為 J_G。
3. **問題：要如何從系統層級降低 CDR 的 Jitter Generation？** 
   → 答案：根據公式 $J_{rms} \propto 1/\sqrt{f_{BW}}$，可以透過增加迴路頻寬 ($f_{BW,BB}$) 來擴大 HPF 對 VCO 雜訊的抑制範圍；或者直接採用 Phase noise 更優良的 VCO ($S_{\phi,vco}$ 較小)。

**記憶口訣：**「輸入乾淨跑線性，雜訊全看 V C O，頻寬越寬壓越低。」
