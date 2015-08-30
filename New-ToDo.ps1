function GetToDoFilePath
{
    "c:\temp\todo.txt"
}

function New-ToDo {
    Param(
    [string] $task
    )

    $filePath = GetToDoFilePath
    
    if (-not (Test-Path $filePath))
    {
        New-Item -Path $filePath -ItemType File
    }

    Add-Content $filePath $task
}
