
$PAT=$Env:AZP_TOKEN
$AzureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PAT)")) }
$UriOrganization = $env:AZP_URL


# $UriPools = $UriOrganization + '/_apis/distributedtask/pools?api-version=6.0'
# $PoolsResult = Invoke-RestMethod -Uri $UriPools -Method get -Headers $AzureDevOpsAuthenicationHeader

$PoolId = "1"
$uriAgents = $UriOrganization + "/_apis/distributedtask/pools/$($PoolId)/agents?api-version=6.0"

$timeout = 5
$StartWait = Get-Date
$findAgent = $false
$AgentName = "dockeragent_669"
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