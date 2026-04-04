# PLL-L11-P1

> 分析日期：2026-04-04
> 原始圖片：images/PLL-L11-P1.jpg

---

同學，這張筆記非常經典，這是台大積體電路設計與高頻電路實驗室（李致毅老師）課程中，探討 **PLL Charge Pump (CP)** 非理想效應的核心解法。

你筆記裡畫的是 **Servo Feedback Charge Pump (主動回授型電荷泵浦)** 搭配 **通道長度調變 (Channel-Length Modulation, CLM) 補償電路**。在 55nm 甚至更先進的製程中，電晶體的 $r_o$ (輸出阻抗) 非常小，如果不用這種手法，$V_{ctrl}$ 變動時 UP 和 DOWN 電流就會嚴重 Mismatch，導致 Reference Spur 爆表。

以下是助教的嚴格拆解：

---
## 【高速 PLL 設計】Charge Pump 通道長度調變補償電路 (Channel-Length Modulation Compensation)

### 數學推導
這段推導的核心目標是證明：**「當 $V_{ctrl}$ 升高導致 UP PMOS 電流因為 CLM 效應衰減時，控制電路能自動產生一個更低的偏壓來強迫 PMOS 吐出更多電流」**。請跟著我一步步 Trace 筆記右圖的閉迴路：

1. **Op-Amp 追蹤機制 (追蹤 $V_{ctrl}$):**
   Op-Amp 的負輸入端接 $V_{ctrl}$，正輸入端接 $M_1$ 的汲極 $V_D$。因為負回授，$V_D$ 被強迫追蹤 $V_{ctrl}$。
   $$V_{ctrl} \uparrow \Rightarrow V_D \uparrow$$
2. **第一級 ($M_1$ 補償產生):**
   $M_1$ 為 PMOS，其汲極電流被固定在 $I_1$。考慮通道長度調變方程式：
   $$I_{M1} = \frac{1}{2} \mu_p C_{ox} \frac{W}{L} (V_{DD} - V_1 - |V_{thp}|)^2 (1 + \lambda (V_{DD} - V_D)) = I_1 \text{ (Constant)}$$
   因為 $V_D \uparrow$，導致跨壓 $(V_{DD} - V_D)$ 變小，亦即 $(1 + \lambda V_{SD})$ 項變小。為了維持 $I_{M1}$ 恆定，$(V_{DD} - V_1 - |V_{thp}|)^2$ 必須變大。
   $$\Rightarrow V_{SG1} \text{ 必須變大} \Rightarrow V_1 \downarrow \text{ (筆記完全正確)}$$
3. **第二級 ($M_2, M_3$ 電流汲取):**
   $M_2$ 和 $M_3$ 共享底部恆定電流源 $I_2$。
   因為 $V_1 \downarrow$，$M_2$ 的 $V_{SG2}$ 變大，導通更強：
   $$I_{M2} \uparrow$$
   根據 KCL，尾電流固定：$I_{M2} + I_{M3} = I_2 \text{ (Constant)}$。
   $$\Rightarrow I_{M3} \downarrow$$
4. **第三級 ($V_2$ 節點轉換):**
   $M_3$ 是一顆 Diode-connected PMOS，其閘極與汲極短接於 $V_2$ 節點。
   要讓 $I_{M3}$ 變小，其 $V_{SG3}$ 必須變小：
   $$V_{DD} - V_2 \downarrow \Rightarrow V_2 \uparrow \text{ (筆記完全正確)}$$
5. **第四級 (NMOS 差動對與輸出 $V_4$):**
   左側 NMOS 接收 $V_2$，右側 NMOS 輸出 $V_4$ (筆記寫 $V_3$ 或 $V_4$，這裡以 $V_4$ 代稱)，尾電流為 $I_3$。
   當 $V_2 \uparrow$，左側 NMOS 導通變強：$I_{D,left} \uparrow$。
   由於 $I_{D,left} + I_{D,right} = I_3 \text{ (Constant)}$，所以 $I_{D,right} \downarrow$。
   右側 NMOS 也是 Diode-connected (或接成 Buffer 形式)，為了讓汲取電流變小，其 $V_{GS}$ 必須下降：
   $$\Rightarrow V_4 \downarrow$$
6. **最終補償 (Pumping more current):**
   $V_4$ 被送回 Charge Pump 作為 UP PMOS 的閘極偏壓。
   $V_4 \downarrow \Rightarrow V_{SG,UP} \uparrow \Rightarrow$ **強迫 UP PMOS 提供更多電流 (Pumping more current)**，完美抵銷了最初因為 $V_{ctrl}$ 升高導致的通道長度調變衰減！

