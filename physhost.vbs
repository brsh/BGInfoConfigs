On Error Resume Next
strValue = ""

'Set up to get our bit-ness (64 or 32)
Set objWMIService = GetObject( "winmgmts://./root/cimv2" )
Set colItems = objWMIService.ExecQuery( "SELECT * FROM Win32_Processor", , 48 )

iBit = 32
For Each objItem in colItems
	If objItem.AddressWidth = 64 Then iBit = 64
Next

'Set up to access the registry
strComputer = "."
Const HKLM = &h80000002

'Here we have to play around a bit due to the bit-ness
Set objCtx = CreateObject("WbemScripting.SWbemNamedValueSet")
objCtx.Add "__ProviderArchitecture", iBit
Set objLocator = CreateObject("Wbemscripting.SWbemLocator")
Set objServices = objLocator.ConnectServer("","root\default","","",,,,objCtx)
Set objStdRegProv = objServices.Get("StdRegProv") 

'Set up inParameters object
Set Inparams = objStdRegProv.Methods_("GetStringValue").Inparameters
Inparams.Hdefkey = HKLM
Inparams.Ssubkeyname = "Software\Microsoft\Virtual Machine\Guest\Parameters"
Inparams.Svaluename = "PhysicalHostName"
set Outparams = objStdRegProv.ExecMethod_("GetStringValue", Inparams,,objCtx)

'in case of Null, add empty text
strValue = Outparams.SValue & ""
 
If Len(Trim(strValue)) = 0 Then 
	strValue = "This Ain't Virtual, Fool"
End If
 
Echo strValue