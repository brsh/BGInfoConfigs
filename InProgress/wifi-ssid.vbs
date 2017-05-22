
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

'' Powershell version ... maybe...
' $strDump = netsh wlan show interfaces
' $objInterface = "" | Select-Object SSID,BSSID,Signal

' foreach ($strLine in $strDump) {
' 	if ($strLine -match "^\s+SSID") {
' 		$objInterface.SSID = $strLine -Replace "^\s+SSID\s+:\s+",""
' 	} elseif ($strLine -match "^\s+BSSID") {
' 		$objInterface.BSSID = $strLine -Replace "^\s+BSSID\s+:\s+",""
' 	} elseif ($strLine -match "^\s+Signal") {
' 		$objInterface.Signal = $strLine -Replace "^\s+Signal\s+:\s+",""
' 	}
' }

' # Do whatever with the resulting object. We'll just print it out here
' $objInterface