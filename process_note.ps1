# ========================================
# 課程筆記自動化處理腳本
# 用法：
#   .\process_note.ps1 L1.jpg              # 單張
#   .\process_note.ps1 L1.jpg,L2.jpg       # 多張
#   .\process_note.ps1 -All                # images\ 全部未處理的
#   .\process_note.ps1 -All -Force         # 強制重新處理全部
# ========================================
param(
    [string[]]$ImageFiles,
    [switch]$All,
    [switch]$Force
)

$ProjectRoot    = $PSScriptRoot
$GDriveRoot     = "G:\我的雲端硬碟\SerDes筆記"
$PromptPath     = Join-Path $ProjectRoot "prompts\analyze_note.md"
$TemplatePath   = Join-Path $ProjectRoot "notes\template.html"
$envFile = Join-Path $PSScriptRoot ".env"
Get-Content $envFile | ForEach-Object { if ($_ -match '^(\w+)=(.+)$') { Set-Variable $matches[1] $matches[2] } }
$NotionToken    = $NOTION_TOKEN
$NotionParentId = $NOTION_PARENT_ID

$NotionHeaders = @{
    "Authorization"  = "Bearer $NotionToken"
    "Notion-Version" = "2022-06-28"
    "Content-Type"   = "application/json"
}

# ── 決定要處理哪些圖片 ──────────────────────────────────────
if ($All) {
    $ImageFiles = Get-ChildItem (Join-Path $ProjectRoot "images\*.jpg") |
        Select-Object -ExpandProperty Name
} elseif (-not $ImageFiles) {
    Write-Error "請指定圖片檔名，或使用 -All 處理全部"
    exit 1
}

$total   = $ImageFiles.Count
$done    = 0
$skipped = 0
$failed  = 0

