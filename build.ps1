# Assumes "wyam" (https://wyam.io/) is installed either globally or in the same directory as this script

function Log-Error($message) {
    if($env:TF_BUILD) {
        Write-Host "##vso[task.logissue]error $message"
    } else {
        Write-Host "ERROR: $message"
    }
}
function Log-Info($message) {
    if($env:TF_BUILD) {
        Write-Host "$message"
    } else {
        Write-Host "INFO: $message"
     }
}

function Get-WyamPath {

    Push-Location $PSScriptRoot
    
    Log-Info "Attempting to find Wyam installation in current directory"
    $wyamCommand = Get-Command ".\wyam" -CommandType Application -ErrorAction SilentlyContinue
    
    if($wyamCommand -eq $null) {
        Log-Info "No local installation of wyam found, attempting to find global installation"
        $wyamCommand = Get-Command "wyam" -CommandType Application -ErrorAction SilentlyContinue
    }
        
    if($wyamCommand -eq $null) {
        Log-Error "Failed to locate wyam. Aborting."
        throw "Build failed."
    } else {
        Log-Info "wyam found at $($wyamCommand.Source)"
        return $wyamCommand.Source
    }
    
    Pop-Location    
}    

$wyamPath = Get-WyamPath
$inputRoot = $PSScriptRoot 

Push-Location $inputRoot

Log-Info "Starting wyam build"
Invoke-Expression "$wyamPath build"
if($LASTEXITCODE -ne 0) {
    Log-Error "wyam failed with exit code $LASTEXITCODE"
    throw "Build failed."
}
Pop-Location