# CDR-L15-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L15-P1.jpg

---


---
## PI-based CDR with BBPD (大訊號 Slewing 分析)

### 數學推導
本頁筆記主要探討基於 Bang-Bang Phase Detector (BBPD) 的 Phase Interpolator (PI) CDR 在面對「大振幅且快速變動」的輸入相位抖動（Jitter）時，進入迴路非線性限幅（Slewing）狀態的行為與頻寬推導。

1. **定義輸入抖動**：
   假設輸入相位帶有正弦抖動：
   $$\phi_{in}(t) = \phi_{in,p} \cos(\omega_{\phi}t + \theta)$$
   其中 $\phi_{in,p}$ 為抖動峰值振幅，$\omega_{\phi}$ 為調變頻率（$\omega_{\phi} = 2\pi f_{\phi} = \frac{2\pi}{T_{\phi}}$）。

2. **Slewing 狀態下的控制電壓變化**：
   當 $\phi_{in}$ 變化極快且幅度極大時（超越了 BBPD 線性追蹤的能力），BBPD 會如同一個符號函數，持續輸出最大極性的訊號。Charge Pump (CP) 此時會持續以最大電流 $\pm I_P$ 對迴路電容 $C$ 進行充放電，此即為 Slewing。
   控制電壓 $V_{ctrl}$ 的變化率（Slew Rate）為恆定值：
   $$\frac{dV_{ctrl}}{dt} = \pm \frac{I_P}{C}$$
   對時間積分後可得：
   $$\Delta V_{ctrl} = \pm \frac{I_P}{C} \Delta t$$

3. **計算輸出相位峰值 $\phi_{out,p}$**：
   從正弦波的零交叉點（Zero-crossing）到波峰，經過的時間恰好為四分之一個週期，即 $\Delta t = \frac{T_{\phi}}{4}$。
   在這段時間內，控制電壓累積達到最大變化量：
   $$V_{ctrl,p} = \frac{I_P}{C} \cdot \frac{T_{\phi}}{4}$$
   因為 PI 的輸出相位與 $V_{ctrl}$ 成正比（增益為 $K_{PI}$），所以 PI 的峰值輸出相位為：
   $$\phi_{out,p} = V_{ctrl,p} \cdot K_{PI} = \frac{I_P}{C} \cdot \frac{T_{\phi}}{4} \cdot K_{PI}$$

4. **轉換為頻域表達式**：
   將週期 $T_{\phi} = \frac{2\pi}{\omega_{\phi}}$ 代入上式：
   $$\phi_{out,p} = \frac{I_P}{C} \cdot \frac{2\pi}{4\omega_{\phi}} \cdot K_{PI} = \frac{\pi \cdot I_P \cdot K_{PI}}{2 \omega_{\phi} C}$$

5. **推導大訊號等效轉移函數與頻寬 ($\omega_{-3dB}$)**：
   定義迴路在 Slewing 狀態下對輸入相位的追蹤能力（等效增益）為：
   $$\left| \frac{\phi_{out,p}}{\phi_{in,p}} \right| = \frac{\pi \cdot I_P \cdot K_{PI}}{2 \omega_{\phi} C \cdot \phi_{in,p}}$$
   當系統剛好無法完全追蹤輸入振幅時（即等效增益降至 1 或 0dB，代表轉折頻率/有效頻寬 $\omega_{-3dB}$），我們令上式等於 1：
   $$1 = \frac{\pi \cdot I_P \cdot K_{PI}}{2 \omega_{-3dB} C \cdot \phi_{in,p}}$$
   移項整理得到 Slewing 限幅下的有效頻寬：
   $$\omega_{-3dB} = \frac{\pi \cdot I_P \cdot K_{PI}}{2 C \cdot \phi_{in,p}}$$
   結論：在 BBPD CDR 中，面對大訊號抖動時，**有效頻寬會與輸入抖動振幅 $\phi_{in,p}$ 成反比**。

