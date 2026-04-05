# CDR-L4-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L4-P1.jpg

---

---
## Dual Loop Architecture & Linear PLL-based CDR Model

### 數學推導
筆記中詳細推導了基於線性相位偵測器（如 Hogge's PD）的 CDR 閉迴路轉移函數。
1. **開迴路增益 $L(s)$**:
   - 線性 PD 的增益為 $K_{pd} = \frac{I_p}{2\pi}$。
   - 迴路濾波器（Loop Filter）阻抗為 $Z(s) = R_p + \frac{1}{sC_p}$。
   - VCO 轉移函數為 $\frac{K_{vco}}{s}$。
   - 由於 CDR 的 Clock 直接與 Data 比較，相當於除頻比 $M=1$ 的 PLL，開迴路增益 $L(s) = \frac{I_p}{2\pi} \cdot (R_p + \frac{1}{sC_p}) \cdot \frac{K_{vco}}{s}$。

2. **閉迴路轉移函數 $T(s)$**:
   $$T(s) = \frac{\phi_{out}(s)}{\phi_{in}(s)} = \frac{L(s)}{1+L(s)} = \frac{ \frac{I_p K_{vco}}{2\pi s} (R_p + \frac{1}{sC_p}) }{ 1 + \frac{I_p K_{vco}}{2\pi s} (R_p + \frac{1}{sC_p}) }$$
   上下同乘 $s^2 C_p$ 整理後得到：
   $$T(s) = \frac{ \frac{I_p K_{vco} R_p}{2\pi} s + \frac{I_p K_{vco}}{2\pi C_p} }{ s^2 + \frac{I_p K_{vco} R_p}{2\pi} s + \frac{I_p K_{vco}}{2\pi C_p} }$$

3. **對照標準二階系統 $s^2 + 2\zeta\omega_n s + \omega_n^2$**:
   - 自然頻率 $\omega_n = \sqrt{\frac{I_p K_{vco}}{2\pi C_p}}$
   - 阻尼比 $\zeta = \frac{R_p}{2} \sqrt{\frac{I_p C_p K_{vco}}{2\pi}}$ （與 $M=1$ 的 PLL 完全相同）

4. **過阻尼近似 (Regular Wireline Application)**:
   - 在常規有線通訊中，為了抑制 Jitter Peaking，會設計成高度過阻尼 ($\zeta \gg 1$)。
   - 在關心的迴路頻寬附近，$s \approx 2\zeta\omega_n$，此時 $2\zeta\omega_n s \gg \omega_n^2$ 且 $s^2 \gg \omega_n^2$。
   - 轉移函數可近似降階：
     $$T(s) \approx \frac{2\zeta\omega_n s}{s^2 + 2\zeta\omega_n s} = \frac{2\zeta\omega_n}{s + 2\zeta\omega_n}$$
   - 系統降階為一階低通濾波器，其迴路頻寬 $\omega_{3dB} = 2\zeta\omega_n = \frac{I_p R_p K_{vco}}{2\pi}$。

### 單位解析
**公式單位消去：**
針對迴路頻寬公式 $\omega_{3dB} = \frac{I_p \cdot R_p \cdot K_{vco}}{2\pi}$：
- $I_p$: $[A]$ (安培)
- $R_p$: $[\Omega] = [V/A]$ (歐姆)
- $K_{vco}$: $[rad/s/V]$ (每伏特產生多少角頻率變化)
- $2\pi$: $[rad]$ (相位差週期)
- 推導：$[A] \times [V/A] \times [rad/s/V] \div [rad] = [V] \times [rad/s/V] \div [rad] = [rad/s] \div [rad] = [1/s] = [rad/s]$ (角頻率單位)。

**圖表單位推斷：**
📈 圖表一：Linear PD 轉移曲線 ($I_{av}$ vs $\Delta\phi$)
- X 軸：輸入資料與時脈的相位差 $\Delta\phi$ $[rad]$，典型範圍 $-2\pi \sim 2\pi$
- Y 軸：Charge Pump 平均輸出電流 $I_{av}$ $[\mu A]$，典型範圍 $-I_p \sim I_p$ (例如 $\pm 100 \mu A$)

📈 圖表二：VCO Tuning Curve ($\omega_{osc}$ vs $V_{ctrl}$)
- X 軸：VCO 控制電壓 $V_{ctrl}$ $[V]$，典型範圍 $0.4V \sim 1.2V$
- Y 軸：振盪角頻率 $\omega_{osc}$ $[rad/s]$ 或實體頻率 $f_{osc}$ $[GHz]$，典型範圍視規格而定 (例如 $10GHz \pm 10\%$)

### 白話物理意義
Linear CDR 在數學結構上就是一個「除頻比等於 1 的 PLL」。為了確保長途傳輸不會放大雜訊（Jitter Peaking），我們會刻意把系統阻尼（$\zeta$）調得超大，讓它的頻率響應退化成一個極度平滑的「一階系統」，此時 CDR 的反應速度（頻寬）就只由電阻決定，不受電容影響。

### 生活化比喻
這就像是一台避震器（阻尼 $\zeta$）調到最硬的跑車。雖然遇到坑洞（相位突變）時不會上下來回彈跳（無 Ringing / Peaking），但方向盤的轉向回饋變得非常直接且線性（一階反應）。這台車的轉向靈敏度（迴路頻寬）完全取決於方向盤傳動軸的剛性（電阻 $R_p$），跟你輪胎的氣充多飽（電容 $C_p$）毫無關係。

### 面試必考點
1. **問題：在 Wireline CDR 中，為什麼要將阻尼比 $\zeta$ 設計得遠大於 1（過阻尼）？**
   → **答案**：為了消除或極小化 Jitter Peaking。在 PCIe、SONET 等長距離或串接多個 Repeater 的通訊標準中，任何微小的 Peaking 都會在傳輸鏈中被指數放大，導致眼圖閉合與系統崩潰。
2. **問題：在 $\zeta \gg 1$ 的近似下，Linear CDR 的迴路頻寬（Loop Bandwidth）由哪些參數決定？**
   → **答案**：由 $\omega_{3dB} \approx \frac{I_p R_p K_{vco}}{2\pi}$ 可知，頻寬完全由 Charge pump 電流 ($I_p$)、迴路濾波器電阻 ($R_p$) 和 VCO 增益 ($K_{vco}$) 決定，**與電容 $C_p$ 無關**。
3. **問題：請說明筆記左上角 Dual Loop CDR 架構中，「w/i Reference」和「w/o Reference」的主要差別？**
   → **答案**：「w/i Reference (有參考時脈)」架構利用外部乾淨的 Reference Clock 透過 PFD 進行鎖頻（Frequency Loop）；「w/o Reference (無參考時脈)」架構則必須直接從輸入的隨機資料（Din）中利用 Frequency Detector (FD) 萃取頻率資訊來鎖頻。兩者都在鎖頻（Lock Det. 觸發）完成後，切換到 PD Loop 進行精準的相位追蹤。

**記憶口訣：**
線性CDR就是大阻尼PLL，避震太硬沒Peaking，頻寬只看電阻R（不管電容C）！
