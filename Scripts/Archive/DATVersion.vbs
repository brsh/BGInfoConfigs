const HKEY_CURRENT_USER = &H80000001
const HKEY_LOCAL_MACHINE = &H80000002
strComputer = "."
 
Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" &_
 strComputer & "\root\default:StdRegProv")
 
strKeyPath = "SOFTWARE\McAfee\AVEngine"
strValueName = "AVDatVersion"
oReg.GetDWORDValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,strMajor

strKeyPath = "SOFTWARE\McAfee\AVEngine"
strValueName = "AVDatVersionMinor"
oReg.GetDWORDValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,strMinor

Echo strMajor & "." & strMinor