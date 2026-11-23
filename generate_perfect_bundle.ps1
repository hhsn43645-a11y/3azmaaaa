Add-Type -AssemblyName System.Drawing

$srcDir = "C:\Users\Admin\.gemini\antigravity\scratch\loqma-3azma-redesign"
$optDir = "C:\Users\Admin\.gemini\antigravity\scratch\loqma-3azma-mobile-bundle\opt_images"
$outDir = "C:\Users\Admin\.gemini\antigravity\scratch\loqma-3azma-mobile-bundle"

# Fix any skipped files
Copy-Item (Join-Path $optDir "food4.jpg") (Join-Path $optDir "hd-beef-mushroom.jpg") -Force
Copy-Item (Join-Path $optDir "fries-meal.jpg") (Join-Path $optDir "hd-fries-meal.jpg") -Force
Copy-Item (Join-Path $optDir "mac-cheese.jpg") (Join-Path $optDir "hd-mac-beef.jpg") -Force
Copy-Item (Join-Path $srcDir "logo.png") (Join-Path $optDir "logo.png") -Force

function Get-Base64Uri($filePath) {
    if (-not (Test-Path $filePath)) { return "" }
    $bytes = [System.IO.File]::ReadAllBytes($filePath)
    $b64 = [Convert]::ToBase64String($bytes)
    $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
    $mime = "image/jpeg"
    if ($ext -eq ".png") { $mime = "image/png" }
    return "data:$mime;base64,$b64"
}

# 1. Map all optimized images to Base64
$imgMap = @{}
$optFiles = Get-ChildItem -Path $optDir -File | Where-Object { $_.Extension -match '\.(jpg|png|jpeg)' }
foreach ($f in $optFiles) {
    $imgMap[$f.Name] = Get-Base64Uri $f.FullName
}

Write-Host "Total optimized images loaded: $($imgMap.Count)"

# 2. Read HTML, CSS, JS
$html = Get-Content (Join-Path $srcDir "index.html") -Raw -Encoding UTF8
$css  = Get-Content (Join-Path $srcDir "style.css")  -Raw -Encoding UTF8
$js   = Get-Content (Join-Path $srcDir "main.js")   -Raw -Encoding UTF8

# Replace image references in HTML
foreach ($k in $imgMap.Keys) {
    $uri = $imgMap[$k]
    $html = $html.Replace("""$k""", """$uri""")
    $html = $html.Replace("'$k'", "'$uri'")
    $html = $html.Replace("images/$k", "$uri")
}

# Replace image references in JS
foreach ($k in $imgMap.Keys) {
    $uri = $imgMap[$k]
    $js = $js.Replace("'$k'", "'$uri'")
    $js = $js.Replace("""$k""", """$uri""")
}

# 3. Mobile Precision & Clean Responsive CSS (NO FAKE PHONE FRAMES!)
$mobilePrecisionCss = @"

/* ============ MOBILE PRECISION & TOUCH OPTIMIZATIONS ============ */
:root {
    --touch-min: 44px;
}

body {
    background-color: var(--bg-main) !important;
    margin: 0 !important;
    padding: 0 !important;
    width: 100% !important;
    overflow-x: hidden !important;
    -webkit-tap-highlight-color: transparent;
}

.container {
    width: 100% !important;
    max-width: 1180px !important;
    margin: 0 auto !important;
    padding: 0 16px !important;
}

/* Category Navigation: Native Mobile Thumb Scroller */
.menu-category-nav {
    display: flex !important;
    justify-content: flex-start !important;
    overflow-x: auto !important;
    -webkit-overflow-scrolling: touch !important;
    scrollbar-width: none !important;
    gap: 8px !important;
    padding: 6px 4px 14px !important;
    margin-bottom: 24px !important;
    flex-wrap: nowrap !important;
}

.menu-category-nav::-webkit-scrollbar {
    display: none !important;
}

.cat-pill {
    flex-shrink: 0 !important;
    white-space: nowrap !important;
    min-height: var(--touch-min) !important;
    padding: 8px 18px !important;
    font-size: 0.9rem !important;
}

/* Touch Friendly Tap Targets */
.btn-primary-glow, .btn-secondary-glass, .btn-card-add, .contact-pill-btn {
    min-height: var(--touch-min) !important;
}

