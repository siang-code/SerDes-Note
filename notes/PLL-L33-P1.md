# PLL-L33-P1

> 分析日期：2026-04-04
> 原始圖片：images/done/PLL-L33-P1.jpg

---


---
## 注入鎖定除頻器 (Injection-Locked Frequency Divider, ILFD)

### 數學推導
本頁筆記主要推導了 LC 注入鎖定除頻器的鎖定範圍 (Lock Range, $W_L$)，以及如何透過電路技巧來增加此範圍。

1. **基礎 Adler's Equation (鎖定範圍公式)：**
   一般振盪器被外部訊號注入時，其鎖定範圍的精確公式為：
   $$W_L = \frac{\omega_0}{2Q} \cdot \frac{I_{inj}}{I_{osc}} \cdot \frac{1}{\sqrt{1 - (\frac{I_{inj}}{I_{osc}})^2}}$$
   其中 $\omega_0$ 為振盪器自振頻率，$Q$ 為 Tank 的品質因子，$I_{inj}$ 為注入電流，$I_{osc}$ 為振盪器核心電流。

2. **實務簡化與等效替換：**
   - 假設注入電流相對較小 ($I_{inj} \ll I_{osc}$)，根號項 $\sqrt{1 - (\dots)^2} \approx 1$。
   - 在此差動 LC 除頻器架構中，注入訊號是從 Tail (尾電流源) 進入，頻率為 $2\omega_0$。交叉耦合對 (Cross-coupled pair) 類似一個混頻器 (Mixer)，將 $2\omega_0$ 的注入訊號與振盪器的基頻 $\omega_0$ 進行混頻。
   - 注入電流的等效基頻成分：因為開關動作類似方波，其一次諧波係數為 $\frac{2}{\pi}$，所以有效注入電流 $I_{inj\_eff} = I_{inj} \cdot \frac{2}{\pi}$。
   - 振盪器等效操作電流：在此近似中，取 $I_{osc} \approx I_B$ (尾電流源的直流值)。

3. **代入化簡得到最終 Lock Range：**
   將上述等效值代入簡化後的公式：
   $$W_L \approx \frac{\omega_0}{2Q} \cdot \frac{I_{inj} \cdot \frac{2}{\pi}}{I_B}$$
   $$\Rightarrow W_L = \frac{\omega_0 \cdot I_{inj}}{Q \cdot \pi \cdot I_B}$$
   這告訴我們：**要增加 Lock Range，可以增加注入電流 $I_{inj}$、減小振盪器本體電流 $I_B$、或降低 Tank 的 $Q$ 值**。

4. **改善鎖定範圍的電路技巧 (Improve Lock Range)：**
   筆記下方提出一個技巧，在 Tail 端加上電感 $L$ 與寄生電容 $C_p$ 形成並聯諧振。
   - 條件：使其在注入頻率諧振，即 $2\omega_0 = \frac{1}{\sqrt{LC_p}}$。
   - 目的：Tune 掉 Tail 端的寄生電容，最大化注入訊號的阻抗，使得 $I_{inj}$ 能更有效地轉化為推動 Tank 的能量，從而提升 Lock Range。

5. **Ring Oscillator 除 3 的原理 (Ex 2)：**
   - 筆記指出：「Ring OSC 波形接近方波，含有豐富的奇次諧波 (3rd, 5th...)」。
   - 當我們用 $3\omega_0$ 的時脈從 Tail 去推動它時，外部的 $3\omega_0$ 能量會與內部振盪器本來就有的 3 次諧波成分產生強烈「共振 / 鎖定」。
   - 因此，整個 Ring OSC 被強迫穩定在基頻為 $\omega_0$ 的狀態，達成 $\omega_0 = Input / 3$ 的除頻效果。

### 單位解析
**公式單位消去：**
針對 Lock Range 推導公式：$W_L = \frac{\omega_0 \cdot I_{inj}}{Q \cdot \pi \cdot I_B}$
*   $\omega_0$: 角頻率，單位 $[\text{rad/s}]$
*   $I_{inj}$: 注入電流，單位 $[\text{A}]$
*   $Q$: 品質因子，為能量比例，無單位 $[1]$
*   $\pi$: 常數，無單位 $[1]$
*   $I_B$: 偏壓電流，單位 $[\text{A}]$

