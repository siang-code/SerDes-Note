# EQ-L4-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/EQ-L4-P1.jpg

---


---
## 基礎通道分析與眼圖閉合臨界點 (RC Channel & 13.3dB Rule)

### 數學推導
本頁筆記利用一個最簡單的一階 RC 低通濾波器來模型化傳輸通道 (Channel)，推導出在什麼情況下，ISI (Intersymbol Interference, 符元間干擾) 會嚴重到讓未等化的眼圖 (Un-equalized Eye) 完全閉合。

1. **定義單一脈波響應 (Pulse Response)：**
   輸入一個振幅為 $V_0$，寬度為 $T_b$ (1 UI) 的方波。
   RC 電路的充電響應為 $V(t) = V_0(1 - e^{-t/\tau})$，其中 $\tau = RC$ 為時間常數。
   在 $t = T_b$ 採樣點 (主游標 Main Cursor)，電壓為：
   $$x[0] = V_0(1 - e^{-T_b/\tau})$$

2. **計算後游標 (Post-cursors) 的放電衰減：**
   在 $t > T_b$ 後，電容開始放電。每經過一個 $T_b$，電壓就會乘上衰減因子 $e^{-T_b/\tau}$。
   $$x[1] = x[0] \cdot e^{-T_b/\tau} = V_0(1 - e^{-T_b/\tau})e^{-T_b/\tau}$$
   $$x[2] = x[0] \cdot e^{-2T_b/\tau} = V_0(1 - e^{-T_b/\tau})e^{-2T_b/\tau}$$
   以此類推。

3. **計算最壞情況下的 ISI 總和：**
   假設前面發送了一長串的 '1'，現在要發送 '0'，前面所有 '1' 殘留下來的尾巴 (Post-cursors) 總和為：
   $$\sum_{k=1}^{\infty} x[k] = V_0(1 - e^{-T_b/\tau}) \left[ e^{-T_b/\tau} + e^{-2T_b/\tau} + \dots \right]$$
   利用等比級數公式 $S = \frac{a_1}{1-r}$，其中首項 $a_1 = e^{-T_b/\tau}$，公比 $r = e^{-T_b/\tau}$：
   $$\sum_{k=1}^{\infty} x[k] = V_0(1 - e^{-T_b/\tau}) \cdot \left( \frac{e^{-T_b/\tau}}{1 - e^{-T_b/\tau}} \right) = V_0 e^{-T_b/\tau}$$

4. **推導眼圖完全閉合 (Eye Fully Closed) 的臨界條件：**
   當「主游標強度」不大於「所有後游標干擾總和」時，眼圖完全閉合，無法正確判決：
   $$x[0] \le \sum_{k=1}^{\infty} x[k]$$
   $$V_0(1 - e^{-T_b/\tau}) \le V_0 e^{-T_b/\tau}$$
   $$1 \le 2e^{-T_b/\tau} \Rightarrow e^{T_b/\tau} \le 2$$
   取自然對數：
   $$T_b/\tau \le \ln(2) \approx 0.693$$
   這代表當通道時間常數 $\tau$ 大到讓 $T_b/\tau = 0.693$ 時，眼圖剛好完全閉合。

5. **轉換為頻域的 Channel Loss：**
   RC 電路的轉移函數為 $H(s) = \frac{1}{1 + s\tau}$。
   我們關心的是奈奎斯特頻率 (Nyquist Frequency) $f_{Nyquist} = \frac{1}{2T_b}$ 下的衰減量。
   角頻率 $\omega_{Nyquist} = 2\pi f_{Nyquist} = \frac{\pi}{T_b}$。
   計算其大小：
   $$|H(j\omega_{Nyquist})| = \frac{1}{\sqrt{1 + (\omega_{Nyquist} \tau)^2}}$$
   將臨界條件 $\tau = \frac{T_b}{\ln(2)}$ 代入：
   $$\omega_{Nyquist} \tau = \frac{\pi}{T_b} \cdot \frac{T_b}{\ln(2)} = \frac{\pi}{\ln(2)} \approx 4.532$$
   $$|H(j\omega_{Nyquist})| = \frac{1}{\sqrt{1 + (4.532)^2}} = \frac{1}{\sqrt{1 + 20.54}} = \frac{1}{\sqrt{21.54}} \approx 0.215$$
   換算成 dB：
   $$20 \log_{10}(0.215) \approx -13.3 \text{ dB}$$
   **結論：只要一階通道在 Nyquist 頻率的衰減超過 13.3 dB，未經 Equalizer 處理的眼圖就會完全閉合！**