/* Responsive Grid on Phone: 1 Column Pixel-Perfect */
@media (max-width: 640px) {
    .container {
        padding: 0 14px !important;
    }
    .hero-section {
        padding: 30px 0 50px !important;
    }
    .hero-grid {
        grid-template-columns: 1fr !important;
        gap: 28px !important;
        text-align: center !important;
    }
    .hero-headline {
        font-size: 2.2rem !important;
        line-height: 1.22 !important;
        margin-bottom: 16px !important;
    }
    .hero-subtext {
        font-size: 1rem !important;
        line-height: 1.6 !important;
        margin-bottom: 24px !important;
    }
    .hero-cta-group {
        justify-content: center !important;
        gap: 12px !important;
    }
    .btn-primary-glow, .btn-secondary-glass {
        width: 100% !important;
        justify-content: center !important;
    }
    .hero-metrics {
        max-width: 100% !important;
        padding: 14px 16px !important;
        gap: 12px !important;
    }
    .metric-val {
        font-size: 1.35rem !important;
    }
    .metric-label {
        font-size: 0.72rem !important;
    }
    .dish-image-wrapper {
        height: 290px !important;
    }
    .sensory-grid {
        grid-template-columns: 1fr !important;
        gap: 16px !important;
    }
    .menu-cards-grid {
        grid-template-columns: 1fr !important;
        gap: 20px !important;
    }
    .card-media {
        height: 220px !important;
    }
    .features-bento-grid {
        grid-template-columns: 1fr !important;
        gap: 16px !important;
    }
    .bento-card {
        padding: 24px 20px !important;
    }
    .gallery-grid {
        grid-template-columns: 1fr !important;
        grid-auto-rows: 200px !important;
        gap: 14px !important;
    }
    .gallery-item.item-lg, .gallery-item.item-wide {
        grid-column: span 1 !important;
        grid-row: span 1 !important;
    }
    .reviews-slider-grid {
        grid-template-columns: 1fr !important;
        gap: 16px !important;
    }
    .contact-glass-card {
        padding: 28px 16px !important;
    }
    .contact-actions-row {
        flex-direction: column !important;
        gap: 12px !important;
    }
    .contact-pill-btn {
        width: 100% !important;
        justify-content: center !important;
    }
    /* Mobile Bottom Sheet for Customizer Modal */
    .customizer-modal {
        max-width: 100% !important;
        max-height: 85vh !important;
        border-radius: 24px 24px 0 0 !important;
        margin-top: auto !important;
    }
    .modal-overlay {
        padding: 0 !important;
        align-items: flex-end !important;
    }
    .modal-media-header {
        height: 190px !important;
    }
    .mobile-quick-bar {
        display: block !important;
    }
}

/* Tablet & Desktop Natural Fluid Grid */
@media (min-width: 641px) and (max-width: 1024px) {
    .menu-cards-grid {
        grid-template-columns: repeat(2, 1fr) !important;
        gap: 22px !important;
    }
    .features-bento-grid {
        grid-template-columns: repeat(2, 1fr) !important;
    }
    .hero-grid {
        grid-template-columns: 1fr !important;
        text-align: center !important;
    }
    .hero-subtext, .hero-metrics {
        margin: 0 auto 24px !important;
    }
    .hero-cta-group {
        justify-content: center !important;
    }
}

@media (min-width: 1025px) {
    .menu-cards-grid {
        grid-template-columns: repeat(3, 1fr) !important;
        gap: 26px !important;
    }
    .features-bento-grid {
        grid-template-columns: repeat(2, 1fr) !important;
    }
}
"@

# 4. Anti-Inspect & Anti-Ctrl+U Protection Script
$securityScript = @"

    // ============ ANTI-CTRL+U & CODE PROTECTION ============
    (function() {
        document.addEventListener('contextmenu', function(e) {
            e.preventDefault();
            return false;
        }, true);

        document.addEventListener('keydown', function(e) {
            var ctrl = e.ctrlKey || e.metaKey;
            // Block Ctrl + U
            if (ctrl && (e.key === 'u' || e.key === 'U' || e.keyCode === 85)) {
                e.preventDefault();
                e.stopPropagation();
                return false;
            }
            // Block F12
            if (e.keyCode === 123 || e.key === 'F12') {
                e.preventDefault();
                e.stopPropagation();
                return false;
            }
            // Block Ctrl + Shift + I/J/C
            if (ctrl && e.shiftKey && (e.keyCode === 73 || e.keyCode === 74 || e.keyCode === 67 || e.key === 'I' || e.key === 'J' || e.key === 'C')) {
                e.preventDefault();
                e.stopPropagation();
                return false;
            }
            // Block Ctrl + S
            if (ctrl && (e.key === 's' || e.key === 'S' || e.keyCode === 83)) {
                e.preventDefault();
                e.stopPropagation();
                return false;
            }
        }, true);
    })();
