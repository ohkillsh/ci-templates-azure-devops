param(
    [string]$project            = "TeamProject",
    [string]$repository         = "GitRepo",
    [string]$excludeBranches    = @("develop", "master"),
    [int]$daysDeleteBefore      = -30,
    [switch]$IS_DRY_RUN         = $false  # Default value is false if not provided
)

$dateTimeNow = [DateTime]::Now
$dateTimeBeforeToDelete = $dateTimeNow.AddDays( $daysDeleteBefore)

Write-Host ("is dry run: {0}" -f $IS_DRY_RUN)
Write-Host ("datetime now: {0}" -f $dateTimeNow)
Write-Host ("delete branches before {0}" -f (get-date $dateTimeBeforeToDelete))

$refs = az repos ref list --project $project --repository $repository --filter heads | ConvertFrom-Json

$toDeleteBranches = @()
 
foreach ($ref in $refs) {

    if ($ref.name -replace "refs/heads/" -in $excludeBranches) {
        continue;
    }

    $objectId = $ref.objectId
 
    # fetch individual commit details
    $commit = az devops invoke `
        --area git `
        --resource commits `
        --route-parameters `
        project=$project `
        repositoryId=$repository `
        commitId=$objectId | ConvertFrom-Json
 
    $toDelete = [PSCustomObject]@{ 
        objectId     = $objectId
        name         = $ref.name
        creator      = $ref.creator.uniqueName
        lastAuthor   = $commit.committer.email
        lastModified = $commit.push.date
    }
    $toDeleteBranches += , $toDelete
}

$toDeleteBranchesList = $toDeleteBranches | Where-Object { (get-date $_.lastModified) -lt (get-date $dateTimeBeforeToDelete) }

if ($toDeleteBranchesList.count -eq 0) {
    Write-Host "No stale branches to delete"
    return;
}

$toDeleteBranchesList |
ForEach-Object {
    Write-Host ("deleting staled branch: name={0} - id={1} - lastModified={2}" -f $_.name, $_.objectId, $_.lastModified)
    if (!$IS_DRY_RUN) {
        $result = az repos ref delete `
            --name $_.name `
            --object-id $_.objectId `
            --project $project `
            --repository $repository |
        ConvertFrom-Json
        Write-Host ("success message: {0}" -f $result.updateStatus)
    }
}