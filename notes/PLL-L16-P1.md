# PLL-L16-P1

> 分析日期：2026-04-04
> 原始圖片：images/PLL-L16-P1.jpg

---

這是一份極具價值的 PLL 系統雜訊最佳化筆記，探討了如何透過數學推導找出讓整體 RMS Jitter 最小的「最佳迴路頻寬 (Optimal Loop Bandwidth)」。這也是高速 SerDes 與頻率合成器面試中，最核心的鑑別題之一。

以下為您拆解這份筆記：

---
## [PLL 雜訊頻譜分析與最佳迴路頻寬推導]

### 數學推導
這段推導的目標是找出能使整體輸出的 RMS Jitter 最小的 PLL 頻寬（$\omega_{BW}$）。

1. **系統模型與雜訊頻譜定義：**
   將 PLL 視為線性非時變 (LTI) 系統，根據隨機訊號理論，輸出功率頻譜密度 (PSD) 等於輸入 PSD 乘上轉移函數大小的平方：
   $S_Y(s) = S_X(s) \cdot |H(s)|^2$
   PLL 的總輸出相位雜訊 $S_{\phi, out}(\omega)$ 是「輸入參考時脈雜訊」與「VCO 內部雜訊」經過各自轉移函數後的疊加：
   $S_{\phi, out}(\omega) = S_{\phi, in}(\omega) \cdot \left| \frac{\phi_{out}}{\phi_{in}} \right|^2 + S_{\phi, vco}(\omega) \cdot \left| \frac{\phi_{out}}{\phi_{vco}} \right|^2$

2. **Overdamped (過阻尼, $\zeta \gg 1$) 近似下的轉移函數：**
   為了簡化計算，當阻尼比 $\zeta$ 夠大時，系統可近似為一階系統（這是李致毅老師上課常用的分析技巧）：
   - **輸入雜訊轉移函數 (Low-Pass Filter, LPF)：**
     $\frac{\phi_{out}}{\phi_{in}} \approx \frac{M \cdot 2\zeta\omega_n}{s + 2\zeta\omega_n} = \frac{M \cdot \omega_{BW}}{s + \omega_{BW}}$
     (其中 $M$ 為除頻比，定義迴路頻寬 $\omega_{BW} \triangleq 2\zeta\omega_n$)
   - **VCO 雜訊轉移函數 (High-Pass Filter, HPF)：**
     $\frac{\phi_{out}}{\phi_{vco}} \approx \frac{s}{s + 2\zeta\omega_n} = \frac{s}{s + \omega_{BW}}$

3. **引入 VCO 雜訊物理模型：**
   忽略極低頻的閃爍雜訊 (Flicker noise, $1/f^3$)，將自由震盪的 VCO 相位雜訊視為受白雜訊積分影響，呈 $1/\omega^2$ 衰減：
   $S_{\phi, vco}(\omega) = S_{\phi, vco}(\omega_0) \cdot \frac{\omega_0^2}{\omega^2}$
   （以 $\omega_0$ 為參考頻率來表示整條曲線）

4. **輸出總雜訊頻譜展開：**
   將上述轉移函數與 VCO 模型代入總公式：
   $S_{\phi, out}(\omega) = S_{\phi, in} \cdot M^2 \cdot \frac{\omega_{BW}^2}{\omega^2 + \omega_{BW}^2} + \left( S_{\phi, vco}(\omega_0) \cdot \frac{\omega_0^2}{\omega^2} \right) \cdot \frac{\omega^2}{\omega^2 + \omega_{BW}^2}$
   **重點來了：** 第二項分子分母的 $\omega^2$ 剛好消掉！
   $S_{\phi, out}(\omega) = S_{\phi, in} \cdot M^2 \cdot \frac{\omega_{BW}^2}{\omega^2 + \omega_{BW}^2} + S_{\phi, vco}(\omega_0) \cdot \frac{\omega_0^2}{\omega^2 + \omega_{BW}^2}$

5. **計算 RMS Jitter 並求極值 (Optimal Bandwidth)：**
   RMS Jitter 變異數 $J_{rms}^2$ 等於相位雜訊頻譜對所有頻率積分：
   $J_{rms}^2 \triangleq \int_0^\infty S_{\phi, out}(f) df = \frac{1}{2} \left[ S_{\phi, in} \cdot M^2 \cdot \omega_{BW} + S_{\phi, vco}(\omega_0) \cdot \frac{\omega_0^2}{\omega_{BW}} \right]$
   *(註：這裡積分出來的第一項與頻寬成正比，第二項與頻寬成反比)*
   為了找出使 $J_{rms}^2$ 最小的 $\omega_{BW}$，對頻寬微分並設為 0：
   $\frac{\partial J_{rms}^2}{\partial \omega_{BW}} = \frac{1}{2} \left[ S_{\phi, in} \cdot M^2 - S_{\phi, vco}(\omega_0) \cdot \frac{\omega_0^2}{\omega_{BW}^2} \right] = 0$
   移項可得最優美的結論：
   $S_{\phi, in} \cdot M^2 = S_{\phi, vco}(\omega_0) \cdot \frac{\omega_0^2}{\omega_{BW,opt}^2}$
   這等同於：$S_{\phi, in} \cdot M^2 = S_{\phi, vco}(\omega_{BW,opt})$

