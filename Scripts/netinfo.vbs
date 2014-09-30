Dim cNet()

Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\.\root\cimv2")
Set colItems = objWMIService.ExecQuery ("Select * From Win32_NetworkAdapter") 'WHERE NetConnectionStatus=2
i = 0
For Each oItem in colItems
	If oItem.MACAddress <> NUL Then 
   		ReDim Preserve cNet(i)
   		Set cNet(i) = New Network
		cNet(i).MACAddress = oItem.MACAddress & ""
		cNet(i).AdapterType = oItem.AdapterType
		cNet(i).Caption = oItem.Caption
		cNet(i).Description = oItem.Description
		cNet(i).Manufacturer = oItem.Manufacturer
		cNet(i).Name = oItem.Name
		cNet(i).NetConnectionID = oItem.NetConnectionID
		cNet(i).NetConnectionStatus = oItem.NetConnectionStatus
		cNet(i).NetEnabled = oItem.NetEnabled
		cNet(i).PhysicalAdapter = oItem.PhysicalAdapter
		cNet(i).ProductName = oItem.ProductName
		cNet(i).Speed = oItem.Speed
		i = i + 1
	End If
Next

Rem Configuration Values
blnShowCaption = True
blnShowIPAddress = True
blnShowIPv6 = False
blnShowDHCP = True
blnShowDHCPExpire = True
blnShowGateway = True
blnShowSubnet = True
blnShowDNSServerSearchOrder = True
blnShowWINSPrimaryServer = True

Rem Define query to get information - IPEnabled restricts the information to active Adaptors
Set colItems = objWMIService.ExecQuery("Select * from Win32_NetworkAdapterConfiguration Where IPEnabled = TRUE")

For x = 0 to UBound(cNet)
Rem Get each adaptor from the table

For Each objItem In colItems
If objItem.MACAddress = cNet(x).MACAddress Then
	Rem Get each IP address for the adaptor
	For Each strIPAddress In objItem.IPAddress
		Rem check to see if it is an IPv6 address and whether we want it
		If strIPAddress = "0.0.0.0" Then
		Else
			If InStr(strIPAddress, "::") = 0 Or blnShowIPv6 Then
				Rem Set up the correct adaptor name by stringing the first 12 characters and also the MAC address
				strCaption = fnSubstring(objItem.Caption, 12, 1024) & " (" & objItem.MACAddress & ")"
				Rem Format DHCP info if required
				If objItem.DHCPEnabled and blnShowDHCP Then
					If blnShowDHCPExpire Then
						strDHCP = " (Expires: " & fnDisplayDate(objItem.DHCPLeaseExpires) & ")"
					End If
				Else
					strDHCP = ""
				End If
				strIPSubnet = objItem.IPSubnet(0)
				strIPSubnet = " / " & strIPSubnet
				
				If Left(cNet(x).IPFormated, 3) = "   " Then
					cNet(x).IPFormated = cNet(x).IPFormated & vbTab & vbTab & vbTab & vbTab & strIPAddress + strIPSubnet & vbCrLf
				Else
					cNet(x).IPFormated = "       IP Address:" & vbTab & strIPAddress + strIPSubnet & vbCrLf
				End If
				If Not IsNull(objItem.DHCPServer) Then
					cNet(x).IPFormated = cNet(x).IPFormated & vbTab & "       DHCP Server:" & vbTab & objItem.DHCPServer + strDHCP & vbCrLf
				End If
				If Not IsNull(objItem.DefaultIPGateway) Then
					cNet(x).IPFormated = cNet(x).IPFormated & vbTab & "       Gateway:" & vbTab & Join(objItem.DefaultIPGateway, ", ") & vbCrLf
				End If

				'Call fnDisplayValue(blnShowSubnet,objItem.IPSubnet(0),"  Subnet",3)
				If Not IsNull(objItem.DNSServerSearchOrder) Then 
					strDNSServerSearchOrder = Join(objItem.DNSServerSearchOrder, ", ")
					cNet(x).IPFormated = cNet(x).IPFormated & vbTab & "       DNS Servers:" & vbTab & strDNSServerSearchOrder & vbCrLf
				End If
				strDNSServerSearchOrder = ""
			End If
		End If
	Next
End If
Next
Next
'Rem print the end of script message
'REM Echo strMessage

sResult = ""

For x = 0 to UBound(cNet)
	If cNet(x).NetConnectionStatus <> "Unknown" Then
		sResult = sResult & vbTab & cNet(x).Name & vbCrLf
		sResult = sResult & vbTab & cNet(x).MacAddress & " | " & cNet(x).NetEnabled & " | " & cNet(x).NetConnectionStatus & " | " & cNet(x).Speed & vbCrLf
		sResult = sResult & vbTab & cNet(x).IPFormated
		sresult = sResult & vbCrLf
	End If
