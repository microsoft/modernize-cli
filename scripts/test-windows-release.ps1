param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$')]
    [string]$Version,

    [ValidateSet('x64', 'arm64')]
    [string]$Architecture = 'x64',

    [ValidateSet('Host', 'Container')]
    [string]$Mode = 'Host',

    [Parameter(Mandatory = $true)]
    [string]$AssetDirectory,

    [Parameter(Mandatory = $true)]
    [string]$WorkDirectory,

    [Parameter(Mandatory = $true)]
    [string]$OutputDirectory
)

$ErrorActionPreference = 'Stop'
if ($Mode -eq 'Container' -and $env:MODERNIZE_RELEASE_CONTAINER -ne '1') {
    throw 'Container mode installs software and must only be invoked by the isolated test workflow.'
}

foreach ($directory in @($WorkDirectory, $OutputDirectory)) {
    [void](New-Item -ItemType Directory -Path $directory -Force)
}
$AssetDirectory = (Resolve-Path -LiteralPath $AssetDirectory).Path
$WorkDirectory = (Resolve-Path -LiteralPath $WorkDirectory).Path
$OutputDirectory = (Resolve-Path -LiteralPath $OutputDirectory).Path
$env:MODERNIZE_CONFIG_HOME = Join-Path $WorkDirectory 'config'
$report = [ordered]@{
    Version = $Version
    Architecture = $Architecture
    Mode = $Mode
    OSVersion = [Environment]::OSVersion.VersionString
    SystemVcRuntimePresent = Test-Path "$env:WINDIR\System32\vcruntime140.dll"
    Passed = $false
}

function Invoke-ReleaseProcess {
    param(
        [string]$Executable,
        [string]$Arguments,
        [int]$TimeoutSeconds = 30
    )

    $startInfo = New-Object Diagnostics.ProcessStartInfo
    $startInfo.FileName = $Executable
    $startInfo.Arguments = $Arguments
    $startInfo.WorkingDirectory = Split-Path -Parent $Executable
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.RedirectStandardInput = $true
    foreach ($secret in @('GH_TOKEN', 'GITHUB_TOKEN', 'COPILOT_GITHUB_TOKEN')) {
        $startInfo.EnvironmentVariables.Remove($secret)
    }
    $process = New-Object Diagnostics.Process
    $process.StartInfo = $startInfo
    try {
        [void]$process.Start()
        $process.StandardInput.Close()
        $stdout = $process.StandardOutput.ReadToEndAsync()
        $stderr = $process.StandardError.ReadToEndAsync()
        $timedOut = -not $process.WaitForExit($TimeoutSeconds * 1000)
        if ($timedOut) {
            & "$env:WINDIR\System32\taskkill.exe" /PID $process.Id /T /F | Out-Null
            if (-not $process.WaitForExit(10000)) {
                throw "Cannot stop timed-out process: $Executable"
            }
        }
        return [pscustomobject]@{
            Executable = Split-Path -Leaf $Executable
            Arguments = $Arguments
            TimedOut = $timedOut
            ExitCode = $process.ExitCode
            Stdout = $stdout.GetAwaiter().GetResult()
            Stderr = $stderr.GetAwaiter().GetResult()
        }
    } finally {
        $process.Dispose()
    }
}

function Assert-Probe {
    param($Probe, [int[]]$ExitCodes = @(0), [string]$OutputPattern)

    if ($Probe.TimedOut -or $Probe.ExitCode -notin $ExitCodes) {
        throw "Startup probe failed: $($Probe | ConvertTo-Json -Compress)"
    }
    if ($OutputPattern -and "$($Probe.Stdout)$($Probe.Stderr)" -notmatch $OutputPattern) {
        throw "Unexpected output: $($Probe | ConvertTo-Json -Compress)"
    }
}

