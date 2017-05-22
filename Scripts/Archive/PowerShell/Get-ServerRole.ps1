#Test that the Servermanager module is available
if (Get-Module -ListAvailable | Where-Object { $_.Name -eq 'ServerManager'}) {
	#Pull in all the installed "top level" roles
	try {
		Import-Module ServerManager
		$roles = Get-WindowsFeature | Where-Object { $_.Installed } | Where-Object { $_.Path -notmatch '\\' }

		#Create the array to hold the objects
		$all = @()

		#Parse through them for the ones we care about:
		$roles | ForEach-Object {
			if ( $_.DisplayName -eq 'Active Directory Certificate Services') {
				$SubItem = $null
				Try {
					#Let's see if we can pull the name of our Certificate Authority...
					$SubItem = (certutil.exe -CAInfo sanitizedname)
					$SubItem = (($SubItem -like "Sanitized*").Split(":")[1]).Trim()
				} Catch { $SubItem = $null }
				$Abbrev = "Cert/CA"
				$NickName = $Abbrev
				if ($SubItem.ToString().Length -gt 0) { $NickName = "$Abbrev ($SubItem)" }
				$all += New-Object -Type psobject -Property @{
					Role = "Active Directory Certificate Services"
					Abbreviation = $Abbrev
					SubItem = $SubItem
					Qualified = $NickName
				}
			}
			if ( $_.DisplayName -eq 'Active Directory Domain Services') {
				$SubItem = $null
				try {
					#Let's see if we can pull the domain name
					$SubItem = (get-addomain -Current LocalComputer).NetBIOSName
				} Catch { $SubItem = $null }
				$Abbrev = "DC"
				$NickName = $Abbrev
				if ($SubItem.ToString().Length -gt 0) { $NickName = "$Abbrev ($SubItem)" }
				$all += New-Object -Type psobject -Property @{
					Role = "Active Directory Domain Services"
					Abbreviation = $Abbrev
					SubItem = $SubItem
					Qualified = $NickName
				}
			}
			if ( $_.DisplayName -eq 'Active Directory Federation Services') {
				$SubItem = $null
				Try {
					#Let's see if we tell if we're Federation or Proxy (or both)
					$IsFederation = (Get-WindowsFeature -Name ADFS-Federation -ErrorAction Stop).Installed
					$IsProxy = (Get-WindowsFeature -Name ADFS-Proxy -ErrorAction Stop).Installed
					$SubItem = ""
					if ($IsFederation) { $SubItem = "ADFS" }
					if ($IsProxy) {
						if ($SubItem.Length -gt 0) { $SubItem = $SubItem + " & " } else { $SubItem = "ADFS "}
						$SubItem = $SubItem + "Proxy"
					}
				} Catch { $SubItem = $null }
				$ADFSFound = $true
				$Abbrev = "ADFS"
				$NickName = $Abbrev
				if ($SubItem.ToString().Length -gt 0) { $NickName = $SubItem } else { $NickName = $Abbrev }
				$all += New-Object -Type psobject -Property @{
					Role = "Active Directory Federation Services"
					Abbreviation = $Abbrev
					SubItem = $SubItem
					Qualified = $NickName
				}
			}
			if ( $_.DisplayName -eq 'DHCP Server') {
				$SubItem = $null
				$Abbrev = "DHCP"
				$NickName = $Abbrev
				$all += New-Object -Type psobject -Property @{
					Role = "DHCP Server"
					Abbreviation = $Abbrev
					SubItem = $SubItem
					Qualified = $NickName
				}
			}
			if ( $_.DisplayName -eq 'DNS Server') {
				$SubItem = $null
				try {
					#Let's see if we can pull the number of "real" domains this dns serves
					$SubItem = (Get-DnsServerZone | Where-Object { (-not $_.IsAutoCreated) -and ($_.IsDSIntegrated) }).Count
				} Catch { $SubItem = $null }
				$Abbrev = "DNS"
				$NickName = $Abbrev
				if ($SubItem.ToString().Length -gt 0) { $NickName = "$Abbrev ($SubItem zones)" }
				$all += New-Object -Type psobject -Property @{
					Role = "DNS Server"
					Abbreviation = $Abbrev
					SubItem = $SubItem
					Qualified = $NickName
				}
			}
			if ( $_.DisplayName -eq 'Remote Desktop Services') {
				$SubItem = $null
				$Abbrev = "RDP"
				$NickName = $Abbrev
				$all += New-Object -Type psobject -Property @{
					Role = "Remote Desktop Services"
					Abbreviation = $Abbrev
					SubItem = $SubItem
					Qualified = $NickName
				}
			}
			if ( $_.DisplayName -eq 'Web Server (IIS)') {
				$SubItem = $null
				Try {
					#Let's see if we can count how many running sites we have...
					Import-Module WebAdministration -ErrorAction Stop
					$SubItem = (Get-ChildItem iis:\sites | Where-Object { $_.State -eq 'Started' }).Count
				} Catch { $SubItem = $null }
				$Abbrev = "IIS"
				$NickName = $Abbrev
				if ($SubItem.ToString().Length -gt 0) { $NickName = "$Abbrev ($SubItem sites)" }
				$all += New-Object -Type psobject -Property @{
					Role = "Web Server (IIS)"
					Abbreviation = $Abbrev
					SubItem = $SubItem
					Qualified = $NickName
				}
			}
			if ( $_.DisplayName -eq 'Windows Server Update Services') {
				$SubItem = $null
				Try {
					#Let's see if we can pull the number of clients...
					[reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | Out-Null
					$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer($env:COMPUTERNAME, $false, 8530)
					$SubItem = $wsus.GetComputerTargetCount()
				} Catch { $SubItem = $null }
				$Abbrev = "WSUS"
				$NickName = $Abbrev
				if ($SubItem.ToString().Length -gt 0) { $NickName = "$Abbrev ($SubItem clients)" }
				$all += New-Object -Type psobject -Property @{
					Role = "Windows Server Update Services"
					Abbreviation = $Abbrev
					SubItem = $SubItem
					Qualified = $NickName
				}
			}
			if ( $_.DisplayName -eq 'SMTP Server') {
				$SubItem = $null
				$Abbrev = "SMTP"
				$NickName = $Abbrev
				$all += New-Object -Type psobject -Property @{
					Role = "SMTP Server"
					Abbreviation = $Abbrev
					SubItem = $SubItem
					Qualified = $NickName
				}
			}
			if ( $_.DisplayName -eq 'Windows Internal Database') {
				$SubItem = $null
				$Abbrev = "WID"
				$NickName = $Abbrev
				$all += New-Object -Type psobject -Property @{
					Role = "Windows Internal Database"
					Abbreviation = $Abbrev
					SubItem = $SubItem
					Qualified = $NickName
				}
			}
			if ( $_.DisplayName -eq 'Failover Clustering') {
				$SubItem = $null
				Try {
					#Let's see if we can pull the name of the cluster
					import-module FailoverClusters
					$SubItem = (get-cluster).Name
				} Catch { $SubItem = $null }
				$Abbrev = "Cluster"
				$NickName = $Abbrev
				if ($SubItem.ToString().Length -gt 0) { $NickName = "$Abbrev ($SubItem)" }
				$all += New-Object -Type psobject -Property @{
					Role = "Failover Clustering"
					Abbreviation = $Abbrev
					SubItem = $SubItem
					Qualified = $NickName
				}
			}
			if ( $_.DisplayName -eq 'Containers') {
				$SubItem = $null
				$Abbrev = "Containers"
				$NickName = $Abbrev
				$all += New-Object -Type psobject -Property @{
					Role = "Containers"
					Abbreviation = $Abbrev
					SubItem = $SubItem
					Qualified = $NickName
				}
			}
		}

		if (-not $ADFSFound) {
			#Test For ADFS 2.0 (not show in the Roles/Features of 2008 R2 [native is 1.1])
			#We won't do this if we found ADFS in the roles...
			if (Get-PSSnapin -Registered -ErrorAction SilentlyContinue | Where-Object {$_.Name -match "Adfs" }) {
					#ADFS snappin is installed
					#Let's see if we tell if we're Federation or Proxy (or both)
				Try {
					Add-PSSnapin Microsoft.Adfs.PowerShell -ErrorAction Stop
					Try {
						$IsFederation = (Get-AdfsProperties -ErrorAction Stop).HostName
					} catch { $IsFederation = $false }
					Try {
						$IsProxy = (get-adfsproxyproperties -ErrorAction Stop).BaseHostName
					} catch { $IsProxy = $false }
					$SubItem = ""
					if ($IsFederation) { $SubItem = "ADFS (" + $IsFederation.Split(".")[0] + ")"}
					if ($IsProxy) {
						if ($SubItem.Length -gt 0) { $SubItem = $SubItem + " & " } else { $SubItem = "ADFS "}
						$SubItem = [String] ($SubItem + "Proxy (" + $IsProxy.Split(".")[0] + ")").Trim()
					}
					$Abbrev = "ADFS"
					if ($SubItem.ToString().Length -gt 0) { $NickName = $SubItem } else { $NickName = $Abbrev }
					$all += New-Object -Type psobject -Property @{
						Role = "Active Directory Federation Services"
						Abbreviation = $Abbrev
						SubItem = $SubItem
						Qualified = $NickName
					}
				} catch { }
			}
		}
	$all = $all | Sort-Object -Property Abbreviation
	$all | Select-Object Role, Abbreviation, SubItem, Qualified | Format-List
	}
	Catch { }
}