### 單位解析
**公式單位消去：**
- **相位功率頻譜密度 (Phase PSD)** $S_{\phi}(\omega)$: 物理單位為 $[rad^2/Hz]$。對頻率 $[Hz]$ 積分會得到變異數 $[rad^2]$。
- **雜訊轉移函數大小平方** $|H(s)|^2$: 兩個相位變數的比例平方 $[rad/rad]^2 = [1]$ (無因次)。
- **總雜訊計算** $S_{\phi, out} = S_{\phi, in} \cdot |H_{in}|^2 + S_{\phi, vco} \cdot |H_{vco}|^2$: $[rad^2/Hz] \cdot [1] + [rad^2/Hz] \cdot [1] = [rad^2/Hz]$。
- **最佳頻寬條件等式檢查** $S_{\phi, in} \cdot M^2 = S_{\phi, vco}(\omega_0) \cdot \frac{\omega_0^2}{\omega_{BW,opt}^2}$:
  左邊: $[rad^2/Hz] \times [1]$ = $[rad^2/Hz]$
  右邊: $[rad^2/Hz] \times \frac{[rad/s]^2}{[rad/s]^2} = [rad^2/Hz]$，單位完美吻合！

**圖表單位推斷：**
筆記中畫了大量頻譜轉移圖，物理意義如下：
📈 **圖表一：整體轉移概念 (左方 3 張圖)**
- X 軸：角頻率 $\omega$ $[rad/s]$ (對數刻度)
- Y 軸：頻譜密度 $S_{\phi}$ $[rad^2/Hz]$ 或 轉移函數大小平方 $[1]$
- 觀察：Input White noise $[rad^2/Hz]$ 乘上 LPF (-20dB/dec 滾降)；VCO Flicker/Random walk noise (-20dB/dec 下降) 乘上 HPF (+20dB/dec 上升)。

📈 **圖表二：最佳頻寬圖解 (右下角大圖)**
- X 軸：角頻率 $\omega$ $[rad/s]$ (對數刻度)
- Y 軸：雜訊頻譜密度 $S$ $[rad^2/Hz]$ (對數刻度)
- 觀察：水平直線是經過放大的輸入雜訊 ($M^2 \cdot S_{\phi, in}$)，斜線是 VCO 自由震盪相位雜訊 ($S_{\phi, vco}(\omega)$)。**這兩條線的「交叉點」，在 X 軸的對應值就是最佳頻寬 $\omega_{BW, opt}$**！

### 白話物理意義
PLL 就像一個天平，頻寬太寬會把外部參考源的雜訊吃進來，頻寬太窄壓不住內部 VCO 的雜訊；最完美的頻寬（Jitter最小的點），就恰好在「外部雜訊（乘上除頻比後）」與「內部 VCO 雜訊」一樣大聲的那個頻率交界點上。

### 生活化比喻
想像你在一家吵雜的餐廳（VCO本身不穩定，有內部噪音）和老闆通電話（Reference Clock，有外部雜訊）。
- **頻寬很大（聽得很專心，追蹤力強）**：你可以把自己的雜音（VCO雜訊）壓得很低，但老闆電話裡的背景雜音（Input Noise）會被你完全聽進去。
- **頻寬很小（耳朵摀起來，不理外部）**：你聽不到老闆電話裡的雜音，但你自己因為聽不清楚而亂講話的錯誤（VCO自由震盪的累積雜訊）就會變得很嚴重。
- **最佳頻寬**：你調整耳機的降噪程度，剛好讓「電話傳來的雜訊」和「你自己分心產生的雜訊」達到一個最低的總和，這個甜蜜點正是兩邊雜訊聲量聽起來一樣大的地方！

### 面試必考點
1. **問題：在 PLL 設計中，如何決定最佳的 Loop Bandwidth 來最小化 RMS Jitter？**
   → **答案：** 最佳頻寬出現在 Reference noise 貢獻的 PSD (乘上除頻比平方 $M^2$) 等於 Free-running VCO phase noise PSD 的那個頻率點。數學上是藉由對總 Jitter 變異數微分求極值 $\frac{\partial J_{rms}^2}{\partial \omega_{BW}} = 0$ 得到的結果。
2. **問題：VCO 的 phase noise 經過 PLL 閉迴路後，從輸出端看，低頻部分的雜訊頻譜形狀會變成怎樣？**
   → **答案：** Free-running VCO phase noise 在頻域上呈 $1/f^2$ 衰減。經過 PLL 的 High-Pass 轉移函數 ($\propto f^2$) 壓抑後，兩者相乘抵銷（$1/f^2 \times f^2 = 1$），在迴路頻寬內 ($f < f_{BW}$) 會變成「平坦 (Flat)」的雜訊頻譜。所以 VCO 雜訊在閉迴路中，行為反而像是一個 LPF 的形狀。
3. **問題：如果把除頻比 $M$ 變大，為了維持最低的 Jitter，PLL 的頻寬應該要調大還是調小？**
   → **答案：** 調小。當 $M$ 變大時，等效輸入雜訊 $M^2 \cdot S_{\phi, in}$ 會上升（圖表上的水平線往上平移）。這條水平線與向右下傾斜的 VCO phase noise 曲線的交點會往「左邊（低頻）」移動，因此最佳頻寬 $\omega_{BW, opt}$ 必須縮小。

**記憶口訣：**
「**寬度取決於交點，M平乘入等於V**」
（最佳頻寬對應兩雜訊曲線交點：$M^2 \times S_{in} = S_{vco}(\omega)$，交點定江山。）
