"=============================================================================
"    Copyright: Copyright (C) 2001 Bindu Wavell & Jeff Lanzarotta
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               minibufexplorer.vim is provided *as is* and comes with no
"               warranty of any kind, either expressed or implied. In no
"               event will the copyright holder be liable for any damamges
"               resulting from the use of this software.
"
" Name Of File: minibufexpl.vim
"  Description: Mini Buffer Explorer Vim Plugin
"   Maintainer: Bindu Wavell <binduwavell@yahoo.com
"          URL: http://www.wavell.net/vim/plugin/minibufexpl.vim
"  Last Change: Tuesday, December 4, 2001
"      Version: 6.0.2
"               Derived from Jeff Lanzarotta's bufexplorer.vim version 6.0.7
"               Jeff can be reached at (jefflanzarotta@yahoo.com) and the
"               original plugin can be found at:
"               http://lanzarotta.tripod.com/vim/plugin/6/bufexplorer.vim.zip
"
"        Usage: Normally, this file should reside in the plugins
"               directory and be automatically sourced. If not, you must
"               manually source this file using ':source minibufexplorer.vim'.
"
"               You may use the default keymappings of
"
"                 <Leader>mbe - Opens MiniBufExplorer
"
"               or you may want to add something like the following
"               two key mappings to your _vimrc/.vimrc file.
"
"                 map <Leader>b :MiniBufExplorer<cr>
"
"               However, in most cases you won't need any key-bindings at all.
"
"               To control where the new split window goes relative to
"               the current window, use the variable:"
"
"                 let g:miniBufExplSplitBelow=0  " Put new window above
"                                                " current.
"                 let g:miniBufExplSplitBelow=1  " Put new window below
"                                                " current.
"
"               The default for this is read from the &splitbellow vim option.
"
"               By default we are now (as of 6.0.1) turning on the MoreThanOne
"               option. This stops the [MiniBufExplorer] from opening 
"               automatically until more than one eligible buffer is available.
"               You can turn this feature off by setting the following variable:
"                 
"                 let g:miniBufExplorerMoreThanOne=0
"
"               By default we are now (as of 6.0.2) forcing the [MiniBufExplorer]
"               window to open up at the edge of the screen. You can turn this 
"               off by setting the following variable:
"
"                 let g:miniBufExplSplitToEdge=0
"
"      History: 6.0.2 2 Changes requested by Suresh Govindachar
"                     Added SplitToEdge option and set it on by default
"                     Added tab and shift-tab mappings in [MBE] window
"               6.0.1 Added MoreThanOne option and set it on by default
"                     MiniBufExplorer will not automatically open until
"                     more than one eligible buffers are opened. This
"                     reduces cluter when you are only working on a
"                     single file.
"               6.0.0 Initial Release on November 20, 2001
"=============================================================================

"
" Has this plugin already been loaded?
"
if exists('loaded_minibufexplorer')
  call <SID>DEBUG('MiniBufExplorer already loaded!', 5)
  finish
endif
let loaded_minibufexplorer = 1

" 
" Setup mbe map
" 
if !hasmapto('<Plug>MiniBufExplorer')
  map <unique> <Leader>mbe <Plug>MiniBufExplorer
endif

" 
" Setup <script> map
" 
map <unique> <script> <Plug>MiniBufExplorer :call <SID>StartExplorer()<CR>

" 
" Create command.
" 
if !exists(':MiniBufExplorer')
  command! MiniBufExplorer :call <SID>StartExplorer()
endif

"
" Debug Level
"
if !exists('g:miniBufExplorerDebugLevel')
  let g:miniBufExplorerDebugLevel = 0 
endif

"
" Allow auto update?
"
" We startout with this off for startup, but once vim is running we 
" turn this on.
if !exists('g:miniBufExplorerAutoUpdate')
  let g:miniBufExplorerAutoUpdate = 0
endif

"
" Display Mini Buf Explorer when there are 'More Than One' eligible buffers
"
if !exists('g:miniBufExplorerMoreThanOne')
  let g:miniBufExplorerMoreThanOne = 1
endif

"
" When opening a new [MiniBufExplorer] window, split the new windows below or 
" above the current window?  1 = below, 0 = above.
"
if !exists('g:miniBufExplSplitBelow')
  let g:miniBufExplSplitBelow = &splitbelow
endif