將單位代入：
$W_L = \frac{[\text{rad/s}] \cdot [\text{A}]}{[1] \cdot [1] \cdot [\text{A}]} = [\text{rad/s}]$
數學推導結果的單位為 $[\text{rad/s}]$，符合鎖定「頻寬 / 頻率範圍」的物理意義，推導無誤。

**圖表單位推斷：**
📈 本頁無圖表。皆為電路架構圖。

### 白話物理意義
**「大水沖小廟才能隨波逐流」**——要讓振盪器聽命於外來的注入訊號（鎖定），外力（注入電流）要盡量大，而振盪器本身的固執程度（本體電流與 Q 值）要盡量小。

### 生活化比喻
把振盪器想像成一個正在盪鞦韆的小孩（以自然頻率 $\omega_0$ 擺動），注入訊號就像是在旁邊推他的大人。
- **Divide-by-2 (LC ILFD)**：大人每當鞦韆到最高點時（一週期兩次，頻率 $2\omega_0$）就往下一壓，迫使鞦韆乖乖保持在大人節奏的一半 ($\omega_0$) 擺動。
- **Lock Range**：如果小孩自己盪得很用力（$I_B$ 大），或者鞦韆很重很難改變節奏（$Q$ 值高），大人（$I_{inj}$）就只能在小孩原本節奏非常近的範圍內才能勉強配合上；如果大人力氣夠大（$I_{inj}$ 大），就能強迫小孩在更寬的頻率範圍內跟著大人的節奏走。
- **Divide-by-3 (Ring OSC)**：鞦韆架有點生鏽，小孩盪的時候會發出「嘰-拐-嘰-拐」的怪聲（包含高頻諧波）。大人如果抓準那個怪聲的頻率（$3\omega_0$）連續快速拍打三下，剛好也能強迫小孩維持每三下拍打完成一次完整擺動的節奏。

### 面試必考點
1. **問題：在設計高速 SerDes 時，為什麼 Prescaler (第一級除頻器) 常選用 Injection-Locked Divider 而不是傳統 CML Divider？**
   → **答案：** 因為在極高頻（如 28GHz 甚至 56GHz 以上），傳統 CML divider 受到 RC 延遲限制，往往無法工作或是需要消耗極大的電流。ILFD 本質上是一個 LC 振盪器，靠諧振抵銷寄生電容，因此能以較低的功耗在極高頻操作。缺點是鎖定範圍（Lock range）較窄。
2. **問題：請說明如何增加 LC ILFD 的 Lock Range？（舉出三個方法）**
   → **答案：** 根據公式 $W_L \propto \frac{I_{inj}}{Q \cdot I_B}$：
   (1) 增加注入訊號強度（提高 $I_{inj}$）。
   (2) 降低 Tank 的 $Q$ 值（可加入電阻，但會犧牲 phase noise 與增加功耗）。
   (3) 降低振盪器核心電流 $I_B$（削弱自身振盪能力，使其更容易被外力牽制）。
   (4) 電路技巧：在 Tail 注入點加上 LC 並聯諧振於 $2\omega_0$，最大化注入效率。
3. **問題：為什麼 Ring Oscillator 架構可以輕易實現除以 3 (Divide-by-3) 的功能，而完美的 LC Tank 很難？**
   → **答案：** 因為完美 LC Tank 過濾了高頻，波形接近純弦波，諧波成分極少。而 Ring Oscillator 輸出波形接近方波（或者說非線性較強），本身就含有豐富的奇次諧波（如 3rd, 5th）。注入 $3\omega_0$ 訊號時，可直接與其內部的 3 次諧波成分進行混頻鎖定，從而穩定基頻於 $\omega_0$。

**記憶口訣：**
*   **「大水沖小廟」**：大 $I_{inj}$ (外力大)、小 $I_B$ (自我意識弱)、小 $Q$ (不固執) $\Rightarrow$ Lock Range 大！
*   **「方波多奇葩」**：Ring OSC 波形像方波，多「奇」次諧波，所以能拿來做除 3 (奇數倍) 的 ILFD。
