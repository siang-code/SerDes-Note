# LA-L5-P1

> 分析日期：2026-04-06
> 原始圖片：images/done/LA-L5-P1.jpg

---


---
## [Resonating Peaking Techniques (Series & Shunt Peaking)]

### 數學推導
筆記中介紹了頻寬拓展技術（Bandwidth Extension Techniques），主要包含 Shunt Peaking（並聯峰化）與 Series Peaking（串聯峰化）。
以最基礎的 **Shunt Peaking** 為例，在負載電阻 $R$ 上串聯一個電感 $L$：

原本的負載阻抗（無電感）為單極點系統：
$Z_0(s) = \frac{R}{1 + sRC}$

加入電感 $L$ 後，負載阻抗變為電阻與電感的串聯，再與寄生電容並聯：
$Z(s) = (R + sL) \parallel \frac{1}{sC} = \frac{R + sL}{1 + sRC + s^2LC}$

定義品質因子相關的比例參數 $m = \frac{L}{R^2C}$ 以及時間常數 $\tau = RC$，將公式改寫：
$Z(s) = R \frac{1 + s \cdot m\tau}{1 + s\tau + s^2 m\tau^2}$

**推導意義：**
從公式可見，分子多出了一個零點 $\omega_z = \frac{R}{L}$。這個零點會隨頻率上升，提早提供相位的領先與增益的補償，藉此抵消原本主極點造成的增益衰減，進而推高（Peaking）高頻響應，達到拓展頻寬的目的。

### 單位解析
**公式單位消去：**
針對阻抗公式 $Z(s) = \frac{R + sL}{1 + sRC + s^2LC}$
- $R$ 的單位為 $[\Omega]$
- $s$ (即 $j\omega$) 的單位為 $[rad/s] \rightarrow [1/s]$
- $L$ 的單位為 $[H] \rightarrow [\Omega \cdot s]$
- $C$ 的單位為 $[F] \rightarrow [s / \Omega]$

逐步檢查各項單位：
- 分子 $sL \rightarrow [1/s] \times [\Omega \cdot s] = [\Omega]$，與 $R$ 單位一致，相加後為 $[\Omega]$。
- 分母 $sRC \rightarrow [1/s] \times [\Omega] \times [s / \Omega] = [無單位]$。
- 分母 $s^2LC \rightarrow [1/s^2] \times [\Omega \cdot s] \times [s / \Omega] = [無單位]$。
- $m = \frac{L}{R^2C} \rightarrow \frac{[\Omega \cdot s]}{[\Omega^2] \times [s / \Omega]} = \frac{[\Omega \cdot s]}{[\Omega \cdot s]} = [無單位]$。
- $Z(s)$ 總單位 $\rightarrow \frac{[\Omega]}{[無單位]} = [\Omega]$，物理單位驗證正確。

**圖表單位推斷：**
📈 圖表單位推斷：左上角 $|A_v|$ vs $\omega$ 頻率響應圖
- **X 軸**：角頻率 $\omega$ [rad/s] 或 頻率 $f$ [GHz]，在高速 SerDes 中，典型範圍約為 1 GHz ~ 50 GHz。
- **Y 軸**：電壓增益絕對值 $|A_v|$ [V/V] 或 [dB]，典型範圍約為 0 ~ 15 dB。
*(圖中特別標示了高頻的 Peaking 凸起處，並警告「要小心 Time domain ringing」，精準點出頻域的 peaking 在時域的副作用。)*

### 白話物理意義
利用電感的「電流慣性」來抵抗高頻時寄生電容造成的「電壓短路」效應，把原本高頻會掉下去的增益硬是「拉」上來，換取更大的頻寬。

### 生活化比喻
就像開車高速過彎（高頻訊號），寄生電容是讓你嚴重減速的阻力；加上電感就像是利用車子的「慣性甩尾（Peaking）」來抵抗減速，讓你維持高速過彎。但如果甩尾過猛（Peaking 峰值太高），出彎後車子就會左右搖晃難以穩定，這就是時域的 Ringing（震盪）。

### 面試必考點
1. **問題：在 Layout 實作 Shunt Peaking 時，電阻 $R$ 和電感 $L$ 誰要接在 VDD（AC Ground）端？為什麼？（對應筆記右側圖解）**
   → **答案：** 電感 $L$ 應該接在 VDD 端（即 VDD -> $L$ -> $R$ -> Drain）。因為螺旋電感體積大，對基板有很大的寄生電容（通常模型化為兩端各 $C/2$）。如果 $L$ 接 VDD（AC Ground），那一端的 $C/2$ 就會被短路接地，不會貢獻到訊號路徑上（筆記寫「$C/2$ 沒了較好」），減少了不必要的極點負擔。
2. **問題：Series Peaking（串聯峰化）的原理是什麼？為什麼筆記上寫「要小心 Time domain ringing」？**
   → **答案：** Series Peaking 將電感串聯在兩級電路之間（如 M1 Drain 與 M2 Gate 之間），其核心作用是「隔離」兩端的寄生電容（$C_{db1}$ 與 $C_{gs2}$），不讓它們並聯相加。這會形成高階（三階以上）LC 低通網路，能比 Shunt Peaking 推升更多頻寬。但因為是高階網路，極容易產生高 Q 值的共軛複數極點，導致群延遲（Group Delay）不平坦，在時域就會出現嚴重的 Overshoot 與 Ringing，導致眼圖（Eye Diagram）閉合或 Jitter 變差。
3. **問題：什麼是 T-coil Peaking（對應筆記中間的「從中間抽頭抽出來」）？**
   → **答案：** 這是一種利用具備互感（$K$）的耦合電感加上橋接電容構成的技術。它可以完美「吸收」下一級的負載電容，使其表現像是一個具有純電阻輸入阻抗的匹配傳輸線。在理想設計下，它能將頻寬提升至無電感時的 2.7~2.8 倍，是 PAM4 56G/112G SerDes 前端極度常用的頻寬拓展大絕招。

**記憶口訣：**
- **Peaking 兩把刀**：Shunt 補增益（拉高頻），Series 切電容（隔離 Cdb/Cgs）。
- **Layout 必考題**：大頭（電感）朝上（VDD），寄生（電容）短路掉。
- **頻域與時域**：頻域太凸（Peaking），時域必抖（Ringing）。
