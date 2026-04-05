# EQ-L3-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/EQ-L3-P1.jpg

---


---
## [Channel Characteristics: Reflection, Dispersion, and ISI]

同學，這頁筆記是整個 SerDes Equalization (EQ) 的核心起點。如果連通道（Channel）把訊號弄成什麼德性都不清楚，後面講 CTLE、FFE、DFE 都是白搭。這頁重點在講訊號在通道中遇到的兩大魔王：**反射 (Reflection)** 與 **色散造成的符元間干擾 (Dispersion / ISI)**。

### 數學推導

**1. 反射係數 (Reflection Coefficient, $\Gamma$) 推導**
當傳輸線特性阻抗為 $Z_0$，負載端阻抗為 $Z_L$ 時，根據邊界條件，電壓與電流必須連續。
在負載端點：
*   總電壓 $V_L = V_{inc} + V_{ref}$ （入射波電壓 + 反射波電壓）
*   總電流 $I_L = I_{inc} - I_{ref}$ （入射波電流 - 反射波電流，方向相反）

根據歐姆定律：
*   $V_{inc} = I_{inc} \cdot Z_0$
*   $V_{ref} = I_{ref} \cdot Z_0$
*   $V_L = I_L \cdot Z_L$

將電流代入電壓式：
$V_L = (I_{inc} - I_{ref}) \cdot Z_L = (\frac{V_{inc}}{Z_0} - \frac{V_{ref}}{Z_0}) \cdot Z_L$
將等式左右同乘 $Z_0$ 並整理：
$V_L \cdot Z_0 = (V_{inc} - V_{ref}) \cdot Z_L$
因為 $V_L = V_{inc} + V_{ref}$，代入左邊：
$(V_{inc} + V_{ref}) \cdot Z_0 = (V_{inc} - V_{ref}) \cdot Z_L$
展開並移項收集 $V_{inc}$ 與 $V_{ref}$：
$V_{ref} \cdot (Z_L + Z_0) = V_{inc} \cdot (Z_L - Z_0)$
得到反射係數定義：
$\Gamma \equiv \frac{V_{ref}}{V_{inc}} = \frac{Z_L - Z_0}{Z_L + Z_0}$

**2. 能量守恆與 Pulse Response 總和 (Normalization)**
筆記中寫到 $\sum_{k=-\infty}^{\infty} x[k] = 1$。這個結論是怎麼來的？不能死背！
假設通道是一個線性非時變系統 (LTI)，其脈衝響應 (Pulse Response) 為 $x(t)$，取樣點為 $x[k]$。
考慮輸入一個**連續的 1 (DC 信號)**，也就是輸入位元序列 $d_k = 1$ for all $k$。
系統在穩態下的輸出 $y[n]$ 為輸入序列與脈衝響應的摺積 (Convolution)：
$y[n] = \sum_{k=-\infty}^{\infty} d_{n-k} \cdot x[k]$
因為 $d_k = 1$，所以 $y[n] = \sum_{k=-\infty}^{\infty} 1 \cdot x[k] = \sum_{k=-\infty}^{\infty} x[k]$
如果通道在低頻 (DC) 沒有損失（或者我們將 DC Gain 歸一化為 1），那麼輸入連續的 1，穩態輸出也會是 1。
因此得證：$\sum_{k=-\infty}^{\infty} x[k] = 1$
這意味著一個 Bit 的能量 (高度) 總和不變，主游標 (main cursor) $x[0]$ 的能量被分攤到了前游標 (precursors) 與後游標 (postcursors) 上。

### 單位解析

**公式單位消去：**
*   **反射係數 $\Gamma$:**
    $\Gamma = \frac{Z_L [\Omega] - Z_0 [\Omega]}{Z_L [\Omega] + Z_0 [\Omega]} = \frac{[\Omega]}{[\Omega]} = [1] (\text{Dimensionless, 無因次比例})$
*   **Pulse Response 歸一化:**
    $y[V] = \sum ( d_k[V] \cdot x[k][V/V] )$，若輸入經過歸一化 $d_k$ 視為純數字 $[1]$，則 $x[k]$ 單位為 $[V]$。若將整體輸出除以輸入振幅歸一化，則 $\sum x[k] = 1$ 中 $x[k]$ 為無單位比例 $[V/V]$。

