let s:save_cpo = &cpo
set cpo&vim

function! prev_md#preview() abort
  let tmp = tempname()
  call writefile(getline(1, "$"), tmp)
  call term_start("mdr", {
        \ 'in_io': 'file',
        \ 'in_name': tmp,
        \ 'exit_cb': function('s:remove_tmp', [tmp]),
        \ 'term_finish': 'close'
        \ })
endfunction

function! s:remove_tmp(tmp, channel, msg) abort
  call delete(a:tmp)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
