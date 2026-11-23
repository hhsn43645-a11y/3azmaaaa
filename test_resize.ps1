Add-Type -AssemblyName System.Drawing

function Resize-Image($srcPath, $dstPath, $maxWidth, $quality) {
    $img = [System.Drawing.Image]::FromFile($srcPath)
    $origW = $img.Width
    $origH = $img.Height
    
    if ($origW -gt $maxWidth) {
        $newW = $maxWidth
        $newH = [int]($origH * ($maxWidth / $origW))
    } else {
        $newW = $origW
        $newH = $origH
    }
    
    $newImg = New-Object System.Drawing.Bitmap $newW, $newH
    $graphics = [System.Drawing.Graphics]::FromImage($newImg)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.DrawImage($img, 0, 0, $newW, $newH)
    
    $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
    $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters 1
    $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality, [long]$quality)
    
    $newImg.Save($dstPath, $codec, $encoderParams)
    
    $graphics.Dispose()
    $newImg.Dispose()
    $img.Dispose()
}

$srcDir = "C:\Users\Admin\.gemini\antigravity\scratch\loqma-3azma-redesign"
$optDir = "C:\Users\Admin\.gemini\antigravity\scratch\loqma-3azma-mobile-bundle\opt_images"
New-Item -ItemType Directory -Force -Path $optDir | Out-Null

$imgs = Get-ChildItem -Path $srcDir -File | Where-Object { $_.Extension -match '\.(jpg|jpeg)' }
foreach ($i in $imgs) {
    $dst = Join-Path $optDir $i.Name
    try {
        Resize-Image $i.FullName $dst 450 72
        $origKb = [Math]::Round($i.Length / 1KB)
        $newKb = [Math]::Round((Get-Item $dst).Length / 1KB)
        Write-Host "$($i.Name): $origKb KB -> $newKb KB"
    } catch {
        Write-Host "Skip $($i.Name)"
    }
}
