function killprocess
{
	$Key = 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings'
	$Name = 'ProxyEnable'
	$result = (Get-ItemProperty -Path "Registry::$Key").$Name
	$process = (Get-Process -ErrorAction SilentlyContinue -Name v2rayn)
	if ($process -ne $null) { Stop-Process -Name v2rayN }
	if ($result -eq 1) { Set-ItemProperty -Path Registry::$Key -Name $Name -Value 0 }
}

if (!(Test-Path .\version))
{
	"geo:0" > .\version
	"xray:0" >> .\version
	"v2rayn:0" >> .\version
}

if (Test-Path .\tmp\) { Remove-Item -r .\tmp\ }
if (Test-Path .\xray.zip) { Remove-Item xray.zip }
if (Test-Path .\v2rayn.zip) { Remove-Item v2rayn.zip }

$latest = (Invoke-RestMethod https://cdn.jsdelivr.net/gh/771073216/dist@main/version | findstr xray).Split(":")[1].trim()
$local = (Get-Content .\version | findstr xray).Split(':')[1]
$remotever = (Invoke-RestMethod https://cdn.jsdelivr.net/gh/771073216/dist@main/version | findstr v2rayn).Split(":")[1].trim()
$localver = (Get-Content .\version | findstr v2rayn).Split(':')[1]
$time = Get-Date -Format 'yyM'
$localtime = (Get-Content .\version | findstr geo).Split(':')[1]

if ($local -lt $latest)
{
	curl https://cdn.jsdelivr.net/gh/771073216/dist@main/xray-windows.zip -O xray.zip
}
if ($localver -lt $remotever)
{
	curl https://cdn.jsdelivr.net/gh/771073216/dist@main/v2rayn.zip -O v2rayn.zip
}
if ($time -ne $localtime)
{
	curl https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geoip.dat -O geoip.dat
	curl https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geosite.dat -O geosite.dat
}

if (Test-Path .\xray.zip)
{
	killprocess
	Expand-Archive -Path .\xray.zip -DestinationPath .\tmp; Remove-Item xray.zip
	Move-Item -Force -Path .\tmp\xray.exe -Destination .
}
if (Test-Path .\v2rayn.zip)
{
	killprocess
	Expand-Archive -Path .\v2rayn.zip -DestinationPath .\tmp; Remove-Item v2rayn.zip
	Move-Item -Force -Path .\tmp\v2rayN\zh-Hans\* -Destination .\zh-Hans; Remove-Item .\tmp\v2rayN\zh-Hans
	Move-Item -Force -Path .\tmp\v2rayN\* -Destination .
}

"geo:$time" > .\version
"xray:$latest" >> .\version
"v2rayn:$remotever" >> .\version
Remove-Item -r -ErrorAction SilentlyContinue .\tmp\
