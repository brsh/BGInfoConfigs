On Error Resume Next
Set oWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\.\root\cimv2")
Set cSettings = oWMIService.ExecQuery ("Select * FROM Win32_ComputerSystem")

For Each oComputer in cSettings
     sManu=oComputer.Manufacturer & ""
     sModel=oComputer.Model & ""
     If objComputer.Architecture = 9 Then ArchitectureType = "64-Bit"
Next

If instr(sManu, "VMWare") > 0 then
	Set cSN = oWMIService.ExecQuery ("Select * from Win32_Bios")
	For Each oSN in cSN
		sSN = oSN.SerialNumber & ""
		sSN = " - " & sSN
	Next
End If

Echo sManu & " - " & sModel & sSN