# Offline integration tests. All replacements occur inside a temporary directory.
$ErrorActionPreference = 'Stop'
$installer = Join-Path (Split-Path $PSScriptRoot -Parent) 'install.ps1'
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ('nvim-installer-test-' + [Guid]::NewGuid().ToString('N'))
$savedRoot = $env:XDG_CONFIG_HOME
$savedApp = $env:NVIM_APPNAME
$failDownload = $false
$failMove = $false

function Invoke-WebRequest {
  param($Uri, $OutFile, [switch]$UseBasicParsing)
  if ($failDownload) { throw 'Simulated download failure' }
  Copy-Item -LiteralPath $testArchive -Destination $OutFile
}
function Move-Item {
  param($LiteralPath, $Destination)
  if ($failMove -and $LiteralPath -like '*unpacked*') { throw 'Simulated install failure' }
  Microsoft.PowerShell.Management\Move-Item -LiteralPath $LiteralPath -Destination $Destination
}
function Assert($Condition, $Message) {
  if (-not $Condition) { throw $Message }
}
function ExpectFailure {
  $failed = $false
  try { & $installer } catch { $failed = $true }
  Assert $failed 'Expected installation to fail'
}

try {
  $source = Join-Path $testRoot 'fixture/repo'
  foreach ($file in @('init.lua', 'lua/core/ui.lua', 'lua/plugins/init.lua', 'nvim-pack-lock.json')) {
    $path = Join-Path $source $file
    New-Item -ItemType Directory -Path (Split-Path $path) -Force | Out-Null
    Set-Content -LiteralPath $path -Value 'fixture'
  }
  $testArchive = Join-Path $testRoot 'config.zip'
  Compress-Archive -LiteralPath $source -DestinationPath $testArchive
  $env:XDG_CONFIG_HOME = Join-Path $testRoot 'config with spaces'
  $env:NVIM_APPNAME = 'test-nvim'
  $target = Join-Path $env:XDG_CONFIG_HOME $env:NVIM_APPNAME
  & $installer
  Assert (Test-Path -LiteralPath "$target/init.lua") 'Fresh install failed'
  Set-Content -LiteralPath "$target/local.txt" -Value 'preserve me'
  & $installer
  $backups = @(Get-ChildItem -LiteralPath $env:XDG_CONFIG_HOME -Directory -Filter 'test-nvim.backup-*')
  Assert ($backups.Count -eq 1) 'Backup missing'
  Assert (Test-Path -LiteralPath (Join-Path $backups[0].FullName 'local.txt')) 'Local edits lost'
  Assert (-not (Test-Path -LiteralPath "$target/local.txt")) 'Config was merged instead of replaced'

  Set-Content -LiteralPath "$target/keep.txt" -Value 'must survive'
  $failDownload = $true
  ExpectFailure
  $failDownload = $false
  Assert (Test-Path -LiteralPath "$target/keep.txt") 'Download failure damaged config'

  $failMove = $true
  ExpectFailure
  $failMove = $false
  Assert (Test-Path -LiteralPath "$target/keep.txt") 'Replacement failure did not restore config'

  Remove-Item -LiteralPath "$source/init.lua"
  Compress-Archive -LiteralPath $source -DestinationPath $testArchive -Force
  ExpectFailure
  Assert (Test-Path -LiteralPath "$target/keep.txt") 'Invalid archive damaged config'
  Assert (@(Get-ChildItem -LiteralPath $env:XDG_CONFIG_HOME -Force -Filter '.nvim-install-*').Count -eq 0) 'Staging directory leaked'
  $env:NVIM_APPNAME = '../unsafe'
  ExpectFailure
  Write-Host 'PASS: fresh install, backup, replacement, download failure, rollback, invalid archive, path validation'
} finally {
  $env:XDG_CONFIG_HOME = $savedRoot
  $env:NVIM_APPNAME = $savedApp
  $resolved = [IO.Path]::GetFullPath($testRoot)
  if ((Split-Path -Parent $resolved).TrimEnd('\') -ne ([IO.Path]::GetTempPath()).TrimEnd('\') -or
      (Split-Path -Leaf $resolved) -notmatch '^nvim-installer-test-[0-9a-f]{32}$') { throw 'Unsafe test cleanup path' }
  if (Test-Path -LiteralPath $resolved) { Remove-Item -LiteralPath $resolved -Recurse -Force }
}
