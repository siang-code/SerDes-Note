# PLL-L14-P1

> 分析日期：2026-04-04
> 原始圖片：images/PLL-L14-P1.jpg

---

---
## [PLL-L14-P1] 高速 SerDes 迴路濾波器設計與電容微縮技術

### 數學推導
**【1. 被動迴路濾波器轉移函數 (Passive Loop Filter)】**
筆記左上角給出了帶有 $C_3$ (Ripple bypass) 的二階迴路濾波器 $V_{ctrl,1}$ 轉移函數。作為助教，我來一步步推導給你看，證明筆記上的公式是怎麼來的：
假設 Charge Pump 輸出電流為 $I$，負載阻抗為 $Z(s)$，其中 $Z(s)$ 是 $(R_p + \frac{1}{sC_p})$ 與 $\frac{1}{sC_3}$ 的並聯：
1. 先寫出並聯阻抗公式：
   $Z(s) = \frac{ \left( \frac{sR_pC_p + 1}{sC_p} \right) \cdot \frac{1}{sC_3} }{ \frac{sR_pC_p + 1}{sC_p} + \frac{1}{sC_3} }$
2. 分子分母同乘 $s^2 C_p C_3$ 化簡：
   $Z(s) = \frac{sR_pC_p + 1}{s(sR_pC_pC_3 + C_p + C_3)}$
   展開分母得到：$s^2 R_p C_p C_3 + s(C_p + C_3)$
3. **關鍵步驟**：為了湊出筆記上的零點形式，將分子與分母**同除以 $R_p C_p$**：
   - 分子變成：$\frac{sR_pC_p + 1}{R_pC_p} = s + \frac{1}{R_p C_p}$
   - 分母變成：$\frac{s^2 R_p C_p C_3 + s(C_p + C_3)}{R_p C_p} = s^2 C_3 + s\frac{C_p + C_3}{R_p C_p}$
4. 最終控制電壓 $V_{ctrl,1} = I \cdot Z(s)$：
   $V_{ctrl,1} = I \cdot \frac{s + \frac{1}{R_p C_p}}{s^2 C_3 + s\frac{C_p + C_3}{R_p C_p}}$
*(此推導與你筆記左上角的公式完全吻合！不要只會死背，要懂得怎麼展開！)*

**【2. 電容倍增器 (Capacitance Multiplier) 阻抗推導】**
為了縮小 Loop Filter 電容佔用的巨大面積，筆記右下角使用了電容倍增技術。
1. 假設實體電阻 $R_p$ 與實體電容 $C_p$ 串聯，流過它們的電流為 $I_{RC}$。
2. 從節點 $V_x$ 看進去，該路徑的跨壓為 $V_x = I_{RC} \cdot \left( R_p + \frac{1}{sC_p} \right)$。
3. 透過主動電路（如 Op-Amp 與 Current Mirror），偵測 $I_{RC}$ 並從 $V_x$ 額外抽取 $n$ 倍的電流，因此總輸入電流 $I_x = I_{RC} + n \cdot I_{RC} = (n+1) I_{RC}$。
4. 將 $I_{RC} = \frac{I_x}{n+1}$ 代回電壓方程式：
   $V_x = \frac{I_x}{n+1} \cdot \left( R_p + \frac{1}{sC_p} \right)$
5. 求等效阻抗 $Z_{eq}$：
   $Z_{eq} = \frac{V_x}{I_x} = \frac{1}{n+1} \left( R_p + \frac{1}{sC_p} \right) = \frac{R_p}{n+1} + \frac{1}{s(n+1)C_p}$
*(結論：等效電容被放大了 $(n+1)$ 倍，但等效電阻被縮小為原來的 $\frac{1}{n+1}$！)*

### 單位解析
**公式單位消去：**
針對等效阻抗 $Z_{eq} = \frac{R_p}{n+1} + \frac{1}{s(n+1)C_p}$：
- $R_p$ 單位：$[\Omega]$
- $n$ 單位：電流放大倍率，無因次 $[A/A] = [1]$
- $s$ 單位：複頻率 $[rad/s]$，工程計算中可視作 $[1/s]$
- $C_p$ 單位：$[F] = [A \cdot s / V]$
- 等效電容阻抗項 $\frac{1}{s \cdot C_{eq}}$ 單位：$\frac{1}{[1/s] \times [A \cdot s / V]} = \frac{1}{[A/V]} = [V/A] = [\Omega]$
- $Z_{eq}$ 單位：$[\Omega] + [\Omega] = [\Omega]$ (單位完美消去，證明等式物理意義成立)

