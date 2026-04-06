# TIA-L11-P1

> 分析日期：2026-04-06
> 原始圖片：images/done/TIA-L11-P1.jpg

---


---
## Inverter-based TIA 與 Common-Gate TIA 架構比較

### 數學推導
這裡我們來嚴格推導筆記中提到的 $R_T$, $R_{in}$, 與 $R_{out}$。
定義 Inverter 的等效轉導為 $G_m = g_{mn} + g_{mp}$，等效輸出阻抗為 $R_o = r_{on} // r_{op}$。
開迴路電壓增益 $A_v = -G_m R_o$。

1. **轉阻增益 (Transimpedance Gain, $R_T$)**：
   - 假設輸入電流為 $I_{in}$，回授電阻為 $R_F$。
   - 節點 KCL（克希荷夫電流定律）：$I_{in} + \frac{V_{out} - V_{in}}{R_F} = 0$
   - 由於 $V_{out} = A_v \cdot V_{in}$，我們可以將 $V_{in}$ 代換為 $\frac{V_{out}}{A_v}$：
   - $I_{in} + \frac{V_{out} - (V_{out}/A_v)}{R_F} = 0$
   - $V_{out} \left( 1 - \frac{1}{A_v} \right) = -I_{in} \cdot R_F$
   - 得到轉阻增益 $R_T = \frac{V_{out}}{I_{in}} = \frac{-R_F}{1 - 1/A_v}$。
   - 當開迴路增益 $|A_v| \gg 1$ 時，$R_T \approx -R_F$。（筆記中的第一個結論）

2. **輸入阻抗 ($R_{in}$)**：
   - 使用 Blackman's Impedance Theorem 或直接推導：
   - $R_{in} = \frac{R_F + R_o}{1 + (-A_v)} = \frac{R_F + R_o}{1 + G_m R_o}$
   - 若 $G_m R_o \gg 1$ 且 $R_F$ 沒有遠大於 $R_o$，則 $R_{in} \approx \frac{R_F}{G_m R_o} + \frac{1}{G_m} \approx \frac{1}{G_m} = \frac{1}{g_{mn} + g_{mp}}$。（筆記中的第二個結論）

3. **輸出阻抗 ($R_{out}$)**：
   - 假設 TIA 前端接的是光電二極體，其 DC 等效為理想電流源（開路，源極阻抗 $R_s \to \infty$）。
   - 輸出阻抗會被回授迴路降低：$R_{out} = \frac{R_o}{1 + G_m R_o}$
   - 當 $G_m R_o \gg 1$ 時，$R_{out} \approx \frac{1}{G_m} = \frac{1}{g_{mn} + g_{mp}}$。（筆記中的第二個結論）

### 單位解析
**公式單位消去法：**
1. **轉阻增益 $R_T \approx -R_F$**：
   - $R_T = \frac{V_{out}}{I_{in}}$ 
   - 單位：$[V] / [A] = [\Omega]$ (歐姆)
   - 右式 $R_F$ 單位為 $[\Omega]$，等式兩邊單位完美吻合。
2. **輸入/輸出阻抗 $R_{in} = R_{out} \approx (g_{mn} + g_{mp})^{-1}$**：
   - 轉導 $g_m$ 定義為 $\frac{\partial I_D}{\partial V_{GS}}$
   - 單位：$[A] / [V] = [A/V]$ (或西門子 $[S]$)
   - 阻抗公式單位：$1 / [A/V] = [V/A] = [\Omega]$ (歐姆)

**圖表單位推斷：**
📈 筆記左上角圖表：**Inverter 轉移曲線 (Voltage Transfer Curve)**
- **X 軸**：輸入電壓 $V_{in}$ $[V]$，典型範圍 $0 \sim V_{DD}$ (例如先進製程 0 ~ 0.9V)。
- **Y 軸**：輸出電壓 $V_{out}$ $[V]$，典型範圍 $0 \sim V_{DD}$。
- **隱藏資訊**：圖中圈起的「inv gain 大區」代表斜率（$\frac{\partial V_{out}}{\partial V_{in}}$）絕對值最大的區域。這通常發生在 $V_{in} \approx V_{DD}/2$ 附近，此時 PMOS 與 NMOS 皆處於飽和區 (Saturation Region)，能提供最大的 $G_m$ 以極大化頻寬與降低輸入阻抗。

