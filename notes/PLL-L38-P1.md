# PLL-L38-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L38-P1.jpg

---


---
## Fractional-N PLL Sigma-Delta 量化雜訊推導

### 數學推導
筆記完整推導了小數除頻器（Fractional-N）中 Sigma-Delta ($\Sigma\Delta$) 調變器所造成的輸出相位雜訊。

1. **量化誤差的變異數（Quantization Noise Power）**：
   假設 $\Sigma\Delta$ 除頻器產生的除數變動（量化誤差 $q[n]$）符合均勻分佈（Uniform Distribution），分佈範圍在 $[-1/2, 1/2]$，因此機率密度函數 $f_Q(x) = 1$。
   計算其變異數（即雜訊總功率）：
   $$ \Delta^2 = \int_{-\infty}^{\infty} (x-m)^2 \cdot f_Q(x) dx = \int_{-1/2}^{1/2} x^2 \cdot 1 dx = \left. \frac{x^3}{3} \right|_{-1/2}^{1/2} = \frac{1}{12} $$

2. **頻率誤差的功率頻譜密度 (PSD)**：
   由於每個取樣點在時間 $T$ 內保持定值（Zero-Order Hold 的方波），其頻譜為單一脈衝的傅立葉轉換。根據定義 $S_Q(\omega) = \frac{\Delta^2}{T} |P(\omega)|^2$：
   $$ S_Q(\omega) = \frac{1}{12T} \left[ \frac{\sin(\omega T/2)}{\omega/2} \right]^2 $$
   這是一個具有主瓣（Main lobe）與旁瓣（Side lobes）的 Sinc 函數。

3. **從「頻率域」轉換至「相域」 (Frequency to Phase Conversion)**：
   除頻比的跳動本質上是「頻率」的誤差。由於相位是頻率的積分，在離散時間 (Discrete-time) 系統中，積分等同於一個累加器（Accumulator），其 Z 轉換為 $H(z) = \frac{1}{1-z^{-1}}$。
   根據 LTI 系統特性 ($S_Y = S_X \cdot |H|^2$)，未整形的相位雜訊頻譜為：
   $$ S_\Phi(z) = S_Q(z) \cdot \left| \frac{1}{1-z^{-1}} \right|^2 $$

4. **$\Sigma\Delta$ 雜訊整形 (Noise Shaping)**：
   使用 $m$ 階的 $\Sigma\Delta$ Modulator 會為雜訊乘上 $|1-z^{-1}|^{2m}$ 的高通濾波特性，將低頻雜訊推至高頻。
   結合積分效應後，相位雜訊的整形項為：
   $$ \left| \frac{1}{1-z^{-1}} \right|^2 \cdot |1-z^{-1}|^{2m} = |1-z^{-1}|^{2m-2} $$
   因為 $z = e^{j\omega T}$，代入歐拉公式可得 $|1-e^{-j\omega T}|^2 = 4\sin^2(\frac{\omega T}{2})$，所以整形項化簡為 $\left[ 2\sin(\frac{\omega T}{2}) \right]^{2m-2}$。

5. **PLL 迴路抑制 (Loop Suppression)**：
   雜訊從回授路徑進入後，等效於經過 PLL 的閉迴路低通濾波器。對於過阻尼（$\zeta \gg 1$）的系統，轉移函數可近似為：
   $$ \left| \frac{\Phi_{out}}{\Phi_{in}} \right|^2 \approx \frac{4\zeta^2\omega_n^2}{\omega^2 + 4\zeta^2\omega_n^2} \cdot (M+\alpha)^2 $$
   *(註：其中 $M+\alpha$ 為小數除頻的平均除頻比 $N_{frac}$)*

6. **總結輸出相位雜訊頻譜**：
   最終的 $S_{\Phi,\Sigma\Delta}$ 等於上述三者的乘積：**[1. Q noise spectrum]** $\times$ **[2. Noise shaping]** $\times$ **[3. Loop suppression]**
   $$ S_{\Phi,\Sigma\Delta} = \frac{1}{12T} \left[ \frac{\sin(\omega T/2)}{\omega/2} \right]^2 \cdot \left[ 2\sin\left(\frac{\omega T}{2}\right) \right]^{2m-2} \cdot \frac{4\zeta^2\omega_n^2}{\omega^2 + 4\zeta^2\omega_n^2} (M+\alpha)^2 $$

