#Программа для проверки отправленной банковской отчетности по форме 440p
#(c) Гребенёв О.Е. 06.11.2019

[string]$curDir = Split-Path -Path $myInvocation.MyCommand.Path -Parent
[string]$libDir = "$curDir\lib"

. $curDir/variables.ps1
. $libDir/PSMultiLog.ps1
. $libDir/libs.ps1

Set-Location $curDir

#проверяем существуют ли нужные пути и файлы
testDir(@($440Arhive, $440Ack, $440Err, $outPath))
createDir(@($logDir))

#ClearUI
Clear-Host
Start-HostLog -LogLevel Information
Start-FileLog -LogLevel Information -FilePath $logName -Append

Write-Log -EntryType Information -Message "Начало работы скрипта"

[string]$curDate = Get-Date -Format "ddMMyyyy"
[string]$curFormatDate = Get-Date -Format "dd.MM.yyyy"
[string]$curArchive = "$440Arhive\$curDate"
[string]$ackPath = "$440Ack\$curDate"
[string]$errPath = "$440Err\$curDate"

if ($debug) {
    $curDate = '30122019'
    $curFormatDate = '30.12.2019'
    $curArchive = "$440Arhive\$curDate"
    $ackPath = "$440Ack\$curDate"
    $errPath = "$440Err\$curDate"
    $outPath = "$outPath\ARCHIV\$curFormatDate"
}

if (!(Test-Path -Path $curArchive)) {
    Write-Log -EntryType Error -Message "Путь $curArchive не найден!"
    exit
}

$body = "Отчет по 440П за $curFormatDate`n"

$arjFiles = Get-ChildItem -Path $curArchive $outgoingFilesArj
$arjCount = ($arjFiles | Measure-Object).count
$arjArr = @()
$flagErr = $false

if ($arjCount -gt 0) {
    $body += "Архивов было отправлено $arjCount шт.`n"
    ForEach ($file in $arjFiles) {
        $name = $file.Name
        $findFile = Get-ChildItem -Path $outPath | Where-Object { ! $_.PSIsContainer } | Where-Object { $_.Name -match "^IZVTUB_" + $file.BaseName + ".+\.xml$" }
        if (($findFile | Measure-Object).count -eq 1) {
            [xml]$xmlOutput = Get-Content $findFile.FullName

            $xmlTag = $xmlOutput.Файл.ИЗВЦБКОНТР

            if ($xmlTag.КодРезПроверки -eq "01") {
                $arjArr += , @($name, $xmlTag.Пояснение)
            }
            else {
                $flagErr = $true
                $arjArr += , @($name, "Ошибка: $($xmlTag.Пояснение)")
            }

        }
        else {
            $flagErr = $true
            $arjArr += , @($name, 'Ошибка: На найдено подтверждение о получении архива!')
        }
    }

    $partHtml = ''
    ForEach ($elem in $arjArr) {
        $body += "ИмяФайла: $($elem[0]) Результат: $($elem[1])`n"
        if ($elem[1].Contains("Ошибка")) {
            $partHtml += "<tr><td style=""font-size: 16px; color: red"">Имя Файла: <strong>$($elem[0])</strong><br>Результат: <strong>$($elem[1])<strong></td></tr>"
        }
        else {
            $partHtml += "<tr><td style=""font-size: 16px"">Имя Файла: <strong>$($elem[0])</strong><br>Результат: <strong>$($elem[1])<strong></td></tr>"
        }

    }
}
else {
    Write-Log -EntryType Error -Message "Архивы исходящих сообщений в каталоге $curArchive не найдены!"
}

$xmlFiles = Get-ChildItem -Path $curArchive $outgoingFilesXml
$xmlCount = ($xmlFiles | Measure-Object).count

if ($xmlCount -gt 0) {
    $body += "Файлов было отправлено $xmlCount шт.`n"
}

$body += "`n"

$arjInFiles = Get-ChildItem -Path $curArchive $ingoingFilesArj
$arjInCount = ($arjInFiles | Measure-Object).count

