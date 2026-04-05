# CDR-L11-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L11-P1.jpg

---


---
## Bang-Bang CDR 頻寬特性與 Half-Rate 相位偵測器 (Alexander PD)

### 數學推導
BB-CDR (Bang-Bang CDR) 由於使用了非線性的 Bang-Bang Phase Detector (BBPD)，其迴路頻寬並非常數，而是與輸入 Jitter 的大小息息相關。
1. **BBPD 有效增益 ($K_{pd,eff}$)**：
   BBPD 的輸出是固定的 $\pm 1$（Bang-Bang），對於弦波抖動 (Sinusoidal Jitter)，其等效的線性增益與輸入抖動峰值 $\phi_{in,p}$ 成反比：
   $K_{pd,eff} \approx \frac{2 I_p}{\pi \phi_{in,p}}$
2. **迴路頻寬 ($\omega_{-3dB}$)**：
   在二階 PLL/CDR 迴路中，高頻時 Loop Filter 的阻抗主要由電阻 $R_p$ 決定（$C_p$ 視為短路）。迴路頻寬大約發生在開迴路增益 $|L(j\omega)| = 1$ 處：
   $\omega_{-3dB} \approx K_{pd,eff} \cdot R_p \cdot K_{VCO}$
3. **代入推導結果**：
   將 $K_{pd,eff}$ 代入，得到筆記右上方的核心公式：
   $\omega_{-3dB} = \frac{2 I_p R_p K_{VCO}}{\pi \phi_{in,p}}$
   這公式完美解釋了筆記中表格的物理現象：
   - $\omega_{-3dB} \propto \frac{1}{\phi_{in,p}}$：輸入 Jitter ($\phi_{in}$) 變大時，頻寬 ($f_{-3dB}$) 下降。
   - $\omega_{-3dB} \propto R_p$：電阻 $R_p$ 變大時，頻寬上升。

### 單位解析
**公式單位消去：**
- $I_p$ (Charge Pump 電流): `[A]`
- $R_p$ (Loop Filter 電阻): `[Ω]` = `[V/A]`
- $K_{VCO}$ (VCO 轉換增益): `[Hz/V]`
- $\phi_{in,p}$ (輸入抖動振幅): `[rad]` (在數學分析中視為無因次的弧度，工程上常寫為 UI)
- $\omega_{-3dB} = \frac{[A] \times [V/A] \times [Hz/V]}{[rad]} = \frac{[Hz]}{[rad]} \Rightarrow \mathbf{[Hz]}$ 

**圖表單位推斷：**
📈 **JTRAN 頻率響應圖 (中段共三張)**
- **X 軸**：Jitter Frequency (抖動頻率) `[Hz]`，典型範圍 $10^4 \sim 10^7$ Hz (對數尺度)。
- **Y 軸**：Jitter Transfer (JTRAN) `[dB]`，典型範圍 -40 dB ~ 0 dB。展示 CDR 追蹤 Jitter 的能力，低頻為 0dB (完全追蹤)，過頻寬後以 -20dB/dec 衰減。

📈 **Half-Rate 取樣時序波形圖 (下段)**
- **X 軸**：時間 `[UI]` 或 `[ps]`，典型範圍數個 UI (例如 10Gbps 下 1 UI = 100 ps)。
- **Y 軸**：電壓 `[V]`，典型範圍 0 ~ VDD (數位邏輯準位)。

### 白話物理意義
Bang-Bang CDR 是一個「遇強則弱」的系統：輸入訊號越晃（Jitter越大），它為了避免反應過度，等效頻寬反而會變窄；而 Half-Rate 架構就是「請兩個工人輪班」，用兩個相差 90 度的半速時鐘來消化超高速的資料。

### 生活化比喻
- **BB-CDR 的頻寬特性**：想像你在開車（CDR），如果路面很平坦（Jitter很小），你可以很靈敏地微調方向盤（頻寬大）；但如果路面非常顛簸（Jitter很大），你怕方向盤打太猛會翻車，反而會遲鈍一點、慢慢修正（頻寬變窄）。
- **Half-Rate 架構**：工廠輸送帶跑太快（10 Gbps），一個檢驗員（Full-rate Clock）根本來不及看。於是老闆請了兩個檢驗員（Half-rate I/Q Clocks），一個專門看奇數號產品，一個看偶數號產品，大家動作放慢一半，但整條產線的處理速度依然維持 10 Gbps。

### 面試必考點
1. **問題：為什麼 Bang-Bang CDR 的 Jitter Transfer Bandwidth 不是固定的？**
   → **答案**：因為 BBPD 是高度非線性元件，其等效增益 ($K_{pd,eff}$) 與輸入 Jitter 大小成反比。Jitter 越大，等效增益越小，導致整體迴路頻寬 ($\omega_{-3dB}$) 下降。
2. **問題：在 Half-Rate Alexander PD 中，判斷時鐘 Early 或 Late 的邏輯原理是什麼？（⚠️ 助教嚴厲提醒：小心筆記陷阱！）**
   → **答案**：以波形圖中的 A1(資料中心), A2(資料邊緣), A3(下筆資料中心) 為例。若資料有轉態 (A1 $\neq$ A3)：
   當 `A1 == A2`，代表邊緣取樣時鐘 (CkQ) 落在轉態「之後」，這意味著時鐘太晚 (**Late**)；
   當 `A2 == A3`，代表邊緣取樣落在轉態「之前」，意味著時鐘太早 (**Early**)。
   *(註：筆記表格寫 `X=1, Y=0 -> Ck early`，這高度取決於電路中 XOR 的接法與延遲對齊邏輯。面試時**絕對不要死背表格**，必須當場畫出 A1, A2, A3 波形並推導給面試官看！)*
3. **問題：為了降低時鐘頻率而使用 Half-Rate 或 Quarter-Rate 架構，會帶來什麼設計挑戰？**
   → **答案**：如筆記紅字所述，多相位時鐘的準確度變得極為致命（"Ck Duty cycle I/Q 90° matter"）。任何 I/Q 相位誤差 (Phase Mismatch) 或 Duty Cycle Distortion (DCD) 都會直接吃掉時序裕度 (Timing Margin)，且硬體面積與佈線複雜度會大幅增加。

**記憶口訣：**
BB頻寬看輸入，抖越大就越遲鈍（$\omega \propto 1/\phi$）；
半速分工降頻率，邊緣資料辨早晚。
