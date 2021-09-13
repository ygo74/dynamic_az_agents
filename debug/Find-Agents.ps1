
$PAT=$Env:AZP_TOKEN
$UriOrganization = $env:AZP_URL
$AgentName = $env:AZP_AGENT_NAME


# $UriPools = $UriOrganization + '/_apis/distributedtask/pools?api-version=6.0'
# $PoolsResult = Invoke-RestMethod -Uri $UriPools -Method get -Headers $AzureDevOpsAuthenicationHeader

$PoolId = "1"
$uriAgents = $UriOrganization + "/_apis/distributedtask/pools/$($PoolId)/agents?api-version=6.0"
$AzureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PAT)")) }

$timeout = 5
$StartWait = Get-Date
$findAgent = $false
$nbretry = 0
while(-not $findAgent)
{
    $nbretry ++
    Write-Host ("Try to retrieve agent '{0}' in Pool '{1}', Nb retry : '{2}'" -f $AgentName, $PoolId, $nbretry)

    $AgentsResults = Invoke-RestMethod -Uri $uriAgents -Method get -Headers $AzureDevOpsAuthenicationHeader
    $findAgent = ($null -ne ($AgentsResults.value | Where-Object {($_.Name -eq $AgentName ) -and ($_.enabled)}))
    if (-not $findAgent)
    {
        # Timeout Management
        $duration = (Get-Date) - $StartWait
        if ($duration.TotalMinutes -ge $timeout)
        {
            Write-Host "##vso[task.logissue type=error]Timeout reached before docker agent is ready."
            throw "Error"
            exit 1
        }

        # Pause for 10 seconds
        Write-Host ("Agent '{0}' not found in Pool '{1}', Wait '{2}' seconds" -f $AgentName, $PoolId, 10)
        Start-Sleep -Seconds 10

    }
    else
    {
        Write-Host ("Found Agent '{0}' in Pool '{1}'" -f $AgentName, $PoolId)
    }
}