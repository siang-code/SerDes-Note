# EQ-L5-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/EQ-L5-P1.jpg

---

---
## Feed-forward Equalizer (FFE)

### 數學推導
筆記中展示了 Two-tap FFE 以及推廣至多階 (2M+1 taps) FFE 的數學模型。

1. **Two-tap FFE 時域方程式 (Time-domain):**
   - 根據右上方的方塊圖，輸入信號 $x(t)$ 分成兩條路徑。一條直接饋送（權重為 1），另一條經過時間為 $T_b$（Bit period）的延遲後，乘上權重係數 $\alpha$。
   - 輸出 $y(t)$ 為這兩路信號的疊加：
     $y(t) = x(t) + \alpha \cdot x(t - T_b)$
   - 筆記特別標註條件為 $-1 < \alpha < 0$，這代表該等化器具有抵銷前一個 bit 影響（De-emphasis/Pre-emphasis）的作用，能提供高頻補償。

2. **轉換至 S 域 (Laplace Transform):**
   - 假設系統起始狀態為零，對時域方程式兩邊取 Laplace 轉換：
     $Y(s) = X(s) + \alpha \cdot X(s)e^{-sT_b}$
   - 整理後可得轉移函數 $H(s)$：
     $H(s) = \frac{Y(s)}{X(s)} = 1 + \alpha e^{-sT_b}$

3. **頻率響應 (Frequency Response):**
   - 將 $s$ 替換為 $j\omega$（其中 $\omega = 2\pi f$），以觀察系統在頻域的穩態響應：
     $H(j\omega) = 1 + \alpha e^{-j\omega T_b}$
   - 利用尤拉公式（Euler's formula） $e^{-j\theta} = \cos\theta - j\sin\theta$ 展開：
     $H(j\omega) = 1 + \alpha [\cos(\omega T_b) - j\sin(\omega T_b)] = [1 + \alpha\cos(\omega T_b)] - j[\alpha\sin(\omega T_b)]$

4. **振幅響應 $|H(j\omega)|$ 與 相位響應 $\angle H(j\omega)$:**
   - **振幅（Magnitude）：** 實部平方加虛部平方開根號
     $|H(j\omega)| = \sqrt{[1 + \alpha\cos(\omega T_b)]^2 + [-\alpha\sin(\omega T_b)]^2}$
     $|H(j\omega)| = \sqrt{1 + 2\alpha\cos(\omega T_b) + \alpha^2\cos^2(\omega T_b) + \alpha^2\sin^2(\omega T_b)}$
     提出 $\alpha^2$ 並利用 $\cos^2\theta + \sin^2\theta = 1$ 的三角恆等式化簡：
     $|H(j\omega)| = \sqrt{1 + \alpha^2 + 2\alpha\cos(\omega T_b)}$
   - **相位（Phase）：** 虛部除以實部取反正切
     $\angle H(j\omega) = \tan^{-1}\left[\frac{-\alpha\sin(\omega T_b)}{1 + \alpha\cos(\omega T_b)}\right]$
   - 筆記註解「Monotonic increasing response from DC to Nyquist」，表示因為 $\alpha < 0$，在 DC ($\omega=0$) 時增益最小為 $1+\alpha$，在 Nyquist ($\omega=\pi/T_b$) 時增益最大為 $1-\alpha$。

5. **推廣至 2M+1 Taps FFE:**
   - 如右下方方塊圖所示，一個具有中心 Tap 以及前後各 M 個 Tap 的 FFE，其離散時間方程式為：
     $y[n] = \alpha_{-M} x[n] + \alpha_{-M+1} x[n-1] + \dots + \alpha_{M} x[n-2M]$
   - 經過 Z 轉換（延遲一單位對應 $z^{-1}$）：
     $H(z) = \alpha_{-M} + \alpha_{-M+1} z^{-1} + \dots + \alpha_M z^{-2M} = \sum_{k=0}^{2M} \alpha_{-M+k} z^{-k}$
   - **重要結論：** Z 域與 S 域的對應關係為 $z = e^{sT_b} = e^{j\omega T_b}$。因為這是一個純前饋架構，數學上等同於 FIR (Finite Impulse Response) Filter，沒有回授項，極點只會存在於原點，故**「無條件穩定 (Unconditionally stable)」**。

### 單位解析
**公式單位消去：**
- $y(t) = x(t) + \alpha \cdot x(t - T_b)$
  - $x(t)$ 與 $y(t)$：電壓 [V] 或電流 [A]
  - $\alpha$：Tap weight，電壓增益或比例常數，無因次 [V/V] = [1]
  - 單位一致性檢驗：$[V] = [V] + [1] \times [V]$，等式兩邊單位一致。
