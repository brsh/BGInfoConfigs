Option Explicit
on error resume next

Dim sScriptIs, sAppToRun, sRetVal, sTxtArray, i, out, bBlank

'Define our PowerShell Script and Command Line
sScriptIs = "c:\bginfo\scripts\PowerShell\Get-ServerRole.ps1"
sAppToRun = "%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -InputFormat None -NoProfile -NoLogo -WindowStyle Hidden -ExecutionPolicy Unrestricted -file " & sScriptIs

'We'll assume no output; we'll change this if we find something
bBlank = True

'Run that command line and capture the output
sRetVal = Run(sAppToRun)

'Format the output
sTxtArray = Split(sRetVal, vbCrLf)

out = ""
out = "Server Role:" & vbTab
for i = 0 to ubound(sTxtArray)
	'Format the columns based on the heading
	'We strip the heading (everything before the ':') and add a comma to separate
	Select Case Trim(Left(sTxtArray(i), 9))
		Case "Qualified"
			out = out & Trim(split(sTxtArray(i), " : ")(1)) & ", "
			bBlank = false
	End Select
Next
out = Trim(out)
out = Left(out, Len(out)-1)

if not bBlank then
	'We hard set bBlank to True early on - setting it to false only if nothing is found
	'If it's not blank, we output the text...
	echo Trim(out) & vbCrLf
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