Next

Echo sResult

Rem End of Programme

Rem Procedures & Functions

Function fnDisplayValue(p_valueLogical, p_valueVar, p_valueDisplay, p_valueTab)
Dim strVar, sReturnTxt

If p_valueLogical Then
	Rem if the value is an array the cycle through each value
	If IsArray(p_valueVar) Then
		For Each strVar In p_valueVar
			Rem if the value is a string then display it, otherwise ignore it 
			If VarType(strVar) = 8 Then
				sReturnTxt = p_valueDisplay & String(p_valueTab," ") & strVar
			End If      
		Next
	Else
		strVar = p_valueVar
		Rem if the value is a string then display it, otherwise ignore it 
			If VarType(strVar) = 8 Then
				sReturnTxt = p_valueDisplay & String(p_valueTab," ") & strVar
			End If      
		End If
	End If 
	If Len(Trim(sReturnTxt)) = 0 Then
		fnDisplayValue = ""
	Else
		fnDisplayValue = sReturnTxt & vbCrLf
	End If
End Function

Rem Function to pull the a substring out from a string
 
Function fnSubstring(p_strData,p_intStart,p_intLength )

   Dim intLen
   intLen = Len(p_strdata)

   If p_intStart < 1 Or p_intStart > intLen Then
      fnSubstring = ""
   Else
      If p_intLength > intLen - p_intStart + 1 Then
         p_intLength = intLen - p_intStart + 1
      End If
      fnSubstring = Right(Left(p_strData, p_intStart + p_intLength - 1), p_intLength)
   End If 

End Function

Function fnDisplayDate(p_strDate)
	Dim strYear, strMonth, strDay, strHour, strMinute, strSecond
	strYear =   fnSubstring(p_strDate,1,4)
	strMonth =  fnSubstring(p_strDate,5,2)   
	strDay =    fnSubstring(p_strDate,7,2)   
	strHour =   fnSubstring(p_strDate,9,2)   
	strMinute = fnSubstring(p_strDate,11,2)   
	strSecond = fnSubstring(p_strDate,13,2)   
	fnDisplayDate = cdate(strMonth & "/" & strDay & "/" & strYear & " " & strHour & ":" & strMinute & ":" & strSecond)
End Function 


'*****************************************************************
'Classes
Class Network
	'This class creates a printer object so we don't need multiple arrays
Public AdapterType
Public Caption
Public Description
Public MACAddress
Public Manufacturer
Public Name
Public NetConnectionID
Private internalConnectionStatus
Public Property Get NetConnectionStatus
	NetConnectionStatus = internalConnectionStatus
End Property
Public Property Let NetConnectionStatus(ByVal statIn)
	Select Case statIn
		Case 0 
			internalConnectionStatus = "Disconnected"
		Case 1
			internalConnectionStatus = "Connecting"
		Case 2 
			internalConnectionStatus = "Connected"
		Case 3 
			internalConnectionStatus = "Disconnecting"
		Case 4 
			internalConnectionStatus = "Hardware not present"
		Case 5 
			internalConnectionStatus = "Hardware disabled"
		Case 6 
			internalConnectionStatus = "Hardware malfunction"
		Case 7 
			internalConnectionStatus = "Media disconnected"
		Case 8 
			internalConnectionStatus = "Authenticating"
		Case 9 
			internalConnectionStatus = "Authentication succeeded"
		Case 10 
			internalConnectionStatus = "Authentication failed"
		Case 11
			internalConnectionStatus = "Invalid address"
		Case 12
			internalConnectionStatus = "Credentials required"
		Case Else
			internalConnectionStatus = "Unknown"
	End Select
End Property
Private Internal_NetEnabled
Public Property Get NetEnabled
	NetEnabled = Internal_NetEnabled
End Property
Public Property Let NetEnabled (ByVal statIn)
	
	If statIn Then
		Internal_NetEnabled = "Enabled"
	ElseIf Not statIn Then
		Internal_NetEnabled = "Disabled"
	Else
		Internal_NetEnabled = "Unknown Status"
	End If
End Property

Public NetworkAddresses
Private internal_PhysicalAdapter
Public Property Get PhysicalAdapter
	PhysicalAdapter = internal_PhysicalAdapter
End Property
Public Property Let PhysicalAdapter(ByVal statIn)
	If statIn Then
		internal_PhysicalAdapter = "Physical Adapter"
	ElseIf Not statIn Then
		internal_PhysicalAdapter = "Virtual Adapter"
	Else
		internal_PhysicalAdapter = "Unknown Adapter"
	End If
