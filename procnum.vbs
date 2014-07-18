Set objWMIService = GetObject("winmgmts:\\.\root\CIMV2") 
Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_ComputerSystem") 

For Each objItem In colItems 
    	echo objItem.NumberofProcessors & " Physical / " & objItem.NumberofLogicalProcessors & " Logical"
Next
