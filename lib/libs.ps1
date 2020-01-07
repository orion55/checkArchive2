function ClearUI{
	$bckgrnd = "DarkBlue"
	$Host.UI.RawUI.BackgroundColor = $bckgrnd
	$Host.UI.RawUI.ForegroundColor = 'White'
	$Host.PrivateData.ErrorForegroundColor = 'Red'
	$Host.PrivateData.ErrorBackgroundColor = $bckgrnd
	$Host.PrivateData.WarningForegroundColor = 'Magenta'
	$Host.PrivateData.WarningBackgroundColor = $bckgrnd
	$Host.PrivateData.DebugForegroundColor = 'Yellow'
	$Host.PrivateData.DebugBackgroundColor = $bckgrnd
	$Host.PrivateData.VerboseForegroundColor = 'Green'
	$Host.PrivateData.VerboseBackgroundColor = $bckgrnd
	Clear-Host
}

function testDir($dirs1){
	foreach ($d1 in $dirs1){
		#проверка существования путей
		if (!(Test-Path -Path $d1)){
			Write-Log -EntryType Error -Message "Путь $d1 не найден!"
			Write-Log -EntryType Information -Message "Нажмите любую клавишу для продолжения"
			Read-Host "Нажмите Enter"
			Exit
		}
	}
}

function testFiles($files){
	foreach ($f1 in $files){
		#проверка существования файлов
		if (!(Test-Path $f1)){
			Write-Log -EntryType Error -Message "Файл $f1 не найден!"
			Write-Log -EntryType Information -Message "Нажмите любую клавишу для продолжения"
			Read-Host "Нажмите Enter"
			Exit
		}
	}
}

#Проверяем существуют ли каталоги, если не существует, то создаём?
function createDir($dirList){
	foreach ($curPath in $dirList){
		#проверка существования путей
		if (!(Test-Path -Path $curPath)){
			New-Item -ItemType directory -Path $curPath | out-Null
		}
	}
}