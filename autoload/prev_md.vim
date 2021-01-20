let s:save_cpo = &cpo
set cpo&vim

let s:prev_buf_nr = 0

function! prev_md#preview() abort
  let bufnr = bufnr()
  let tmp = tempname()
  let s:md_winid = bufwinid(bufnr('%'))
  call writefile(getline(1, "$"), tmp)
  let s:prev_buf_nr = term_start("mdr", {
        \ 'vertical': 1,
        \ 'in_io': 'file',
        \ 'in_name': tmp,
        \ 'exit_cb': function('s:remove_tmp', [tmp]),
        \ 'term_finish': 'open',
        \ 'term_opencmd': 'vnew|b %d',
        \ })
  let timer = timer_start(7000, 'MdrExec', {'repeat': 1})
endfunction

function! MdrExec(timer) abort
  call win_gotoid(s:md_winid)
  let tmp = tempname()
  call writefile(getline(1, "$"), tmp)

  let winid = bufwinid(s:prev_buf_nr)
  call win_gotoid(winid)
  "call StopJob()
  let jobid = term_getjob(s:prev_buf_nr)
  call job_stop(jobid)
  echo jobid
  let c = 0
  while job_status(jobid) is# 'run'
    if c > 5
      return
    endif
    sleep 1m
    let c += 1
  endwhile
  let s:prev_buf_nr = term_start("mdr", {
        \ 'hidden': 1,
        \ 'curwin': 1,
        \ 'in_io': 'file',
        \ 'in_name': tmp,
        \ 'exit_cb': function('s:remove_tmp', [tmp]),
        \ 'term_finish': 'close'
        \ })

endfunction

function StopJob() abort
  " current buffer id -> bufnr('%')
  let s:jobid = term_getjob(bufnr('%'))
  call job_stop(s:jobid)
endfunction


function! s:remove_tmp(tmp, channel, msg) abort
  call delete(a:tmp)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
