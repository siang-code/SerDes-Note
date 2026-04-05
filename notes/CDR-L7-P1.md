# CDR-L7-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L7-P1.jpg

---


---
## [Purely Linear Phase Detector (Mixer-Based PD)]

### 數學推導
這份筆記的核心在於證明 **Mixer-based PD 如何自然實現 Tri-state (三態) 行為**，而不需要像傳統數位 PD 那樣依賴複雜的邏輯閘來產生 UP/DOWN 脈波。

我們將訊號分為兩種情況探討：
**假設條件：**
*   時脈訊號 (Clock)： $V_{ck}(t) = B \cos(\omega t + \theta)$，其中 $\theta$ 為時脈相位。
*   XOR 輸出訊號 $V_{XOR}(t)$：將數位方波以其基頻諧波近似。

**情境一：資料有轉態 (Data Transition Occurs)**
當資料發生轉態時，XOR 閘會輸出一個脈波。我們取其基頻成分：
$V_{XOR}(t) \approx A \cos(\omega t + \tau)$，其中 $\tau$ 為資料邊緣的相位。
Mixer (混頻器/乘法器) 將兩者相乘：
$$V_{mixer}(t) = V_{XOR}(t) \times V_{ck}(t)$$
$$V_{mixer}(t) = [A \cos(\omega t + \tau)] \times [B \cos(\omega t + \theta)]$$
根據積化和差公式 $\cos(x)\cos(y) = \frac{1}{2}[\cos(x-y) + \cos(x+y)]$，展開得到：
$$V_{mixer}(t) = \frac{AB}{2} [\cos(\tau - \theta) + \cos(2\omega t + \tau + \theta)]$$
*推導結論：* 這裡包含了低頻的相位差資訊 $\frac{AB}{2}\cos(\tau - \theta)$，以及高頻的兩倍頻訊號 $\cos(2\omega t + \dots)$。筆記中明確寫到高頻項會被 "Removed by LPF" (迴路濾波器濾除)，因此進入 VCO 的控制電壓僅剩正比於相位差的直流成分。

**情境二：資料無轉態 (Long Run / No Transition)**
當資料連續為 1 或連續為 0 時，XOR 輸出保持在低電位（或常數負值）：
$V_{XOR}(t) = -A$
進入 Mixer 相乘：
$$V_{mixer}(t) = (-A) \times [B \cos(\omega t + \theta)]$$
$$V_{mixer}(t) = -AB \cos(\omega t + \theta)$$
*推導結論：* 此時 Mixer 的輸出是一個純高頻的交流訊號。當這個訊號經過低通濾波器 (LPF) 時，弦波的平均值 (DC 值) 為 **0**。這代表沒有淨電流充放電，完美且「自然地」等效於 Charge Pump 的 **Tri-state (高阻抗態)**，迴路電壓維持不變，VCO 頻率不飄移！

---

### 單位解析

**公式單位消去：**
1.  **Mixer 乘法運算：** Mixer 實際上是一個類比乘法器 (例如 Gilbert Cell)，具有轉換增益 $K_m$。
    *   $V_{mixer} = K_m \cdot V_{XOR} \cdot V_{ck}$
    *   $[V] = [V^{-1}] \cdot [V] \cdot [V]$ (等式成立，Mixer 輸出為電壓)
2.  **V/I Converter (Charge Pump 等效)：** 將電壓轉為電流充放電。
    *   $I_p = g_m \cdot V_{mixer}$
    *   $[A] = [A/V] \cdot [V]$ (等式成立，輸出為電流)
3.  **整體 PD Gain ($K_{PD}$)：** 描述相位差如何轉換為平均電流。
    *   $\overline{I_p} = K_{PD} \cdot \Delta\phi$
    *   $[A] = [A/rad] \cdot [rad]$ (等式成立，這是迴路頻寬計算的核心參數)

**圖表單位推斷：**
📈 **圖表一：左上角波形圖 (Waveforms)**
*   **X 軸**：時間 $t$ $[ps]$ 或 $[UI]$。典型範圍：對於 10Gbps 訊號，1 UI ($T_b$) = 100 ps。
*   **Y 軸**：電壓振幅 $[V]$ 或 $[mV]$。典型範圍：CML (Current Mode Logic) 準位約 $300 \sim 400 mV_{pp}$。

