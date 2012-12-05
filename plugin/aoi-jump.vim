"============================================================================
"File:        aoi-jump.vim
"Description: 
"Maintainer:  Junji Watanabe <watanabe0621@gmail.com>
"Version:     0.0.2
"Last Change: 2012/12/05
"License:
"
"============================================================================

function! SmartyJump()
  let current_path = expand("%:p")
  let tpl_path = '/tpl/' . expand("<cfile>")
  let include_file_path = substitute(current_path, '/*/\<tpl/.*', tpl_path, '') 
  if filereadable(include_file_path)
    execute 'edit ' . include_file_path
  else
    echohl ErrorMsg
    echo 'no such file ' . include_file_path
    echohl None
  endif
endfunction

function! AoiModuleJump()
  let current_path = expand("%:p")
  let backend_dir = substitute(current_path, '/*/\<Processor/.*', '', '')
  let module_name = expand("<cfile>")
  let module_path = 'Module/' . substitute(module_name, '_', '/', '') . '.php'
  let include_file_path = backend_dir . '/' . module_path
  if filereadable(include_file_path)
    execute 'edit ' . include_file_path
  else
    echohl ErrorMsg
    echo 'no such file ' . include_file_path
    echohl None
  endif
endfunction

function! AoiProcessorJump()
  let current_path = expand("%:p")
  let base_dir = substitute(current_path, '/*/\<frontend/.*', '', '')
  let action_path = substitute(current_path, '.*\<act\>', '', '')
  let include_file_path = base_dir . '/Service/*/Processor' . action_path
  execute 'edit ' . include_file_path
  "if filereadable(include_file_path)
  "  execute 'edit ' . include_file_path
  "else
  "  echohl ErrorMsg
  "  echo 'no such file ' . include_file_path
  "  echohl None
  "endif
endfunction

function! AoiClientJump()
  let current_path = expand("%:p")
  let base_dir = substitute(current_path, '/*/\<Service/.*', '', '')
  let processor_path = substitute(current_path, '.*\<Processor\>', '', '')
  let include_file_path = base_dir . '/frontend/*/act' . processor_path
  execute 'edit ' . include_file_path
  "if filereadable(include_file_path)
  "  execute 'edit ' . include_file_path
  "else
  "  echohl ErrorMsg
  "  echo 'no such file ' . include_file_path
  "  echohl None
  "endif
endfunction

"nnoremap <silent> <space>b :e#<CR>
"nnoremap <silent> <space>m :call AoiModuleJump()<CR>
"nnoremap <silent> <space>p :call AoiProcessorJump()<CR>
"nnoremap <silent> <space>f :call AoiClientJump()<CR>
"nnoremap <silent> <space>i :call SmartyJump()<CR>
