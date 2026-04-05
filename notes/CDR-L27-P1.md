# CDR-L27-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L27-P1.jpg

---


---
## 結合 DLL 與 PLL 打破 JTRAN 與 JTOL 頻寬限制 (Combine DLL & PLL to separate the corner freq. of JTRAN & JTOL)

### 數學推導
在這個創新的架構中，輸入信號先經過一個電壓控制延遲線 (VCDL)，再進入 Phase Detector (PD) 與 VCO 的輸出進行比較。VCDL 與 VCO 共用同一個控制電壓 $V_c$。
我們來逐步推導這個系統的轉移函數：

1. **建立系統方程式：**
   - 輸入相位 $\phi_{in}$ 經過 VCDL（相位增益為 $k_{ps}$），產生的等效相位偏移為 $V_c \cdot k_{ps}$。
   - Phase Detector (PD) 實際比較的相位差為：$\Delta\phi = \phi_{in} - V_c \cdot k_{ps} - \phi_{out}$。
   - Charge Pump (CP) 的平均輸出電流：$I_{av} = \Delta\phi \cdot \frac{I_p}{2\pi}$。
   - 迴路濾波器（僅有一顆電容 $C$）上的控制電壓：$V_c = I_{av} \cdot \frac{1}{sC}$。
   - 將 $I_{av}$ 展開代入，得到 $V_c$ 與相位的關係：
     $$V_c = (\phi_{in} - V_c \cdot k_{ps} - \phi_{out}) \cdot \frac{I_p}{2\pi sC} \quad \text{--- (式 1)}$$
   - 對於 VCO，其輸出相位是控制電壓的積分：
     $$s\phi_{out} = K_{vco} \cdot V_c \implies V_c = \frac{s\phi_{out}}{K_{vco}} \quad \text{--- (式 2)}$$

2. **推導 Jitter Transfer (JTRAN, $\phi_{out}/\phi_{in}$)：**
   - 將 (式 2) 代入 (式 1) 消去 $V_c$：
     $$\frac{s\phi_{out}}{K_{vco}} = \left(\phi_{in} - k_{ps}\frac{s\phi_{out}}{K_{vco}} - \phi_{out}\right) \frac{I_p}{2\pi sC}$$
   - 等式兩邊同乘 $2\pi sC \cdot K_{vco}$ 並移項整理：
     $$s^2 2\pi C \phi_{out} = I_p K_{vco} \phi_{in} - I_p k_{ps} s \phi_{out} - I_p K_{vco} \phi_{out}$$
     $$\Rightarrow (s^2 2\pi C + s I_p k_{ps} + I_p K_{vco}) \phi_{out} = I_p K_{vco} \phi_{in}$$
   - 得到轉移函數：
     $$JTRAN = \frac{\phi_{out}}{\phi_{in}}(s) = \frac{\frac{I_p K_{vco}}{2\pi C}}{s^2 + s\frac{I_p k_{ps}}{2\pi C} + \frac{I_p K_{vco}}{2\pi C}}$$
   - 我們定義系統的自然頻率 $\omega_n$ 與阻尼比 $\zeta$：
     $$\omega_n^2 = \frac{I_p K_{vco}}{2\pi C}, \quad 2\zeta\omega_n = \frac{I_p k_{ps}}{2\pi C}$$
   - 透過設計讓阻尼比極大 ($\zeta \gg 1$)，這會產生兩個距離很遠的實數極點 $\omega_1$ (主極點，低頻) 與 $\omega_2$ (高頻)。因此分母可近似為 $(s+\omega_1)(s+\omega_2) \approx s^2 + \omega_2 s + \omega_1\omega_2$：
     $$\omega_1 = \frac{\omega_n^2}{2\zeta\omega_n} = \frac{K_{vco}}{k_{ps}}, \quad \omega_2 = 2\zeta\omega_n = \frac{I_p k_{ps}}{2\pi C}$$
   - 最終得到 JTRAN：
     $$JTRAN \approx \frac{\omega_n^2}{(s+\omega_1)(s+\omega_2)}$$
     *(此處可知 JTRAN 的轉折頻率由較低的 $\omega_1$ 決定)*

