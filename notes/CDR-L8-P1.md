# CDR-L8-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L8-P1.jpg

---


---
## Alexander Phase Detector (Bang-Bang PD) 原理與架構

### 數學推導
Alexander Phase Detector (BBPD) 的核心概念是**超取樣 (Oversampling)**，具體來說是「每一個 bit 取樣兩次 (2 samples per bit)」。我們利用三個連續的取樣點 $S_1, S_2, S_3$ 來判斷 Clock 的相位是超前 (Early) 還是落後 (Late)。

1.  **定義取樣點與時間關聯：**
    *   假設目前時間為 $t$，Clock 的週期為 $T_{clk}$（對應一個 bit 的時間，即 Full-rate 架構）。
    *   $S_3$ (Latest)：當前資料中心的取樣點（對應電路中的 $Q_1$）。
    *   $S_2$ (Middle)：資料邊界 (Edge) 的取樣點，比 $S_3$ 早半個週期（對應電路中被 retime 後的 $Q_4$）。
    *   $S_1$ (Earliest)：前一個資料中心的取樣點，比 $S_3$ 早一個週期（對應電路中的 $Q_2$）。
2.  **定義邏輯判斷函數 (XOR)：**
    根據筆記上方的波形圖，我們定義兩個 XOR 閘的輸出：
    *   $X = S_1 \oplus S_2$ （比較前一個資料與邊界）
    *   $Y = S_2 \oplus S_3$ （比較邊界與當前資料）
3.  **情境推導與狀態機 $F(X,Y)$：**
    *   **Case 1: Clock Early (時鐘太早)**
        *   如左上圖，Clock 取樣點整體往左偏移。資料的轉移 (Transition) 發生在 $S_2$ 之後、$S_3$ 之前。
        *   因此，$S_1$ 和 $S_2$ 踩在同一個電位 $\Rightarrow S_1 = S_2 \Rightarrow X = 0$
        *   $S_2$ 和 $S_3$ 踩在不同電位 $\Rightarrow S_2 \neq S_3 \Rightarrow Y = 1$
        *   結果：$F(X,Y) = (0,1) \Rightarrow$ 輸出 **Early** 訊號（指示 VCO 降頻/延遲）。
    *   **Case 2: Clock Late (時鐘太晚)**
        *   如右上圖，Clock 取樣點整體往右偏移。資料的轉移發生在 $S_1$ 之後、$S_2$ 之前。
        *   因此，$S_1$ 和 $S_2$ 踩在不同電位 $\Rightarrow S_1 \neq S_2 \Rightarrow X = 1$
        *   $S_2$ 和 $S_3$ 踩在同一個電位 $\Rightarrow S_2 = S_3 \Rightarrow Y = 0$
        *   結果：$F(X,Y) = (1,0) \Rightarrow$ 輸出 **Late** 訊號（指示 VCO 升頻/提前）。
    *   **Case 3: Long Runs (無資料轉移)**
        *   資料連續為 000 或 111。
        *   $S_1 = S_2 = S_3 \Rightarrow X = 0, Y = 0$
        *   結果：$F(X,Y) = (0,0) \Rightarrow$ 輸出 **Tri-state**。Charge Pump 不充不放，保持當前控制電壓。這解決了隨機資料長時間無轉移時，CDR 頻率會亂飄的問題。

### 單位解析
**公式單位消去：**
Bang-Bang PD 本質是數位邏輯，輸出為布林值。但若將其結合 Charge Pump 來看其等效增益 $K_{pd}$：
*   $I_{out} = I_{cp} \times \text{sgn}(\Delta \phi)$
    *   $\Delta \phi$ [rad] 或 [UI]: 輸入相位差。
    *   $\text{sgn}(\cdot)$ [無單位]: 符號函數 (由 BBPD 邏輯實現，輸出 $\pm 1$ 或 $0$)。
    *   $I_{cp}$ [A]: Charge pump 電流。
    *   $I_{out}$ [A] = [A] $\times$ [無單位] = [A]。
