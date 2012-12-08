"============================================================================
"File:        aoi-jump.vim
"Description: 
"Maintainer:  Junji Watanabe <watanabe0621@gmail.com>
"Version:     0.2.0
"Last Change: 2012/12/07
"License:
"
"============================================================================

" conf
" smarty template directory name
let s:template_dir_name = 'tpl'
let s:aciton_dir_name   = 'act'

" private function
" {{{ _init()
function! _init()
  let s:current_path = expand("%:p")
  let s:cursor_file  = expand("<cfile>")
  let s:cursor_word  = expand("<cword>")
  let s:cursor_WORD  = expand("<cWORD>")

  let s:base_dir = substitute(s:current_path, '/*/\<Service/.*',  '', '')
  let s:base_dir = substitute(s:base_dir,     '/*/\<frontend/.*', '', '')
endfunction
" }}}
" {{{ _getBackendBaseDir()
function! _getBackendBaseDir()
  let l:backend_base_dir = substitute(s:current_path,     '/*/\<Processor/.*', '', '')
  let l:backend_base_dir = substitute(l:backend_base_dir, '/*/\<Module/.*',    '', '')
  let l:backend_base_dir = substitute(l:backend_base_dir, '/*/\<Cascade/.*',   '', '')
  return l:backend_base_dir
endfunction
" }}}
" {{{ _getFrontendBaseDir()
function! _getFrontendBaseDir()
  let l:frontend_base_dir = substitute(s:current_path, '/*/\<tpl/.*',   '', '')
  return l:frontend_base_dir 
endfunction
" }}}
" {{{ _getModuleIdentifier()
function! _getModuleIdentifier()
  let l:cursor = split(s:cursor_WORD, '->')
  let l:length = len(l:cursor)
  if l:length == 4
    let l:mpdule_idnt = l:cursor[2]
  elseif l:length == 3
    let l:mpdule_idnt = l:cursor[1]
  endif
  return l:mpdule_idnt
endfunction
" }}}
" {{{ _genarateModuleIdentifier()
function! _genarateModuleIdentifier()
  let l:module_path = substitute(s:current_path, '/.*/\<Module/',  '', '')
  let l:module_path = substitute(l:module_path,  '.php',  '', '')
  let l:module_path = substitute(l:module_path,  '/',  '_', 'g')
  let l:module_path = tolower(l:module_path)
  return l:module_path
endfunction
" }}}
" {{{ _getMethodName()
function! _getMethodName()
  let l:cursor = split(s:cursor_WORD, '->')
  let l:length = len(l:cursor)
  if l:length == 4
    let l:method = l:cursor[3]
  elseif l:length == 3
    let l:method = l:cursor[2]
  endif
  let l:method_name = substitute(l:method, '(.*',  '', '')
  return l:method_name
endfunction
" }}}
" {{{ _changeCase(str)
function! _changeCase(str)
  let l:str = substitute(a:str, "_", "/_/", 'g')
  let l:str = substitute(l:str, "\\w\\+", "\\u\\0", 'g')
  let l:str = substitute(l:str, "/_/", "_", 'g')
  return l:str
endfunction
" }}}
"" 実行系
" {{{ _executeEditFile(path)
function! _executeEditFile(path)
  if filereadable(a:path)
    execute 'edit ' . a:path
  else
    echohl ErrorMsg
    echo 'no such file ' . a:path
    echohl None
    return false
  endif
endfunction
" }}}
" {{{ _executeGrep(pattern, backend_base_dir)
function! _executeGrep(pattern, backend_base_dir)
    let l:command = printf("grep -r \"%s\" %s | cw", a:pattern, a:backend_base_dir)
    echo l:command
    execute l:command
endfunction
" }}}
" {{{ _searchMethodDefinition(method_name)
function! _searchMethodDefinition(method_name)
  let l:searh_str = printf('function %s(', a:method_name)
  call search(l:searh_str)
endfunction
" }}}

" main function
" {{{ AoiGrep()
function! AoiGrep()
  call _init()
  let l:method_name = s:cursor_word
  let l:module_identifier = _genarateModuleIdentifier()
  let l:pattern = printf('>%s->%s(', l:module_identifier, l:method_name)
  let l:backend_base_dir = _getBackendBaseDir()

  call _executeGrep(l:pattern, l:backend_base_dir)
endfunction
" }}}
" {{{ AoiModuleJump()
function! AoiModuleJump()
  call _init()
  let l:method_name = _getMethodName()
  let l:module_identifier = _getModuleIdentifier()
  let l:module_path = substitute(_changeCase(l:module_identifier), '_', '/', 'g')
  let l:backend_base_dir = _getBackendBaseDir()
  let l:file_path = printf('%s/Module/%s.php', l:backend_base_dir, l:module_path)

  call _executeEditFile(l:file_path)
  call _searchMethodDefinition(l:method_name)
endfunction
" }}}
" {{{ AoiProcessorJump()
function! AoiProcessorJump()
  call _init()
  let l:action_path = substitute(s:current_path, '\<act_cli\>', 'act/Cli', '')
  let l:action_path = substitute(l:action_path, '.*\<act\>', '', '')
  let l:file_path = printf('%s/Service/*/Processor/%s', s:base_dir, l:action_path)
  execute 'edit ' . l:file_path
endfunction
" }}}
" {{{ AoiClientJump()
function! AoiClientJump()
  call _init()
  let l:processor_path = substitute(s:current_path, '.*\<Processor\>', '', '')
  let l:file_path = printf('%s/frontend/*/%s/%s', s:base_dir, s:aciton_dir_name, l:processor_path)
  let l:file_path = substitute(l:file_path, '\<act\/\/Cli\>', 'act_cli', '')
  execute 'edit ' . l:file_path
endfunction
" }}}
" {{{ SmartyJump()
function! SmartyJump()
  call _init()
  let l:frontend_base_dir = _getFrontendBaseDir()
  let l:file_path = printf('%s/%s/%s', l:frontend_base_dir, s:template_dir_name, s:cursor_file)
  call _executeEditFile(l:file_path)
endfunction
" }}}

"set grepprg=grep\ -nH

"nnoremap <silent> <space>b :e#<CR>
"nnoremap <silent> <space>ag :call AoiGrep()<CR>
"nnoremap <silent> <space>am :call AoiModuleJump()<CR>
"nnoremap <silent> <space>ap :call AoiProcessorJump()<CR>
"nnoremap <silent> <space>ac :call AoiClientJump()<CR>
"nnoremap <silent> <space>i :call SmartyJump()<CR>
