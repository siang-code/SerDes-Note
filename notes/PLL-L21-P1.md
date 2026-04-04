# PLL-L21-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L21-P1.jpg

---


---
## Advanced VCOs: Multiphase LC Ring & Distributed Traveling Wave Oscillators

### 數學推導
本頁筆記探討了三種進階 VCO 架構的演進，以下為核心數學推導：

**1. Multiphase LC Ring Oscillator (多相 LC 環形振盪器)**
*   **相位條件：** 圖中為 4 級全差分環形振盪器 (4-stage differential ring)，尾端交叉連接提供了 $180^\circ$ 的直流反相。根據巴克豪森準則 (Barkhausen Criterion)，迴路總相移必須為 $360^\circ$。因此，4 個 LC delay cell 必須提供剩餘的 $180^\circ$：
    $$\Delta \phi = \frac{180^\circ}{4} = 45^\circ \text{ per stage}$$
*   **偏頻與 Q 值退化：** 單級 LC Tank 的阻抗相位公式為：
    $$\angle Z(j\omega) = \tan^{-1}\left(Q \cdot \left(\frac{\omega_0}{\omega} - \frac{\omega}{\omega_0}\right)\right)$$
    在共振頻率 $\omega_0$ 時，相移為 $0^\circ$。為了強制產生 $45^\circ$ 的相移，振盪頻率 $\omega'$ 必須強迫偏離 $\omega_0$。此時 LC Tank 的等效阻抗 $|Z|$ 會大幅下降，等同於電路的有效品質因數 (Effective Q) 退化，這就是筆記上寫「oscillates @ $\omega' \Rightarrow Q \text{ degrades}$」的數學根本原因。
*   **多模態振盪 (Multi-mode Oscillation)：** 4 級環形迴路可以有兩種相位解滿足振盪條件：每級 $45^\circ$ (總和 $180^\circ$) 或每級 $135^\circ$ (總和 $540^\circ \equiv 180^\circ$)。設計上必須讓主模態 ($45^\circ$) 的迴路增益 (Loop Gain) $\ge 1$，並確保高頻的寄生模態 ($135^\circ$) Loop Gain $< 1$，這對應筆記圖旁的「2個解...讓高頻的 loop gain=1 (邊界)，另一個稍為 < 1」。

**2. Distributed / Rotary Traveling Wave Oscillator (RTWO 行波振盪器)**
*   **傳輸線延遲：** 將傳輸線等效為多段 LC 梯形電路，每一小段的寄生電感為 $L_u$，寄生電容為 $C_u$。單段傳遞延遲為 $t_d = \sqrt{L_u C_u}$。
*   **振盪頻率：** 筆記中的八邊形 (Octagon) 結構形成了一個封閉環。訊號以行波 (Traveling Wave) 形式在環內傳播。環路切分為 8 個節點 (0°, 45°, 90°, ..., 315°)。訊號繞行物理環路一圈，剛好經歷完整的 $360^\circ$ 相位變化。因此，振盪週期 $T$ 等於繞行一圈的總延遲：
    $$T = 8 \times t_d = 8 \sqrt{L_u C_u}$$
    $$f_{osc} = \frac{1}{T} = \frac{1}{8 \sqrt{L_u C_u}}$$
*   **負阻抗補償：** 行波在傳輸過程中會被金屬線的寄生電阻消耗能量。分佈在各節點的差分對 (Differential Pair) 提供等效負阻抗 $-G_m$（對應筆記「產生負阻抗補回損耗」），只要 $\Sigma G_m > \text{Total Loss}$，波浪就能永續繞行。

### 單位解析
**公式單位消去：**
針對 RTWO 頻率公式：$f_{osc} = \frac{1}{8 \sqrt{L_u C_u}}$
*   $L_u$ (電感): $[H] = \left[\frac{V \cdot s}{A}\right]$
*   $C_u$ (電容): $[F] = \left[\frac{A \cdot s}{V}\right]$
*   分母的根號項：$\sqrt{L_u \cdot C_u} = \sqrt{\frac{V \cdot s}{A} \cdot \frac{A \cdot s}{V}} = \sqrt{s^2} = [s]$
*   整體頻率：$f_{osc} = \frac{1}{[s]} = [Hz]$ （赫茲，物理意義完全吻合）

