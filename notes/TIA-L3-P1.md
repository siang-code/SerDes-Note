# TIA-L3-P1

> 分析日期：2026-04-04
> 原始圖片：images/TIA-L3-P1.jpg

---

同學，看來你正在複習 TIA（Transimpedance Amplifier）最核心的觀念：**等效輸入雜訊 (Input-Referred Noise)** 以及 **散粒雜訊 (Shot Noise)**。在高速 SerDes 的前端設計中，TIA 的雜訊直接決定了整個接收器 (RX) 的靈敏度 (Sensitivity)。光有高頻寬是不夠的，如果雜訊太大，訊號一進來就被淹沒了。

仔細看你的筆記，你已經抓到了將輸出雜訊推回輸入端的核心定義，以及 PD (Photo Diode) 先天雜訊的物理極限。以下是針對你這頁筆記的嚴格解析，請務必把單位消去法和物理意義刻在腦海裡！

---
## [TIA Input-Referred Noise & Photodiode Shot Noise]

### 數學推導
在寬頻 (Broadband) 高速電路中，雜訊不是單一頻率，而是分佈在整個頻譜上的。我們必須積分整個頻寬內的雜訊功率。

1. **輸出雜訊功率 (Total Output Noise Power)：**
   TIA 輸出的電壓雜訊頻譜密度 (PSD) 為 $\overline{V_{n,out}^2}(f)$。為了得到總輸出雜訊功率，我們必須對整個頻譜積分：
   $$ \text{Total } V_{n,out}^2 = \int_0^\infty \overline{V_{n,out}^2}(f) df $$
   *(說明：這代表經過 TIA 頻寬限制（Low-pass 特性）後的實際總輸出雜訊總量。)*

2. **等效輸入雜訊功率 (Input-Referred Noise Power, $\overline{I_{n,in}^2}$)：**
   我們希望知道「如果 TIA 本身是完美的（無雜訊），那相當於要在輸入端灌入多少雜訊電流，才會在輸出端產生一模一樣的雜訊總量？」
   由於實際的轉阻增益 $R_T(f)$ 會隨頻率下降（如你筆記左圖），業界標準做法是統一除以 **「直流或中頻段的轉阻增益平方 ($R_{T,DC}^2$)」** 來做基準換算：
   $$ \overline{I_{n,in}^2} \triangleq \frac{\int_0^\infty \overline{V_{n,out}^2} df}{R_{T,DC}^2} $$

3. **等效輸入雜訊均方根電流 (RMS Noise Current, $I_{n,rms}$)：**
   功率開根號，還原成真實世界可以直觀感受的電流值：
   $$ I_{n,rms} = \sqrt{\overline{I_{n,in}^2}} $$
   *(說明：這是評估光接收器靈敏度 (Sensitivity) 的最重要指標，通常要求在幾個 $\mu A$ 甚至 $nA$ 等級。)*

4. **光電二極體散粒雜訊 (Photodiode Shot Noise)：**
   $$ \overline{I_n^2} \triangleq 2 \cdot q \cdot I_{DC} $$
   *(說明：光電流 $I$ 是由一顆顆離散的電子 ($q$) 構成，這種量子化特性會產生無法避免的散粒雜訊，且頻譜是平坦的 (White Noise)。正如你筆記所寫，這是「RX 無法控制」的先天物理極限。)*

### 單位解析

**公式單位消去：**
- **等效輸入雜訊功率 $\overline{I_{n,in}^2}$：**
  - 分子積分項：$\int \overline{V_{n,out}^2} df \Rightarrow \left[ \frac{V^2}{Hz} \right] \times [Hz] = [V^2]$
  - 分母轉阻平方：$R_{T,DC}^2 \Rightarrow [\Omega^2] = \left[ \frac{V}{A} \right]^2 = \left[ \frac{V^2}{A^2} \right]$
  - 兩者相除：$\frac{[V^2]}{[V^2/A^2]} = \mathbf{[A^2]}$ (雜訊電流平方)
- **等效輸入 RMS 電流 $I_{n,rms}$：**
  - $\sqrt{[A^2]} = \mathbf{[A]}$ (通常為 $\mu A_{rms}$)
- **散粒雜訊 PSD $\overline{I_n^2}$：**
  - $q$ (基本電荷量) 單位為庫倫 $[C] = [A \cdot s]$
  - $I$ (直流電流) 單位為 $[A]$
  - $2 \cdot q \cdot I \Rightarrow [A \cdot s] \times [A] = [A^2 \cdot s] = \mathbf{\left[ \frac{A^2}{Hz} \right]}$ (電流雜訊頻譜密度)

