# LA-L5-P2

> 分析日期：2026-04-06
> 原始圖片：images/done/LA-L5-P2.jpg

---


---
## Method II: Cherry-Hopper Amplifier

### 數學推導
Cherry-Hopper 架構的核心是將第一級轉導（Transconductance, Gm）與第二級轉阻（Transimpedance, TIA）級聯。藉由在第二級加入 Shunt-Shunt 負回授電阻 $R_F$，大幅壓低節點阻抗，將極點推向高頻。

1. **定義電路模型與節點 KCL**
   - 第一級 M1 將電壓轉電流，輸出至節點 X：$i_{out1} = -g_{m1} v_{in}$（假設電流流出節點 X）。
   - 第二級 M2 與 $R_F$ 構成 TIA。對節點 X 進行 KCL（假設電流源負載為理想）：
     $$g_{m1} v_{in} + \frac{v_x - v_{out}}{R_F} = 0 \quad \text{--- (式 1)}$$
   - 對節點 Vout 進行 KCL：
     $$\frac{v_{out} - v_x}{R_F} + g_{m2} v_x = 0$$
     $$\Rightarrow v_{out} - v_x = -g_{m2} R_F v_x \Rightarrow v_{out} = v_x(1 - g_{m2} R_F) \quad \text{--- (式 2)}$$

2. **求解電壓增益 ($V_{out}/V_{in}$)**
   - 將 (式 2) 的 $v_{out}$ 代回 (式 1)：
     $$g_{m1} v_{in} + \frac{v_x - v_x(1 - g_{m2} R_F)}{R_F} = 0$$
     $$g_{m1} v_{in} + \frac{g_{m2} R_F v_x}{R_F} = 0 \Rightarrow g_{m1} v_{in} + g_{m2} v_x = 0 \Rightarrow v_x = -\frac{g_{m1}}{g_{m2}} v_{in}$$
   - 將 $v_x$ 代入 (式 2) 求 $v_{out}$：
     $$v_{out} = \left(-\frac{g_{m1}}{g_{m2}} v_{in}\right)(1 - g_{m2} R_F) = -\frac{g_{m1}}{g_{m2}} v_{in} + g_{m1} R_F v_{in}$$
     $$\Rightarrow \frac{v_{out}}{v_{in}} = g_{m1} R_F - \frac{g_{m1}}{g_{m2}}$$

3. **求解輸入極點 ($W_{px}$)**
   - 節點 X 的阻抗即為 TIA 的輸入阻抗 $R_{in,TIA}$。加入測試電壓 $v_x$，電流 $i_x = \frac{v_x - v_{out}}{R_F}$。
   - 代入 $v_{out} = v_x(1 - g_{m2} R_F)$，得 $i_x = g_{m2} v_x$。
   - $R_{in,TIA} = \frac{v_x}{i_x} = \frac{1}{g_{m2}}$。
   - 因此，極點被大幅推向高頻：$W_{px} = \frac{1}{R_{in,TIA} C_x} \simeq \frac{g_{m2}}{C_x}$。

4. **求解輸出極點 ($W_{py}$)**
   - 節點 Vout 的阻抗為 TIA 的輸出阻抗 $R_{out,TIA}$。從 Vout 灌入測試電壓 $v_t$，並令 $v_{in} = 0$。
   - 節點 X KCL: $\frac{v_x - v_t}{R_F} = 0 \Rightarrow v_x = v_t$。
   - 節點 Vout KCL: $i_t = \frac{v_t - v_x}{R_F} + g_{m2} v_x = 0 + g_{m2} v_t$。
   - $R_{out,TIA} = \frac{v_t}{i_t} = \frac{1}{g_{m2}}$。
   - 極點同樣被推向高頻：$W_{py} = \frac{1}{R_{out,TIA} C_y} \simeq \frac{g_{m2}}{C_y}$。

