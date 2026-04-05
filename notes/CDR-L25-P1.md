# CDR-L25-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L25-P1.jpg

---


---
## Jitter Transfer (JTRAN) in CDR Systems

### 數學推導
Jitter Transfer (JTRAN) 定義為 CDR 迴路對「輸入 Jitter」的頻率響應（轉移函數）。最簡單的量測方式是在輸入資料上加上弦波的相位調變 (Sinusoidal phase modulation)，然後觀察輸出時脈 (Clock) 相位的變化程度。

**1. Linear CDR 的 Jitter Transfer**
這是一個典型的二階 PLL 閉迴路轉移函數：
$$H(s) = \frac{\phi_{out}(s)}{\phi_{in}(s)} = \frac{2\zeta\omega_n s + \omega_n^2}{s^2 + 2\zeta\omega_n s + \omega_n^2}$$
其中系統的自然頻率 $\omega_n$ 與阻尼因數 $\zeta$ 定義為：
$$\omega_n^2 = \frac{I_p K_{vco}}{2\pi C_p}$$
$$\zeta = \frac{R_p}{2} \sqrt{\frac{I_p C_p K_{vco}}{2\pi}}$$
當系統設計為高阻尼（Over-damped, $\zeta \gg 1$）時，系統極點會被拉開，可近似為一階低通濾波器：
$$\frac{\phi_{out}}{\phi_{in}} \approx \frac{2\zeta_1\omega_n}{s + 2\zeta_1\omega_n}$$
此時的 -3dB 頻寬（Corner Frequency）為：
$$\omega_{-3dB} = 2\zeta_1\omega_n = 2 \left( \frac{R_p}{2} \sqrt{\frac{I_p C_p K_{vco}}{2\pi}} \right) \left( \sqrt{\frac{I_p K_{vco}}{2\pi C_p}} \right) = \frac{I_p R_p K_{vco}}{2\pi}$$

**2. Bang-Bang (BB) CDR 的 Jitter Transfer**
BB-PD 是非線性元件（轉移曲線為步階函數 Step Function），無法直接求取傳統的線性轉移函數。我們必須利用等效增益（Describing Function / Slew-rate limit）來推導。
在高頻區段（$\omega \gg \omega_{-3dB}$），VCO 的頻率偏移受到 charge pump 電流切換的限制（Slew-rate limited），其 JTRAN 近似為：
$$|JTRAN| \approx \frac{\pi I_p R_p K_{vco}}{2 \omega \phi_{in,p}}$$
對應到一階低通濾波器的高頻漸近線特性 $|H(j\omega)| \approx \frac{\omega_{-3dB}}{\omega}$，我們可以反推等效的 -3dB 頻寬為：
$$\omega_{-3dB} = \frac{\pi I_p R_p K_{vco}}{2 \phi_{in,p}}$$
因此，BB CDR 的等效轉移函數可寫為：
$$\frac{\phi_{out,p}(s)}{\phi_{in,p}} \approx \frac{1}{1 + \frac{s}{\omega_{-3dB}}}$$
**注意：** $\phi_{in,p}$ 為輸入 Jitter 的峰值振幅，這表示 BB CDR 的頻寬會**隨著輸入 Jitter 大小而改變**。

### 單位解析
**公式單位消去：**
- $I_p$: Charge pump 電流，單位 $[A]$
- $R_p$: 迴路濾波器等效電阻，單位 $[\Omega] = [V/A]$
- $K_{vco}$: VCO 增益，單位 $[rad/s/V]$
- $\phi_{in,p}$: 相位振幅，單位 $[rad]$ （筆記中提到 1 UI = 1 bit period = $360^\circ$ = $2\pi$ rad）

1. **Linear CDR 頻寬 $\omega_{-3dB}$：**
   $$\omega_{-3dB} = \frac{I_p R_p K_{vco}}{2\pi} \rightarrow \frac{[A] \cdot [V/A] \cdot [rad/s/V]}{[rad/cycle]} = [1/s] = [rad/s]$$
   （$I_p/2\pi$ 即為 PD 增益 $K_{pd}$，單位 $[A/rad]$，完美消去得到 $[rad/s]$）

2. **BB CDR 頻寬 $\omega_{-3dB}$：**
   $$\omega_{-3dB} = \frac{\pi I_p R_p K_{vco}}{2 \phi_{in,p}} \rightarrow \frac{[1] \cdot [A] \cdot [V/A] \cdot [rad/s/V]}{[rad]} = \frac{[rad/s]}{[rad]} = [1/s] = [rad/s]$$

