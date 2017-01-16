
strComputer = "."   ' use "." for local computer 

' CONSTANTS
'
wbemImpersonationLevelImpersonate = 3
wbemAuthenticationLevelPktPrivacy = 6
sCol = vbTab

'=======================================================================
' MAIN
'=======================================================================

' Connect to machine
'
If Not strUser = "" Then

	' Connect using user and password
	'
	Set objLocator = CreateObject("WbemScripting.SWbemLocator")
	Set objWMI = objLocator.ConnectServer _
		(strComputer, "root\cimv2", strUser, strPassword)
	objWMI.Security_.ImpersonationLevel = wbemImpersonationLevelImpersonate
	objWMI.Security_.AuthenticationLevel = wbemAuthenticationLevelPktPrivacy
	
Else

	' Connect using current user
	'
	Set objWMI = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2") 

End If

' Get OS name
'
Set colOS = objWMI.InstancesOf ("Win32_OperatingSystem")

For Each objOS in colOS
	strName = objOS.Name
Next

If Instr(strName, "Windows 2000") > 0 Then

	'-------------------------------------------------------------------
	' Code for Windows 2000
	'-------------------------------------------------------------------

	' Get user name
	'
	Set colComputer = objWMI.ExecQuery("Select * from Win32_ComputerSystem")
	
	For Each objComputer in colComputer
		Wscript.Echo "User: " & objComputer.UserName
	Next

	' ------------------------------------------------------------------
	
Else

	' ------------------------------------------------------------------
	' Code for Windows XP or later
	' ------------------------------------------------------------------
	
	' Get interactive session
	'
	Set colSessions = objWMI.ExecQuery _ 
		  ("Select * from Win32_LogonSession ") 
	
	If colSessions.Count = 0 Then 
		' No interactive session found
	Else 
		'Interactive session found
		'
		Ech PadLeft("Full Name", 19) & PadLeft("User Name", 20) & PadLeft("Type", 14) & PadLeft("Logon Time", 20)

		For Each objSession in colSessions 		
			If (objSession.LogonType = 2) or (objSession.LogonType = 10) then
				Set colList = objWMI.ExecQuery("Associators of " _ 
				& "{Win32_LogonSession.LogonId=" & objSession.LogonId & "} " _ 
				& "Where AssocClass=Win32_LoggedOnUser Role=Dependent" ) 
					
				' Show user info
				'
				sUName = ""
				sFName = ""
				sDomain = ""
				For Each objItem in colList 
					sUName = objItem.Name & ""
					sFName = objItem.FullName & ""
					sDomain = objItem.Domain & ""
				Next 
				If sUName <> "" then
					sStart = objSession.StartTime & ""
					If objSession.LogonType = 2 then
						sType = "Interactive"
					Else
						sType = "Remote"
					End If
					Ech PadLeft(sFName, 19) & PadLeft(sDomain & "\" & sUName, 20) & PadLeft(sType, 14) & PadLeft(WMIDateStringToDate(sStart), 20)
				End If
			End If
		Next 
	End If 
	
	' ------------------------------------------------------------------


End If

Sub Ech(sText)
	Echo sText 
End Sub


Function PadRight(sOrig, iWidth)
	'right justify a column of text so "123" becomese "   123"
	Dim sRet, iMax
	iMax = iWidth - Len(sOrig)
	if iMax => 0 then
		sRet = String(iMax, " ") & sOrig
	else
		sRet = "~" & Right(sOrig, iWidth - 1 ) 
	end if
	PadRight = sRet & sCol
End Function

Function PadLeft(sOrig, iWidth)
	'left justify a column of text to a specific width
	Dim sRet, iMax
	iMax = iWidth - Len(sOrig)
	If iMax => 0 then 
		sRet = sOrig & String(iMax, " ")
	else
		sRet = Left(sOrig, iWidth - 1) & "~"
	end if
	PadLeft = sRet & sCol
End Function

Function WMIDateStringToDate(dtmDate)
On Error Resume Next
	WMIDateStringToDate = CDate(Mid(dtmDate, 5, 2) & "/" & _
	Mid(dtmDate, 7, 2) & "/" & Left(dtmDate, 4) _
	& " " & Mid (dtmDate, 9, 2) & ":" & Mid(dtmDate, 11, 2) & ":" & Mid(dtmDate,13, 2))
On Error GoTo 0
End Function
