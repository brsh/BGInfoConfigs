Option Explicit
on error resume next

Dim sScriptIs, sAppToRun, sRetVal, sTxtArray, i

'Define our PowerShell Script and Command Line
sScriptIs = "c:\bginfo\scripts\PowerShell\Get-SQLVersion.ps1"
sAppToRun = "%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -NoProfile -NoLogo -WindowStyle Hidden -ExecutionPolicy Unrestricted -file " & sScriptIs

'Run that script and capture the output
sRetVal = Run(sAppToRun)

'Adjust the output to a) preserve indenting, and b) remove blank and --- lines
echo vbCrLf
sTxtArray = Split(sRetVal, vbCrLf)
for i = 0 to ubound(sTxtArray)
	if Len(Trim(sTxtArray(i))) = 0 Then
		' Do Nothing
	elseif Left(Trim(sTxtArray(i)), 2) = "--" then
		' Do Nothing
	else
		echo sTxtArray(i)
	end if
next

Function Run(sCLI)
	'Here we execute the command specified
	Dim oApp, wShell, dteWait
	Set wShell = CreateObject("wscript.shell")
	Set oApp = wShell.exec(sCLI)
	If Err.Number <> 0 Then
		Echo "Error found: " & Err.Description
		Err.Clear
	End If
	'and wait for it to exit
	do until oApp.status = 1
		'Sleep for 1 second (vbs in bginfo has no wscript.sleep function)
		dteWait = DateAdd("s", 1, Now())
		Do Until (Now() > dteWait)
		Loop
	Loop
	Run = oApp.StdOut.ReadAll
End Function