3. **推導 Jitter Tolerance (JTOL, $\phi_{in,max}$)：**
   - JTOL 定義為：在維持 PD 輸入端最大容許相位誤差（例如 $\pm0.5$ UI，避免 Cycle Slip）的情況下，系統能承受的輸入抖動。
     $$JTOL = \phi_{in,max} \quad \text{s.t.} \quad |\Delta\phi| = 0.5 \text{ UI}$$
   - 從前面整理出 $\Delta\phi$ 的表達式，代入 $\phi_{out} = JTRAN \cdot \phi_{in}$ 以及 $\omega_1 = \frac{K_{vco}}{k_{ps}}$：
     $$\Delta\phi = \phi_{in} - k_{ps}V_c - \phi_{out} = \phi_{in} - \frac{k_{ps} s}{K_{vco}}\phi_{out} - \phi_{out}$$
     $$\Delta\phi = \phi_{in} \left[ 1 - \left(1 + \frac{s}{\omega_1}\right) JTRAN \right]$$
   - 將 $JTRAN$ 代入化簡中括號內的項次：
     $$1 - \frac{s+\omega_1}{\omega_1} \cdot \frac{\omega_n^2}{(s+\omega_1)(s+\omega_2)} = 1 - \frac{\omega_n^2}{\omega_1(s+\omega_2)}$$
   - 因為 $\frac{\omega_n^2}{\omega_1} = \omega_2$，上式完美化簡為：
     $$1 - \frac{\omega_2}{s+\omega_2} = \frac{s}{s+\omega_2}$$
   - 因此 JTOL 為：
     $$JTOL = \frac{0.5}{|\frac{s}{s+\omega_2}|} = \frac{0.5 (s+\omega_2)}{s}$$
     *(此處可知 JTOL 有一個位於原點的極點與位於 $\omega_2$ 的零點，轉折頻率由較高的 $\omega_2$ 決定)*

### 單位解析
**公式單位消去：**
- **控制電壓 ($V_c$)**：$V_c = I_{av} \cdot \frac{1}{sC}$
  $[V] = [A] \cdot [\frac{1}{\frac{1}{s} \cdot \frac{A \cdot s}{V}}] = [A] \cdot [\frac{V}{A}] = [V]$
- **自然頻率平方 ($\omega_n^2$)**：$\omega_n^2 = \frac{I_p K_{vco}}{2\pi C}$
  $[(\frac{rad}{s})^2] = \frac{[A] \cdot [\frac{rad}{s \cdot V}]}{[\frac{A \cdot s}{V}]} = \frac{rad}{s^2}$
- **極點 $\omega_1$**：$\omega_1 = \frac{K_{vco}}{k_{ps}}$
  $[\frac{rad}{s}] = \frac{[\frac{rad}{s \cdot V}]}{[\frac{rad}{V}]} = \frac{1}{s} = [\frac{rad}{s}]$
- **極點 $\omega_2$**：$\omega_2 = \frac{I_p k_{ps}}{2\pi C}$
  $[\frac{rad}{s}] = \frac{[A] \cdot [\frac{rad}{V}]}{[\frac{A \cdot s}{V}]} = \frac{rad}{s}$

**圖表單位推斷：**
📈 **圖 1：PD+CP 轉移曲線**
- X 軸：相位差 $\Delta\phi$ [rad]，典型範圍 $-2\pi \sim 2\pi$
- Y 軸：平均電流 $I_{av}$ [A]，典型範圍 $-I_p \sim I_p$（約 $\mu A \sim mA$ 等級）

📈 **圖 2：VCDL 與 VCO 轉移曲線**
- X 軸：控制電壓 $V_c$ [V]，典型範圍 $0 \sim V_{DD}$
- Y 軸 (VCDL)：相位偏移 $\Delta\phi$ [rad]；Y 軸 (VCO)：輸出頻率 $\omega_{out}$ [rad/s]

