# LA-L8-P1

> 分析日期：2026-04-06
> 原始圖片：images/done/LA-L8-P1.jpg

---


---
## 高速有線收發器的訊號完整性與錯誤率分析 (Signal Integrity & BER in High-Speed Wireline TRX)

### 數學推導
1.  **差動訊號擺幅 (Differential Signal Swing):**
    從左側的差動對電路圖 (Differential Pair) 可知，單端輸出擺幅為 $V_o = I_{SS} \cdot R$。
    差動峰對峰值擺幅 (Peak-to-Peak Differential Swing) 為單端擺幅的兩倍：$V_{PP} = 2V_o$。
2.  **常態分佈機率密度函數 (Normal Distribution PDF):**
    假設系統中的隨機雜訊 (Random Noise) 呈現常態分佈，其 PDF 公式為：
    $$P_n = \frac{1}{\Delta n \sqrt{2\pi}} \exp\left(\frac{-n^2}{2\Delta n^2}\right)$$
    其中 $\Delta n$ 為雜訊的均方根 (RMS) 值，也就是標準差 $\sigma$。
3.  **位元錯誤率 (Bit Error Rate, BER) 推導:**
    考慮傳送邏輯 '0' 的情況，無雜訊時接收端的理想電壓為 $-V_o$。若加上雜訊後，總電壓大於判定門檻 (0V)，接收端就會誤判為 '1'，這就是發生錯誤的機率 $P_{0 \to 1}$。
    假設傳送 '0' 的先驗機率為 $\frac{1}{2}$（即 0 與 1 出現機率相同）：
    $$P_{0 \to 1} = \frac{1}{2} \int_{0}^{\infty} \frac{1}{\Delta n \sqrt{2\pi}} \exp\left(-\frac{(u - (-V_o))^2}{2\Delta n^2}\right) du$$
    $$P_{0 \to 1} = \frac{1}{2} \int_{0}^{\infty} \frac{1}{\Delta n \sqrt{2\pi}} \exp\left(-\frac{(u + V_o)^2}{2\Delta n^2}\right) du$$
    進行變數變換，令 $z = \frac{u + V_o}{\Delta n}$，則微分項 $dz = \frac{du}{\Delta n}$。
    積分下限：當 $u = 0$ 時，$z = \frac{V_o}{\Delta n}$。積分上限：當 $u \to \infty$ 時，$z \to \infty$。
    代入上式並將 $\Delta n$ 移出積分外消去，得到：
    $$\text{Error Probability for '0'} = \int_{\frac{V_o}{\Delta n}}^{\infty} \frac{1}{\sqrt{2\pi}} \exp\left(-\frac{z^2}{2}\right) dz$$
    定義著名的 $Q$-function 為 $Q(x) \triangleq \int_{x}^{\infty} \frac{1}{\sqrt{2\pi}} \exp\left(-\frac{z^2}{2}\right) dz$。
    由於系統的對稱性，傳送 '1' 發生錯誤的機率 $P_{1 \to 0}$ 等於傳送 '0' 發生錯誤的機率。
    因此總錯誤率 (BER) 為：
    $$BER = P_{0 \to 1} + P_{1 \to 0} = \frac{1}{2} Q\left(\frac{V_o}{\Delta n}\right) + \frac{1}{2} Q\left(\frac{V_o}{\Delta n}\right) = Q\left(\frac{V_o}{\Delta n}\right)$$
    將 $V_o = \frac{V_{PP}}{2}$ 代入，得 $BER = Q\left(\frac{V_{PP}}{2\Delta n}\right)$。
4.  **SNR 與訊號擺幅限制 (SNR & Signal Swing Restrictions):**
    在高速 SerDes 通訊標準中，經常要求非常嚴苛的位元錯誤率，如 $BER < 10^{-12}$。
    由查表（或筆記上的 $Q(x)$ 關係圖）可知，要達到這個錯誤率，SNR 值 $\eta$ 必須大約為 7：
    $$Q(\eta) = 10^{-12} \Rightarrow \eta \approx 7$$
    因此，我們對差動訊號的擺幅要求為：
    $$\frac{V_o}{\Delta n} = 7 \Rightarrow \frac{V_{PP}}{2\Delta n} = 7 \Rightarrow V_{PP} > 14 \Delta n$$
    這個公式告訴我們，為了在隨機雜訊下維持通訊品質，差動 Peak-to-Peak 擺幅至少要是雜訊均方根值的 14 倍。
    然而，我們**無法無限制地增大訊號擺幅**來提升 SNR，因為會面臨以下問題：
    - **問題一 (頻寬瓶頸)：** 若想單純增大電阻 $R$ 來提升 $V_o$，會增加 RC 時間常數 (Time Constant)，導致節點的頻寬變小，高速訊號會被嚴重衰減。
    - **問題二 (功耗與雜訊)：** 若 $R$ 不能太大，就只能開大尾電流 $I_{SS}$。但 $I_{SS}$ 變大，不僅功耗上升，電晶體本身產生的熱雜訊 (Thermal Noise) 也會跟著變大，陷入惡性循環。
    - **問題三 (電壓餘裕)：** 隨著先進製程演進 (28nm $\to$ 0.9V, 22nm $\to$ 0.8V)，電源電壓 (Supply Voltage) 越來越低，能給予電晶體維持飽和區 (Saturation Region) 的 Headroom 空間不足，訊號擺幅無法再像過去 Bipolar 電路那樣大，且 CMOS 電路通常需要 $3\times \sim 4\times$ 更大的擺幅才能順利完成開關切換 (Switching)。

