# EQ-L2-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/EQ-L2-P1.jpg

---


---
## 傳輸線通道損耗 (Wireline Channel Loss) - 介電損耗主導與 ISI

### 數學推導
這頁筆記推導了當傳輸線被**介電損耗 (Dielectric loss)** 主導時，單一位元脈波 (Pulse) 經過通道後的時域波形，藉此評估 ISI (符元間干擾) 的嚴重程度。

**Step 1: 建立通道頻率響應模型**
假設介電損耗主導，通道轉移函數的振幅隨頻率 $f$ 呈指數衰減：
$G(f) = \exp(-k_d \cdot l \cdot |f|)$ 
（註：筆記中寫 $f$，但在做傅立葉逆轉換時，物理上的頻譜必須具備共軛對稱性，因此隱含對絕對值 $|f|$ 積分）

**Step 2: 求通道的脈衝響應 (Impulse Response) $G(t)$**
將頻域轉回時域，利用傅立葉逆轉換：
$G(t) = \mathcal{F}^{-1}\{G(f)\} = \int_{-\infty}^{\infty} \exp(-k_d \cdot l \cdot |f|) \cdot \exp(j2\pi ft) df$
將積分拆分為正負頻率兩部分：
$= \int_{-\infty}^{0} \exp(f(k_d l + j2\pi t)) df + \int_{0}^{\infty} \exp(-f(k_d l - j2\pi t)) df$
解積分得到：
$= \frac{1}{k_d l + j2\pi t} + \frac{1}{k_d l - j2\pi t} = \frac{(k_d l - j2\pi t) + (k_d l + j2\pi t)}{(k_d l)^2 + (2\pi t)^2}$
$G(t) = \frac{2 k_d \cdot l}{k_d^2 l^2 + 4\pi^2 t^2}$
（這是一個羅倫茲分佈 Lorentzian distribution，特徵是拖著很長的尾巴）

**Step 3: 求單一脈波響應 (Pulse Response) $y(t)$**
輸入 $x(t)$ 是一個振幅為 $V_0$，寬度為 $T_b$ (1 個 bit 週期) 的方波。輸出為輸入與脈衝響應的卷積：
$y(t) = x(t) * G(t) = \int_{0}^{T_b} V_0 \cdot \frac{2 k_d l}{k_d^2 l^2 + 4\pi^2 (t-\tau)^2} d\tau$
令代換變數 $u = \frac{2\pi(t-\tau)}{k_d l}$，則 $du = \frac{-2\pi}{k_d l} d\tau \Rightarrow d\tau = \frac{-k_d l}{2\pi} du$
積分式化簡為 $\int \frac{1}{1+u^2} du = \tan^{-1}(u)$ 形式，代入上下界 $\tau = 0$ 與 $\tau = T_b$：
$y(t) = \frac{V_0}{\pi} \left[ \tan^{-1}\left(\frac{2\pi t}{k_d l}\right) - \tan^{-1}\left(\frac{2\pi(t-T_b)}{k_d l}\right) \right]$

**Step 4: 尋找脈波響應的最大峰值 $y_{1,max}$**
為了找最大值，對 $t$ 微分並令 $\frac{dy}{dt} = 0$。由波形對稱性可知，峰值必發生在脈波正中央，即 $t = \frac{T_b}{2}$：
$y_{1,max} = y\left(\frac{T_b}{2}\right) = \frac{V_0}{\pi} \left[ \tan^{-1}\left(\frac{\pi T_b}{k_d l}\right) - \tan^{-1}\left(\frac{-\pi T_b}{k_d l}\right) \right]$
利用 $\tan^{-1}(-x) = -\tan^{-1}(x)$ 的奇函數特性：
$y_{1,max} = \frac{2V_0}{\pi} \tan^{-1}\left(\frac{\pi T_b}{k_d l}\right)$
（這個值代表經過通道後，原本高為 $V_0$ 的信號「最高還能剩多少」）

### 單位解析
**公式單位消去：**
1. **衰減指數 $\exp(-k_d \cdot l \cdot f)$**：指數內部必須為無單位 (dimensionless)。
   - 頻率 $f$ 單位為 $[\text{Hz}] = [1/\text{s}]$
   - 長度 $l$ 單位為 $[\text{m}]$
   - 故介電損耗常數 $k_d$ 的單位必須是 $[\text{s/m}]$。
   - $[-k_d \cdot l \cdot f] \Rightarrow [\text{s/m}] \times [\text{m}] \times [1/\text{s}] = [1]$ (無單位，合理)。
2. **脈衝響應 $G(t) = \frac{2 k_d l}{(k_d l)^2 + 4\pi^2 t^2}$**：
   - 分子 $[2 k_d l] \Rightarrow [\text{s/m}] \times [\text{m}] = [\text{s}]$
   - 分母 $[(k_d l)^2 + 4\pi^2 t^2] \Rightarrow [\text{s}^2]$
   - 整體 $[G(t)] = [\text{s}] / [\text{s}^2] = [1/\text{s}]$。這在卷積積分中 $\int G(t) d\tau$ 會與 $d\tau$ 的 $[\text{s}]$ 消掉，符合系統理論預期。
