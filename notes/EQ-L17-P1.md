# EQ-L17-P1

> 分析日期：2026-04-06
> 原始圖片：images/done/EQ-L17-P1.jpg

---


---
## 拿掉 Slicer 的 DFE 穩定度分析與 Z 轉換 (DFE Stability & IIR Filter Model)

### 數學推導
在分析 DFE (Decision Feedback Equalizer) 的本質穩定度時，我們通常會先進行一個重要假設：「**Neglect the slicer**」（忽略判決器）。因為 Slicer 是一個強烈的非線性元件，忽略它能讓我們使用線性系統的工具（如 Z-transform）來檢視迴路結構。

1. **建立差分方程式 (Difference Equation)：**
   根據筆記左上的方塊圖，拿掉 Slicer 後，系統變成一個標準的 IIR (Infinite Impulse Response) 濾波器。
   前向路徑 (Feedforward) 增益為 1，回授路徑 (Feedback) 有多個 Tap，係數為 $-\alpha_1, -\alpha_2, \dots, -\alpha_N$。
   輸出 $y[n]$ 可以表示為輸入 $x[n]$ 加上所有回授項：
   $y[n] = x[n] - \alpha_1 y[n-1] - \alpha_2 y[n-2] - \dots - \alpha_N y[n-N]$
   *(注意：一般 DFE 是減去干擾，但這裡根據方塊圖的加法器與 $-\alpha_i$ 標示來列式)*

2. **轉換至 Z 域 (Z-transform)：**
   對等號兩邊取 Z 轉換（利用時間延遲性質 $y[n-k] \leftrightarrow z^{-k}Y(z)$）：
   $Y(z) = X(z) - \alpha_1 z^{-1} Y(z) - \alpha_2 z^{-2} Y(z) - \dots - \alpha_N z^{-N} Y(z)$
   移項整理：
   $Y(z) \cdot [1 + \alpha_1 z^{-1} + \alpha_2 z^{-2} + \dots + \alpha_N z^{-N}] = X(z)$

3. **求得轉移函數 (Transfer Function) $H(z)$：**
   $H(z) = \frac{Y(z)}{X(z)} = \frac{1}{1 + \alpha_1 z^{-1} + \alpha_2 z^{-2} + \dots + \alpha_N z^{-N}}$

4. **利用部分分式展開 (Partial-Fraction Expansion) 找極點：**
   為了找極點，我們可以將分母因式分解，並將 $H(z)$ 展開為多項式之和：
   $H(z) = \frac{1}{1 - a z^{-1}} + \dots + \frac{1 - a \cos(\omega_0) z^{-1}}{1 - 2a \cos(\omega_0) z^{-1} + a^2 z^{-2}} + \dots$
   - **實數極點 (Real poles)：** 對應 $\frac{1}{1 - a z^{-1}}$，極點在 $z = a$。
   - **共軛複數極點 (Complex conjugate poles)：** 對應二次式分母 $(1 - a e^{j\omega_0} z^{-1})(1 - a e^{-j\omega_0} z^{-1})$，極點在 $z = a e^{\pm j\omega_0}$，極點到原點距離為 $|a|$。

5. **穩定度條件判斷 (BIBO Stability)：**
   - **Causal System (因果系統)：** 系統的收斂域 (Region of Convergence, RoC) 必定在最外圍極點的外部，即 $|z| > |a|$。
   - **BIBO Stable (有界輸入有界輸出穩定)：** 穩定系統的 RoC 必須包含**單位圓 ($|z| = 1$)**。
   - **結論：** 因此，必須滿足 $|a| < 1$。也就是說，**所有極點都必須落在 Z 平面的單位圓內**，系統才不會發散。

6. **不穩定範例驗證：**
   若給定一個極端情況，回授係數為 1，轉移函數為 $H(z) = \frac{1}{1 - z^{-1}}$ (極點在 $z=1$，剛好在單位圓上)。
   輸入一個單位脈衝 $x[n] = \delta[n] = \{\dots, 0, 0, 1, 0, 0, \dots\}$
   輸出會不斷累積：$y[n] = x[n] + y[n-1] \Rightarrow y[n] = \{\dots, 0, 0, 1, 1, 1, \dots\}$
   這是一個 Step function（步階函數），能量無限大，證明了極點 $|a| \ge 1$ 會導致系統不穩定（Unstable）。

### 單位解析
**公式單位消去：**
- $y[n] = x[n] - \alpha_1 y[n-1]$
  若 $x[n]$ 為接收端的電壓訊號 $[\text{V}]$，則輸出 $y[n]$ 亦為 $[\text{V}]$。
  由此可知，DFE 的 Tap 係數 $\alpha_1$ 必須是**無因次量 (Dimensionless)**：$[\text{V}] / [\text{V}] = [1]$。
