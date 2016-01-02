function GetToDoFilePath
{
    $documents = [environment]::getfolderpath("mydocuments")

    "c:\temp\todo.txt"
}

function New-ToDo {
    [cmdletbinding()]
    Param(
    [Parameter(Mandatory=$true, Position=0)]
    [string] $Task,
    [Parameter()]
    [string] $Due,
    [Parameter()]
    [ValidatePattern("^[A-Z]$")]
    [string] $Priority
    )

    $filePath = GetToDoFilePath
    
    if (-not (Test-Path $filePath))
    {
        New-Item -Path $filePath -ItemType File
    }

    $taskToAdd = $task.Trim()

    if (-not [string]::IsNullOrEmpty($priority))
    {
        $priority = $priority.ToUpper();
        $taskToAdd = "($priority) $taskToAdd"
    }

    if (-not [String]::IsNullOrEmpty($due))
    {
        $dueDate = Get-Date -Date $due

        $taskToAdd = "$taskToAdd due:{0:yyyy-MM-dd}" -f $dueDate
    }

    Add-Content $filePath $taskToAdd
}

function Get-ToDo {
    [cmdletbinding()]

    Param(
    [Parameter()]
    [switch] $Done,
    [Parameter()]
    [switch] $All
    )

    $filePath = GetToDoFilePath
    if (-not (Test-Path $filePath))
    {
        return @()
    }

    $lines = Get-Content -Path $filePath

    $step1 = $lines | Where { -not [String]::IsNullOrWhiteSpace($_) }
    $counter = 1

    $step2 = $step1 | foreach { ("{0,2}. {1}" -f $counter, $_); $counter += 1 }

    $step3 = $step2 | where { $All -or ($_.ToString().Substring(4,2) -ne "x " -and -not $Done) -or ($_.ToString().Substring(4,2) -eq "x " -and $Done)}

    $result = $step3

    return $result
}
