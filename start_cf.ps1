taskkill /f /im cloudflared.exe 2>$null
Start-Sleep -Seconds 2
$cf = 'C:\Users\Nico Clairmont\Projects\rent_split\cloudflared.exe'
$log = 'C:\Users\Nico Clairmont\Projects\rent_split\.cf-log.txt'
Remove-Item $log -ErrorAction SilentlyContinue
Start-Process -FilePath $cf -ArgumentList @('tunnel','--url','http://localhost:8080') -RedirectStandardError $log -NoNewWindow -PassThru
Start-Sleep -Seconds 15
$content = Get-Content $log -ErrorAction SilentlyContinue
$url = ($content | Select-String 'https://[a-z0-9-]+\.trycloudflare\.com' -AllMatches).Matches.Value | Select-Object -First 1
Write-Host $url