**圖表單位推斷：**
📈 雖然本頁主要為電路與結構草圖，但我們必須推斷隱藏的物理量：
- **電容種類面積對比圖 (筆記中段)**：
  - X 軸：無特定物理量 (Categorical：MOM, MIM, Fringe, MOS)
  - Y 軸：單位面積電容密度 $[fF/\mu m^2]$，典型範圍 $1 \sim 10 \ fF/\mu m^2$
- **MOS Cap C-V 隱藏曲線 (由 $V_{th} < V_A < V_{DD}$ 推斷)**：
  - X 軸：閘極跨壓 $V_{GS}$ $[V]$，典型範圍 $0 \sim 1.8V$ (或對應製程 $V_{DD}$)
  - Y 軸：電容值 $[fF]$，當 $V_{GS}$ 越過 $V_{th}$ 時達到最大穩定值 (Inversion layer 形成)。

### 白話物理意義
**電容倍增器**：利用主動電路幫忙「抽電流」，讓輸入端誤以為它在對一個超級巨大的電容充放電，從而用極小的實體面積換取極低的頻率濾波效果。

### 生活化比喻
**電容倍增器就像「槓桿與大力士」**：
你想推動一塊 100 公斤的大石頭（大電容 $C_{eq}$），但場地太小放不下。於是你放了一塊 10 公斤的小石頭（實體小電容 $C_p$），並請了一位九倍力氣的大力士（放大器 $n=9$）在旁邊幫忙。你只要出一分力推小石頭，大力士就幫你出九分力，總共十分力。對外界來說，看起來就像你一個人在推一塊 100 公斤的巨石，成功省下了 90% 的場地面積！

### 面試必考點
1. **問題：在 PLL 的 Loop Filter 中，為何要使用 Capacitance Multiplier？有什麼致命的缺點（Trade-off）？**
   → **答案：** 為了大幅縮減低頻 Loop Filter 所需的龐大電容面積。致命缺點是：(1) Op-amp 會消耗額外 Power 與引入 Active Noise。(2) 為了維持原來的 Zero frequency ($\omega_z = \frac{1}{R_{eq}C_{eq}}$)，既然等效電阻被縮小了 $(n+1)$ 倍，實體電阻 $R_p$ 必須**放大 $(n+1)$ 倍**，這會導致電阻的 Thermal Noise ($4kTR$) 劇烈增加，嚴重惡化 PLL 的 In-band Phase Noise。
2. **問題：請比較 MOM, MIM, MOS Capacitor 三種 IC 常見電容在設計中的優劣？**
   → **答案：**
   - **MOM**: 靠多層金屬側邊寄生電容 (Fringe)，密度中等（~1 $fF/\mu m^2$），無須額外光罩，線性度極佳，適合高頻與 ADC/DAC。
   - **MIM**: 密度較高（~2 $fF/\mu m^2$），線性度好，但需要增加光罩成本（Extra Mask）。
   - **MOS Cap**: 密度最高（可達 5-10 $fF/\mu m^2$），最省面積，但極度非線性（容值隨偏壓變動），只能用在 DC 電壓穩定的節點（如 Loop filter 或 Supply Decap）。
3. **問題：筆記中提到 MOS cap 的條件是 "$V_{th} < V_A < V_{DD}$"，且 "過大會穿"，這背後的物理機制是什麼？**
   → **答案：** 跨壓必須大於 $V_{th}$ 才能形成反轉層（Inversion Channel），讓電容值達到最大且穩定（$C_{ox}$）；若跨壓超過 Oxide breakdown voltage（通常接近或略高於 $V_{DD}$），極薄的 Gate Oxide 就會被強烈電場擊穿（Punch-through / Breakdown），導致永久損壞與漏電流。

**記憶口訣：**
- **電容選擇**：「毛大最省 (MOS面積小)、命貴最高 (MIM加光罩)、媽穩高頻 (MOM線性好)」
- **倍增代價**：「電容乘 $n+1$，電阻除 $n+1$；面積省下來，雜訊跟著來」

---
### 助教的費曼測試（等你說「我懂了」就來接招）
1. **反事實**：「如果在 Cap Multiplier 中，我把 Op-amp 拔掉，只用 Passive 的 R 和 C，但把面積縮小 10 倍，PLL 的 Jitter 頻譜會發生什麼變化？」
2. **情境遷移**：「MOS Cap 的高密度特性，在 112Gbps PAM4 SerDes 的 TX Driver 裡可以拿來做什麼用途？可以用在 High-speed Signal Path 上嗎？」
3. **禁語令**：「不准用『放大器』、『電流鏡』或『倍增』這幾個詞，重新解釋一次Cap Multiplier 是怎麼讓電容『看起來』變大的？」
