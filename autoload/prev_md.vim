let s:save_cpo = &cpo
set cpo&vim

function! prev_md#preview() abort
  if !executable('mdr')
    echomsg 'not found mdr'
    return
  endif
  " write tmp file
  let tmp = tempname()
  let s:md_winid = bufwinid(bufnr())
  call writefile(getline(1, "$"), tmp)
  let s:option = {
    \ 'vertical': 1,
    \ 'in_io': 'file',
    \ 'in_name': tmp,
    \ 'exit_cb': function('s:remove_tmp', [tmp]),
    \ 'term_finish': 'open',
    \ 'term_opencmd': 'vnew|b %d',
    \ 'term_kill': 'kill',
    \ }
  let s:prev_buf_nr = term_start("mdr", s:option)
  let timer = timer_start(g:auto_prev_time, 'MdrExec', {'repeat': -1})
endfunction

function! MdrExec(timer) abort
  let s:current_winid = bufwinid(bufnr())
  " if current cursor == mdr preview
  if bufnr() == s:prev_buf_nr
    return
  endif
  " if mdr preview not exist
  if !bufexists(s:prev_buf_nr)
    call timer_stopall()
    return
  endif
  " if md modified
  if !&modified
    return
  endif

  call win_gotoid(s:md_winid)
  let tmp = tempname()
  call writefile(getline(1, "$"), tmp)

  let winid = bufwinid(s:prev_buf_nr)
  call win_gotoid(winid)
  " job stop
  let jobid = term_getjob(s:prev_buf_nr)
  call job_stop(jobid)
  let c = 0
  while job_status(jobid) is# 'run'
    if c > 5
      return
    endif
    sleep 1m
    let c += 1
  endwhile
  let s:option = {
    \ 'curwin': 1,
    \ 'in_io': 'file',
    \ 'in_name': tmp,
    \ 'exit_cb': function('s:remove_tmp', [tmp]),
    \ 'term_finish': 'open',
    \ 'term_opencmd': 'vnew|b %d',
    \ 'term_kill': 'kill',
    \ }
  let s:prev_buf_nr = term_start("mdr", s:option)

  " move before window
  call win_gotoid(s:current_winid)
endfunction


function! s:remove_tmp(tmp, channel, msg) abort
  call delete(a:tmp)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