**圖表單位推斷：**
📈 **圖表單位推斷：**
- **左圖 (轉阻增益 $R_T$ vs 頻率 $f$)：**
  - X 軸：頻率 [Hz]，典型範圍 DC ~ 50 GHz (視 SerDes 規格而定)
  - Y 軸：轉阻增益 $R_T$ [$\Omega$]，典型範圍 $50\Omega \sim 5k\Omega$
- **中圖 (輸出雜訊 PSD $\overline{V_{n,out}^2}$ vs 頻率 $f$)：**
  - X 軸：頻率 [Hz]，典型範圍 DC ~ 50 GHz
  - Y 軸：電壓雜訊頻譜密度 [$V^2/Hz$]，典型範圍 $10^{-18} \sim 10^{-15} V^2/Hz$
- **下圖 (雜訊頻譜分佈示意圖)：**
  - X 軸：頻率 [Hz]，覆蓋整個 Nyquist bandwidth
  - Y 軸：雜訊功率頻譜密度 [$A^2/Hz$] (紅線代表平坦的 Shot/Thermal Noise floor，下方波形代表訊號主頻帶分佈)

### 白話物理意義
**「等效輸入雜訊就是照妖鏡，把電路後端所有亂七八糟的雜訊，全部折算成『如果電路很完美，那到底是多髒的輸入訊號造成的』，以此來公平評估 TIA 的好壞。」**

### 生活化比喻
想像 TIA 是一台「濾水器」(放大器)，水(訊號)經過後流出來。你想知道這台濾水器本身到底會不會「掉鐵鏽」(產生內部雜訊)。
你測量流出來的水有多髒 (Total Output Noise $\int \overline{V_{n,out}^2} df$)，然後除以濾水器的「基礎水流量」(DC Gain $R_{T,DC}$)，藉此反推：「如果濾水器本身不掉鐵鏽，那這水質相當於進水口被倒了多少克灰塵？」
那個「反推的灰塵量」就是 Input-Referred Noise。而 Shot Noise 則是水源裡本來就自帶的微生物（量子效應），濾水器設計得再好也無法消除它 (RX無法控制)。

### 面試必考點
1. **問題：在計算 Input-Referred Noise 時，為什麼分母是除以 $R_{T,DC}^2$，而不是除以隨頻率變化的 $R_T(f)^2$？**
   → **答案：** 因為我們需要一個「單一的等效數值」來跟輸入端的原始直流/中頻訊號電流（Peak-to-Peak 電流）做直接比較，以計算 SNR。如果除以 $R_T(f)^2$，在超高頻時 $R_T$ 趨近於零，會導致等效輸入雜訊在數學上暴增至無限大，但實際上那些高頻訊號早已被濾除，這樣算沒有工程意義。
2. **問題：Photo Diode 的 Shot Noise 來源是什麼？接收端 (RX) 設計者能用電路技巧消除它嗎？**
   → **答案：** 來源是光電流由離散的電子組成（電荷量子化 $q$），造成統計上的電流波動。RX 設計者**無法消除它**（正如筆記所寫），這是系統靈敏度的終極物理極限。只能盡量降低 TIA 本身的 Thermal Noise 去逼近這個極限。
3. **問題：TIA 為了降低 Input-Referred Noise，第一級通常會怎麼設計？**
   → **答案：** 通常會盡量增大回授電阻 ($R_F$) 或轉阻增益，因為熱雜訊電流的 PSD 與 $4kT/R_F$ 成正比。$R_F$ 越大，其貢獻的等效輸入雜訊電流反而越小（雖然輸出電壓雜訊變大，但除以 $R_F^2$ 折算回輸入端後變小了）。不過這會面臨頻寬下降的 Trade-off。

**記憶口訣：**
**「等效輸入看直流 (除以 $R_{T,DC}$)，面積開根求電流 (積分開根號)，散粒天生無從救 (RX 無法控制)！」**

---
*TA 費曼測試警告：同學，你如果覺得你懂了，請告訴我：「如果今天是一顆 112Gbps PAM4 的 TIA，Nyquist 頻率高達 28GHz，在積分高頻雜訊時，如果你不小心用了 $R_T(f)^2$ 當分母，你的 SNR 預估會發生什麼災難？」想清楚再回答！*
