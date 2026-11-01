" Move by display (wrapped) line instead of logical line
nmap j gj
nmap k gk
nmap 0 g0
nmap $ g$

" Use the system clipboard for yank/delete/paste instead of vim's
" internal register — the single most common vimrc-support fix
" people add first (source: community example configs).
set clipboard=unnamed

" Jump to the position of your last edit. Obsidian's vim engine
" (codemirror-vim) doesn't implement vim's full multi-entry change
" list, so g; only recalls the single most recent edit rather than
" cycling further back like it would in real vim — it's aliased to
" the `. mark, which is what the engine actually tracks.
nmap g; `.

" Vim-style jump list through Obsidian's note navigation history.
exmap back obcommand app:go-back
exmap forward obcommand app:go-forward
nmap <C-o> :back<CR>
nmap <C-i> :forward<CR>

" Leader-key shortcuts.
let mapleader=","
exmap todaynote obcommand daily-notes
nmap <leader>d :todaynote<CR>

" TODO: couldn't confirm the exact command ID for "Templates: Insert
" template" from docs. Find it via Settings > Hotkeys (search "insert
" template") or the dev console (Cmd-Opt-I -> app.commands.listCommands()),
" then uncomment:
" exmap inserttemplate obcommand templates:insert-template
" nmap <leader>t :inserttemplate<CR>
