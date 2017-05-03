# Test for query.exe, and do nothing if it's not there
if (get-command query.exe -ErrorAction silentlycontinue) {
	# Run the 'query user' command and catch the output
	Try {
		$quserOut = (query.exe user 2>&1)
		if ($quserOut -match "No user exists") { exit }
		if ($quserOut.Count -lt 2 ) { exit }
	} Catch { exit }

	# Create our holder variable
	$out = @()
	# Replace all (more than 2) spaces with commas in the returned data and parse it thru the CSV cmdlet
	$users = $quserOut -replace '\s{2,}', ',' | ConvertFrom-CSV -Header 'UserName', 'Session', 'ID', 'State', 'IdleTime', 'LogonTime'
	# Remove the header row by ignoring row 0
	$users = $users[1..$users.count]
	#Now run thru each item to format the data
	for ($i = 0; $i -lt $users.count; $i++) {
		# Sometimes, there is no session info, so we have to bump data down a slot
		if ($users[$i].Session -match '^\d+$') 	{
			$users[$i].logonTime = $users[$i].idleTime
			$users[$i].idleTime = $users[$i].STATE
			$users[$i].STATE = $users[$i].ID
			$users[$i].ID = $users[$i].Session
			$users[$i].Session = $null
		}
		# query user indicates the current user with '>'
		$users[$i].Username = [string] $users[$i].UserName.Replace('>', '')
		# cast the correct datatypes
		$users[$i].ID = [int] $users[$i].ID
		# query user also includes idle time for active users... and it's usually incorrect
		if ($users[$i].State -match 'Active') {
			$users[$i].idleTime = "0:0"
		}
		else {
			# Set the idletime to a format we can use as a TimeSpan
			$idleString = $users[$i].idleTime
			if ($idleString -eq '.') { $users[$i].idleTime = 0 }
			# if it's just a number by itself, insert a '0:' in front of it. Otherwise [timespan] cast will interpret the value as days rather than minutes
			if ($idleString -match '^\d+$') { $users[$i].idleTime = "0:$($users[$i].idleTime)" }
			# if it has a '+', change the '+' to a colon and add ':0' to the end
			if ($idleString -match "\+") {
				$newIdleString = $idleString -replace "\+", ":"
				$newIdleString = $newIdleString + ':0'
				$users[$i].idleTime = $newIdleString
			}
		}
		# and make the dates human readable
		$t = [timespan]$users[$i].idleTime
		$users[$i].idleTime =  [string]::Format("{0:0}d {1:00}h {2:00}m", $t.Days, $t.Hours, $t.Minutes);
		$users[$i].logonTime = ([datetime]$users[$i].logonTime).ToString('dd-MMM-yyyy  HH:mmt')
	}
	#Sort by user name
	$users = $users | Sort-Object -Property UserName,IdleTime
	#Force the fields we want (i.e., no ID field)
	$out += $users | Select-Object UserName,Session,State,IdleTime,LogonTime
	#And output the result
	$out
}