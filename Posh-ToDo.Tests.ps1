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

    It "should add due date if valid date passed in due parameter" {
        $testTask = "Test Task"
        $testDate = "11-Jul-2016"
        $formated = "2016-07-11"

        New-ToDo $testTask -due $testDate

        $todoFile = GetToDoFilePath
        $todoFile | Should Contain "due:$formatted"
    }

    It "should fail if invalid date passed in due parameter" {
        $testTask = "Test Task"
        $testDate = "45-Fsh-2016"

        { New-ToDo $testTask -due $testDate } | Should Throw
    }
}

#New-Todo should fail if no task specified - this is inherent in making task mandatory, but still worth a test?

#Interesting ideas around parsing due dates
   # 'tomorrow', 'next', 'x day(s)', 'x working days', '<day of week>' - would want a date parse function

Describe "Get-ToDo" {

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

# Get-ToDo
   # 'Should return incomplete items with due date set if due with no date specified
   # 'Should return incomplete items due on or before specified due date if due flag with date
   # 'Should return incomplete items with priority if priority with no priority specified
   # 'Should return incomplete items with priority equal to or below specified priority
   # Standard sort options (notwithstanding that I could use actual sort
   # This implies migrating to objects for internal storage
    
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

            $filePath | Should Contain "x \d{4}-\d{2}-\d{2} First undone item"
        }

        It "Should not mark item with index as done if already done" {
            Set-ToDo 1 -Done

            $filePath | Should Not Contain "x \d{4}-\d{2}-\d{2} x "
        } 

        It "Should add completion date for done" {
            Set-ToDo 2 -Done
            
            $date = "{0:yyyy-MM-dd}" -f $dueDate
            $filePath | Should Contain $date 
        }
    }
}

#Set-todo with valid number should not fail - inherent? Covered by other cases?

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
Describe "Update-ToDo" {

    Mock GetToDoFilePath { "TestDrive:\todo.txt" }

    Context "File with incomplete tasks" {

        BeforeEach {
            $filePath = GetToDoFilePath
            if (Test-Path $filePath)
            {
                Remove-Item $filePath
            }

            $testFilePath = Join-Path $here "update-todo-test.txt"
            Copy-Item $testFilePath $filePath
        }

        It "Should sort" { # (alpha, but that means priority then due date)
            Update-ToDo

            $todoFile = Get-ToDo -All

            $todoFile | Should Not BeNullOrEmpty
            $todoFile.Length | Should Be 5
            $todoFile[0].Substring(0,7) | Should Be " 1. (A)"
            $todoFile[1].Substring(0,7) | Should Be " 2. Fir"
            $todoFile[2].Substring(0,7) | Should Be " 3. Sec"
            $todoFile[3].Substring(0,5) | Should Be " 4. x"
            $todoFile[4].Substring(0,5) | Should Be " 5. x"
        }

        #Should generate new items for done repeats 

        #Should not generate new item for repeat if already exists
    }
}

#Archive-ToDo (is this separate or is this part of update??)

    #Should remove done items from todo file

    #Should add done items to archive file

    #Archive file name is todo.txt -> todo-archive.txt my-todo.txt -> my-todo-archive.txt

#At some point magically refactor to introduce a "class" to manage the things

#File parameter to specify alternative file - for get, set, update, archive

# Need at least one class, ToDoItem - I'm about to lock myself to ps5 !

# Properties: priority, isDone, dateDone, text
# Method: toString (!)

Describe "ToDoItem" {

    It "Should parse done" {
       $parsed = [ToDoItem]::new("x I am a done item")
       $parsed.IsDone | Should Be $true    
    }

    # TODO: This and the above are data driven test if that will work here
    It "Should parse not done" {
       $parsed = [ToDoItem]::new("I am a not done item")
       $parsed.IsDone | Should Be $false
    }

    It "Should parse date done" {
       $parsed = [ToDoItem]::new("x 2016-10-04 I am a done item with a date")
       $expected = Get-Date("04-Oct-2016")
       $parsed.DateDone | Should Be $expected       
    }

    It "Should not set date done if it can't parse the date" {
       $parsed = [ToDoItem]::new("x I am a done item without a date")
       $expected = [DateTime]::MinValue
       $parsed.DateDone | Should Be $expected       
    }


    $prioritised = @(
        "(J) prioritised, not done",
        "x (J) prioritised, done",
        "x 2016-10-04 (J) prioritised, done with date"
    )
    
    foreach($item in $prioritised) {
        It "Should parse priority" {
            $parsed = [ToDoItem]::new($item)
            $parsed.Priority | Should Be "J"
        }
    }

    $notPrioritised = @(
        "not prioritised, not done",
        "x not prioritised, done",
        "x 2016-10-04 not prioritised, done with date"
    )

    foreach($item in $notPrioritised) {
        It "Should not set priority if none set" {
            $parsed = [ToDoItem]::new($item)
            $parsed.Priority | Should Be $null
        }
    }

    # By this we mean that it should extract the description text and not include non-description
    # hmm if I start adding tags and things tests in this context will need to be extended
    It "Should parse description" {

    }
} 