### 單位解析
**公式單位消去：**
針對最核心的 PMOS 電流方程式：
$$I_D = \frac{1}{2} \cdot \mu_p C_{ox} \cdot \frac{W}{L} \cdot (V_{SG} - |V_{th}|)^2 \cdot (1 + \lambda V_{SD})$$
- $\mu_p C_{ox}$ (製程轉導參數): $[\text{A}/\text{V}^2]$
- $W/L$ (長寬比): 無因次 $[1]$
- $(V_{SG} - |V_{th}|)^2$ (過驅動電壓平方): $[\text{V}^2]$
- $\lambda$ (通道長度調變係數): $[\text{V}^{-1}]$
- $(1 + \lambda V_{SD})$: $[1] + [\text{V}^{-1}][\text{V}] = [1]$ (無因次)
消去結果：$[\text{A}/\text{V}^2] \times [\text{V}^2] \times [1] = \mathbf{[A]}$ (安培，電流單位)

**圖表單位推斷：**
📈 **右下方 Charge Pump 輸出特性圖：**
- **X 軸：** 控制電壓 $V_{ctrl}$ **[V]**，典型範圍 $0 \sim V_{DD}$ (在成熟製程如 0.18μm 為 $0 \sim 1.8\text{V}$)。
- **Y 軸：** 輸出電流 $I_{out}$ **[μA]**，典型範圍 $10\mu\text{A} \sim 500\mu\text{A}$。
- **物理意義：** 虛線代表沒有補償時，當 $V_{ctrl}$ 接近 VDD 或 GND，電流會因為 $V_{DS}$ 被壓縮而快速掉落；實線代表加入你筆記中的補償電路後，電流能維持 Flat 的完美平坦區間。

### 白話物理意義
當 Charge Pump 輸出端電壓過高，導致上游電晶體因為「沒壓差」而擠不出電流時，這套電路就像一個「智慧加壓馬達」，偵測到壓差變小，就自動把上游水龍頭（Gate 偏壓）轉得更開，硬是把電流補回來。

### 生活化比喻
想像一個高架水塔（UP PMOS）往底下的大水缸（Loop Filter, $V_{ctrl}$）注水。
當水缸的水位（$V_{ctrl}$）越來越高，逼近水塔的高度時，水流速度自然會變慢（這就是通道長度調變效應）。
為了解決這個問題，我們裝了一個水位感測器（Op-Amp），只要發現水缸水位升高，就立刻啟動一套連桿機構（$M_1 \sim M_4$），強行把水塔的閥門（$V_4$）拉得更開，確保出水量永遠保持不變！

### 面試必考點
1. **問題：為什麼 Charge Pump 一定要保持 UP 和 DOWN 電流完美匹配？**
   → **答案：** 如果 $I_{UP} \neq I_{DN}$，在 PLL 鎖定時，Phase Detector 會產生 Static Phase Offset (靜態相位誤差) 來彌補漏電，這會導致 VCO 控制線上出現週期性的 Ripple，進而在頻譜上產生嚴重的 Reference Spur (突波)。
2. **問題：在先進製程 (如 7nm/5nm)，這個電路的效用大嗎？為什麼？**
   → **答案：** 效用極大且必須存在。先進製程的電晶體 $L$ 極短，導致 $r_o$ 非常小（$\lambda$ 極大），電流對 $V_{DS}$ 的變化超級敏感。如果不做主動回授與補償，Charge Pump 的電流失配會高達 30% 以上。
3. **問題：這個 Error Amplifier 的頻寬設計有什麼限制？**
   → **答案：** 頻寬不能太大也不能太小！它必須比 PLL 的 Loop Bandwidth 快，才能即時追蹤 $V_{ctrl}$ 的變化；但必須遠低於 Reference Frequency，否則會把開關切換的高頻雜訊 (Switching Noise) 直接放大並耦合進 bias line，導致 Jitter 惡化。

**記憶口訣：** 
**「壓升管窄流變小，負回授降閘門保」** 
($V_{ctrl}$ 升高導致等效壓差變小電流縮減，透過負回授一路連動降低 Gate 電壓，強迫導通以保證電流平坦。)

---

### 😈 助教的費曼測試 (Feynman Test)
同學，這套連鎖反應你覺得你懂了是吧？現在我考你一個情境遷移：
**「如果今天我們要補償的是底下的 DOWN NMOS Current Source，請不准用筆記裡的電路，用口頭告訴我，Op-Amp 的極性該怎麼接？最後一級的 $V_{bias}$ 是該上升還是下降？」** 
（想想看，NMOS 源極接地，如果 $V_{ctrl}$ 下降逼近地端會發生什麼事？）想清楚再回答！