"
" When opening a new [MiniBufExplorer] window, split the new windows to the
" full edge? 1 = yes, 0 = no.
"
if !exists('g:miniBufExplSplitToEdge')
  let g:miniBufExplSplitToEdge = 1
endif

"
" Setup an autocommand group and some autocommands that keep our explorer
" updated automatically.
"
augroup MiniBufExplorer
autocmd MiniBufExplorer BufReadPost * call <SID>AutoUpdate()
autocmd MiniBufExplorer BufNewFile * call <SID>AutoUpdate()
autocmd MiniBufExplorer BufNew * call <SID>AutoUpdate()
autocmd MiniBufExplorer VimEnter * let g:miniBufExplorerAutoUpdate = 1 |call <SID>AutoUpdate()

" 
" StartExplorer
" 
" Sets up our explorer and causes it to be displayed
"
function! <SID>StartExplorer()
  call <SID>DEBUG('Entering StartExplorer()',10)

  call <SID>FindCreateExplorer()

  " Make sure we are in our window
  if bufname('%') != '[MiniBufExplorer]'
    call <SID>DEBUG('DisplayBuffers called in invalid window',1)
    return
  endif

  " Prevent a report of our actions from showing up.
  let l:save_rep = &report
  let l:save_sc  = &showcmd
  let &report    = 10000
  set noshowcmd 

  " !!! We may want to make the following optional -- Bindu
  " New windows don't cause all windows to be resized to equal sizes
  set noequalalways
  " !!! We may want to make the following optional -- Bindu
  " We don't want the mouse to change focus without a click
  set nomousefocus
 
  if has("syntax")
    syn match bufExploreNormal   '\[[^\]]*\]'
    syn match bufExploreChanged  '\[[^\]]*\]+'
    syn match bufExploreCurrent  '\[[^\]]*\]\*+\='
    
    if !exists("g:did_minibufexplorer_syntax_inits")
      let g:did_minibufexplorer_syntax_inits = 1
      hi def link bufExploreCurrent Special
      hi def link bufExploreChanged String
      hi def link bufExploreNormal  Comment
    endif
  endif

  " If you press return in the [MiniBufExplorer] then try
  " to open the selected buffer in the previous window.
  nnoremap <buffer> <cr> :call <SID>SelectBuffer()<cr>
  " If you DoubleClick in the [MiniBufExplorer] then try
  " to open the selected buffer in the previous window.
  nnoremap <buffer> <2-leftmouse> :call <SID>DoubleClick()<cr>
  " If you press d in the [MiniBufExplorer] then try to
  " delete the selected buffer.
  nnoremap <buffer> d :call <SID>DeleteBuffer()<cr>
  " The following allow us to use regular movement keys to 
  " scroll in a wrapped single line buffer
  nnoremap <buffer> j gj
  nnoremap <buffer> k gk
  nnoremap <buffer> <down> gj
  nnoremap <buffer> <up> gk
  " The following allows for quicker moving between buffer
  " names in the [MBE] window
  nnoremap <buffer> <TAB> W
  nnoremap <buffer> <S-TAB> B
 
  call <SID>DisplayBuffers()

  let &report  = l:save_rep
  let &showcmd = l:save_sc

endfunction

" 
" FindCreateExplorer
" 
" Attempts to find a window with a mini buffer explorer. If it is found then 
" moves there. Otherwise creates a new window and configures it.
"
function! <SID>FindCreateExplorer()
  call <SID>DEBUG('Entering FindCreateExplorer()',10)

  " Save the user's split setting.
  let l:saveSplitBelow = &splitbelow

  " Set to our new values.
  let &splitbelow = g:miniBufExplSplitBelow

  " Try to find an existing window that contains 
  " [MiniBufExplorer]. If found goto the existing 
  " window, otherwise split open a new window.
  let l:bufNum = bufnr('MiniBufExplorer')
  if l:bufNum != -1
    call <SID>DEBUG('[MiniBufExplorer] found in buffer: '.l:bufNum,9)
    let l:winNum = bufwinnr(l:bufNum)
  else
    let l:winNum = -1
  endif
  if l:winNum != -1
    call <SID>DEBUG('Found window: '.l:winNum,9)
    exec l:winNum.' wincmd w'
    let l:winFound = 1
  else

    if g:miniBufExplSplitToEdge == 1
        if &splitbelow
            bo sp [MiniBufExplorer]
        else
            to sp [MiniBufExplorer]
        endif
    else
        sp [MiniBufExplorer]
    endif

    " Make sure we are in our window
    if bufname('%') != '[MiniBufExplorer]'
      call <SID>DEBUG('DisplayBuffers called in invalid window',1)
      return
    endif

    " Turn off the swapfile, set the buffer type so that it won't get written,
    " and so that it will get deleted when it gets hidden.
    setlocal noswapfile
    setlocal buftype=nofile
    setlocal bufhidden=delete
    " Turn on word wrap in our explorer
    setlocal wrap
    call <SID>DEBUG('Window created: '.winnr(),9)
  endif

  " Restore the user's split setting.
  let &splitbelow = l:saveSplitBelow

