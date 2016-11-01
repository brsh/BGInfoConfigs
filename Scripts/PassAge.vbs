Option Explicit
On Error Resume Next
' Modded From:
' https://community.spiceworks.com/scripts/show/1916-ldap-query-to-get-user-s-password-age

Dim sUserName, sReturnedDN, sUserFullDN, iPasswordLastSet, iTimeDifference
Dim wshNetwork

Set wshNetwork = CreateObject( "WScript.Network" )
sUserName = wshNetwork.UserName

sReturnedDN = SearchDistinguishedName(sUserName)
Set sUserFullDN = GetObject("LDAP://" & sReturnedDN)

iPasswordLastSet = sUserFullDN.PasswordLastChanged
iTimeDifference = Int(Now - iPasswordLastSet)
Echo iPasswordLastSet & " (" & iTimeDifference & " days old)" 

Public Function SearchDistinguishedName(ByVal sAccountName)
    ' Function:     SearchDistinguishedName
    ' Description:  Searches the DistinguishedName for a given SamAccountName
    ' Parameters:   ByVal sAccountName - The SamAccountName to search
    ' Returns:      The DistinguishedName Name
    Dim oRootDSE, oConnection, oCommand, oRecordSet

    Set oRootDSE = GetObject("LDAP://rootDSE")
    Set oConnection = CreateObject("ADODB.Connection")
    oConnection.Open "Provider=ADsDSOObject;"
    Set oCommand = CreateObject("ADODB.Command")
    oCommand.ActiveConnection = oConnection
    oCommand.CommandText = "<LDAP://" & oRootDSE.get("defaultNamingContext") & _
        ">;(&(objectCategory=User)(samAccountName=" & sAccountName & "));distinguishedName;subtree"
    Set oRecordSet = oCommand.Execute
    On Error Resume Next
    SearchDistinguishedName = oRecordSet.Fields("DistinguishedName")
    If Err.Number <> 0 Then
		SearchDistinguishedName = "Error - Invalid username"
		Err.Clear
	End If
    oConnection.Close
    Set oRecordSet = Nothing
    Set oCommand = Nothing
    Set oConnection = Nothing
    Set oRootDSE = Nothing
End Function