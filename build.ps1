# Assumes "wyam" (https://wyam.io/) is installed either globally or in the same directory as this script
param($OutputDirectory)

function Log-Error($message) {
    if ($env:TF_BUILD) {
        Write-Host "##vso[task.logissue]error $message"
    }
    else {
        Write-Host "ERROR: $message"
    }
}

function Log-Warning($message) {
    if ($env:TF_BUILD) {
        Write-Host "##vso[task.logissue]warning $message"
    }
    else {
        Write-Host "WARN: $message"
    }
}

function Log-Info($message) {
    if ($env:TF_BUILD) {
        Write-Host "$message"
    }
    else {
        Write-Host "INFO: $message"
    }
}

function Get-WyamPath {

    Push-Location $PSScriptRoot
    
    Log-Info "Attempting to find Wyam installation in current directory"
    $wyamCommand = Get-Command ".\wyam" -CommandType Application -ErrorAction SilentlyContinue
    
    if ($null -eq $wyamCommand) {
        Log-Info "No local installation of wyam found, attempting to find global installation"
        $wyamCommand = Get-Command "wyam" -CommandType Application -ErrorAction SilentlyContinue
    }
        
    if ($null -eq $wyamCommand) {
        Log-Error "Failed to locate wyam. Aborting."
        throw "Build failed."
    }
    else {
        Log-Info "wyam found at $($wyamCommand.Source)"
        return $wyamCommand.Source
    }
    
    Pop-Location    
}    

function Get-GitCommitHash {

    # Check if git is installed
    $gitCommand = Get-Command "git" -CommandType Application -ErrorAction SilentlyContinue

    if ($null -eq $gitCommand) {
        Log-Warning "Cannot determine git commit hash: Git does not seem to be installed."
        return $null
    }

    $commitHash = Invoke-Expression "git rev-parse HEAD"
    if ($LASTEXITCODE -ne 0) {
        Log-Warning "Cannot determine git commit hash: Git failed with exit code $LASTEXITCODE"
        return $null
    }

    Log-Info "Current git commit hash is $commitHash"
    return $commitHash
}


$wyamPath = Get-WyamPath
$wyamArgs = "build"

if ($null -eq $OutputDirectory) {
    $OutputDirectory = Join-Path $PSScriptRoot "output"    
} 
Log-Info "Using output directory '$OutputDirectory'"
$wyamArgs +=  " --output `"$OutputDirectory`""

$commitHash = Get-GitCommitHash

if($null -eq $commitHash) {
    Log-Warning "Git commit hash is null, cannot embed git version into generated site"
} else {
    Log-Info "Embedding git commit hash $commitHash into generated site"
    $wyamArgs += " --setting `"Git.CommitHash=$commitHash`""
}

Push-Location $PSScriptRoot 
Log-Info "Starting wyam build with arguments `"$wyamArgs`""
Invoke-Expression "$wyamPath $wyamArgs"
if ($LASTEXITCODE -ne 0) {
    Log-Error "wyam failed with exit code $LASTEXITCODE"
    throw "Build failed."
}
Pop-Location