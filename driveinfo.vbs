' Outputs: Driveletter - [Volumename] - FreeSpace
' 
' Written by Inge B. (ibr@lyse.net) for use with BGInfo 

Set objWMIService = GetObject("winmgmts:\\.\root\CIMV2") 
Set colItems = objWMIService.ExecQuery _ 
("SELECT * FROM Win32_LogicalDisk Where DriveType = 3") 

echo "  " & vbTab & PadRight("Free") & vbTab & PadRight("Free") & vbtab & PadRight("Total") & vbTab & "Format" & vbtab & "Label" 

For Each objItem In colItems 
	If IsNumeric(objItem.freespace) Then
		sSpace = objItem.freespace
		sName = objItem.VolumeName
		sDrive = objItem.DeviceID
		sSize = objItem.Size
		if isNumeric(sSize) then sPercent = Round(sSpace/sSize, 2) * 100
		
		sSpace = ReSize(sSpace)
		sSize = ReSize(sSize)
		 
		If Len(Trim(sName)) = 0 Then sName = "No Label"
		If sName = "" Then sName = "No Label"
		sFormat = objItem.FileSystem
	    	'freespace = sDrive & vbTab & sSpace & " | " & sPercent & "% free " & vbTab & sSize & " total " & vbTab & sName & ""
		freespace = sDrive & vbTab & PadRight(sSpace) & vbTab & PadRight(sPercent & "%") & vbTab & PadRight(sSize) & vbTab & sFormat & vbTab & sName 
    		echo freespace
	Else
		'echo "No Data Available"
	End If
Next

Function ReSize(sInteger)
	If sInteger >= 1073741824 then 
        	ReSize = Round(sInteger / 1073741824, 0)
		If Len(Resize) > 3 then 
			Resize = Round(Resize / 1000, 0) & "tb"
		Else
			Resize = Resize & "gb"
		End If
	elseif sInteger >= 1048576 then 
		ReSize = Round(sInteger / 1048576, 0)
		If Len(Resize) > 3 then 
			Resize = Round(Resize / 1000, 0) & "gb"
		Else
			Resize = Resize & "mb"
		End If
	elseif sInteger >= 1024 then 
		ReSize = Round(sInteger / 1024, 0)
		If Len(Resize) > 3 then 
			Resize = Round(Resize / 1000, 0) & "mb"
		Else
			Resize = Resize & "kb"
		End If
	Else 
		ReSize = sInteger & "b" 
	End If 
End Function

Function PadRight(sOrig)
	'right justify a column of text so "123" becomese "   123"
	Dim sRet
	sRet = String(6 - Len(sOrig), " ") & sOrig
	PadRight = sRet
End Function
