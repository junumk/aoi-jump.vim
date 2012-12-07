## About

aoi-jump.vim is a vim plugin for jump to Aoi Processor, Aoi Module, smarty include file ..

## How to Use

Simply, you can use this plugin with the following shortcuts.

     ```
      " back
      nnoremap <silent> <space>b  :e#<CR>
      " aoi grep
      nnoremap <silent> <space>ag :call AoiGrep()<CR>
      " jump to aoi module
      nnoremap <silent> <space>am :call AoiModuleJump()<CR>
      " jump to aoi processor
      nnoremap <silent> <space>ap :call AoiProcessorJump()<CR>
      " jump to aoi client
      nnoremap <silent> <space>ac :call AoiClientJump()<CR>
      " jump to smarty include file
      nnoremap <silent> <space>i  :call SmartyJump()<CR>
     ```

If you managed vim-plugin with bundle, add the following setting to your vimrc.

     ```
     Bundle 'watanabe0621/aoi-jump.vim'
     ```
