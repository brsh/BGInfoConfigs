Option Explicit
on error resume next

Dim sScriptIs, sAppToRun, sRetVal, sTxtArray, i, out, bDidHeading

'Define our PowerShell Script and Command Line
sScriptIs = "c:\bginfo\scripts\PowerShell\Get-SQLVersion.ps1"
sAppToRun = "%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -InputFormat None -NoProfile -NoLogo -WindowStyle Hidden -ExecutionPolicy Unrestricted -file " & sScriptIs

'Run that script and capture the output
sRetVal = Run(sAppToRun)

'Format the output
sTxtArray = Split(sRetVal, vbCrLf)
for i = 0 to ubound(sTxtArray)
	'Initialize our output each time
	out = ""
	if len(trim(sTxtArray(i))) > 15 then
		''All other lines, trim the first 15 characters (headings) if there are 15 characters
		if left(Trim(sTxtArray(i)), Len("Instance")) = "Instance" then
			out = Trim(Right(sTxtArray(i), (len(sTxtArray(i)) - 15)))
			if not bDidHeading then
				out = "SQL Instances: " & vbTab & Trim(out)
				bDidHeading = True
			end if
		else
			if Instr(sTxtArray(i), "Not a Cluster Resource" ) > 0 then
				out = ""
			else
				out = vbtab & Trim(Right(sTxtArray(i), (len(sTxtArray(i)) - 15)))
			end if
		end if
	end if
	if len(trim(out)) > 0 then
		'Now, output only non-blank lines
		echo Trim(out)
	End If
next

'Add a blank line at the end ... if we displayed any info
if bDidHeading Then echo vbCrLf


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
