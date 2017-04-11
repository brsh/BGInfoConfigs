
if (get-module -ListAvailable | Where-Object { $_.Name -eq 'WebAdministration'}) {
	Import-Module WebAdministration
	$all = @()
	Try {
		Get-ChildItem iis:\sites | where-object { $_.State -eq "Started" } | ForEach-Object {
			$out = New-Object psobject
			Add-member -InputObject $out -MemberType NoteProperty -Name "Site" -value "$($_.Name) `($($_.PhysicalPath.ToString().Replace('\Empty', ''))`)"
			[string] $bindings = ""
			$_.Bindings.Collection | where-object { $_.Protocol -match "http" } | foreach-object { $bindings += "$($_.Protocol)/$($_.BindingInformation.ToString().Trim(":"))`n" }
			$bindings = $bindings.Trim("`n")
			Add-member -InputObject $out -MemberType NoteProperty -Name "Bindings" -value $bindings
			$all += $out
		}
		$all | fl
	} Catch {
		# No sites Found
	}
}