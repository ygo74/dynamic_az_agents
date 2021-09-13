
$PAT=$Env:AZP_TOKEN
$UriOrganization = $env:AZP_URL
$AgentName = $env:AZP_AGENT_NAME


# $UriPools = $UriOrganization + '/_apis/distributedtask/pools?api-version=6.0'
# $PoolsResult = Invoke-RestMethod -Uri $UriPools -Method get -Headers $AzureDevOpsAuthenicationHeader

$PoolId = "1"
$uriAgents = $UriOrganization + "/_apis/distributedtask/pools/$($PoolId)/agents?api-version=6.0"
$AzureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PAT)")) }

Write-Host ("Try to retrieve agent '{0}' in Pool '{1}'" -f $AgentName, $PoolId)

$AgentsResults = Invoke-RestMethod -Uri $uriAgents -Method get -Headers $AzureDevOpsAuthenicationHeader
$findAgent = $AgentsResults.value | Where-Object {($_.Name -eq $AgentName ) -and ($_.enabled)}
if ($null -eq $findAgent)
{
    Write-Host ("Agent '{0}' already removed from Pool '{1}'" -f $AgentName, $PoolId)
}
else
{
    Write-Host ("Found Agent '{0}' in Pool '{1}', remove it" -f $AgentName, $PoolId)
    $uriAgentDetail = $UriOrganization + "/_apis/distributedtask/pools/$($PoolId)/agents/$($findAgent.Id)?api-version=6.0"
    Invoke-RestMethod -Uri $uriAgentDetail -Method Delete -Headers $AzureDevOpsAuthenicationHeader
}
