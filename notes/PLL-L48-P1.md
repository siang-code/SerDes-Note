# PLL-L48-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L48-P1.jpg

---


---
## [TDC架構與DCO電容陣列設計]

### 數學推導
**1. Oscillator-based TDC (振盪器型時間數位轉換器) 量化誤差推導**
在筆記中的「Osc. Based」區塊，利用一個週期為 $T$ 的振盪器來量測兩個訊號（Clkdiv 與 Ckref）的相位差（時間差 $\Delta t$）。
- 假設真實時間差為 $\Delta t$，振盪器週期為 $T_{osc} = T$。
- 計數器 (Counter) 量測到的數值為 $N = \lfloor \frac{\Delta t}{T} \rfloor$ （取高斯下斯、整數部分）。
- 量測到的等效時間為 $t_{meas} = N \cdot T$。
- **量化誤差 (Quantization Error)** 定義為：$e_q = \Delta t - t_{meas}$。
- 因為是計數整數個週期，所以未被計數到的殘餘時間必定落在 $0$ 到 $T$ 之間。我們假設相位差與振盪器相位是無關的，因此 $e_q$ 是一個**均勻分佈 (Uniform Distribution)**。
- 機率密度函數 (PDF) 為：$f(x) = \frac{1}{T}$，其中 $0 \le x < T$。
- 誤差平均值 (Mean)：
  $\mu = \int_{0}^{T} x \cdot f(x) dx = \int_{0}^{T} x \cdot \frac{1}{T} dx = \frac{1}{T} [\frac{1}{2}x^2]_{0}^{T} = \frac{T}{2}$
- 誤差變異數 (Variance, 即 AC noise power)：
  $\sigma^2 = \int_{0}^{T} (x - \mu)^2 \cdot f(x) dx = \int_{0}^{T} (x - \frac{T}{2})^2 \cdot \frac{1}{T} dx = \frac{1}{T} [\frac{1}{3}(x - \frac{T}{2})^3]_{0}^{T} = \frac{1}{3T} ( (\frac{T}{2})^3 - (-\frac{T}{2})^3 ) = \frac{1}{3T} ( \frac{T^3}{8} + \frac{T^3}{8} ) = \frac{T^2}{12}$
- 量化雜訊有效值 (RMS jitter)：$\sigma_{rms} = \frac{T}{\sqrt{12}}$。這是 DPLL 中 TDC 貢獻的 In-band Phase Noise 的基礎！

**2. DCO 頻率調變推導 (LC-Tank)**
- LC 振盪器頻率公式：$f_{osc} = \frac{1}{2\pi\sqrt{L \cdot C_{total}}}$
- 總電容 $C_{total} = C_{fixed} + C_{tune}$，其中 $C_{tune}$ 由開關控制。
- 當我們切換一個最小電容單位 $\Delta C$ 時，頻率的變化量 $\Delta f$（即 DCO 的解析度 $K_{DCO}$）可由對 $C$ 偏微分得到：
  $\frac{\partial f_{osc}}{\partial C} = \frac{1}{2\pi\sqrt{L}} \cdot (-\frac{1}{2})C_{total}^{-3/2} = -\frac{1}{2} \cdot \frac{1}{2\pi\sqrt{L\cdot C_{total}}} \cdot \frac{1}{C_{total}} = -\frac{1}{2} \cdot \frac{f_{osc}}{C_{total}}$
- 故頻率步進：$\Delta f \approx -\frac{1}{2} f_{osc} \frac{\Delta C}{C_{total}}$ （負號代表電容增加，頻率下降）。

### 單位解析
**公式單位消去：**
- 量化雜訊 RMS 值：$\sigma_{rms} = \frac{T}{\sqrt{12}}$
  - $[s] = \frac{[s]}{[-]}$ (常數 $\sqrt{12}$ 無單位，等式成立)
- DCO 頻率步進：$\Delta f = -\frac{1}{2} f_{osc} \frac{\Delta C}{C_{total}}$
  - $[Hz] = [-] \times [Hz] \times \frac{[F]}{[F]} = [Hz]$ (電容單位法拉相消，等式成立)
- PDF 機率密度函數積分：$\int_{0}^{T} f(x) dx = 1$
  - $[s] \times [\frac{1}{s}] = [-]$ (機率的總和為 1，無因次，等式成立)

**圖表單位推斷：**
📈 波形圖 (Clkdiv, Ckref, Osc)：
- X 軸：時間 [ps] 或 [ns]，典型範圍取決於參考頻率，例如 50MHz Ref clock 週期為 20ns。
- Y 軸：電壓 [V]，典型範圍為 0 ~ VDD (例如 0 ~ 0.9V)。
📈 量化誤差機率密度函數 $f(x)$ 圖：
- X 軸：殘餘時間差 [ps]，典型範圍 0 ~ 振盪器週期 $T$ (例如 0 ~ 100ps)。
- Y 軸：機率密度 [1/ps]，高度為 $1/T$。