*   **注意：** BBPD 是高度非線性的，其等效增益 $K_{pd} = \frac{\Delta I_{out}}{\Delta \phi}$ 在 $\Delta \phi = 0$ 處趨近於無限大 [A/rad]。

**圖表單位推斷：**
📈 **頂部 Clock Early / Late 波形圖：**
- X 軸：時間 [UI] (Unit Interval) 或 [ps]，典型範圍：顯示約 2~3 UI。
- Y 軸：電壓 [V]，代表數位邏輯準位，典型範圍 0 ~ VDD (例如 0~1.0V)。

📈 **底部電路時序圖 (Timing Diagram)：**
- X 軸：時間 [UI] 或 [ps]，箭頭表示時間流動方向。
- Y 軸：各節點電壓 [V] ($D_{in}, ck, Q_1 \sim Q_4$)，為數位高低電位。可以看出 $Q_2$ 確實比 $Q_1$ 晚了整整 1 個 clock cycle (1 UI)。

### 白話物理意義
利用在資料的「正中央」跟「邊緣」各踩一腳取樣，看邊緣那一腳是踩在資料變化「前」還是變化「後」，就能精準抓出時鐘是太快還是太慢；如果資料沒變化，就乖乖閉嘴不動作 (Tri-state)。

### 生活化比喻
就像你在玩「太鼓達人」。$S_1$ 和 $S_3$ 是音符的中心，$S_2$ 是音符的邊緣。如果你在 $S_2$ 敲下去的時候，發現聲音跟前一個音符 $S_1$ 一樣，代表你敲「太早」了，還沒進入下一個音符的領域；如果你在 $S_2$ 敲下去發現聲音已經變成下一個音符 $S_3$ 了，代表你敲「太晚」了。如果螢幕上根本沒有音符過來（Long runs），你的鼓棒就懸在半空中不要動（Tri-state），才不會破壞 Combo。

### 面試必考點
1. **問題：Alexander PD (Bang-Bang PD) 最大的優點是什麼？**
   - 答案：具有 **Automatic Retiming** 功能，且在資料沒有轉移 (Long runs) 時會自動進入 **Tri-state**，不會產生錯誤的相位誤差訊號，非常適合處理 PRBS 等隨機性資料。
2. **問題：請解釋 Bang-Bang PD 的轉移特性 (Transfer Curve)，它對 CDR 系統有什麼負面影響？**
   - 答案：BBPD 的轉移特性是非線性的符號函數 (Sign function)，只有 $+1, 0, -1$ 三種狀態。這會導致 CDR 系統無法收斂到一個絕對靜止的相位，而是會在理想相位附近產生極限環震盪 (Limit Cycle)，這會貢獻系統的 Jitter Generation (抖動產生)。
3. **問題：在你的筆記電路圖中，為什麼不直接把 $Q_3$ 拿去跟 $Q_1$ 做 XOR，而要多加一個 Flip-flop 產生 $Q_4$？**
   - 答案：為了解決 **Metastability (亞穩態)** 與 **Clock Domain Crossing** 的問題。$Q_3$ 是用 Clock 的下緣 (falling edge) 觸發的，而 $Q_1$ 是上緣 (rising edge)。把它們直接丟進 XOR 會產生毛刺 (glitch)。用另一個上緣觸發的 FF 將 $Q_3$ 重新對齊 (Retime) 產生 $Q_4$，確保所有進入 XOR 判斷邏輯的訊號都在同一個時間基準面上。

**記憶口訣：**
**「三點定江山 ($S_1, S_2, S_3$)，無轉就發呆 (Tri-state)，非線會發抖 (Limit cycle jitter)。」**

---
*(※ 費曼測試準備就緒，若你覺得理解了，請告訴我，我將進行反事實提問！)*