### 單位解析
**公式單位消去：**
* **$T_b/\tau$ 指數項：** $T_b$ [s] / ($\tau = R[\Omega] \times C[F]$) [s] = [s]/[s] = [無因次 dimensionless]。指數的次方必須是無因次，物理意義才成立。
* **$\omega_{Nyquist} \tau$ 項：** $\omega$ [rad/s] $\times \tau$ [s] = [rad] = [無因次 dimensionless]。在轉移函數的實部與虛部相加中，單位必須一致。
* **$|H(j\omega)|$ 轉換函數：** $V_{out}[V] / V_{in}[V]$ = [V/V] = [無因次]，常取 $20\log_{10}$ 轉換為對數單位 [dB]。

**圖表單位推斷：**
* 📈 **時域波形圖 (左側)：**
  - X 軸：時間 $t$ [s] 或 [UI] (Unit Interval)，標註點為 $0, T_b, 2T_b...$。
  - Y 軸：電壓 $V$ [V] 或 [mV]，標註脈波響應採樣點 $x(-1), x(0), x(1)...$。
* 📈 **頻域 Bode Plot (中間)：**
  - X 軸：頻率。**（TA 嚴格糾正：筆記軸標 $\omega$ [rad/s]，但刻度寫 $\frac{1}{2T_b}$ [Hz]，這是標準學生常犯的混淆！正確寫法應標註 $f$ 軸，刻度為 $\frac{1}{2T_b}$；或標註 $\omega$ 軸，刻度為 $\frac{\pi}{T_b}$）**。
  - Y 軸：增益大小 $|H|$ [V/V] 或 [dB]。Nyquist 點增益標註為 0.215 (-13.3dB)。
* 📈 **Hexagon Trade-off 圖 (右下)：**
  - 無絕對單位。代表設計維度的定性拉扯，包含：Gain, Power, Speed, Boosting, Complexity, Accuracy。箭頭代表「魚與熊掌不可兼得」。

### 白話物理意義
通道就像一個會拖泥帶水的大電容，如果它把信號「糊」掉的程度，讓最高頻率 (Nyquist rate) 衰減超過 13.3 dB，前一個 bit 殘留的尾巴 (ISI) 就會比現在這個 bit 本身還要大，導致接收端徹底瞎掉（眼圖閉合）。

### 生活化比喻
想像你在一個回音極大的山洞裡（Channel）對著朋友大喊單字（傳送信號）。如果你講話速度太快（Data Rate 很高），前一個單字的回音（ISI）還沒散去，就會蓋過你正在講的下一個單字。13.3 dB 的衰減臨界點，就像是「回音大到剛好把你現在講的話完全淹沒」的那個山洞深度。Equalizer (EQ) 就像是給朋友戴上一個智慧抗噪耳機，專門預測並抵銷這種山洞回音。

### 面試必考點
1. **問題：在設計 SerDes 接收端時，如果量測到 Channel Loss 在 Nyquist 頻率為 15 dB，你預期 RX 端沒開 EQ 時看到的眼圖會長怎樣？為什麼？**
   * **答案：** 預期眼圖會「完全閉合 (Fully Closed)」。因為根據一階 RC 模型推導，當 Nyquist 頻率衰減超過 13.3 dB ($|H| \approx 0.215$) 時，最壞情況下的 ISI 總和就會超過主游標能量。15 dB > 13.3 dB，故眼圖必閉合，必須開啟 CTLE 或 DFE 進行等化。
2. **問題：Equalizer 能夠完美救回所有 damaged signal 嗎？它有什麼潛在的副作用？**
   * **答案：** 不能。EQ 雖然能補償衰減和色散造成的 ISI，且對反射 (Reflection) 有一點點幫助，但它是一把雙面刃。最致命的副作用是 EQ（特別是線性 EQ 如 CTLE）在放大高頻信號的同時，也會**等比例放大高頻雜訊 (High-frequency noise) 和串擾 (Crosstalk)**。這就是 Hexagon 圖中提到的 Trade-off。
3. **問題：在你的筆記中提到了 Analog Design Hexagon，若今天要增加 EQ 的 Boosting 能力，通常會犧牲哪些面向？**
   * **答案：** 根據 Trade-off 圖，增加 Boosting (Equalization) 能力通常需要增加電路的 Complexity (例如增加 stage 數或使用 peaking inductor)，這會導致 Power 增加。同時，為了推高頻寬 (Speed) 與 Boosting，往往需要犧牲低頻 Gain 或者影響 Accuracy (引入雜訊或非線性)。

**記憶口訣：**
**「RC 衰減一三三，不加 EQ 眼閉上；拉高頻寬救信號，雜訊 Crosstalk 跟著漲。」** (13.3 dB 臨界點，EQ 放大高頻伴隨雜訊提升的 Trade-off)
