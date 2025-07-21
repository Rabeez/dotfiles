" Have j and k navigate visual lines rather than logical ones
nmap j gj
nmap k gk

" Quickly remove search highlights
nmap <ESC> :nohl<CR>

" Yank to system clipboard
set clipboard=unnamed

unmap <Space>

" Go back and forward with Ctrl+O and Ctrl+I
" (make sure to remove default Obsidian shortcuts for these to work)
exmap back obcommand app:go-back
nmap <C-o> :back<CR>
exmap forward obcommand app:go-forward
nmap <C-i> :forward<CR>
exmap fuzzyfiles obcommand switcher:open
nmap <Space>ff :fuzzyfiles<CR>
exmap fuzzygrep obcommand global-search:open
nmap <Space>fg :fuzzygrep<CR>
exmap explorer obcommand app:toggle-left-sidebar
nmap <Space>ee :explorer<CR>
exmap graph obcommand app:toggle-right-sidebar
nmap <Space>gg :graph<CR>
" Right click menu (useful for spell corrections)
exmap context obcommand editor:context-menu
nmap K :context<CR>
" ToggleList plugin hotkeys
exmap listtogglen obcommand obsidian-toggle-list:Task-Next
map <CR> :listtogglen<CR>
exmap listtogglep obcommand obsidian-toggle-list:Task-Prev
map <C-CR> :listtogglep<CR>

" Replace `x` with black hole register version
nnoremap x "_x

" Center cursor while scrolling or navigatin
nnoremap <C-u> <C-u>zz
nnoremap <C-d> <C-d>zz
nnoremap G Gzz
nnoremap U :redo<CR>

" Paste in next line
nnoremap <C-p> o<Esc>p

" Navigate across 'virtual lines' rather than real ones
" This is needed since most 'paragraphs' are actually just single long line
" with soft wrapping
nnoremap <Up> k
nnoremap <Down> j

" Surround Text
exmap surround_wiki surround [[ ]]
exmap surround_double_quotes surround " "
exmap surround_single_quotes surround ' '
exmap surround_backticks surround ` `
exmap surround_brackets surround ( )
exmap surround_square_brackets surround [ ]
exmap surround_curly_brackets surround { }

" NOTE: must use 'map' and not 'nmap'
map [[ :surround_wiki<CR>
nunmap s
vunmap s
map s" :surround_double_quotes<CR>
map s' :surround_single_quotes<CR>
map s` :surround_backticks<CR>
map sb :surround_brackets<CR>
map s( :surround_brackets<CR>
map s) :surround_brackets<CR>
map s[ :surround_square_brackets<CR>
map s] :surround_square_brackets<CR>
map s{ :surround_curly_brackets<CR>
map s} :surround_curly_brackets<CR>
