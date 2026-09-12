[CmdletBinding()]
param(
    [string]$CompanionProcessName = "openclaw.tray.winui",
    [int]$GatewayPort = 18789,
    [string]$DiagnosticsLogPath = (Join-Path $env:LOCALAPPDATA "OpenClawTray\Logs\diagnostics.jsonl"),
    [int]$DiagnosticsLogMaxAgeHours = 24,
    [string]$StartupNamePattern = "*OpenClaw*",
    [string[]]$RequiredEndpoints = @(
        "10.10.1.201:1234",
        "10.10.1.201:11434",
        "10.10.1.201:6333",
        "10.10.1.201:8888"
    )
)

# Rewritten 2026-09-12 for the native OpenClaw Windows Companion architecture.
# The gateway used to run inside a WSL2/Ubuntu distro; it now runs as a native
# Windows service managed by the Companion app. This script replaces the old
# WSL-registration / systemd-service checks with checks that match that
# architecture. It is read-only: it does not open, read, or print any
# credential, token, or config value, and it changes nothing.

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$checks = [System.Collections.Generic.List[object]]::new()

function Add-Check {
    param(
        [string]$Name,
        [ValidateSet("PASS", "FAIL", "WARN")]
        [string]$Status,
        [string]$Detail
    )

    $checks.Add([pscustomobject]@{
            Check  = $Name
            Status = $Status
            Detail = $Detail
        })
}

try {
    $proc = Get-Process -Name $CompanionProcessName -ErrorAction SilentlyContinue
    if ($proc) {
        Add-Check -Name "Companion process" -Status "PASS" -Detail "'$CompanionProcessName' is running (PID $($proc[0].Id))."
    }
    else {
        Add-Check -Name "Companion process" -Status "FAIL" -Detail "'$CompanionProcessName' is not running. Launch OpenClaw Windows Companion."
    }
}
catch {
    Add-Check -Name "Companion process" -Status "WARN" -Detail $_.Exception.Message.Trim()
}

try {
    $gatewayUp = Test-NetConnection -ComputerName "127.0.0.1" -Port $GatewayPort -InformationLevel Quiet -WarningAction SilentlyContinue
    if ($gatewayUp) {
        Add-Check -Name "Gateway listener" -Status "PASS" -Detail "127.0.0.1:$GatewayPort is accepting connections."
    }
    else {
        Add-Check -Name "Gateway listener" -Status "FAIL" -Detail "127.0.0.1:$GatewayPort is not accepting connections. Check the Companion app's Diagnostics page."
    }
}
catch {
    Add-Check -Name "Gateway listener" -Status "WARN" -Detail $_.Exception.Message.Trim()
}

try {
    if (Test-Path -LiteralPath $DiagnosticsLogPath) {
        $ageHours = ((Get-Date) - (Get-Item -LiteralPath $DiagnosticsLogPath).LastWriteTime).TotalHours
        if ($ageHours -le $DiagnosticsLogMaxAgeHours) {
            Add-Check -Name "Diagnostics log" -Status "PASS" -Detail "Found, last written $([math]::Round($ageHours, 1))h ago."
        }
        else {
            Add-Check -Name "Diagnostics log" -Status "WARN" -Detail "Found, but last written $([math]::Round($ageHours, 1))h ago (older than $DiagnosticsLogMaxAgeHours h). Companion may not have run recently."
        }
    }
    else {
        Add-Check -Name "Diagnostics log" -Status "FAIL" -Detail "Not found at '$DiagnosticsLogPath'. Adjust -DiagnosticsLogPath if Companion installs to a different location."
    }
}
catch {
    Add-Check -Name "Diagnostics log" -Status "WARN" -Detail $_.Exception.Message.Trim()
}

try {
    $runKeyHit = $false
    $runKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    if (Test-Path $runKeyPath) {
        $runKeyHit = [bool](Get-Item -Path $runKeyPath | Select-Object -ExpandProperty Property | Where-Object { $_ -like $StartupNamePattern })
    }

    $startupFolder = [Environment]::GetFolderPath("Startup")
    $startupShortcutHit = [bool](Get-ChildItem -Path $startupFolder -Filter $StartupNamePattern -ErrorAction SilentlyContinue)

    $scheduledTaskHit = [bool](Get-ScheduledTask -TaskName $StartupNamePattern -ErrorAction SilentlyContinue)

    if ($runKeyHit -or $startupShortcutHit -or $scheduledTaskHit) {
        $via = @()
        if ($runKeyHit) { $via += "Run key" }
        if ($startupShortcutHit) { $via += "Startup folder" }
        if ($scheduledTaskHit) { $via += "Scheduled Task" }
        Add-Check -Name "Startup persistence" -Status "PASS" -Detail "Registered via: $($via -join ', ')."
    }
    else {
        Add-Check -Name "Startup persistence" -Status "WARN" -Detail "No match for '$StartupNamePattern' in the Run key, Startup folder, or Task Scheduler. Companion may use a different mechanism than this check knows about; confirm manually before treating this as a real failure."
    }
}
catch {
    Add-Check -Name "Startup persistence" -Status "WARN" -Detail $_.Exception.Message.Trim()
}

foreach ($endpoint in $RequiredEndpoints) {
    $parts = $endpoint.Split(":", 2)
    $hostName = $parts[0]
    $port = [int]$parts[1]

    try {
        $reachable = Test-NetConnection -ComputerName $hostName -Port $port -InformationLevel Quiet -WarningAction SilentlyContinue
        if ($reachable) {
            Add-Check -Name "LAN service $endpoint" -Status "PASS" -Detail "TCP connection succeeded."
        }
        else {
            Add-Check -Name "LAN service $endpoint" -Status "FAIL" -Detail "TCP connection failed."
        }
    }
    catch {
        Add-Check -Name "LAN service $endpoint" -Status "WARN" -Detail $_.Exception.Message.Trim()
    }
}

$checks | Format-Table -AutoSize

if ($checks.Status -contains "FAIL") {
    exit 1
}
