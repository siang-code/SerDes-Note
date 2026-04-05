# CDR-L20-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L20-P1.jpg

---


---
## Bang-Bang CDR 鎖定範圍 (Capture Range of BB-CDRs)

### 數學推導
本頁筆記探討當資料率 (Data Rate) 發生突變時，Bang-Bang CDR (BB-CDR) 的追蹤能力極限。

1. **初始狀態：** 系統處於鎖定狀態，資料頻率為 $W_{DR}$，VCO 頻率與其匹配。
2. **頻率突變：** 假設在時間 $t=0$ 時，輸入資料頻率突然發生階躍變化 (Frequency Step)，新的頻率為 $W_{DR} + \Delta W$。
3. **BBPD 的響應：** 因為輸入頻率改變，輸入資料與 VCO 時脈之間的相位差會開始隨時間線性累積（$\Delta\phi = \Delta W \cdot t$）。BBPD 會偵測到這個相位落後或超前，並輸出最大且恆定的電流。此處我們假設它一直輸出 $+I_P$ 或 $-I_P$（進入 saturated/slewing 狀態）。
4. **Loop Filter 的瞬態響應：** 電流 $I_P$ 注入由電阻 $R_P$ 和電容 $C_P$ 組成的迴路濾波器。在極短的時間內（瞬態），電容 $C_P$ 兩端的電壓來不及變化，主要的電壓跳變發生在比例路徑 (Proportional Path) 的電阻 $R_P$ 上。
   - 控制電壓的瞬時跳變量：$\Delta V_{ctrl} = I_P \cdot R_P$
5. **VCO 的頻率跳變：** 由於控制電壓瞬間改變了 $\Delta V_{ctrl}$，VCO 的頻率也會瞬間產生一個跳變來試圖跟上新的資料率。
   - VCO 頻率的最大瞬時補償量：$\Delta W_{VCO\_max} = \Delta V_{ctrl} \cdot K_{VCO} = I_P \cdot R_P \cdot K_{VCO}$
6. **鎖定條件 (Capture Range)：**
   - **Return to lock (左下圖)：** 如果輸入的頻率變化量 $|\Delta W|$ 小於 VCO 能瞬間產生的頻率補償量，即 $|\Delta W| < I_P \cdot R_P \cdot K_{VCO}$。這時系統的修正能力大於誤差累積的速度，取樣點在眼圖中偏移後（1 $\rightarrow$ 2），最終會被拉回資料轉態點（2 $\rightarrow$ 3 $\rightarrow$ 4），系統重新鎖定。
   - **Loss of lock (右下圖)：** 如果輸入的頻率變化量 $|\Delta W|$ 過大，超過了系統瞬間的最大補償能力，即 $|\Delta W| > I_P \cdot R_P \cdot K_{VCO}$。這時 VCO 拼盡全力也追不上頻率差，相位誤差會持續擴大，取樣點在眼圖中一路向右/向左滑動（1 $\rightarrow$ 2 $\rightarrow$ 3 $\rightarrow$ 4），穿越整個 Eye opening，這就是所謂的 **Cycle Slip (滑相)**，系統失去鎖定。

由此推導出 BB-CDR 純靠 Phase Detector 的頻率捕捉範圍極限為：$|\Delta W| \approx I_P R_P K_{VCO}$，這個值大約與 CDR 的迴路頻寬 (Loop Bandwidth) 同等量級。

### 單位解析
**公式單位消去：**
- $I_P$ (Charge Pump 峰值電流) = $[A]$
- $R_P$ (迴路濾波器電阻) = $[\Omega] = [V/A]$
- $K_{VCO}$ (VCO 增益) = $[rad/s/V]$ 或 $[Hz/V]$
推導：$|\Delta W|_{max} = I_P \times R_P \times K_{VCO}$
單位：$[A] \times [V/A] \times [Hz/V] = [Hz]$ (頻率單位，與 $\Delta W$ 吻合)。

