# Đổi tên toàn bộ file trong C:\BG thành slug.bg.ext
# Ví dụ: "Kanojo Ga Yatsu Ni Idakareta Hi 1.png"
# => "kanojo-ga-yatsu-ni-idakareta-hi-1.bg.png"

$folder = "C:\BG"

# Hàm slugify
function To-Slug($text) {
    $normalized = $text.Normalize([Text.NormalizationForm]::FormD)
    $sb = New-Object Text.StringBuilder
    foreach ($ch in $normalized.ToCharArray()) {
        if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($ch) -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
            $sb.Append($ch) | Out-Null
        }
    }
    $noDiacritics = $sb.ToString()
    $slug = $noDiacritics.ToLower() -replace '[^a-z0-9]+','-'
    $slug = $slug.Trim('-')
    return $slug
}

Get-ChildItem -Path $folder -File | ForEach-Object {
    $ext = $_.Extension.ToLower().TrimStart(".")  # ví dụ jpg/png/webp
    $nameOnly = $_.BaseName                       # tên gốc bỏ đuôi
    $slug = To-Slug $nameOnly

    $newName = "$slug.bg.$ext"
    $newPath = Join-Path $folder $newName

    if ($_.FullName -ne $newPath) {
        Write-Host "Đổi $($_.Name) -> $newName"
        Rename-Item -Path $_.FullName -NewName $newName -Force
    }
}