### 單位解析
**公式單位消去：**
* **變異數 $\Delta^2$**：$x$ 為除數誤差（無單位 [UI]），$f_Q(x)$ 為 [1/UI]。$\int x^2 f_Q(x) dx \Rightarrow [UI^2] \times [1/UI] \times [UI] = [UI^2]$（純數值方差）。
* **量化雜訊 PSD $S_Q(\omega)$**：$\frac{\Delta^2}{T} |P(\omega)|^2 \Rightarrow \frac{[UI^2]}{[s]} \times [s^2] = [UI^2 \cdot s]$。在頻域中 $[s] = [1/Hz]$，所以單位是 $[UI^2/Hz]$。
* **積分與整形 $|1-z^{-1}|^{2m-2}$**：Z 轉換的轉移函數，為純比例放大 [無單位]。
* **總相位雜訊 $S_{\Phi,\Sigma\Delta}$**：$[UI^2/Hz] \times [無單位] \times [無單位] = [UI^2/Hz]$（若乘上 $(2\pi)^2$ 則為工程上常用的 $[rad^2/Hz]$）。

**圖表單位推斷：**
1. **$q[n]$ 時域波形 (左上)**：
   - X 軸：時間 $t$ [s] 或離散指標 $n$。典型範圍：10~50 ns（視 Reference Clock 週期 $T$ 而定）。
   - Y 軸：除頻誤差 $q[n]$ [UI]。典型範圍：-0.5 UI ~ +0.5 UI。
2. **$f_Q(x)$ 機率密度函數 (中上)**：
   - X 軸：誤差值 $x$ [UI]。典型範圍：-1/2 ~ 1/2。
   - Y 軸：機率密度 [1/UI]。數值為常數 1。
3. **$S_Q(\omega)$ Sinc 頻譜 (左中)**：
   - X 軸：角頻率 $\omega$ [rad/s]。主瓣範圍：$-2\pi/T \sim 2\pi/T$。
   - Y 軸：頻率誤差的功率頻譜密度 [$UI^2/Hz$]。

### 白話物理意義
Sigma-Delta Modulator 把「除不盡」產生的小誤差（量化雜訊）透過高通濾波「推」到高頻去，接著 PLL 像一個大笨鐘一樣只對低頻有反應（低通濾波），完美地把高頻雜訊濾掉，最後輸出既精準又乾淨的頻率。

### 生活化比喻
想像你在切蛋糕給客人，客人想要剛好 3.14 塊（小數除頻）。你只能給 3 塊或 4 塊，這中間的誤差就是「量化雜訊」。
Sigma-Delta 調變器就像一個「花式發牌員」，有時候塞 3 塊，有時候塞 4 塊，平均下來剛剛好是 3.14，但他切換的速度極快（把雜訊推到高頻）。而客人的胃消化很慢（PLL 的低通濾波器），根本感覺不到忽大忽小的塊數差異，只覺得自己平穩地吃下了 3.14 塊蛋糕！

### 面試必考點
1. **問題：為什麼頻率誤差轉換成相位誤差時，需要乘上 $\frac{1}{1-z^{-1}}$？**
   $\rightarrow$ 答案：因為頻率是相位的微分（$f = \frac{1}{2\pi} \frac{d\Phi}{dt}$）。在離散時間系統中，相位的變化是頻率誤差的「累加（積分）」，對應的 Z 轉換轉移函數即為 $\frac{1}{1-z^{-1}}$。這個積分動作會使得低頻雜訊被放大（產生 1/f 特性）。
2. **問題：如果使用 $m$ 階的 Sigma-Delta Modulator，最終輸出相位的雜訊整形（Noise Shaping）階數為何是 $2m-2$ 而不是 $2m$？**
   $\rightarrow$ 答案：因為 $m$ 階 $\Sigma\Delta$ 針對「頻率」雜訊的整形能力是 $|1-z^{-1}|^{2m}$；但頻率轉為相位時具有 $|1-z^{-1}|^{-2}$ 的積分效應。兩者相乘抵銷一階，導致最終表現在「相位」上的整形階數降為 $2m-2$。
3. **問題：在 Fractional-N PLL 設計中，如何壓抑 $\Sigma\Delta$ 造成的高頻帶外雜訊 (Out-of-band noise)？**
   $\rightarrow$ 答案：有三個主要方向：(1) 降低 PLL 的迴路頻寬（降低 $\omega_n$）；(2) 在 Loop Filter 中增加極點（增加濾波器階數）；(3) 提高 Reference Clock 的頻率（等同增加超取樣率 OSR，讓雜訊被推到更遠的高頻）。

**記憶口訣：**
「除數跳動變 Sinc，頻轉相位減一階，高頻雜訊靠 Loop 濾」
