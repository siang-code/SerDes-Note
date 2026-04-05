# CDR-L26-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L26-P1.jpg

---


---
## Jitter Tolerance (JTOL) 與 Linear CDR 抖動容忍度分析

### 數學推導
**目標：從 CDR 的追蹤誤差定義推導出 JTOL 的轉移函數。**

1. **誤差定義（Error Condition）：** 
   在 CDR 系統中， Clock 會在資料眼圖（Eye Diagram）的中心進行取樣。一個理想的眼圖寬度是 1 UI（Unit Interval）。如果輸入資料的相位（$\phi_{in}$）與 CDR 輸出的 Clock 相位（$\phi_{out}$）偏差超過半個眼圖寬度（$0.5$ UI），取樣點就會落在轉換區，產生誤碼（Bit Error）。
   $$|\phi_{in} - \phi_{out}| \ge 0.5 \text{ UI}$$

2. **引入 Jitter Transfer (JTRAN)：**
   CDR 的輸出相位是輸入相位經過系統轉移函數 JTRAN 濾波後的結果，即 $\phi_{out} = \text{JTRAN}(s) \cdot \phi_{in}$。代入上式：
   $$|\phi_{in} - \text{JTRAN}(s) \cdot \phi_{in}| \ge 0.5 \text{ UI}$$
   提出 $\phi_{in}$：
   $$|\phi_{in}| \cdot |1 - \text{JTRAN}(s)| \ge 0.5 \text{ UI}$$

3. **JTOL 的定義（Jitter Tolerance）：**
   JTOL 被定義為在不產生額外誤碼（無 BER penalty）的前提下，系統所能容忍的「最大輸入相位變異量（$\phi_{in, max}$）」。將等式改寫：
   $$JTOL \triangleq \phi_{in, max} = \frac{0.5}{|1 - \text{JTRAN}(s)|}$$
   *(註：$1 - \text{JTRAN}(s)$ 即為 Error Transfer Function, $E(s)$)*

4. **代入一階近似的 CDR 模型：**
   對於一個高阻尼（over-damped, $\zeta$ 較大）的二階 PLL/CDR，系統可以近似為一階模型，其閉迴路頻寬 $\omega_{-3dB} \approx 2\zeta\omega_n$。
   對應的 $\text{JTRAN}(s) \approx \frac{2\zeta\omega_n}{s + 2\zeta\omega_n}$。
   那麼誤差函數 $1 - \text{JTRAN}(s) = 1 - \frac{2\zeta\omega_n}{s + 2\zeta\omega_n} = \frac{s}{s + 2\zeta\omega_n}$。
   將其代入 JTOL 公式：
   $$JTOL = \frac{0.5}{\left| \frac{s}{s + 2\zeta\omega_n} \right|} = \frac{0.5 \cdot |s + 2\zeta\omega_n|}{|s|}$$

5. **頻率響應極值分析：**
   - **高頻時（$s = j\omega \rightarrow \infty$）：** $JTOL \approx \frac{0.5 \cdot \omega}{\omega} = 0.5 \text{ UI}$。
   - **低頻時（$s = j\omega \rightarrow 0$）：** $JTOL \approx \frac{0.5 \cdot 2\zeta\omega_n}{\omega}$。這表示 JTOL 隨著頻率降低而增加，呈現 $-20\text{ dB/dec}$ 的斜率（圖中標示）。

### 單位解析
**公式單位消去：**
1. **Error Phase** = $|\phi_{in} - \phi_{out}|$ = $[\text{UI}] - [\text{UI}] = [\text{UI}]$
2. **JTOL** = $\frac{0.5}{|1 - \text{JTRAN}|}$
   - $0.5$ 為眼圖半寬，單位為 $[\text{UI}]$
   - $\text{JTRAN}$ 為 $\frac{\phi_{out}}{\phi_{in}}$，單位為 $[\text{UI}] / [\text{UI}] = [\text{無單位}]$
   - 結果：$[\text{UI}] / [\text{無單位}] = [\text{UI}]$
3. **Loop Bandwidth $\omega_{-3dB}$** = $\frac{I_p \cdot R_p \cdot K_{vco}}{2\pi}$
   - 這裡筆記的寫法混用了 $\omega$ (rad/s) 與 $f$ (Hz)。嚴格來說，若計算頻率 $f_{-3dB}$，公式為：
   - $I_p$ (Charge Pump Current) = $[\text{A}]$
   - $R_p$ (Loop Filter Resistor) = $[\Omega] = [\text{V/A}]$
   - $K_{vco}$ (VCO Gain) = $[\text{Hz/V}]$
   - 相乘：$[\text{A}] \times [\text{V/A}] \times [\text{Hz/V}] = [\text{Hz}]$。若要換算成角頻率 $\omega_{-3dB}$ $[\text{rad/s}]$，則不應除以 $2\pi$（除非 $K_{vco}$ 的單位原本定義為 rad/s/V，此處需特別注意教授或業界的慣用表示法）。

