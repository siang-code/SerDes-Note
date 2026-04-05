# EQ-L10-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/EQ-L10-P1.jpg

---


---
## Continuous Time Linear Equalizer (CTLE) 演進與 Inductive Peaking 的致命傷

### 數學推導
本頁筆記展示了 CTLE 為了補償高頻損失（High freq loss）的架構演進，重點在於推導出 Active Inductive Peaking 的轉移函數與其二階系統特性。

**Step 1: 純 CR 高通濾波器 (High-pass filter)**
- 架構：串聯 $C$，下地 $R$。
- 轉移函數：$H(s) = \frac{sRC}{1+sRC}$。
- **缺點**：DC gain $\to -\infty$ dB（線性值為 0）。在 SerDes 中，NRZ 訊號包含大量低頻與 DC 成分，純高通會把訊號 DC 準位完全砍掉，無法使用。

**Step 2: 被動式 CTLE (Passive EQ)**
- 架構：利用分壓電路 $R_1, R_2$ 確保 DC 增益，並在 $R_1$ 旁並聯 $C_1$ 產生高頻零點，負載端有寄生電容 $C_2$。
- 轉移函數：$H(s) = \frac{R_2}{R_1+R_2} \cdot \frac{1 + R_1 C_1 s}{1 + (R_1 || R_2)(C_1+C_2) s}$
- **缺點**：「No gain $\Rightarrow$ SNR degrades」。雖然有等化效果，但整體是衰減的（Gain < 1），會讓訊號變小，惡化訊雜比。

**Step 3: 主動式電感峰化 (Active Inductive Peaking CTLE) - 核心推導**
- 架構：差動對 (Differential Pair) 加上 $R_S-L$ 串聯負載，輸出端有寄生電容 $C$ 下地。
- 負載阻抗 $Z_L(s) = (R_S + sL) || \frac{1}{sC} = \frac{R_S + sL}{LCs^2 + R_S C s + 1}$
- 定義二階系統標準參數：
  - 自然頻率 (Natural frequency): $\omega_n^2 = \frac{1}{LC} \Rightarrow \omega_n = \frac{1}{\sqrt{LC}}$
  - 阻尼比 (Damping factor): 將分母同除 $LC$ 得到 $s^2 + \frac{R_S}{L}s + \frac{1}{LC}$。對應標準式 $s^2 + 2\zeta\omega_n s + \omega_n^2$，可得 $2\zeta\omega_n = \frac{R_S}{L} \Rightarrow \zeta = \frac{R_S}{2L\omega_n} = \frac{R_S}{2} \sqrt{\frac{C}{L}}$
- 將 $Z_L(s)$ 整理為李致毅教授筆記上的形式：
  - 分子：$sL + R_S = L(s + \frac{R_S}{L}) = L(s + 2\zeta\omega_n)$
  - 分母：$LC(s^2 + 2\zeta\omega_n s + \omega_n^2)$
  - $Z_L(s) = \frac{L(s + 2\zeta\omega_n)}{LC(s^2 + 2\zeta\omega_n s + \omega_n^2)} = \frac{1}{C} \frac{s + 2\zeta\omega_n}{s^2 + 2\zeta\omega_n s + \omega_n^2}$
  - 利用前面推導的關係式：$\frac{\omega_n}{2\zeta} = \frac{1/\sqrt{LC}}{R_S\sqrt{C/L}} = \frac{1}{R_S C}$，因此 $\frac{1}{C} = R_S \frac{\omega_n}{2\zeta}$。
  - 轉移函數 $H(s) = g_m Z_L(s) = g_m R_S \cdot \frac{s + 2\zeta\omega_n}{s^2 + 2\zeta\omega_n s + \omega_n^2} \cdot \frac{\omega_n}{2\zeta}$ （**與筆記公式完全吻合！**）

### 單位解析
**公式單位消去：**
- $\omega_n = \frac{1}{\sqrt{LC}}$
  - $[L] = \text{H (Henry)} = \text{V}\cdot\text{s}/\text{A} = \Omega\cdot\text{s}$
  - $[C] = \text{F (Farad)} = \text{A}\cdot\text{s}/\text{V} = \text{s}/\Omega$
  - $[L \cdot C] = (\Omega\cdot\text{s}) \cdot (\text{s}/\Omega) = \text{s}^2$
  - $[\omega_n] = 1 / \sqrt{\text{s}^2} = 1/\text{s} = \text{rad/s}$ (角頻率)