**圖表單位推斷：**
1. 📈 **Repeater JTRAN Accumulation Plot (中上方)**
   - X 軸：Jitter 頻率 $f$ [Hz] (對數尺度)
   - Y 軸：轉移函數大小 $|JTRAN|$ [dB]
   - 物理意義：展示多級中繼器 (如 1000 級) 串接後，微小的 Peaking 會被指數級放大。
2. 📈 **Linear PD 特性曲線 (左中)**
   - X 軸：相位差 $\Delta\phi$ [rad]，範圍 $\pm 2\pi$
   - Y 軸：平均電流 $I_{av}$ [A]，斜率為 $\frac{I_p}{2\pi}$
3. 📈 **Linear CDR Bode Plot (左下)**
   - X 軸：角頻率 $\omega$ [rad/s] (對數尺度)
   - Y 軸：$|JTRAN|$ [dB]，低頻平坦區為 0dB，高頻以 -20dB/dec 下降。
4. 📈 **BB-PD 特性曲線 (右中)**
   - X 軸：相位差 $\Delta\phi$ [rad]
   - Y 軸：平均電流 $I_{av}$ [A]，呈現 $\pm I_p$ 的非線性步階特性。
5. 📈 **BB CDR Bode Plot (右下)**
   - X 軸：角頻率 $\omega$ [rad/s] (對數尺度)
   - Y 軸：$|JTRAN|$ [dB]，轉角頻率 $\omega_{-3dB}$ 會隨 $\phi_{in,p}$ 飄移。

### 白話物理意義
Jitter Transfer 就是「輸入抖動有多少被傳遞到輸出」。Linear CDR 的濾波頻寬是固定的硬體參數；而 Bang-Bang CDR 則是一個「遇強則弱」的系統，輸入抖動越大，它的等效頻寬就越窄。

### 生活化比喻
把 Jitter Transfer 想像成汽車的「懸吊避震器」：
- **輸入 Jitter** 是路面的坑洞與起伏。
- **Linear CDR** 是一般的避震器，不管是小碎石還是大坑洞，阻尼反應是固定的。
- **Bang-Bang CDR** 是一種「只有全開或全關」的極端避震器。遇到小碎石它反應很靈敏（頻寬寬），但如果遇到巨大的連續坑洞（大的 $\phi_{in,p}$），它因為每次只能給固定的力道（Slew-rate limit），反而會來不及反應，導致整體變得很軟（等效頻寬變窄）。
- **Peaking 效應** 就像 1000 台車排成一列開過同一個坑洞，第一台車稍微彈高 1 公分，第二台車跟著彈高 1.01 公分……到第 1000 台車時，車子可能就直接飛起來了（眼圖完全閉合）。

### 面試必考點
1. **問題：在長途光纖通訊（如 SONET 協定）中，為何極度要求 CDR 不能有 Jitter Peaking？**
   → 答案：長途傳輸會串接多個 Repeater (CDR)。轉移函數上若在某頻段有微小的 Peaking（如 $>0dB$），這個放大倍率會被「連乘」。例如 0.1dB 的 peaking 經過 1000 級串接後會變成非常巨大的抖動，導致後段電路完全無法還原時脈。
2. **問題：Linear CDR 和 Bang-Bang CDR 的頻寬決定因素有何不同？**
   → 答案：Linear CDR 的頻寬 ($\omega_{-3dB} = \frac{I_p R_p K_{vco}}{2\pi}$) 是由 PVT 與被動元件決定的常數；而 BB CDR 的等效頻寬 ($\omega_{-3dB} \propto \frac{1}{\phi_{in,p}}$) 是「動態」的，輸入的 Jitter 振幅越大，等效頻寬越小（因為受限於 Slew Rate）。
3. **問題：BB-PD 是非線性元件，怎麼畫出 Bode Plot 或定義頻寬？**
   → 答案：使用大訊號分析或 Describing Function 方法，給定一個特定振幅 $\phi_{in,p}$ 的弦波抖動作為輸入，觀察輸出受到 $I_p$ 限制（Slew-rate limiting）的相位變化，從而推導出針對「特定輸入振幅」下的等效線性頻寬。

**記憶口訣：**
- **JTRAN 頻寬特性**：「線固 Bang 反」 (Linear CDR 頻寬固定；Bang-Bang 頻寬與輸入 Jitter 成反比)。
- **Peaking 累積**：「一趴乘千遍，眼圖糊成線」。
