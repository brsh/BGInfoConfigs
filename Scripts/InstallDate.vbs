Option Explicit
On Error Resume Next

Dim oWMIService, colOS, oOS, newDate

Function GetWMIDate(wmidate)
	GetWMIDate = CDate(Mid((wmidate), 5, 2) & "/" & _
		Mid((wmidate), 7, 2) & "/" & _
		Left((wmidate), 4) & " " & _
		Mid ((wmidate), 9, 2) & ":" & _
	    Mid((wmidate), 11, 2) & ":" & _
	    Mid((wmidate), 13, 2))
End Function

Err.Clear

Set oWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2") 
Set colOS = oWMIService.ExecQuery("Select * from Win32_OperatingSystem") 
If err.Number = 0 Then
	For Each oOS in colOS 
		newDate = GetWMIDate(oOS.InstallDate)
		if LEN(newDate) > 0 then 
	 		Echo newDate
 		Else
 			Echo "Error Getting Date"
 			Exit For
 		End If
	Next
Else
	Echo "Error Getting Date"
End If


