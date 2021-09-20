# define target
$installerUri = [uri]"https://download.visualstudio.microsoft.com/download/pr/22c17f05-944c-48dc-9f68-b1663f9df4cb/f3f6868ff82ea90b510c3ef76b8ee3ed2b559795da8dd80f3706fb8a7f7510d6/vs_BuildTools.exe"
$newbuildToolsVersion = "16.11.3"

$newBuildTools = "vs_buildtools-{0}" -f $newbuildToolsVersion

$ProgressPreference="SilentlyContinue"

# Download new Build tools installer
$proxy = [System.Net.WebRequest]::GetSystemWebProxy().GetProxy($installerUri) | Select-Object -ExpandProperty OriginalString
Invoke-WebRequest -Uri $installerUri -OutFile "$newBuildTools.exe" -Proxy $proxy  -ProxyUseDefaultCredentials

$layoutName = "vs_buildtools-desktop-web-{0}" -f $newbuildToolsVersion

$ArgumentsList = @(
    "--layout `"$layoutName-new`"",
    '--add Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools;includeRecommended;includeOptional',
    '--add Microsoft.VisualStudio.Workload.WebBuildTools;includeRecommended;includeOptional',
    '--add Microsoft.VisualStudio.Workload.NodeBuildTools;includeRecommended;includeOptional',
    '--add Microsoft.VisualStudio.Component.Workflow.BuildTools;includeRecommended;includeOptional',
    '--add Microsoft.VisualStudio.Workload.MSBuildTools;includeRecommended;includeOptional',
    '--lang en-US'
)

$buildToolsPath = Resolve-Path -Path "$newBuildTools.exe" | Select-Object -ExpandProperty Path
Start-Process -FilePath $buildToolsPath -ArgumentList $ArgumentsList -NoNewWindow -Wait

