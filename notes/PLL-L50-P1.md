# PLL-L50-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L50-P1.jpg

---


---
## DLL 相位雜訊轉移函數與特性分析 (Phase Noise Transfer Functions in DLL)

作為高速 SerDes 助教，我必須先強調：**這張筆記是 DLL (Delay-Locked Loop) 最核心的考點！** 很多面試者連 DLL 跟 PLL 的 Noise Transfer Function 都搞混，這會直接被請出去。請把這頁的推導刻在腦海裡。

### 數學推導
這裡我們建立 DLL 的連續時間線性相位模型 (Continuous-Time Linear Phase Model)。

**1. Reference Noise Transfer Function (輸入參考雜訊轉移)**
*   **物理機制：** DLL 透過 Phase Detector (PD) 比較輸入相位 $\phi_{in}$ 與輸出相位 $\phi_{out}$，產生誤差送入 Charge Pump (CP) 與 Loop Filter (電容 C)，最後控制 Delay Line。注意，輸出相位是輸入相位**加上** Delay Line 的延遲。
*   **推導：**
    迴路控制電壓 $V_{ctrl} = (\phi_{in} - \phi_{out}) \cdot \frac{I_p}{2\pi} \cdot \frac{1}{sC}$
    輸出相位 $\phi_{out} = \phi_{in} + V_{ctrl} \cdot K_{DL}$  *(注意：這裡 $K_{DL}$ 是相位的控制增益)*
    將 $V_{ctrl}$ 帶入：
    $\phi_{out} = \phi_{in} + (\phi_{in} - \phi_{out}) \cdot \frac{I_p \cdot K_{DL}}{2\pi sC}$
    把 $\phi_{out}$ 移到等號同一邊，$\phi_{in}$ 移到另一邊：
    $\phi_{out} \cdot \left(1 + \frac{I_p K_{DL}}{2\pi sC}\right) = \phi_{in} \cdot \left(1 + \frac{I_p K_{DL}}{2\pi sC}\right)$
    因為括號內不為零，兩邊消去：
    **$\Rightarrow \frac{\phi_{out}}{\phi_{in}} = 1$** (這是一個 All-pass filter！)

**2. Delay Line Noise Transfer Function (延遲線自身雜訊轉移)**
*   **物理機制：** 假設輸入乾淨 ($\phi_{in} = 0$)，Delay Line 本身產生了相位雜訊 $\phi_{DL}$。
*   **推導：**
    控制電壓 $V_{ctrl} = (0 - \phi_{out}) \cdot \frac{I_p}{2\pi} \cdot \frac{1}{sC}$
    輸出相位包含雜訊與迴路修正： $\phi_{out} = \phi_{DL} + V_{ctrl} \cdot K_{DL}$
    代入 $V_{ctrl}$：
    $\phi_{out} = \phi_{DL} - \phi_{out} \cdot \frac{I_p \cdot K_{DL}}{2\pi sC}$
    移項整理：
    $\phi_{out} \cdot \left(1 + \frac{I_p K_{DL}}{2\pi sC}\right) = \phi_{DL}$
    定義迴路頻寬 $\omega_p = \frac{I_p \cdot K_{DL}}{2\pi C}$，代入上式：
    $\phi_{out} \cdot \left(1 + \frac{\omega_p}{s}\right) = \phi_{DL}$
    整理得到轉移函數：
    **$\Rightarrow \frac{\phi_{out}}{\phi_{DL}} = \frac{s}{s + \omega_p}$** (這是一個 1st-order High-pass filter！)

### 單位解析
**公式單位消去：**
這裡常有學生搞錯 $K_{DL}$ 的單位。在時間域，Delay line gain 是 $K_{vcdl}$ [s/V]。轉換到相位域模型，相位的增益 $K_{DL} = K_{vcdl} \times \omega_{ref}$，單位才會是 [rad/V]。
*   **Loop Bandwidth $\omega_p$:**
    $\omega_p = \frac{I_p \cdot K_{DL}}{2\pi C}$
    $= \frac{[A] \times [rad/V]}{[F]} = \frac{[A \cdot rad/V]}{[A \cdot s/V]} = \frac{rad}{s} = [rad/s]$ (完美消去！)