📈 **圖表二：中下方 PD Characteristic (相位偵測特性曲線)**
*   **X 軸**：輸入相位差 $\Delta\phi = \tau - \theta$ $[rad]$ 或 $[UI]$。典型範圍：$-\pi$ 到 $+\pi$ (即 -0.5 UI 到 +0.5 UI)。
*   **Y 軸**：平均輸出電壓 $\overline{V_{mixer}}$ $[V]$ 或平均電流 $\overline{I_p}$ $[A]$。

📈 **圖表三：右下方 Hogge vs Purely Linear 比較圖**
*   **X 軸**：資料傳輸率 Data Rate $[Gbps]$。典型範圍：$1 Gbps \sim 100+ Gbps$。
*   **Y 軸**：等效 PD 增益 (PD Gain, $K_{PD}$) $[A/rad]$。
    *   *觀察：* Hogge PD 曲線在高頻率時大幅衰減，而 Purely Linear 曲線維持平坦，這正是 Mixer-based 架構在先進製程/高速 SerDes 中被廣泛採用的主因。

---

### 白話物理意義
Mixer-based PD 放棄了傳統「產生數位脈衝來比對寬度」的做法，直接把「資料邊緣的波形」跟「時脈波形」像混音器一樣相乘；有轉態時乘出直流電壓推動迴路，遇到連續 0 或 1 的 Long Run 時，乘出來的純交流電平均為零，自帶「沒訊號就不動作」的完美防護罩。

---

### 生活化比喻
想像一個「聲控旋轉門」。傳統數位 PD (Hogge) 像是警衛，聽到腳步聲（資料邊緣）就要立刻按兩下碼錶，算時間差再來推門，如果人走太快（Data Rate 太高），警衛按碼錶的手速會跟不上，門就推不準。
Mixer-based PD 則像是直接把門連上一個「共振麥克風」。有腳步聲（轉態）時，聲音頻率跟門的旋轉頻率產生共振推力（Mixer 相乘）；如果沒人走過去（Long Run），麥克風只收到門自己轉動的風切聲，正負抵消後沒有淨推力（DC 為 0），門就維持原本的速度繼續轉，完全不需要警衛按碼錶！

---

### 面試必考點

1.  **問題：為什麼在 >28Gbps 的超高速 SerDes 中，設計師通常偏好 Mixer-based PD 而非 Hogge PD？ (對應右下角圖表)**
    *   **答案：** Hogge PD 依賴 Flip-Flop 產生 proportional 和 reference pulses，高頻時邏輯閘的 setup/hold time 限制與 RC 延遲會導致脈波變形 (Pulse shrinking/swallowing)，使得 PD Gain 嚴重下降甚至失效。Mixer-based PD 是純類比訊號相乘，不涉及窄脈衝產生與比較，頻寬由類比節點決定，因此在極高 Data Rate 下仍能維持線性的 PD Gain。
2.  **問題：在 Mixer-based PD 中，當遇到連續多個 0 或 1 (Long Run) 時，迴路會發生什麼事？它需要額外的 Tri-state 控制電路嗎？**
    *   **答案：** 不需要。當發生 Long Run 時，XOR 輸出為常數直流 (例如負值)。這個常數乘上 Clock 的弦波後，Mixer 輸出會是一個純交流的 Clock 頻率訊號。經過 Loop Filter 積分後，平均電壓/電流為零。這「天然地」實現了等效的 Tri-state 行為，VCO 的控制電壓不會被拉動，維持當下頻率。
3.  **問題：筆記中前端有 $V_A \rightarrow \text{Buffer} \rightarrow V_C \rightarrow \text{Buffer} \rightarrow V_E$，最後 $V_A$ 和 $V_E$ 進 XOR。這個 Delay 鏈的作用是什麼？若 Delay 太短或太長會怎樣？**
    *   **答案：** 這個 Delay 決定了 XOR 輸出的脈波寬度（即基頻成分的能量大小）。
        *   **太短：** XOR 輸出的脈波能量太弱（基頻振幅 $A$ 太小），會導致 Mixer 轉換出來的 PD Gain 不足，迴路頻寬變小，Jitter tracking 能力變差。
        *   **太長：** 脈波寬度超過半個 UI，會干擾到下一個 bit 的偵測，產生嚴重的 Intersymbol Interference (ISI)，破壞線性度。

**記憶口訣：**
> **「混頻線性免脈波，長跑零均穩 VCO，高速不衰選這坨！」**
> (Mixer 線性相乘不需脈波產生，遇到 Long Run 輸出平均為零穩定 VCO，高速 Data Rate 下增益不衰減就選這個架構。)
