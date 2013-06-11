"============================================================================
"File:        aoi-jump.vim
"Description: 
"Maintainer:  Junji Watanabe <watanabe0621@gmail.com>
"Version:     0.3.0
"Last Change: 2012/12/08
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
" {{{_backendInit()
function! _backendInit()
  call _setJumpMode()
  let s:method_name = _getMethodName()
  if s:jump_mode != 'this'
    let s:identifier = _getJumpIdentifier()
    let s:jump_path = substitute(_changeCase(s:identifier), '_', '/', 'g')
    let s:backend_base_dir = _getBackendBaseDir()
  endif
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
" {{{ _getJumpIdentifier()
function! _getJumpIdentifier()
  let l:cursor = split(s:cursor_WORD, '->')
  let l:length = len(l:cursor)
  if l:length == 4
    let l:idnt = l:cursor[2]
  elseif l:length == 3
    let l:idnt = l:cursor[1]
  endif
  return l:idnt
endfunction
" }}}
" {{{ _setJumpMode()
function! _setJumpMode()
  let l:cursor = split(s:cursor_WORD, '->')
  let l:length = len(l:cursor)
  if l:length == 4
    let l:jump_mode = l:cursor[1]
  elseif l:length == 3
    let l:jump_mode = 'module'
  elseif l:length == 2
    " $this->_hogehoge(...
    let l:jump_mode = 'this'
  endif
  let s:jump_mode = l:jump_mode

  if s:jump_mode == 'data'
    let l:method = substitute(l:cursor[3], '(.*',  '', '')
    if l:method == 'execute' || l:method == 'find'
      let l:cascade_mode = 'DataFormat'
    else
      let l:cascade_mode = 'Gateway'
    endif
    let s:cascade_jump_mode = l:cascade_mode
  endif
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
  if s:jump_mode == 'data'
    let l:method = substitute(l:cursor[3], '(.*',  '', '')
    if l:method == 'execute' || l:method == 'find'
      " get cursor line and next line
      let l:cursor_line = getline('.') . getline(line('.') + 1)
      let l:str = substitute(l:cursor_line, '.*(\ *', '', '')
      let l:result = split(l:str, "'")
      let l:method_name = l:result[0]
    else
      let l:method = l:cursor[3]
      let l:method_name = substitute(l:method, '(.*',  '', '')
    endif
  elseif s:jump_mode == 'module'
    if l:length == 4
      let l:method = l:cursor[3]
    elseif l:length == 3
      let l:method = l:cursor[2]
    endif
    let l:method_name = substitute(l:method, '(.*',  '', '')
  elseif s:jump_mode == 'this'
    let l:method = l:cursor[1]
    let l:method_name = substitute(l:method, '(.*',  '', '')
  endif
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
    "execute 'vsp'
    "execute 'wincmd c'
    execute 'wincmd w'
    execute 'edit ' . a:path
    "execute 'wincmd x'
    "execute 'wincmd x'
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
    let l:processor_dir = a:backend_base_dir ."/Processor"
    let l:module_dir    = a:backend_base_dir ."/Module"
    let l:command = printf("grep \"%s\" %s/**/*.php %s/**/*.php | cw", a:pattern, l:processor_dir, l:module_dir)
    "echo l:command
    execute l:command
endfunction
" }}}
" {{{ _searchMethodDefinition(method_name)
function! _searchMethodDefinition(method_name)
  if s:jump_mode == 'data'
    let l:searh_str = printf("'%s'\ *=>", a:method_name)
  elseif s:jump_mode == 'module' || s:jump_mode == 'this'
    let l:searh_str = printf('function %s(', a:method_name)
  endif
  call search(l:searh_str)
endfunction
" }}}

" main function
" {{{ AoiGrep()
function! AoiGrep()
  call _init()
  execute "vsp"
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
  call _backendInit()
  if s:jump_mode == 'data'
    let l:file_path = printf('%s/Cascade/%s/%s.php', s:backend_base_dir, s:cascade_jump_mode,s:jump_path)
    call _executeEditFile(l:file_path)
  elseif s:jump_mode == 'module'
    "execute "vsp"
    "execute 'wincmd w'
    let l:file_path = printf('%s/Module/%s.php', s:backend_base_dir, s:jump_path)
    call _executeEditFile(l:file_path)
  endif

  "echo s:method_name
  call _searchMethodDefinition(s:method_name)
  "execute 'foldopen'
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
