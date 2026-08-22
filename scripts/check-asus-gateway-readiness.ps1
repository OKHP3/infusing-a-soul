[CmdletBinding()]
param(
    [string]$Distro = "Ubuntu",
    [ValidatePattern("^[a-zA-Z0-9@._-]+\.service$")]
    [string]$GatewayService = "openclaw-gateway.service",
    [string]$WslBootTask = "WSL Boot",
    [string[]]$RequiredEndpoints = @(
        "10.10.1.201:1234",
        "10.10.1.201:11434",
        "10.10.1.201:6333",
        "10.10.1.201:8888"
    )
)

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

function Invoke-WslCheck {
    param([string]$Script)

    $output = $Script | & wsl.exe -d $Distro -- bash -s 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw ($output | Out-String)
    }

    return $output
}

try {
    $distroRows = & wsl.exe -l -v 2>&1
    $distroText = ($distroRows | Out-String) -replace "`0", ""
    if ($LASTEXITCODE -eq 0 -and $distroText -match "(?m)^\s*\*?\s*$([regex]::Escape($Distro))\s+") {
        Add-Check -Name "WSL distribution" -Status "PASS" -Detail "$Distro is registered."
    }
    else {
        Add-Check -Name "WSL distribution" -Status "FAIL" -Detail "$Distro is not registered or could not be listed."
    }
}
catch {
    Add-Check -Name "WSL distribution" -Status "FAIL" -Detail $_.Exception.Message.Trim()
}

try {
    $task = Get-ScheduledTask -TaskName $WslBootTask -ErrorAction SilentlyContinue
    if ($null -eq $task) {
        Add-Check -Name "WSL boot task" -Status "FAIL" -Detail "Scheduled Task '$WslBootTask' is absent. The WSL gateway can idle-stop after its last client exits."
    }
    else {
        Add-Check -Name "WSL boot task" -Status "PASS" -Detail "Scheduled Task '$WslBootTask' is present with state '$($task.State)'."
    }
}
catch {
    Add-Check -Name "WSL boot task" -Status "WARN" -Detail "Could not inspect Scheduled Task '$WslBootTask': $($_.Exception.Message.Trim())"
}

try {
    $wslGatewayCheck = @'
printf 'dbus_launch='; command -v dbus-launch || true
printf 'linger='; loginctl show-user "$(whoami)" -p Linger --value 2>/dev/null || true
printf 'systemd='; grep -E '^systemd\s*=\s*true' /etc/wsl.conf 2>/dev/null || true
printf 'service_enabled='; systemctl --user is-enabled __GATEWAY_SERVICE__ 2>/dev/null || true
printf 'service_active='; systemctl --user is-active __GATEWAY_SERVICE__ 2>/dev/null || true
listener='not-listening'
for attempt in $(seq 1 15); do
  if ss -ltnH 2>/dev/null | grep -q ':18789'; then
    listener='LISTEN'
    break
  fi
  sleep 1
done
printf 'listener=%s\n' "$listener"
'@
    $wslGatewayCheck = $wslGatewayCheck.Replace("__GATEWAY_SERVICE__", $GatewayService)
    $prerequisites = Invoke-WslCheck -Script $wslGatewayCheck

    $prerequisiteText = $prerequisites | Out-String
    if ($prerequisiteText -match "dbus_launch=/" -and $prerequisiteText -match "linger=yes" -and $prerequisiteText -match "systemd=systemd=true") {
        Add-Check -Name "WSL prerequisites" -Status "PASS" -Detail "systemd, user lingering, and dbus-launch are available."
    }
    else {
        Add-Check -Name "WSL prerequisites" -Status "FAIL" -Detail "systemd, user lingering, or dbus-launch is missing."
    }

    if ($prerequisiteText -match "service_enabled=enabled") {
        Add-Check -Name "OpenClaw service" -Status "PASS" -Detail "$GatewayService is enabled in the WSL user session."
    }
    else {
        Add-Check -Name "OpenClaw service" -Status "FAIL" -Detail "$GatewayService is not enabled."
    }

    if ($prerequisiteText -match "service_active=active" -and $prerequisiteText -match "listener=LISTEN") {
        Add-Check -Name "Gateway listener" -Status "PASS" -Detail "The loopback gateway listener is active on port 18789 inside WSL."
    }
    elseif ($prerequisiteText -match "service_active=active") {
        Add-Check -Name "Gateway listener" -Status "FAIL" -Detail "The service is active but port 18789 is not listening. Inspect the OpenClaw service journal."
    }
    else {
        Add-Check -Name "Gateway listener" -Status "FAIL" -Detail "The service is not active."
    }
}
catch {
    Add-Check -Name "WSL gateway checks" -Status "FAIL" -Detail $_.Exception.Message.Trim()
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
