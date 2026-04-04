# PLL-L41-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L41-P1.jpg

---


---
## [PLL迴路頻寬與VCO雜訊貢獻的等效設計 (Bandwidth Design for Equal VCO Noise)]

### 數學推導
本頁筆記的核心在探討：如果我們有兩個相似的 VCO，但操作在不同的頻率（$f_{ck2} = N \cdot f_{ck1}$），我們該如何調整 PLL 的迴路頻寬（$W_{BW}$），才能讓這兩個 PLL 輸出端「由 VCO 貢獻的相位雜訊（Jitter）」保持相同？

1. **定義積分相位雜訊（Jitter Variance）**：
   輸出端由 VCO 貢獻的 Jitter 平方（$J_{rms}^2$）即為濾波後 VCO 雜訊頻譜密度曲線下的總面積。
   $$J_{rms}^2 = \int_0^\infty S_{\phi,out}(f) df$$

2. **面積近似（相等面積法）**：
   經過 PLL 的高通濾波後，VCO 雜訊在 $W_{BW}$ 內會被壓抑（斜率為 $+20dB/dec$ 抵銷 VCO 自身的 $-20dB/dec$ 變為平坦），在 $W_{BW}$ 之外則跟隨原本 VCO 的 $-20dB/dec$ 下降。
   因此，高通濾波後的雜訊總面積，可以近似為一塊矩形面積（高度 $\times$ 頻寬）：
   $$\text{Area} \approx S_{\phi}(W_{BW}) \cdot W_{BW}$$
   要讓兩個 PLL 的 VCO 雜訊貢獻相同，則面積必須相等：
   $$S_1 \cdot W_{BW1} = S_2 \cdot W_{BW2}$$

3. **代入 VCO 相位雜訊模型**：
   根據 Leeson's Equation 的簡化形式，VCO 雜訊與振盪頻率的平方成正比，與頻偏的平方成反比：
   $$S_{\phi} \propto \frac{k_0}{4Q^2} \frac{\omega_{ck}^2}{\omega^2}$$
   我們將此關係代入 $S_1$（在 $\omega = W_{BW1}$ 處）與 $S_2$（在 $\omega = W_{BW2}$ 處）：
   $$S_1 = \frac{k_0}{4Q^2} \cdot \frac{\omega_{ck1}^2}{W_{BW1}^2}$$
   $$S_2 = \frac{k_0}{4Q^2} \cdot \frac{\omega_{ck2}^2}{W_{BW2}^2}$$

4. **解出頻寬比例**：
   將 $S_1, S_2$ 代回相等面積方程式：
   $$\left( \frac{k_0}{4Q^2} \cdot \frac{\omega_{ck1}^2}{W_{BW1}^2} \right) \cdot W_{BW1} = \left( \frac{k_0}{4Q^2} \cdot \frac{\omega_{ck2}^2}{W_{BW2}^2} \right) \cdot W_{BW2}$$
   消去常數項 $\frac{k_0}{4Q^2}$ 並化簡：
   $$\frac{\omega_{ck1}^2}{W_{BW1}} = \frac{\omega_{ck2}^2}{W_{BW2}}$$
   移項得到迴路頻寬的關係：
   $$\frac{W_{BW2}}{W_{BW1}} = \frac{\omega_{ck2}^2}{\omega_{ck1}^2} = N^2$$
   **結論**：若頻率提升 $N$ 倍，迴路頻寬必須提升 $N^2$ 倍才能維持相同的 VCO Jitter 貢獻。

### 單位解析
**公式單位消去：**
- $J_{rms}^2 = \int_0^\infty S_{\phi}(f) df$
  - $[rad^2] = [rad^2/Hz] \times [Hz]$ （這代表相位誤差的變異數，開根號即為 rms jitter $[rad]$）
- $\frac{W_{BW2}}{W_{BW1}} = \frac{\omega_{ck2}^2}{\omega_{ck1}^2}$
  - $\frac{[rad/s]}{[rad/s]} = \frac{[rad/s]^2}{[rad/s]^2} \Rightarrow [無單位] = [無單位]$ （比例關係）

