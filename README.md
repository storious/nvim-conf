
# Simple Neovim Config
A simple Neovim configuration for personal development.
## Requirements
*   **Neovim** (v0.12.0+)
*   **Git**
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
3.  **Clone Config**:
    ```powershell
    # Backup old config if exists
    if (Test-Path $env:LOCALAPPDATA\nvim) { Rename-Item $env:LOCALAPPDATA\nvim nvim.bak }
    git clone https://github.com/storious/nvim-conf.git $env:LOCALAPPDATA\nvim
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
2.  **Clone Config**:
    ```bash
    # Backup old config if exists
    [ -d ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.bak
    git clone https://github.com/storious/nvim-conf.git ~/.config/nvim
    ```
## Keymaps
### General
| Key | Action |
| :--- | :--- |
| `<leader>w` | Save file |
| `<leader>x` | Close buffer (force close in terminal) |
| `<leader>e` | Open file explorer |
| `<leader>fm` | Format code |
### Buffer & Tab
| Key | Action |
| :--- | :--- |
| `]b` / `[b` | Next / Previous buffer |
| `Tab` / `S-Tab` | Next / Previous tab |
| `<leader>tn` | New tab |
| `<leader>tc` | Close tab |
### Window & Terminal
| Key | Action |
| :--- | :--- |
| `<M-h/j/k/l>` | Navigate windows |
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

