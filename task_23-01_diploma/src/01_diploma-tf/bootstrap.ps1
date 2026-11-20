 $ErrorActionPreference = "Stop"

# читаем env.sh из секретов (формат "export VAR=value")
Get-Content "$HOME\.secrets\netology\diploma\env.sh" | ForEach-Object {
    if ($_ -match '^\s*export\s+([A-Z_]+)=("?)(.+?)\2\s*$') {
        [Environment]::SetEnvironmentVariable($Matches[1], ($Matches[3] -replace '\$HOME', $HOME -replace '\$USERPROFILE', $env:USERPROFILE), "Process")
    }
}

 $saName   = "diploma-sa"
 $folderId = $env:YC_FOLDER_ID
 $keyFile  = "$HOME\.secrets\netology\diploma\key.json"
 $bucket   = $env:YC_STATE_BUCKET

# SA: создать или взять существующий
 $sa = yc iam service-account get --name $saName --folder-id $folderId --format json 2>$null
if (-not $sa) {
    $sa = yc iam service-account create --name $saName --folder-id $folderId --format json | ConvertFrom-Json
    Write-Host "SA $saName created: $($sa.id)"
} else {
    $sa = $sa | ConvertFrom-Json
    Write-Host "SA $saName exists: $($sa.id)"
}

# роли
 $roles = @("editor","storage.admin","vpc.admin","compute.admin","container-registry.admin","kms.keys.encrypterDecrypter","load-balancer.admin","iam.serviceAccounts.admin")
foreach ($role in $roles) {
    yc resource-manager folder add-access-binding --id $folderId --role $role --service-account-id $sa.id 2>$null
    Write-Host "role $role granted"
}

# ключ SA
yc iam key create --service-account-name $saName --folder-id $folderId --output $keyFile
Write-Host "key saved: $keyFile"

# бакет для state
yc storage bucket create --name $bucket --folder-id $folderId --default-storage-class standard --max-size 1073741824 2>$null
if (-not $?) { Write-Host "bucket $bucket already exists" }
Write-Host "done"