**圖表單位推斷：**
📈 **圖表一（最左側）：VCO 開迴路相位雜訊頻譜 $S_{\phi}$ vs $\omega$**
- X 軸：頻率偏移 $\omega$ $[rad/s]$ (對數座標)，典型範圍 $10^3 \sim 10^8$ rad/s
- Y 軸：相位雜訊功率頻譜密度 $S_{\phi}$ $[rad^2/Hz]$ 或 $[dBc/Hz]$，曲線呈 $-20dB/dec$ 下降 ($\propto 1/\omega^2$)。兩 VCO 頻譜高度差 $20\log_{10}(N)$ dB。

📈 **圖表二（中間）：PLL 對 VCO 雜訊的轉移函數 $|\phi_{out}/\phi_{VCO}|^2$**
- X 軸：頻率 $\omega$ $[rad/s]$ (對數座標)
- Y 軸：增益平方 $[V/V]$ 或 $[rad/rad]$ (無單位)，表現為高通濾波器特性，轉角頻率為 $W_{BW}$。

📈 **圖表三（最右側）：閉迴路輸出相位雜訊 (僅看 VCO 貢獻)**
- X 軸：頻率偏移 $\omega$ $[rad/s]$ (對數座標)
- Y 軸：輸出相位雜訊 PSD $[rad^2/Hz]$。在頻寬 $W_{BW}$ 內被高通壓平，頻寬外跟隨 $1/\omega^2$ 下降。圖中陰影面積即為 Jitter 變異數。

### 白話物理意義
要想讓兩顆頻率相差 N 倍的 VCO，在鎖相迴路裡吵鬧（雜訊）的程度聽起來一樣，比較高頻的那顆 VCO 因為天生雜訊大 N^2 倍，所以你必須把 PLL 的「消噪頻寬」開大 N^2 倍才能把它壓制下來。

### 生活化比喻
想像你在開車，VCO 雜訊就像車子引擎的震動。
今天你換了一台轉速快 4 倍（$N=4$）的跑車，引擎震動的能量會變成 16 倍（$N^2$）。為了讓車內的乘客感覺到「一樣平穩（相同 Jitter）」，你必須把避震器（PLL 迴路頻寬）的反應速度調快 16 倍，才能瞬間抵銷掉這些高頻震動。但避震器調太快，路面上的小碎石（Reference Noise）反而會全部傳進車裡！

### 面試必考點
1. **問題：若要將 PLL 輸出頻率提高 4 倍（$N=4$），且要求 VCO 貢獻的 Jitter 不變，迴路頻寬要怎麼調？有什麼實務困難？** 
   → 答案：頻寬必須提高 $4^2 = 16$ 倍。實務上非常困難，因為：1. 頻寬有上限，為了穩定度通常 $W_{BW} \le W_{ref}/10 \sim W_{ref}/20$；2. 頻寬太大會讓 Input, PFD, Charge Pump 的低通雜訊大量進入輸出端（High $W_{BW} \Rightarrow$ more noise from input）。
2. **問題：為什麼圖中閉迴路 VCO 相位雜訊頻譜在 $W_{BW}$ 內部是平坦的？** 
   → 答案：因為 VCO 本身的開迴路雜訊呈現 $1/\omega^2$ 的特性（$-20dB/dec$），而 PLL 對 VCO 的雜訊轉移函數在頻寬內是高通特性，正比於 $\omega^2$（$+20dB/dec$）。兩者相乘抵銷，使得頻譜在頻寬內變為平坦（常數）。
3. **問題：在設計 SerDes PLL 時，為什麼不能無限放大 Loop Bandwidth 來把 VCO 雜訊壓到最低？** 
   → 答案：PLL 設計是「雜訊的 Trade-off」。對 VCO 來說是高通（喜歡寬頻寬），但對 Reference, PFD, CP 來說是低通（喜歡窄頻寬）。無限放大頻寬不僅會引入大量前端雜訊，還會因為離散時間採樣效應（Delay in loop）違反 Gardner 穩定度準則導致系統發散。

**記憶口訣：**
「VCO 升 N 倍，雜訊長 N 平方，頻寬要追 N 平方，小心 Reference 雜訊反咬、迴路炸光光！」
