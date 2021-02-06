let s:save_cpo = &cpo
set cpo&vim

function! prev_md#preview() abort
  if !executable('glow')
    echomsg 'not found glow'
    return
  endif
  " write tmp file
  let s:tmp = tempname() . '.md'
  call writefile(getline(1, "$"), s:tmp)

  let s:md_buf_nr = bufnr()
  let s:md_winid = bufwinid(s:md_buf_nr)

  let s:option = {
    \ 'vertical': 1,
    \ 'exit_cb': function('s:remove_tmp', [s:tmp]),
    \ 'term_finish': 'open',
    \ 'term_opencmd': 'vnew|b %d',
    \ 'term_kill': 'kill',
    \ }
  let s:prev_buf_nr = term_start('/bin/sh', s:option)
  call term_sendkeys(s:prev_buf_nr, "export PAGER=\"less -R\" \<CR>")
  let s:winid = bufwinid(s:prev_buf_nr)
  let sendkey = printf("glow %s -p \<CR>", s:tmp)
  call term_sendkeys(s:prev_buf_nr, sendkey)
  call win_gotoid(s:prev_buf_nr)
  if get(g:, 'prev_md_auto_update', 0) == 1
    let timer = timer_start(g:auto_prev_time, 'GlowExec', {'repeat': -1})
  endif
endfunction

function! GlowExec(timer) abort
  " if current cursor != markdown buffer
  if bufnr() != s:md_buf_nr
    return
  endif
  " if glow window not exist || markdown window not exist
  if bufwinnr(s:prev_buf_nr) == -1 || bufwinnr(s:md_buf_nr) == -1
    echomsg 'stop timer'
    call timer_stop(a:timer)
    return
  endif
  " if markdown modified
  if !&modified
    return
  endif

  let tmp_ary_ex = readfile(s:tmp)

  call win_gotoid(s:md_winid)
  let s:tmp = tempname() . '.md'
  call writefile(getline(1, "$"), s:tmp)

  let tmp_ary = readfile(s:tmp)
  if tmp_ary_ex == tmp_ary
    return
  endif

  let current_line = getline('.')
  "let pager = printf("export PAGER=\"less -R+/%s\" \<CR>", current_line)
  let sendkey = printf("glow %s -p \<CR>", s:tmp)

  " exit glow window
  call term_sendkeys(s:prev_buf_nr, 'q')
  call term_sendkeys(s:prev_buf_nr, "\<c-l>")
  call term_wait(s:prev_buf_nr)

  "call term_sendkeys(s:prev_buf_nr, pager)
  call term_sendkeys(s:prev_buf_nr, sendkey)
  call term_wait(s:prev_buf_nr)

endfunction


function! s:remove_tmp(tmp, channel, msg) abort
  call delete(a:tmp)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
