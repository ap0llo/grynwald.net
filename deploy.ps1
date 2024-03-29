param(     
    [Parameter(Mandatory = $true)][string]$SourceDirectory,
    [Parameter(Mandatory = $true)][string]$RepositoryUrl,
    [Parameter(Mandatory = $true)][string]$TargetBranch,
    [Parameter(Mandatory = $true)][string]$WorkingDirectory
)

. (Join-Path $PSScriptRoot "utils.ps1")

Write-Host "Cloning repository '$RepositoryUrl' into '$WorkingDirectory'"
Invoke-Expression "git clone `"$RepositoryUrl`" `"$WorkingDirectory`""
if ($LASTEXITCODE -ne 0) {
    Log-Error "Cloning Pages repository failed, git exited with exit code $LASTEXITCODE"
    exit 1
}
Push-Location $WorkingDirectory

Write-Host "Checking out branch $TargetBranch"
Invoke-Expression "git checkout $TargetBranch"
if ($LASTEXITCODE -ne 0) {
    Log-Error "Failed to checkout branch $TargetBranch, git exited with exit code $LASTEXITCODE"
    exit 1
}
$roboCopyOptions = "/E /PURGE"
$roboCopyOptions += " /XD `"$(Join-Path $WorkingDirectory ".git")`""  
$roboCopyOptions += " /XF `"$(Join-Path $WorkingDirectory "CNAME")`""

Invoke-Expression "robocopy `"$SourceDirectory`" `"$WorkingDirectory`" $roboCopyOptions"
if ($LASTEXITCODE -gt 7) {
    Log-Error "Robocopy exited with exit code $LASTEXITCODE"
    exit 1
}

Invoke-Expression "git add ."
if ($LASTEXITCODE -ne 0) {
    Log-Error "git failed with exit code $LASTEXITCODE"
    exit 1
}

# TODO: Skip commit if there are no pending changes
# TODO: Use better formatting for commit message, include commit id of source repo
# TODO: Adjust commit message when running outside Azure Pipelines
Invoke-Expression "git config user.name `"Azure Pipelines`" "
Invoke-Expression "git config user.email `"<>`" "

$commitMessage = "Automatic deploy to GitHub Pages by Azure Pipelines`r`n" + `
                 "`r`n" + `
                 "Build Definition: $env:BUILD_DEFINITIONNAME`r`n" + `
                 "Build Number: $env:BUILD_BUILDNUMBER`r`n" + `
                 "Source: $env:BUILD_REPOSITORY_URI at revision $env:BUILD_SOURCEVERSION`r`n" + `
                 "`r`n" + `
                 "$env:BUILD_BUILDURI`r`n"

$commitMessagePath = Join-Path (Get-Location) "commitMessage.txt"
[System.IO.File]::WriteAllText($commitMessagePath, $commitMessage.TrimEnd())

Invoke-Expression "git commit -F `"$commitMessagePath`" "
if ($LASTEXITCODE -ne 0) {
    Log-Error "Committing to GitHub Pages repository failed, git exited with exit code $LASTEXITCODE"
    exit 1
}

Invoke-Expression "git push"
if ($LASTEXITCODE -ne 0) {
    Log-Error "Pushing to GitHub Pages repository failed, git exited with exit code $LASTEXITCODE"
    exit 1
}

Pop-Location