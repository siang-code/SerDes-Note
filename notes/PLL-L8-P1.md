# PLL-L8-P1

> 分析日期：2026-04-04
> 原始圖片：images/PLL-L8-P1.jpg

---

---
## [Type-IV PFD 與 Charge Pump 的非理想效應：Deadzone 與 Current Mismatch]

### 數學推導
筆記中探討了 Type-IV PFD 如何將相位差 $\Delta\phi$ 轉換為平均電流 $\overline{I_{out}}$，以及當 Charge Pump 發生 Current Mismatch 時，為何會產生靜態相位誤差 (Static Phase Offset)。

1. **理想 Charge Pump 平均輸出電流 ($\overline{I_{out}}$) 與相位差 ($\Delta\phi$) 的線性關係：**
   當 PFD 偵測到相位差 $\Delta\phi$ (單位為 rad) 時，對應的時間差為 $\Delta t = \frac{\Delta\phi}{\omega_{ref}} = \frac{\Delta\phi}{2\pi} T_{ref}$。
   在 $\Delta t$ 時間內，Charge Pump 輸出的電流為 $I_P$ 或 $I_N$ (假設理想狀況 $I_P = I_N = I_0$)。
   在一個參考週期 $T_{ref}$ 內的平均輸出電流為：
   $$ \overline{I_{out}} = \frac{1}{T_{ref}} \int_{0}^{T_{ref}} I_{out}(t) dt = \frac{I_0 \cdot \Delta t}{T_{ref}} $$
   將 $\Delta t = \frac{\Delta\phi}{2\pi} T_{ref}$ 代入：
   $$ \overline{I_{out}} = \frac{I_0 \cdot \left(\frac{\Delta\phi}{2\pi} T_{ref}\right)}{T_{ref}} = \frac{I_0}{2\pi} \Delta\phi $$
   這證明了 $\overline{I_{out}}$ 與 $\Delta\phi$ 呈現完美的線性關係，斜率即為增益 $K_{PD} = \frac{I_0}{2\pi}$，這也就是筆記右上角「Linear PD」沒有 Deadzone 的理想特性。

2. **Charge Pump Current Mismatch 造成的 Static Phase Offset (SPO)：**
   筆記下方提到：「If $I_N \neq I_P \Rightarrow$ 相位會有固定的 phase error 來彌補」。
   當 $I_P \neq I_N$ 時（例如 $I_P < I_N$），為了讓 PLL 鎖定（即 Loop Filter 上的平均電荷變化量為零，維持 $\overline{I_{out}} = 0$），系統必須產生一個固定的相位誤差 $\Delta t_{error}$。
   假設 Type-IV PFD 的 Reset 延遲時間為 $t_{reset}$（即 QA 和 QB 同時為 High 的時間，用來消除 Deadzone）。
   在穩態鎖定下，每一個週期中 Up 電流充入的總電荷量必須等於 Down 電流抽取的總電荷量：
   $$ Q_{up} = Q_{down} $$
   假設輸入時脈 A 需領先時脈 B $\Delta t_{error}$，則 QA 會開啟 $\Delta t_{error} + t_{reset}$ 的時間，而 QB 僅開啟 $t_{reset}$ 的時間：
   $$ I_P \cdot (\Delta t_{error} + t_{reset}) = I_N \cdot t_{reset} $$
   展開後移項：
   $$ I_P \cdot \Delta t_{error} + I_P \cdot t_{reset} = I_N \cdot t_{reset} $$
   $$ I_P \cdot \Delta t_{error} = (I_N - I_P) \cdot t_{reset} $$
   $$ \Delta t_{error} = \frac{I_N - I_P}{I_P} \cdot t_{reset} $$
   將時間差轉換為相位差 $\Delta\phi_{error}$：
   $$ \Delta\phi_{error} = 2\pi \frac{\Delta t_{error}}{T_{ref}} = 2\pi \frac{I_N - I_P}{I_P} \frac{t_{reset}}{T_{ref}} $$
   這證明了即便平均電流 $\overline{I_{out}} = 0$，只要 $I_N \neq I_P$，就一定會存在 $\Delta\phi_{error} \neq 0$。這解釋了筆記右下角的圖中，傳遞函數直線為何會發生水平平移，使得 "Locked here" 的交點偏離原點。

### 單位解析
**公式單位消去：**
- **平均電流公式**：$\overline{I_{out}} = \frac{I_0}{2\pi} \Delta\phi$
  - $\Delta\phi$ 單位：$[rad]$ （物理意義上表示相位角，為無因次量）
  - $I_0$ 單位：$[A]$
  - $2\pi$ 單位：$[rad]$
  - $K_{PD} = \frac{I_0}{2\pi}$ 單位：$[A/rad]$
  - 單位消去：$[A/rad] \times [rad] = [A]$ (成功得到平均電流)
- **相位誤差公式**：$\Delta\phi_{error} = 2\pi \frac{I_N - I_P}{I_P} \frac{t_{reset}}{T_{ref}}$
  - $I_N, I_P$ 單位：$[A]$，相減及相除後：$[A] / [A] = [無因次比例]$
  - $t_{reset}, T_{ref}$ 單位：$[s]$，相除後：$[s] / [s] = [無因次比例]$
  - $2\pi$ 單位：$[rad]$
  - 單位消去：$[rad] \times [無因次] \times [無因次] = [rad]$ (成功得到相位誤差)

