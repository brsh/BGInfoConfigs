'Option Explicit

'On Error Resume Next
Set oWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\.\root\cimv2")
Set colSettings = oWMIService.ExecQuery ("Select * from Win32_Processor")
 
For Each Proc in colSettings
	sProcName = proc.Name
	sProcName = Replace(sProcName, "(R)", "")
	sProcName = Replace(sProcName, "(TM)", "")
	sProcName = Replace(sProcName, "CPU ", "")
	sProcName = Replace(sProcName, "Intel ", "")
	sProcName = Replace(sProcName, "  ", "")
	If InStr(sProcName, "@") > 0 Then sProcName = Left(sProcName, InStr(sProcName, "@") - 1)
	sProcName = Trim(sProcName)

	MaxSpeed = Proc.MaxClockSpeed
	If Not IsNull(MaxSpeed) then
		Select Case Len(MaxSpeed)
			Case 4, 5, 6
				MaxSpeed = Round((MaxSpeed / 1000), 2) & "Ghz"
			Case Else
				
		End Select
	End If
	
	sCores = Proc.NumberofCores 
	sLogical = Proc.NumberofLogicalProcessors
	
Next

Set colItems = oWMIService.ExecQuery("SELECT * FROM Win32_ComputerSystem") 

For Each oItem In colItems 
   	sSockets = oItem.NumberofProcessors
Next

Echo sCores & " physical / " & sLogical & " logical cores, per socket"
