# PLL-L42-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L42-P1.jpg

---


---
## 次諧波注入鎖定鎖相迴路 (Subharmonic Injection-Locked PLLs)

### 數學推導
筆記主要比較了三種架構的相位雜訊表現：傳統 PLL、單純次諧波注入鎖定 VCO (Subharmonic ILVCO)，以及結合兩者的 SILPLL。

1. **次諧波頻率關係**：
   輸出頻率為注入頻率的整數倍。
   $$ \omega_{out} = N \cdot \omega_{inj} $$
   其中 $N$ 是倍頻比 (分頻數 $M$ 通常等於 $N$)。

2. **單純 ILVCO 的相位雜訊模型**：
   - 自由振盪 (Free-running) 的 VCO 相位雜訊 $S_{\phi, VCO}$ 隨頻率偏移量 $\omega$ 呈 $1/\omega^2$ 下降。
   - 引入注入訊號後，在鎖定範圍 (Lock range) $\omega_L$ 內，VCO 會追蹤注入訊號的相位。
   - 因為是次諧波注入（倍頻），注入源的雜訊會被放大 $20\log(N)$ dB：
     $$ S_{\phi, out}(\omega) \approx S_{\phi, inj}(\omega) + 20\log(N) \quad \text{for } \omega < \omega_L $$
   - **缺點**：如果沒有外部 PLL 迴路輔助，VCO 的自然振盪頻率容易因 PVT 變異而飄移 (Drifting)。因為 $\omega_L$ 通常很小，一旦飄移超過 $\omega_L$ 就會失鎖 (Unlock)。如筆記所寫：「Subject to drifting ($\omega_L$ is small)」。

3. **結合 PLL 與 Injection Locking (SILPLL)**：
   - 傳統 PLL 的迴路頻寬為 $\omega_{BWL}$，只能在 $\omega_{BWL}$ 內壓制 VCO 雜訊。
   - 引入注入路徑後，注入鎖定機制提供了一個更寬的「等效頻寬」$\omega_L$。
   - **關鍵不等式**：$\omega_L > \omega_{BWL}$ (for most cases)
   - 這樣做的好處是：由慢速的 PLL 迴路確保長期的頻率鎖定（解決 drifting 導致失鎖的問題），同時利用快速的 Injection Locking 在更寬的頻段 ($\omega_L$) 內大幅壓制 VCO 的相位雜訊。

### 單位解析
**公式單位消去：**
- 倍頻公式：$\omega_{out} = N \cdot \omega_{inj}$
  - $[\text{rad/s}] = [\text{無因次常數}] \times [\text{rad/s}]$
  - 兩邊單位一致，代表頻率的線性倍數關係。
- 相位雜訊放大公式：$S_{\phi, out} \approx S_{\phi, inj} + 20\log(N)$
  - $[\text{dBc/Hz}] = [\text{dBc/Hz}] + [\text{dB}]$
  - 對數尺度下的相加等同於線性尺度下的相乘（相位誤差放大 $N$ 倍，功率頻譜放大 $N^2$ 倍，取 $10\log(N^2) = 20\log(N)$）。

**圖表單位推斷：**
1. 📈 **相位雜訊頻譜圖 (左上/中左/中下三張 Bode Plot)**：
   - **X 軸**：頻率偏移量 $\omega$ 或 $f$ $[\text{Hz}]$ (通常為對數尺度，例如 $10^3 \sim 10^8\text{ Hz}$)。
   - **Y 軸**：相位雜訊 $S_\phi$ $[\text{dBc/Hz}]$ (典型範圍如 $-80 \sim -140\text{ dBc/Hz}$)。
   - **圖意**：展示傳統 PLL、單純 ILVCO、SILPLL 三者壓制 VCO free-running 雜訊（黑色虛線）的能力。 SILPLL 能在較寬的 $\omega_L$ 內將雜訊壓低至 $20\log(N) + L_{inj}$ 的水平。