*(註：筆記中的 BJT 版本更進階，在回授路徑中加入了 Q5/Q6 Emitter Follower 當作 Buffer，避免 $R_F$ 負載效應降低 Q3/Q4 增益，這是實務上常見的優化技巧。)*

### 單位解析
**公式單位消去：**
1. **電壓增益 $A_v = g_{m1} R_F - \frac{g_{m1}}{g_{m2}}$**
   - $g_{m1} R_F$: $[\text{A/V}] \times [\Omega] = [\text{A/V}] \times [\text{V/A}] = [1]$ (無單位，為電壓增益倍數)
   - $\frac{g_{m1}}{g_{m2}}$: $[\text{A/V}] / [\text{A/V}] = [1]$ (無單位)
   - 兩項相減結果仍為無單位，符合電壓增益物理意義。

2. **極點頻率 $W_{px} = \frac{g_{m2}}{C_x}$**
   - $g_{m2}$: 轉導 $[\text{A/V}]$
   - $C_x$: 電容 $[\text{F}] = [\text{C/V}] = [\text{A}\cdot\text{s/V}]$
   - $W_{px}$: $[\text{A/V}] / [\text{A}\cdot\text{s/V}] = [1/\text{s}] = [\text{rad/s}]$ (角頻率單位正確)

**圖表單位推斷：**
📈 本頁無圖表 (僅有電路架構圖)。

### 白話物理意義
Cherry-Hopper 架構利用局部電阻負回授，硬生生把第二級放大器的輸入與輸出阻抗「壓扁」到只剩 $1/g_m$，藉由犧牲部分增益，換取 RC 延遲極小化，實現超大頻寬。

### 生活化比喻
就像大隊接力，第一棒（M1）只負責全速衝刺把棒子（電流）交給第二棒。第二棒（M2）身上雖然綁了一根沉重的彈力帶（$R_F$ 負回授），限制了他最終能跑多遠（增益受限），但這根彈力帶讓他的「煞車與啟動反應時間」變得極短（阻抗變小，極點推向高頻），非常適合處理 SerDes 需要的超高速瞬間變化訊號。

### 面試必考點
1. **問題：Cherry-Hopper 架構為何能提升頻寬？**
   → 答案：利用 Gm-TIA 交替級聯，TIA 級的 Shunt-Shunt 負回授將節點 X (輸入) 與節點 Y (輸出) 的等效阻抗皆降低至 $1/g_{m2}$，使得寄生電容 $C_x$ 與 $C_y$ 產生的極點頻率 $W_p \simeq g_m/C$ 被大幅推向高頻。
2. **問題：筆記提到的 "Output CM definition issue" 是什麼原因造成的？**
   → 答案：因為 M3/M4 的閘極與汲極被 $R_F$ 直流短路。如果上方的 PMOS 電流源與下方的 NMOS 尾電流源存在 Mismatch，這個不平衡的誤差直流電流必須全部流過 $R_F$。因為 $R_F$ 通常很大，會導致輸出共模電壓發生巨大的不可控偏移（$V_{out,cm} = V_{gs3} + I_{error} \times R_F$）。
3. **問題：此架構為何會有 "Voltage headroom issue" (電壓裕度問題)？**
   → 答案：因為是直流直接耦合 (DC-coupled)，第一級的汲極電壓等於第二級的閘極電壓 ($V_{D1} = V_{G3}$)。加上電流源負載都需要維持在飽和區 ($V_{DS} > V_{OV}$)，層層疊加的 $V_{GS}$ 與 $V_{DSAT}$ 使得電路在低電源電壓 (如 1.0V) 下很難維持所有電晶體都在飽和區，通常需要較高的 VDD (如筆記所述的 1.8V)。

**記憶口訣：**
**Cherry-Hopper = 「交替換手，阻抗壓扁」** (Gm轉TIA，回授電阻把 RC 極點踢到天邊，代價是共模飄移與裕度吃緊)。
