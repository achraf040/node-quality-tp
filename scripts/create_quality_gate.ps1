param(
  [string]$ProjectKey = "node-quality-tp",
  [string]$GateName   = "CESI - NodeJS TP Gate"
)

if (-not $env:SONAR_HOST_URL) { Write-Error "Env SONAR_HOST_URL is required"; exit 1 }
if (-not $env:SONAR_TOKEN)    { Write-Error "Env SONAR_TOKEN is required"; exit 1 }

$base  = $env:SONAR_HOST_URL
$token = $env:SONAR_TOKEN

function Invoke-SonarPost($path, $body) {
  try {
    Invoke-RestMethod -Method Post -Uri "$base$path" `
      -Headers @{ Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${token}:")) } `
      -Body $body -ContentType "application/x-www-form-urlencoded" | Out-Null
    return $true
  } catch {
    return $false
  }
}

Write-Host "Creating/ensuring Quality Gate: '$GateName' at $base"

$ok = Invoke-SonarPost "/api/qualitygates/create" "name=$([uri]::EscapeDataString($GateName))"
if ($ok) { Write-Host "Gate created." } else { Write-Host "Gate may already exist. Continuing..." }

function Add-Cond($metric, $op, $threshold) {
  $body = "gateName=$([uri]::EscapeDataString($GateName))&metric=$metric&op=$op&error=$threshold"
  $ok = Invoke-SonarPost "/api/qualitygates/add_condition" $body
  if ($ok) { Write-Host "Condition added: $metric $op $threshold" } else { Write-Host "Condition may already exist: $metric" }
}

Add-Cond "new_coverage" "LT" "80"
Add-Cond "new_duplicated_lines_density" "GT" "3"
Add-Cond "new_security_hotspots_reviewed" "LT" "100"
Add-Cond "new_security_rating" "GT" "1"
Add-Cond "new_reliability_rating" "GT" "1"
Add-Cond "new_maintainability_rating" "GT" "1"

$assignOk = Invoke-SonarPost "/api/qualitygates/select" "projectKey=$ProjectKey&gateName=$([uri]::EscapeDataString($GateName))"
if ($assignOk) { Write-Host "Gate assigned to project '$ProjectKey'." } else { Write-Error "Failed to assign gate to '$ProjectKey'." ; exit 1 }
Write-Host "Done."
