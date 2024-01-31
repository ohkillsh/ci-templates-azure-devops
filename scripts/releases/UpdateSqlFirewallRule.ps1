#Author - Gustavo Kuno 
#Other sites to provide IPv4 public address with this type of request

<#
http://ipinfo.io/ip
http://ifconfig.me/ip
http://icanhazip.com
http://ident.me
http://smart-ip.net/myip
#>

# Set Parameters
[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline = $true)][String] $ResourceName = "azure-sql-server-name",
    [Parameter(ValueFromPipeline = $true)][String] $ResourceGroup = "rg-name"
     )

#Setting additional parameters
$ExistingFirewallRuleName = "AzureDevOpsPipeline"
$PubIPSource = "https://ipinfo.io/ip"


$currentIP = (Invoke-WebRequest -uri $PubIPSource -UseBasicParsing).content.TrimEnd()

Write-Output "Updating SQL Database firewall config"

$FirewallRuleList = Get-AzSqlServerFirewallRule -ServerName $ResourceName -ResourceGroupName $ResourceGroup

$FirewallRuleNameList = $FirewallRuleList.FirewallRuleName

if ($FirewallRuleNameList.Length -gt 0) {
    $index = [System.Array]::IndexOf($FirewallRuleNameList, $ExistingFirewallRuleName)

    if ($index -ge 0) {
        Write-Output "Deleting firewall rule $ExistingFirewallRuleName"
        Remove-AzSqlServerFirewallRule -FirewallRuleName $ExistingFirewallRuleName -ServerName $ResourceName -ResourceGroupName $ResourceGroup
    }
    
    else {
        Write-Output "The firewall rule list is empty or null."
    
        New-AzSqlServerFirewallRule `
        -FirewallRuleName "$ExistingFirewallRuleName" `
        -StartIpAddress $currentIP `
        -EndIpAddress $currentIP `
        -ServerName $ResourceName `
        -ResourceGroupName $ResourceGroup
        
        Write-Output "Updated firewall rule to include current IP: $currentIP"
    }
}

Start-Sleep -Seconds 15