# PLL-L12-P1

> 分析日期：2026-04-04
> 原始圖片：images/PLL-L12-P1.jpg

---

---
## Charge-Pump PLL 連續時間模型與穩定度分析 (Loop Model and Behavior)

### 數學推導
這頁筆記的核心在於證明**為什麼 Type-II PLL 必須要有電阻 $R_p$ 才能穩定**，並推導其二階系統參數。我們分兩步來推導：

**1. 系統不穩定情況：只有電容 $C_p$ (無 $R_p$)**
此時迴路濾波器轉移函數為 $Z(s) = \frac{1}{sC_p}$。我們將前向路徑（Forward Path）的增益相乘得到開迴路增益 $G(s)$：
$$G(s) = \underbrace{\left(\frac{I_p}{2\pi}\right)}_{\text{PFD+CP}} \cdot \underbrace{\left(\frac{1}{sC_p}\right)}_{\text{Filter}} \cdot \underbrace{\left(\frac{K_{vco}}{s}\right)}_{\text{VCO}}$$
閉迴路轉移函數（假設沒有除頻器，M=1）：
$$H(s) = \frac{\phi_{out}}{\phi_{in}} = \frac{G(s)}{1 + G(s)} = \frac{\frac{I_p K_{vco}}{2\pi C_p s^2}}{1 + \frac{I_p K_{vco}}{2\pi C_p s^2}} = \frac{\frac{I_p K_{vco}}{2\pi C_p}}{s^2 + \frac{I_p K_{vco}}{2\pi C_p}}$$
**結果分析**：特徵方程式為 $s^2 + \frac{I_p K_{vco}}{2\pi C_p} = 0$，解出兩個極點 $s_{1,2} = \pm j\sqrt{\frac{I_p K_{vco}}{2\pi C_p}}$。這兩個極點剛好落在 s-plane 的虛數軸（$j\omega$ 軸）上。**物理意義上，這是一個純振盪器，系統完全不穩定 (Unstable)。**

**2. 系統穩定情況：加入電阻 $R_p$ 與除頻器 $M$**
加入電阻後，濾波器變成 Proportional-Integral (PI) 架構，$Z(s) = R_p + \frac{1}{sC_p} = \frac{sR_pC_p + 1}{sC_p}$。這引進了一個 Zero。
開迴路增益 $G(s) = \left(\frac{I_p}{2\pi}\right) \cdot \left(R_p + \frac{1}{sC_p}\right) \cdot \left(\frac{K_{vco}}{s}\right) = \frac{I_p K_{vco}}{2\pi} \frac{sR_pC_p + 1}{s^2 C_p}$
回授係數 $\beta = \frac{1}{M}$（筆記提到「週期拉長兩倍，相位變成一半」，除頻器本質上也是相位的除法器）。
閉迴路轉移函數推導：
$$H(s) = \frac{G(s)}{1 + \frac{G(s)}{M}}$$
將 $G(s)$ 代入，並將分子分母同乘以 $M \cdot s^2 C_p$ 來化簡：
$$H(s) = \frac{M \cdot \frac{I_p K_{vco}}{2\pi} (sR_pC_p + 1)}{M s^2 C_p + \frac{I_p K_{vco}}{2\pi} (sR_pC_p + 1)}$$
分子分母同除以 $M \cdot C_p$，並將分子提出 $M$ 以符合標準式：
$$H(s) = \frac{M \left[ \frac{I_p K_{vco} R_p}{2\pi M} s + \frac{I_p K_{vco}}{2\pi M C_p} \right]}{s^2 + \frac{I_p K_{vco} R_p}{2\pi M} s + \frac{I_p K_{vco}}{2\pi M C_p}}$$
比對經典控制理論的二階系統標準式 $H(s) = \frac{M(2\zeta\omega_n s + \omega_n^2)}{s^2 + 2\zeta\omega_n s + \omega_n^2}$，可提取出關鍵參數：
*   **自然頻率 (Natural Frequency)**: $\omega_n^2 = \frac{I_p K_{vco}}{2\pi M C_p} \implies \mathbf{\omega_n = \sqrt{\frac{I_p K_{vco}}{2\pi M C_p}}}$
*   **阻尼係數 (Damping Factor)**: $2\zeta\omega_n = \frac{I_p K_{vco} R_p}{2\pi M}$
    $\implies \zeta = \frac{I_p K_{vco} R_p}{4\pi M} \cdot \frac{1}{\omega_n} = \frac{I_p K_{vco} R_p}{4\pi M} \sqrt{\frac{2\pi M C_p}{I_p K_{vco}}} \implies \mathbf{\zeta = \frac{R_p}{2} \sqrt{\frac{I_p K_{vco} C_p}{2\pi M}}}$
**結果分析**：極點變為 $s_{1,2} = (-\zeta \pm \sqrt{\zeta^2 - 1})\omega_n$。只要 $\zeta > 0$（亦即 $R_p > 0$），極點的實部就是負的，全落在左半平面 (LHP)，系統終於**穩定 (Stable)**。

### 單位解析
**公式單位消去：**
這裡我們嚴格驗證 $\omega_n$ 的單位是否為角頻率 $[\text{rad/s}]$：
*   $I_p$ (Charge Pump 電流): $[\text{A}]$
*   $K_{vco}$ (VCO 增益，輸入電壓轉輸出角頻率): $[\text{rad} \cdot \text{s}^{-1} \cdot \text{V}^{-1}]$
*   $2\pi$ (相位單位): $[\text{rad}]$
*   $M$ (除頻比): 無因次 $[1]$
*   $C_p$ (電容): $[\text{F}] = [\text{Coulomb} \cdot \text{V}^{-1}] = [\text{A} \cdot \text{s} \cdot \text{V}^{-1}]$