foreach ($ImageFile in $ImageFiles) {

    $ImagePath = Join-Path $ProjectRoot "images\$ImageFile"
    if (-not (Test-Path $ImagePath)) {
        Write-Warning "找不到圖片，跳過：$ImageFile"
        $failed++
        continue
    }

    Write-Host "`n════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host " 處理：$ImageFile" -ForegroundColor White
    Write-Host "════════════════════════════════════" -ForegroundColor DarkGray

    # ── Step 1：識別標題 ────────────────────────────────────
    Write-Host "[1/4] 識別筆記標題..." -ForegroundColor Yellow
    $TitlePrompt = "請只回答這張筆記右上角的標題文字，不要加任何其他說明。格式範例：PLL-L1-P1"
    $RawTitle = & gemini -p "$TitlePrompt @$ImagePath" 2>$null | Out-String
    $titleLines = ($RawTitle -split "`n").Trim() | Where-Object {
        $_ -ne "" -and $_ -match '^[A-Za-z0-9]' -and $_ -notmatch 'node\.exe|NativeCommandError|Attempt \d+ failed'
    }
    $NoteName = if ($titleLines) {
        ($titleLines | Select-Object -Last 1) -replace '[\\/:*?"<>|]', '-'
    } else { "" }

    if (-not $NoteName) {
        $NoteName = [System.IO.Path]::GetFileNameWithoutExtension($ImageFile)
        Write-Host "  無法識別標題，使用原始檔名：$NoteName" -ForegroundColor DarkYellow
    } else {
        Write-Host "  識別標題：$NoteName" -ForegroundColor Green
    }

    # ── 已處理過？跳過 ──────────────────────────────────────
    $OutputPath = Join-Path $ProjectRoot "notes\$NoteName.md"
    if ((Test-Path $OutputPath) -and -not $Force) {
        Write-Host "  ⏭  已存在 notes\$NoteName.md，跳過（用 -Force 強制重跑）" -ForegroundColor DarkYellow
        $skipped++
        continue
    }

    # ── Step 2：重新命名圖片 & Gemini 分析 ─────────────────
    $NewImagePath = Join-Path $ProjectRoot "images\$NoteName.jpg"
    if ($ImagePath -ne $NewImagePath -and -not (Test-Path $NewImagePath)) {
        Move-Item $ImagePath $NewImagePath -Force
        Write-Host "  圖片重新命名：$NoteName.jpg" -ForegroundColor Green
    } else {
        $NewImagePath = $ImagePath
    }

    Write-Host "[2/4] Gemini 分析筆記中..." -ForegroundColor Cyan
    $Prompt = Get-Content $PromptPath -Raw -Encoding UTF8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $Result = & gemini -p "$Prompt @$NewImagePath" 2>$null | Out-String

    $Header = "# $NoteName`n`n> 分析日期：$(Get-Date -Format 'yyyy-MM-dd')`n> 原始圖片：images/$NoteName.jpg`n`n---`n`n"
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($OutputPath, ($Header + $Result), $utf8)
    Write-Host "  MD 筆記已存：notes\$NoteName.md" -ForegroundColor Green

    # ── Step 2.5：生成互動 HTML ─────────────────────────────
    Write-Host "[2.5/4] 生成互動 HTML..." -ForegroundColor Cyan
    $HtmlPath   = Join-Path $ProjectRoot "notes\$NoteName.html"
    $mdContent  = [System.IO.File]::ReadAllText($OutputPath, [System.Text.Encoding]::UTF8)

    function Get-Section($text, $heading) {
        $m = [regex]::Match($text, "### $heading\s*\r?\n([\s\S]*?)(?=\r?\n### |\r?\n## |\*\*記憶|\z)")
        if ($m.Success) { return $m.Groups[1].Value.Trim() } else { return "" }
    }
    function Get-QuizItems($text) {
        $items = [System.Collections.Generic.List[hashtable]]::new()
        $blocks = [regex]::Matches($text, '(?ms)^\d+\.\s+\*\*(.+?)\*\*\s*\r?\n([\s\S]*?)(?=^\d+\.|\*\*記憶|\z)')
        foreach ($b in $blocks) {
            $q = $b.Groups[1].Value -replace '^問題[：:]?\s*', ''
            $aMatch = [regex]::Match($b.Groups[2].Value, '答案[：:]\s*([\s\S]+)')
            $a = if ($aMatch.Success) { $aMatch.Groups[1].Value.Trim() -replace '\*\*$','' } else { $b.Groups[2].Value.Trim() }
            $items.Add(@{ question = $q.Trim(); answer = $a.Trim() })
        }
        return $items
    }

    $h2Match    = [regex]::Match($mdContent, '## (.+)')
    $intro      = if ($h2Match.Success) { $h2Match.Groups[1].Value.Trim() } else { "" }
    $mathSec    = Get-Section $mdContent "數學推導"
    $unitsSec   = Get-Section $mdContent "單位解析"
    $plainSec   = Get-Section $mdContent "白話物理意義"
    $analogySec = Get-Section $mdContent "生活化比喻"
    $quizText   = Get-Section $mdContent "面試必考點"
    $quizItems  = Get-QuizItems $quizText
    $mnMatch    = [regex]::Match($mdContent, '\*\*記憶口訣[：:]\*\*\s*\r?\n([\s\S]+?)(?=\r?\n---|\z)')
    $mnemonic   = if ($mnMatch.Success) { $mnMatch.Groups[1].Value.Trim() } else { "" }

    # 問題延伸（由 ask_note.ps1 附加）
    $qaItems    = [System.Collections.Generic.List[hashtable]]::new()
    $qaMatches  = [regex]::Matches($mdContent, '(?ms)#### Q：(.+?)\r?\n([\s\S]*?)(?=#### Q：|\z)')
    foreach ($m in $qaMatches) {
        $qaItems.Add(@{ question = $m.Groups[1].Value.Trim(); answer = $m.Groups[2].Value.Trim() })
    }

    $sections = @(
        @{ type="intro";    content=$intro }
        @{ type="math";     title="數學推導";     content=$mathSec }
        @{ type="units";    title="單位解析";     content=$unitsSec }
        @{ type="plain";    title="白話物理意義"; content=$plainSec }
        @{ type="analogy";  title="生活化比喻";   content=$analogySec }
        @{ type="quiz";     title="面試必考點";   items=@($quizItems) }
        @{ type="mnemonic"; content=$mnemonic }
    )
    # 只在有 Q&A 時才加入
    if ($qaItems.Count -gt 0) {
        $sections += @{ type="qa"; title="問題延伸"; items=@($qaItems) }
    }
    $noteData = @{
        title    = $NoteName
        date     = (Get-Date -Format 'yyyy-MM-dd')
        imageUrl = "../images/$NoteName.jpg"
        sections = $sections
    }
    $noteDataJson    = $noteData | ConvertTo-Json -Depth 8 -Compress
    $templateContent = [System.IO.File]::ReadAllText($TemplatePath, [System.Text.Encoding]::UTF8)
    $htmlContent     = $templateContent -replace '/\*INJECT_NOTE_DATA\*/', "const NOTE_DATA = $noteDataJson;"
    [System.IO.File]::WriteAllText($HtmlPath, $htmlContent, $utf8)
    Write-Host "  互動 HTML：notes\$NoteName.html" -ForegroundColor Green

    # ── Step 3：同步到 Google Drive ─────────────────────────
    Write-Host "[3/4] 同步到 Google Drive..." -ForegroundColor Magenta
    Copy-Item $NewImagePath (Join-Path $GDriveRoot "images\$NoteName.jpg") -Force
    Copy-Item $OutputPath   (Join-Path $GDriveRoot "notes\$NoteName.md")   -Force
    Copy-Item $HtmlPath     (Join-Path $GDriveRoot "notes\$NoteName.html") -Force
    Write-Host "  已同步 Google Drive" -ForegroundColor Green

    # ── Step 4：上傳 Notion ──────────────────────────────────
    Write-Host "[4/4] 上傳 Notion..." -ForegroundColor Blue

    # 取分類前綴（PLL-L1-P1 → PLL）
    $category = ($NoteName -split '-')[0]

    # 找或建分類子頁面
    $catSearchBody = @{ query = $category; filter = @{ value = "page"; property = "object" } } | ConvertTo-Json
    $catSearchResp = Invoke-RestMethod -Uri "https://api.notion.com/v1/search" -Method POST -Headers $NotionHeaders -Body $catSearchBody
    $catPage = $catSearchResp.results | Where-Object {
        $_.object -eq "page" -and
        ($_.parent.page_id -replace '-','') -eq ($NotionParentId -replace '-','') -and
        $_.properties.title.title[0].plain_text -eq $category
    } | Select-Object -First 1

    if (-not $catPage) {
        $catBody = @{
            parent     = @{ page_id = $NotionParentId }
            properties = @{ title = @{ title = @(@{ text = @{ content = $category } }) } }
        } | ConvertTo-Json -Depth 5
        $catPage = Invoke-RestMethod -Uri "https://api.notion.com/v1/pages" -Method POST -Headers $NotionHeaders -Body $catBody
        Write-Host "  建立分類頁面：$category" -ForegroundColor Cyan
    }
    $categoryPageId = $catPage.id

    # 檢查是否已有同名筆記（避免重複）
    $noteSearchBody = @{ query = $NoteName; filter = @{ value = "page"; property = "object" } } | ConvertTo-Json
    $noteSearchResp = Invoke-RestMethod -Uri "https://api.notion.com/v1/search" -Method POST -Headers $NotionHeaders -Body $noteSearchBody
    $existingPage = $noteSearchResp.results | Where-Object {
        $_.object -eq "page" -and $_.properties.title.title[0].plain_text -eq $NoteName
    } | Select-Object -First 1

    if ($existingPage) {
        Write-Host "  Notion 已有此筆記，跳過：$NoteName" -ForegroundColor DarkYellow
    } else {
        $createBody = @{ filename = "$NoteName.jpg"; content_type = "image/jpeg" } | ConvertTo-Json
        $createResp = Invoke-RestMethod -Uri "https://api.notion.com/v1/file_uploads" -Method POST -Headers $NotionHeaders -Body $createBody
        $uploadId   = $createResp.id
        $uploadUrl  = $createResp.upload_url

        Add-Type -AssemblyName System.Net.Http
        $httpClient  = New-Object System.Net.Http.HttpClient
        $httpClient.DefaultRequestHeaders.Add("Authorization", "Bearer $NotionToken")
        $httpClient.DefaultRequestHeaders.Add("Notion-Version", "2022-06-28")
        $form        = New-Object System.Net.Http.MultipartFormDataContent
        $fileStream  = [System.IO.File]::OpenRead($NewImagePath)
        $fileContent = New-Object System.Net.Http.StreamContent($fileStream)
        $fileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse("image/jpeg")
        $form.Add($fileContent, "file", "$NoteName.jpg")
        $uploadResp  = $httpClient.PostAsync($uploadUrl, $form).Result
        $fileStream.Close()
        $httpClient.Dispose()

        if ($uploadResp.IsSuccessStatusCode) {
            Write-Host "  圖片已上傳 Notion" -ForegroundColor Green
        } else {
            Write-Host "  圖片上傳失敗：$($uploadResp.StatusCode)" -ForegroundColor Red
        }

        $NoteContent = [System.IO.File]::ReadAllText($OutputPath, [System.Text.Encoding]::UTF8)
        $chunks = @(); $pos = 0
        while ($pos -lt $NoteContent.Length) {
            $len = [Math]::Min(2000, $NoteContent.Length - $pos)
            $chunks += $NoteContent.Substring($pos, $len); $pos += $len
        }
        $contentBlocks = $chunks | ForEach-Object {
            @{ type = "paragraph"; paragraph = @{ rich_text = @(@{ text = @{ content = $_ } }) } }
        }
        $pageBlocks = @(
            @{ type = "image"; image = @{ type = "file_upload"; file_upload = @{ id = $uploadId } } }
        ) + $contentBlocks
        $pageBody = @{
            parent     = @{ page_id = $categoryPageId }
            properties = @{ title = @{ title = @(@{ text = @{ content = $NoteName } }) } }
            children   = $pageBlocks
        } | ConvertTo-Json -Depth 10 -Compress
        $pageResp = Invoke-RestMethod -Uri "https://api.notion.com/v1/pages" -Method POST -Headers $NotionHeaders -Body ([System.Text.Encoding]::UTF8.GetBytes($pageBody))
        Write-Host "  Notion 頁面：$($pageResp.url)" -ForegroundColor Green
    }

    Start-Process $HtmlPath
    $done++
}

# ── 重新產生首頁 ────────────────────────────────────────────
if ($done -gt 0) {
    $buildIndex = Join-Path $ProjectRoot "build_index.ps1"
    if (Test-Path $buildIndex) {
        Write-Host "`n更新首頁 index.html..." -ForegroundColor Cyan
        & powershell -File $buildIndex
    }
}

# ── 推上 GitHub ─────────────────────────────────────────────
if ($done -gt 0) {
    Write-Host "`n推上 GitHub..." -ForegroundColor Cyan
    git -C $ProjectRoot add .
    git -C $ProjectRoot commit -m "add notes $(Get-Date -Format 'yyyy-MM-dd')"
    git -C $ProjectRoot push
    Write-Host "  GitHub 已同步" -ForegroundColor Green
}

# ── 最終摘要 ────────────────────────────────────────────────
Write-Host "`n════════════════════════════════════" -ForegroundColor White
Write-Host " 全部完成！" -ForegroundColor Green
Write-Host "  處理：$done　跳過：$skipped　失敗：$failed　共：$total" -ForegroundColor Cyan
Write-Host "════════════════════════════════════`n" -ForegroundColor White
