Set objShell = CreateObject("WScript.Shell")
Set objExecObject = objShell.Exec("C:\Program Files\BGInfo\sessions.bat")
'Set objExecObject = objShell.Exec("c:\windows\system32\query.exe user")
strText = ""
'Do While Not objExecObject.StdOut.AtEndOfStream
'    strText = "LKLKHJ"
'Loop
'Echo strText & "---" & err.number

Set objStdOut = objExecObject.StdOut
strOutput = objStdOut.ReadAll
echo strOutput