if ($arjInCount -gt 0) {
    $msgInFiles = Get-ChildItem -Path $curArchive | Where-Object { $_.Name -match $ingoingFilesXml }
    $msgInCount = ($msgInFiles | Measure-Object).count

    if ($msgInCount -gt 0) {
        $body += "Поступило $msgInCount сообщения(ий) `n"
    }

    $ackCount = 0
    if (Test-Path -Path $ackPath) {
        $ackFiles = Get-ChildItem -Path $ackPath $kvitXml
        $ackCount = ($ackFiles | Measure-Object).count
        if ($ackCount -gt 0) {
            $body += "Поступило успешных подтверждений $ackCount шт.`n"
        }
    }

    $partTwoHtml = ''
    $errCount = 0
    if (Test-Path -Path $errPath) {
        $errFiles = Get-ChildItem -Path $errPath $kvitXml
        $errCount = ($errFiles | Measure-Object).count
        if ($errCount -gt 0) {
            $flagErr = $true
            $body += "Поступило подтверждений с ошибками $errCount шт.`n"

            ForEach ($errFile in $errFiles) {
                [xml]$xmlDocument = Get-Content $errFile.FullName
                $nameFile = $xmlDocument.Файл.КВТНОПРИНТ.ИмяФайла
                $explanation = $xmlDocument.Файл.КВТНОПРИНТ.Результат.Пояснение

                $body += "$nameFile - $explanation`n"
                $partTwoHtml += "<tr><td style=""font-size: 16px; color: red"">Имя Файла: <strong>$($nameFile)</strong><br>Пояснение: <strong>$($explanation)<strong></td></tr>"
            }
        }
    }
}
else {
    Write-Log -EntryType Error -Message "Архивы входящих сообщений в каталоге $curArchive не найдены!"
}

if ($arjCount -eq 0 -and $arjInCount -eq 0 ) {
    exit
}

$bodyHtml = @"
<table>
    <tr>
        <td style="text-align: center; font-size: 22px">Отчёт по 440П за $curFormatDate</td>
    </tr>
    <tr>
        <td style="padding-left: 10px; padding-right: 10px"><hr></td>
    </tr>
    <tr>
        <td style="text-align: center; font-size: 20px">Архивов было отправлено <strong>$arjCount</strong> шт.</td>
    </tr>
    $partHtml
    <tr>
        <td style="text-align: center; font-size: 18px">Файлов было отправлено <strong>$xmlCount</strong> шт.</td>
    </tr>
"@

$bodyHtml += @"
    <tr>
        <td style="padding-left: 10px; padding-right: 10px"><hr></td>
    </tr>
    <tr>
        <td style="text-align: center; font-size: 18px">Поступило <strong>$msgInCount</strong> сообщения(ий)</td>
    </tr>
    <tr>
        <td style="text-align: center; font-size: 18px">Поступило успешных подтверждений <strong>$ackCount</strong> шт.</td>
    </tr>
    <tr>
        <td style="text-align: center; font-size: 18px">Поступило подтверждений с ошибками <strong>$errCount</strong> шт.</td>
    </tr>
    $partTwoHtml
</table>
"@

#$bodyHtml | Out-File -FilePath "$curDir\index.html"
Write-Log -EntryType Information -Message $body

if (Test-Connection $mailServer -Quiet -Count 2) {
    $title = "Отчёт по 440П за $curFormatDate"
    if ($flagErr) {
        $title = "Ошибка! " + $title
    }
    $encoding = [System.Text.Encoding]::UTF8
    Send-MailMessage -To $mailAddr -Body $bodyHtml -Encoding $encoding -From $mailFrom -Subject $title -SmtpServer $mailServer -BodyAsHtml
    Write-Log -EntryType Information -Message "Письмо было успешно отправлено!"
}
else {
    Write-Log -EntryType Error -Message "Не удалось соединиться с почтовым сервером $mail_server"
}

Write-Log -EntryType Information -Message "Конец работы скрипта"

Stop-FileLog
Stop-HostLog