### 單位解析
**公式單位消去：**
- $I_P$ 為電流 $\Rightarrow$ [A]
- $C$ 為電容 $\Rightarrow$ [F] = [A·s/V]
- $\frac{I_P}{C}$ 決定電壓斜率 $\Rightarrow \frac{[A]}{[A \cdot s / V]} = [V/s]$
- $T_{\phi}$ 為時間 $\Rightarrow$ [s]
- $K_{PI}$ 為 PI 增益 $\Rightarrow$ [rad/V]
- $\phi_{out,p} = \frac{I_P}{C} \cdot \frac{T_{\phi}}{4} \cdot K_{PI} \Rightarrow [V/s] \cdot [s] \cdot [rad/V] = [rad]$ (相位單位，合理)
- 計算頻寬：$\omega_{-3dB} = \frac{\pi \cdot I_P \cdot K_{PI}}{2 \cdot C \cdot \phi_{in,p}}$
  $\Rightarrow \frac{[無單位] \cdot [A] \cdot [rad/V]}{[A \cdot s / V] \cdot [rad]} = \frac{[A/V] \cdot [rad]}{[A/V] \cdot [s] \cdot [rad]} = \left[\frac{1}{s}\right] = [rad/s]$ (角頻率單位，合理)

**圖表單位推斷：**
📈 圖一（左下，BBPD 特性）：
- X 軸：相位誤差 $\Delta\phi$ [UI] 或 [rad]，典型範圍 -0.5 UI ~ +0.5 UI
- Y 軸：平均電流 $I_{av}$ [A]，典型範圍 $-I_P$ ~ $+I_P$ (例如 $\pm 50 \mu A$)

📈 圖二（左中，PI 轉換特性）：
- X 軸：控制電壓 $V_{ctrl}$ [V]，典型範圍 0 ~ 1 V
- Y 軸：輸出相位 $\phi_{out}$ [UI] 或 [rad]，典型範圍 0 ~ 1 UI

📈 圖三（右上，Slewing 時域波形）：
- X 軸：時間 $t$ [ns] 或 [UI]，典型範圍為抖動週期 $T_{\phi}$
- Y 軸：相位 $\phi$ [UI] 或 [rad]
- *紅線為受 Slew Rate 限制的三角波，無法跟上藍色的高頻正弦波。*

📈 圖四（右下，等效轉移函數 Bode Plot）：
- X 軸：抖動調變角頻率 $\omega_{\phi}$ [rad/s] (對數刻度)
- Y 軸：抖動轉移增益 $\left| \frac{\phi_{out}}{\phi_{in}} \right|$ [無單位]，(對數刻度)，高頻滾降斜率為 $\propto \frac{1}{\omega_{\phi}}$

### 白話物理意義
Bang-Bang CDR 在面對「又大又快」的輸入相位晃動時，因為 Charge Pump 吐出的電流有極限，導致追蹤相位的速度跟不上，最後造成「輸入抖動越大，CDR 能成功追蹤的頻寬就越小」的非線性現象。

### 生活化比喻
想像你在開一輛方向盤轉速有物理極限的車（Slew-rate limited）。如果前面的引導車只是小幅度蛇行，你可以輕鬆轉方向盤跟上（Normal tracking）。但如果引導車開始大幅度且極速地左右狂切車道（Fast & large $\phi_{in}$），你方向盤就算打到底也轉不過去，只能勉強走出一個來不及轉彎的「Z字型」路線（三角形波）。引導車晃得越遠（$\phi_{in,p}$ 越大），你能順利跟上的車速與頻率就越低（頻寬變小）。

### 面試必考點
1. **問題：在 BBPD CDR 中，大訊號 (Large Signal) 下的 Jitter Tracking Bandwidth 有什麼特徵？**
   → 答案：因為 Slewing 效應，大訊號下的有效頻寬會與輸入抖動的振幅 ($\phi_{in,p}$) 成反比。這與 Linear CDR 頻寬恆定（獨立於振幅）的特性完全不同。
2. **問題：請解釋推導 Slewing 輸出相位時，為什麼時間要乘上 $\frac{T_{\phi}}{4}$？**
   → 答案：因為輸入抖動被視為正弦波，從相位為 0 的交叉點累積到峰值 (Peak)，剛好經過四分之一個週期。在這段時間內 BBPD 認為「落後/超前」狀態不變，CP 持續提供單方向最大電流對電容充電，此時造成的相位改變即為最大輸出相位。
3. **問題：在電路設計上，如何提高 BBPD CDR 對大振幅抖動的追蹤能力（提高 Slewing 頻寬）？**
   → 答案：根據公式 $\omega_{-3dB} = \frac{\pi \cdot I_P \cdot K_{PI}}{2 C \cdot \phi_{in,p}}$，可以透過：(1) 增加 Charge Pump 的電流 $I_P$；(2) 提高 Phase Interpolator 的增益 $K_{PI}$；(3) 縮小迴路濾波電容 $C$ 來改善。

**記憶口訣：**
大訊號下必 Slew，頻寬振幅成反比；電流增益能救場，電容太大追不及。
