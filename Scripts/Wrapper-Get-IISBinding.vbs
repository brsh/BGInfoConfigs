Option Explicit
on error resume next

Dim sScriptIs, sAppToRun, sRetVal, sTxtArray, i, out, bBlank, bDidHeading

'Define our PowerShell Script and Command Line
sScriptIs = "c:\bginfo\scripts\PowerShell\Get-IISBindings.ps1"
sAppToRun = "%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -InputFormat None -NoProfile -NoLogo -WindowStyle Hidden -ExecutionPolicy Unrestricted -file " & sScriptIs

'Run that command line and capture the output
sRetVal = Run(sAppToRun)

'Format the output
sTxtArray = Split(sRetVal, vbCrLf)
for i = 0 to ubound(sTxtArray)
	'Initialize our output each time
	out = ""
	if left(sTxtArray(i), 3) = "   " then
		'Check for a line without a heading (additional bindings) and indent it
		out = vbtab & trim(sTxtArray(i))
	elseif left(sTxtArray(i), 4) = "Bind" then
		'Check for the first line with the Binding heading and indent it
		out = vbtab & Trim(Right(sTxtArray(i), (len(sTxtArray(i)) - 10)))
	elseif len(sTxtArray(i)) > 10 then
		'All other lines, trim the first 10 characters (headings) if there are 10 characters
		out = Trim(Right(sTxtArray(i), (len(sTxtArray(i)) - 10)))
	end if
	if len(trim(out)) > 0 then
		'Now, output only non-blank lines, and attach the IIS Sites heading to the first line only
		if not bDidHeading then
			out = "IIS Sites: " & vbTab & Trim(out)
			bDidHeading = True
		end if
		echo Trim(out)
	End If
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
