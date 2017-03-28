# First, test if SQL instances are even available
if (test-path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL") {
	# Define base HKLM
	$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', '.')
	# Open the Reg's List of All Instances
	$regKey= $reg.OpenSubKey("SOFTWARE\\Microsoft\\Microsoft SQL Server\\Instance Names\\SQL" )
	# And get all the Value NAMES
	$values = $regkey.GetValueNames()
	# Create the array that will hold all the list objects
	$all = @()
	# Now, cycle through all the Value NAMES to find specific instance information
	$values | ForEach-Object {
		# The Actual Value NAME
		$value = $_
		# The Value VALUE
		$inst = $regKey.GetValue($value)
		# Build the path the to the Instance in the registry
		$path = "SOFTWARE\\Microsoft\\Microsoft SQL Server\\" + $inst
		# Get the Version info
		$version = $reg.OpenSubKey($path + "\\MSSQLServer\\" + "CurrentVersion").GetValue("CurrentVersion")
		# Make an attempt for Cluster Information
		try {
			[bool] $IsCluster = $true
			$ClusterName = ""
			$ClusterName = $reg.OpenSubKey($path + "\\Cluster").GetValue("ClusterName")
			try {
				$ClusterOwner = (Get-WmiObject -Namespace "root\mscluster" -Class MSCluster_Resource |
					Where-Object {($_.Name -match $ClusterName) -and ($_.Type -eq "Network Name")} |
					Select-Object OwnerNode -First 1).OwnerNode
			} catch { $ClusterOwner = ""}
		} catch { [bool] $IsCluster = $false }
		# Create a new object to hold this info, and add our custom info
		$out = new-object psobject
		Add-member -InputObject $out -MemberType NoteProperty -Name "SQLInstanceName" -value $value
		Add-member -InputObject $out -MemberType NoteProperty -Name "Version" -value $version
		if ($IsCluster) {
			Add-member -InputObject $out -MemberType NoteProperty -Name "ClusterName" -value $ClusterName
			Add-member -InputObject $out -MemberType NoteProperty -Name "OwningNode" -value $ClusterOwner
		}
		# Add it to the array
		$all += $out
	}
	# Output all the objects in a nice table (as text)
	$all | Format-Table -AutoSize
}