endfunction

" 
" DisplayBuffers.
" 
" Makes sure we are in our explorer, then erases the current buffer and turns 
" it into a mini buffer explorer window.
"
function! <SID>DisplayBuffers()
  call <SID>DEBUG('Entering DisplayBuffers()',10)
  
  " Make sure we are in our window
  if bufname('%') != '[MiniBufExplorer]'
    call <SID>DEBUG('DisplayBuffers called in invalid window',1)
    return
  endif

  " We need to be able to modify the buffer
  setlocal modifiable

  " Delete all lines in buffer.
  1,$d _
  
  call <SID>ShowBuffers()
  call <SID>ResizeWindow()
  
  normal! zz
  
  " Prevent the buffer from being modified.
  setlocal nomodifiable

endfunction

" 
" Resize Window
" 
" Makes sure we are in our explorer, then sets the height for our explorer 
" window so that we can fit all of our information without taking extra lines.
"
function! <SID>ResizeWindow()
  call <SID>DEBUG('Entering ResizeWindow()',10)

  " Make sure we are in our window
  if bufname('%') != '[MiniBufExplorer]'
    call <SID>DEBUG('DisplayBuffers called in invalid window',1)
    return
  endif

  let l:width  = winwidth('.')
  let l:length = strlen(getline('.'))
  let l:height = (l:length / l:width) 
  " handle truncation from div
  if (l:length % l:width) != 0
    let l:height = l:height + 1
  endif
  exec('resize '.l:height)

endfunction

" 
" ShowBuffers.
" 
" Makes sure we are in our explorer, then adds a list of all modifiable 
" buffers to the current buffer. Special marks are added for buffers that 
" are in one or more windows (*) and buffers that have been modified (+)
"
function! <SID>ShowBuffers()
  call <SID>DEBUG('Entering ShowBuffers()',10)

  " Make sure we are in our window
  if bufname('%') != '[MiniBufExplorer]'
    call <SID>DEBUG('ShowBuffers called in invalid window',1)
    return
  endif

  let l:save_rep = &report
  let l:save_sc = &showcmd
  let &report = 10000
  set noshowcmd 
  
  let l:NBuffers = bufnr('$')     " Get the number of the last buffer.
  let l:i = 0                     " Set the buffer index to zero.

  let l:fileNames = ''

  " Loop through every buffer less than the total number of buffers.
  while(l:i <= l:NBuffers)
    let l:i = l:i + 1
   
    " Make sure the buffer in question is listed.
    if(getbufvar(l:i, '&buflisted') == 1)
      " Get the name of the buffer.
      let l:BufName = bufname(l:i)
      " Check to see if the buffer is a blank or not. If the buffer does have
      " a name, process it.
      if(strlen(l:BufName))
        " Only show modifiable non-hidden buffers (The idea is that we don't 
        " want to show Explorers)
        if (getbufvar(l:i, '&modifiable') == 1 && 
           \getbufvar(l:i, '&hidden') == 0 &&
           \BufName != '[MiniBufExplorer]')
          
          " Get filename & Remove []'s & ()'s
          let l:shortBufName = fnamemodify(l:BufName, ":t")                  
          let l:shortBufName = substitute(l:shortBufName, '[][()]', '', 'g') 
          let l:fileNames = l:fileNames.'['.l:i.':'.l:shortBufName.']'

          " If the buffer is open in a window mark it
          if bufwinnr(l:i) != -1
            let l:fileNames = l:fileNames . '*'
          endif

          " If the buffer is modified then mark it
          if(getbufvar(l:i, '&modified') == 1)
            let l:fileNames = l:fileNames . '+'
          endif

          let l:fileNames = l:fileNames . ' '

        endif
      endif
    endif
  endwhile

  " Goto the end of the buffer put the buffer list 
  " and then delete the extra trailing blank line
  $
  put! =l:fileNames
  $ d _

  let &report  = l:save_rep
  let &showcmd = l:save_sc
  
