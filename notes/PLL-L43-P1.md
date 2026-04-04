# PLL-L43-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L43-P1.jpg

---

---
## [Injection-Locked PLLs (IL-PLL) 注入鎖定鎖相迴路與時序對齊]

### 數學推導
筆記中提到 IL-PLL 的核心概念是「消除累積的 Jitter」並需要「$\Delta T_i$ 來對齊相位」。背後的物理機制可由 VCO 的相位雜訊累積與 Adler's Equation 來推導：

1. **VCO 相位誤差累積 (Phase Error Accumulation):**
   自由振盪的 VCO，其相位誤差變異數隨時間呈線性增長：
   $$ \sigma_{\Delta T}^2(t) = \kappa^2 \cdot t $$
   在一般 PLL 中，這個誤差會累積直到被迴路頻寬修正。而在 IL-PLL 中，每隔 $N$ 個週期注入一次純淨的 Reference Clock ($Ck_{ref}$)，會將累積的誤差「歸零」（Clean-up ordinary accumulated PLL Jitter）。

2. **注入鎖定的相位差 (Adler's Equation):**
   當我們將 $Ck_{ref}$ 的邊緣注入 VCO 時，若兩者自然頻率有微小偏差 $\Delta \omega = \omega_{vco} - N \cdot \omega_{ref}$，系統會產生一個靜態相位差 $\theta_0$：
   $$ \sin(\theta_0) = \frac{\omega_{vco} - N \cdot \omega_{ref}}{\omega_{lock}} $$
   其中 $\omega_{lock}$ 為注入鎖定範圍 (Lock range)。

3. **為何需要 $\Delta T_i$ (延遲補償)?**
   為了達到最低的 Jitter（圖中的谷底），我們希望注入邊緣剛好落在 VCO 的理想零交越點（Zero-crossing），即 $\theta_0 \approx 0$。
   如果普通的 PLL 迴路（Ordinary Phase Locking Path）鎖定時的穩態相位與注入路徑（Inj. Locking Path）有時間差，就會導致注入瞬間發生相位跳變，產生嚴重的 Deterministic Jitter (DJ)。
   因此必須加入一個可調延遲 $\Delta T_i$，滿足：
   $$ \Delta \phi_{align} = \omega_{vco} \cdot \Delta T_i - \theta_0 = 0 $$
   確保兩個路徑完美對齊（Line up）。

### 單位解析
**公式單位消去：**
* **VCO Jitter 累積公式:**
  $$ \sigma_{\Delta T}^2 [s^2] = \kappa^2 \left[\frac{s^2}{s}\right] \cdot t [s] = [s^2] $$
  （$\kappa$ 為時域的 Jitter proportionality constant，單位常寫作 $s^{1/2}$，時間 $t$ 單位為 $s$）
* **Adler's Phase Equation:**
  $$ \sin(\theta_0) [\text{無單位}] = \frac{\Delta \omega \ [\text{rad/s}]}{\omega_{lock} \ [\text{rad/s}]} = [\text{無單位}] $$

**圖表單位推斷：**
📈 圖表單位推斷（右側 Jitter vs. Timing 曲線）：
- **X 軸：** 注入時間偏移量 $t$ 或相位 $\phi$，單位推斷為 [ps] 或 [Degree/UI]。典型範圍為一個 VCO 週期 $0 \sim T$。圖中标示 "~240°" 代表有效且低 Jitter 的注入時間視窗寬度約佔整個週期的 $2/3$。
- **Y 軸：** 輸出抖動 Jitter，單位推斷為 [ps rms] 或 [UI]。典型範圍視頻率而定，在平坦區（谷底）可能 < 0.5ps，在邊緣區（兩側翹起）會急遽惡化。

### 白話物理意義
IL-PLL 就像是用一個極度精準的外部時鐘，定期「強制覆寫」VCO的相位來清除累積的誤差；但如果硬塞的時間點不對，反而會讓系統產生巨大的突波和抖動，所以需要 $\Delta T_i$ 來精準抓時機。

### 生活化比喻
想像一群蒙眼齊步走的士兵（VCO信號），走久了步伐會逐漸不整齊（Jitter累積）。
這時班長（Reference Clock）每隔10秒就會大喊一聲「標齊對正！」（注入信號）。只要一喊，所有人瞬間拉回正確位置（Clean-up accumulated jitter），隊伍就能保持極度整齊（Ultra low jitter）。
但是！班長「喊口令的時機（$\Delta T_i$）」非常重要。必須剛好在士兵準備跨步的那一瞬間喊；如果士兵腳還在半空中你硬要他踩地（U型曲線兩側），士兵會踉蹌跌倒，反而造成更大的混亂（Jitter飆高）。圖中的 "~240°" 就是士兵可以安全調整步伐的「黃金時間視窗」。

### 面試必考點
1. **問題：為什麼筆記特別強調「Need $\Delta T_i$ to line up」？如果不加 $\Delta T_i$ 對齊會發生什麼事？**
   → 答案：如果不加 $\Delta T_i$ 對齊，普通 PLL 鎖定的 VCO 邊緣與注入信號的邊緣會有時間差。當注入信號強勢介入時，VCO 相位會發生瞬間拉扯（Phase Jump），這會在輸出頻譜上產生極大的 Reference Spur（參考突波），並在時域上產生嚴重的 Deterministic Jitter (DJ)，破壞 IL-PLL 原本 Ultra-low Jitter 的優勢。

2. **問題：請解釋右圖 U 型曲線的物理意義？為什麼中間有一段 "~240°" 的平坦區？**
   → 答案：此圖是「輸出 Jitter」對「注入時間偏移量」的關係。中間平坦區代表在此時間視窗內注入，VCO 能順利被鎖定且相位跳變極小，Jitter 由乾淨的 Ref Clock 主導。兩側翹起是因為注入點太靠近 VCO 的峰值（敏感度低的地方）或極性相反處，導致注入拉扯過大，系統難以鎖定或產生極大干擾。240度代表該架構的注入容忍度（Injection Window）相當寬。

3. **問題：筆記最後寫「High tolerance to PVT variations」，一般的 Ring-VCO IL-PLL 其實對 PVT 很敏感，為什麼這裡能容忍？**
   → 答案：因為這是一個混合架構（通常稱為 MDLL 或具有 Ordinary phase locking path 的 IL-PLL）。普通的 PLL 迴路（透過 PFD/CP/LF）擁有無限大的直流增益，負責追蹤並補償低頻的 PVT 漂移；而注入路徑（Inj. Locking Path）只負責高頻的 Jitter 消除。兩者分工合作，因此能同時達到低 Jitter 與高 PVT 容忍度。

**記憶口訣：**
定期打針除百病，對準節拍最要緊。（打針=Injection，除百病=Clean Jitter，對準節拍=$\Delta T_i$ alignment）。
