On Error Resume Next
Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\.\root\cimv2")
Set colSettings = objWMIService.ExecQuery ("Select * from Win32_Processor")
 
For Each objComputer in colSettings
     If objComputer.Architecture = 0 Then ArchitectureType = "32-Bit"
     If objComputer.Architecture = 6 Then ArchitectureType = "Intel Itanium"
     If objComputer.Architecture = 9 Then ArchitectureType = "64-Bit"
Next

Set colOperatingSystems = objWMIService.ExecQuery ("Select * from Win32_OperatingSystem")
For Each objOperatingSystem in colOperatingSystems
    OSCaption = Trim(Replace(objOperatingSystem.Caption,"Microsoft ",""))
    OSCaption = Replace(OSCaption,"Microsoft","")
    OSCaption = Replace(OSCaption,"(R)","")
    OSCaption = Trim(Replace(OSCaption,",","")) 
Next


Echo OSCaption & ", " & ArchitectureType
