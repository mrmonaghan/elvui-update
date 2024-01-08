## VARIABLES ##
# ElvUI download base URL
$baseUrl = "https://api.tukui.org/v1/addon/elvui"
# OS-specified temp directory
$tempDir = [System.IO.Path]::GetTempPath()

$zipFile = "$tempDir/elvui.zip"

# currently this script only supports managing ElvUI for retail installations.
$gameVersion = "_retail_"

# attempt to determine the WoW install directory
$wowInstall = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*, HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -eq 'World Of Warcraft'}

# exit if no WoW install is found
if ($wowInstall) {
    $gameDir = $wowInstall | Select-Object -ExpandProperty InstallLocation
    Write-Host -ForegroundColor Yellow "Found existing World Of Warcraft installation: $gameDir. Comparing versions..."
} else {
    Write-Host -ForegroundColor Red "No existing World Of Warcraft installation detected. Ensure the game is installed prior to running this script :)"
    exit
}

$addonsDir = "$gameDir/$gameVersion/Interface/AddOns"
$baseUiDir = "$addonsDir/ElvUI"

# check for an exising ElvUI installation
$existingInstall = if (Test-Path -Path $baseUiDir) {
    $true
} else {
    $false
}

$currentVersion = [System.Version]"1.0"

# if ElvUI is already installed, capture the version for comparison.
if ($existingInstall) {
    $existingConfig = Get-Content "$baseUiDir/ElvUI_Mainline.toc" |
    Where-Object { $_ -match '(?<=##\sVersion:\s).*'}
    switch($Matches.Length) {
        1 { 
            $currentVersion = [System.Version]$Matches.0
            Write-Host -ForegroundColor Yellow "Found existing ElvUI installation (version $currentVersion)..."
        }
        Default {
            Write-Host -ForegroundColor Red "Unable to determine current version of ElvUI from install location: $baseUiDir"
        }
    }
} else {
    Write-Host -ForegroundColor Yellow "No existing ElvUI installation found in $addonsDir. Creating new installation..."
    $currentVersion = "null"
}

# make a download request to the ElvUI API
$getElvUiRequest = Invoke-WebRequest $baseUrl | ConvertFrom-Json
# parse directories that are included as part of the addon
$elvUIDirectories = $getElvUiRequest | Select-Object -ExpandProperty directories
# capture the latest version string from the HTTP request
$latestVersionStr = $getElvUiRequest | Select-Object -ExpandProperty version
# cast latest version to a System.Version for comparison
$latestVersion = [System.Version]$latestVersionStr


# back up current ElvUI directories
if ($existingInstall) {
    # compare versions and exit if no update is required.
    if ($latestVersion -le $currentVersion) {
        Write-Host -ForegroundColor Yellow "Current ElvUI version '$currentVersion' matches latest version '$latestVersion'. No action required."
        Read-Host "Press Enter to continue..."
        exit
    } else {
        Write-Host -ForegroundColor Yellow "Current ElvUI version '$currentVersion' is out of date - latest version is '$latestVersion'. Beginning update..."
    }

    Write-Host -ForegroundColor Yellow "Backing up current ElvUI installation..."
    foreach ($dir in $elvUIDirectories) {
        try {
            Copy-Item -Path "$addonsDir/$dir" -Destination "$addonsDir/$dir.backup" -Force
        } 
        catch {
            Write-Host -ForegroundColor Red "Failed backup: $dir => $dir.backup."
            Write-Error $_
        }
    }
    Write-Host -ForegroundColor Yellow "Backup complete!"
}


# capture the download URL from the download request response
$downloadUrl = $getElvUiRequest | Select-Object -ExpandProperty url

# download the .zip file to the temp directory
Invoke-WebRequest $downloadUrl -OutFile $zipFile

# extract the .zip into the specified AddOns directory
Expand-Archive -Path $zipFile -DestinationPath "$addonsDir" -Force

# remove the .zip file
Remove-Item -Path $zipFile -Force 

Write-Host -ForegroundColor Green "ElvUI has been successfully updated ($currentVersion => $latestVersion)"

Read-Host "Press Enter to continue..."