**圖表單位推斷：**
1.  📈 **Channel Loss ($S_{21}$) 頻譜圖：**
    *   X 軸：頻率 (Frequency) $[GHz]$，典型範圍 0 ~ Nyquist rate (例如 28Gbps 對應 14GHz)。
    *   Y 軸：穿透係數幅值 $|S_{21}|$ $[dB]$，典型範圍 0 dB ~ -35 dB。筆記中 "due to connectors" 指的是連接器寄生參數造成的阻抗不連續，常在特定頻率產生共振凹陷 (Notch)。
2.  📈 **Reflection 時域波形圖 (Vin, Vout vs t)：**
    *   X 軸：時間 $[ns]$ 或 $[ps]$。筆記寫 "3~5倍時間後反射"，這取決於走線長度 (Time Delay, $T_{pd}$)。
    *   Y 軸：電壓 $[V]$ 或 $[mV]$，典型邏輯準位。
3.  📈 **Pulse Response ($D_{out}$ vs t) & ISI 波形圖：**
    *   X 軸：時間，通常以 Unit Interval $[UI]$ 為單位標示取樣點 $k$。$1 UI = T_b$ (Bit period)。
    *   Y 軸：歸一化振幅 (Normalized Amplitude) $[-]$ 或電壓 $[mV]$。

### 白話物理意義
**「通道就像一個爛彈簧床，你在上面跳一下 (Single Pulse)，震動不會馬上停，餘震 (Pre/Post-cursors) 會干擾你接下來跳的每一步 (ISI)；而且如果床邊緣沒固定好 (阻抗不匹配)，波浪還會反彈回來打你 (Reflection)。」**

### 生活化比喻
*   **反射 (Reflection)：** 在空曠的山谷大喊，如果山壁（負載）不能完美吸收聲音（阻抗匹配），聲音就會變成回音彈回來，跟你下一句要講的話疊加在一起，讓你聽不清楚。
*   **色散與 ISI (Dispersion & ISI)：** 在吸水性太強的宣紙上寫毛筆字。你點一滴墨（一個 Bit），墨水會慢慢暈開（Dispersion）。如果你寫字速度太快（High Data Rate），字跟字靠得太近，墨跡就會互相渲染疊加（ISI），最後糊成一團看不出寫什麼。能量守恆的意思是，那一滴墨水的總量沒變（$\sum x[k] = 1$），只是它不在原本該在的位置（$x[0]$ 變小），跑去干擾別人了（變成 $x[-1], x[1]$ 等）。

### 面試必考點
1. **問題：什麼是 Pre-cursor 和 Post-cursor？在電路設計上哪個比較難消除？**
   → **答案：** Pre-cursor 是主訊號到達**前**的漏訊（通常由通道相位非線性或反射引起）；Post-cursor 是主訊號到達**後**的拖尾（由通道高頻衰減/RC延遲引起）。**Pre-cursor 比較難消除**，因為它違反因果性（Causality），接收端無法用已經收到的歷史資料來預測未來（所以 DFE 對 Pre-cursor 無效，必須靠發射端的 FFE 先行預處理）。
2. **問題：如果 $S_{21}$ 頻譜上在 Nyquist 頻率處有一個很深的 Notch (凹洞)，時域的 Pulse response 會有什麼特徵？**
   → **答案：** 頻域有 Notch 代表特定高頻能量被吃掉，通常對應到時域會有嚴重的振鈴現象 (Ringing)。這會導致 Pulse response 產生大量且長尾的 Post-cursors，且有正有負，嚴重惡化眼圖 (Eye diagram)。
3. **問題：為了消除反射，我們通常把 $Z_L$ 匹配到 $Z_0$ (例如 $50\Omega$)。實務上在 IC 內部是怎麼做的？會有什麼缺點？**
   → **答案：** 實務上使用 On-Die Termination (ODT)，在 RX 端並聯一個精準的電阻到 VDD 或 GND。缺點是會消耗靜態直流功耗 (DC Power)，並且電阻值會隨 PVT (製程、電壓、溫度) 變異，通常需要額外的校準電路 (Calibration circuit) 來微調電阻值。

**記憶口訣：**
**「阻抗不配必反射，高頻衰減必色散；主波縮水能量守恆，前人(Pre)乘涼後人(Post)遭殃。」**
