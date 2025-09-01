param(
  [string]$OutJson = ".\zerdata_make_manifest.json"
)

function Make-PrettyName([string]$url) {
  # Lấy segment cuối và làm đẹp
  $id = ($url -split '/')[ -1 ]
  $pretty = ($id -replace '[_\-]+',' ' -replace '\s+',' ').Trim()
  $ti = [System.Globalization.CultureInfo]::InvariantCulture.TextInfo
  return $ti.ToTitleCase($pretty.ToLower())
}

function Clean-Name([string]$name) {
  # Bỏ chữ "Hentai Z.Bot" ở cuối, không phân biệt hoa thường
  return ($name -replace '\s*Hentai\s+Z\.Bot$','').Trim()
}

# Nạp JSON cũ nếu có
$items = @()
if (Test-Path -LiteralPath $OutJson) {
  try {
    $loaded = Get-Content -Raw -LiteralPath $OutJson | ConvertFrom-Json
    if ($loaded) { $items = @($loaded) }
  } catch { }
}

Write-Host "ARCHIVE JSON LIVE - Paste tung dong 'Name - URL' hoac URL. Enter rong de dung." -ForegroundColor Cyan
Write-Host "Output: $OutJson"
Write-Host ""

while ($true) {
  $line = Read-Host "Paste 1 line"
  if ([string]::IsNullOrWhiteSpace($line)) { break }

  $line = $line.Trim()
  if ($line -notmatch '(https?://archive\.org/(?:details|embed)/\S+)') {
    Write-Host ">> Khong tim thay URL archive.org hop le trong dong nay." -ForegroundColor Yellow
    continue
  }

  $url = $matches[1]
  $idx = $line.IndexOf($url)
  $name = ""
  if ($idx -gt 0) {
    $name = $line.Substring(0, $idx).Trim(' ','-')
  }
  if (-not $name) { $name = Make-PrettyName $url }

  # Làm sạch tên
  $name = Clean-Name $name

  $obj = [pscustomobject]@{ name = $name; link = $url }
  $items += $obj

  # Ghi ra file ngay sau mỗi lần thêm
  $items | ConvertTo-Json -Depth 4 | Set-Content -Encoding UTF8 -LiteralPath $OutJson
  Write-Host ("+ Added: {0}" -f $name) -ForegroundColor Green
}

$items | ConvertTo-Json -Depth 4 | Set-Content -Encoding UTF8 -LiteralPath $OutJson
Write-Host ("Done -> {0} (total {1} items)" -f $OutJson, $items.Count) -ForegroundColor Cyan