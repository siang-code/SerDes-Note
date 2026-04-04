# PLL-L13-P1

> 分析日期：2026-04-04
> 原始圖片：images/PLL-L13-P1.jpg

---

---
## [PLL 迴路模型與濾波器設計 (Loop Model & Filter Design)]

### 數學推導
（逐步推導，每步說明）
本頁筆記主要推導 Type-II PLL (Charge Pump PLL) 的開迴路增益 (Open Loop Gain) 與轉移函數，這是決定系統穩定度與頻寬的核心。

1.  **各區塊轉移函數定義**：
    *   **Phase Frequency Detector + Charge Pump (PFD+CP)**: 將相位差 $\Delta\phi$ 轉換為電流 $I_{out}$。在一個參考週期 $2\pi$ 內，最大輸出電流為 $I_p$。其平均轉移增益為 $K_{pd} = \frac{I_p}{2\pi}$。
    *   **Loop Filter (一階, 1st order)**: 由電阻 $R_p$ 與電容 $C_p$ 串聯組成。將電流轉換為控制電壓 $V_{ctrl}$。阻抗 $Z(s) = R_p + \frac{1}{sC_p} = \frac{sR_pC_p + 1}{sC_p}$。
    *   **Voltage Controlled Oscillator (VCO)**: 將控制電壓轉換為輸出相位。頻率是相位的微分，因此相位是頻率的積分。轉移函數為 $\frac{K_{vco}}{s}$。
    *   **Divider (除頻器)**: 將輸出相位除以 $M$。反饋增益為 $\frac{1}{M}$。(筆記中公式 $A$ 主要探討 Forward Gain $G(s)$ 或假設 $M=1$ 的狀況，以簡化極零點分析)。

2.  **開迴路增益 $A(s)$ (Open Loop Gain)**：
    將上述順向路徑相乘：
    $$A(s) = \left( \frac{I_p}{2\pi} \right) \cdot \left( R_p + \frac{1}{sC_p} \right) \cdot \left( \frac{K_{vco}}{s} \right)$$
    提出 $\frac{1}{sC_p}$ 進行整理：
    $$A(s) = \frac{I_p K_{vco}}{2\pi s} \cdot \left( \frac{sR_pC_p + 1}{sC_p} \right) = \frac{I_p K_{vco}}{2\pi C_p} \cdot \frac{(1 + sR_pC_p)}{s^2}$$

3.  **極零點分析 (Pole-Zero Analysis)**：
    *   **極點 (Poles)**：分母有 $s^2$，代表在原點 ($s=0$) 有**兩個極點** ($s_1 = s_2 = 0$)。這定義了這是一個 Type-II 的控制系統，能對 Step 頻率變化達到零穩態誤差。
    *   **零點 (Zero)**：分子為 $(1 + sR_pC_p) = 0$，解得左半平面零點 (LHP Zero) $\omega_z = \frac{1}{R_pC_p}$。
    *   **為什麼需要零點？** 兩個原點極點會貢獻 $-180^\circ$ 的相位延遲。如果沒有零點提昇相位，相位餘裕 (Phase Margin, PM) 會是 $0$ 甚至負的，系統必定震盪（不穩定）。$R_p$ 的加入產生了這個救命的零點。

### 單位解析
**公式單位消去：**
以開迴路增益公式 $A(s) = K_{pd} \times Z(s) \times \frac{K_{vco}}{s}$ 為例：
*   $K_{pd} = \frac{I_p}{2\pi}$：單位為 $[\text{A}/\text{rad}]$ (每徑度相位差產生多少安培電流)
*   $Z(s) = R_p + \frac{1}{sC_p}$：單位為 $[\Omega] = [\text{V}/\text{A}]$ (歐姆定律，電流轉電壓)
*   $\frac{K_{vco}}{s}$：$K_{vco}$ 在此架構下常表示為 $[\text{rad/s}/\text{V}]$ (配合 $K_{pd}$ 的 rad)。積分項 $\frac{1}{s}$ 單位為 $[\text{s}]$。故 $\frac{K_{vco}}{s}$ 單位為 $[\text{rad}/(\text{s}\cdot\text{V})] \times [\text{s}] = [\text{rad}/\text{V}]$。
*   **單位消去**：$A(s)$ 單位 = $[\text{A}/\text{rad}] \times [\text{V}/\text{A}] \times [\text{rad}/\text{V}] = 1$ (**無單位 Unitless**)。迴路增益必須是無因次量，物理意義完全正確。

