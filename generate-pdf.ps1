$originalPath = "C:\Users\User\Downloads\Tesina\tesinaGiovanni\index.html"
$outputPath = "C:\Users\User\Downloads\Tesina\tesinaGiovanni\output-print.html"
$pdfPath = "C:\Users\User\Downloads\Tesina\tesinaGiovanni\Tesina.pdf"
$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"

Write-Host "Reading original HTML..." -ForegroundColor Cyan
$html = Get-Content -Path $originalPath -Raw -Encoding UTF8

Write-Host "Injecting CSS overrides for PDF print layout..." -ForegroundColor Cyan

$cssOverride = @'
<style id="print-override">
  @page { margin: 12mm 15mm; size: A4; }
  html, body { overflow: visible !important; height: auto !important; background: rgba(252, 233, 215, 1) !important; background-image: none !important; }
  body { background-attachment: scroll !important; }
  main { display: block !important; width: auto !important; height: auto !important; overflow: visible !important; }
  .sezione { width: auto !important; height: auto !important; min-height: 0 !important; flex: none !important; overflow: visible !important; page-break-after: always !important; break-after: page !important; justify-content: flex-start !important; background: rgba(252, 233, 215, 1) !important; }
  .modal { display: block !important; position: relative !important; opacity: 1 !important; visibility: visible !important; pointer-events: auto !important; inset: auto !important; z-index: auto !important; padding: 28px max(20px, calc((100vw - 1100px) / 2 + 20px)) !important; align-items: normal !important; justify-content: normal !important; transition: none !important; page-break-after: always !important; break-after: page !important; background: rgba(252, 233, 215, 1) !important; }
  .modal-sfondo { display: none !important; }
  .modal-box { max-height: none !important; position: relative !important; z-index: auto !important; overflow: visible !important; opacity: 1 !important; transform: none !important; transition: none !important; background: rgba(252, 233, 215, 1) !important; }
  .chiudi-modal { display: none !important; }
  .navigazione-laterale, .navigazione-freccia:not(.nodo-mappa), .qr-code { display: none !important; }
  .scheda-copertina { position: static !important; }
  .scheda-copertina--destra { text-align: left !important; right: auto !important; }
  #introduzione.sezione { padding-bottom: 48px !important; }
  @supports (height: 100dvh) { html, body, main, .sezione { height: auto !important; min-height: 0 !important; } }
  .etichetta-modal { margin: 0 0 14px 0 !important; }
  /* Nascondi la mappa concettuale SVG */
  #mappa .mappa, #mappa .legenda-mappa, #mappa .navigazione-freccia { display: none !important; }
  /* Stili per l'indice degli argomenti */
  .contenuto-con-immagine { background: transparent !important; }
  .grafico-modale { background: transparent !important; border: 1px solid #ddd8d0 !important; }
  .indice-pdf { max-width: 700px; margin: 40px auto; padding: 0 20px; font-family: 'Georgia', 'Times New Roman', serif; }
  .indice-pdf h2 { font-size: 1.6rem; color: #1a3a5c; text-align: center; margin-bottom: 30px; border-bottom: 2px solid #1a3a5c; padding-bottom: 10px; }
  .indice-pdf ul { list-style: none; padding: 0; margin: 0; columns: 2; column-gap: 30px; }
  .indice-pdf li { margin-bottom: 10px; break-inside: avoid; }
  .indice-pdf a { display: flex; justify-content: space-between; align-items: center; padding: 10px 14px; background: #f8f7f5; border-radius: 4px; border: 1px solid #ddd8d0; text-decoration: none; color: #2c2a28; font-size: 1rem; transition: background 0.2s; }
  .indice-pdf a:hover { background: #edeae4; }
  .indice-pdf .num { font-weight: 700; color: #1a3a5c; font-size: 0.85rem; }
</style>
'@

# Inietta anche un indice testuale dentro la sezione mappa
$indiceHtml = @'
<div class="indice-pdf">
  <h2>Indice degli argomenti</h2>
  <ul>
    <li><a><span>Storia - La crisi del 1929 e il New Deal</span><span class="num">p. 3</span></a></li>
    <li><a><span>Geografia - Gli Stati Uniti e la Silicon Valley</span><span class="num">p. 4</span></a></li>
    <li><a><span>Italiano - Pirandello e l'io individuale</span><span class="num">p. 5</span></a></li>
    <li><a><span>Scienze - Plutone e l'esplorazione spaziale</span><span class="num">p. 6</span></a></li>
    <li><a><span>Inglese - The Marshall Plan</span><span class="num">p. 7</span></a></li>
    <li><a><span>Spagnolo - La Guerra Civil Espanola</span><span class="num">p. 8</span></a></li>
    <li><a><span>Tecnologia - L'evoluzione del petrolio</span><span class="num">p. 9</span></a></li>
    <li><a><span>Arte - Tano Festa e la Pop Art</span><span class="num">p. 10</span></a></li>
    <li><a><span>Educazione fisica - Olimpiadi di Los Angeles 1932</span><span class="num">p. 11</span></a></li>
    <li><a><span>Educazione civica - L'educazione finanziaria</span><span class="num">p. 12</span></a></li>
    <li><a><span>Latino - La societa romana</span><span class="num">p. 13</span></a></li>
    <li><a><span>Religione - La Quadragesimo Anno</span><span class="num">p. 14</span></a></li>
  </ul>
</div>
'@

$html = $html -replace '</style>', "</style>`n$cssOverride"

Write-Host "Injecting text index into mappa section..." -ForegroundColor Cyan
$mappaPattern = [regex]::new('(<section id="mappa" class="sezione[^>]*>)(.*?)(</section>)', [System.Text.RegularExpressions.RegexOptions]::Singleline)
$html = $mappaPattern.Replace($html, "`$1`n$indiceHtml`n`$3", 1)

Write-Host "Reordering: placing Conclusione before Riferimenti..." -ForegroundColor Cyan
$pattern = [regex]::new('(<div id="modal-riferimenti" class="modal">.*?</div>\s*</div>\s*)(\s*<section id="conclusione[^>]*>)', [System.Text.RegularExpressions.RegexOptions]::Singleline)
$html = $pattern.Replace($html, '${2}${1}')

Write-Host "Writing modified HTML to $outputPath..." -ForegroundColor Cyan
[System.IO.File]::WriteAllText($outputPath, $html, [System.Text.Encoding]::UTF8)

Write-Host "Generating PDF with Chrome DevTools Protocol..." -ForegroundColor Cyan
$tempUserData = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "chrome-pdf-" + [System.IO.Path]::GetRandomFileName())
$port = Get-Random -Minimum 40000 -Maximum 49999
$fileUrl = "file:///$($outputPath.Replace('\', '/'))"
$chromeArgs = @(
    "--headless",
    "--disable-gpu",
    "--remote-debugging-port=$port",
    "--user-data-dir=$tempUserData",
    $fileUrl
)
Write-Host "Running: $chromePath $chromeArgs" -ForegroundColor Gray
$proc = Start-Process -FilePath $chromePath -ArgumentList $chromeArgs -WindowStyle Hidden -PassThru

function Invoke-CdpCommand {
    param (
        [System.Net.WebSockets.ClientWebSocket]$Socket,
        [int]$Id,
        [string]$Method,
        [hashtable]$Params = @{}
    )

    $payload = @{
        id = $Id
        method = $Method
        params = $Params
    } | ConvertTo-Json -Depth 20 -Compress

    $sendBytes = [System.Text.Encoding]::UTF8.GetBytes($payload)
    $Socket.SendAsync(
        [System.ArraySegment[byte]]::new($sendBytes),
        [System.Net.WebSockets.WebSocketMessageType]::Text,
        $true,
        [Threading.CancellationToken]::None
    ).GetAwaiter().GetResult()

    while ($true) {
        $buffer = New-Object byte[] 65536
        $stream = New-Object System.IO.MemoryStream

        do {
            $result = $Socket.ReceiveAsync(
                [System.ArraySegment[byte]]::new($buffer),
                [Threading.CancellationToken]::None
            ).GetAwaiter().GetResult()

            if ($result.Count -gt 0) {
                $stream.Write($buffer, 0, $result.Count)
            }
        } while (-not $result.EndOfMessage)

        $message = [System.Text.Encoding]::UTF8.GetString($stream.ToArray())
        $response = $message | ConvertFrom-Json

        if ($response.id -eq $Id) {
            if ($response.error) {
                throw "Chrome DevTools error for ${Method}: $($response.error.message)"
            }

            return $response.result
        }
    }
}

try {
    $jsonEndpoint = "http://127.0.0.1:$port/json"
    $targets = $null

    for ($i = 0; $i -lt 60; $i++) {
        try {
            $targets = Invoke-RestMethod -Uri $jsonEndpoint -UseBasicParsing
            if ($targets) {
                break
            }
        } catch {
            Start-Sleep -Milliseconds 250
        }
    }

    if (-not $targets) {
        throw "Chrome DevTools endpoint was not available."
    }

    $target = @($targets | Where-Object { $_.type -eq "page" -and $_.url -eq $fileUrl })[0]
    if (-not $target) {
        $target = @($targets | Where-Object { $_.type -eq "page" })[0]
    }

    if (-not $target -or -not $target.webSocketDebuggerUrl) {
        throw "No debuggable Chrome page was found."
    }

    $socket = [System.Net.WebSockets.ClientWebSocket]::new()
    [void]$socket.ConnectAsync([Uri]$target.webSocketDebuggerUrl, [Threading.CancellationToken]::None).GetAwaiter().GetResult()

    [void](Invoke-CdpCommand -Socket $socket -Id 1 -Method "Page.enable")

    for ($i = 0; $i -lt 40; $i++) {
        $ready = Invoke-CdpCommand -Socket $socket -Id (10 + $i) -Method "Runtime.evaluate" -Params @{
            expression = "document.readyState"
            returnByValue = $true
        }

        if ($ready.result.value -eq "complete") {
            break
        }

        Start-Sleep -Milliseconds 250
    }

    Start-Sleep -Milliseconds 1000

    $pdfResult = Invoke-CdpCommand -Socket $socket -Id 100 -Method "Page.printToPDF" -Params @{
        printBackground = $true
        displayHeaderFooter = $false
        preferCSSPageSize = $true
    }

    [System.IO.File]::WriteAllBytes($pdfPath, [Convert]::FromBase64String($pdfResult.data))
    $socket.Dispose()
} finally {
    if ($proc -and -not $proc.HasExited) {
        $proc.Kill()
        $proc.WaitForExit()
    }
}

$maxRetries = 5
$retryDelay = 1000
$pdfCreated = $false
for ($i = 0; $i -lt $maxRetries; $i++) {
    if (Test-Path $pdfPath) {
        $size = (Get-Item $pdfPath).Length
        if ($size -gt 0) {
            Write-Host "SUCCESS: PDF generated at $pdfPath" -ForegroundColor Green
            Write-Host "Size: $([math]::Round($size / 1KB, 1)) KB" -ForegroundColor Green
            $pdfCreated = $true
            break
        }
    }
    Start-Sleep -Milliseconds $retryDelay
}
if (-not $pdfCreated) {
    Write-Host "ERROR: PDF was not created!" -ForegroundColor Red
}

Write-Host "Cleaning up temporary files..." -ForegroundColor Cyan
Remove-Item -Path $outputPath -Force -ErrorAction SilentlyContinue
Remove-Item -Path $tempUserData -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Done!" -ForegroundColor Green
