<#
.NAME: 
InstallWindowsUpdates.ps1
.DESCRIPTION:
Install all Windows Updates that are available without a reboot.
.SYNOPSYS:
Install All Windows Updates available without rebooting.
.EXAMPLE:
PS> set-executionpolicy bypass -force; .\InstallWindowsUpdates.ps1
.AUTHOR: 
Michael Free
#>

### Check admin
$checkadmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($checkadmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -eq $false) {
  Write-Warning "Not Administrator"
  Exit 1
}

### Check NuGet
$CheckNuget = Get-PackageProvider | where-object {$_.Name -eq "NuGet"}
if ($null -eq $CheckNuget) {
  Write-Warning "NuGet Not Installed"
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Install-PackageProvider NuGet -Force
  if ($?) {
    Import-PackageProvider NuGet -Force
    if ($?) {
      Write-Host "Imported NuGet Package Provider Successfully"
    } else {
      Write-Warning "Failed to Import NuGet Package Provider"
      Exit 1
    }
  } else {
    Write-Warning "Failed to Install NuGet as Package Provider"
    Exit 1
  }
}

### Check PS Update
$CheckPSUpdates = get-module -ListAvailable -Name PSWindowsUpdate | where-object {$_.Name -eq "PSWindowsUpdate"}
if ($CheckPSUpdates -eq $null) {
  Write-Warning "PSWindowsUpdate module is not installed..."
  ## need a force accept here
  Install-Module PSWindowsUpdate -force -Confirm:$false
  if ($?) {
    Get-Command -Module PSWindowsUpdate
    if ($?) {
      write-host "Succesfully fetched PSWindowsUpdate module..."
    } else {
      Write-Warning "Failed to fetch PsWindowsUpdate module..."
    }
  } else {
    Write-Warning "Failed to install PSWindowsUpdate Module..."
    Exit 1
  }
}

### if statement here to check update manager
Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -Confirm:$false
if ($?) {
  Install-WindowsUpdate -microsoftupdate -acceptall -ignorereboot
  if ($?) {
    write-host "Successfully installed Windows Updates"
    Exit 0
  } else {
    Write-Warning "Failed to install all windows updates"
    Exit 1
  }
}
