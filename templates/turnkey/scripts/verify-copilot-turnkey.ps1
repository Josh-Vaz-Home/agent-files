#Requires -Version 7.0
[CmdletBinding()]
param(
    [string]$RepoRoot = (Get-Location).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$resolvedRepoRoot = (Resolve-Path -Path $RepoRoot).Path
$results = [System.Collections.Generic.List[object]]::new()

function Add-Result {
    param(
        [string]$Category,
        [string]$Name,
        [ValidateSet('PASS', 'WARN', 'FAIL')]
        [string]$Status,
        [string]$Details
    )

    $results.Add([pscustomobject]@{
            Category = $Category
            Name     = $Name
            Status   = $Status
            Details  = $Details
        })
}

function Resolve-ExtensionFolderId {
    param([string]$Name)

    return ($Name -replace '-(\d+\.)+\d+.*$', '').ToLowerInvariant()
}

function Get-InstalledExtensionIds {
    $codeCommand = Get-Command code -ErrorAction SilentlyContinue
    if ($null -ne $codeCommand) {
        $cliExtensions = @(code --list-extensions 2>$null)
        if ($cliExtensions.Count -gt 0) {
            Add-Result -Category 'Environment' -Name 'VS Code extension source' -Status 'PASS' -Details 'Verified installed extensions with `code --list-extensions`.'
            return $cliExtensions | ForEach-Object { $_.Trim().ToLowerInvariant() } | Sort-Object -Unique
        }
    }

    $extensionsFolder = Join-Path $HOME '.vscode\extensions'
    if (Test-Path $extensionsFolder) {
        $folderExtensions = @(Get-ChildItem -Path $extensionsFolder -Directory | ForEach-Object { Resolve-ExtensionFolderId -Name $_.Name } | Sort-Object -Unique)
        if ($folderExtensions.Count -gt 0) {
            Add-Result -Category 'Environment' -Name 'VS Code extension source' -Status 'WARN' -Details 'Fell back to the local extensions folder because the `code` CLI was unavailable or returned no extension list.'
            return $folderExtensions
        }
    }

    Add-Result -Category 'Environment' -Name 'VS Code extension source' -Status 'FAIL' -Details 'Could not determine installed extensions from the `code` CLI or the local extensions folder.'
    return @()
}

function Get-JsonFileContent {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        return $null
    }

    try {
        return Get-Content -Path $Path -Raw | ConvertFrom-Json -AsHashtable
    }
    catch {
        Add-Result -Category 'Files' -Name $Path -Status 'FAIL' -Details "Unreadable JSON: $($_.Exception.Message)"
        return $null
    }
}

function Get-NestedValue {
    param(
        [hashtable]$Object,
        [string]$PropertyPath
    )

    if ($Object.ContainsKey($PropertyPath)) {
        return $Object[$PropertyPath]
    }

    $current = $Object
    foreach ($segment in $PropertyPath.Split('.')) {
        if ($current -is [hashtable] -and $current.ContainsKey($segment)) {
            $current = $current[$segment]
        }
        else {
            return $null
        }
    }

    return $current
}

function Test-RequiredSetting {
    param(
        [string]$SettingName,
        [object]$Expected,
        [hashtable]$WorkspaceSettings,
        [hashtable]$UserSettings
    )

    $workspaceValue = if ($null -ne $WorkspaceSettings) { Get-NestedValue -Object $WorkspaceSettings -PropertyPath $SettingName } else { $null }
    $userValue = if ($null -ne $UserSettings) { Get-NestedValue -Object $UserSettings -PropertyPath $SettingName } else { $null }

    $settingFound = $false
    $source = $null
    $actual = $null

    foreach ($candidate in @(
            @{ Source = 'workspace'; Value = $workspaceValue },
            @{ Source = 'user'; Value = $userValue }
        )) {
        $value = $candidate.Value
        if ($null -eq $value) {
            continue
        }

        if ($Expected -is [System.Array]) {
            if (@($value) -join '|' -eq @($Expected) -join '|') {
                $settingFound = $true
                $source = $candidate.Source
                $actual = @($value) -join ', '
                break
            }
        }
        elseif ($value -eq $Expected) {
            $settingFound = $true
            $source = $candidate.Source
            $actual = $value
            break
        }
    }

    if ($settingFound) {
        Add-Result -Category 'Settings' -Name $SettingName -Status 'PASS' -Details "Expected value found in $source settings: $actual"
    }
    else {
        Add-Result -Category 'Settings' -Name $SettingName -Status 'FAIL' -Details "Expected value not found. Expected: $Expected"
    }
}

function Test-CommandAvailable {
    param(
        [string]$CommandName,
        [string]$DisplayName
    )

    if (Get-Command $CommandName -ErrorAction SilentlyContinue) {
        Add-Result -Category 'Environment' -Name $DisplayName -Status 'PASS' -Details "$CommandName is available on PATH."
        return $true
    }

    Add-Result -Category 'Environment' -Name $DisplayName -Status 'FAIL' -Details "$CommandName is not available on PATH."
    return $false
}

