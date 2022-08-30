# InstallWindowsUpdates
A quick and dirty script to download and install all Windows 10 updates at once without a reboot in between. 

## Summary
Windows 10 can be annoying to deal with when it comes to updates.  Often Windows will download and install only one update at a time and then request a reboot each time the update is applied.

If you're a system administrator this can become time consuming and impractical.  Especially if the system that you are working on is several updates behind. 

## Process
This script will not run unless it is ran with either local or domain administrator privileges. After it has verified that it is running with Admin rights, it will check for the NuGet package Manager.

If NuGet isn't installed, it will install it.  After that a check to see if the [Powershell Gallery Repository](https://www.powershellgallery.com/) has been added. If it isn't, then it's added.  If it is, then we move on to the next step.

Powershell Gallery has a module name PSWindowsUpdate that allows you to install Windows Updates via the Powershell CLI.  Once this has been installed, it will then force windows updates with no reboots. 

Sit back, wait for it to finish, and reboot ONLY ONCE!
