# EQ-L20-P1

> 分析日期：2026-04-06
> 原始圖片：images/done/EQ-L20-P1.jpg

---


### 數學推導
1. **CML 閂鎖器 (Latch) 的基準與回授強度**：
   筆記左上角提到：「`cross couple pair 力量要比 input pair 強 2x ~ 3x => DFF`」。這確保了正回授（Regeneration）的速度與鎖定能力。在傳統無 DFE 的狀態下，判決門檻為差模 $0\text{V}$。

2. **電流加總式 1-Tap DFE (Current-Summing DFE)**：
   電路圖左側加入了由前一筆資料 $D_{out}$ 驅動的反饋差動對（尾電流為 $\alpha I_{SS}$）。在 Master Latch 的 Tracking Phase ($CK=1$)，負載電阻 $R$ 上同時流過主訊號與反饋訊號的電流：
   $$ \Delta V_{out} = -R \cdot (\Delta I_{in} + \Delta I_{fb}) $$
   其中，主訊號轉導電流 $\Delta I_{in} = g_{m,in} \cdot V_{in}$。反饋差動對被 $D_{out}$ 完全切換，因此 $\Delta I_{fb} = \pm \alpha I_{SS}$ （正負號取決於前一個 bit 是 1 還是 0）。

3. **動態門檻漂移 (Threshold Shifting)**：
   要改變判決結果，必須讓內部節點電壓差 $\Delta V_{out} = 0$（達到翻轉臨界點）。將上述公式代入並令其等於 0：
   $$ g_{m,in} \cdot V_{in, threshold} + (\pm \alpha I_{SS}) = 0 $$
   $$ V_{in, threshold} = \mp \frac{\alpha I_{SS}}{g_{m,in}} $$
   這證明了 DFE 根據前一個 bit 的狀態，將原本 $0\text{V}$ 的判決門檻動態平移了 $\frac{\alpha I_{SS}}{g_{m,in}}$。
   *對應筆記：當 $\alpha = 1/5$ 時，若前一個 bit 為 0（通道有負向 ISI），下一個 bit 只要超過 $-1/5$ 就當作 1；若前一個 bit 為 1（通道有正向 ISI），下一個 bit 跌過 $1/5$ 就當作 0。*

### 單位解析
**公式單位消去：**
- 節點電壓變化：$\Delta V_{out} = -R \cdot (\Delta I_{in} + \Delta I_{fb})$
  $$ [\text{V}] = [\Omega] \times ([\text{A}] + [\text{A}]) $$
- 等效門檻電壓：$V_{in, threshold} = \frac{\alpha I_{SS}}{g_{m,in}}$
  $$ [\text{V}] = \frac{[\text{A}]}{[\text{A/V}]} = [\text{V}] $$

**圖表單位推斷：**
📈 **1-tap DFE Flipping Thresholds (左下眼圖)**
- X 軸：時間 [UI] 或 [ps]，典型範圍 1~2 UI (例如 28Gbps 下約為 35.7ps/UI)
- Y 軸：電壓振幅 [mV]，典型範圍 $\pm 200 \sim 300\text{mV}$。圖中標示的 $V_{TH,H}$ 和 $V_{TH,L}$ 即為門檻偏移量，若全擺幅為 $300\text{mV}$，1/5 的偏移量約為 $\pm 60\text{mV}$。

### 白話物理意義
1-Tap DFE 就是「看前一個人的臉色決定現在的標準」：因為通道有 ISI（前一個 bit 會干擾現在的 bit），所以我們故意把判斷門檻調高或調低來抵消這個干擾，讓訊號能更快、更容易跨越門檻被正確判斷。

### 生活化比喻
就像是「體重計歸零」。如果你知道前一個量體重的人在秤上留下了 1 公斤的泥巴（ISI），你不會傻傻直接量，而是先把體重計的指針（Threshold）往回調 1 公斤（變成負值）。這樣你站上去量出來的，才是你真正的體重，而且指針可以「提早」達到正確的刻度。

### 面試必考點
1. **問題：筆記提到「Cross-coupled pair 力量要比 input pair 強 2x~3x」，為什麼有這個設計準則？**
   → **答案：** 在 Latch 的 Tracking phase 轉換到 Latching phase 的瞬間，交錯耦合對（Cross-coupled pair）負責提供正回授（Regeneration）。為了抵抗輸入對可能殘留的相反電壓，並確保能快速將位準拉開到 Full swing（$V_{DD}$ 與 $V_{DD}-IR$），正回授的驅動力必須足夠大，通常 size 甚至轉導 $g_m$ 會設計為輸入對的 2 到 3 倍。
2. **問題：1-Tap DFE 為什麼能提升操作速度（如筆記所述 BW 頻寬提升 ~20%）？**
   → **答案：** 因為動態調整了判決門檻（Threshold shifting），使得受 ISI 衰減且爬升緩慢的訊號，能「提早」碰到新的、較低的門檻，進而提早觸發 Latch 內部的正回授機制，省下了等待訊號爬升的時間，等效上提升了 Latch 的操作速度與頻寬。
3. **問題：這個直接反饋 (Direct Feedback) 架構最大的 Timing 瓶頸（Critical Path）在哪裡？**
   → **答案：** 在於 DFF 的 Clock-to-Q 延遲 加上 訊號拉回前端 DFE 電流源的 RC 延遲。這整個「判決 $\to$ 輸出 $\to$ 反饋穩定改變下一個門檻」的迴路，必須嚴格在 1 UI（一個 bit 時間）內完成，這在極高速（如 56Gbps PAM4）下非常困難，通常需要改用 Loop-Unrolled DFE 架構來避開這個瓶頸。

**記憶口訣：**
**「前一 bit 留殘影，DFE 門檻動態移；電流相加抵干擾，提早翻轉速無敵！」**