**圖表單位推斷：**
1. 📈 **PFD & CP 邏輯與充放電波形圖 (左上)**：
   - X 軸：時間 $t$ $[\text{ns}]$，典型範圍 $0 \sim 10\text{ ns}$ (取決於 Reference Clock 週期的數倍)
   - Y 軸 (A, B, QA, QB)：電壓 $[\text{V}]$，數位邏輯準位，典型範圍 $0 \sim 1.0\text{V}$ (VDD)
   - Y 軸 (Vctrl)：控制電壓 $[\text{V}]$，典型範圍 $0.2\text{V} \sim 0.8\text{V}$ (Charge Pump 可正常運作的 Compliance Voltage 範圍)
2. 📈 **Binary PD vs Linear PD 轉換曲線 (中上)**：
   - X 軸：相位差 $\Delta\phi$ $[\text{rad}]$ 或 $[\text{UI}]$，典型範圍 $-\pi \sim +\pi$ 或 $-0.5 \sim +0.5\text{ UI}$
   - Y 軸：平均輸出電流 $\overline{I_{out}}$ $[\mu\text{A}]$，典型範圍 $-100\mu\text{A} \sim +100\mu\text{A}$
3. 📈 **Deadzone Jitter 示意圖 (中下)**：
   - X 軸：時間 $t$ $[\text{ps}]$
   - Y 軸：Clock 電壓振幅 $[\text{V}]$
   - 斜線區域 (Jitter)：表示 Clock 邊緣在 Deadzone 內隨機飄移的時間範圍，因為系統在此區間無「Corrective info」(即開迴路狀態)，典型值數個到數十個 ps。
4. 📈 **Current Mismatch 造成的 Locking Point 偏移 (右下)**：
   - X 軸：相位差 $\Delta\phi$ $[\text{rad}]$，通常範圍極小，落在數個 $\text{mrad}$ 級別。
   - Y 軸：平均輸出電流 $\overline{I_{out}}$ $[\mu\text{A}]$。
   - 交點 "Locked here"：Y 軸必定為 $0\mu\text{A}$ (電荷平衡狀態)，X 軸對應一非零的 Static Phase Offset。

### 白話物理意義
Type-IV PFD 本身沒有死區，但如果 Charge Pump 的「充水」與「放水」電流大小不相等，PLL 為了在每個週期維持 Loop Filter 的總電荷不變，就必須強迫輸入時脈產生一個固定的「時間差」（Phase Error），讓比較弱的那端多開一段時間來彌補電流差。

### 生活化比喻
把 PLL 的 Loop Filter 想像成一個浴缸 (Vctrl 水位)，PFD 是眼睛，Charge Pump 是水龍頭（進水 $I_P$）和排水孔（出水 $I_N$）。
如果眼睛很敏銳（Type-IV 沒有 Deadzone），但進水量大於出水量（Current Mismatch）；為了讓每天結算時浴缸的水位維持不變（$\overline{I_{out}} = 0$），每次只要你同時開關水龍頭和排水孔，你就必須故意「讓排水孔多開一陣子」（固定的 Phase Error）來抵銷進水太快的問題。這導致系統看似穩定了，但其實你的開關動作永遠存在一個時間差。

### 面試必考點
1. **問題：Type-IV PFD 是如何解決 Deadzone (死區) 問題的？代價是什麼？** 
   → 答案：藉由在 NAND Gate (Reset 路徑) 中刻意加入 Delay Cell，產生一段固定的 $t_{reset}$ 時間。這確保了即使輸入相位差 $\Delta\phi$ 極小，QA 和 QB 也會「同時為 High」一小段時間，強迫 Charge Pump 的開關完全導通，避免死區造成的 Jitter 累積。代價是這段時間 $I_P$ 和 $I_N$ 同時開啟，若兩者不匹配就會產生 Static Phase Offset 與 Reference Spur。
2. **問題：在頻譜上，Charge Pump 的 Current Mismatch 會造成什麼現象？為什麼？** 
   → 答案：會造成 Reference Spur 變大。因為 Current Mismatch 迫使系統產生 Static Phase Offset，這意味著在每個 Reference 週期，Charge Pump 都會將不成對的電流突波打入 Loop Filter。這會在 $V_{ctrl}$ 上產生週期性的 Ripple，進而對 VCO 產生頻率調變 (FM)，在載波旁產生距離為 $f_{ref}$ 的突波 (Spur)。
3. **問題：在電路設計上，如何改善 Charge Pump 的 Current Mismatch？** 
   → 答案：最經典的做法是採用 Active Charge Pump 架構。利用一個 Rail-to-Rail 的 OP 構成 Unity-gain buffer，將 $V_{ctrl}$ 的電壓複製給 Charge Pump 內部 Current Mirror 的 Drain 端，強迫 Up/Down 電流源的 $V_{ds}$ 保持相等，從而消除 Channel Length Modulation 帶來的電流誤差。或是改用 Fully-Differential (全差動) 的 Charge Pump 架構。

**記憶口訣：**
**死區靠Delay解，電流不配Spur飛，緩衝追壓消誤差。**
---
