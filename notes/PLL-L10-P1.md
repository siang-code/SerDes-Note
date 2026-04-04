# PLL-L10-P1

> 分析日期：2026-04-04
> 原始圖片：images/PLL-L10-P1.jpg

---

這張筆記涵蓋了 PLL 中 Charge Pump (電荷泵, CP) 的三種經典架構演進，以及它們如何處理非理想效應（Non-idealities），特別是 Channel Length Modulation (通道長度調變) 與開關效應。這是 SerDes 面試中必考的「起手式」題目。

以下是助教為你整理的深度解析：

---
## [PLL Charge Pump 架構與非理想效應]

### 數學推導
在 Charge Pump 中，最致命的非理想效應是 **Up/Down 電流不匹配 (Current Mismatch)**，這會導致 PLL 鎖定時產生靜態相位誤差 (Static Phase Offset)。我們來推導這個過程：

1. **考慮 Channel Length Modulation (CLM) 的電流方程式：**
   理想電流源電流為 $I_{ideal}$，但實際 MOS 處於飽和區時，電流會受汲極-源極電壓 ($V_{DS}$) 影響：
   $$I_D = I_{ideal} \cdot (1 + \lambda V_{DS})$$
   *(其中 $\lambda$ 為通道長度調變參數)*

2. **Charge Pump 的 Up/Down 電流差異：**
   假設 Loop Filter 電壓為 $V_{ctrl}$，開關的導通電阻為 $R_{on}$。
   - 上拉 PMOS 電流：$I_{up} = I_{P,ideal} \cdot [1 + \lambda_p (VDD - V_{ctrl} - I_{up}R_{on,p})]$
   - 下拉 NMOS 電流：$I_{down} = I_{N,ideal} \cdot [1 + \lambda_n (V_{ctrl} - I_{down}R_{on,n})]$
   
   **推導結論：** 由於 $I_{up}$ 與 $I_{down}$ 對 $V_{ctrl}$ 的相依性不同 (一個是 $VDD - V_{ctrl}$，一個是 $V_{ctrl}$)，除非 $V_{ctrl}$ 剛好在某個特定電壓 (通常接近 VDD/2)，否則必定存在 $\Delta I = I_{up} - I_{down} \neq 0$。

3. **Mismatch 造成的靜態相位誤差 (Static Phase Error)：**
   當 PLL 鎖定 (Lock) 時，Charge Pump 在一個週期內注入 Loop Filter 的淨電荷必須為零：
   $$Q_{net} = Q_{up} - Q_{down} = 0$$
   $$I_{up} \cdot t_{up} = I_{down} \cdot t_{down}$$
   假設 PFD 有一個固定的重置延遲時間 $t_{reset}$ (為了消除 Dead-zone)，若 $I_{up} > I_{down}$，則 $t_{down}$ 必須大於 $t_{up}$ 來補償。這多出來的時間差 $\Delta t = t_{down} - t_{up}$，就是 Phase Frequency Detector (PFD) 必須產生的輸入相位差。
   $$\Delta t \approx t_{reset} \cdot \frac{\Delta I}{I_{up}}$$

### 單位解析
**公式單位消去：**
針對靜態時間誤差公式 $\Delta t \approx t_{reset} \cdot \frac{\Delta I}{I_{up}}$ 進行單位驗證：
- $t_{reset}$ 單位：$[s]$ (秒)
- $\Delta I$ 單位：$[A]$ (安培)
- $I_{up}$ 單位：$[A]$ (安培)
- **單位消去：** $[s] \times \frac{[A]}{[A]} = [s]$ (時間單位，符合邏輯)
轉換為相位誤差 $\Delta \phi$ (單位 Radian)：
$\Delta \phi = 2\pi \cdot \frac{\Delta t}{T_{ref}}$  => $[rad] = [rad] \cdot \frac{[s]}{[s]}$ => $[rad]$

**圖表隱藏單位推斷：**
雖然本頁主要是電路圖，但在面試時若畫出 Charge Pump 特性，你腦中必須浮現「CP 轉移特性圖 (I-V Curve)」：
- **X 軸：** Loop Filter 電壓 $V_{ctrl}$ $[V]$，典型範圍 $0.2V \sim 1.0V$ (假設 1.2V 核心電壓，需扣除 CP 兩端電晶體的 $V_{DS,sat}$ 進入 Triode 的極限)。
- **Y 軸：** 輸出電流 $I_{out}$ $[\mu A]$，典型範圍 $\pm 50 \mu A \sim \pm 500 \mu A$。

