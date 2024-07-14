" Learn about vim abbreviations feature here:
" https://vonheikemen.github.io/devlog/tools/using-vim-abbreviations/

" Ctrl+d will expand abbreviations
inoremap <C-d> @<C-]>

function! s:lang_lua() abort
  iabbrev <buffer> ff@ function()<CR>end<Esc>O
  iabbrev <buffer> fun@ function Z()<CR>end<Esc>O<Esc><Up>fZa<BS>
  iabbrev <buffer> if@ if Z then<CR>end<Esc>O<Esc><Up>fZa<BS>
  iabbrev <buffer> elif@ elseif Z then<Esc>FZa<BS>
  iabbrev <buffer> foreach@ for i, x in pairs(Z) do<CR>end<Esc>O<Esc><Up>fZa<BS>
endfunction

function! s:lang_markdown() abort
  iabbrev <buffer> `@ ```<CR>```<Up><End><CR>
  iabbrev <buffer> js@ ```<CR>```<Up><End>js<CR>
  iabbrev <buffer> sh@ ```<CR>```<Up><End>sh<CR>
  iabbrev <buffer> html@ ```<CR>```<Up><End>html<CR>
  iabbrev <buffer> css@ ```<CR>```<Up><End>css<CR>
endfunction

function! s:web() abort
  iabbrev <buffer> con@ console.log();<Left><Left>
  iabbrev <buffer> im@ import {} from '';<Left><Left>
  iabbrev <buffer> if@ if() {<CR>}<Esc>%<Left><Left>i
  iabbrev <buffer> el@ else {<CR>}<Up><End>
  iabbrev <buffer> eli@ else {<CR>}<Esc>%iif() <Left><Left>
  iabbrev <buffer> sw@ switch(z) {<CR>}<Up><End><CR>case :<CR><BS>break;<CR><CR>default:<CR><BS>break;<Esc>j%Fzxi
  iabbrev <buffer> ff@ function() {<CR>}<Esc>%F(i
  iabbrev <buffer> afun@ async function() {<CR>}<Esc>%F(i
  iabbrev <buffer> forii@ for(let i = 0; i <z; i++) {<CR><CR>}<Esc><Up><Up>fzxi
  iabbrev <buffer> forof@ for(let value ofz) {<CR><CR>}<Esc><Up><Up>fzxi
  iabbrev <buffer> iife@ (async function() {z})()<Esc>%Fzxi<CR><CR><Up>
endfunction

autocmd FileType lua call s:lang_lua()
autocmd FileType markdown,md call s:lang_markdown()
autocmd FileType html,javascript,typescript,vue call s:web()

