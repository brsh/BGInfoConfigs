'Option Explicit

'On Error Resume Next
Set oWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\.\root\cimv2")
Set colSettings = oWMIService.ExecQuery ("Select * from Win32_Processor")
 
For Each Proc in colSettings
	sCores = Proc.NumberofCores 
	sLogical = Proc.NumberofLogicalProcessors
Next

Echo sCores & " physical / " & sLogical & " logical cores"
