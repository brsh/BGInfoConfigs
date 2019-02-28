<#
.SYNOPSIS
    Pulls Data from AWS Local Instance service

.DESCRIPTION
	Pulls miscellaneous data about AWS instances. Only valid for an AWS instance on EC2 (go figure, right).

	See AWS EC2Launch (Windows 2016): %ProgramData%\Amazon\EC2-Windows\Launch\Module\Scripts\Set-Wallpaper.ps1
	See AWS EC2Config (Windows Pre-2016): %ProgramFiles%\Amazon\EC2ConfigService\Settings

.EXAMPLE
    Get-AWSInfo.ps1

#>


[CmdletBinding()]
param ( )

BEGIN {
	try {
		$ping = New-Object System.Net.NetworkInformation.Ping
		$result = $ping.Send('169.254.169.254')
		if ($result.status -eq 'success') {
			write-verbose "Ping'd local AWS instance metadata. Prolly an AWS Instance"
		} else {
			write-verbose "Could not ping local AWS instance metadata. Prolly not an AWS Instance"
			exit
		}
	} catch {
		write-verbose "Error ping'ing local AWS instance metadata. Prolly not an AWS Instance"
		exit
	}
}

PROCESS {
	Try {
		$instanceSize = (Invoke-WebRequest '169.254.169.254/latest/meta-data/instance-type' -erroraction Stop).Content
	} catch { $instanceSize = '' }
	Try {
		$instanceID = (Invoke-WebRequest '169.254.169.254/latest/meta-data/instance-id' -erroraction Stop).Content
	} catch { $instanceID = '' }
	Try {
		$hostName = (Invoke-WebRequest '169.254.169.254/latest/meta-data/hostname' -erroraction Stop).Content
	} catch { $hostName = '' }
	Try {
		$firstmac = ((Invoke-WebRequest '169.254.169.254/latest/meta-data/network/interfaces/macs' -ErrorAction Stop).Content | Select-Object -First 1).ToString().TrimEnd('/')
		$vpcID = (Invoke-WebRequest "169.254.169.254/latest/meta-data/network/interfaces/macs/$firstmac/vpc-id" -ErrorAction Stop).Content
		$subnetID = (Invoke-WebRequest "169.254.169.254/latest/meta-data/network/interfaces/macs/$firstmac/subnet-id" -ErrorAction Stop).Content
	} catch { $vpcID = '' }

	Try {
		$AvailabilityZone = (Invoke-WebRequest '169.254.169.254/latest/meta-data/placement/availability-zone' -erroraction Stop).Content
	} catch { $AvailabilityZone = '' }

	Try {
		$PublicIP = (Invoke-WebRequest '169.254.169.254/latest/meta-data/placement/public-ipv4' -erroraction Stop).Content
	} catch { $PublicIP = '' }

	# These include all generations, both latest and older types. (Will need updating...)
	$instanceTypes = @(
		@{ Type = "t1.micro"; Memory = "613 MB"; NetworkPerformance = "Very Low" }
		@{ Type = "t2.nano"; Memory = "500 MB"; NetworkPerformance = "Low to Moderate" }
		@{ Type = "t2.micro"; Memory = "1 GB"; NetworkPerformance = "Low to Moderate" }
		@{ Type = "t2.small"; Memory = "2 GB"; NetworkPerformance = "Low to Moderate" }
		@{ Type = "t2.medium"; Memory = "4 GB"; NetworkPerformance = "Low to Moderate" }
		@{ Type = "t2.large"; Memory = "8 GB"; NetworkPerformance = "Low to Moderate" }
		@{ Type = "t2.xlarge"; Memory = "16 GB"; NetworkPerformance = "Moderate" }
		@{ Type = "t2.2xlarge"; Memory = "32 GB"; NetworkPerformance = "Moderate" }
		@{ Type = "m4.large"; Memory = "8 GB"; NetworkPerformance = "Moderate" }
		@{ Type = "m4.xlarge"; Memory = "16 GB"; NetworkPerformance = "High" }
		@{ Type = "m4.2xlarge"; Memory = "32 GB"; NetworkPerformance = "High" }
		@{ Type = "m4.4xlarge"; Memory = "64 GB"; NetworkPerformance = "High" }
		@{ Type = "m4.10xlarge"; Memory = "160 GB"; NetworkPerformance = "10 Gigabit" }
		@{ Type = "m3.medium"; Memory = "3.75 GB"; NetworkPerformance = "Moderate" }
		@{ Type = "m3.large"; Memory = "7.5 GB"; NetworkPerformance = "Moderate" }
		@{ Type = "m3.xlarge"; Memory = "15 GB"; NetworkPerformance = "High" }
		@{ Type = "m3.2xlarge"; Memory = "30 GB"; NetworkPerformance = "High" }
		@{ Type = "m1.small"; Memory = "1.7 GB"; NetworkPerformance = "Low" }
		@{ Type = "m1.medium"; Memory = "3.7 GB"; NetworkPerformance = "Moderate" }
		@{ Type = "m1.large"; Memory = "7.5 GB"; NetworkPerformance = "Moderate" }
		@{ Type = "m1.xlarge"; Memory = "15 GB"; NetworkPerformance = "High" }
		@{ Type = "c4.large"; Memory = "3.75 GB"; NetworkPerformance = "Moderate" }
		@{ Type = "c4.xlarge"; Memory = "7.5 GB"; NetworkPerformance = "High" }
		@{ Type = "c4.2xlarge"; Memory = "15 GB"; NetworkPerformance = "High" }
		@{ Type = "c4.4xlarge"; Memory = "30 GB"; NetworkPerformance = "High" }
		@{ Type = "c4.8xlarge"; Memory = "60 GB"; NetworkPerformance = "10 Gigabit" }
		@{ Type = "c3.large"; Memory = "3.75 GB"; NetworkPerformance = "Moderate" }
		@{ Type = "c3.xlarge"; Memory = "7.5 GB"; NetworkPerformance = "Moderate" }
		@{ Type = "c3.2xlarge"; Memory = "15 GB"; NetworkPerformance = "High" }
		@{ Type = "c3.4xlarge"; Memory = "30 GB"; NetworkPerformance = "High" }
		@{ Type = "c3.8xlarge"; Memory = "60 GB"; NetworkPerformance = "10 Gigabit" }
		@{ Type = "c1.medium"; Memory = "1.7 GB"; NetworkPerformance = "Moderate" }
		@{ Type = "c1.xlarge"; Memory = "7 GB"; NetworkPerformance = "High" }
		@{ Type = "cc2.8xlarge"; Memory = "60.5 GB"; NetworkPerformance = "10 Gigabit" }
		@{ Type = "cc1.4xlarge"; Memory = "23 GB"; NetworkPerformance = "10 Gigabit" }
		@{ Type = "g2.2xlarge"; Memory = "15 GB"; NetworkPerformance = "High" }
		@{ Type = "g2.8xlarge"; Memory = "60 GB"; NetworkPerformance = "10 Gigabit" }
		@{ Type = "cg1.4xlarge"; Memory = "22 GB"; NetworkPerformance = "10 Gigabit" }
		@{ Type = "r3.large"; Memory = "15 GB"; NetworkPerformance = "Moderate" }
		@{ Type = "r3.xlarge"; Memory = "30.5 GB"; NetworkPerformance = "Moderate" }
		@{ Type = "r3.2xlarge"; Memory = "61 GB"; NetworkPerformance = "High" }
		@{ Type = "r3.4xlarge"; Memory = "122 GB"; NetworkPerformance = "High" }
		@{ Type = "r3.8xlarge"; Memory = "244 GB"; NetworkPerformance = "10 Gigabit" }
		@{ Type = "r4.large"; Memory = "15.25 GB"; NetworkPerformance = "Up to 10 Gigabit" }
		@{ Type = "r4.xlarge"; Memory = "30.5 GB"; NetworkPerformance = "Up to 10 Gigabit" }
		@{ Type = "r4.2xlarge"; Memory = "61 GB"; NetworkPerformance = "Up to 10 Gigabit" }
		@{ Type = "r4.4xlarge"; Memory = "122 GB"; NetworkPerformance = "Up to 10 Gigabit" }
		@{ Type = "r4.8xlarge"; Memory = "244 GB"; NetworkPerformance = "10 Gigabit" }
		@{ Type = "r4.16large"; Memory = "488 GB"; NetworkPerformance = "20 Gigabit" }
		@{ Type = "x1.16xlarge"; Memory = "976 GB"; NetworkPerformance = "10 Gigabit" }
		@{ Type = "x1.32xlarge"; Memory = "1952 GB"; NetworkPerformance = "High" }
		@{ Type = "m2.xlarge"; Memory = "17.1 GB"; NetworkPerformance = "Moderate" }
		@{ Type = "m2.2xlarge"; Memory = "34.2 GB"; NetworkPerformance = "Moderate" }
		@{ Type = "m2.4xlarge"; Memory = "68.4 GB"; NetworkPerformance = "High" }
		@{ Type = "cr1.8xlarge"; Memory = "244 GB"; NetworkPerformance = "10 Gigabit" }
		@{ Type = "d2.xlarge"; Memory = "30.5 GB"; NetworkPerformance = "Moderate" }
		@{ Type = "d2.2xlarge"; Memory = "61 GB"; NetworkPerformance = "High" }
		@{ Type = "d2.4xlarge"; Memory = "122 GB"; NetworkPerformance = "High" }
		@{ Type = "d2.8xlarge"; Memory = "244 GB"; NetworkPerformance = "10 Gigabit" }
		@{ Type = "i2.xlarge"; Memory = "30.5 GB"; NetworkPerformance = "Moderate" }
		@{ Type = "i2.2xlarge"; Memory = "61 GB"; NetworkPerformance = "High" }
		@{ Type = "i2.4xlarge"; Memory = "122 GB"; NetworkPerformance = "High" }
		@{ Type = "i2.8xlarge"; Memory = "244 GB"; NetworkPerformance = "10 Gigabit" }
		@{ Type = "i3.large"; Memory = "15.25 GB"; NetworkPerformance = "Up to 10 Gigabit" }
		@{ Type = "i3.xlarge"; Memory = "30.5 GB"; NetworkPerformance = "Up to 10 Gigabit" }
		@{ Type = "i3.2xlarge"; Memory = "61 GB"; NetworkPerformance = "Up to 10 Gigabit" }
		@{ Type = "i3.4xlarge"; Memory = "122 GB"; NetworkPerformance = "Up to 10 Gigabit" }
		@{ Type = "i3.8xlarge"; Memory = "244 GB"; NetworkPerformance = "10 Gigabit" }
		@{ Type = "i3.16xlarge"; Memory = "488 GB"; NetworkPerformance = "20 Gigabit" }
		@{ Type = "hi1.4xlarge"; Memory = "60.5 GB"; NetworkPerformance = "10 Gigabit" }
		@{ Type = "hs1.8xlarge"; Memory = "117 GB"; NetworkPerformance = "10 Gigabit" }
		@{ Type = "m4.16xlarge"; Memory = "256 GB"; NetworkPerformance = "20 Gigabit" }
		@{ Type = "p2.xlarge"; Memory = "61 GB"; NetworkPerformance = "High" }
		@{ Type = "p2.8xlarge"; Memory = "488 GB"; NetworkPerformance = "10 Gigabit" }
		@{ Type = "p2.16xlarge"; Memory = "732 GB"; NetworkPerformance = "20 Gigabit" }
	)

	# Set instance type information if instance size was found from metadata above
	if ($instanceSize) {
		$instanceType = $instanceTypes | Where-Object {$_.Type.Equals($instanceSize)}
		if ($instanceType) {
			$NetworkPerformance = $instanceType.NetworkPerformance
		} else {
			$NetworkPerformance = ''
			$instanceType = $instanceSize
		}
	}

	$out = New-Object psobject

	Add-Member -InputObject $out -MemberType NoteProperty -Name "InstanceSize" -Value $instanceSize
	Add-Member -InputObject $out -MemberType NoteProperty -Name "InstanceID" -Value $instanceID
	Add-Member -InputObject $out -MemberType NoteProperty -Name "InternalHostName" -Value $hostName
	Add-Member -InputObject $out -MemberType NoteProperty -Name "vpcID" -Value $vpcID
	Add-Member -InputObject $out -MemberType NoteProperty -Name "SubnetID" -Value $subnetID
	Add-Member -InputObject $out -MemberType NoteProperty -Name "AvailabilityZone" -Value $AvailabilityZone
	Add-Member -InputObject $out -MemberType NoteProperty -Name "PublicIP" -Value $PublicIP
	Add-Member -InputObject $out -MemberType NoteProperty -Name "NetworkPerformance" -Value $NetworkPerformance

	$out
}


END { }