End Property
Public ProductName
Private internal_Speed
Public Property Get Speed
	Speed = internal_Speed
End Property
Public Property Let Speed(ByVal statIn)
	If IsNumeric(statIn) Then
		Select Case Len(statIn)
			Case 0, 1, 2, 3
				internal_Speed = statIn & "bps / " & statIn/8 & "Bps"
			Case 4, 5, 6
				internal_Speed = statIn/1000 & "kbps / " & (statIn/8)/1000 & "KBps"
			Case 7, 8, 9
				internal_Speed = statIn/1000000 & "mbps / " & (statIn/8)/1000000 & "MBps"
			Case 10, 11, 12
				internal_Speed = statIn/1000000000 & "gbps / " & (statIn/8)/1000000000 & "GBps"
			Case 13, 14, 15
				internal_Speed = statIn/1000000000000 & "gbps / " & (statIn/8)/1000000000000 & "GBps"
			Case 16, 17, 18
				internal_Speed = Round(statIn/1000000000000000, 2) & "gbps / " & Round((statIn/8)/1000000000000000, 2) & "GBps"
			Case 19, 20, 21
				internal_Speed = Round(statIn/1000000000000000000, 2) & "gbps / " & Round((statIn/8)/1000000000000000000, 2) & "GBps"
			Case Else
				internal_Speed = statIn & "bps / " & statIn/8 & "Bps"
		End Select
	Else
		internal_Speed = "Unknown bps"
	End If
End Property
Public Gateway
Public DNS
Public IP
Public IPFormated
Public Mask
Public DHCP
End Class

'End Classes
'*****************************************************************





 

'



' 
' 
' ' Outputs: Driveletter - [Volumename] - FreeSpace
' ' 
' ' Written by Inge B. (ibr@lyse.net) for use with BGInfo 
' 
' Set objWMIService = GetObject("winmgmts:\\.\root\CIMV2") 
' Set colItems = objWMIService.ExecQuery _ 
' ("SELECT * FROM Win32_LogicalDisk Where DriveType = 3") 
' 
' echo "  " & vbTab & PadRight("Free") & vbTab & PadRight("Free") & vbtab & PadRight("Total") & vbtab & "Label"
' 
' For Each objItem In colItems 
' 	If IsNumeric(objItem.freespace) Then
' 		sSpace = objItem.freespace
' 		sName = objItem.VolumeName
' 		sDrive = objItem.DeviceID
' 		sSize = objItem.Size
' 		if isNumeric(sSize) then sPercent = Round(sSpace/sSize, 2) * 100
' 		
' 		sSpace = ReSize(sSpace)
' 		sSize = ReSize(sSize)
' 		 
' 		If Len(Trim(sName)) = 0 Then sName = "No Label"
' 		If sName = "" Then sName = "No Label"
' 	    	'freespace = sDrive & vbTab & sSpace & " | " & sPercent & "% free " & vbTab & sSize & " total " & vbTab & sName & ""
' 		freespace = sDrive & vbTab & PadRight(sSpace) & vbTab & PadRight(sPercent & "%") & vbTab & PadRight(sSize) & vbTab & sName
'     		echo freespace
' 
' 	Else
' 		'echo "No Data Available"
' 	End If
' Next
' 
' Function ReSize(sInteger)
' 	If sInteger >= 1073741824 then 
'         	ReSize = Round(sInteger / 1073741824, 0)
' 		If Len(Resize) > 3 then 
' 			Resize = Round(Resize / 1000, 0) & "tb"
' 		Else
' 			Resize = Resize & "gb"
' 		End If
' 	elseif sInteger >= 1048576 then 
' 		ReSize = Round(sInteger / 1048576, 0)
' 		If Len(Resize) > 3 then 
' 			Resize = Round(Resize / 1000, 0) & "gb"
' 		Else
' 			Resize = Resize & "mb"
' 		End If
' 	elseif sInteger >= 1024 then 
' 		ReSize = Round(sInteger / 1024, 0)
' 		If Len(Resize) > 3 then 
' 			Resize = Round(Resize / 1000, 0) & "mb"
' 		Else
' 			Resize = Resize & "kb"
' 		End If
' 	Else 
' 		ReSize = sInteger & "b" 
' 	End If 
' End Function
' 
' Function PadRight(sOrig)
' 	'right justify a column of text so "123" becomese "   123"
' 	Dim sRet
' 	sRet = String(6 - Len(sOrig), " ") & sOrig
' 	PadRight = sRet
' End Function
