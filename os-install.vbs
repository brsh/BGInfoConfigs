' Special BGInfo Script
' OS Install Date v1.1
' Programmed by WindowsStar - Free To Use (c) 2012
' ---------------------------------------------------
Set dtmConvertedDate = CreateObject("WbemScripting.SWbemDateTime")
strComputer = "."
Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set ColOS = objWMIService.ExecQuery ("Select * from Win32_OperatingSystem")
For Each objOS in ColOS
    dtmConvertedDate.Value = objOS.InstallDate
    Echo dtmConvertedDate.GetVarDate
Next
