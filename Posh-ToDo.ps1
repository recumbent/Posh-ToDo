function GetToDoFilePath
{
    
    if ($env:todotxtfolderpath -ne $null)
    {
        $filePath = Join-Path $env:todotxtfolderpath "todo.txt"
    }
    else
    {
        $documents = [environment]::getfolderpath("mydocuments")
        $filePath = Join-Path $documents "todo.txt"
    }

    return $filePath
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

function Set-ToDo {
    [cmdletbinding()]

    Param(
    [Parameter(Mandatory=$true, Position=0)]
    [int] $Item,
    [Parameter()]
    [switch] $Done
    )

    $filePath = GetToDoFilePath

    if (-not (Test-Path $filePath))
    {
        throw "todo.txt is empty"
    }
    else
    {
        $lines = Get-Content -Path $filePath
    }

    $total = $lines.Count

    if ($Item -lt 1 -or $Item -gt $total)
    {
        throw ("Valid item number is in the range 1 to $total")
    }

    $itemLine = $lines[$Item - 1]
    if (-not $itemLine.StartsWith("x "))
    {
        $dateCompleted = (Get-Date).ToString("yyyy-MM-dd")
        $lines[$Item - 1] = ("x $dateCompleted $itemLine")
    }

    Set-Content -Path $filePath -Value $lines
}


function Update-ToDo {
    [cmdletbinding()]

    $filePath = GetToDoFilePath

    if (-not (Test-Path $filePath))
    {
        throw "todo.txt is empty"
    }
    else
    {
        $lines = Get-Content -Path $filePath
    }

    $sorted = ($lines | Sort-Object)

    Set-Content -Path $filePath -Value $sorted
}