- $\zeta = \frac{R_S}{2} \sqrt{\frac{C}{L}}$
  - $[R_S] = \Omega$
  - $[\sqrt{C/L}] = \sqrt{(\text{s}/\Omega) / (\Omega\cdot\text{s})} = \sqrt{1/\Omega^2} = 1/\Omega$
  - $[\zeta] = \Omega \cdot (1/\Omega) = 1$ (無因次，符合阻尼比定義)

**圖表單位推斷：**
- **Bode Plot (左下，頻率響應圖)：**
  - X 軸：角頻率 $\omega$ $[\text{rad/s}]$ 或 $f$ $[\text{GHz}]$ (log scale)。
  - Y 軸：轉移函數大小 $|H|$ $[\text{dB}]$。典型範圍：低頻平坦，高頻 Peak 可達 0~16.5 dB (如筆記標示 $\zeta=0.2 \Rightarrow 16.5\text{dB}$ Boosting)。
- **Step Response (中下，步階響應圖)：**
  - X 軸：時間 $t$ $[\text{ps}]$，典型範圍數十到數百 ps (取決於 data rate)。
  - Y 軸：輸出電壓 $V_{out}$ $[\text{mV}]$。圖中紅線為包絡線 $e^{-\zeta\omega_n t}$。
- **Eye Diagram (右下，眼圖)：**
  - X 軸：時間 $t$ $[\text{UI}]$ (Unit Interval)，典型看 2~3 個 UI。
  - Y 軸：差動電壓 $[\text{mV}]$。圖中明顯看到因為 Ringing 造成的跡線(Trace)混亂，導致眼圖閉合。

### 白話物理意義
加電感雖然能靠「共振」把高頻增益硬拉起來（Peaking），但如果推過頭（阻尼 $\zeta$ 太小），系統就會像裝了太軟的彈簧一樣，在時域產生嚴重的振盪（Ringing），讓前一筆資料的餘震干擾到下一筆資料（ISI）。

### 生活化比喻
這就像幫越野車換避震器。遇到爛路（高頻衰減）時，你換了一組超硬的彈簧（加電感 L），讓車子壓過坑洞時能迅速彈起（High freq boosting）；但如果你忘了加阻尼油（$\zeta$ 太小），車子過坑後會上下狂晃很久（Ringing）。這狂晃會讓你看不清前面的路，就像電路裡的 ISI 讓你判斷錯下一個 Bit 是 0 還是 1。

### 面試必考點
1. **問題：為什麼被動式 EQ (Passive CTLE) 不受歡迎，通常要搭配主動式電路？**
   → 答案：被動式 EQ 在低頻是靠分壓來衰減訊號以突顯高頻，整體 DC 增益小於 1（如筆記寫的 SNR degrades）。這會讓訊號整體振幅變小，更容易受到後級電路 Noise 的干擾，因此必須搭配主動式（有 $g_m$ 放大）的架構。
2. **問題：Inductive Peaking 中的 $L$ 太大會發生什麼事？請從頻域與時域解釋。**
   → 答案：由公式 $\zeta = \frac{R_S}{2}\sqrt{\frac{C}{L}}$ 可知，$L$ 變大會導致阻尼比 $\zeta$ 下降（Underdamped）。在頻域，會看到 Gain peaking 太尖銳（共軛極點太靠近 jw 軸）；在時域，Step response 會出現嚴重的 Ringing，導致前一個 bit 殘留的能量干擾下一個 bit，造成 ISI (Inter-Symbol Interference) 惡化。
3. **問題：在 Inductive Peaking 電路中，決定 Peaking 頻率（$\omega_n$）跟 Peaking 程度（$\zeta$）的元件分別是誰？**
   → 答案：Peaking 頻率主要由 $\omega_n = 1/\sqrt{LC}$ 決定，也就是電感 $L$ 與寄生電容 $C$；而 Peaking 的劇烈程度（阻尼 $\zeta$）則與負載電阻 $R_S$ 成正比，與 $\sqrt{L}$ 成反比。

**記憶口訣：**
被動衰減降 SNR，主動電感拉高頻；
$L$ 大 $\zeta$ 小會 Ringing，頻域尖峰時域暈。

---
**👨‍🏫 TA 的費曼挑戰（Feynman Test）：**
如果面試官問你：「我看你的轉移函數裡有一個零點 $\omega_z = 2\zeta\omega_n$（即分子 $s + 2\zeta\omega_n$），這個零點的物理意義是什麼？它是怎麼產生 Peaking 的？」
*(提示：思考阻抗 $Z_L(s)$ 中，電感 $L$ 和電阻 $R_S$ 串聯的轉折頻率。)*
