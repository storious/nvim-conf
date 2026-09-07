
# Simple Neovim Config
A simple Neovim configuration for personal development.
## Requirements
*   **Neovim** (v0.12.0+)
*   **Git** (used by Neovim to install/update plugins; no manual clone needed)
*   **fzf**
*   **PowerShell 7+** (Only for Windows users).
## Quickstart
### Windows
1.  **Install Neovim** (via winget):
    ```powershell
    winget install Neovim.Neovim
    ```
    or via scoop
    ```powershell
    scoop install neovim
    ```
2.  **Install PowerShell** (if not installed):
    ```powershell
    winget install Microsoft.PowerShell
    ```
3.  **Install or replace the config** (close Neovim first):
    ```powershell
    & ([scriptblock]::Create((Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/storious/nvim-conf/main/install.ps1').Content))
    ```
### macOS / Linux
1.  **Install Neovim**:
    *   **macOS**: `brew install neovim`
    *   **Ubuntu/Debian**:
        ```bash
        sudo add-apt-repository ppa:neovim-ppa/unstable
        sudo apt update
        sudo apt install neovim
        ```
2.  **Install or replace the config** (requires `curl` and `tar`; close Neovim first):
    ```bash
    (set -e; installer=$(mktemp); trap 'rm -f "$installer"' EXIT; curl -fsSL https://raw.githubusercontent.com/storious/nvim-conf/main/install.sh -o "$installer"; sh "$installer")
    ```

Run the same command again to update. The installer downloads a GitHub archive, validates the required files, and backs up the **entire previous config** beside it as `nvim.backup-<timestamp>-<unique suffix>` before replacing it. A failed download leaves the old config untouched; a failed replacement attempts to restore the backup. Local customizations remain in the backup and are not merged automatically. Plugin data, parsers and caches are preserved. The installer does not install Neovim, Git, fzf, PowerShell or language servers.

Default destinations are `%LOCALAPPDATA%\nvim` on Windows and `~/.config/nvim` on Linux/macOS. Both installers honor `XDG_CONFIG_HOME` and `NVIM_APPNAME` (a simple directory name). No administrator privileges or `sudo` are needed for the default locations.

You can also download and inspect the script before running it, or choose a branch, tag or commit:

```powershell
Invoke-WebRequest -UseBasicParsing https://raw.githubusercontent.com/storious/nvim-conf/main/install.ps1 -OutFile install.ps1
.\install.ps1 -Ref main
```

```sh
curl -fsSL https://raw.githubusercontent.com/storious/nvim-conf/main/install.sh -o install.sh
sh install.sh main
```

To roll back, close Neovim, move the new config aside, then rename the printed backup path to the original config name. These remote commands become available after the installer files are published to this repository's `main` branch.
## Plugin Management
Plugins are loaded on first use or shortly after the first screen is drawn. Run `:PackUpdate` to update the configured plugins. Tree-sitter uses installed parsers directly and installs a missing parser only when that language is opened.
## Appearance
The built-in `unokai` theme is complemented by a quiet gutter, subtle cursor line, matching floating windows and rounded terminal borders. The native statusline shows mode, project/file, Git changes (when at least 90 columns wide), and cursor position; tabs show a `+` for unsaved changes. Diagnostic signs use readable `E/W/I/H` labels without requiring a special font. UI highlights are reapplied after changing colorschemes.

All decorations reuse Neovim and existing plugins. No UI plugins, animation timers, Git subprocesses, or diagnostic scans are added to startup or statusline redraws. Paths and tab labels remain cached until relevant editor events.

On Windows, file-tree filesystem watchers are disabled to avoid event storms after deleting expanded directories. The tree refreshes after its file operations, on writes, and when entering the tree. Use `R` inside the tree to refresh external changes while staying in it.
## LSP
`lua-language-server` and `clangd` start only when their executables are available. Missing servers are skipped silently, and format-on-save runs only when the current buffer has an attached formatter.
## Large Files
Files at least 2 MiB or 50,000 lines automatically use a lightweight mode. Tree-sitter, LSP, Gitsigns, indentation guides, pair insertion, and trailing-space highlighting are skipped without changing window-local display settings.
## Keymaps
### General
| Key | Action |
| :--- | :--- |
| `<leader>w` | Save file |
| `<leader>x` | Close buffer (force close in terminal) |
| `<leader>e` | Toggle file explorer |
| `<leader>fm` | Format code |
| `<leader>r` | Check for external file changes |
| `<` / `>` (visual mode) | Adjust indentation and keep selection |
| `<leader>uw` | Toggle wrapping in the current window (preserves indentation) |
| `<leader>ul` | Toggle tab, trailing-space and nonbreaking-space markers in the current window |
| `<leader>uh` | Toggle LSP inlay hints in the current buffer |

New splits open to the right or below. Horizontal scrolling keeps five columns of context. Completion menus and documentation use the same rounded borders and palette as other floating windows, without changing when completion loads.
### Buffer & Tab
| Key | Action |
| :--- | :--- |
| `]b` / `[b` | Next / Previous buffer |
| `<leader>tn` / `<leader>tp` | Next / Previous tab |
| `<leader>tb` | New tab |
| `<leader>tc` | Close tab |
### Window & Terminal
| Key | Action |
| :--- | :--- |
| `<C-h/j/k/l>` | Navigate windows |
| `<M-j/k>` | Move line or selection |
| `<leader>tt` | Open terminal in new tab |
| `<leader>tv` | Open terminal in vertical split |
| `<M-i>`      | Toggle float terminal |
| `<Esc><Esc>` | Exit terminal mode |
### LSP & Diagnostic
| Key | Action |
| :--- | :--- |
| `gd` | Go to definition |
| `gr` | Find references |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>dd` | Show diagnostics |
| `]d` / `[d` | Next / Previous diagnostic |
### Clipboard
| Key | Action |
| :--- | :--- |
| `<C-c>` | Copy to system clipboard |
| `<C-x>` | Cut to system clipboard |
| `<C-p>` | Paste from system clipboard |