function Test-Firefox {
    $candidates = @(
        @(
            (Get-Command firefox -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue),
            (Get-Command firefox.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue),
            (Join-Path $env:ProgramFiles 'Mozilla Firefox\firefox.exe'),
            (Join-Path ${env:ProgramFiles(x86)} 'Mozilla Firefox\firefox.exe')
        ) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -Unique
    )

    if ($candidates.Count -gt 0) {
        Add-Result -Category 'Environment' -Name 'Firefox' -Status 'PASS' -Details "Found Firefox at $($candidates[0])"
        return
    }

    Add-Result -Category 'Environment' -Name 'Firefox' -Status 'FAIL' -Details 'Firefox is required for the strict browser profile but was not found in a standard location or on PATH.'
}

function Test-DockerServer {
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Add-Result -Category 'Environment' -Name 'Docker server' -Status 'FAIL' -Details 'docker CLI is not available on PATH.'
        return
    }

    try {
        $serverVersion = docker version --format '{{.Server.Version}}' 2>$null
        if ([string]::IsNullOrWhiteSpace($serverVersion)) {
            throw 'Docker server version not returned.'
        }

        Add-Result -Category 'Environment' -Name 'Docker server' -Status 'PASS' -Details "Docker server is reachable. Version: $serverVersion"
    }
    catch {
        Add-Result -Category 'Environment' -Name 'Docker server' -Status 'FAIL' -Details 'Docker CLI is present but the Docker server is not reachable.'
    }
}

$requiredExtensions = @(
    'ms-python.python',
    'ms-python.vscode-pylance',
    'dbaeumer.vscode-eslint',
    'esbenp.prettier-vscode',
    'github.vscode-pull-request-github',
    'github.vscode-github-actions',
    'sonarsource.sonarlint-vscode',
    'ms-azuretools.vscode-containers',
    'ms-azuretools.vscode-docker',
    'ms-ossdata.vscode-pgsql',
    'ms-playwright.playwright',
    '42crunch.vscode-openapi',
    'humao.rest-client'
)

$installedExtensions = Get-InstalledExtensionIds
$missingExtensions = @($requiredExtensions | Where-Object { $_.ToLowerInvariant() -notin $installedExtensions })
if ($missingExtensions.Count -eq 0) {
    Add-Result -Category 'Extensions' -Name 'Required extension stack' -Status 'PASS' -Details 'All required extensions are installed.'
}
else {
    Add-Result -Category 'Extensions' -Name 'Required extension stack' -Status 'FAIL' -Details ('Missing: ' + ($missingExtensions -join ', '))
}

$workspaceExtensionsPath = Join-Path $resolvedRepoRoot '.vscode\extensions.json'
$workspaceSettingsPath = Join-Path $resolvedRepoRoot '.vscode\settings.json'
$userSettingsPath = Join-Path $env:APPDATA 'Code\User\settings.json'

$workspaceExtensions = Get-JsonFileContent -Path $workspaceExtensionsPath
$workspaceSettings = Get-JsonFileContent -Path $workspaceSettingsPath
$userSettings = Get-JsonFileContent -Path $userSettingsPath

if ($null -ne $workspaceExtensions -and $workspaceExtensions.ContainsKey('recommendations')) {
    $recommended = @($workspaceExtensions['recommendations']) | ForEach-Object { $_.ToLowerInvariant() }
    $missingRecommendations = @($requiredExtensions | Where-Object { $_.ToLowerInvariant() -notin $recommended })
    if ($missingRecommendations.Count -eq 0) {
        Add-Result -Category 'Files' -Name '.vscode/extensions.json' -Status 'PASS' -Details 'All required extensions are recommended in the workspace.'
    }
    else {
        Add-Result -Category 'Files' -Name '.vscode/extensions.json' -Status 'FAIL' -Details ('Missing recommendations: ' + ($missingRecommendations -join ', '))
    }
}
else {
    Add-Result -Category 'Files' -Name '.vscode/extensions.json' -Status 'FAIL' -Details 'Missing or unreadable workspace extension recommendations.'
}

Test-RequiredSetting -SettingName 'github.copilot.chat.githubMcpServer.enabled' -Expected $true -WorkspaceSettings $workspaceSettings -UserSettings $userSettings
Test-RequiredSetting -SettingName 'github.copilot.chat.githubMcpServer.toolsets' -Expected @('default') -WorkspaceSettings $workspaceSettings -UserSettings $userSettings
Test-RequiredSetting -SettingName 'githubPullRequests.experimental.chat' -Expected $true -WorkspaceSettings $workspaceSettings -UserSettings $userSettings
Test-RequiredSetting -SettingName 'python.analysis.typeCheckingMode' -Expected 'strict' -WorkspaceSettings $workspaceSettings -UserSettings $userSettings
Test-RequiredSetting -SettingName 'python.analysis.diagnosticMode' -Expected 'workspace' -WorkspaceSettings $workspaceSettings -UserSettings $userSettings

