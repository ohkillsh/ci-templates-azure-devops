param(
    [string]$project            = "TeamProject",
    [string]$repository         = "GitRepo",
    [string]$targetBranch = "master",
    [switch]$IS_DRY_RUN = $false  # Default value is false if not provided
)

Write-Host ("is dry run: {0}" -f $IS_DRY_RUN)

$prsCompleted = az repos pr list `
    --project $project `
    --repository $repository `
    --target-branch $targetBranch `
    --status completed `
    --query "[].sourceRefName" |
ConvertFrom-Json;

if ($prsCompleted.count -eq 0) {
    Write-Host "No merged pull request"
    return;
}

$refs = az repos ref list --project $project --repository $repository --filter heads | ConvertFrom-Json

$refs |
Where-Object { $prsCompleted.Contains( $_.name ) } |
ForEach-Object {
    Write-Host ("deleting merged branch: {0} - {1}" -f $_.name, $_.objectId)
    if (!$IS_DRY_RUN) {
        $result = az repos ref delete `
            --name $_.name `
            --object-id $_.objectId `
            --project $project `
            --repository $repository |
        ConvertFrom-Json
        Write-Host ("success message: {0}" –f $result.updateStatus)
    }
}