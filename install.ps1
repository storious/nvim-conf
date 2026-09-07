# Run with PowerShell 5.1+; PowerShell 7 is required by the Neovim config itself.
[CmdletBinding()]
param(
  [string]$Ref = 'main'
)

& {
  $ErrorActionPreference = 'Stop'
  $appName = if ($env:NVIM_APPNAME) { $env:NVIM_APPNAME } else { 'nvim' }
  if ($appName -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]*$') {
    throw 'NVIM_APPNAME must be a simple directory name (letters, digits, dot, underscore, hyphen).'
  }
  $configRoot = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { $env:LOCALAPPDATA }
  if (-not $configRoot -or -not [IO.Path]::IsPathRooted($configRoot)) {
    throw 'XDG_CONFIG_HOME or LOCALAPPDATA must be an absolute path.'
  }
  $configRoot = [IO.Path]::GetFullPath($configRoot)
  $target = Join-Path $configRoot $appName
  $stage = Join-Path $configRoot ('.nvim-install-' + [Guid]::NewGuid().ToString('N'))
  $backup = $null

  try {
    New-Item -ItemType Directory -Path $stage -Force | Out-Null
    $archive = Join-Path $stage 'config.zip'
    $unpacked = Join-Path $stage 'unpacked'
    $encodedRef = [Uri]::EscapeDataString($Ref)
    Write-Host "Downloading storious/nvim-conf ($Ref)..."
    Invoke-WebRequest -UseBasicParsing -Uri "https://codeload.github.com/storious/nvim-conf/zip/$encodedRef" -OutFile $archive
    Expand-Archive -LiteralPath $archive -DestinationPath $unpacked
    $roots = @(Get-ChildItem -LiteralPath $unpacked -Directory)
    if ($roots.Count -ne 1) { throw 'Unexpected archive layout; existing config was not changed.' }
    $source = $roots[0].FullName
    foreach ($required in @('init.lua', 'lua/core/ui.lua', 'lua/plugins/init.lua', 'nvim-pack-lock.json')) {
      if (-not (Test-Path -LiteralPath (Join-Path $source $required) -PathType Leaf)) {
        throw "Archive is missing $required; existing config was not changed."
      }
    }

    # A same-parent rename preserves the complete old config, including local edits.
    if (Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue) {
      $backup = $target + '.backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [Guid]::NewGuid().ToString('N').Substring(0, 8)
      Move-Item -LiteralPath $target -Destination $backup
      Write-Host "Backup: $backup"
    }
    try {
      Move-Item -LiteralPath $source -Destination $target
    } catch {
      if ($backup -and -not (Test-Path -LiteralPath $target)) {
        Move-Item -LiteralPath $backup -Destination $target
        Write-Host 'Previous config restored.'
      }
      throw
    }
    Write-Host "Installed: $target"
    Write-Host 'Restart Neovim. Existing plugin data is preserved; missing plugins download on first use.'
  } finally {
    # Only remove the unique staging directory created by this invocation.
    if ((Split-Path -Parent $stage).TrimEnd('\', '/') -ne $configRoot.TrimEnd('\', '/') -or
        (Split-Path -Leaf $stage) -notmatch '^\.nvim-install-[0-9a-f]{32}$') {
      throw "Refusing to clean unexpected staging path: $stage"
    }
    if (Test-Path -LiteralPath $stage) {
      Remove-Item -LiteralPath $stage -Recurse -Force
    }
  }
}
