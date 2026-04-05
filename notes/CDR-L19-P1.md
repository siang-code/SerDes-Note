# CDR-L19-P1

> 分析日期：2026-04-05
> 原始圖片：images/done/CDR-L19-P1.jpg

---


---
## Injection-Locked CDR (注入鎖定時脈與資料回復電路)

### 數學推導
本電路主要由三大區塊組成：邊緣偵測器 (Edge Detector)、注入鎖定振盪器 (Injection-Locked Oscillator, ILO) 與參考迴路 (Reference PLL)。

**1. 邊緣偵測器 (Edge Detector) 推導：**
*   **目的**：將非歸零 (NRZ) 資料 `Din` 轉換成包含時脈頻率成分的脈衝訊號。
*   **延遲設定**：圖中設定延遲時間為半個位元週期： $\Delta T = \frac{T_b}{2}$
*   **邏輯運算**：使用 XOR 閘，其輸入為原始資料 $D_{in}(t)$ 與延遲後的資料 $D_{in}(t - \Delta T)$。
    $V_{inject}(t) = D_{in}(t) \oplus D_{in}(t - \frac{T_b}{2})$
*   **動態行為**：當 $D_{in}(t)$ 發生轉態 (例如 $0 \rightarrow 1$) 時，$D_{in}(t)$ 變為 1，但 $D_{in}(t - \frac{T_b}{2})$ 在接下來的 $\frac{T_b}{2}$ 時間內仍維持 0。此時 XOR 輸出為 1。過了 $\frac{T_b}{2}$ 後，兩個輸入皆為 1，XOR 輸出降為 0。
*   **結論**：資料的每一次轉態，都會產生一個脈波寬度為 $\frac{T_b}{2}$ 的正脈衝。這些脈衝含有豐富的資料率 (Data Rate) 頻率成分，將作為注入訊號。

**2. 參考 PLL (Reference PLL) 與壓控振盪器 (VCO) 推導：**
*   **目的**：提供振盪器一個準確的「自然共振頻率」(Free-running frequency)，使其接近資料率，以確保注入鎖定能成功發生。
*   **控制電壓**：Reference PLL 接收乾淨的參考時脈 $ck_{ref}$，鎖定後產生控制電壓 $V_{ctrl}$。
*   **電壓隨耦器 (Voltage Follower)**：$V_{ctrl}$ 經過一個單位增益緩衝器 (OP Amp 接成負回授)，用來隔離 Reference PLL 與主要的振盪器，避免高頻注入訊號干擾 PLL 迴路。
*   **頻率關係**：圖中紅字標示 $V_{co1} = V_{co2} = V_{co3}$ (此處應指各級延遲單元的控制電壓相同，或指代這是一個由相同級組成的振盪器)。在未注入資料脈衝時，其振盪頻率為：
    $\omega_{osc\_free} = \omega_{ref\_pll} = K_{vco} \cdot V_{ctrl}$

**3. 注入鎖定 (Injection Locking) 原理：**
*   當邊緣偵測器產生的脈衝注入到振盪器節點時，若 $\omega_{osc\_free}$ 與資料率 $\omega_{data}$ 夠接近（落在鎖定範圍 Lock Range 內），脈衝的能量會強制「重置」或「微調」振盪器的相位。
*   最終穩態時，振盪器輸出的時脈 $Clk_{out}$ 的相位會對齊輸入資料 $D_{in}$ 的轉態邊緣，達到時脈回復 (Clock Recovery) 的目的。接著用此 $Clk_{out}$ 觸發 DFF 重新取樣 $D_{in}$，得到乾淨的 $D_{out}$ (Data Recovery)。

### 單位解析
**公式單位消去：**
1.  **延遲時間 $\Delta T$**：
    $\Delta T = \frac{T_b}{2} = \frac{1}{2 \cdot R_b}$
    *   $T_b$ (Bit Period): $[s]$ (秒)
    *   $R_b$ (Data Rate): $[bps]$ (每秒位元數) 或 $[Hz]$
    *   單位消去：$[s] = \frac{1}{[1/s]} = [s]$
