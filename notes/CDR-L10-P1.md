# CDR-L10-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L10-P1.jpg

---


---
## [BBPD詳細研究] Bang-Bang Phase Detector 大訊號非線性分析

### 數學推導
本頁筆記主要分析當 Bang-Bang Phase Detector (BBPD) 在面臨大訊號 Jitter 時的「非線性 (Slewing)」行為，並推導其等效的 Jitter Transfer 頻寬。

1. **定義輸入 Jitter 與系統變數：**
   假設輸入的 Jitter 為一個弦波：$\phi_{in}(t) = \phi_{in,p} \cos(\omega_\phi t)$。
   其中 $\phi_{in,p}$ 是峰值振幅，$\omega_\phi$ 是 Jitter 的調變頻率，對應的週期為 $T_\phi = \frac{2\pi}{\omega_\phi}$。

2. **區分操作區域：**
   - **Linear Region:** 當輸入相位誤差 $\Delta\phi < \phi_m$ (一個極小的線性區間)，BBPD 可視為線性，適用標準線性 PLL 模型。
   - **Non-linear Region:** 當 $\Delta\phi > \phi_m$ (大訊號)，BBPD 輸出電流飽和在 $\pm I_p$。此時若 $\omega_\phi$ 增加，VCO 相位追趕不上輸入，發生 **Slewing**。

3. **計算 Slewing 下的輸出相位峰值 $\phi_{out,p}$：**
   當發生嚴重 Slewing 時，CP 輸出恆定電流 $\pm I_p$，經過 $R_p$ 產生方波電壓，使 VCO 頻率也是方波 $\Delta\omega_{vco} = \pm I_p \cdot R_p \cdot K_{vco}$。
   頻率的積分是相位，所以輸出相位 $\phi_{out}$ 會是三角波。
   從三角波波形圖可知，在四分之一個週期 $\frac{T_\phi}{4}$ 內，相位從 0 爬升到最大值 $\phi_{out,p}$：
   $$ \phi_{out,p} = (頻率變化量) \times (時間) = (I_p \cdot R_p \cdot K_{vco}) \cdot \left(\frac{T_\phi}{4}\right) $$

4. **推導等效頻寬 $\omega_{-3dB}$：**
   將 $T_\phi = \frac{2\pi}{\omega_\phi}$ 代入上式：
   $$ \phi_{out,p} = \frac{I_p \cdot R_p \cdot K_{vco} \cdot \frac{2\pi}{\omega_\phi}}{4} = \frac{\pi \cdot I_p \cdot R_p \cdot K_{vco}}{2 \cdot \omega_\phi} $$
   定義 Jitter Transfer (JTRAN) 的大小為輸出與輸入振幅比：
   $$ \left| \frac{\phi_{out,p}}{\phi_{in,p}} \right| = \frac{\pi \cdot I_p \cdot R_p \cdot K_{vco}}{2 \cdot \omega_\phi \cdot \phi_{in,p}} $$
   我們定義頻寬 $\omega_{-3dB}$ 為轉移函數大小下降到 1 (即 0 dB 交越點，此處以漸近線交點做為大訊號等效頻寬的近似)：
   令 $\left| \frac{\phi_{out,p}}{\phi_{in,p}} \right| = 1$，並將 $\omega_\phi$ 替換為 $\omega_{-3dB}$：
   $$ 1 = \frac{\pi \cdot I_p \cdot R_p \cdot K_{vco}}{2 \cdot \omega_{-3dB} \cdot \phi_{in,p}} \implies \omega_{-3dB} = \frac{\pi \cdot I_p \cdot R_p \cdot K_{vco}}{2 \cdot \phi_{in,p}} $$

### 單位解析
**公式單位消去：**
- $I_p$ (Charge Pump 電流)：$[A]$
- $R_p$ (Loop Filter 電阻)：$[V/A]$ 或 $[\Omega]$
- $K_{vco}$ (VCO 增益)：$[rad/s/V]$
- **頻率步階** $\Delta\omega_{vco} = I_p \cdot R_p \cdot K_{vco}$：$[A] \times [V/A] \times [rad/s/V] = [rad/s]$
- **週期** $T_\phi$：$[s]$
- **相位峰值** $\phi_{out,p} = \Delta\omega_{vco} \times \frac{T_\phi}{4}$：$[rad/s] \times [s] = [rad]$
- **等效頻寬** $\omega_{-3dB} = \frac{\pi \cdot I_p \cdot R_p \cdot K_{vco}}{2 \cdot \phi_{in,p}}$：$\frac{[無單位] \cdot [rad/s]}{[rad]} = [rad/s]$ (頻率單位，推導正確)