**圖表單位推斷：**
*   **第一列 (轉移函數振幅 $|\frac{\phi_{out}}{\phi_{in}}|, |\frac{\phi_{out}}{\phi_{DL}}|$):**
    *   X 軸：角頻率 $\omega$ [rad/s] (Log scale)，典型範圍 $10^3 \sim 10^9$ rad/s。
    *   Y 軸：增益 [V/V] 或 [rad/rad] (線性尺度 0~1)。
*   **第二/三/四列 (雜訊功率頻譜密度 $S_{\phi}$):**
    *   X 軸：頻率偏移 $\omega$ [rad/s] (Log scale)。
    *   Y 軸：相位雜訊 PSD $S_{\phi}$ [$rad^2/Hz$] 或 $\mathcal{L}(f)$ [dBc/Hz]，典型範圍 -80 ~ -150 dBc/Hz。
    *   *(助教糾錯)*：筆記第三列右圖標示高通濾波後的斜率為 **20dB/dec**。請注意，如果 Y 軸是「功率」頻譜密度 ($rad^2/Hz$)，因為轉移函數平方 $|H(s)|^2 \propto \omega^2$，斜率應該是 **40dB/dec**。如果寫 20dB/dec，代表 Y 軸畫的是「電壓」頻譜密度 (V/$\sqrt{Hz}$)，面試被問到要能區分這點！

### 白話物理意義
DLL 是一個對輸入雜訊照單全收（All-pass），但會利用回授機制把自己內部產生的低頻雜訊濾掉（High-pass），且永遠不會累積誤差的乖寶寶。

### 生活化比喻
*   **PLL (像蒙眼走路)：** 你的 VCO 就像蒙眼走路，每一步方向偏了一點（頻率誤差），這一步的誤差會帶到下一步，導致你離目標越來越遠，這叫做 **Jitter Accumulation（雜訊累積）**，所以低頻 Phase noise 很大。
*   **DLL (像軍隊報數)：** Delay Line 就像排隊報數，第一人喊 1，第二人聽到了喊 2。如果第二人恍神喊慢了（Delay line noise），只會影響他自己的時間，第三個人還是聽第一個人的基準時鐘（Reference clock），所以誤差在下一個週期就「重置」了，**不會累積到天涯海角**。

### 面試必考點
1.  **問題：DLL 對 Reference 跟 Delay Line 的 Noise Transfer Function (NTF) 分別是什麼形狀？**
    *   答案：對 Reference 是 All-pass (轉移函數為 1)；對 Delay Line 自身雜訊是 High-pass (轉移函數為 $\frac{s}{s+\omega_p}$)。
2.  **問題：為什麼筆記最下方寫 "DLL accumulates no jitter, presenting much lower phase noise"？比較 DLL 與 PLL 在低頻區段的 Phase Noise 差異。**
    *   答案：因為 Delay Line 的轉移函數沒有積分項 ($1/s$)，其本質雜訊是平坦的白雜訊 (White noise)。而 PLL 的 VCO 是一個積分器，會將白雜訊積分成 $1/f^2$ 的隨機漫步 (Random walk) 雜訊，造成 Jitter Accumulation。因此在低頻偏移處 (Low offset frequency)，DLL 的 phase noise floor 遠低於 PLL (如筆記最下方圖示)。
3.  **問題：筆記提到 "DL noise mostly comes from supply"，這對 SerDes 晶片佈局 (Layout) 與系統設計有什麼啟示？**
    *   答案：Delay Line 的延遲時間極度敏感於電源電壓 ($V_{dd}$)。Supply Ripple 會直接透過 Delay Line 轉化為 Deterministic Jitter (DJ)。因此，DLL 必須配備高 PSRR 的 LDO 獨立供電，且 Layout 時電源線要特別乾淨、加上足夠的 Decoupling Capacitor。

**記憶口訣：**
> **「DLL 三字訣：入全通 (Ref All-pass)、己高通 (DL High-pass)、不累積 (No Jitter Accumulation)！」**

---
### 🧙‍♂️ 助教的費曼測試 (Feynman Test)
如果你覺得「我懂了」，請接招：
1. **反事實攻擊：** 如果把 DLL Loop Filter 的電容 C 拔掉（變成極小），對 Delay Line noise 的濾波效果會有什麼影響？$\omega_p$ 會跑到哪裡？
2. **禁語令：** 不准用 "Jitter Accumulation" 或 "積分器" 這兩個詞，用直觀的波形圖向我解釋為什麼 VCO 雜訊比 Delay Line 雜訊可怕？
