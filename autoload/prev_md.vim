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