**圖表單位推斷：**
1. **JTOL(U.I.) vs. $\omega$ 圖：**
   - X 軸：Jitter Modulation Frequency $\omega$ $[\text{rad/s}]$（對數尺度）。
   - Y 軸：Jitter Tolerance Amplitude $[\text{UI}]$（對數尺度）。高頻漸近線為 $0.5$ UI。
2. **JTRAN vs. $\omega$ 圖：**
   - X 軸：Jitter Modulation Frequency $\omega$ $[\text{rad/s}]$（對數尺度）。轉折頻率在 $\omega_{-3dB} = 2\zeta\omega_n$。
   - Y 軸：Magnitude $[\text{dB}]$。低頻平坦區為 $0$ dB，高頻以 $-20\text{ dB/dec}$ 下降。
3. **OC-192 mask 圖：**
   - X 軸：Jitter freq. Modulation freq. $[\text{Hz}]$。表格中 $f_1$ 到 $f_4$ 分別為 $2\text{ kHz}, 20\text{ kHz}, 400\text{ kHz}, 4\text{ MHz}$。
   - Y 軸：JTOL 容忍度 $[\text{UI}]$。對應的規範值為 $15\text{ UI}, 1.5\text{ UI}, 0.15\text{ UI}$。

### 白話物理意義
**Jitter Tolerance (JTOL)** 就是系統「眼睛（Clock）能跟著目標（Data）晃動」的最大極限，晃動太快或幅度太大超過這極限，取樣點就會偏離中心超過半個眼睛寬度，導致你看錯資料（Bit Error）。

### 生活化比喻
想像你在非常顛簸的高鐵上（輸入資料充滿抖動 $\phi_{in}$）用手機看文章（Clock 取樣資料）。
- **JTRAN (追隨能力)**：你的手和脖子能跟著車廂晃動的程度。車子晃得慢，你完全跟得上（JTRAN $= 1$）；車子震得快，你根本來不及反應（JTRAN $\approx 0$）。
- **JTOL (容忍度)**：如果晃動很快（高頻），手機只能在螢幕大小範圍內晃（$0.5$ UI），超過你就會看錯字。但如果晃動很慢（低頻），就算手機晃動幅度超過 $10$ 公尺（> $1$ UI），只要你的身體能完美跟著同步移動，你依然看得很清楚！這就是為什麼低頻的 JTOL 容忍度可以無限大。

### 面試必考點
1. **問題：為什麼 JTOL 的頻率響應在高頻段會收斂到一條水平線（通常是 0.5 UI）？**
   - **答案：** 因為高頻 Jitter 變動太快，超出了 CDR 迴路頻寬（Loop Bandwidth）的追蹤能力，此時 $1 - \text{JTRAN} \approx 1$（CDR 輸出的 clock 相對是靜止的）。因此系統能容忍的最大相位變異，就僅剩下眼圖本身左右各一半的寬度（即理想狀態下的 $0.5$ UI）。

2. **問題：如果系統高頻的 JTOL fail，可以透過調大 CDR 頻寬來解決嗎？**
   - **答案：** **不行！** 調整 CDR 頻寬只能改變轉折頻率（將 $-20\text{ dB/dec}$ 的斜線往右推），無法提升高頻的極限值。高頻 JTOL 的極限受限於眼圖的本質品質（如 ISI 或 Random Jitter 吃掉了 margin）。要改善高頻 JTOL，必須優化前端的 Equalizer (CTLE/DFE) 來把眼圖打開。

3. **問題：在規範（如圖中 OC-192 Mask）中，通常哪一個頻率區段的 JTOL 測試最容易 Fail？（筆記標示「最難」）**
   - **答案：** Mask 的高頻轉折點（圖中標示 $f_4$ 的位置）。因為在這個頻率點附近，CDR 的追隨能力已經開始下降（甚至可能有 Peaking 導致追蹤誤差放大），但規格依然要求一個大於理想極限（例如 $0.15$ UI 或更嚴格）的容忍度。

**記憶口訣：**
**「低頻跟著晃，高頻吃眼眶」**（低頻靠 CDR 迴路頻寬追蹤大抖動，高頻 CDR 失效，只能靠眼圖本身的 0.5 UI 寬度硬扛）。