**圖表單位推斷：**
📈 **Bode Plot 單位推斷 (筆記左側中段圖表)**：
*   **X 軸**：角頻率 $\omega$ $[\text{rad/s}]$，對數尺度 (Log-scale)。典型範圍 $10^4 \sim 10^9 \text{ rad/s}$。
*   **Y 軸 (上圖 $|A|$)**：開迴路增益大小 $[\text{dB}]$。典型範圍 $-40 \text{ dB} \sim 80 \text{ dB}$。
*   **Y 軸 (下圖 $\angle A$)**：相位角 $[\text{Degree}, ^\circ]$。典型範圍 $-180^\circ \sim -90^\circ$ (考量高頻寄生極點會掉到 $-180^\circ$ 以下)。圖中標示的 $PM$ 即為在增益 $0\text{dB}$ 頻率（Crossover Frequency, $\omega_c$）時，相位與 $-180^\circ$ 的距離。
*(筆記特別指出：若 $I_p K_{vco}$ 下降，Gain 曲線整體下移，導致交越頻率左移靠近 $\omega_z$，使得 Phase Margin 變小，穩定度惡化。)*

### 白話物理意義
Loop Filter 裡的電阻 $R_p$ 就像是給系統裝上「預測煞車」，它提早給出相位超前（Zero），把因為 Charge Pump 和 VCO 雙重積分導致快要失控翻車的 PLL 硬生生拉回穩定軌道，代價是會產生顛簸（Ripple / Spur）。

### 生活化比喻
想像你在開一台車（VCO），如果只靠看終點線來加速（只有 $C_p$ 積分），你會一路狂奔，等到過了終點才發現並開始倒車，最後在終點線來回震盪停不下來（這就是只有雙極點的不穩定）。
加上電阻 $R_p$ 就像加入了「感受速度」的機制（微分作用），當你快接近終點但速度還很快時，你會提早踩煞車，穩穩地停在終點上（Zero 提升相位，增加 PM）。然而，煞車皮摩擦會產生碎震（$I_p \times R_p$ 產生的突波），所以我們需要額外加裝小避震器（並聯的小電容 $C_s$）來吸收這些震動。

### 面試必考點
1. **問題：在 Type-II Charge Pump PLL 中，如果 Loop Filter 只放一顆電容 $C_p$ 會怎樣？為什麼一定要串聯電阻 $R_p$？**
   * **答案**：只放 $C_p$ 會導致開迴路轉移函數在原點有兩個極點（一個來自 CP 電流對 $C_p$ 積分，另一個來自 VCO 頻率積分成相位），相位直接從 $-180^\circ$ 開始，Phase Margin 為零，系統絕對不穩定。串聯 $R_p$ 能產生一個左半平面零點 (LHP Zero, $\omega_z = 1/R_pC_p$)，提供相位超前 (Phase Lead)，將相位拉回 $-90^\circ$ 的方向，確保系統擁有足夠的 Phase Margin 才能穩定鎖定。

2. **問題：加了 $R_p$ 穩定了系統，卻帶來了 Reference Spur 的問題，機制是什麼？要怎麼解決？**
   * **答案**：當 PLL 鎖定時，PFD 仍會輸出極短的脈衝。Charge Pump 的瞬間脈衝電流 $I_p$ 流過 $R_p$ 時，會產生巨大的電壓突波 $\Delta V = I_p \times R_p$ (Ripple)。這個突波會直接調變 VCO 的控制電壓 $V_{ctrl}$，在輸出頻譜上產生 Reference Spur 並且嚴重惡化 Jitter。解決方案是在 $R_p$ 與 $C_p$ 旁邊並聯一顆小電容 $C_s$（通常 $C_s < 5\% \sim 10\% \text{ of } C_p$）構成 2nd-order Loop Filter，利用 $C_s$ 提供高頻電流的低阻抗旁路，有效吸收並濾除突波。

3. **問題：為了濾除 Ripple 加入了額外的極點（如 3rd-order 迴路中的 LPF 極點 $\omega_3$），這些極點的頻率位置該怎麼決定？**
   * **答案**：筆記下方明確指出，頻率擺放必須滿足 $\text{Loop BW} < \omega_3 < \omega_{ref} \ll \omega_{osc}$。
     1. $\omega_3 \approx 10 \times \text{Loop BW}$：確保高頻極點遠離 Crossover frequency ($\omega_c$)，避免其造成的相位延遲吃到好不容易用零點建起來的 Phase Margin，導致穩定度下降。
     2. $\omega_3 < \omega_{ref}$：確保截止頻率夠低（比 Update Rate 慢），才能有效衰減 Reference frequency 帶來的 Vctrl Ripple 與 Spur。連續時間近似的前提是 $f_{ref}$ 夠快，讓離散的 Pulse 看起來像平均電流。

**記憶口訣：**
「雙極不穩加 R 救，R 生突波 C 來收；零點保相極點濾，頻寬十倍好悠遊。」
（雙極點不穩定加電阻救，電阻產生突波加電容收；零點保留相位餘裕、極點用來濾波，極點頻率放頻寬十倍遠最好）
