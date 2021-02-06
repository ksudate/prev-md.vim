# prev-md.vim

Vim plugin for realtime markdown preview

![screenshot](https://user-images.githubusercontent.com/33239455/107126540-e1d36000-68f3-11eb-8463-7e0c5e061c8f.gif)

## Installation

To install using [Vim-Plug](https://github.com/junegunn/vim-plug):

```
" add this line to your .vimrc
Plug 'tmrekk121/prev-md.vim'
```

## Requirements

- [charmbracelet/glow](https://github.com/charmbracelet/glow)

## Usage

```
:Prevmd
```

## Settiongs

```
let g:auto_prev_time=5000   " set preview refresh interval (default 5000)
let g:prev_md_auto_update=1 "enable auto preview (default 1)
```
