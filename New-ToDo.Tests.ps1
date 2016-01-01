$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "New-ToDo" {
    Mock GetToDoFilePath { "TestDrive:\todo.txt" }
    It "should create file if it doesn't exist" {
        $TestTask = "This is something that needs to be done"
        New-Todo $testTask

        $todoFile = GetToDoFilePath

        $todoFile | Should Exist
    }

    It "should add task to file" {
        $TestTask = "This is something that needs to be done"
        New-Todo $testTask

        $todoFile = GetToDoFilePath

        $todoFile | Should Contain $testTask
    }

    It "should add due date if date provided" {
        $TestTask = "This is a something with a due date"
        $DueDateString = "11-Jul-2064"

        New-ToDo $TestTask -due $DueDateString

        $todoFile = GetToDoFilePath

        $todoFile | Should Contain "due:2064-07-11"
    }

    It "should accept a valid priority" {
        $TestTask = "This is a something with a priority"

        { New-ToDo $TestTask -priority A } | Should Not Throw
        { New-ToDo $TestTask -priority Z } | Should Not Throw
        { New-ToDo $TestTask -priority a } | Should Not Throw
        { New-ToDo $TestTask -priority z } | Should Not Throw
    }

    It "should reject an invalid priority" {
        $TestTask = "This is a something with an invalid priority"

        { New-ToDo $TestTask -priority 0 } | Should Throw
        { New-ToDo $TestTask -priority 9 } | Should Throw
        { New-ToDo $TestTask -priority AA } | Should Throw
        { New-ToDo $TestTask -priority "" } | Should Throw
    }

    It "should prefix task with priority" {
        $TestTast = "Test Task"

        .\New-ToDo $TestTask -priority A

        $todoFile = GetToDoFilePath

        $todoFile | Should Contain "(A) $TestTask"
    }

}

#New-Todo should fail if no task specified - this is inherent in making task mandatory

#New-Todo should add due: if -due parameter with valid date

#New-Todo should fail if -due parameter with invalid date

#New-Todo should accept valid priority
#New-Todo should reject invalid priority
#New-Todo should prefix with priority if priority valid

Describe "Get-ToDo" {
#Get-ToDo should list incomplete todos with a numeric prefix (need to define order?)
#Get-ToDo with completed flag should list completed todos with numeric prefix
    Mock GetToDoFilePath { "TestDrive:\todo.txt" }
    Context "No file" {
        It "should return an empty list if file doesn't exist" {
            $todoList = Get-ToDo

            $todoList | Should BeNullOrEmpty
        }
    }

    Context "File with incomplete tasks" {

        BeforeEach {
            $filePath = GetToDoFilePath
            if (Test-Path $filePath)
            {
                Remove-Item $filePath
            }

            $testFilePath = Join-Path $here "get-todo-test.txt"
            Copy-Item $testFilePath $filePath
        }

        It "should list incompleted tasks" {
            $todoFile = Get-ToDo

            $todoFile | Should Not BeNullOrEmpty
            $todoFile.Length | Should Be 3
            $todoFile[0].Substring(0,2) | Should Be " 2"
            $todoFile[1].Substring(0,2) | Should Be " 3"
            $todoFile[2].Substring(0,2) | Should Be " 5"
        }
    }
}

#Get-ToDo with done flag should list items that are done

#Set-todo with done flag should set the specified (by number) todo to done (prefix entry with an "x ")

#Set-todo with invalid number should fail

#Set-todo with valid number should not fail