**圖表單位推斷：**
📈 右上角 LC Tank 頻率響應圖：
*   **上圖 (轉移函數強度)**
    - X 軸：角頻率 $\omega$ [rad/s] 或 $f$ [Hz]，中心虛線為共振頻率 $\omega_0$。
    - Y 軸：增益大小 $|H(j\omega)|$ [V/V] 或阻抗大小 [$\Omega$]，在 $\omega_0$ 處有最大峰值。
*   **下圖 (相位響應)**
    - X 軸：角頻率 $\omega$ [rad/s] 或 $f$ [Hz]。
    - Y 軸：相位角 $\angle H(j\omega)$ [Degree]，典型範圍從 $+90^\circ$ 到 $-90^\circ$，並在共振點 $\omega_0$ 穿過 $0^\circ$ 軸（藍線）。藍圈標示了為了湊齊 $45^\circ$ 相移，工作頻率被迫偏移到 $\omega'$ 的位置。

### 白話物理意義
為了在超高頻產生精準的多相訊號，我們放棄了會嚴重降低 Q 值的傳統 LC 環形電路，改讓訊號在「沒有終端電阻的傳輸線軌道」上像波浪一樣不斷跑圈圈，藉此實現極低功耗與超高頻率。

### 生活化比喻
*   **Multiphase LC Ring (多相 LC 環)：** 就像一場 4 人接力賽，規定每個人交棒時身體必須死板地傾斜 45 度 (強迫相移)。因為跑步姿勢極不自然 (偏離共振點)，跑者的速度和效率都會大幅下降 (Q 值退化)。
*   **RTWO (行波振盪器)：** 就像體育場裡滿場觀眾在玩「波浪舞」。觀眾 (交錯耦合對 $-G_m$) 不用自己繞著球場跑，只要在原地適時站起來提供一點能量 (補償損耗)，波浪就能順著環形座位 (傳輸線) 一直完美地轉下去。而且因為座位是個圓環 (Self-terminated)，波浪永遠不會撞到牆壁反彈，不會浪費多餘的能量。

### 面試必考點
1. **問題：為什麼將 LC Tank 串聯成多相環形振盪器 (Multiphase LC Ring) 會導致 Phase Noise 變差？**
   → **答案：** LC Tank 只有在共振頻率 $\omega_0$ 時相位為 $0^\circ$、等效阻抗最高 (Q 值最大)。為了在環路中湊出巴克豪森準則所需的相移（例如 4 級需要每級 $45^\circ$），必須強迫電路工作在偏離 $\omega_0$ 的頻率 $\omega'$，這會導致 Tank 等效阻抗急劇下降、Q 值嚴重退化，使振盪器的雜訊抑制能力大減。
2. **問題：筆記中第二項的 T-line delay cell VCO，其致命缺點是什麼？為什麼不能用在低功耗 SerDes？**
   → **答案：** T-line 為了避免訊號反射，必須接上與特徵阻抗相等的終端電阻 ($R=Z_0$，通常為 $50\Omega$)。若要在如此低的阻抗上產生足夠推動下一級的電壓擺幅 (Swing = I $\times$ R)，需要灌入極大的直流電流，導致靜態功耗高得令人無法接受。
3. **問題：Rotary Traveling Wave Oscillator (RTWO) 是如何解決 T-line VCO 的高功耗問題的？**
   → **答案：** RTWO 利用傳輸線形成物理上的封閉環 (Closed Loop)，因為沒有端點，所以是「Self-terminated (自我終結)」，徹底移除了會吃掉大量功耗的實體匹配電阻。均勻分佈在環上的交錯耦合對 ($-G_m$) 只需微調提供足夠的負阻抗來補償傳輸線的金屬損耗 (Loss)，即可輕鬆維持行波運作。

**記憶口訣：**
「多相偏頻 Q 必降，傳輸電阻太耗電，行波環繞無終端，負阻補損波不斷」