### 白話物理意義
Inverter-based TIA 就是把數位電路的「反相器」加上一顆回授電阻，讓上下兩顆電晶體 (PMOS和NMOS) 同時出力幫忙把電流訊號轉成電壓；這種「雙管齊下」的設計能用最少的耗電換到極大的放大能力，但代價是回授系統在高速下容易煞不住車而產生震盪。

### 生活化比喻
想像一個水龍頭（輸入電流）下面放著一個掛在彈簧上的水桶（輸出電壓）。Inverter 就像是水桶上下各有一個工人（PMOS和NMOS）：當水一變多，上面的工人放繩子、下面的工人往下拉，兩人「雙管齊下」讓水桶迅速下降；回授電阻 $R_F$ 則是那根彈簧，確保水桶不會直接掉到地上，而是穩定在一個高度。
相較之下，筆記下半部提到的 Common-Gate TIA 就像是只有一個工人在控制，雖然力量小一點，但因為沒有彈簧（無回授），所以絕對不會發生彈簧上下彈跳（震盪不穩）的問題。

### 面試必考點
1. **問題：在相同的消耗電流下，Inverter-based TIA 相比於傳統單端 CS (Common-Source) TIA 有什麼絕對優勢？**
   → **答案：** Inverter-based TIA 採用電流重複利用技術 (Current-reuse)。在相同的偏壓電流下，它的等效轉導是 $g_{mn} + g_{mp}$，提供了兩倍的 $G_m$。這不僅帶來更高的開迴路增益，還能進一步降低閉迴路輸入阻抗，並有效壓低電晶體帶來的 Thermal Noise。
2. **問題：筆記圖中特別圈出「inv gain 大區」，在實際電路中如何確保電路一定會操作在這個高增益區？**
   → **答案：** 依靠自我偏壓 (Self-biased) 特性。在 DC 情況下，光電二極體沒有電流流過回授電阻 $R_F$，因此 $R_F$ 兩端無壓降，強迫 $V_{in,DC} = V_{out,DC}$。這條 $V_{out}=V_{in}$ 的直線恰好會精準切在 Inverter 轉移曲線最陡峭的「gain 大區」，自動確保了最大的 $G_m$。
3. **問題：筆記提到 Common-Gate TIA "No feedback : 無條件 stable"，反過來說，Inverter-based TIA 為什麼會有不穩定 (Instability) 的問題？**
   → **答案：** Inverter-based TIA 是 Shunt-Shunt Feedback 架構。輸入端有光感測器帶來的巨大寄生電容 ($C_{in}$)，輸出端有負載電容 ($C_L$)，在迴路中形成了兩個主要的低頻極點 (Pole)。當增益很大且這兩個極點靠得太近時，相位邊際 (Phase Margin) 會嚴重不足，導致高速運作時產生 Ringing 甚至震盪。

**記憶口訣：**
「雙管齊下 Gm 大，轉阻 Rf 自我偏壓；高速最怕電容大，極點太近會震盪；若求穩妥 CG 上，開路無回保平安！」

---

### 👨‍🏫 助教的費曼測試（Feynman Test）
如果你覺得你看懂這張筆記了，試著回答我這三個問題：
1. **反事實攻擊**：如果把 Inverter 的 NMOS 拔掉，只留 PMOS 加上理想電流源（變成傳統 CS TIA），DC 工作點還能完美鎖定在「gain 大區」嗎？為什麼？
2. **情境遷移**：這個 $R_{in} \approx (g_{mn} + g_{mp})^{-1}$ 的特性，在 112Gbps PAM4 SerDes 的哪個接收端 Block 也會用到類似的「低輸入阻抗」觀念來吸收龐大的寄生電容？
3. **禁語令**：不准用「回授 (Feedback)」、「極點 (Pole)」、「相位邊際 (Phase Margin)」，用白話文解釋一次為什麼 Inverter-based TIA 容易震盪？
*(下次上課前把答案交給我！)*