### 單位解析
**公式單位消去：**
- **單端擺幅 $V_o$** = $I_{SS} \times R = [\text{A}] \times [\Omega] = [\text{V}]$
- **Q-function 自變數 $z$** = $\frac{v + V_o}{\Delta n} = \frac{[\text{V}] + [\text{V}]}{[\text{V}]} = [\text{無因次 (Dimensionless)}]$。Q-function 評估的是電壓超過了幾個「標準差 $\sigma$」，因此沒有單位。
- **誤差率 $BER$** = $Q(7) = [\text{無因次 (Probability)}]$，代表發生錯誤的機率，介於 0 到 1 之間。

**圖表單位推斷：**
- 📈 **雙峰常態分佈圖 (PDF)：**
  - X 軸：電壓 $v$ $[\text{V}]$，典型範圍 $\pm 500\text{ mV}$ (對應單端擺幅 $V_o$)
  - Y 軸：機率密度函數 PDF $[\text{V}^{-1}]$
- 📈 **Q-function 關係圖：**
  - X 軸：訊號雜訊比 $\eta$ (即 $\frac{V_o}{\Delta n}$) $[\text{無單位}]$，典型範圍 0 ~ 10
  - Y 軸：誤碼率 BER $Q(x)$ $[\text{無單位}, \text{對數尺度 (Log scale)}]$，典型範圍 $10^0$ ~ $10^{-15}$

### 白話物理意義
在充滿雜訊的高速傳輸中，訊號的擺幅就像你講話的音量，雜訊就像背景噪音；你的音量如果沒有比噪音大至少 7 倍（單端）或 14 倍（雙端），接收端就會把 '0' 聽成 '1' 導致致命錯誤，而且這種被隨機雜訊吃掉的錯誤，是無法靠等化器 (EQ) 救回來的。

### 生活化比喻
想像你在一個非常吵雜的夜市（隨機雜訊 Noise $\Delta n$）裡跟遠處的朋友點餐，你比手語 '0' (拳頭, $-V_o$) 或 '1' (食指, $+V_o$)。如果夜市的燈光閃爍不定（雜訊擾動造成 PDF 分佈），你的手勢變化必須拉得夠大（$V_{PP} > 14\Delta n$），朋友才不會看走眼。如果你試圖把手伸得更長（增加擺幅），不僅會抽筋（頻寬下降），還會打到旁邊的人（Headroom 不夠），一旦朋友看錯（產生 Error），就算他事後再怎麼努力回想，也補救不回來了。

### 面試必考點
1. **問題：在高速 SerDes 中，若要求 $BER < 10^{-12}$，訊號的 Peak-to-Peak 擺幅 $V_{PP}$ 至少要是 rms noise ($\Delta n$) 的幾倍？**
   → **答案：** 14 倍。推導過程：$BER = Q(\frac{V_o}{\Delta n}) < 10^{-12} \Rightarrow \frac{V_o}{\Delta n} > 7$。因為 $V_{PP} = 2V_o$，所以 $V_{PP} > 14\Delta n$。
2. **問題：為了對抗雜訊降低 BER，直接無腦把 Tx 端的負載電阻 $R$ 加大來提高訊號擺幅 $V_o$ 有什麼壞處？**
   → **答案：** 有兩個致命壞處。第一，節點的 RC 時間常數 (Time Constant) 增加，導致頻寬 (Bandwidth) 下降，高速訊號會變成 ISI (符元間干擾)。第二，如果為了維持頻寬而改為加大尾電流 $I_{SS}$，不僅功耗上升，電晶體產生的雜訊也會變大；更嚴重的是，在先進製程低 Supply Voltage 的限制下，Headroom 空間會不夠，導致電晶體掉入 Triode region。
3. **問題：為何筆記提到 Error 一旦出現就「補不回來」？接收端不是有 Equalizer (EQ) 可以用嗎？**
   → **答案：** Equalizer 主要的功能是用來補償「確定性」的通道衰減 (Channel Loss) 所造成的 ISI。但筆記中探討的是隨機熱雜訊 (Random Thermal Noise)，它是不可預測的。一旦 Random Noise 瞬間的振幅大到越過判定門檻 (0V) 造成誤判，這個物理層的資訊就永遠遺失了，EQ 救不回來，只能靠更高層的 FEC (Forward Error Correction) 演算法來修正。

**記憶口訣：**
「**BER 負十二，單七雙十四；想加大擺幅，頻寬電壓會打架。**」
*(解譯：BER 要 $10^{-12}$，V_o/noise 要 7，Vpp/noise 要 14；R 大掉頻寬，Iss 大吃 Headroom 電壓)*
