Powershell.SaveMeTime
=====================

A set of powershell scripts i can run to automate common tasks i do several times every day.

A nice gotcha is that by default you can't run scripts in Powershell without either running Powershell as Administrator or prefixing each set of calls with a execution policy temporary suspension.

If you want to just get on nd develop some Powershell (who doesn't right?!?!!?) then you can turn this off by running 'Set-ExecutionPolicy Unrestricted', you are then presented with a warning about the setting protecting you, being the grown up dev you are type 'Y' when asked if you want to confirm you want to turn this off

To auto load the modules and scripts place the startup.ps1 in the following directory:
`%UserProfile%\My Documents\WindowsPowerShell\`

Renaming it `Microsoft.PowerShell_profile.ps1`