- **連續與離散 Impulse 定義的物理意義：**
  - 連續時間 $\int_{-\infty}^{\infty} \delta(t) dt = 1$：時間 $t$ 單位為 $[\text{s}]$，積分結果無單位 $[1]$，故 $\delta(t)$ 的單位為 $[\text{s}^{-1}]$。
  - 離散時間 $\sum \delta[n] = 1$：Index $n$ 為樣本數 $[1]$（無單位），故 $\delta[n]$ 為純數 $[1]$ 或直接對應電壓單位 $[\text{V}]$。

**圖表單位推斷：**
1. 📈 **Z-plane 圖：**
   - X 軸：實部 $\text{Re}(z)$ [無單位]，範圍通常在 $\pm 1$ 附近看單位圓。
   - Y 軸：虛部 $\text{Im}(z)$ [無單位]，範圍通常在 $\pm 1$ 附近看單位圓。
2. 📈 **連續時間脈衝 $\delta(t)$ 圖：**
   - X 軸：時間 $t$ [s] (在 SerDes 中通常為 ps 級別)。
   - Y 軸：振幅 $[\text{s}^{-1}]$ 或當作理想電壓 $[\text{V}]$，高度趨近 $\infty$，寬度趨近 0。
3. 📈 **離散時間脈衝 $\delta[n]$ 圖：**
   - X 軸：取樣點 Index $n$ [無單位] (整數)。
   - Y 軸：振幅 $x[n]$ [V] 或無單位，典型值為 1。

### 白話物理意義
DFE 把判決器 (Slicer) 拿掉後，就等同於一個帶有「無限歷史記憶」的回授濾波器；如果回授權重太大（極點跑出單位圓），一個小小的干擾就會在迴路裡無限放大，導致整個接收器系統崩潰。

### 生活化比喻
這就像是在 KTV 唱歌，麥克風（輸入 $x[n]$）收到聲音後從喇叭（輸出 $y[n]$）放出來，聲音又傳回麥克風產生回授（Feedback $\alpha_i$）。
如果擴大機的音量旋鈕（極點大小 $|a|$）轉得太大（$|a| \ge 1$），哪怕你只是輕輕拍一下麥克風（輸入脈衝 $\delta[n]$），喇叭就會發出無限放大的刺耳「嘰——」尖叫聲（Unstable）。只有把音量控制在安全範圍內（極點在單位圓內 $|a| < 1$），殘響才會漸漸消失。

### 面試必考點
1. **問題：在分析 DFE 架構時，為什麼第一步通常是 "Neglect the slicer"（忽略判決器）？這樣分析有什麼物理意義？**
   - **答案：** Slicer (Comparator) 是一個強烈的非線性元件 (Hard limiter)。為了能使用強大的線性系統理論（如 Z 轉換、極點分析、Bode Plot）來評估「回授迴路本身的本質穩定性」，我們必須先將其簡化為線性模型 (即 IIR Filter)。如果在線性模型下系統都不穩定（極點在單位圓外），在實際電路中極容易產生嚴重的 Error Propagation（錯誤傳播）或 Limit Cycle（極限環震盪）。

2. **問題：DFE 是一個 FIR 還是 IIR Filter？要滿足 BIBO 穩定的數學條件是什麼？**
   - **答案：** DFE 在結構上包含輸出到輸入的回授 (Feedback)，因此在忽略 Slicer 的情況下，它等同於一個 IIR (Infinite Impulse Response) Filter（CTLE 和 FFE 才是 FIR）。要滿足 BIBO 穩定，其 Z 域轉移函數的所有極點 (Poles) 絕對值都必須小於 1，也就是必須全部落在 Z 平面的**單位圓內**。

3. **問題：筆記最後寫道 "Actually DFE may have a more stringent condition to stay stable" (實際上 DFE 有更嚴格的穩定條件)，請問這在實際 SerDes 系統設計中是指什麼現象？**
   - **答案：** 即使極點在單位圓內（線性系統穩定），實際帶有 Slicer 的 DFE 會面臨 **Error Propagation (錯誤傳播)** 的問題。如果通道雜訊導致 Slicer 發生了一個 bit 的誤判，這個錯誤的值會乘上 Tap 係數 ($\alpha_i$) 加回下一個 bit 的判斷中。如果 Tap 係數絕對值總和過大（例如 $\sum |\alpha_i| > 1$），這個單一錯誤就可能觸發一連串的連續錯誤 (Burst Errors)。因此，實際 DFE Tap 係數的上限限制，通常會比單純看「極點是否在單位圓內」還要嚴格得多。

**記憶口訣：**
> **「DFE 穩定三部曲：拔 Slicer 變 IIR，極點塞進單位圓，防 Error 傳播限 Tap 值！」**