**圖表單位推斷：**
- **Data Rate vs Time (左上方階躍圖)：**
  - X 軸：時間 $[ns]$ 或 $[μs]$，典型範圍：突波發生的微秒等級瞬間。
  - Y 軸：角頻率 $\omega$ $[rad/s]$ 或 $[GHz]$，典型範圍：例如從 10 GHz 跳變到 10.05 GHz。
- **BBPD Transfer Curve (左中圖)：**
  - X 軸：相位誤差 $\Delta\phi$ $[UI]$ 或 $[rad]$，典型範圍：$-0.5\ UI \sim +0.5\ UI$。
  - Y 軸：平均輸出電流 $I_{av}$ $[\mu A]$，典型範圍：$\pm 50 \sim \pm 200\ \mu A$ (由 $I_P$ 決定)。
- **Eye Diagram / Phase Trajectory (下方兩張眼圖)：**
  - X 軸：相位或時間 $[UI]$，典型範圍：$0 \sim 1\ UI$ (一個眼睛的寬度)。
  - Y 軸：電壓振幅 $[mV]$，典型範圍：$\pm 300\ mV$ (差分訊號)。圖中的點(1,2,3,4)代表時脈取樣邊緣在資料眼圖中的相對位置軌跡。

### 白話物理意義
Bang-Bang CDR 遇到資料頻率突然改變時，只能靠「踩到底的油門」（輸出最大電流 $I_P$ 乘上電阻 $R_P$ 產生的瞬間電壓）來拉抬 VCO 頻率；如果前方的車瞬間加速太多（$\Delta W$ 太大），你的破車油門踩到底也追不上，就會發生「滑相」徹底跟丟。

### 生活化比喻
想像你（VCO）蒙著眼跟著前面的車（Data）跑，教練（BBPD）只能告訴你「太快」或「太慢」，不能告訴你差多少。
當前車突然「瞬間暴衝加速」（$\Delta W$），你只能使出吃奶的力氣「全速衝刺」（輸出最大電流經過電阻產生的瞬間加速力 $I_P R_P K_{VCO}$）。
如果前車暴衝的幅度，超過了你全力衝刺能增加的極速，你就會被海放（Loss of lock）。所以設計師通常會幫你配一個「雷達測速儀」（FD, Frequency Detector），先幫你把速度拉近到你能力範圍內，再交給教練微調。

### 面試必考點
1. **問題：Bang-Bang CDR 的 Capture Range (捕捉範圍) 是由哪些參數決定的？**
   - 答案：由 $I_P$ (CP 電流), $R_P$ (迴路電阻) 和 $K_{VCO}$ 決定。公式為 $\Delta \omega_{capture} \approx I_P R_P K_{VCO}$。這代表系統利用 Proportional Path 能產生的最大瞬態頻率跳變量。
2. **問題：為什麼我們不能直接把 $I_P$ 或 $R_P$ 調到無限大，來獲得無限大的 Capture Range？**
   - 答案：因為 $I_P R_P K_{VCO}$ 同時也正比於迴路頻寬 (Loop Bandwidth) 和穩態時的 Bang-Bang Jitter (Dithering Jitter)。盲目加大這些參數會導致 Jitter Peaking 變嚴重，且鎖定後的穩態 Jitter 大幅惡化，犧牲了訊號品質。
3. **問題：筆記最下方寫道「FD 把頻率帶到 CDR 的 loop BW 以下再交給 PD」，這是什麼架構？為什麼要這樣做？**
   - 答案：這是 Dual-loop CDR 架構。因為 BB-CDR 純靠 Phase loop 的頻率捕捉範圍極小（只有大約 Loop BW 的大小，很容易失鎖）。因此需要一個獨立的 Frequency Detector (FD) 形成 Frequency Acquisition Loop，先粗調 VCO 頻率，把頻率誤差縮小到 $|\Delta W| < I_P R_P K_{VCO}$ 的範圍內，然後再交接給 BBPD 進行精細的相位鎖定。

**記憶口訣：** 頻率突變全靠 R，全速衝刺有限度，超過極限就滑相，先靠 FD 來帶路。 (R 代表 $R_P$)
---
