function GetToDoFilePath
{
    "c:\temp\todo.txt"
}

function New-ToDo {
    [cmdletbinding()]
    Param(
    [Parameter(Mandatory=$true, Position=0)]
    [string] $task,
    [Parameter()]
    [string] $due,
    [Parameter()]
    [ValidatePattern("^[A-Z]$")]
    [string] $priority
    )

    $filePath = GetToDoFilePath
    
    if (-not (Test-Path $filePath))
    {
        New-Item -Path $filePath -ItemType File
    }

    $taskToAdd = $task

    if (-not [String]::IsNullOrEmpty($due))
    {
        $dueDate = Get-Date -Date $due

        $taskToAdd = "$taskToAdd due:{0:yyyy-MM-dd}" -f $dueDate
    }

    Add-Content $filePath $taskToAdd
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

    $step2 = $step1 | foreach { ("{0,2}. {1}" -f $counter, $_); $counter += 1 }

    $step3 = $step2 | where { $_.ToString().Substring(4,2) -ne "x " }

    $result = $step3

    return $result
}
