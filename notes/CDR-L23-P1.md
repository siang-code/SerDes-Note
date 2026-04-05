# CDR-L23-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L23-P1.jpg

---


---
## Pottbacker 頻率偵測器 (Pottbacker Frequency Detector)

### 數學推導
Pottbacker 是一種無參考時脈 (Reference-less) 的頻率偵測器，核心思想是利用資料邊緣 (Data edge) 對正交時脈 (Quadrature clocks) 進行取樣，藉由觀察「差頻 (Beat Frequency)」的相位旋轉方向來判斷快慢。

1. **定義輸入時脈與資料**：
   設正交時脈為：
   $ck_I(t) = \text{sgn}(\cos(2\pi f_{ck} t))$
   $ck_Q(t) = \text{sgn}(\sin(2\pi f_{ck} t))$
   其中 $ck_I$ 相位領先 $ck_Q$ 90度。

2. **資料取樣 (Sampling)**：
   利用 Data (發生在 $t = k T_{data}$) 的邊緣去觸發 D-Flip-Flop，取樣這兩個時脈，得到：
   $Q_1[k] = ck_I(k T_{data}) = \text{sgn}(\cos(2\pi f_{ck} \cdot k T_{data}))$
   $Q_2[k] = ck_Q(k T_{data}) = \text{sgn}(\sin(2\pi f_{ck} \cdot k T_{data}))$

3. **差頻轉換 (Beat Frequency)**：
   代入 $T_{data} = 1/f_{data}$，觀察取樣後的等效相位：
   $\phi_k = 2\pi f_{ck} \frac{k}{f_{data}} = 2\pi \frac{f_{data} + \Delta f}{f_{data}} k = 2\pi k + 2\pi \frac{\Delta f}{f_{data}} k$
   扣除 $2\pi k$ 的整數圈後，等效相位隨時間的變化為：
   $\phi_{eq}[k] = 2\pi \Delta f \cdot (k T_{data}) = 2\pi \Delta f \cdot t$
   這表示取樣後的訊號 $Q_1, Q_2$ 是一組以差頻 $\Delta f$ 運作的低頻正交訊號！

4. **判斷頻率快慢 (Polarity of $\Delta f$)**：
   - **當 $f_{ck} > f_{data}$ ($\Delta f > 0$)**：
     $\phi_{eq}$ 隨時間增加，$(Q_1, Q_2)$ 的狀態軌跡為**順時針**旋轉：`(1,0) -> (1,1) -> (0,1) -> (0,0)`。此時 $Q_1$ 波形領先 $Q_2$。利用 $Q_2$ 的上升緣去取樣 $Q_1$，會得到 **$Q_3 = 1$**。
   - **當 $f_{ck} < f_{data}$ ($\Delta f < 0$)**：
     $\phi_{eq}$ 隨時間減少，狀態軌跡為**逆時針**旋轉：`(1,0) -> (0,0) -> (0,1) -> (1,1)`。此時 $Q_2$ 波形領先 $Q_1$。利用 $Q_2$ 的上升緣去取樣 $Q_1$，會得到 **$Q_3 = 0$**。

5. **自動關閉機制 (Automatic Shut-off)**：
   當 CDR 鎖定時 ($f_{ck} = f_{data}$)，$\Delta f = 0$，等效相位停止變化，$Q_1, Q_2$ 會變成不跳動的直流 (DC) 值。只要設計讓 PD (Phase Detector) 鎖定時的相位剛好使 $Q_2$ 停在「Disable CP」的準位（例如圖中的 CP off 狀態），FD 就會在鎖定瞬間自動休眠，避免干擾 PD 的精細追蹤。若失去鎖定，$Q_2$ 開始跳動，FD 即自動甦醒。

