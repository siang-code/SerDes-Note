param(
    [string]$NoteName = "",
    [switch]$All
)

$ProjectRoot = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
$NotesDir    = Join-Path $ProjectRoot "notes"
$ImagesDir   = Join-Path $ProjectRoot "images"
$PdfDir      = Join-Path $ProjectRoot "pdf"
$TmpDir      = Join-Path $ProjectRoot "pdf_tmp"

New-Item -ItemType Directory -Path $PdfDir -Force | Out-Null
New-Item -ItemType Directory -Path $TmpDir -Force | Out-Null

$BrowserPaths = @(
    "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    "C:\Program Files\Microsoft\Edge\Application\msedge.exe",
    "C:\Program Files\Google\Chrome\Application\chrome.exe",
    "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
)
$Browser = $BrowserPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $Browser) {
    Write-Error "Edge/Chrome not found"
    exit 1
}
Write-Host "Browser: $Browser" -ForegroundColor Cyan

if ($All) {
    $MdFiles = Get-ChildItem -Path $NotesDir -Filter "*.md" |
               Where-Object { $_.Name -notlike "03ddf*" }
} elseif ($NoteName) {
    $MdFiles = @(Get-Item (Join-Path $NotesDir "$NoteName.md") -ErrorAction SilentlyContinue)
    if (-not $MdFiles) {
        Write-Error "Not found: notes\$NoteName.md"
        exit 1
    }
} else {
    Write-Error "Usage: .\export_pdf.ps1 -NoteName PLL-L1-P1  OR  -All"
    exit 1
}

$Total   = $MdFiles.Count
$Success = 0

foreach ($MdFile in $MdFiles) {
    $BaseName  = $MdFile.BaseName
    $PdfPath   = Join-Path $PdfDir "$BaseName.pdf"
    $TmpHtml   = Join-Path $TmpDir "$BaseName.html"
    $ImgPath   = Join-Path $ImagesDir "$BaseName.jpg"
    if (-not (Test-Path $ImgPath)) {
        $ImgPath = Join-Path $ImagesDir "done\$BaseName.jpg"
    }

    Write-Host "[$($Success+1)/$Total] $BaseName ..." -ForegroundColor Yellow

    # Read MD content
    $mdText = [System.IO.File]::ReadAllText($MdFile.FullName, [System.Text.Encoding]::UTF8)

    # Embed image as base64 if exists
    $imgTag = ""
    if (Test-Path $ImgPath) {
        $imgBytes  = [System.IO.File]::ReadAllBytes($ImgPath)
        $imgBase64 = [Convert]::ToBase64String($imgBytes)
        $imgTag    = "<img src='data:image/jpeg;base64,$imgBase64' style='max-width:100%;margin-bottom:24px;'>"
    }

    # Escape MD text for HTML first
    $htmlText = $mdText `
        -replace '&', '&amp;' `
        -replace '<', '&lt;' `
        -replace '>', '&gt;' `
        -replace "`n", '<br>'

    # Then convert inline markdown images ![alt](path) to base64 <img>
    $htmlText = [regex]::Replace($htmlText, '!\[([^\]]*)\]\(([^)]+)\)', {
        param($m)
        $altText  = $m.Groups[1].Value
        $imgSrc   = $m.Groups[2].Value
        $absPath  = [System.IO.Path]::GetFullPath((Join-Path $NotesDir $imgSrc))
        if (Test-Path $absPath) {
            $bytes  = [System.IO.File]::ReadAllBytes($absPath)
            $b64    = [Convert]::ToBase64String($bytes)
            $ext    = [System.IO.Path]::GetExtension($absPath).TrimStart('.').ToLower()
            if ($ext -eq 'jpg') { $ext = 'jpeg' }
            return "<img src='data:image/$ext;base64,$b64' alt='$altText' style='max-width:100%;margin:8px 0;border:1px solid #ccc;'>"
        }
        return $m.Value
    })

    # Build simple print-friendly HTML
    $html = @"
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
  body { font-family: Arial, sans-serif; font-size: 13px; line-height: 1.6; padding: 32px; color: #111; background: #fff; }
  img  { border: 1px solid #ccc; }
  pre  { background: #f5f5f5; padding: 12px; white-space: pre-wrap; word-break: break-word; }
  h1   { font-size: 18px; border-bottom: 2px solid #333; padding-bottom: 6px; }
</style>
</head>
<body>
<h1>$BaseName</h1>
$imgTag
<pre>$htmlText</pre>
</body>
</html>
"@

    [System.IO.File]::WriteAllText($TmpHtml, $html, [System.Text.Encoding]::UTF8)

    $proc = Start-Process -FilePath $Browser -ArgumentList @(
        "--headless",
        "--disable-gpu",
        "--no-sandbox",
        "--allow-file-access-from-files",
        "--run-all-compositor-stages-before-draw",
        "--print-to-pdf=`"$PdfPath`"",
        "--print-to-pdf-no-header",
        "`"$TmpHtml`""
    ) -Wait -PassThru -NoNewWindow

    if (Test-Path $PdfPath) {
        Write-Host "  OK -> pdf\$BaseName.pdf" -ForegroundColor Green
        $Success++
    } else {
        Write-Host "  FAILED (exit: $($proc.ExitCode))" -ForegroundColor Red
    }
}

# Cleanup tmp
Remove-Item -Path $TmpDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Done: $Success / $Total" -ForegroundColor White
Write-Host "Output: $PdfDir" -ForegroundColor White