📈 **圖 3：JTRAN 頻率響應 (Bode Plot)**
- X 軸：角頻率 $\omega$ [rad/s] (對數刻度)
- Y 軸：轉移增益 JTRAN [dB]，在 $\omega_1$ 前為 0dB，過 $\omega_1$ 以 -20dB/dec 下降，過 $\omega_2$ 以 -40dB/dec 下降。

📈 **圖 4：JTOL 頻率響應 (Bode Plot)**
- X 軸：角頻率 $\omega$ [rad/s] (對數刻度)
- Y 軸：抖動容忍度 JTOL [UI] (對數刻度)，低頻區以 -20dB/dec 下降，高頻區於 $\omega_2$ 處打平至 0.5 UI。

### 白話物理意義
透過在 PD 前方加入一個與 VCO 共用控制電壓的 Delay Line，形成「DLL+PLL」雙重迴路，成功將 Jitter 濾波頻寬（低頻 $\omega_1$）與 Jitter 容忍頻寬（高頻 $\omega_2$）互相脫鉤，打破傳統二階 PLL 無法同時兼顧濾波與容忍的限制。

### 生活化比喻
這就像一台車同時裝備了「氣壓避震器」(PLL) 和「主動式電子懸吊」(DLL)。
一般的氣壓避震（PLL）反應慢，調軟一點能完美濾掉碎石路面的震動（低 JTRAN 頻寬 $\omega_1$）；但遇到大坑洞時來不及反應，車底會撞擊地面（低頻 JTOL 差）。
現在加入能瞬間偵測並改變輪胎高度的主動懸吊（DLL），遇到大坑洞瞬間伸展（高 JTOL 頻寬 $\omega_2$）吸收衝擊，而氣壓避震依然保持柔軟濾掉高頻噪音。兩套系統完美分工，兼顧了平穩與坑洞容忍度。

### 面試必考點
1. **問題：在傳統的二階 Charge-Pump PLL 中，為何 Jitter Transfer (JTRAN) 和 Jitter Tolerance (JTOL) 會有 trade-off？**
   - 答案：傳統二階 PLL 中，JTRAN 和 JTOL 的轉折頻率主要皆由同一個 Loop Bandwidth ($\omega_n$) 決定。為了加強濾波（要求較低的 JTRAN 頻寬），必須縮小 $\omega_n$；但這會導致 PLL 無法快速追蹤輸入信號的大幅低頻相位變化，導致 JTOL 變差、容易發生 Cycle Slip。兩者在頻寬設計上互相衝突。
2. **問題：本圖中的 DLL+PLL 架構如何打破上述的 trade-off？原理為何？**
   - 答案：藉由在輸入端加入一個由 $V_c$ 控制的 VCDL，構成一個具備極大阻尼比（$\zeta \gg 1$）的系統，產生兩個分離的實數極點。此時 JTRAN 的轉折頻率由第一個極點 $\omega_1 = K_{vco}/k_{ps}$ 決定（可設計在極低頻以加強濾波）；而 JTOL 的轉折頻率由第二個極點 $\omega_2 = I_p k_{ps}/2\pi C$ 決定（可設計在較高頻以擴大容忍範圍），成功使兩者脫鉤。
3. **問題：如果想要單獨降低此系統的 JTRAN 頻寬，卻完全不影響 JTOL 頻寬，你應該調整哪個電路參數？為什麼？**
   - 答案：應該調降 VCO 的增益 $K_{vco}$。從推導出的公式可知 $\omega_1 = K_{vco}/k_{ps}$，而 $\omega_2 = I_p k_{ps}/2\pi C$。由於 $\omega_2$ 的決定式中完全不包含 $K_{vco}$，因此單純降低 $K_{vco}$ 就能縮小 JTRAN 頻寬（$\omega_1$），且對 JTOL 頻寬（$\omega_2$）毫無影響。

**記憶口訣：**
- **雙管齊下破限制**：DLL 顧容忍 ($\omega_2$ 往高頻推)，PLL 顧濾波 ($\omega_1$ 往低頻壓)。
- **極點分離法**：$\omega_1$ 只看元件壓控增益比 ($K_{vco}/k_{ps}$)，$\omega_2$ 才看充放電 ($I_p k_{ps}/C$)。
