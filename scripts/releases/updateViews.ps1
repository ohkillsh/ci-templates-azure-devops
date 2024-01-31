param (
  [string]$SqlInstance = "localhost",
  [string]$database = "database",
  [string]$sqlPassword,
  [string]$sqlUsername

)

[securestring]$pwdSecureString = convertto-securestring -String "${sqlPassword}" -AsPlainText -Force

$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "${sqlUsername}", $pwdSecureString

invoke-DbaQuery `
  -SqlInstance $SqlInstance `
  -database $database `
  -sqlCredential $creds `
  -CommandType StoredProcedure `
  -Query dba.refreshCatalogView `
  -SqlParameter @{ ObjectName = 'all' }

