# PLL-L37-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L37-P1.jpg

---


---
## MASH $\Sigma-\Delta$ Modulator 與 Noise Transfer Function (NTF)

### 數學推導
這頁筆記的核心在推導 MASH (Multi-stAge noise SHaping) 架構如何透過「級聯 (Cascade)」與「數位消除邏輯 (Digital Cancellation Logic)」來提升雜訊整型的階數，同時保持系統絕對穩定。

**1. 2nd-Order MASH (1-1) 消除邏輯推導：**
假設我們使用最標準的線性模型來分析：
*   **第一級 (Stage 1)：** 輸出為輸入信號加上一次整型後的量化誤差。
    $Y_1(z) = X(z) + (1-z^{-1})Q_1(z)$
*   **第二級 (Stage 2)：** 我們將第一級的**量化誤差 $Q_1$** 作為第二級的輸入（實務上通常是提取第一級量化器輸入與輸出的差值再反相，即輸入為 $-Q_1$）。
    $Y_2(z) = -Q_1(z) + (1-z^{-1})Q_2(z)$
*   **數位消除邏輯 (Cancellation Logic)：** 為了消掉 $Q_1(z)$，我們對 $Y_2$ 乘上 $(1-z^{-1})$ 並與 $Y_1$ 相加：
    $Y_{out}(z) = Y_1(z) + (1-z^{-1})Y_2(z)$
    $Y_{out}(z) = [X(z) + (1-z^{-1})Q_1(z)] + (1-z^{-1})[-Q_1(z) + (1-z^{-1})Q_2(z)]$
    $Y_{out}(z) = X(z) + (1-z^{-1})Q_1(z) - (1-z^{-1})Q_1(z) + (1-z^{-1})^2 Q_2(z)$
    $Y_{out}(z) = X(z) + (1-z^{-1})^2 Q_2(z)$
*(註：筆記中寫作 $Y = X - (1-Z^{-1})^2 Q_2$，其正負號差異僅取決於第二級量化誤差 $Q$ 的定義方式（是 Input-Output 還是 Output-Input），物理意義上均代表二階雜訊整型。)*

**2. NTF (Noise Transfer Function) 頻率響應推導：**
對於 m 階的 $\Sigma-\Delta$ 調變器，其 NTF 為 $(1-z^{-1})^m$。我們將 $z = e^{j\omega T}$ 代入來求其大小（Magnitude）：
*   $NTF(z) = (1-z^{-1})^m = (1 - e^{-j\omega T})^m$
*   利用尤拉公式與半角技巧提出 $e^{-j\omega T / 2}$：
    $1 - e^{-j\omega T} = e^{-j\omega T / 2} \left( e^{j\omega T / 2} - e^{-j\omega T / 2} \right)$
*   根據正弦函數定義 $\sin(\theta) = \frac{e^{j\theta} - e^{-j\theta}}{2j}$：
    $e^{j\omega T / 2} - e^{-j\omega T / 2} = 2j \cdot \sin\left(\frac{\omega T}{2}\right)$
*   代回原式並取絕對值（Magnitude）：
    $|NTF(e^{j\omega T})| = \left| e^{-j\omega T / 2} \cdot 2j \cdot \sin\left(\frac{\omega T}{2}\right) \right|^m$
    因為 $|e^{-j\omega T / 2}| = 1$ 且 $|2j| = 2$：
    $|NTF| = \left[ 2\sin\left(\frac{\omega T}{2}\right) \right]^m$

這就是筆記中寫下 `NTF: 擋雜訊的能力` 的數學根本來源。

### 單位解析
**公式單位消去：**
在此數位信號處理域中，信號多為無因次（Dimensionless）或以 LSB 為單位。
我們來看角頻率與取樣週期的乘積 $\omega T$：
*   $\omega$ 單位為 [rad/s]
*   $T$ 單位為 [s] (取樣週期)
*   $\omega T$ = [rad/s] × [s] = [rad]
正弦函數 $\sin()$ 的輸入必須是角度或弧度 [rad]，輸出為無因次 [unitless]。因此 $|NTF|$ 本身是一個無因次的增益倍數（Gain multiplier）。

