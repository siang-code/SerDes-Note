# TIA-L11-P3

> 分析日期：2026-04-06
> 原始圖片：images/done/TIA-L11-P3.jpg

---


---
## Inverter-based TIA 的頻寬與雜訊分析 (Bandwidth & Noise Analysis)

### 數學推導
這份筆記涵蓋了 Inverter-based TIA 的兩個核心議題：**極點頻寬估算 (Zero-Value Time Constant, ZVTC)** 以及 **輸出雜訊分析**。

**Part 1: 頻寬分析 (轉移函數分母 $D(s) = 1 + b_1 s + b_2 s^2$)**
根據開路時間常數法 (Open-Circuit Time Constant)，我們可以估算系統的極點位置。
1. **求 $b_1$ (第一階係數):**
   $b_1 = \tau_{Cin}^0 + \tau_{CL}^0$
   *   **輸入端時間常數 $\tau_{Cin}^0$:** 假設輸出端 $C_L$ 拔除 (Open)。因為 $R_F$ 加上負回授，閉迴路輸入阻抗 $R_{in} \approx \frac{1}{g_{mp}+g_{mn}}$ (假設迴路增益夠大)。因此 $\tau_{Cin}^0 \approx C_{in} \times \frac{1}{g_{mp}+g_{mn}}$。
   *   **輸出端時間常數 $\tau_{CL}^0$:** 假設輸入端 $C_{in}$ 拔除 (Open)。閉迴路輸出阻抗 $R_{out}$ 同樣約為 $\frac{1}{g_{mp}+g_{mn}}$。因此 $\tau_{CL}^0 \approx C_L \times \frac{1}{g_{mp}+g_{mn}}$。

2. **求 $b_2$ (第二階係數):**
   $b_2$ 可以透過兩種路徑計算來交互驗證（筆記中特別標示了「幾乎相等」）：
   *   **路徑一 ($b_2 = \tau_{Cin}^0 \times \tau_{CL}^{Cin\text{-short}}$):** 
       若將輸入端 $C_{in}$ 短路至 AC 地，輸出端看進去的阻抗剩下 $R_F \parallel r_o \approx R_F$。所以 $\tau_{CL}^{Cin\text{-short}} \approx R_F C_L$。
       相乘得到：$b_2 = \left(C_{in} \frac{1}{g_{mp}+g_{mn}}\right) \times (R_F C_L) = \frac{C_{in} C_L R_F}{g_{mp}+g_{mn}}$。
   *   **路徑二 ($b_2 = \tau_{CL}^0 \times \tau_{Cin}^{CL\text{-short}}$):**
       若將輸出端 $C_L$ 短路至 AC 地，輸入端看進去的阻抗只剩下 $R_F$。所以 $\tau_{Cin}^{CL\text{-short}} = R_F C_{in}$。
       相乘得到：$b_2 = \left(C_L \frac{1}{g_{mp}+g_{mn}}\right) \times (R_F C_{in}) = \frac{C_{in} C_L R_F}{g_{mp}+g_{mn}}$。
   *   **結論:** 兩種推導結果完全一致，驗證了系統二階響應的係數估算。

**Part 2: 雜訊分析 (MOSFET Noise Contribution)**
為了分析 MOS 產生的雜訊對輸出的影響，筆記採用了極具物理直覺的「阻抗法」：
1. 考慮 MOS 的 Thermal Noise 電流 $\overline{I_{n,M}^2} = \overline{I_{n,Mp}^2} + \overline{I_{n,Mn}^2} = 4kT\gamma(g_{mp}+g_{mn})$。
2. 假設輸入端 Floating ($I_{in}=0$)，此時沒有 AC 訊號電流流過 $R_F$，因此 $V_{in} = V_{out}$（Gate = Drain）。
3. 當 Gate 和 Drain 短接時，MOS 等效變成了 **Diode-connected** 組態，其看進去的阻抗 $R_{out} \approx \frac{1}{g_{mp}+g_{mn}}$。
4. 輸出電壓雜訊即為雜訊電流乘上等效阻抗的平方：
   $\overline{V_{n,out,M}^2} = \overline{I_{n,M}^2} \times R_{out}^2 = \overline{I_{n,M}^2} \times \left(\frac{1}{g_{mp}+g_{mn}}\right)^2$
   展開得到：$\overline{V_{n,out,M}^2} = 4kT\gamma(g_{m,tot}) \times \frac{1}{(g_{m,tot})^2} = \frac{4kT\gamma}{g_{mp}+g_{mn}}$。
5. **結論:** $g_m$ 越大，MOS 貢獻的輸出電壓雜訊越小！

