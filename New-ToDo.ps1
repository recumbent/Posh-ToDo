function GetToDoFilePath
{
    "c:\temp\todo.txt"
}

function New-ToDo {
    [cmdletbinding()]
    Param(
    [Parameter(Mandatory=$true, Position=0)]
    [string] $task
    )

    $filePath = GetToDoFilePath
    
    if (-not (Test-Path $filePath))
    {
        New-Item -Path $filePath -ItemType File
    }

    Add-Content $filePath $task
}

function Get-ToDo {
    [cmdletbinding()]

    $filePath = GetToDoFilePath
    if (-not (Test-Path $filePath))
    {
        return @()
    }

    $lines = Get-Content -Path $filePath

    $step1 = $lines | Where { -not [String]::IsNullOrWhiteSpace($_) }
    
    $counter = 1
    $result = $step1 | foreach { ("{0:nn}. {1}" -f $counter, $_); $counter += 1 }

    return $result
}
