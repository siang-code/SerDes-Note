# PLL-L32-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L32-P1.jpg

---


---
## 注入鎖定除頻器 (Injection Locked Divider, ILD) 與鎖定範圍推導

### 數學推導
本頁筆記的核心在推導 **注入鎖定振盪器 (Injection Locked Oscillator, ILO)** 的單邊鎖定範圍 (Locking Range, $\omega_L$)，即經典的 Adler's Equation 的相量圖推導法，並將此概念應用於極高頻的除頻器設計。

1. **建立 Phasor (相量) 電流平衡方程式**：
   根據 KCL，從外部注入的電流 $\vec{I}_{inj}$ 與振盪器本體提供的維持電流 $\vec{I}_{osc}$ 會共同匯入 LC Tank，形成總電流 $\vec{I}_T$。即：
   $$\vec{I}_{inj} + \vec{I}_{osc} = \vec{I}_T$$
   當振盪器被鎖定在注入頻率 $\omega_{inj}$ 時，若 $\omega_{inj}$ 偏離了 Tank 的自然共振頻率 $\omega_0$，Tank 會產生一個相移 $\phi_0$。因此，Tank 的端電壓 $V_{out}$ 與流進 Tank 的總電流 $I_T$ 之間存在 $\phi_0$ 的相位差。由於 $\vec{I}_{osc}$ 與 $V_{out}$ 同相 (或嚴格說是 $180^\circ$ 反相的等效負電阻電流)，所以 $\vec{I}_T$ 與 $\vec{I}_{osc}$ 之間也會有 $\phi_0$ 的夾角。

2. **利用餘弦定理求取極值 (最大相移)**：
   由向量三角形可得邊長關係：
   $$I_{inj}^2 = I_{osc}^2 + I_T^2 - 2 I_{osc} I_T \cos\phi_0$$
   為了找出系統能容忍的「最大相移 $\phi_0$」(這對應到最大的頻率偏移，也就是鎖定範圍的邊界)，我們對 $I_T$ 微分並令 $\frac{d(\cos\phi_0)}{dI_T} = 0$：
   $$0 = 2I_T - 2I_{osc} \left( \cos\phi_0 + I_T \frac{d\cos\phi_0}{dI_T} \right)$$
   代入 $\frac{d\cos\phi_0}{dI_T} = 0$ 消除後半項，得到最大相移發生的條件：
   $$I_T = I_{osc} \cos\phi_0$$
   **幾何意義**：當 $\phi_0$ 達到最大時，向量 $\vec{I}_T$ 必然與 $\vec{I}_{inj}$ 垂直 ($\vec{I}_T \perp \vec{I}_{inj}$)，形成直角三角形。
   由該直角三角形可知：
   $$\tan\phi_{0,max} = \frac{I_{inj}}{I_T} = \frac{I_{inj}}{I_{osc} \cos\phi_{0,max}} = \frac{I_{inj}}{I_{osc}\sqrt{1 - (I_{inj}/I_{osc})^2}}$$

3. **結合 LC Tank 的相位斜率**：
   LC Tank 的品質因子 $Q$ 與相位斜率的關係為：$Q = \frac{\omega_0}{2} \left| \frac{d\phi}{d\omega} \right|$。
   對於微小的頻率偏移 $\Delta\omega = |\omega_0 - \omega_{inj}|$，相移 $\phi_0$ 可近似為：
   $$\tan\phi_{0,max} \approx \phi_{0,max} = \left| \frac{d\phi}{d\omega} \right| \cdot |\omega_0 - \omega_{inj}| = \frac{2Q}{\omega_0} \omega_L$$
   (其中單邊鎖定範圍 $\omega_L = |\omega_0 - \omega_{inj}|$)

4. **推導出最終的 Locking Range**：
   將步驟2與步驟3的 $\tan\phi_{0,max}$ 聯立：
   $$\frac{2Q}{\omega_0} \omega_L = \frac{I_{inj}}{I_{osc}\sqrt{1 - (I_{inj}/I_{osc})^2}}$$
   $$\Rightarrow \omega_L = \frac{\omega_0}{2Q} \cdot \frac{I_{inj}}{I_{osc}} \cdot \frac{1}{\sqrt{1 - (I_{inj}/I_{osc})^2}}$$
   當注入訊號較小 ($I_{inj} \ll I_{osc}$) 時，可簡化為 $\omega_L \approx \frac{\omega_0}{2Q} \frac{I_{inj}}{I_{osc}}$。總鎖定範圍即為 $2\omega_L$。

5. **應用於高頻除頻器 (ILFD)**：
   筆記右上角提到「To achieve even higher freq $\Rightarrow$ Need the simple topology」。傳統的 CML 除頻器速度受限，因此改將頻率為 $2\omega_0$ 的訊號從 Tail 端 (Control line points) 注入 LC VCO，利用電路的非線性產生 2 階諧波 (2nd order harmonics) 互鎖，使振盪器輸出穩定在 $\omega_0$，這就是極高頻 SerDes 常見的次諧波注入鎖定除頻器 ($\div 2$ circuitry)。

