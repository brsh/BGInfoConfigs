
if (get-module -ListAvailable -Verbose:$false | Where-Object { $_.Name -eq 'WebAdministration'}) {
	Try {
		Import-Module WebAdministration -ErrorAction Stop -Verbose:$false
		$all = @()
		Try {
			Get-ChildItem iis:\sites -ErrorAction Stop | where-object { $_.State -eq "Started" } | ForEach-Object {
				$out = New-Object psobject
				Add-member -InputObject $out -MemberType NoteProperty -Name "Site" -Value "$($_.Name)"
				Add-Member -InputObject $out -MemberType NoteProperty -Name "Path" -Value "$($_.PhysicalPath.ToString().Replace('\Empty', ''))"
				[string[]] $bindings = @()
				$_.Bindings.Collection | where-object { ($_.Protocol -match "http") -or ($_.Protocol -match "ftp") } | foreach-object {
					$bindings += "$($_.Protocol)/$($_.BindingInformation.ToString().Trim(":"))"
				}
				Add-member -InputObject $out -MemberType NoteProperty -Name "Bindings" -Value $bindings
				$all += $out
			}
			$all
		} Catch {
			# No sites Found
		}
	} catch {
		# Web Administration Module failed to load
	}
}