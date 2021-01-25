if exists('g:loaded_prev_md')
  finish
endif
let g:loaded_prev_md = 1

let s:save_cpo = &cpo
set cpo&vim

" default setting
if !exists('g:mkdp_auto_start')
    let g:auto_prev_time = 5000
endif

command! PrevMd call prev_md#preview()

let &cpo = s:save_cpo
unlet s:save_cpo