### 白話物理意義
- **Osc-TDC**：用一把刻度是固定的尺（內部高頻振盪器）去量測一段不固定的長度（相位差），量不到的零頭就是量化誤差，這誤差永遠小於尺上的一格。
- **DCO 開關擺放位置**：把電容陣列的開關放在靠近地端（Bottom），是為了避免開關的寄生電容直接感受到 LC Tank 巨大的電壓擺幅，從而降低非線性（AM-PM conversion）並維持較高的 Q 值。

### 生活化比喻
- **Osc-TDC**：想像你用一個「一秒滴答一次的碼表」去計時百米賽跑。如果選手跑了 10.4 秒，你的碼表只能按出 10 秒。那漏掉的 0.4 秒就是你的「量測極限」，而這個極限最大不會超過你碼表的一滴答（1 秒）。要量得更準（Two-step），你得找另一個能計算 0.1 秒的微型碼表來量那個剩下的 0.4 秒。
- **DCO 開關位置**：想像一個高壓水塔（LC Tank）連著水管。你想用水龍頭（MOS 開關）控制水管裡的儲水量（電容）。如果你把水龍頭裝在靠近水塔的高壓端，水龍頭的墊片（寄生電容）會一直承受高低起伏的巨大水壓，容易變形且漏水（非線性與能量損耗）。如果你把水龍頭裝在水管最底部的出水口（接地端），那邊水壓極低且穩定，水龍頭就能精準控制且不易損壞。

### 面試必考點
1. **問題：筆記中特別標註「為何開關擺下面？不擺上面？」，請問在 LC DCO 設計中，Switch 放在接地面與放在 Tank 面的差異為何？**
   - 答案：放在上面（Tank 端）會讓 MOS 開關的 Source/Drain 直接看入振盪器的巨大電壓擺幅。MOS 開關的寄生電容（$C_{gs}, C_{gd}, C_{db}$）是具備高度電壓相依性的（Voltage-dependent）。當大訊號擺動時，這些寄生電容會跟著變化，導致嚴重的 AM-to-FM 雜訊轉換（振幅雜訊轉相噪），並降低 Tank Q 值。放在下面（接地端），開關的一端是固定的 AC Ground，另一端在開關導通時也被拉到接近地電位，電壓擺幅極小，寄生電容效應變為線性且穩定。
2. **問題：在設計 DCO 的 Cap Array 時，為何要同時使用 Binary 與 Thermometer 兩種編碼架構？（筆記右下角圖示）**
   - 答案：這是一種 Trade-off。**Binary Array** ($1C, 2C, 4C, 8C$) 能用最少的控制位元（Bits）覆蓋最大的電容調變範圍（Tuning Range），但它在進位時（例如 $0111 \rightarrow 1000$）容易產生巨大的 DNL (Differential Non-Linearity) 和 Glitch 導致頻率跳躍。**Thermometer Array** ($1C, 1C, 1C, 1C$) 確保了嚴格的單調性（Monotonicity），每次切換步進相同，DNL 極佳，但需要龐大的解碼器（Decoder）和繞線面積。因此通常採用 Segmented 架構：MSB（Coarse tune）使用 Binary 或 Thermometer，而關鍵的 LSB（Fine tune）一定使用 Thermometer 以保證 DPLL 鎖定時的線性度與低雜訊。
3. **問題：Oscillator-based TDC 的解析度極限是什麼？筆記左方的 "Two-step" 架構是如何解決這個問題的？**
   - 答案：Osc-based TDC 的解析度（LSB）受限於量測用振盪器的「最小週期」（或是 Ring oscillator 的單級 Inverter delay）。這通常卡在製程極限，無法無限縮小。**Two-step TDC** 就像是用兩把尺：第一步用粗刻度的尺（Coarse TDC，例如 Osc-based）量測大部分的時間差；第二步將量剩的「殘餘時間（Residue time）」透過 Time Amplifier 放大，或是丟給另一組極高解析度但量測範圍小的 Vernier TDC（Fine TDC）去量測。這樣就能同時兼顧「大量測範圍（Large Range）」與「高解析度（High Resolution）」。

**記憶口訣：**
- **DCO 開關：** 「高壓危險放下面，寄生電容不作怪。」（High-swing 避開 MOS junction）
- **Cap Array 分工：** 「Binary 拚範圍，溫度計（Thermometer）保線性。」
- **TDC 兩步走：** 「粗細搭配，先切大塊再磨細微。」