endfunction

" 
" HasEligibleBuffer
" 
" Returns 1 if there are any buffers that can be displayed in a 
" mini buffer explorer. Otherwise returns 0
"
function! <SID>HasEligibleBuffer()
  call <SID>DEBUG('Entering HasEligibleBuffer()',10)

  let l:save_rep = &report
  let l:save_sc = &showcmd
  let &report = 10000
  set noshowcmd 
  
  let l:NBuffers = bufnr('$')     " Get the number of the last buffer.
  let l:i        = 0              " Set the buffer index to zero.
  let l:found    = 0              " No buffer found

  if (g:miniBufExplorerMoreThanOne == 1)
    call <SID>DEBUG('More Than One mode turned on',6)
    let l:needed = 2
  else
    let l:needed = 1
  endif

  " Loop through every buffer less than the total number of buffers.
  while(l:i <= l:NBuffers && l:found < l:needed)
    let l:i = l:i + 1
   
    " Make sure the buffer in question is listed.
    if (getbufvar(l:i, '&buflisted') == 1)
      " Get the name of the buffer.
      let l:BufName = bufname(l:i)
      " Check to see if the buffer is a blank or not. If the buffer does have
      " a name, process it.
      if (strlen(l:BufName))
        " Only show modifiable non-hidden buffers (The idea is that we don't 
        " want to show Explorers)
        if ((getbufvar(l:i, '&modifiable') == 1) && 
           \getbufvar(l:i, '&hidden') == 0 &&
           \(BufName != '[MiniBufExplorer]'))
          
            let l:found = l:found + 1
            call <SID>DEBUG('Found '.l:found.' eligible buffers so far.',6)

        endif
      endif
    endif
  endwhile

  let &report  = l:save_rep
  let &showcmd = l:save_sc

  return (l:found >= l:needed)
  
endfunction

"
" Auto Update
"
" IF auto update is turned on     AND
"    we are in a real buffer      AND
"    we are not in our own window AND
"    we have an eligible buffer   THEN
" Update our explorer and get back to the current window
"
function! <SID>AutoUpdate()
  call <SID>DEBUG('Entering AutoUpdate()',10)

  " Only allow updates when the AutoUpdate flag is set
  " this allows us to stop updates on startup.
  if g:miniBufExplorerAutoUpdate == 1
    " Only show BufExplorer if we have a real buffer
    if bufnr('%') != -1 && bufname('%') != ""
      " only update if we are not in our window
      if bufname('%') != '[MiniBufExplorer]'
        if <SID>HasEligibleBuffer()
          call <SID>StartExplorer()
          " if we are not already in the [MiniBufExplorer] window
          " then goto the previous window (back to working buffer)
          if bufname('#') != '[MiniBufExplorer]'
            wincmd p
          endif
        endif
      endif
    endif
  endif
endfunction

