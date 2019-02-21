<#
.SYNOPSIS
    Pulls Drive info from WMI

.DESCRIPTION
    Pulls local drive info from WMI....

.EXAMPLE
    Get-DriveInfo.ps1

#>


[CmdletBinding()]
param ( )

BEGIN { $drives = Get-CimInstance -Class Win32_LogicalDisk -Filter 'DriveType = 3' }

PROCESS {
	$drives | ForEach-Object {
		$out = New-Object psobject
		[string] $label = $_.VolumeName
		if ($label.Length -eq 0) { $label = "(No Label)"}
		Add-Member -InputObject $out -MemberType NoteProperty -Name "FreeSpace" -Value $([int] ([math]::Round(($_.FreeSpace / 1GB), 0)))
		Add-Member -InputObject $out -MemberType NoteProperty -Name "UsedSpace" -Value $([int] ([math]::Round(($_.Size - $_.FreeSpace) / 1GB, 0)))
		Add-Member -InputObject $out -MemberType NoteProperty -Name "Size" -Value $([int] ($_.Size / 1GB))
		Add-Member -InputObject $out -MemberType NoteProperty -Name "FreePercent" -Value $([int] (($_.FreeSpace / $_.Size) * 100))
		Add-Member -InputObject $out -MemberType NoteProperty -Name "UsedPercent" -Value $([int] ((($_.Size - $_.FreeSpace) / $_.Size) * 100))
		Add-Member -InputObject $out -MemberType NoteProperty -Name "VolumeName" -Value $label
		Add-Member -InputObject $out -MemberType NoteProperty -Name "Drive" -Value $_.DeviceID
		Add-Member -InputObject $out -MemberType NoteProperty -Name "FileSystem" -Value $_.FileSystem
		Add-Member -InputObject $out -MemberType NoteProperty -Name "IsDirty" -Value ([bool] $_.VolumeDirty)
		$out
	}
}

END { }

