# EQ-L11-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/EQ-L11-P1.jpg

---


### 數學推導
1. **半電路模型 (Half-Circuit Model)**:
   由於電路為全差動架構，我們可以取半電路進行分析。在差動模式下，兩個源極節點之間的電壓中點為虛擬接地。因此，源極退化網路 $R_S$ 與 $2C_S$（圖上標示為 $C_S$ 在兩端，其實等效半電路為 $2C_S$ 與 $R_S/2$ 並聯）的等效阻抗為：
   $Z_S = \frac{R_S}{2} \parallel \frac{1}{s(2C_S)} = \frac{\frac{R_S}{2} \cdot \frac{1}{s 2C_S}}{\frac{R_S}{2} + \frac{1}{s 2C_S}} = \frac{R_S / 2}{1 + s R_S C_S}$
2. **轉移函數 (Transfer Function)**:
   包含源極退化阻抗的共源極放大器增益公式為 $A_v = \frac{-g_m R_D}{1 + g_m Z_S}$。
   代入上述 $Z_S$：
   $A_v(s) = \frac{-g_m R_D}{1 + g_m \left( \frac{R_S/2}{1 + s R_S C_S} \right)} = \frac{-g_m R_D (1 + s R_S C_S)}{1 + s R_S C_S + g_m R_S/2}$
3. **整理為標準零極點式**:
   將分母常數項提出，萃取出直流增益 $\frac{-g_m R_D}{1 + g_m R_S/2}$：
   $A_v(s) = \left( \frac{-g_m R_D}{1 + g_m R_S/2} \right) \cdot \frac{1 + s R_S C_S}{1 + s \frac{R_S C_S}{1 + g_m R_S/2}}$
   再加上由輸出端負載 $R_D$ 與寄生電容 $C_L$ 所產生的極點 $\omega_{p2} = \frac{1}{R_D C_L}$，可得完整轉移函數：
   $\frac{V_{out}}{V_{in}}(s) \approx \frac{g_m R_D}{1 + \frac{g_m R_S}{2}} \cdot \frac{1 + \frac{s}{\omega_{z1}}}{(1 + \frac{s}{\omega_{p1}})(1 + \frac{s}{\omega_{p2}})}$
4. **零極點萃取**:
   - **Zero**: $\omega_{z1} = \frac{1}{R_S C_S}$ (由源極 RC 網路決定)
   - **Pole 1**: $\omega_{p1} = \frac{1 + \frac{g_m R_S}{2}}{R_S C_S} = \omega_{z1} \left(1 + \frac{g_m R_S}{2}\right)$ (源極網路產生的第一極點)
   - **Pole 2**: $\omega_{p2} = \frac{1}{R_D C_L}$ (輸出節點原本的 RC 寄生極點)

### 單位解析
**公式單位消去：**
- **零點頻率 $\omega_{z1}$**:
  $\omega_{z1} = \frac{1}{R_S \cdot C_S}$
  $[ \frac{1}{\Omega \cdot F} ] = \left[ \frac{1}{(V/A) \cdot (C/V)} \right] = \left[ \frac{1}{C/A} \right] = \left[ \frac{1}{s} \right] = [rad/s]$
- **低頻直流增益 $A_{DC}$**:
  $A_{DC} = \frac{g_m \cdot R_D}{1 + g_m \cdot R_S/2}$
  分子：$g_m [A/V] \times R_D [V/A] = [無單位]$
  分母：$1 + g_m [A/V] \times (R_S/2) [V/A] = 1 + [無單位] = [無單位]$
  整體單位為 [V/V] (無單位比例)。

**圖表單位推斷：**
📈 圖表單位推斷：
- **波特圖 (Bode Plot - 增益 $|V_{out}/V_{in}|$ vs $\omega$)**:
  - X 軸：角頻率 $\omega$ [rad/s] (對數刻度)，典型範圍 $10^8 \sim 10^{11}$ rad/s
  - Y 軸：電壓增益幅度 $|V_{out}/V_{in}|$ [V/V 或 dB] (對數刻度)，高頻平坦區固定為 $g_m R_D$，典型範圍 $0 \sim 10$ V/V。