**圖表單位推斷：**
📈 關於筆記下方的 NTF 頻率響應圖表：
*   **X 軸：** 歸一化角頻率 $\omega T$ [rad] 或 歸一化頻率 $f/f_s$ [無因次]。筆記標示了 $\pi/T$ 對應到 $0.5$（此處 $0.5$ 意指 $0.5 f_s$，即 Nyquist frequency）。典型範圍為 $0$ 到 $\pi$ (rad) 或 $0$ 到 $0.5$ ($f_s$)。
*   **Y 軸：** 雜訊轉移函數大小 $|NTF|$ [無因次]，即雜訊增益。筆記標示了 2, 4, 8，這對應到當頻率達到最高（$\omega T = \pi, \sin(\pi/2)=1$）時，m 階 NTF 的最大峰值 $2^m$。1階為 2，2階為 4，3階為 8。

### 白話物理意義
MASH 架構就像「接力掃地」，第一個人掃過留下細微灰塵，第二個人專門去掃那層灰塵；階數越高，低頻（我們在意的區域）掃得越乾淨，但代價是把所有垃圾都堆到高頻區（圖中往上翹的地方），等著交給 PLL 的低通濾波器去丟掉。

### 生活化比喻
想像一個三道工序的淨水器（3rd-Order MASH）。
第一道粗濾網（1st Order）濾掉大顆粒，但漏了泥沙；它把濾出的水和「泥沙情報」傳給下一站。
第二道細濾網專門針對「泥沙情報」過濾，但又漏了微生物。
第三道超濾網專門針對「微生物」過濾。
最後我們把這三道處理過的水用巧妙的方式混在一起（Cancellation Logic），得到極度純淨的飲用水（低頻低雜訊）。而那些被擋下來的髒東西，全部被高壓馬達沖到廢水管（高頻雜訊放大），只要我們最後用一個塞子（PLL Loop Filter）把廢水管堵住不讓它流進杯子就好。

### 面試必考點
1. **問題：既然要高階雜訊整型，為什麼不直接做一個單一迴路的 3 階 $\Sigma-\Delta$ Modulator，而要用 MASH 1-1-1 級聯？**
   → 答案：**穩定度問題。** 傳統大迴路高階（≥3階）$\Sigma-\Delta$ Modulator 容易因為內部信號擺幅過大而飽和，導致系統不穩定（Unstable）。MASH 由多個 1 階系統級聯，1階系統是**絕對穩定**的，因此 MASH 在獲得高階整型能力的同時，完美避開了穩定度風險。
2. **問題：圖中 $|NTF|$ 曲線「往上翹」代表什麼代價？這在 PLL 系統中如何解決？**
   → 答案：代表**高頻雜訊放大（High-frequency Noise Peaking）**。階數 $m$ 越高，高頻處的最大增益 $2^m$ 越大（3階高達 8 倍）。在 Fractional-N PLL 中，這個被推到高頻的量化雜訊必須依靠 PLL 本身的**閉迴路低通濾波特性（Loop Filter）**來濾除，否則會嚴重惡化 Phase Noise。這也是筆記寫「但在 PLL 頻寬外 $\Rightarrow$ 沒事」的原因。
3. **問題：MASH 架構最大的致命傷（缺點）是什麼？**
   → 答案：**對 Mismatch（不匹配）極度敏感，會導致雜訊洩漏（Noise Leakage）。** 數位消除邏輯 $(1-z^{-1})$ 完美預設了前級的類比傳遞函數也是精準的 $1$ 或 $z^{-1}$。如果類比電路（如 OP-AMP 增益不足、電容不匹配）導致實際傳遞函數有偏差，前級的量化雜訊 $Q_1$ 就無法被完美相消，會直接「漏」到輸出端，使得低頻雜訊大幅上升，破壞高階整型效果。

**記憶口訣：** MASH 三字訣 —— **「階、翹、漏」** (階數高靠級聯保穩定、高頻翹起需 LPF、類比不配會漏雜訊)
