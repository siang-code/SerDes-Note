# PLL-L45-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L45-P1.jpg

---


---
## ADPLL 數位濾波器與轉移函數 (ADPLL Digital Filter & Transfer Function)

### 數學推導
這張筆記的核心在於證明：**在取樣頻率夠高的情況下，全數位鎖相迴路 (ADPLL) 的連續時間近似行為，與傳統類比電荷泵鎖相迴路 (CPPLL) 完全相同。**

**Step 1: 建立數位濾波器的 Z 轉換轉移函數**
由方塊圖可知，數位濾波器分為比例 (Proportional) 與積分 (Integral) 雙路徑：
- 比例路徑增益：$k_1$
- 積分路徑包含一個累加器 (Accumulator)，其迴路包含一個延遲單元 $z^{-1}$。累加器的轉移函數為 $\frac{1}{1 - z^{-1}}$，加上積分增益 $k_2$，此路徑為 $\frac{k_2}{1 - z^{-1}}$。
- 總和輸出：$H_d(z) = \frac{N_{out}}{N_{in}}(z) = k_1 + \frac{k_2}{1 - z^{-1}}$

**Step 2: 離散到連續時間的對應近似 (sT ≪ 1)**
將 Z 轉換映射到 S 轉換：$z = e^{sT}$，其中 $T$ 為參考頻率的週期 ($T = 1/f_{ref}$)。
當迴路頻寬遠小於參考頻率時（通常設計為 $< 1/10 f_{ref}$），亦即 $|sT| \ll 1$，我們可以使用泰勒展開式取一階近似：
$$z^{-1} = e^{-sT} \approx 1 - sT$$
將此近似代回濾波器公式：
$$H_d(s) \approx k_1 + \frac{k_2}{1 - (1 - sT)} = k_1 + \frac{k_2}{sT}$$
這證明了數位 PI 控制器在低頻下，等效於一個帶有零點的連續時間積分器。對比類比 RC 濾波器的阻抗 $Z(s) = R + \frac{1}{sC}$，我們可以發現明確的物理對應關係：$k_1 \leftrightarrow R$，$k_2/T \leftrightarrow 1/C$。

**Step 3: 建立 ADPLL 閉迴路轉移函數**
根據筆記中的迴路方程式（注意圖中的 $k_{DCO}$ 我這裡統稱，指 DCO 增益）：
$$\frac{(\phi_{in} - \frac{\phi_{out}}{M})}{2\pi} \cdot N_p \cdot \left(k_1 + \frac{k_2}{sT}\right) \cdot \frac{k_{DCO}}{s} = \phi_{out}$$
我們將 $\phi_{out}$ 整理到等式同一邊，解出閉迴路轉移函數 $H(s) = \frac{\phi_{out}}{\phi_{in}}$：
$$\phi_{out} \left[ 1 + \frac{N_p \cdot k_{DCO}}{2\pi \cdot M \cdot s} \left( \frac{k_1 sT + k_2}{sT} \right) \right] = \phi_{in} \left[ \frac{N_p \cdot k_{DCO}}{2\pi \cdot s} \left( \frac{k_1 sT + k_2}{sT} \right) \right]$$
分子分母同乘 $2\pi M s^2 T$：
$$H(s) = \frac{\phi_{out}}{\phi_{in}} = M \frac{N_p k_{DCO} k_1 T s + N_p k_{DCO} k_2}{2\pi M T s^2 + N_p k_{DCO} k_1 T s + N_p k_{DCO} k_2}$$
分子分母再同除以 $2\pi M T$，整理成標準的二階系統形式 $\frac{M(2\zeta\omega_n s + \omega_n^2)}{s^2 + 2\zeta\omega_n s + \omega_n^2}$：
$$H(s) = M \frac{ \left(\frac{N_p k_{DCO} k_1}{2\pi M}\right)s + \left(\frac{N_p k_{DCO} k_2}{2\pi M T}\right) }{ s^2 + \left(\frac{N_p k_{DCO} k_1}{2\pi M}\right)s + \left(\frac{N_p k_{DCO} k_2}{2\pi M T}\right) }$$

**Step 4: 萃取自然頻率 ($\omega_n$) 與阻尼因子 ($\zeta$)**
比較係數可得：
$$\omega_n^2 = \frac{N_p \cdot k_{DCO} \cdot k_2}{2\pi \cdot M \cdot T} \implies \omega_n = \sqrt{\frac{N_p \cdot k_2 \cdot k_{DCO}}{2\pi \cdot T \cdot M}}$$
$$2\zeta\omega_n = \frac{N_p \cdot k_{DCO} \cdot k_1}{2\pi \cdot M} \implies \zeta = \frac{N_p k_{DCO} k_1}{4\pi M \omega_n} = \frac{k_1}{2} \sqrt{\frac{N_p \cdot T \cdot k_{DCO}}{2\pi \cdot k_2 \cdot M}}$$
完全吻合筆記推導。

### 單位解析
身為工程師，公式推出來如果單位不對就是垃圾。我們來嚴格檢驗自然頻率 $\omega_n$ 的單位。

