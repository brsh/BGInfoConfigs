Option Explicit
on error resume next

Dim wShell, sScriptIs, sAppToRun, sRetVal, sTxtArray, i, out, bBlank, sTemp, Bitness, sPSPath

Set wShell = CreateObject("wscript.shell")

'Define our PowerShell Script and Command Line - you'll want to adjust this if the path is diff
sScriptIs = "c:\bginfo\scripts\PowerShell\Get-SystemReport.ps1"

Bitness = GetBitness
if Bitness = 32 then
	sPSPath = "%SystemRoot%\sysnative\"
else
	sPSPath = "%SystemRoot%\system32\"
end if

sAppToRun = sPSPath & "WindowsPowerShell\v1.0\powershell.exe -InputFormat None -NoProfile -NoLogo -WindowStyle Hidden -ExecutionPolicy Bypass -file " & sScriptIs & " -BGInfo"

'This version disables/bypasses the execution policy - even if it can't be bypassed :)
'Use this... um... if you need.. but .. um... well.. um... gotta go!
'sAppToRun = sPSPath & "WindowsPowerShell\v1.0\powershell.exe -NoProfile -NoLogo -WindowStyle Hidden -ExecutionPolicy Bypass -command " & chr(34) & " & {($ctx = $ExecutionContext.GetType().GetField('_context', 'nonpublic,instance').GetValue( $executioncontext)).GetType().GetField('_authorizationManager', 'nonpublic,instance').SetValue($ctx, (New-Object System.Management.Automation.AuthorizationManager 'Microsoft.PowerShell')); " & sScriptIs & " -BGInfo }" & chr(34)

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
	Dim oApp, dteWait
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

function GetBitness()
	Dim WshProcEnv, process_architecture, Bitness
	Set WshProcEnv = wShell.Environment("Process")

	'This will be the process-level bitness (not processor)
	process_architecture= WshProcEnv("PROCESSOR_ARCHITECTURE")

	If process_architecture = "x86" Then
		Bitness = 32
	Else
		Bitness = 64
	End if
	GetBitness = Bitness

End function