### 單位解析
**公式單位消去：**
- 差頻 (Beat Frequency): $f_{beat} [\text{Hz}] = |f_{ck} [\text{Hz}] - f_{data} [\text{Hz}]| = [\text{Hz}] - [\text{Hz}] = [\text{Hz}]$
- 取樣相位累積: $\Delta \phi [\text{rad}] = 2\pi \left[\frac{\text{rad}}{\text{cycle}}\right] \times \Delta f \left[\frac{\text{cycle}}{\text{s}}\right] \times \Delta t [\text{s}] = \left[\frac{\text{rad}}{\text{cycle}}\right] \times [\text{Hz}] \times [\text{s}] = [\text{rad}]$

**圖表單位推斷：**
📈 **時序圖 (Timing Diagrams，左右兩側)**：
- X 軸：時間 $t$ [ps] 或 [UI] (Unit Interval)，典型範圍為數十到數百個 UI（因為 Beat freq. 週期遠大於 Data rate 週期）。
- Y 軸：電壓 [V]，典型範圍為 CMOS 邏輯準位 0V ~ 1.2V，代表邏輯狀態 0 與 1。

📈 **狀態旋轉圖 (State Diagram，中下圓餅圖)**：
- X 軸：$Q_1$ 邏輯狀態，無單位 (Dimensionless)，值為 0 或 1。
- Y 軸：$Q_2$ 邏輯狀態，無單位 (Dimensionless)，值為 0 或 1。

### 白話物理意義
Pottbacker FD 就是利用「資料」當作閃光燈，去照相觀察兩個「相差 90 度的時脈」；如果時脈跑得比資料快，照片裡時脈的相位就會像時鐘指針一樣順時針轉，反之則逆時針轉，藉此判斷並修正頻率的快慢。

### 生活化比喻
想像操場上有兩個跑者 I 和 Q，Q 永遠落後 I 四分之一圈。你閉著眼睛，每當聽到代表「資料」的節拍器響起，你就睜開眼睛拍一張照。
如果他們跑得比節拍器快，你會發現連續幾張照片中，他們的位置不斷「順時針」往前推進。
如果他們跑得比節拍器慢，在照片中他們看起來就像在「倒退嚕」（逆時針轉）。
Pottbacker 電路就是透過這連續的照片，判斷他們是順轉還是逆轉，立刻就知道該叫他們加速還是減速。最棒的是，當他們速度和節拍器完美同步時，照片裡的人就會定格，這時 FD 裁判就可以自動下班去喝茶（Automatic shut-off）了！

### 面試必考點
1. **問題：請解釋 Pottbacker Frequency Detector 的基本工作原理？**
   → **答案**：它是一種 Reference-less FD。利用 Data edge 取樣 Quadrature Clocks (I/Q)，產生低頻的 Beat frequency 訊號 $Q_1, Q_2$。藉由 D-FF 判斷 $Q_1, Q_2$ 的領先/落後關係（即狀態圓的旋轉方向），就能得知時脈頻率是太快還是太慢，進而輸出 $Q_3$ 驅動 Charge Pump。
2. **問題：為什麼 Pottbacker FD 號稱可以達到 "Automatic shut off"？這有什麼好處？**
   → **答案**：當頻率與相位鎖定時，Data edge 會穩定對齊 Clock 的特定相位，$Q_1$ 和 $Q_2$ 停止跳動並變成直流 (DC) 訊號。如果讓鎖定時的 $Q_2$ 狀態剛好對應到 Charge Pump 的 Disable 控制端，FD 就會自動關閉。好處是能避免 FD 產生多餘的 jitter 注入 Loop filter，讓 PD (Phase Detector) 能不受干擾地接手精細的相位追蹤。
3. **問題：如果把 Pottbacker FD 的輸入 Quadrature Clocks 換成單相 (Single-phase) Clock，還能正常運作嗎？**
   → **答案**：不能。單相時脈被取樣後只能產生單一的差頻訊號，我們可以看出頻率不一樣（波形會上下跳動），但無法判斷「方向」（無法得知是太快還是太慢）。必須要有 I/Q 兩個正交訊號，才能在二維平面上建立順時針或逆時針的旋轉方向性，藉此判別頻率誤差 $\Delta f$ 的正負極性。

**記憶口訣：**
拍照取樣 IQ 圈，順快逆慢看領先，鎖定定格就休眠。
