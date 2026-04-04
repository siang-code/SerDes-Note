# PLL-L40-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L40-P1.jpg

---


---
## [PLL-L40-P1] 頻率除頻器對 Phase Noise 與 Jitter 的影響

### 數學推導
本頁筆記的核心在證明：**理想的除頻器 (Divider) 會降低 Phase Noise，但不會改變絕對時間域的 RMS Jitter。**

**Part 1: 除頻器對 Phase Noise ($\mathcal{L}(f)$) 的影響**
1. 根據 Leeson's Equation 的簡化形式，振盪器的相位雜訊頻譜密度可表示為：
   $S_{\phi}(\Delta f) = \frac{k_0}{4Q^2} \cdot \frac{f_c^2}{\Delta f^2}$
   (其中 $f_c$ 為載波頻率，$\Delta f$ 為 offset frequency，在此筆記中混用 $\omega$ 與 $f$，物理意義相同)
2. 假設一訊號 $ck1$ 經過 $\div 2$ 除頻器輸出為 $ck2$，且除頻器本身不貢獻雜訊 (Assuming same Q, $\div 2$ contributes no noise)。
   對於 $ck1$：$S_1 = \frac{k_0}{4Q^2} \cdot \frac{f_{c1}^2}{\Delta f^2}$
   對於 $ck2$：其載波頻率變成 $f_{c2} = \frac{f_{c1}}{2}$，代入公式得：
   $S_2 = \frac{k_0}{4Q^2} \cdot \frac{(f_{c1}/2)^2}{\Delta f^2} = \frac{1}{4} \left( \frac{k_0}{4Q^2} \cdot \frac{f_{c1}^2}{\Delta f^2} \right) = \frac{1}{4} S_1$
3. 將其轉換為分貝 (dB) 表示：
   $\Delta \mathcal{L} = 10 \log_{10}\left(\frac{S_2}{S_1}\right) = 10 \log_{10}\left(\frac{1}{4}\right) = -6 \text{ dB}$
   **結論：除以 $N$ 的除頻器會讓 Phase Noise 頻譜整體下降 $20 \log_{10}(N)$ dB。**

**Part 2: 除頻器對 RMS Jitter ($J_{rms}$) 的影響**
1. 角度域的 RMS Jitter 平方 ($J_{rms}^2 [\text{rad}^2]$) 為相位雜訊頻譜的積分：
   $J_{rms}^2 [\text{rad}^2] = \int_{0}^{\infty} S_{\phi}(f) df$
2. 要將角度誤差轉換為時間誤差（秒），需利用角頻率 $\omega_c = 2\pi f_c$ 進行換算：
   $J_{rms} [\text{sec}] = \frac{J_{rms} [\text{rad}]}{2\pi f_c}$
   故 $J_{rms}^2 [\text{sec}^2] = \left(\frac{1}{2\pi f_c}\right)^2 \int_{0}^{\infty} S_{\phi}(f) df$
3. 分別計算 $ck1$ 與 $ck2$ 的時間域 Jitter：
   - $J_{rms, ck1}^2 = \left(\frac{1}{2\pi f_{c1}}\right)^2 \int S_1 df$
   - $J_{rms, ck2}^2 = \left(\frac{1}{2\pi (f_{c1}/2)}\right)^2 \int S_2 df = \left(\frac{2}{2\pi f_{c1}}\right)^2 \int \frac{1}{4} S_1 df$
4. 將 $ck2$ 的常數項提出：
   $J_{rms, ck2}^2 = 4 \cdot \left(\frac{1}{2\pi f_{c1}}\right)^2 \cdot \frac{1}{4} \int S_1 df = \left(\frac{1}{2\pi f_{c1}}\right)^2 \int S_1 df = J_{rms, ck1}^2$
   **結論：在忽略除頻器自身雜訊的前提下，$J_{rms, ck1} [\text{sec}] = J_{rms, ck2} [\text{sec}]$，時間域的抖動保持完全不變。**

### 單位解析
**公式單位消去：**
1. **$J_{rms} [\text{sec}]$ 的換算：**
   $J_{rms} [\text{sec}] = \frac{J_{rms} [\text{rad}]}{\omega_c [\text{rad/sec}]}$
   單位消去：$[\text{rad}] \div \left[\frac{\text{rad}}{\text{sec}}\right] = [\text{sec}]$
   （這也就是筆記中標註「除以整個週期，即為秒 $\rightarrow$ 乘以 $2\pi$ 換成角度 rad」的數學意義：$\frac{t}{T} \cdot 2\pi = \phi$）