- **波特圖 (Bode Plot - 相位 $\angle V_{out}/V_{in}$ vs $\omega$)**:
  - X 軸：角頻率 $\omega$ [rad/s] (對數刻度)
  - Y 軸：相位角 [Degree, $^\circ$]，典型範圍 $-90^\circ \sim +90^\circ$。
- **MOS Varactor 轉移曲線圖 ($C_{GS}$ vs $V_{GS}$)**:
  - X 軸：閘源極電壓 $V_{GS}$ [V]，典型範圍 $-1 \sim +1$ V
  - Y 軸：等效電容 $C_{GS}$ [fF 或 pF]，典型範圍 $10 \sim 100$ fF。

### 白話物理意義
CTLE (連續時間線性等化器) 的「高頻提升」其實是個幻覺；它絕對無法突破電晶體本身的物理極限 ($g_m R_D$)，它的真相是**「藉由刻意壓抑低頻信號，讓高頻信號相對顯得比較大」**，進而達到高低頻能量平衡的等化效果。

### 生活化比喻
這就像是你戴著一副最大音量已經固定的耳機聽音樂（高頻極限 $g_m R_D$）。當你覺得貝斯（低頻）太轟、蓋過了鈸的聲音（高頻）時，你無法把鈸的聲音單獨調得更大，你只能去轉動「降低低音」的旋鈕（改變 $V_{ctrl}$ 降低低頻增益）。低音變小了，高音的細節自然就「相對」凸顯出來了。

### 面試必考點
1. **問題：在典型的 Source Degeneration CTLE 中，為何高頻增益的極限永遠是 $g_m R_D$，與源極的 R, C 無關？**
   → 答案：因為在極高頻率下，源極的退化電容 $C_S$ 會視為短路 (Short)。此時源極等於直接交流接地，整個電路退化回最基本、沒有源極退化的共源極 (Common-Source) 放大器，所以高頻的最大極限增益就是本質的 $g_m R_D$。
2. **問題：根據筆記波特圖，當控制電壓 $V_{ctrl}$ 上升時，低頻增益變大，但 Peaking Amount（補償量）卻變小，請用數學公式解釋原因？**
   → 答案：由圖與筆記可知 $V_{ctrl} \uparrow$ 會使 $R_{eq} \downarrow$。低頻增益為 $\frac{g_m R_D}{1 + g_m R_{eq}/2}$，當 $R_{eq}$ 下降時，分母變小，低頻增益上升。而高頻增益固定為 $g_m R_D$，Peaking Amount = (高頻增益 / 低頻增益) = $1 + g_m R_{eq}/2$。因此 $R_{eq}$ 變小，Peaking Amount 自然就變小了。這適合用在通道耗損較輕微的場景。
3. **問題：為什麼圖中的 $\omega_z$ 和 $\omega_{p1}$ 在 $V_{ctrl}$ 改變時，向高頻移動的幅度不同，導致曲線在高頻會合？**
   → 答案：因為 $\omega_z = \frac{1}{R_S C_S}$，而 $\omega_{p1} = \omega_z (1 + \frac{g_m R_S}{2})$。當 $R_S$ 下降時，$\omega_z$ 往高頻移動；但同時乘載係數 $(1 + \frac{g_m R_S}{2})$ 也在縮小，導致 $\omega_{p1}$ 往高頻移動的「比例」不如 $\omega_z$ 來得大。在對數頻率軸上，兩者的距離變近了，最終所有曲線都會收斂在同一個高頻增益極限上。

**記憶口訣：**
**「CTLE 假放大，真壓抑；高頻頂到底 ($g_m R_D$)，全靠壓低頻。」**
