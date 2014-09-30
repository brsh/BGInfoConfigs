Set objShell = CreateObject("WScript.Shell")
Set objExecObject = objShell.Exec("C:\Program Files\BGInfo\Scripts\sessions.bat")
Do While Not objExecObject.StdOut.AtEndOfStream
    strText = objExecObject.StdOut.ReadLine
    Echo "Hello" & strText 
Loop
