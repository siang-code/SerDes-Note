# CDR-L13-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L13-P1.jpg

---


---
## All-Digital PLL based CDR (全數位鎖相迴路時脈資料回復電路)

### 數學推導
本頁筆記的核心在於將傳統的「類比連續時間 PLL」對應到「全數位離散時間 PLL (ADPLL)」，並證明在取樣頻率夠高時，兩者的數學行為是一致的。

1.  **Analog Phase Transfer Function (類比相移轉移函數):**
    由 Bang-Bang PD (電流 $\pm I_p$)、RC Loop Filter (電阻 $R_p$, 電容 $C_p$) 及 VCO (增益 $K_{vco}$) 組成。
    Charge pump 電流經過 Loop filter 的阻抗轉換成控制電壓，再由 VCO 積分成輸出相位 $\phi_{out}$：
    $$\phi_{out} = \pm I_p \cdot \left( R_p + \frac{1}{s C_p} \right) \cdot \frac{K_{vco}}{s}$$

2.  **Digital Phase Transfer Function (數位 z-domain 模型):**
    在 ADPLL 中，使用數位乘法器與累加器取代 RC 濾波器：
    *   數位 BBPD 輸出數位邏輯值，例如 $\pm \frac{1}{2}$。
    *   Digital Loop Filter (DLF) 包含比例路徑 (Proportional path, 增益 $k_1$) 與積分路徑 (Integral path, 增益 $k_2$ 加上 z-domain 累加器 $\frac{1}{1-z^{-1}}$)。
    *   DCO (Digital Controlled Oscillator) 根據數位控制碼輸出頻率/相位，包含積分項 $\frac{K_{dco}}{s}$。
    原始的混合 (z 與 s) 方程式為：
    $$\phi_{out} = \pm \frac{1}{2} \cdot \left( k_1 + \frac{k_2}{1 - z^{-1}} \right) \cdot \frac{K_{dco}}{s}$$

3.  **Z-domain 到 S-domain 的連續時間近似 (Continuous-time approximation):**
    令 $T_{DLF}$ 為數位濾波器的取樣週期 ($T_{DLF} = 1/f_{DLF}$)。利用 $z = e^{sT_{DLF}}$，當訊號頻率 (即 Loop Bandwidth) 遠低於取樣頻率時，我們有 $sT_{DLF} \ll 1$。
    使用泰勒展開式近似：
    $$1 - z^{-1} = 1 - e^{-sT_{DLF}} \approx 1 - (1 - sT_{DLF}) = sT_{DLF}$$
    將此近似代入方程式，將離散系統化為連續時間系統：
    $$\phi_{out} \approx \pm \frac{1}{2} \cdot \left( k_1 + \frac{k_2}{s T_{DLF}} \right) \cdot \frac{K_{dco}}{s}$$

4.  **類比與數位參數對照 (Analog-to-Digital Mapping):**
    對比首尾兩式，可以得到硬體設計上的完美對應關係：
    *   Charge Pump 電流 $I_p \iff$ 數位步進值 $1/2$
    *   等效電阻 $R_p \iff$ 比例增益 $k_1$
    *   等效電容的倒數 $\frac{1}{C_p} \iff \frac{k_2}{T_{DLF}} = k_2 \cdot f_{DLF}$
    *   VCO 增益 $K_{vco} \iff$ DCO 增益 $K_{dco}$
    筆記中特別註明「此東西實際上遠大於 loop bandwidth」，意思是指取樣頻率 $f_{DLF}$ 必須夠快，上述的連續時間近似才會成立，系統才不會因為過大的離散時間延遲 (Phase delay) 而不穩定。

### 單位解析
**公式單位消去：**
*   **Analog 方程式:** $\phi_{out} = \pm I_p \left( R_p + \frac{1}{s C_p} \right) \frac{K_{vco}}{s}$
    *   $I_p$: $[A]$ (Ampere)
    *   $\left( R_p + \frac{1}{s C_p} \right)$: 阻抗 $\rightarrow [\Omega] = [V/A]$
    *   $K_{vco}$: VCO 增益 $\rightarrow [rad/s/V]$
    *   $1/s$: 積分項 $\rightarrow [s]$
    *   單位消去：$[A] \times [V/A] \times [rad/s/V] \times [s] = [rad]$ (相位單位)
*   **Digital 近似方程式:** $\phi_{out} \approx \pm \frac{1}{2} \left( k_1 + \frac{k_2}{s T_{DLF}} \right) \frac{K_{dco}}{s}$
    *   $\pm \frac{1}{2}$: 數位 BBPD 輸出 $\rightarrow [LSB]$ (數位最小位元，代表階數)
    *   $k_1, k_2$: 數位乘法器增益 $\rightarrow [1]$ (無因次)
    *   $s$: 頻率 $\rightarrow [1/s]$
    *   $T_{DLF}$: 取樣週期 $\rightarrow [s]$
    *   $K_{dco}$: DCO 增益 $\rightarrow [rad/s/LSB]$
    *   $1/s$: 積分項 $\rightarrow [s]$
    *   單位消去：$[LSB] \times \left( [1] + \frac{[1]}{[1/s] \times [s]} \right) \times [rad/s/LSB] \times [s] = [LSB] \times [1] \times [rad/s/LSB] \times [s] = [rad]$ (相位單位)