### 單位解析
**公式單位消去：**
1. **$Q = \frac{\omega_0}{2} \left| \frac{d\phi}{d\omega} \right|$**
   - $\omega_0$: [rad/s]
   - $\phi$: [rad]
   - $\omega$: [rad/s]
   - 代入：[rad/s] × ([rad] / [rad/s]) = [rad] = 無單位 (純量)。這驗證了品質因子 $Q$ 是個無單位的比例常數。
2. **$\omega_L = \frac{\omega_0}{2Q} \cdot \frac{I_{inj}}{I_{osc}}$**
   - $\omega_0$: [rad/s]
   - $Q$: 無單位
   - $I_{inj}, I_{osc}$: [A]
   - 代入：([rad/s] / 1) × ([A] / [A]) = [rad/s]。等式兩邊單位一致，皆為角頻率。

**圖表單位推斷：**
📈 圖表單位推斷 (LC Tank 頻率響應圖)：
- **上圖 (阻抗大小 $|Z|$)**：
  - X 軸：角頻率 $\omega$ [rad/s] 或 $f$ [GHz]，典型範圍：VCO 振盪頻率附近 (例如 25~35 GHz)。
  - Y 軸：等效阻抗 $|Z|$ [$\Omega$]，典型範圍：數百 $\Omega$ (取決於 Tank 的 $R_p$)。
- **下圖 (相位響應 $\angle Z$)**：
  - X 軸：角頻率 $\omega$ [rad/s] 或 $f$ [GHz]。
  - Y 軸：相移度數 $\phi$ [度] 或 [rad]，典型範圍：$+90^\circ$ (低頻電感性) 至 $-90^\circ$ (高頻電容性)，在 $\omega_0$ 時交會於 $0^\circ$。

### 白話物理意義
「注入鎖定」就像是在推一個正在盪鞦韆的人；如果你推的節奏（$I_{inj}$）跟鞦韆原本的節奏（$I_{osc}$）差不多，鞦韆就會乖乖被你「牽著走」；推的力氣越大（$I_{inj}$ 大），你能容忍的節奏誤差（Locking Range）就越寬。

### 生活化比喻
想像「兩人三腳」的遊戲。原本振盪器有自己的跑步節奏（$\omega_0$），現在來了一個帶有自己節奏的強勢隊友（注入訊號 $\omega_{inj}$）把你綁在一起。如果兩人的節奏很接近，或者這位隊友的力氣超大（$I_{inj}$ 很大），那你就會被迫完全配合他的腳步（這叫 Locking）。但如果他跑太快或太慢（超出 Lock Range），或者他力氣太小拉不動你，你們就會各跑各的，最後跌倒失去同步（Unlocking）。

### 面試必考點
1. **問題：在 Injection Locked Oscillator (ILO) 中，想要增加 Locking Range (鎖定範圍) 有哪些方法？**
   - 答案：根據 $\omega_L \propto \frac{\omega_0}{2Q} \frac{I_{inj}}{I_{osc}}$，可以 (1) 增加注入電流強度 $I_{inj}$；(2) 降低 Tank 的 $Q$ 值 (加上電阻，但會犧牲 Phase Noise)；(3) 降低振盪器本體的偏壓電流 $I_{osc}$ (讓本體變弱，更容易被牽著走)。
2. **問題：在最大鎖定範圍的邊界 (Edge of lock range) 時，注入電流與 Tank 電流的相位關係為何？**
   - 答案：此時向量 $\vec{I}_{inj}$ 必須與總電流 $\vec{I}_T$ 互相垂直 ($\vec{I}_T \perp \vec{I}_{inj}$)，此時 Tank 提供的相移 $\phi_0$ 達到系統所能容忍的極限。
3. **問題：為何在 112G/224G 等極高頻 SerDes 系統中，第一級除頻器常使用 ILFD (注入鎖定除頻器) 而非傳統的 CML Divider？**
   - 答案：傳統 CML Divider 依靠 Latch 的正回授迴路運作，受到寄生 RC 延遲的限制，在毫米波頻段會因速度跟不上而失效。ILFD 本質上是一個 LC 振盪器，利用 Tail 注入 $2\omega_0$ 觸發次諧波鎖定產生 $\omega_0$ 輸出，其最高工作頻率僅受限於 LC Tank 的共振，非常適合極高頻應用。

**記憶口訣：**
**「鎖定範圍看三寶：注入大、Q低、本體小！」** (對應 $I_{inj} \uparrow, Q \downarrow, I_{osc} \downarrow$)
**「邊界直角現，注入拉到極限！」** (最大相移時 $\vec{I}_{inj} \perp \vec{I}_T$)
---
