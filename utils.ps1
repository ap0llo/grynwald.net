function Log-Error($message) {
    if ($env:TF_BUILD) {
        Write-Host "##vso[task.logissue type=error] $message"
    }
    else {
        Write-Host "ERROR: $message"
    }
}

function Log-Warning($message) {
    if ($env:TF_BUILD) {
        Write-Host "##vso[task.logissue type=warning] $message"
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
