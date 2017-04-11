Option Explicit
on error resume next

Dim sScriptIs, sAppToRun, sRetVal, sTxtArray, i, out, bBlank, sTemp

'Define our PowerShell Script and Command Line
sScriptIs = "c:\bginfo\scripts\PowerShell\Get-UserSessions.ps1"
sAppToRun = "%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -InputFormat None -NoProfile -NoLogo -WindowStyle Hidden -ExecutionPolicy Unrestricted -file " & sScriptIs

'We'll assume no output; we'll change this if we find something
bBlank = True

'Run that command line and capture the output
sRetVal = Run(sAppToRun)

'Format the output
sTxtArray = Split(sRetVal, vbCrLf)

out = ""
out = out & PadLeft("UserName", 15) & vbTab
'out = out & PadLeft("Session", 9) & vbTab
out = out & PadLeft("State", 7) & vbTab
out = out & PadLeft("Idle Time", 12) & vbTab
out = out & Trim("LogOn Time") & vbCrLf
for i = 0 to ubound(sTxtArray)
	'Initialize our output each time
	sTemp = ""
	'Format the columns based on the heading
	'We strip the heading (everything before the ':') and pad the string to a specific length + a tab
	Select Case Trim(Left(sTxtArray(i), 9))
		Case "UserName"
			sTemp = sTemp & PadLeft(Trim(split(sTxtArray(i), " : ")(1)), 15) & vbTab
			bBlank = false
		Case "Session"
			'Session isn't all that useable, so we don't include it here
			'sTemp = sTemp & PadLeft(Trim(split(sTxtArray(i), " : ")(1)), 11) & vbTab
		Case "State"
			sTemp = sTemp & PadLeft(Trim(split(sTxtArray(i), " : ")(1)), 7) & vbTab
		Case "IdleTime"
			sTemp = sTemp & PadLeft(Trim(split(sTxtArray(i), " : ")(1)), 15) & vbTab
		Case "LogonTime"
			'As this is the last column, we forgo the padding and use a new line at the end
			sTemp = sTemp & Trim(split(sTxtArray(i), " : ")(1)) & vbCrLf
	End Select
	out = out & sTemp
Next

if not bBlank then
	'We hard set bBlank to True early on - setting it to false only if nothing is found
	'If it's not blank, we output the text...
	echo Trim(out)
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
		dteWait = DateAdd("s", 1, Now())
		Do Until (Now() > dteWait)
		Loop
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


