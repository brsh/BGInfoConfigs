Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
Set colOperatingSystems = objWMIService.ExecQuery("Select * From Win32_PerfFormattedData_PerfOS_System")

For Each objOS in colOperatingSystems
    intSystemUptime = objOS.SystemUpTime
Next

' Calculate Days: save total seconds
intSecsTotal     = intSystemUpTime
' Divide total seconds by daily seconds and truncate decimal portion
intDays          = Fix( intSecsTotal / 86400 )
' Isolate remaining [hourminutesecond] total seconds = total seconds - ( days * 86400 seconds )
intSecsRemaining = ( intSecsTotal - ( intDays * 86400 ))
' Calculate Hours: save total remaining seconds
intSecsTotal     = intSecsRemaining
' Divide total seconds by hourly seconds and truncate decimal portion
intHours         = Right(Fix( intSecsTotal / 3600 ), 2)
' Isolate remaining [minutesecond] total seconds = total [hourminutesecond] seconds - ( hours * 3600 seconds )
intSecsRemaining = ( intSecsTotal - ( intHours * 3600 ))
' Calculate Minutes and Seconds: save total remaining seconds
intSecsTotal     = intSecsRemaining
' Divide total seconds by minute seconds and truncate decimal portion
intMinutes       = Right("00" & Fix( intSecsTotal / 60 ), 2)
' Isolate remaining total seconds = Total [minuteandsecond] seconds - (minutes * 60 seconds)
intSeconds       = Right("00" & ( intSecsTotal - ( intMinutes * 60 )), 2)
Echo intDays & "d " & intHours & "h " & intMinutes & "m " & intSeconds & "s"