" 
" GetSelectedBuffer
" 
" If we are in our explorer window then return the buffer number
" for the buffer under the cursor.
"
function! <SID>GetSelectedBuffer()
  call <SID>DEBUG('Entering GetSelectedBuffer()',10)

  " Make sure we are in our window
  if bufname('%') != '[MiniBufExplorer]'
    call <SID>DEBUG('GetSelectedBuffer called in invalid window',1)
    return -1
  endif

  let @" = ""
  normal yi[
  if @" != ""
    return substitute(@",'\([0-9]*\):.*', '\1', '') + 0
  else
    return -1
  endif

endfunction

" 
" SelectBuffer.
" 
" If we are in our explorer, then we attempt to open the buffer under the
" cursor in the previous window.
"
function! <SID>SelectBuffer()
  call <SID>DEBUG('Entering SelectBuffer()',10)

  " Make sure we are in our window
  if bufname('%') != '[MiniBufExplorer]'
    call <SID>DEBUG('SelectBuffer called in invalid window',1)
    return 
  endif

  let l:save_sc = &showcmd
  set noshowcmd 
  
  let l:bufnr = <SID>GetSelectedBuffer()

  if(l:bufnr != -1)             " If the buffer exists.
    " Switch to the previous window
    wincmd p
    " If we are in the buffer explorer then try another window
    if bufname('%') == '[MiniBufExplorer]'
      wincmd w
    endif
    " And load the selected buffer
    exec('b! '.l:bufnr)
    " Update our window
    "call <SID>DisplayBuffers() !!! should autocmd
    " And go back to the previous window (again)
    "wincmd p !!! should autocmd
  endif

  let &showcmd = l:save_sc

endfunction

" 
" Delete selected buffer from list.
" 
" After making sure that we are in our explorer, This will delete the buffer 
" under the cursor. If the buffer under the cursor is being displayed in a
" window, this routine will attempt to get different buffers into the 
" windows that will be affected so that windows don't get removed.
"
function! <SID>DeleteBuffer()
  call <SID>DEBUG('Entering DeleteBuffer()',10)

  " Make sure we are in our window
  if bufname('%') != '[MiniBufExplorer]'
    call <SID>DEBUG('DeleteBuffer called in invalid window',1)
    return 
  endif

  let l:save_rep = &report
  let l:save_sc  = &showcmd
  let &report    = 10000
  set noshowcmd 
  
  let l:selBuf     = <SID>GetSelectedBuffer()
  let l:selBufName = bufname(l:selBuf)

  
  if l:selBuf != -1
    " Save previous window so that if we show a buffer after
    " deleting. The show will come up in the correct window.
    wincmd p
    let l:prevWin    = winnr()
    let l:prevWinBuf = winbufnr(winnr())

    call <SID>DEBUG('Previous window: '.l:prevWin.' buffer in window: '.l:prevWinBuf,5)
    call <SID>DEBUG('Selected buffer is <'.l:selBufName.'>['.l:selBuf.']',5)

    " If buffer is being displayed in a window then 
    " move window to a different buffer before 
    " deleting this one. Don't move to a hidden 
    " buffer if that is possible.
    let l:winNum = (bufwinnr(l:selBufName) + 0)
    " while we have windows that contain our buffer
    while l:winNum != -1 
        call <SID>DEBUG('Buffer '.l:selBuf.' is being displayed in window: '.l:winNum,5)

        " move to window that contains our selected buffer
        exec l:winNum.' wincmd w'

        call <SID>DEBUG('We are now in window: '.winnr().' which contains buffer: '.bufnr('%').' and should contain buffer: '.l:selBuf,5)

        " Change buffer (keeping track of before and after buffers)
        let l:origBuf = bufnr('%')
        bn
        let l:curBuf  = bufnr('%')

        " Skip any non-modifiable buffers, but don't cycle forever
        " This should stop us from stopping in any of the [Explorers]
        while getbufvar(bufnr('%'), '&modifiable') == 0 && l:origBuf != l:curBuf
            bn
            let l:curBuf = bufnr('%')
        endwhile

        call <SID>DEBUG('Window now contains buffer: '.bufnr('%').' which should not be: '.l:selBuf,5)

        if l:origBuf == l:curBuf
            " we wrapped so we are going to have to delete a buffer 
            " that is in an open window.
            let l:winNum = -1
        else
            " see if we have anymore windows with our selected buffer
            let l:winNum = (bufwinnr(l:selBufName) + 0)
        endif
    endwhile

    " Attempt to restore previous window
    call <SID>DEBUG('Restoring previous window to: '.l:prevWin,5)
    exec l:prevWin.' wincmd w'

    " Try to get back to the [BufExplorer] window 
    let l:winNum = bufwinnr(bufnr('BufExplorer'))
    if l:winNum != -1
        exec l:winNum.' wincmd w'
        call <SID>DEBUG('Got to [BufExplorer] window: '.winnr(),5)
    else
        call <SID>DEBUG('Unable to get to [BufExplorer] window',1)
    endif
  
    " Delete the buffer selected.
    exec('bd '.l:selBuf)

    " Allow us to update the display
    setlocal modifiable

    " Update the buffer list
    if bufname('%') == '[MiniBufExplorer]'
      call <SID>DisplayBuffers()
    else
      call <SID>DEBUG('Unable to update [BufExplorer] window',1)
    endif

  endif

  setlocal nomodifiable

  let &report  = l:save_rep
  let &showcmd = l:save_sc

endfunction

"
" DoubleClick - Double click with the mouse.
"
function! s:DoubleClick()
  call <SID>DEBUG('Entering DoubleClick()',10)
  call <SID>SelectBuffer()
endfunction

"
" DEBUG
"
" Display debug output when debugging is turned on
"
function! <SID>DEBUG(msg, level)
  if g:miniBufExplorerDebugLevel >= a:level
    echo confirm(a:msg, 'OK')
  endif
endfunction