2. **Phase Noise 積分：**
   $J_{rms}^2 [\text{rad}^2] = \int S_{\phi}(f) df \Rightarrow \left[\frac{\text{rad}^2}{\text{Hz}}\right] \times [\text{Hz}] = [\text{rad}^2]$

**圖表單位推斷：**
📈 **左側頻譜圖（Phase noise plot）：**
- **X 軸：** Offset frequency $\Delta f$ 或 $\omega$ $[\text{Hz}$ 或 $\text{rad/s}]$ (對數尺度 Log scale)，典型範圍 $10\text{kHz} \sim 100\text{MHz}$
- **Y 軸：** Phase Noise $\mathcal{L}(f)$ $[\text{dBc/Hz}]$，典型範圍 $-80 \sim -150 \text{ dBc/Hz}$
- **圖形意義：** $ck1$ 的曲線整體比 $ck2$ 高出 $6\text{dB}$。

📈 **右側時域波形圖（Jitter in Time Domain）：**
- **X 軸：** 時間 Time $[\text{ps}]$ 或 $[\text{ns}]$
- **Y 軸：** 電壓 Amplitude $[\text{V}]$，典型範圍 $0 \sim 1\text{V}$ (VDD)
- **波形邊緣的模糊帶 (Jitter)：** $\Delta t = J_{rms}$ $[\text{ps}]$，這代表過零點 (Zero-crossing) 的時間變異量。上下兩個波形（$ck1$ 與 $ck2$）在轉態時的模糊寬度（以秒為單位）是相同的。

### 白話物理意義
除頻器雖然讓「每個時脈週期內的相位誤差角度」等比例變小了（所以 Phase Noise 曲線下降），但因為除頻後的「單一週期時間長度」也等比例變長了，一除一乘互相抵消，導致時脈在絕對時間軸上的抖動（秒數）根本沒有改變。

### 生活化比喻
想像你在開車畫圓形賽道。
- **高頻 (ck1)**：你 1 分鐘開一圈，手不穩導致你偏離終點線的誤差是 **「偏離圓心 10 度」**。換算成賽道上的距離，大約是 **5 公尺**。
- **除頻 (ck2)**：現在規定你放慢速度，2 分鐘才開一圈（$\div 2$）。因為開得慢，你控制方向盤更穩了，角度誤差縮小成 **「偏離圓心 5 度」**（這就是 Phase Noise 下降 6dB）。
- **結果**：但是！因為你現在花 2 分鐘開一圈，代表你單圈行駛的總路徑變長了，把這 5 度的誤差換算回賽道上的絕對距離，算出來**還是 5 公尺**！
也就是說，**角度上的相對誤差看似變好了，但時間（距離）上的絕對誤差根本沒變。**

### 面試必考點
1. **問題：將一個 10GHz 的 Clock 經過 ideal $\div 4$ 除頻器變成 2.5GHz，其 Phase Noise 頻譜會如何變化？**
   → **答案：** 下降 $20 \log_{10}(4) = 12 \text{ dB}$。因為頻率變為 $1/4$，在相同 frequency offset 下，其相位波動量變為原來的 $1/4$，取 $10 \log_{10}((1/4)^2)$ 即為 -12 dB。
2. **問題：承上題，該 2.5GHz 訊號的 Time-domain RMS Jitter (ps) 會變好嗎？**
   → **答案：** 不會。理想情況下 RMS Jitter 保持不變。因為 Phase Noise 下降的比例，剛好被週期 $T$ 變長給抵消了 $\left( J_{rms,sec} = \frac{J_{rms,rad}}{2\pi f_c} \right)$。
3. **問題：在實際電路設計中 (Non-ideal Divider)，除頻後的 Jitter 真的不變嗎？**
   → **答案：** 實際上 Jitter 會**變差（增加）**。筆記中強調了「Neglect noise contributed by $\div 2$ circuit」，但在實務上，除頻器（如 CML 或 CMOS Flip-flops）內部的電晶體會額外貢獻 Thermal Noise 與 Flicker Noise，使得輸出的絕對時間誤差（秒數）大於輸入。

**記憶口訣：**
> **「除頻降噪二十 Log，時間抖動絕對不動；除非電路自己加料（雜訊），否則秒數不增不減。」**

---
**👨‍🏫 助教的費曼測試（Feynman Test）**
你以為你懂了嗎？接招：
1. **【反事實】** 如果今天不是做頻率除以 2，而是過一個理想的「倍頻器 (Multiplier)」把頻率乘以 2，Phase Noise 會變怎樣？Jitter 會變怎樣？
2. **【禁語令】** 不准用「Phase Noise」、「Jitter」、「頻譜」這三個專有名詞，用非理工科大學生聽得懂的話，解釋這頁筆記在證明什麼現象。
*(想好答案再來找我！)*