**圖表單位推斷：**
📈 **BBPD 轉移曲線圖 (左下)：**
- X 軸：相位誤差 $\Delta\phi$ $[rad]$ 或 $[UI]$，典型範圍 $\pm 0.5$ UI
- Y 軸：平均輸出電流 $I_{av}$ $[A]$，典型範圍 $\pm I_p$ (約數十至數百 $\mu A$)

📈 **時域波形圖 (中間)：**
- X 軸：時間 $t$ $[s]$，典型範圍取決於 Jitter 頻率 (如 $1 \sim 10 ns$)
- Y 軸 (上)：相位 $\phi_{in}, \phi_{out}$ $[rad]$ 或 $[UI]$
- Y 軸 (中)：電流 $I_p$ $[A]$
- Y 軸 (下)：頻率 $\omega_{vco}$ $[rad/s]$

📈 **Jitter Transfer (JTRAN) 頻率響應圖 (右下)：**
- X 軸：Jitter 頻率 $\omega_\phi$ $[rad/s]$，對數尺度 (log scale)
- Y 軸：轉移函數大小 $\left|\frac{\phi_{out}}{\phi_{in}}\right|$ $[dB]$，從 $0$ dB 開始以 $-20$ dB/dec 下降。

### 白話物理意義
當輸入的相位抖動（Jitter）太大或太快時，BBPD 已經把電流「催到底（$\pm I_p$）」了，VCO 改變相位的速度依然跟不上輸入的變化速度（發生 Slewing），導致輸出的相位變成斜率固定的三角波。而且輸入抖動幅度越大，系統就越早「跟不上」，等效的追蹤頻寬就越窄。

### 生活化比喻
想像你開著一輛方向盤最多只能轉一圈的車（最大電流 $I_p$）。如果前面的領跑車（輸入 Jitter）只是緩慢蛇行，你可以輕鬆跟上。但如果領跑車突然快速且大範圍地左右狂飆，你方向盤打到底（Slewing）也來不及轉彎，只能走出一條比較平緩的折線（三角波 $\phi_{out}$）。而且領跑車蛇行幅度越大（$\phi_{in,p}$ 越大），你感覺「跟不上」的極限就越早到來（等效頻寬 $\omega_{-3dB}$ 變小）。

### 面試必考點
1. **問題：在 BB-CDR 中，Jitter Transfer 的頻寬 (Loop BW) 有什麼獨特現象？**
   → **答案：** BB-CDR 的等效 Loop BW 是 **Input Dependent (與輸入相關)** 的。從公式 $\omega_{-3dB} = \frac{\pi I_p R_p K_{vco}}{2 \phi_{in,p}}$ 可知，當系統處於 Slewing 狀態時，輸入 Jitter 振幅 $\phi_{in,p}$ 越大，等效頻寬越小。
2. **問題：BB-CDR 的 Jitter Peaking 大概是多少？為什麼？**
   → **答案：** BB-CDR 幾乎 **沒有 Jitter Peaking (Almost no peaking)**。因為它的本質是高度非線性的 Slewing 限制，大訊號下就是一個直接以 -20dB/dec 往下掉的低通特性，不像線性二階 PLL 會因為阻尼不足 (under-damped) 而在頻寬邊緣產生共振峰。
3. **問題：如何增加 BB-CDR 對大訊號 Jitter 的容忍度（提高等效頻寬）？**
   → **答案：** 根據 $\omega_{-3dB}$ 公式，可以增加 CP 電流 $I_p$、增加 Loop Filter 電阻 $R_p$（這兩者等同於增加 Bang-Bang step size），或者增加 VCO 的增益 $K_{vco}$。但這會導致鎖定時的穩態 Jitter (Proportional Jitter) 變大，這是典型的 Trade-off。

**記憶口訣：**
大訊號必 Slew，三角波跟著走；頻寬看輸入，越大越遲鈍；沒有 Peaking 好棒棒。
