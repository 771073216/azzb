$latest = (invoke-restmethod https://api.github.com/repos/XTLS/Xray-core/releases/latest | findstr tag_name).Split("v")[1]
$local = (.\xray.exe -version).Split()[1]
$remotever = (invoke-restmethod https://api.github.com/repos/2dust/v2rayN/releases/latest | findstr tag_name).Split(":")[1].trim()
$localver = (Get-Item .\v2rayN.exe).VersionInfo.FileVersion

$kill = {
$Key = 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings'
$Name = 'ProxyEnable'
$result = (Get-ItemProperty -Path "Registry::$Key").$Name
$process = (Get-Process -ErrorAction SilentlyContinue -Name v2rayn)
if ($process -ne $null)
{
  Get-Process -ErrorAction SilentlyContinue -Name v2rayN | Stop-Process
}
if ($result -eq 1)
{
  Set-ItemProperty -path Registry::$Key -Name $Name -value 0
}
}

if ($local -eq $latest)
{
  curl https://api.azzb.workers.dev/https://github.com/XTLS/Xray-core/releases/latest/download/Xray-windows-64.zip -O xray.zip
}

if ( $localver -eq $remotever )
{
  curl https://api.azzb.workers.dev/https://github.com/2dust/v2rayN/releases/latest/download/v2rayN.zip -O v2rayn.zip
}

if ($local -eq $latest)
{
  .$kill
  Expand-Archive -Path .\xray.zip -DestinationPath .\tmp ; del xray.zip
  Move-Item -Force -Path .\tmp\xray.exe -Destination .
}

if ( $localver -eq $remotever )
{
  .$kill
  Expand-Archive -Path .\v2rayn.zip -DestinationPath .\tmp ; del v2rayn.zip
  Move-Item -Force -Path .\tmp\v2rayN\zh-Hans\* -Destination .\zh-Hans ; del .\tmp\v2rayN\zh-Hans
  Move-Item -Force -Path .\tmp\v2rayN\* -Destination .
}

del -r -ErrorAction SilentlyContinue ./tmp/

curl https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geoip.dat -O geoip.dat
curl https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geosite.dat -O geosite.dat