**變數物理量定義：**
- $\phi_{in}, \phi_{out}$: 相位，單位 $[ \text{rad} ]$
- $2\pi$: 一圈的弧度，單位 $[ \text{rad/cycle} ]$
- $N_p$: 數位鑑相器 (TDC) 增益。輸入是週期誤差，輸出是數位碼。單位 $[ \text{LSB/cycle} ]$
- $k_1, k_2$: 數位濾波器乘法係數，無因次，單位 $[1]$
- $T$: 取樣週期，單位 $[ \text{s} ]$
- $M$: 除頻比，無因次，單位 $[1]$
- $k_{DCO}$: 數位控制振盪器增益。輸入是數位碼，輸出是角頻率。單位 $[ \text{rad/s} / \text{LSB} ]$

**公式單位消去：自然頻率 $\omega_n$**
$$\omega_n = \sqrt{\frac{N_p \cdot k_2 \cdot k_{DCO}}{2\pi \cdot T \cdot M}}$$
將單位代入：
$$\text{Unit of } \omega_n = \sqrt{ \frac{ [ \text{LSB}/\text{cycle} ] \cdot [1] \cdot [ \text{rad/s} / \text{LSB} ] }{ [ \text{rad}/\text{cycle} ] \cdot [\text{s}] \cdot [1] } }$$
分子消去 LSB，分母整理：
$$= \sqrt{ \frac{ \text{rad} / (\text{cycle} \cdot \text{s}) }{ \text{rad} \cdot \text{s} / \text{cycle} } }$$
$$= \sqrt{ \frac{1}{\text{s}^2} } = \left[ \frac{\text{rad}}{\text{s}} \right]$$
完美符合角頻率的物理單位！這證明了推導過程中沒有漏掉任何 $2\pi$ 轉換。

**圖表單位推斷：**
本頁無圖表，但有等效電路圖：
- 類比濾波器中的 $V_{ctrl}$ 單位為 $[ \text{V} ]$，$I$ 單位為 $[ \text{A} ]$。
- 對應到數位濾波器，$N_{out}$ 為數位控制碼 $[ \text{LSB} ]$，$N_{in}$ 為鑑相誤差 $[ \text{LSB} ]$。這再次說明了數位與類比信號在系統模型中的對偶性。

### 白話物理意義
只要 ADPLL 的運作速度（取樣率 $1/T$）遠快於它追蹤相位變化的速度（迴路頻寬 $\omega_n$），這套數位系統在數學上的表現就跟傳統類比 PLL 毫無二致，唯一的差別只在於 TDC 帶來的量化底噪 (Quantization Noise)。

### 生活化比喻
想像你在開車（追蹤參考頻率）。
傳統 **Analog PLL** 就像「無段變速油門」，你根據與前車的距離，平滑、連續地調整踩油門的深度。
**ADPLL** 就像「數位段數油門」（比如只有 0~100 階），而且你每隔 $T$ 秒才睜開眼睛看一次前車距離（取樣）。
只要你「睜眼頻率極高（$sT \ll 1$）」，而且「油門段數切得很細（量化誤差小）」，坐在車裡的乘客（系統響應）根本感覺不出你是連續踩油門還是數位踩油門，車子一樣能穩定地跟在別人後面。

### 面試必考點
1. **問題：在設計 ADPLL 時，什麼情況下你可以直接套用傳統類比 Type-II PLL 的 $\omega_n$ 與 $\zeta$ 公式來設計？**
   → 答案：當「連續時間近似」成立時。亦即迴路頻寬必須遠小於參考頻率（通常 $\omega_n < \frac{1}{10} \frac{2\pi}{T}$），此時 $e^{-sT} \approx 1 - sT$ 成立，離散的 Z 域極點行為會退化成 S 域的積分行為。
2. **問題：請說明 ADPLL 數位濾波器中的 $k_1, k_2$ 參數，分別對應到傳統 Charge Pump PLL 迴路濾波器中的哪個實體元件？**
   → 答案：$k_1$（Proportional gain）對應到電阻 $R$（決定零點與阻尼因子）；$k_2$（Integral gain，配合累加器）對應到電容 $C$ 的倒數（決定積分強度與自然頻率）。
3. **問題：既然 ADPLL 與 Analog PLL 在系統動態上幾乎一樣，那為何現在先進製程都要轉向 ADPLL？筆記最下方紅字提到的 "major difference" 會造成什麼影響？**
   → 答案：先進製程電壓微縮，類比 VCO 的 tuning range 與 Charge Pump 的 headroom 受到嚴重擠壓，且漏電嚴重（漏電會改變電容上的 $V_{ctrl}$）。ADPLL 變數皆為數位訊號不受漏電影響，且面積可隨製程縮小。但紅字指出最大的代價是 TDC Quantization Noise，這個數位化的「階梯誤差」會經過迴路被高通濾波到輸出，成為 ADPLL In-band phase noise 的主要貢獻者，必須藉由提高 TDC 解析度或使用 $\Delta\Sigma$ 調變技術來壓抑。

**記憶口訣：**
「**高頻取樣近似連續，k1 扮電阻 k2 當電容，動態完全一樣，只差量化底噪。**」
