# Offworld

Personal Neovim configuration that I use on debian (stable) systems.

What's included here? Custom colorschemes, statusline, tabline, lsp client config, session helper, terminal toggle and a simple completion setup.

## Requirements

* Neovim v0.7 or greater.
* git.
* (Optional) [lua-language-server](https://github.com/LuaLS/lua-language-server)

## Installation

* Download the code into Neovim's configuration folder

```sh
git clone https://github.com/VonHeikemen/offworld-nvim ~/.config/nvim
```

* Generate the help tags

```vim
:helptags ALL
```

## Custom keybindings

Leader key: `Space`.

| Mode | Key | Action |
| --- | --- | --- |
| Normal | `gy` | Copy text to clipboard. |
| Normal | `gp` | Paste text from clipboard. |
| Normal | `x` | Delete one character without modifying internal registers. |
| Normal | `X` | Delete text without modifying internal registers. |
| Normal | `U` | Redo changes which were undone. |
| Normal | `K` | Displays hover information about the symbol under the cursor. |
| Normal | `gd` | Jump to the definition. |
| Normal | `gD` | Jump to declaration. |
| Normal | `gi` | Lists all the implementations for the symbol under the cursor. |
| Normal | `go` | Jumps to the definition of the type symbol |
| Normal | `gr` | Lists all the references. |
| Normal | `gs` | Displays a function's signature information. |
| Normal | `<F2>` | Renames all references to the symbol under the cursor. |
| Normal | `<F3>` | Format code in current buffer. |
| Normal | `<F4>` | Selects a code action available at the current cursor position. |
| Normal | `gl` | Show diagnostics in a floating window. |
| Normal | `[d` | Move to the previous diagnostic. |
| Normal | `]d` | Move to the next diagnostic. |
| Normal | `<leader>h` | Go to first non empty character in line. |
| Normal | `<leader>l` | Go to last non empty character in line. |
| Normal | `<leader>a` | Select all text. |
| Normal | `<leader>w` | Save file. |
| Normal | `<leader>qq` | Quit Neovim safely. |
| Normal | `<leader>Q` | Quit Neovim (discard unsaved changes). |
| Normal | `<leader>bc` | Close current buffer. |
| Normal | `<leader>bq` | Close current buffer and quit if it's the last. |
| Normal | `<leader>bl` | Go to last active buffer. |
| Normal | `<leader><space>` | Search open buffers. |
| Normal | `<Ctrl-k>` | Move current line up. |
| Normal | `<Ctrl-j>` | Move current line down. |
| Normal | `<leader>sj` | Begin word search and replace. |
| Normal | `<leader>sq` | Word search and replace but using a macro. |
| Normal | `<leader>sQ` | Apply macro in register `i`. |
| Normal | `<F8>` | Apply macro in the next match of the current search. |
| Normal | `Q` | Repeat recently used macro. |
| Normal | `<leader>e` | Toggle file explorer. |
| Normal | `<leader>E` | Open file explorer in current folder. |
| Normal | `<F5>` | Toggle embedded terminal. |
| Normal | `<leader>m` | Include current buffer in menu. |
| Normal | `<leader>M` | Include current buffer in menu and show the menu. |
| Insert | `<C-d>` | Expand abbreviations. This is the hack I use for snippets. |
| Normal | `M` | Show buffer menu. |
| Normal | `<Alt-1>` | Navigate to the file in the first line of the buffer menu. |
| Normal | `<Alt-2>` | Navigate to the file in the second line of the buffer menu. |
| Normal | `<Alt-3>` | Navigate to the file in the third line of the buffer menu. |
| Normal | `<Alt-4>` | Navigate to the file in the fourth line of the buffer menu. |
| Normal | `gc` | Toggle comment in current line. |
| Visual | `gc` | Toggle comment in current selection. |

### Autocomplete keybindings

| Mode | Key | Action |
| --- | --- | --- |
| Insert | `<Ctrl-y>` | Confirm completion item. |
| Insert | `<Enter>` | Confirm completion item. |
| Insert | `<Ctrl-e>` | Toggle completion menu. |
| Insert | `<Ctrl-p>` | Move to previous item. |
| Insert | `<Ctrl-n>` | Move to next item. |
| Insert | `<Tab>` | Show completion menu if cursor is in the middle of a word. Go to next completion item if completion menu is visible. Otherwise, insert tab character. |
| Insert | `<Shift-Tab>` | If completion menu is visible, go to previous completion item. Otherwise, insert tab character. |

## How to install third-party plugins?

Turns out we only need to download them in a specific folder and Neovim will take care of the rest. So, inside this configuration there is a command called `GitPlugin`, this can help you download plugins from github. All you need to know is the name of the author and the name of the repository.

Let's say you want to download a nice colorscheme like [tokyonight](https://github.com/folke/tokyonight.nvim), you can execute this command.

```vim
:GitPlugin install folke/tokyonight.nvim
```

The command `GitPlugin` can also be used to update or remove plugins. See help page `:help git-plugin.txt` to know more about it.

Note `GitPlugin` is not meant to be a fully-featured plugin manager. But you can use it to download one, say [paq-nvim](https://github.com/savq/paq-nvim).

```vim
:GitPlugin install savq/paq-nvim package=paqs
```