2.  **VCO 自由振盪頻率 $\omega_{osc\_free}$**：
    $\omega_{osc\_free} = 2\pi \cdot K_{vco} \cdot V_{ctrl}$
    *   $K_{vco}$ (VCO 增益): $[Hz/V]$
    *   $V_{ctrl}$ (控制電壓): $[V]$
    *   單位消去：$[rad/s] = [rad] \cdot [Hz/V] \cdot [V] = [rad] \cdot [1/s] = [rad/s]$ (注意：工程上常混用 Hz 與 rad/s，若以 $f$ 表示則為 $[Hz]$)

**圖表單位推斷：**
*   本頁為電路方塊圖，圖中繪製了數位與類比的波形示意圖 (在 XOR 閘之前後)。
    📈 **波形圖單位推斷**：
    *   **X 軸 (水平)**：時間 (Time) $[ps]$ 或 $[ns]$。對於 Gbps 等級的 SerDes，典型範圍約為數百 picoseconds (例如 10Gbps 下，1 UI = 100ps)。
    *   **Y 軸 (垂直)**：電壓 (Voltage) $[V]$。典型範圍在先進製程中約為 $0 \sim 0.9V$ 或 $0 \sim 1.2V$ (取決於 VDD)。

### 白話物理意義
利用資料轉態產生的短脈衝，像鞭子一樣「抽打」振盪器，強迫它的節奏跟著資料走；同時旁邊有一個參考 PLL 像節拍器一樣給予基本盤速度，防止資料很久沒變化時振盪器頻率跑掉。

### 生活化比喻
這就像是在推鞦韆（振盪器）。Reference PLL 是鞦韆本身的長度與重量，決定了它自然擺動的大致頻率。輸入資料就像是你站在旁邊推鞦韆。你只有在資料有變化（Edge）時才會推一把（注入脈衝）。只要你推的頻率（資料率）跟鞦韆原本的頻率差不多，鞦韆最後就會完全配合你推的節奏擺動（注入鎖定）。如果很久沒有資料進來（CID，連續相同位元），你就沒推鞦韆，但因為 Reference PLL 的存在，鞦韆還是會以非常接近原本速度的頻率繼續擺動，不會馬上停下來或亂晃。

### 面試必考點
1.  **問題：為什麼 Injection-Locked CDR 需要一個 Reference PLL？不能直接注入嗎？**
    *   **答案：** 為了提供足夠準確的初始頻率。注入鎖定 (Injection Locking) 的鎖定範圍 (Lock Range) 通常很窄。如果沒有 Reference PLL 將 VCO 的自然振盪頻率拉到接近資料率，單靠微弱的注入脈衝可能無法把頻率「拉」過去，導致無法鎖定。此外，當輸入資料出現長連續相同位元 (CID) 沒有轉態時，缺少注入訊號，VCO 會漂移回自然頻率，Reference PLL 能保證這時的頻率依然精準，避免時脈跑掉導致取樣錯誤。
2.  **問題：圖中 Edge Detector 的 Delay $\Delta T$ 為什麼要設定為 $T_b/2$？如果大於或小於會有什麼影響？**
    *   **答案：** 設定為 $T_b/2$ (半個 UI) 可以產生最大能量且對稱的注入脈衝，這對於鎖定效能最佳。如果 $\Delta T$ 太小，產生的脈衝過窄，注入能量不足，可能導致鎖定範圍變小或無法鎖定；如果 $\Delta T$ 接近 $T_b$，則會變成類似一個反相延遲器，無法有效標示資料邊緣，失去邊緣偵測的意義。
3.  **問題：Injection-Locked CDR 與傳統的 Phase-Locked Loop (PLL) based CDR 相比，最大的優缺點是什麼？**
    *   **答案：**
        *   **優點**：鎖定速度極快 (Fast Lock-in)，幾乎是瞬時的，因為是直接在相位上作修正，非常適合 Burst-mode 傳輸 (如 PON 網路)。架構相對簡單。
        *   **缺點**：Jitter Filtering 能力差。因為輸入的資料 Jitter 會透過注入脈衝直接轉移到 VCO 的輸出時脈上，甚至可能產生 Jitter Peaking。傳統 PLL-CDR 則可以透過 Loop Filter 濾除高頻 Jitter。

**記憶口訣：**
**「邊緣生脈衝，注入鎖相位；參考定頻基，不怕沒資料。」** (Edge -> Pulse -> Inject -> Lock; Ref PLL -> Base Freq -> Tolerate CID)