將單位代入 $\omega_n = \sqrt{ \frac{I_p \cdot K_{vco}}{2\pi \cdot M \cdot C_p} }$：
$$\omega_n = \sqrt{ \frac{[\text{A}] \cdot [\text{rad} \cdot \text{s}^{-1} \cdot \text{V}^{-1}]}{[\text{rad}] \cdot [1] \cdot [\text{A} \cdot \text{s} \cdot \text{V}^{-1}]} }$$
分子分母消去 $[\text{A}]$、$[\text{V}^{-1}]$、$[\text{rad}]$：
$$\omega_n = \sqrt{ \frac{[\text{s}^{-1}]}{[\text{s}]} } = \sqrt{[\text{s}^{-2}]} = [\text{s}^{-1}] \Rightarrow \mathbf{[rad/s]}$$
（推導完全吻合物理現實！）

**圖表單位推斷：**
📈 **圖 1（右上）：VCO 轉移特性**
- X 軸：控制電壓 $V_{ctrl}$ $[\text{V}]$，典型範圍 0.5V ~ 1.5V (VDD=1.8V)。
- Y 軸：輸出角頻率 $\omega_{out}$ $[\text{rad/s}]$，斜率即為 $K_{vco}$。

📈 **圖 2（中左）：PFD/CP 轉移特性**
- X 軸：輸入相位差 $\Delta\phi$ $[\text{rad}]$，線性範圍為 $-2\pi \sim +2\pi$。
- Y 軸：平均充放電電流 $\overline{I_{av}}$ $[\text{A}]$，典型範圍 $\pm 10\mu\text{A} \sim \pm 1\text{mA}$。斜率為 $I_p/2\pi$。

📈 **圖 3 & 4（中下）：Root Locus 極點分佈圖**
- X 軸：實部 $\sigma$ $[\text{rad/s}]$，代表時域上的衰減速度。
- Y 軸：虛部 $j\omega$ $[\text{rad/s}]$，代表時域上的振盪頻率。

### 白話物理意義
純電容濾波器就像開車**「只看現在位置、不看速度」**，一定會衝過頭來回震盪（Unstable）；加入電阻 $R_p$ 產生 Zero，等於賦予系統**「預測未來誤差變化率」**的能力，讓迴路能提早煞車，平穩鎖定（Stable）。

### 生活化比喻
想像你在洗澡調水溫（目標 40 度）。
如果迴路裡只有電容 $C_p$（等於一個單純的水桶累積熱水）：水太冷你就狂開熱水，等你「感覺」到 40 度時，水管裡已經累積一堆熱水，下一秒直接燙傷你變 45 度；你又狂開冷水，反覆被燙到和冰到，這就是 **Unstable（持續震盪）**。
加入電阻 $R_p$ 相當於你具備了「預測」能力：當水溫快速上升到 38 度時，你感覺到「上升速度太快了」，提早把手縮回來一點（這就是 Zero 帶來的 Phase Lead 領先補償），這樣水溫就會穩穩停在 40 度不亂晃，這就是 **Stable**。

此外，筆記右下角提到 "Continuous-time approx"：PFD 是一拍一拍比較的（階梯狀），但只要比較速度極快（Reference 頻率遠大於系統反應頻寬 $\omega_{ref} \gg \omega_{BW}$），就像電影每秒播放 60 張照片，你的眼睛看起來就會是連續、線性的行為。

### 面試必考點
1. **問題：為什麼 Type-II PLL 迴路濾波器一定要加電阻 $R_p$？不加會怎樣？**
   → 答案：因為 VCO 積分器貢獻一個極點在原點，純電容 $C_p$ 又貢獻一個極點在原點。雙重極點導致系統相位餘裕 (Phase Margin) 為 0 度，閉迴路極點落在虛數軸上，系統必定不穩定。加入 $R_p$ 可產生一個 LHP Zero ($\omega_z = 1/R_pC_p$)，提供相位領先補償，把極點拉進左半平面使系統穩定。
2. **問題：在設計 Wireline SerDes (CDR/PLL) 與 Wireless RF PLL 時，Damping factor $\zeta$ 的考量有何不同？**
   → 答案：Wireline 為了避免 Jitter 被放大（Jitter Peaking），通常設計成 Overdamped ($\zeta \gg 1$)；Wireless 為了快速切換頻帶（Fast Lock Time），通常設計近乎 Critically damped ($\zeta \approx 1$ 或 0.707) 以達到最快的暫態收斂。
3. **問題：連續時間線性模型 (Continuous-time approx) 成立的先決條件是什麼？**
   → 答案：參考時脈頻率 ($f_{ref}$) 必須遠大於 PLL 的迴路頻寬 ($f_{BW}$)，通常設計法則為 $f_{ref} \ge 10 \times f_{BW}$。若此條件不成立，離散取樣效應會使系統不穩定，甚至產生 aliasing jitter。

**記憶口訣：**
**「電阻造零點，雙極點救星」(RC makes Zero)；**
**「有線怕抖 (Overdamped)，無線怕慢 (Critical damped)」。**