### 白話物理意義
Charge Pump 就像是水庫的雙向抽水/放水馬達，這三張圖展示了「水龍頭裝在水管哪裡」的演進：裝在末端會積水壓亂噴 (Drain Switching)，裝在電源端啟動太慢 (Gate Switching)，所以最後要在測試管路上裝個「假水龍頭」來精準複製水流阻力 (Replica Biasing)。

### 生活化比喻
- **Top 圖 (Drain Switching)：** 像是在水管「最末端」裝開關。關水時，水管內（電流源）的水壓會積聚（掉入 Triode region）。下次一開水，積聚的水壓會「噗」一聲瞬間噴出多餘的水，這在電路裡叫 Charge Sharing / Current Spike，會讓你的 PLL 抖動 (Jitter) 爆表。
- **Middle 圖 (Gate Switching)：** 像是在「馬達的電源總開關」操作。關水時馬達徹底停轉（進入 Cutoff）。好處是不會積水壓，但每次開水都要重新啟動馬達（對巨大的 Gate 寄生電容充放電），反應非常慢 (More parasitics)。
- **Bottom 圖 (Replica Biasing)：** 為了解決馬達出水不對稱，我們在工廠測試管路（Bias branch）也裝上一個「永遠開著的假開關」（$M_1, M_3$ mimic $R_{on}$），讓測試管路的阻力跟實際管路一模一樣，這樣鏡像出來的電流就會非常精準。

### 面試必考點
1. **問題：請說明 Drain Switching Charge Pump (筆記最上圖) 最大的致命傷是什麼？**
   - 答案：當開關 (M2/M3) OFF 時，電流源 (M1/M4) 的 Drain 端浮接，失去 $V_{DS}$ 而掉入 **Triode Region (線性區)**。當開關瞬間 ON 時，電流源需要時間回到 Saturation，瞬間的電荷重新分配會造成 Current Spike (電流突波)，導致嚴重的 Reference Spur 與 Jitter。
2. **問題：什麼是 Channel Length Modulation 對 Charge Pump 的影響？**
   - 答案：隨 VCO 控制電壓 ($V_{ctrl}$) 上下浮動，CP 內 PMOS 與 NMOS 電流源的 $V_{DS}$ 會改變，導致 $I_{up}$ 與 $I_{down}$ 產生 Mismatch。這會迫使 PLL 在 Lock 時產生 Static Phase Offset 來平衡電荷。
3. **問題：筆記最下方的架構加入了 M1 與 M3，這叫做什麼技術？目的是什麼？**
   - 答案：這是 **Replica Biasing (複製品偏壓)** 技術。M1 與 M3 的閘極接死 (常開)，用來在 Bias 支路中模擬真實 Pumping 支路中開關的導通電壓降 ($V_{drop} = I \cdot R_{on}$)。這確保了電流鏡的 Primary 端與 Secondary 端看到完全相同的 $V_{DS}$ 邊界條件，大幅降低 current mismatch。

**記憶口訣：**
「**Drain** 關斷掉 **Triode** (噴突波)，**Gate** 關斷嫌太慢 (充大C)，**Replica** 假開關神救援 (抵消 Ron)！」

---

### 🚨 費曼測試 (TA 的嚴格拷問)
如果你覺得你懂了，請接招：
1. **情境遷移：** 「在 56Gbps PAM4 SerDes 的 CDR (Clock Data Recovery) 中，如果你用 Drain Switching CP，這個 Current Spike 會對你收到的 Eye Diagram 造成什麼具體形狀的破壞？」
2. **反事實：** 「如果筆記最下方那張圖，我把 Dummy Switch (M1, M3) 的 W/L 縮小一半，但其他都不變，這對 Mismatch 補償會有什麼反效果？」
3. **禁語令：** 「現在，不准說出『Triode』、『Saturation』、『Channel Length Modulation』這三個詞，請重新解釋為什麼 Top 圖的電路會產生 Phase Offset？」

請試著回答看看，答得出來，這關面試你就穩了。