try {
    $prefix = "modernize_${Version}_windows_${Architecture}"
    $msi = Join-Path $AssetDirectory "$prefix.msi"
    if ($Mode -eq 'Host') {
        $expectedArchitecture = if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { 'arm64' } else { 'x64' }
        if ($Architecture -ne $expectedArchitecture) {
            throw "Native startup tests require $Architecture Windows; this process is $expectedArchitecture."
        }
        $checksums = @{}
        foreach ($line in Get-Content (Join-Path $AssetDirectory "modernize_${Version}_checksums.txt")) {
            if ($line -match '^([a-fA-F0-9]{64})\s+\*?(.+)$') {
                $checksums[$Matches[2]] = $Matches[1]
            }
        }
        $report.AssetHashes = @{}
        foreach ($extension in @('msi', 'zip')) {
            $name = "$prefix.$extension"
            $hash = (Get-FileHash (Join-Path $AssetDirectory $name) -Algorithm SHA256).Hash
            $report.AssetHashes[$name] = $hash
            if (-not $checksums.ContainsKey($name) -or $hash -ne $checksums[$name]) {
                throw "Release checksum mismatch: $name"
            }
        }
        $payload = Join-Path $WorkDirectory 'payload'
        Expand-Archive (Join-Path $AssetDirectory "$prefix.zip") $payload -Force
        $plugin = Join-Path $payload "runtimes\win-$Architecture\native\plugins\computer-use"
        $report.Signatures = @()
        foreach ($binary in @($msi, (Join-Path $payload 'modernize.exe'),
                (Join-Path $plugin 'computer-use-mcp.exe'), (Join-Path $plugin 'CopilotComputerUse.exe'))) {
            $signature = Get-AuthenticodeSignature -LiteralPath $binary
            $report.Signatures += [pscustomobject]@{
                File = Split-Path -Leaf $binary
                Status = $signature.Status.ToString()
                Signer = $signature.SignerCertificate.Subject
            }
            if ($signature.Status -ne 'Valid') {
                throw "Invalid signature: $binary ($($signature.Status))"
            }
        }
        $report.BundledVcRuntime = @(Get-ChildItem $payload -Recurse -Filter 'vcruntime140*.dll' |
            ForEach-Object { $_.FullName.Substring($payload.Length + 1) })
        $report.CliVersion = Invoke-ReleaseProcess (Join-Path $payload 'modernize.exe') '--version'
        Assert-Probe $report.CliVersion -OutputPattern ([regex]::Escape($Version))
        $report.CliHelp = Invoke-ReleaseProcess (Join-Path $payload 'modernize.exe') '--help'
        Assert-Probe $report.CliHelp -OutputPattern 'Usage'
        $report.McpHelper = Invoke-ReleaseProcess (Join-Path $plugin 'computer-use-mcp.exe') '--help'
        Assert-Probe $report.McpHelper -ExitCodes @(0, 2) -OutputPattern 'arguments are not supported|Usage'
        $report.ComputerUseHelper = Invoke-ReleaseProcess (Join-Path $plugin 'CopilotComputerUse.exe') '--help'
        Assert-Probe $report.ComputerUseHelper -OutputPattern 'Usage'
    } else {
        if ($Architecture -ne 'x64') {
            throw 'The Windows Server Core container test currently supports x64 only.'
        }
        if ($report.SystemVcRuntimePresent) {
            throw 'The container already has VC runtime installed; it cannot establish a clean baseline.'
        }
        Add-Type -TypeDefinition @'
using System.Runtime.InteropServices;
public static class ReleaseErrorMode {
    [DllImport("kernel32.dll")] public static extern uint SetErrorMode(uint mode);
}
'@
        [void][ReleaseErrorMode]::SetErrorMode(3)
        $installed = Join-Path $WorkDirectory 'installed'
        $installLog = Join-Path $OutputDirectory 'msi-install.log'
        $report.MsiInstall = Invoke-ReleaseProcess "$env:WINDIR\System32\msiexec.exe" `
            "/i `"$msi`" /qn /norestart INSTALLFOLDER=`"$installed`" /l*v `"$installLog`"" 180
        Assert-Probe $report.MsiInstall -ExitCodes @(0, 3010)
        $plugin = Join-Path $installed 'runtimes\win-x64\native\plugins\computer-use'
        $helper = Join-Path $plugin 'computer-use-mcp.exe'
        $report.CliBeforeRuntime = Invoke-ReleaseProcess (Join-Path $installed 'modernize.exe') '--version'
        $report.HelperBeforeRuntime = Invoke-ReleaseProcess $helper '--help'
        $runtimeFiles = @(Get-ChildItem (Join-Path $AssetDirectory 'vc-runtime-x64') -Filter '*.dll')
        if ($runtimeFiles.Count -eq 0) {
            throw 'App-local runtime comparison requires official Visual Studio redistributable DLLs.'
        }
        $report.AppLocalRuntimeFiles = @($runtimeFiles | ForEach-Object {
            [pscustomobject]@{ File = $_.Name; SHA256 = (Get-FileHash $_.FullName).Hash }
        })
        foreach ($runtimeFile in $runtimeFiles) {
            Copy-Item $runtimeFile.FullName -Destination $plugin
        }
        $report.HelperWithAppLocalRuntime = Invoke-ReleaseProcess $helper '--help'
        Assert-Probe $report.HelperWithAppLocalRuntime -ExitCodes @(0, 2) -OutputPattern 'arguments are not supported|Usage'
        foreach ($runtimeFile in $runtimeFiles) {
            Remove-Item (Join-Path $plugin $runtimeFile.Name)
        }
        $runtimeInstaller = Join-Path $AssetDirectory 'vc_redist.x64.exe'
        $report.RuntimeInstall = Invoke-ReleaseProcess $runtimeInstaller `
            "/install /quiet /norestart /log `"$(Join-Path $OutputDirectory 'vcredist-install.log')`"" 180
        Assert-Probe $report.RuntimeInstall -ExitCodes @(0, 3010)
        $report.CliAfterRuntime = Invoke-ReleaseProcess (Join-Path $installed 'modernize.exe') '--version'
        Assert-Probe $report.CliAfterRuntime -OutputPattern ([regex]::Escape($Version))
        $report.HelperAfterRuntime = Invoke-ReleaseProcess $helper '--help'
        Assert-Probe $report.HelperAfterRuntime -ExitCodes @(0, 2) -OutputPattern 'arguments are not supported|Usage'
        $report.MissingVcRuntimeReproduced = ($report.HelperBeforeRuntime.ExitCode -eq -1073741515)
        $uninstallLog = Join-Path $OutputDirectory 'msi-uninstall.log'
        $report.MsiUninstall = Invoke-ReleaseProcess "$env:WINDIR\System32\msiexec.exe" `
            "/x `"$msi`" /qn /norestart /l*v `"$uninstallLog`"" 180
        Assert-Probe $report.MsiUninstall -ExitCodes @(0, 3010)
        if ($report.MissingVcRuntimeReproduced) {
            throw 'Release helper requires an externally installed VC runtime: clean startup failed, then succeeded after installing VC runtime.'
        }
        Assert-Probe $report.CliBeforeRuntime -OutputPattern ([regex]::Escape($Version))
        Assert-Probe $report.HelperBeforeRuntime -ExitCodes @(0, 2) -OutputPattern 'arguments are not supported|Usage'
    }
    $report.Passed = $true
} catch {
    $report.Error = $_.Exception.Message
    throw
} finally {
    $report | ConvertTo-Json -Depth 8 | Set-Content (Join-Path $OutputDirectory "$Mode-$Architecture.json") -Encoding UTF8
    $report | ConvertTo-Json -Depth 8 | Write-Output
}