- $z = e^{sT_b}$
  - $s$：複數頻率，單位為 $[s^{-1}]$ 或 $[rad/s]$
  - $T_b$：Bit period 時間，單位為 $[s]$
  - $sT_b$：相乘後為 $[s^{-1}] \times [s] = [1]$（無因次）。指數函數 $e$ 的次冪必須為無因次，且 Z 轉換變數 $z$ 本身無因次，物理邏輯完美吻合。

**圖表單位推斷：**
📈 Magnitude Response ($|H|$ vs. $f$) 圖表推斷：
- X 軸：頻率 $f$ [Hz] 或 [GHz]。標示了關鍵頻率點：$\frac{1}{2T_b}$ (Nyquist frequency) 與 $\frac{1}{T_b}$ (Data Rate)。
- Y 軸：系統振幅增益 $|H|$ [V/V]（若取 log 則為 [dB]）。在 DC 時增益為 $1+\alpha$（較低），在 Nyquist 頻率時增益 peaking 到最高點 $1-\alpha$。

📈 Phase Response ($\angle H$ vs. $f$) 圖表推斷：
- X 軸：頻率 $f$ [Hz] 或 [GHz]，範圍同上。
- Y 軸：相位角 $\angle H$ [Degree] 或 [Radian]。典型範圍通常在 $-90^\circ \sim +90^\circ$。從圖中可見在 DC ($f=0$) 與 Nyquist ($f=\frac{1}{2T_b}$) 處，相位角皆回歸為 0。

### 白話物理意義
FFE 就是一個「參考歷史來修正現在」的等化器，它故意把之前的信號乘上負值並加到現在的信號中，用來扣除通道造成的殘留尾巴（ISI），把本來衰減的高頻給「凸顯」出來。

### 生活化比喻
FFE 就像是一個「會記仇且能自動降噪的傳聲筒」。如果通道是一條會產生嚴重低頻回音（ISI）的長廊，FFE 傳聲筒在收到現在這句「喂」的時候，會故意把上一句「喂」的聲音反相（乘上負係數 $\alpha$）播出來。這樣一來，長廊產生的多餘回音剛好被反相的聲音抵銷掉，讓你聽到最乾淨清晰的原始對話。而且它只看輸入，不會把喇叭播出的聲音再吸進麥克風，所以絕對不會產生那種刺耳的無限回授尖叫聲（無條件穩定）。

### 面試必考點
1. **問題：為什麼 FFE (Feed-forward Equalizer) 在系統穩定度上是「無條件穩定 (Unconditionally stable)」？**
   → 答案：因為 FFE 屬於 FIR (Finite Impulse Response) 架構，訊號只有前饋路徑而沒有回授路徑。在 Z 轉換的轉移函數中，它的分母為常數（極點全在 Z 平面的原點 $z=0$），不可能落在單位圓之外，因此絕對不會發散震盪。
2. **問題：如果通道表現出低通特性（高頻衰減），在 Two-tap FFE 中 $\alpha$ 值應該設正還是設負？為什麼？**
   → 答案：應該設為負值（$-1 < \alpha < 0$）。代入振幅公式 $|H(j\omega)| = \sqrt{1+\alpha^2+2\alpha\cos(\omega T_b)}$ 可知，當 $\alpha$ 為負時，DC 增益（$\omega=0$, $\cos=1$）為 $1+\alpha$ 較小，而 Nyquist 頻率（$\omega=\pi/T_b$, $\cos=-1$）增益為 $1-\alpha$ 較大。這樣能形成高頻強調（Peaking），剛好補償通道的高頻損耗。
3. **問題：請推導 Two-tap FFE 在 Nyquist frequency 的轉移函數增益大小？**
   → 答案：Nyquist 頻率為 $f = \frac{1}{2T_b}$，對應角頻率 $\omega = 2\pi f = \frac{\pi}{T_b}$。
   此時 $\omega T_b = \pi$，而 $\cos(\pi) = -1$。
   代入振幅公式：$|H| = \sqrt{1 + \alpha^2 + 2\alpha(-1)} = \sqrt{1 - 2\alpha + \alpha^2} = \sqrt{(1-\alpha)^2} = 1 - \alpha$。

**記憶口訣：**
**FFE 無回授必穩定，負 $\alpha$ 壓低頻拉高頻，Nyquist 算一算 $\cos(\pi)$ 變減號。**
