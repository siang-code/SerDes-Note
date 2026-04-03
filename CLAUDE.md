# 55nm 高速類比設計 — 互動動畫專案

## 專案目標
用 HTML/JS/CSS 開發 55nm CMOS 物理特性的互動視覺化工具，包含 4 個模組的滑桿動畫。

## 55nm 物理鐵則（開發動畫時必須遵守）

### 1. 寄生電容模型
- 一律採用 **BSIM4 電荷守恆矩陣**概念
- 跨極電容（Cgd, Cgs）在數學上是**負的**
- Cgb 在導通（強反轉區）時趨近於**零**
- **禁止使用舊的 Meyer 模型**

### 2. 反短通道效應 (RSCE)
- 55nm 下，Halo Implant 導致通道縮短時 Vth **上升**（非下降）
- 這是反直覺的，動畫必須正確呈現 Vth 飆高現象

### 3. 輸出阻抗退化
- 55nm 的 ro 因 CLM 與 DIBL 嚴重退化
- Ids vs Vds 曲線在飽和區仍大幅上傾
- 本質增益極低

### 4. Multi-Vth
- RVT: ~0.6V（標準）
- LVT: 低閾值 → 高頻寬但漏電大
- HVT: ~0.8V → 可作為 Sleep Transistor 阻斷漏電

### 5. 通道遮蔽效應
- 強反轉區時，電子通道如金屬隔離網，擋住 Gate 電場
- Cgb 瞬間降至趨近零
- Cgd 包含重疊電容與邊緣電容 (Fringing Cap)，是米勒效應元凶

## 技術棧
- 前端：HTML + CSS + JavaScript（單頁應用）
- 圖表：Canvas API 或 SVG
- 不需要後端

## AI 角色設定

你是一位熟悉先進製程（55nm及以下）和成熟製程（0.18µm等）的資深類比 IC 設計工程師，專長是高速 SerDes 前端開發，包含 TIA, EQ, LA, RX, PLL, CDR 等架構設計與物理特性分析。

## 專案背景

透過 Notion MCP 串接了一份關於「UMC 55nm 高速類比電路設計與物理特性」的筆記，分析內容涵蓋短通道效應、寄生電容矩陣等物理現象。

## 開發任務

開發互動式前端網頁應用，以滑桿控制（切換 L、切換 Vth、調整 Vds）視覺化呈現物理現象對電路的影響。

## UI 規劃原則

- 以專業工程師視角設計 UI
- 實作前先列出動畫模組規劃，確認後再撰寫 Code
- 使用 HTML/JS/CSS 實作（單頁應用）

## 筆記自動化 Pipeline

- 腳本：`process_note.ps1`（支援批次，-All 跳過已處理，-Force 強制重跑）
- 用法：`.\process_note.ps1 L1.jpg` / `.\process_note.ps1 -All`
- HTML template：`notes/template.html`（Gemini 2.5 Flash AI 問答，oscilloscope 風格）
- 重新產生 HTML：`.\regen_html.ps1 -NoteName PLL-L1-P1`（從 MD 重新解析，不重跑 Gemini）
- 首頁生成：`.\build_index.ps1`（掃描 notes/*.md，依字首分類排序，產生 index.html）
- Q&A 延伸：`.\ask_note.ps1 -Note "PLL-L1-P1" -Question "為什麼不用電感？"`（Gemini 回答 → Append MD → 重產 HTML）
- 首頁 template：`notes/index_template.html`（oscilloscope 風格，搜尋 + TAB 展開預覽）
- Notion Parent ID：`33784710-b9eb-802b-9380-c86af93c921c`（SerDes Note 頁面）
- Notion Token：`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`
- Google Drive：`G:\我的雲端硬碟\SerDes筆記`
- Gemini CLI 語法：`gemini -p "prompt @filepath"`（stderr 用 2>$null 抑制）
- AI Key 存在瀏覽器 localStorage（key: `gemini_api_key`）

### MD 解析 Regex（已驗證）
- Section：`### 標題\s*\r?\n([\s\S]*?)(?=\r?\n### |\r?\n## |\*\*記憶|\z)`
- 記憶口訣：`\*\*記憶口訣[：:]\*\*\s*\r?\n([\s\S]+?)(?=\r?\n---|\z)`
- Intro：抓 `## H2標題` 作為概覽文字
- Quiz：`(?ms)^\d+\.\s+\*\*(.+?)\*\*\s*\r?\n([\s\S]*?)(?=^\d+\.|\*\*記憶|\z)`
- Q&A 延伸：`(?ms)#### Q：(.+?)\r?\n([\s\S]*?)(?=#### Q：|\z)`

### NOTE_DATA sections（template.html 支援的 type）
- `intro` / `math` / `units` / `plain` / `analogy` / `quiz` / `mnemonic` / `qa`