**Part 3: 右半平面零點 (RHP Zero)**
筆記右下角提到了 $C_{gd}$ 的影響：
1. 當訊號頻率升高，訊號會直接透過 $C_{gd}$ 前饋 (Feedforward) 到輸出端，而不經過 $g_m$ 反相放大。
2. 找零點即是令 $V_{out} = 0$。此時前饋電流等於主動電流：$s C_{gd} V_{in} = (g_{mp}+g_{mn}) V_{in}$。
3. 解得零點頻率 $\omega_z = +\frac{g_{mp}+g_{mn}}{C_{gd}}$。此為正值，代表這是一個 Right-Half Plane (RHP) Zero，會嚴重惡化 Phase Margin。

### 單位解析
**公式單位消去：**
1. **時間常數 $\tau$:**
   $\tau = R \times C \Rightarrow [\Omega] \times [\text{F}] = \left[\frac{\text{V}}{\text{A}}\right] \times \left[\frac{\text{C}}{\text{V}}\right] = \left[\frac{\text{C}}{\text{A}}\right] = \left[\frac{\text{A} \cdot \text{s}}{\text{A}}\right] = [\text{s}]$ (秒)
2. **雜訊頻譜密度 (Noise Spectral Density):**
   $\overline{V_n^2} = \overline{I_n^2} \times R^2 \Rightarrow \left[\frac{\text{A}^2}{\text{Hz}}\right] \times [\Omega^2] = \left[\frac{\text{A}^2}{\text{Hz}}\right] \times \left[\frac{\text{V}^2}{\text{A}^2}\right] = \left[\frac{\text{V}^2}{\text{Hz}}\right]$
3. **轉導 $g_m$ 與阻抗 $R$:**
   $R_{in} \approx \frac{1}{g_m} \Rightarrow [\Omega] = \frac{1}{[\text{A}/\text{V}]} = \left[\frac{\text{V}}{\text{A}}\right]$ (匹配無誤)

**圖表單位推斷：**
本頁無圖表（全為電路圖與數學推導式）。

### 白話物理意義
Inverter-TIA 就像是自己把自己的頭尾接起來（Diode-connected），靠著極低的阻抗來吸收輸入的光電流，並且只要內部電晶體夠強壯（$g_m$ 夠大），就能把元件自己產生的電壓抖動（雜訊）壓制到最低。

### 生活化比喻
把 TIA 想像成一個夜店的「自動旋轉門」（回授網路）。
輸入的光電流是急著進場的客人，如果轉門的馬達力量（**$g_m$**）越大，門轉得越快、阻力越小（**阻抗低，頻寬大**），客人就不會塞在門口（**輸入電壓突波小**）。同時，超強力的馬達也能穩住轉軸，就算馬達本身有點震動（**MOS 電流雜訊**），也不會導致整扇門劇烈搖晃（**輸出電壓雜訊變小**）。

### 面試必考點
1. **問題：在設計 Inverter-based TIA 時，為了降低 MOS 貢獻的電壓雜訊，你應該把 MOS 的 $g_m$ 調大還是調小？為什麼？** 
   → **答案：應該調大。** 雖然調大 $g_m$ 會讓元件本身的電流雜訊 ($\overline{I_n^2} \propto g_m$) 變大，但是負回授造成的等效輸出阻抗 ($1/g_m$) 會以**平方倍**下降。最終輸出電壓雜訊 $\overline{V_n^2} = \overline{I_n^2} \times R_{out}^2 \propto g_m \times (1/g_m)^2 = 1/g_m$，所以 $g_m$ 越大，輸出電壓雜訊反而越小。
2. **問題：請解釋 ZVTC (Zero-Value Time Constant) 估算二階極點 $b_2$ 係數時，物理意義是什麼？** 
   → **答案：** $b_2$ 代表兩個極點時間常數的乘積。物理上，我們分別計算「當一個電容開路時，另一個電容看到的時間常數」乘上「當剛才那個電容短路時，這個電容看到的時間常數」。筆記中證明了不管先短路哪一個，乘積的結果都相等 ($C_{in} C_L R_F / g_{m,tot}$)，這確保了系統特徵方程式估算的自洽性。
3. **問題：高頻時 TIA 電路中的 $C_{gd}$ 會造成什麼問題？** 
   → **答案：會產生 RHP Zero (右半平面零點)。** 因為高頻訊號會繞過 $g_m$ 主放大器，直接透過 $C_{gd}$ 前饋 (Feedforward) 到輸出端。這個前饋訊號與主放大訊號極性相反，會導致相位嚴重延遲，吃掉 Phase Margin，造成 TIA 轉態時產生振盪 (Ringing)。

**記憶口訣：**
**「$g_m$ 大好辦事：阻抗低、頻寬寬、電壓雜訊少一半！但要小心 $C_{gd}$ 走後門（RHP Zero）惹麻煩！」**
