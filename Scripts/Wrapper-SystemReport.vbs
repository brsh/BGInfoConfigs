Option Explicit
on error resume next

Dim sScriptIs, sAppToRun, sRetVal, sTxtArray, i, out, bBlank, sTemp

'Define our PowerShell Script and Command Line
sScriptIs = "c:\bginfo\scripts\PowerShell\Get-SystemReport.ps1"
sAppToRun = "%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -InputFormat None -NoProfile -NoLogo -WindowStyle Hidden -ExecutionPolicy Unrestricted -file " & sScriptIs & " -BGInfo"

'Run that command line and capture the output
sRetVal = Run(sAppToRun)

'Format the output
Do while Left(sRetVal, 1) = vbCrLf
	sRetVal = Right(sRetVal, Len(sRetVal) - 1)
Loop

if Len(sRetVal) > 0 then
	echo Trim(sRetVal) & vbCrLf
End If

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
		wShell.Run "%COMSPEC% /c ping -n 1 127.0.0.1>nul",0,1
	Loop
	Run = oApp.StdOut.ReadAll
End Function

Function PadLeft(sOrig, iLength)
	'left justify a column of text so padleft("123", 6) becomes "123   "
	Dim sRet
	if len(sOrig) < iLength then
		sRet = sOrig & String(iLength - Len(sOrig), " ")
	else
		sRet = sOrig
	end if
	PadLeft = sRet
End Function


