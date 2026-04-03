# ========================================
# 筆記問題延伸腳本
# 用法：.\ask_note.ps1 -Note "PLL-L1-P1" -Question "為什麼這裡不用電感？"
# 流程：讀 MD context → 送 Gemini → Append 到 MD → 重新產生 HTML
# ========================================
param(
    [Parameter(Mandatory=$true)]
    [string]$Note,

    [Parameter(Mandatory=$true)]
    [string]$Question
)

$ProjectRoot = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
$MdPath      = Join-Path $ProjectRoot "notes\$Note.md"

Write-Host "DEBUG MdPath: $MdPath" -ForegroundColor Yellow
Write-Host "DEBUG exists: $(Test-Path $MdPath)" -ForegroundColor Yellow
if (-not (Test-Path $MdPath)) {
    Write-Error "找不到筆記：$MdPath"
    exit 1
}

Write-Host "`n[1/3] 讀取筆記 context..." -ForegroundColor Yellow
$mdContent = [System.IO.File]::ReadAllText($MdPath, [System.Text.Encoding]::UTF8)

Write-Host "[2/3] Gemini 回答中..." -ForegroundColor Cyan
$prompt = @"
你是一位熟悉先進製程（55nm及以下）和成熟製程（0.18µm等）的資深類比 IC 設計工程師。
以下是學生的筆記內容，請根據這份筆記的 context 回答學生的問題。

【筆記內容】
$mdContent

【學生問題】
$Question

請用繁體中文回答，精準且言簡意賅。包含：
1. 直接回答問題
2. 補充相關的物理意義或電路設計考量
3. 如果跟面試有關，額外補充面試官可能會追問的方向
"@

$tmpPrompt = Join-Path $ProjectRoot "ask_note_prompt.txt"
[System.IO.File]::WriteAllText($tmpPrompt, $prompt, [System.Text.Encoding]::UTF8)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$answer = & gemini -p "@$tmpPrompt" 2>$null | Out-String

if (-not $answer.Trim()) {
    Write-Error "Gemini 回答為空"
    exit 1
}

Write-Host "[3/3] 寫入筆記..." -ForegroundColor Green

# 檢查是否已有「問題延伸」section
$hasQASection = $mdContent -match '### 問題延伸'

$appendText = ""
if (-not $hasQASection) {
    $appendText += "`n`n### 問題延伸`n"
}

$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm'
$appendText += "`n#### Q：$Question`n> 提問時間：$timestamp`n`n$($answer.Trim())`n"

$utf8 = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::AppendAllText($MdPath, $appendText, $utf8)
Write-Host "  已附加到 notes\$Note.md" -ForegroundColor Green

# 重新產生 HTML
Write-Host "  重新產生 HTML..." -ForegroundColor Cyan
& powershell -File (Join-Path $ProjectRoot "regen_html.ps1") -NoteName $Note

# 重新產生首頁
$buildIndex = Join-Path $ProjectRoot "build_index.ps1"
if (Test-Path $buildIndex) {
    & powershell -File $buildIndex
}

# 同步 Q&A 到 Notion
$envFile = Join-Path $ProjectRoot ".env"
Get-Content $envFile | ForEach-Object { if ($_ -match '^(\w+)=(.+)$') { Set-Variable $matches[1] $matches[2] } }
$NotionToken   = $NOTION_TOKEN
$NotionHeaders = @{
    "Authorization"  = "Bearer $NotionToken"
    "Notion-Version" = "2022-06-28"
    "Content-Type"   = "application/json"
}
Write-Host "  同步 Q&A 到 Notion..." -ForegroundColor Cyan
$searchBody = @{ query = $Note; filter = @{ value = "page"; property = "object" } } | ConvertTo-Json
$searchResp = Invoke-RestMethod -Uri "https://api.notion.com/v1/search" -Method POST -Headers $NotionHeaders -Body $searchBody
$notionPage = $searchResp.results | Where-Object {
    $_.object -eq "page" -and $_.properties.title.title[0].plain_text -eq $Note
} | Select-Object -First 1

if ($notionPage) {
    $qaBlocks = @(
        @{ type = "heading_3"; heading_3 = @{ rich_text = @(@{ text = @{ content = "Q：$Question" } }) } }
        @{ type = "paragraph"; paragraph = @{ rich_text = @(@{ text = @{ content = $answer.Trim() } }) } }
    )
    $patchBody = @{ children = $qaBlocks } | ConvertTo-Json -Depth 6
    Invoke-RestMethod -Uri "https://api.notion.com/v1/blocks/$($notionPage.id)/children" -Method PATCH -Headers $NotionHeaders -Body $patchBody | Out-Null
    Write-Host "  Notion 已更新" -ForegroundColor Green
} else {
    Write-Host "  找不到對應 Notion 頁面，跳過同步" -ForegroundColor DarkYellow
}

# 推上 GitHub
Write-Host "  推上 GitHub..." -ForegroundColor Cyan
git -C $ProjectRoot add .
git -C $ProjectRoot commit -m "qa: $Note - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git -C $ProjectRoot push
Write-Host "  GitHub 已同步" -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor White
Write-Host " 完成！" -ForegroundColor Green
Write-Host "  問題：$Question"
Write-Host "  筆記：notes\$Note.md"
Write-Host "  HTML：notes\$Note.html"
Write-Host "========================================`n" -ForegroundColor White
