[string]$curDir = Split-Path -Path $myInvocation.MyCommand.Path -Parent

#временный каталог
[string]$tmp = "$curDir\temp"
[boolean]$debug = $true

#настройка почты
#[string]$mailAddr = "tmn-f365@tmn.apkbank.apk"
[string]$mailAddr = "tmn-goe@tmn.apkbank.ru"
#[string]$mailAddr = "tmn_oit@tmn.apkbank.apk"
[string]$mailServer = "191.168.6.50"
[string]$mailFrom = "atm_support@tmn.apkbank.apk"

#архив
[string]$440Arhive = "$tmp\440p\Arhive"
[string]$440Ack = "$tmp\440p\ack"
[string]$440Err = "$tmp\440p\error"
[string]$outPath = "$tmp\OUT"

#маски
[string]$outgoingFilesArj = "AFN_7102803_MIFNS00_*_000??.ARJ"
[string]$outgoingFilesXml = "*_*7102803_*.xml"

[string]$ingoingFilesArj = "AFN_MIFNS00_7102803_*_000??.ARJ"
[string]$ingoingFilesXml = "^\w{3}\d7102803_\d+_\d+.xml$"
[string]$kvitXml = "KWTFCB_*.xml"

#имя лог-файла
[string]$logDir = $curDir + "\log"
[string]$logName = "$logDir\checkArchive.log"

[string]$arj32 ="$curDir\util\arj32.exe"