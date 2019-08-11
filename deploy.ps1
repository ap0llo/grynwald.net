param(     
    [Parameter(Mandatory=$true)][string]$SourceDirectory,
    [Parameter(Mandatory=$true)][string]$RepositoryUrl,
    [Parameter(Mandatory=$true)][string]$TargetBranch,
    [Parameter(Mandatory=$true)][string]$WorkingDirectory
)

. (Join-Path $PSScriptRoot "utils.ps1")

Write-Host "Cloning repository '$RepositoryUrl' into '$WorkingDirectory'"
Invoke-Expression "git clone `"$RepositoryUrl`" `"$WorkingDirectory`""
if($LASTEXITCODE -ne 0) {
    Log-Error "Cloning Pages repository failed, git exited with exit code $LASTEXITCODE"
    exit 1
}
Push-Location $WorkingDirectory

Write-Host "Checking out branch $TargetBranch"
Invoke-Expression "git checkout $TargetBranch"
if($LASTEXITCODE -ne 0) {
    Log-Error "Failed to checkout brnach $TargetBranch, git exited with exit code $LASTEXITCODE"
    exit 1
}
$roboCopyOptions = "/E /PURGE"
$roboCopyOptions += " /XD `"$(Join-Path $WorkingDirectory ".git")`""  
$roboCopyOptions += " /XF `"$(Join-Path $WorkingDirectory "CNAME")`""

Invoke-Expression "robocopy `"$SourceDirectory`" `"$WorkingDirectory`" $roboCopyOptions"
if($LASTEXITCODE -gt 1) {
    Log-Error "Robocopy exited with exit code $LASTEXITCODE"
    exit 1
}

Invoke-Expression "git add ."
if($LASTEXITCODE -ne 0) {
    Log-Error "git failed with exit code $LASTEXITCODE"
    exit 1
}

# TODO: Skip commit if there are no pending changes
# TODO: Use better formatting for commit message, include commit id of source repo
# TODO: Adjust commit message when running outside Azure Pipelines
Invoke-Expression "git commit -m `"Automatic deploy to GitHub Pages by Azure Pipelines ($env:BUILD_DEFINITIONNAME)/$env:BUILD_BUILDNUMBER)`" "
if($LASTEXITCODE -ne 0) {
    Log-Error "Committing to GitHub Pages repository failed, git exited with exit code $LASTEXITCODE"
    exit 1
}

Invoke-Expression "git push"
if($LASTEXITCODE -ne 0) {
    Log-Error "Pushing to GitHub Pages repository failed, git exited with exit code $LASTEXITCODE"
    exit 1
}

Pop-Location