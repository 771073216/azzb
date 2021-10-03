function killprocess
{
  $Key = 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings'
  $result = (Get-ItemProperty "Registry::$Key").ProxyEnable
  $process = (Get-Process -ErrorAction SilentlyContinue v2rayn)
  if ($process -ne $null) { Stop-Process -Name v2rayN }
  if ($result -eq 1) { Set-ItemProperty Registry::$Key ProxyEnable 0 }
}

if (!(Test-Path .\version))
{
  "geo:0" > .\version
  "xray:0" >> .\version
  "v2rayn:0" >> .\version
}

if (Test-Path .\tmp\) { Remove-Item -Recurse .\tmp\ }
if (Test-Path .\xray.zip) { Remove-Item xray.zip }
if (Test-Path .\v2rayn.zip) { Remove-Item v2rayn.zip }

curl https://cdn.jsdelivr.net/gh/771073216/dist@main/version -O remote.txt
$xraylatest = (Get-Content .\remote.txt | findstr xray).Split(':')[1].trim()
$xraylocal = (Get-Content .\version | findstr xray).Split(':')[1]
$guilatest = (Get-Content .\remote.txt | findstr v2rayn).Split(':')[1].trim()
$guilocal = (Get-Content .\version | findstr v2rayn).Split(':')[1]
$geotime = Get-Date -Format 'yyM'
$geolocal = (Get-Content .\version | findstr geo).Split(':')[1]
Remove-Item remote.txt

if ($xraylocal -lt $xraylatest)
{
  curl https://cdn.jsdelivr.net/gh/771073216/dist@main/windows/xray-windows.zip -O xray.zip
}
if ($guilocal -lt $guilatest)
{
  curl https://cdn.jsdelivr.net/gh/771073216/dist@main/windows/v2rayn-v$guilatest.zip -O v2rayn.zip
}
if ($geotime -ne $geolocal)
{
  curl https://cdn.jsdelivr.net/gh/771073216/geofile@release/geoip.dat -O geoip.dat
  curl https://cdn.jsdelivr.net/gh/771073216/geofile@release/geosite.dat -O geosite.dat
}

if (Test-Path .\xray.zip)
{
  killprocess
  Expand-Archive .\xray.zip .\tmp
  Remove-Item xray.zip
  Move-Item -Force .\tmp\xray.exe .
}
if (Test-Path .\v2rayn.zip)
{
  killprocess
  Expand-Archive .\v2rayn.zip .\tmp
  Remove-Item v2rayn.zip
    if (Test-Path .\zh-Hans)
    { 
    Remove-Item -Recurse .\zh-Hans
    Move-Item -Force .\tmp\v2rayN\zh-Hans\ .
    }
  Move-Item -Force .\tmp\v2rayN\* .
}

if (Test-Path .\tmp\) {Remove-Item -Recurse .\tmp\ }

"geo:$geotime" > .\version
"xray:$xraylatest" >> .\version
"v2rayn:$guilatest" >> .\version

if (!(Test-Path .\guiNConfig.json))
{
  .\v2rayN.exe
  sleep 1
  killprocess
  $conf = Get-Content .\guiNConfig.json
  clear-content .\guiNConfig.json
  foreach ($line in $conf)
  {
    $liner = $line -replace '"coreType": 0,','"coreType": 1,' `
    -replace '"routingIndex": 0,','"routingIndex": 1,' `
    -replace '"enableRoutingAdvanced": false,','"enableRoutingAdvanced": true,'
    Add-content .\guiNConfig.json $liner
  }
}