**圖表單位推斷：**
1.  📈 **Analog BBPD 轉移曲線 ($I_{av}$ vs $\Delta\phi$):**
    *   X 軸：相位誤差 $\Delta\phi$ [UI]，典型範圍 -1 到 +1 UI
    *   Y 軸：平均輸出電流 $I_{av}$ [μA]，典型範圍 $\pm 50$ μA
2.  📈 **Analog VCO 轉移曲線 ($\omega_{vco}$ vs $V_{ctrl}$):**
    *   X 軸：控制電壓 $V_{ctrl}$ [V]，典型範圍 0~1.2 V
    *   Y 軸：振盪頻率 $\omega_{vco}$ [GHz] 或 [rad/s]，典型範圍 5~10 GHz
3.  📈 **Digital BBPD 轉移曲線 ($N_{av}$ vs $\Delta\phi$):**
    *   X 軸：相位誤差 $\Delta\phi$ [UI]，典型範圍 -1 到 +1 UI
    *   Y 軸：平均數位輸出碼 $N_{av}$ [LSB]，典型範圍 $\pm 0.5$ 或 $\pm 1$ LSB
4.  📈 **DCO 轉移曲線 ($\omega_{dco}$ vs $N_{ctrl}$):**
    *   X 軸：數位控制碼 $N_{ctrl}$ [LSB] (整數)，典型範圍 0~1023 (10-bit DCO)
    *   Y 軸：振盪頻率 $\omega_{dco}$ [GHz]，呈現離散階梯狀，每階高度為解析度 $\Delta K_{dco}$ [MHz/LSB]

### 白話物理意義
把傳統類比 PLL 裡用來儲存電壓的「大電容」和放電的「電阻」，直接換成電腦裡的「加法器」和「乘法器」。只要電腦算得夠快（取樣頻率遠大於迴路頻寬），它調控 DCO 頻率的行為，看起來就跟連續的類比電路一模一樣。

### 生活化比喻
**類比 PLL 就像用「水龍頭與水桶」控制水位的抽水馬達：** 偵測器發現水位低，就打開水龍頭加水 (Charge Pump $I_p$)，水流過濾網和水桶 (RC Loop Filter) 變成平穩的水壓 ($V_{ctrl}$)，去無段變速地控制馬達轉速 (VCO)。
**全數位 PLL 就像用「電腦與步進馬達」：** 偵測器告訴電腦「太慢了」，電腦立刻算出來「+1」這個數字 (Digital Loop Filter)，傳給步進馬達 (DCO) 說「把轉速往上切一檔」。只要電腦一秒鐘算幾千萬次 (高 $f_{DLF}$)，步進馬達轉起來就像無段變速一樣順暢。

### 面試必考點
1.  **問題：為什麼在先進製程 (如 5nm/3nm) 的高速 CDR 中，越來越傾向使用 All-Digital PLL (ADPLL) 而非傳統 Analog PLL？**
    *   **答案：** (1) **製程微縮友善：** 先進製程的 Supply Voltage (VDD) 極低，類比 Charge Pump 的 Voltage Headroom 嚴重受限，難以維持高輸出阻抗與線性度；而 ADPLL 主要是數位邏輯，能完美享受製程微縮帶來的面積與功耗紅利。(2) **完美抗漏電：** 數位 Loop Filter 把相位誤差存在 Register 裡，不會像類比電容有漏電流 (Leakage) 導致 Ripple。(3) **彈性高：** 迴路參數 (k1, k2) 可以透過軟體即時調整，方便做 PVT 校準與自適應 (Adaptive) 頻寬控制。
2.  **問題：在筆記的推導中，什麼情況下 ADPLL 的連續時間近似模型 ($1-z^{-1} \approx sT_{DLF}$) 會失效？失效會造成什麼後果？**
    *   **答案：** 當迴路頻寬 (Loop Bandwidth) 接近數位濾波器的取樣頻率 ($f_{DLF}$) 時（通常大於 $1/10 \sim 1/20$ $f_{DLF}$），近似就會失效。此時離散時間系統特有的「運算延遲 (Latency)」與「零階保持器 (ZOH) 效應」會吃掉大量的 Phase Margin，導致系統不穩定（Jitter Peaking 變大，甚至震盪），這時必須改用 Z-domain 來進行精確的穩定度分析。
3.  **問題：DCO 的頻率解析度 ($\Delta K_{dco}$，即每個 LSB 對應的頻率變化) 粗細，對 CDR 系統的 Jitter 有什麼影響？**
    *   **答案：** DCO 解析度直接決定了**量化雜訊 (Quantization Noise)** 造成的 Dither Jitter。因為 DCO 頻率只能呈階梯狀變化，無法「完美」鎖定在一個小數頻率上，導致穩態時 DCO 控制碼會在相鄰兩個值之間來回跳動 (Limit Cycle)。$\Delta K_{dco}$ 越大（解析度越差），頻率跳動的幅度就越大，累積出來的輸出 Phase Jitter 就越大。

**記憶口訣：**
**數位代類比，k1替電阻，k2替電容，只要算得快，離散變連續。**
