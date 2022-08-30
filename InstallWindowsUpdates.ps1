
function check_admin {
  $checkadmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
  $checkadmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
function get_nuget {
  $CheckNuget = Get-PackageProvider | where-object {$_.Name -eq "NuGet"}
  if ($null -ne $CheckNuget) {
    return $true
  } else {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    if ($?) {
      Install-PackageProvider NuGet -Force
      if ($?) {
        Import-PackageProvider NuGet -Force
        if ($?) {
          Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
          if ($?) {
            return $true
          } else {
            Write-Warning "Failed to set PSGallery as a trusted installation repository for NuGet..."
            return $false
          }
        } else {
          write-warning "Failed to import NuGet package provider..."
          return $false
        }
      } else {
        Write-Warning "NuGet failed to install..."
        return $false
      }
    } else {
      Write-Warning "Failed to install TLS 1.2 to install NuGet"
      return $false
    }
  }
}
function get_pswinupdate {
  if (get-module -ListAvailable -Name PSWindowsUpdate) {
    return $true
  } else {
    Write-Warning "PSWindowsUpdate module is not installed..."
    if (get_nuget -eq $true) {
      Install-Module PSWindowsUpdate
      if ($?) {
        Get-Command -Module PSWindowsUpdate
        if ($?) {
          return $true
        } else {
         Write-Warning "Failed to import PSWindowsUpdate module..."
         return $false
        }
      } else {
        Write-Warning "Failed to install PSWindowsUpdate module..."
        return $false
      }
    } else {
      return $false
    }
  }
}
function update_windows {
  Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -Confirm:$false
  if ($?) {
      Install-WindowsUpdate -microsoftupdate -acceptall -ignorereboot
      if ($?) {
        return $true
      } else {
        Write-Warning "Failed to download and install all Windows Updates..."
        return $false
      }
  } else {
    Write-Warning "Failed to opt-in for automatic windows update confirmations..."
    return $false
  }
}
if (check_admin -eq $true) {
  Write-Host "Administrative Rights have been verified..."
  if (get_pswinupdate -eq $true) {
    Write-Host "PSWindowsUpdate module was successful. Installing updates..."
    if (update_windows -eq $true) {
      Write-Host "Windows Updates have completed successfully. Please reboot the computer when ready..."
      exit 0
    } else {
      exit 1
    }
  } else {
    exit 1
  }
} else {
  Write-Warning "InstallWindowsUpdates.ps1 must be ran with Administrative Rights..."
  exit 1
}
