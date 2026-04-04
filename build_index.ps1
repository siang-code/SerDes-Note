# ========================================
# 首頁生成腳本
# 掃描 notes/*.md，依字首分類排序，產生 index.html
# 用法：.\build_index.ps1
# ========================================

$ProjectRoot  = $PSScriptRoot
$NotesDir     = Join-Path $ProjectRoot "notes"
$TemplatePath = Join-Path $ProjectRoot "notes\index_template.html"
$OutputPath   = Join-Path $ProjectRoot "index.html"

# 收集所有筆記 metadata
$notes = @()
Get-ChildItem (Join-Path $NotesDir "*.md") | Where-Object { $_.Name -ne "template.html" } | ForEach-Object {
    $name = $_.BaseName
    $content = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)

    # 抓 H2 作為 intro
    $h2 = [regex]::Match($content, '## (.+)')
    $intro = if ($h2.Success) { $h2.Groups[1].Value.Trim() } else { "" }

    # 抓日期
    $dm = [regex]::Match($content, '分析日期：(\d{4}-\d{2}-\d{2})')
    $date = if ($dm.Success) { $dm.Groups[1].Value } else { "" }

    # 分類前綴（取第一段英文字母，例如 PLL-L1-P1 → PLL）
    $prefix = if ($name -match '^([A-Za-z]+)') { $Matches[1].ToUpper() } else { "OTHER" }

    $notes += @{
        name   = $name
        prefix = $prefix
        date   = $date
        intro  = $intro
        html   = "notes/$name.html"
    }
}

# 依 prefix 排序，再依 L 號（數字）排序
$notes = $notes | Sort-Object { $_.prefix }, {
    if ($_.name -match '-L(\d+)-P(\d+)') {
        [int]$matches[1] * 1000 + [int]$matches[2]
    } else {
        999999
    }
}

# 按 prefix 分群
$groups = [ordered]@{}
foreach ($n in $notes) {
    if (-not $groups.Contains($n.prefix)) { $groups[$n.prefix] = @() }
    $groups[$n.prefix] += $n
}

# 產生 JSON
$groupData = @()
foreach ($key in $groups.Keys) {
    $groupData += @{
        category = $key
        notes    = @($groups[$key] | ForEach-Object {
            @{ name = $_.name; date = $_.date; intro = $_.intro; html = $_.html }
        })
    }
}

$indexJson = $groupData | ConvertTo-Json -Depth 6 -Compress
$templateContent = [System.IO.File]::ReadAllText($TemplatePath, [System.Text.Encoding]::UTF8)
$htmlContent = $templateContent -replace '/\*INJECT_INDEX_DATA\*/', "const INDEX_DATA = $indexJson;"

$utf8 = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($OutputPath, $htmlContent, $utf8)
Write-Host "首頁已生成：index.html（$($notes.Count) 份筆記，$($groups.Count) 個分類）" -ForegroundColor Green