$requiredFiles = @(
    'docs/copilot-turnkey.md',
    '.env.example',
    '.vscode/settings.json',
    '.vscode/extensions.json',
    'scripts/verify-copilot-turnkey.ps1'
)

foreach ($relativePath in $requiredFiles) {
    $fullPath = Join-Path $resolvedRepoRoot $relativePath
    if (Test-Path $fullPath) {
        Add-Result -Category 'Files' -Name $relativePath -Status 'PASS' -Details 'Found required file.'
    }
    else {
        Add-Result -Category 'Files' -Name $relativePath -Status 'FAIL' -Details 'Required file is missing.'
    }
}

$openApiCandidates = @(
    @(
        (Join-Path $resolvedRepoRoot 'openapi/openapi.yaml'),
        (Join-Path $resolvedRepoRoot 'docs/openapi.yaml')
    ) | Where-Object { Test-Path $_ }
)
if ($openApiCandidates.Count -gt 0) {
    Add-Result -Category 'Files' -Name 'OpenAPI file' -Status 'PASS' -Details "Found $($openApiCandidates[0])"
}
else {
    Add-Result -Category 'Files' -Name 'OpenAPI file' -Status 'FAIL' -Details 'Expected `openapi/openapi.yaml` or `docs/openapi.yaml`.'
}

$httpCandidates = @()
$rootRequests = Join-Path $resolvedRepoRoot 'requests.http'
if (Test-Path $rootRequests) {
    $httpCandidates += $rootRequests
}
$apiFolder = Join-Path $resolvedRepoRoot 'api'
if (Test-Path $apiFolder) {
    $httpCandidates += Get-ChildItem -Path $apiFolder -Recurse -File -Filter '*.http' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
}
if ($httpCandidates.Count -gt 0) {
    Add-Result -Category 'Files' -Name 'REST Client requests' -Status 'PASS' -Details "Found $($httpCandidates[0])"
}
else {
    Add-Result -Category 'Files' -Name 'REST Client requests' -Status 'FAIL' -Details 'Expected `requests.http` or at least one `api/*.http` file.'
}

$playwrightConfigs = @(Get-ChildItem -Path $resolvedRepoRoot -File -Filter 'playwright.config.*' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName)
if ($playwrightConfigs.Count -gt 0) {
    Add-Result -Category 'Files' -Name 'Playwright config' -Status 'PASS' -Details "Found $($playwrightConfigs[0])"
}
else {
    Add-Result -Category 'Files' -Name 'Playwright config' -Status 'FAIL' -Details 'Expected a `playwright.config.*` file in the repo root.'
}

$placeholderFiles = @(
    (Join-Path $resolvedRepoRoot 'docs/copilot-turnkey.md')
)

if ($httpCandidates.Count -gt 0) {
    $placeholderFiles += $httpCandidates
}

if ($openApiCandidates.Count -gt 0) {
    $placeholderFiles += $openApiCandidates
}

$placeholderFiles = $placeholderFiles | Where-Object { Test-Path $_ } | Select-Object -Unique

foreach ($file in $placeholderFiles) {
    $placeholders = Select-String -Path $file -Pattern '<replace-me' -SimpleMatch -ErrorAction SilentlyContinue
    if ($placeholders) {
        Add-Result -Category 'Placeholders' -Name ([IO.Path]::GetFileName($file)) -Status 'FAIL' -Details 'Replace every `<replace-me>` token before declaring turnkey readiness.'
    }
    else {
        Add-Result -Category 'Placeholders' -Name ([IO.Path]::GetFileName($file)) -Status 'PASS' -Details 'No unresolved `<replace-me>` tokens found.'
    }
}

Test-CommandAvailable -CommandName 'node' -DisplayName 'Node.js' | Out-Null
Test-CommandAvailable -CommandName 'npm' -DisplayName 'npm' | Out-Null
Test-CommandAvailable -CommandName 'python' -DisplayName 'Python' | Out-Null
Test-Firefox
Test-DockerServer

$sortedResults = $results | Sort-Object Category, Name
$sortedResults | Format-Table -AutoSize | Out-String | Write-Host

$failedResults = @($sortedResults | Where-Object { $_.Status -eq 'FAIL' })
$warningResults = @($sortedResults | Where-Object { $_.Status -eq 'WARN' })

if ($failedResults.Count -gt 0) {
    Write-Host "Turnkey verification failed: $($failedResults.Count) failing check(s), $($warningResults.Count) warning(s)." -ForegroundColor Red
    exit 1
}

if ($warningResults.Count -gt 0) {
    Write-Host "Turnkey verification passed with $($warningResults.Count) warning(s)." -ForegroundColor Yellow
    exit 0
}

Write-Host 'Turnkey verification passed.' -ForegroundColor Green
exit 0