3. **輸出電壓 $y_{1,max} = \frac{2V_0}{\pi} \tan^{-1}\left(\frac{\pi T_b}{k_d l}\right)$**：
   - $\tan^{-1}$ 內部參數：$[T_b] / [k_d l] \Rightarrow [\text{s}] / ([\text{s/m}] \times [\text{m}]) = [\text{s}]/[\text{s}] = [1]$ (角度無單位，合理)。
   - 外側乘數：$\frac{2V_0}{\pi} \Rightarrow [\text{V}]$。
   - 最終 $y_{1,max}$ 單位為 $[\text{V}]$，電壓推導無誤。

**圖表單位推斷：**
* 📈 **左下圖 (Input $x(t)$ / Output $y(t)$)**
  - X 軸：時間 $t$ $[\text{ps}]$ 或 $[\text{UI}]$，典型範圍 $0 \sim T_b$。
  - Y 軸：電壓 $[\text{mV}]$，典型範圍 $0 \sim V_0$ (例如 $800\text{mV}$)。
* 📈 **中下圖 (Channel Loss vs. Freq)**
  - X 軸：頻率 $f$ $[\text{GHz}]$，關鍵標示點為 Nyquist frequency $\frac{1}{2T_b}$。
  - Y 軸：損耗振幅 $|G(f)|$ $[\text{dB}]$。
* 📈 **右下圖 (Eye Diagram 眼圖)**
  - X 軸：時間 $[\text{UI}]$，典型範圍顯示 1~2 個 Unit Interval。
  - Y 軸：電壓 $[\text{mV}]$，標示了最佳情況(全0或全1的穩態)以及最差情況(Eye opening)。筆記標示在特定 Loss 下眼高僅剩 $19.4\%$。

### 白話物理意義
訊號在傳輸線上跑，因為介質會像海綿吸水一樣「吃掉」高頻能量，導致原本方正俐落的數位訊號「糊掉並向外擴散」，自己變矮的同時還踩到前後 bit 的地盤，這就是造成眼圖閉合的元凶 ISI。

### 生活化比喻
想像你在濃霧中（介質）對著遠方快速閃爍手電筒發送摩斯密碼。霧氣不僅會讓光變暗（Loss），還會讓光暈開（Pulse widening）。如果你閃得太快（高傳輸率 $1/T_b$ 大），前一次閃光的殘影還沒散去，下一次閃光又亮了，遠方的人看到的就會是一團持續發亮、根本分不清間隔的爛泥（Eye fully closed）。

### 面試必考點
1. **問題：在 Dielectric Loss 主導的通道中，Nyquist Frequency ($1/2T_b$) 的 Loss 達到多少 dB 時，眼圖會完全閉合 (fully closed)？**
   - **答案：** 13.65 dB。如筆記最下方結論，當 Nyquist loss 達 13.65 dB 時，單一脈波的峰值 $y_{1,max}$ 衰減過多，且長尾巴累積的 Pre/Post-cursor ISI 總和剛好大於等於主游標能量，導致最差情況下的眼高 (Eye opening) 降為 0。
2. **問題：寫出 Dielectric Loss Dominant 通道的脈波時域響應形狀，並說明這對 EQ 設計有什麼影響？**
   - **答案：** 時域響應為 $\tan^{-1}$ 函數的相減（源自羅倫茲分佈的卷積）。其致命特徵是具有「衰減極慢的長尾巴 (Long Tail)」。這意味著 Post-cursor ISI 會綿延很多個 UI，因此在接收端通常需要 Tap 數目較多的 DFE (Decision Feedback Equalizer) 才能有效消除後續干擾。
3. **問題：為什麼我們評估 Channel Loss 時，特別愛看 Nyquist Frequency ($1/2T_b$) 這個點？**
   - **答案：** 因為在數位通訊中，最高頻且最密集的訊號變化是「010101...」的交替圖樣，這時的基頻剛好就是 $\frac{1}{2T_b}$ (即 Nyquist freq)。評估此頻率的衰減量，就能快速且保守地掌握通道對資料傳輸最嚴苛的低通濾波效應。

**記憶口訣：**
介電損耗看指數，時域拉成羅倫茲；
一三六五 dB 值 (13.65)，眼圖閉合入土時。

---
### 😈 助教的費曼測試（自我驗證）
如果你覺得你懂了，試著回答：
* **反事實：** 「如果今天通道不是介電損耗主導，而是『集膚效應 (Skin Effect)』主導，通道轉移函數的指數項 $f$ 會變成什麼？時域的尾巴會變長還是變短？」 *(提示：會變成 $\sqrt{f}$，尾巴會更長更難搞！)*
* **情境遷移：** 「你知道 13.65 dB 眼圖就全關了，但現在 PCIe Gen5/Gen6 通道 Loss 動輒 30~40 dB，訊號是怎麼活下來的？」 *(提示：這就是為什麼我們需要 TX FFE, RX CTLE 和 DFE 聯手把這 30dB 補回來！)*
