
Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\.\root\cimv2")
Set colSettings = objWMIService.ExecQuery ("Select * from Win32_PhysicalMemory")
 
For Each objComputer in colSettings
	iCapacity = iCapacity + CDbl(objComputer.Capacity)
Next

Echo GBNum(iCapacity)

Function GBNum(sNumber)
	'Here, we format numbers to drive sizes (so 123 becomes 123b for bytes; 27232130 becomes 27mb)
	Dim sRet, iLen

 	If Left(sNumber / 1024, 1) = "9" Then
 		iLen = Len(sNumber) - 1
 	Else
		iLen = Len(sNumber)
 	End If

	Select Case iLen
		Case 0, 1, 2, 3
			'bytes
			sRet = FormatNumber(sNumber, 1) & "B"
		Case 4, 5, 6
			'kilobytes
			sRet = FormatNumber(sNumber / 1024, 1) & "KB"
		Case 7, 8, 9
			'megabytes
			sRet = FormatNumber(sNumber / 1048576, 1) & "MB"
		Case 10, 11, 12
			'gigabytes
			sRet = FormatNumber(sNumber / 1073741824, 1) & "GB"
		Case 13, 14, 15
			'terabytes
			sRet = FormatNumber(sNumber / 1099511627776, 1) & "TB"
		Case 16, 17, 18
			'petabytes
			sRet = FormatNumber(sNumber / 1125899906842624, 1) & "PB"
		Case 19, 20, 21
			'exabytes
			sRet = FormatNumber(sNumber / 1.152921504606847e+18, 1) & "EB"
		Case 22, 23, 24
			'zettabytes
			sRet = FormatNumber(sNumber / 1.180591620717411e+21, 1) & "ZB"
		Case 25, 26, 27
			'yottabytes (really? I'm gonna see this in my life??)
			sRet = FormatNumber(sNumber / 1.208925819614629e+24, 1) & "YB"		
		Case Else
			'bytes
			sRet = FormatNumber(sNumber, 1) & "B"
	End Select
	'sRet = PadRight(sRet)
	GBNum = sRet

End Function