2. 📈 **時序圖 (右下角)**：
   - **X 軸**：時間 $t$ $[\text{ps}]$ (若 $Ck_{out}$ 為 10GHz，則週期 $T = 100\text{ ps}$)。
   - **Y 軸**：電壓 $V$ $[\text{V}]$ (邏輯準位，例如 $0 \sim 1\text{V}$ 或 $0 \sim 1.2\text{V}$)。
   - **圖意**：$Ck_{out}$ 是高頻時脈 (週期 $T$)。$V_{inj}$ 是從低頻參考時脈 $Ck_{ref}$ 萃取出來的窄脈衝，每隔 $M$ 個週期出現一次，強迫對齊 $Ck_{out}$ 的邊緣。

### 白話物理意義
將乾淨的低頻參考時脈轉換成「超短脈衝」，每隔幾個週期就直接「打入」高頻振盪器中強制它對齊步伐，同時保留傳統鎖相迴路在背景默默微調，完美結合了「快速寬頻降噪」與「長期不飄移」的優點。

### 生活化比喻
- **傳統 PLL** 就像老師（Reference）用聯絡簿（Phase Detector）定期檢查學生的進度（VCO），反應較慢（$\omega_{BWL}$ 小），學生在這期間容易分心走偏（累積相位雜訊）。
- **單純 Injection Locking** 就像老師拿著棍子（脈衝 $V_{inj}$），每走 $M$ 步就敲一下學生的腳強迫對齊步伐，反應極快（$\omega_L$ 大），但如果學生天生步距差太多（Drifting），棍子敲不到就會完全失控（Unlock）。
- **SILPLL** 則是結合兩者：老師平時還是看聯絡簿確保學生長期大方向是對的（不會 Drifting 失鎖），但每走 $M$ 步還是會用棍子精準敲一下腳（Injection）來消滅短期的步伐偏差（寬頻壓制相位雜訊）。

### 面試必考點
1. **問題：為什麼需要 Subharmonic Injection-Locked PLL (SILPLL)？單純用傳統 PLL 不好嗎？**
   → 答案：傳統 PLL 為了抑制 Reference 帶來的雜訊與突波 (Spur)，迴路頻寬 $\omega_{BWL}$ 不能太大，這導致它無法有效抑制 VCO 高頻段的相位雜訊。SILPLL 引入 Injection 路徑，利用其較大的鎖定範圍 $\omega_L > \omega_{BWL}$，能打破傳統頻寬限制，在寬頻段內大幅降低 VCO 雜訊。

2. **問題：單純只做 Injection-Locked VCO 有什麼致命缺點？為什麼要加回 PLL 迴路？**
   → 答案：單純的 ILVCO 其鎖定範圍 ($\omega_L$) 通常很窄。晶片在不同溫度或電壓下 (PVT 變異)，VCO 的自由振盪頻率很容易飄移。一旦飄移超過 $\omega_L$，就會失去鎖定 (Unlock)。加回 PLL 迴路能提供長期且穩定的頻率追蹤，確保 VCO 永遠被拉回 $\omega_L$ 的捕獲範圍內。

3. **問題：在 SILPLL 的架構圖中，為什麼參考時脈 $Ck_{ref}$ 要經過一個 Pulse Generator (Delay $\Delta T_1$ + XOR) 產生 $V_{inj}$ 脈衝，而不是直接注入方波？**
   → 答案：注入訊號的作用是「在邊緣提供相位修正」。如果注入寬方波，它在非邊緣時期會持續干擾 VCO 的自然振盪，破壞波形對稱性，甚至惡化雜訊或引入過大的 Reference Spur。使用極窄的脈衝，可以將能量集中在需要對齊的瞬間，達到 "Phase realization" 且最小化對 VCO 其他時間的干擾。

**記憶口訣：**
「**P**LL 顧長期不飄 (窄頻寬)，**I**njection 打邊緣降噪 (寬頻寬)，兩者合一 (**SILPLL**) 穩又少噪。」
