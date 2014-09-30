
Dim oWMI, oMSNdis, i, ID
Dim sSSID 

On Error Resume Next

Set oWMI = GetObject("winmgmts:")

Set oMSNdis = oWMI.ExecQuery("Select * from MSNdis_80211_ServiceSetIdentifier Where active=true")

For Each oSSID In oMSNdis
	For i = 0 To oSSID.Ndis80211SsId(0)
			ID = ID & Chr(oSSID.Ndis80211SsId(i + 4))
	Next
	sSSID = ID
Next

WScript.Echo sSSID

