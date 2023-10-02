$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# Load custom functions
. "$toolsDir\utils\utils.ps1"

Write-Host "Getting the state of the current Securepoint VPN service (if any)..."
# Needed to reset the state of the service if upgrading from a previous version
try {
  $previousService = GetServiceProperties "Securepoint VPN"
} catch {
  Write-Host "No previous Securepoint VPN service detected."
}

$packageArgs = @{
  packageName            = 'securepointsslvpn'
  fileType               = 'msi'
  file                   = "$toolsDir\openvpn-client-installer-2.0.40.msi"
  file64                 = "$toolsDir\openvpn-client-installer-2.0.40.msi"
  checksum               = 'afb44dd9d21ab904a0c0c08a83e975c76d94541eccced19b9f5ee87a1dd0705514719054ef749a8eb42190f1588dc3871309447afa70398ecc96d22489f42616'
  checksum64             = 'afb44dd9d21ab904a0c0c08a83e975c76d94541eccced19b9f5ee87a1dd0705514719054ef749a8eb42190f1588dc3871309447afa70398ecc96d22489f42616'
  checksumType           = 'sha512'
  checksumType64         = 'sha512'
  silentArgs             = "/qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`" TRANSFORMS=`":en-us.mst`""
  validExitCodes         = @(0, 3010, 1641)
  softwareName           = 'securepoint*ssl*vpn*'
}

Install-ChocolateyInstallPackage @packageArgs

if ($previousService) {
  Write-Host "Resetting previous Securepoint VPN service to " `
    "'$($previousService.status)' and " `
    "'$($previousService.startupType)'..."
  SetServiceProperties `
    -name "Securepoint VPN" `
    -status "$($previousService.status)" `
    -startupType "$($previousService.startupType)"
}