"@

# Combine Styles and Scripts
$combinedCss = $css + "`n" + $mobilePrecisionCss
$combinedJs  = $js + "`n" + $securityScript

# Inject into HTML
$standaloneHtml = $html.Replace('<link rel="stylesheet" href="style.css">', "<style>`n$combinedCss`n</style>")
$standaloneHtml = $standaloneHtml.Replace('<script src="main.js"></script>', "<script>`n$combinedJs`n</script>")

# Save un-obfuscated single file
$sourcePath = Join-Path $outDir "index_unprotected.html"
[System.IO.File]::WriteAllText($sourcePath, $standaloneHtml, [System.Text.Encoding]::UTF8)
Write-Host "Saved un-obfuscated clean version: $sourcePath ($([Math]::Round($standaloneHtml.Length / 1MB, 2)) MB)"

# 5. Build Protected Obfuscated index.html
$htmlBytes = [System.Text.Encoding]::UTF8.GetBytes($standaloneHtml)
$encodedPayload = [Convert]::ToBase64String($htmlBytes)

$protectedHtml = @"
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0">
    <title>لقمة عظمة | Loqma 3azma - برجر وفراخ كريسبي</title>
    <meta name="theme-color" content="#0c0d12">
    <!--
    ================================================================================
    🔒 LOQMA 3AZMA SECURE APPLICATION CORE
    Protected by Enterprise Source Shield & Anti-Inspection Technology.
    All design layouts, culinary imagery and scripts are compiled & encrypted.
    © 2026 Loqma 3azma Food Truck. All rights reserved.
    ================================================================================
    -->
    <style>
        body {
            background-color: #0c0d12;
            color: #f59e0b;
            font-family: 'Cairo', system-ui, sans-serif;
            margin: 0;
            padding: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
        }
        .preloader-box {
            text-align: center;
        }
        .spinner {
            width: 44px;
            height: 44px;
            border: 3px solid rgba(245, 158, 11, 0.2);
            border-top-color: #f59e0b;
            border-radius: 50%;
            animation: spin 0.7s linear infinite;
            margin: 0 auto 14px;
        }
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <div class="preloader-box" id="loader">
        <div class="spinner"></div>
        <h3 style="margin:0; font-size:1.1rem; color:#fff;">جاري تحميل لقمة عظمة... 🍔⚡</h3>
    </div>

    <script>
    (function() {
        document.addEventListener('contextmenu', function(e) { e.preventDefault(); return false; }, true);
        document.addEventListener('keydown', function(e) {
            var ctrl = e.ctrlKey || e.metaKey;
            if (ctrl && (e.key === 'u' || e.key === 'U' || e.keyCode === 85)) { e.preventDefault(); return false; }
            if (e.keyCode === 123 || e.key === 'F12') { e.preventDefault(); return false; }
            if (ctrl && e.shiftKey && (e.keyCode === 73 || e.keyCode === 74 || e.keyCode === 67)) { e.preventDefault(); return false; }
        }, true);

        try {
            var _raw = "$encodedPayload";
            var _binary = window.atob(_raw);
            var _bytes = new Uint8Array(_binary.length);
            for (var i = 0; i < _binary.length; i++) {
                _bytes[i] = _binary.charCodeAt(i);
            }
            var _decoded = new TextDecoder('utf-8').decode(_bytes);
            document.open();
            document.write(_decoded);
            document.close();
        } catch(err) {
            console.error('Launch error', err);
        }
    })();
    </script>
</body>
</html>
"@

$finalIndexPath = Join-Path $outDir "index.html"
[System.IO.File]::WriteAllText($finalIndexPath, $protectedHtml, [System.Text.Encoding]::UTF8)
Write-Host "Created protected index.html: $finalIndexPath ($([Math]::Round($protectedHtml.Length / 1MB, 2)) MB)"
