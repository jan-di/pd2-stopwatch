#Requires -Version 5.0

$OutDir = "$PSScriptRoot\out"

if (!(Test-Path $OutDir)) {
    New-Item $OutDir -ItemType 'Directory' | Out-Null
} else {
    Get-ChildItem $OutDir | ForEach-Object {
        Remove-Item $_.FullName -Recurse
    }
}

New-Item "$OutDir\Stopwatch" -ItemType 'Directory' | Out-Null

Get-ChildItem "$PSScriptRoot" -Exclude (".*", "out", "debug", $MyInvocation.MyCommand.Name) | ForEach-Object {
    Copy-Item $_ -Destination "$OutDir\Stopwatch" -Recurse
}

Compress-Archive "$OutDir\Stopwatch" -DestinationPath "$OutDir\Stopwatch.zip"
Remove-Item "$OutDir\Stopwatch" -Recurse