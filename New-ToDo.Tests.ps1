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
        $TestTask = "Test Task"

        New-ToDo $TestTask -priority A

        $todoFile = GetToDoFilePath

        $expected = "\(A\) $TestTask"
        $todoFile | Should Contain $expected
    }

}

#New-Todo should fail if no task specified - this is inherent in making task mandatory, but still worth a test?

#New-Todo should add due: if -due parameter with valid date

#New-Todo should fail if -due parameter with invalid date


Describe "Get-ToDo" {
#Get-ToDo should list incomplete todos with a numeric prefix (need to define order?)
#Get-ToDo with completed flag should list completed todos with numeric prefix
    Mock GetToDoFilePath { "TestDrive:\todo.txt" }
    Context "No file" {
        It "should return an empty list if file doesn't exist" {
            $todoList = Get-ToDo

            $todoList | Should BeNullOrEmpty
        }

        
        It "should return an empty list for done if file doesn't exist" {
            $todoList = Get-ToDo -Done

            $todoList | Should BeNullOrEmpty
        }

        It "should return an empty list for all if file doesn't exist" {
            $todoList = Get-ToDo -All

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

        It "should list completed tasks if done switch set" {
            $todoFile = Get-ToDo -Done

            $todoFile | Should Not BeNullOrEmpty
            $todoFile.Length | Should Be 2
            $todoFile[0].Substring(0,2) | Should Be " 1"
            $todoFile[1].Substring(0,2) | Should Be " 4"
        }

        It "should list all tasks if all switch set" {
            $todoFile = Get-ToDo -All

            $todoFile | Should Not BeNullOrEmpty
            $todoFile.Length | Should Be 5
            $todoFile[0].Substring(0,2) | Should Be " 1"
            $todoFile[1].Substring(0,2) | Should Be " 2"
            $todoFile[2].Substring(0,2) | Should Be " 3"
            $todoFile[3].Substring(0,2) | Should Be " 4"
            $todoFile[4].Substring(0,2) | Should Be " 5"
        }
    }
}

Describe "Set-ToDo" {

    Mock GetToDoFilePath { "TestDrive:\todo.txt" }
    Context "No file" {

        It "Should error if no tasks" {
            { Set-ToDo 1 } | Should Throw
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

        It "Should error if item number invalid" {
            { Set-ToDo -5 } | Should Throw
            { Set-ToDo 0 }  | Should Throw
            { Set-ToDo 6 }  | Should Throw
            { Set-ToDo A }  | Should Throw
        }

        It "Should mark item with index as done" {
            Set-ToDo 2 -Done

            $filePath | Should Contain "x First undone item"
        } 
    }
}

#Set-todo with valid number should not fail - inherent? Covered by other cases?

#Set-todo with done flag should set the specified (by number) todo to done (prefix entry with an "x ")

#Make this into a module

#Push

#Split files (around module)

#Work out what next

#Set-ToDo Error if index out of range (empty file, block -ve with valiation, too high)

#Context

#Project

#Tag

#Lead time

#Repeat

#Update-ToDo (sort, bring back repeats)

#Archive-ToDo (is this separate or is this part of update??)

#At some point magically refactor to introduce a "class" to manage the things
