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
"  Last Change: Monday, February 4, 2002
"      Version: 6.0.7
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
"               key mapping to your _vimrc/.vimrc file.
"
"                 map <Leader>b :MiniBufExplorer<cr>
"
"               However, in most cases you won't need any key-bindings at all.
"
"               To control where the new split window goes relative to
"               the current window, use the setting:
"
"                 let g:miniBufExplSplitBelow=0  " Put new window above
"                                                " current.
"                 let g:miniBufExplSplitBelow=1  " Put new window below
"                                                " current.
"
"               The default for this is read from the &splitbellow vim option.
"
"               By default we are now (as of 6.0.2) forcing the -MiniBufExplorer-
"               window to open up at the edge of the screen. You can turn this 
"               off by setting the following variable in your .vimrc:
"
"                 let g:miniBufExplSplitToEdge = 0
"
"               By default we are now (as of 6.0.1) turning on the MoreThanOne
"               option. This stops the -MiniBufExplorer- from opening 
"               automatically until more than one eligible buffer is available.
"               You can turn this feature off by setting the following variable
"               in your .vimrc:
"                 
"                 let g:miniBufExplorerMoreThanOne=0
"
"               To enable the optional mapping of Control + Vim Direction Keys 
"               [hjkl] to window movement commands, you can put the following into 
"               your .vimrc:
"
"                 let g:miniBufExplMapWindowNavVim = 1
"
"               To enable the optional mapping of Control + Arrow Keys to window 
"               movement commands, you can put the following into your .vimrc:
"
"                 let g:miniBufExplMapWindowNavArrows = 1
"
"               To enable the optional mapping of <C-TAB> and <C-S-TAB> to a 
"               function that will bring up the next or previous buffer in the
"               current window, you can put the following into your .vimrc:
"
"                 let g:miniBufExplMapCTabSwitchBufs = 1
"
"               To enable the optional mapping of <C-TAB> and <C-S-TAB> to mappings
"               that will move to the next and previous (respectively) window, you
"               can put the following into your .vimrc:
"
"                 let g:miniBufExplMapCTabSwitchWindows = 1
"
"               NOTE: If you set the ...TabSwitchBufs AND ...TabSwitchWindows, 
"                     ...TabSwitchBufs will be enabled and ...TabSwitchWIndows 
"                     will not.
"
"
"      History: 6.0.7 o Handling BufDelete autocmd so that the UI updates 
"                       properly when using :bd (rather than going through 
"                       the MBE UI.)
"                     o The AutoUpdate code will now close the MBE window when 
"                       there is a single eligible buffer available.
"                       This has the usefull side effect of stopping the MBE
"                       window from the VIM session open when you close the 
"                       last buffer.
"                     o Added functions, commands and maps to close & update
"                       the MBE window (<leader>mbc and <leader>mbu.)
"                     o Made MBE open/close state be sticky if set through
"                       StartExplorer(1) or StopExplorer(1), which are 
"                       called from the standard mappings. So if you close
"                       the mbe window with \mbc it won't be automatically 
"                       opened again unless you do a \mbe (or restart VIM).
"                     o Removed spaces between "tabs" (even more mini :)
"                     o Simplified MBE tab processing 
"               6.0.6 Fixed register overwrite bug found by Sébastien Pierre
"               6.0.5 Fixed an issue with window sizing when we run out of 
"                     buffers.  Also fixed some weird commenting bugs.
"                     Added more optional fancy window/buffer navigation:
"                     o You can turn on the capability to use control and the 
"                       arrow keys to move between windows.
"                     o You can turn on the ability to use <C-TAB> and 
"                       <C-S-TAB> to open the next and previous (respectively) 
"                       buffer in the current window.
"                     o You can turn on the ability to use <C-TAB> and 
"                       <C-S-TAB> to switch windows (forward and backwards 
"                       respectively.)
"               6.0.4 Added optional fancy window navigation: 
"                     o Holding down control and pressing a vim direction 
"                       [hjkl] will switch windows in the indicated direction.
"               6.0.3 Changed buffer name to -MiniBufExplorer- to resolve
"                     Issue in filename pattern matching on Windows.
"               6.0.2 2 Changes requested by Suresh Govindachar
"                     Added SplitToEdge option and set it on by default
"                     Added tab and shift-tab mappings in [MBE] window
"               6.0.1 Added MoreThanOne option and set it on by default
"                     MiniBufExplorer will not automatically open until
"                     more than one eligible buffers are opened. This
"                     reduces cluter when you are only working on a
"                     single file.
"               6.0.0 Initial Release on November 20, 2001
"
"         Todo: o Provide better support for user defined syntax highlighting
"               o Add the ability to specify a regexp for eligible buffers
"                 allowing the ability to filter out certain buffers that 
"                 you don't want to control from MBE
"
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
" If we don't already have a keyboard
" mapping for mbe then create one.
" 
if !hasmapto('<Plug>MiniBufExplorer')
  map <unique> <Leader>mbe <Plug>MiniBufExplorer
endif
if !hasmapto('<Plug>CMiniBufExplorer')
  map <unique> <Leader>mbc <Plug>CMiniBufExplorer
endif
if !hasmapto('<Plug>UMiniBufExplorer')
  map <unique> <Leader>mbu <Plug>UMiniBufExplorer
endif

" 
" Setup <Script> internal map.
" 
noremap <unique> <script> <Plug>MiniBufExplorer  :call <SID>StartExplorer(1, -1)<CR>:<BS>
noremap <unique> <script> <Plug>CMiniBufExplorer :call <SID>StopExplorer(1)<CR>:<BS>
noremap <unique> <script> <Plug>UMiniBufExplorer :call <SID>AutoUpdate(-1)<CR>:<BS>

" 
" Create command mbe command.
" 
if !exists(':MiniBufExplorer')
  command! MiniBufExplorer :call <SID>StartExplorer(1, -1)
endif
if !exists(':CMiniBufExplorer')
  command! CMiniBufExplorer :call <SID>StopExplorer(1)
endif
if !exists(':UMiniBufExplorer')
  command! UMiniBufExplorer :call <SID>AutoUpdate(-1)
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
" When opening a new -MiniBufExplorer- window, split the new windows below or 
" above the current window?  1 = below, 0 = above.
"
if !exists('g:miniBufExplSplitBelow')
  let g:miniBufExplSplitBelow = &splitbelow
endif

"
" When opening a new -MiniBufExplorer- window, split the new windows to the
" full edge? 1 = yes, 0 = no.
"
if !exists('g:miniBufExplSplitToEdge')
  let g:miniBufExplSplitToEdge = 1
endif

"
" Global flag to turn extended window navigation commands on or off
" enabled = 1, dissabled = 0
"
if !exists('g:miniBufExplMapWindowNav')
  " This is for backwards compatibility and may be removed in a
  " later release, please use the ...NavVim and/or ...NavArrows 
  " settings.
  let g:miniBufExplMapWindowNav = 0
endif
if !exists('g:miniBufExplMapWindowNavVim')
  let g:miniBufExplMapWindowNavVim = 0
endif
if !exists('g:miniBufExplMapWindowNavArrows')
  let g:miniBufExplMapWindowNavArrows = 0
endif
if !exists('g:miniBufExplMapCTabSwitchBufs')
  let g:miniBufExplMapCTabSwitchBufs = 0
endif
" Notice: that if CTabSwitchBufs is turned on then
" we turn off CTabSwitchWindows.
if g:miniBufExplMapCTabSwitchBufs == 1 ||
   \!exists('g:miniBufExplMapCTabSwitchWindows')
  let g:miniBufExplMapCTabSwitchWindows = 0
endif

"
" If we have enabled control + vim direction key remapping
" then perform the remapping
"
" Notice: I left g:miniBufExplMapWindowNav in for backward
" compatibility. Eventually this mapping will be removed so
" please use the newer g:miniBufExplMapWindowNavVim setting.
if g:miniBufExplMapWindowNavVim || 
   \g:miniBufExplMapWindowNav
  noremap <C-J> <C-W>j
  noremap <C-K> <C-W>k
  noremap <C-H> <C-W>h
  noremap <C-L> <C-W>l
endif

"
" If we have enabled control + arrow key remapping
" then perform the remapping
"
if g:miniBufExplMapWindowNavArrows
  noremap <C-Down>  <C-W>j
  noremap <C-Up>    <C-W>k
  noremap <C-Left>  <C-W>h
  noremap <C-Right> <C-W>l
endif

" If we have enabled <C-TAB> and <C-S-TAB> to switch buffers
" in the current window then perform the remapping
"
if g:miniBufExplMapCTabSwitchBufs
  noremap <C-TAB>   :call <SID>CycleBuffer(1)<CR>:<BS>
  noremap <C-S-TAB> :call <SID>CycleBuffer(0)<CR>:<BS>
endif

"
" If we have enabled <C-TAB> and <C-S-TAB> to switch windows
" then perform the remapping
"
if g:miniBufExplMapCTabSwitchWindows
  noremap <C-TAB>   <C-W>w
  noremap <C-S-TAB> <C-W>W
endif



"
" Setup an autocommand group and some autocommands that keep our explorer
" updated automatically.
"
augroup MiniBufExplorer
autocmd MiniBufExplorer BufReadPost * call <SID>DEBUG('BufReadPost AutoCmd', 10) |call <SID>AutoUpdate(-1)
autocmd MiniBufExplorer BufNewFile  * call <SID>DEBUG('BufNewFile AutoCmd', 10) |call <SID>AutoUpdate(-1)
autocmd MiniBufExplorer BufNew      * call <SID>DEBUG('BufNew AutoCmd', 10) |call <SID>AutoUpdate(-1)
autocmd MiniBufExplorer BufDelete   * call <SID>DEBUG('BufDelete AutoCmd', 10) |call <SID>AutoUpdate(expand('<abuf>'))
autocmd MiniBufExplorer VimEnter    * call <SID>DEBUG('VimEnter AutoCmd', 10) |let g:miniBufExplorerAutoUpdate = 1 |call <SID>AutoUpdate(-1)

" 
" StartExplorer
" 
" Sets up our explorer and causes it to be displayed
"
function! <SID>StartExplorer(sticky, delBufNum)
  call <SID>DEBUG('Entering StartExplorer()',10)

  if a:sticky == 1
    let g:miniBufExplorerAutoUpdate = 1
  endif

  call <SID>FindCreateExplorer()

  " Make sure we are in our window
  if bufname('%') != '-MiniBufExplorer-'
    call <SID>DEBUG('StartExplorer called in invalid window',1)
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

  " If you press return in the -MiniBufExplorer- then try
  " to open the selected buffer in the previous window.
  nnoremap <buffer> <CR> :call <SID>MBESelectBuffer()<CR>:<BS>
  " If you DoubleClick in the -MiniBufExplorer- then try
  " to open the selected buffer in the previous window.
  nnoremap <buffer> <2-LEFTMOUSE> :call <SID>MBEDoubleClick()<CR>:<BS>
  " If you press d in the -MiniBufExplorer- then try to
  " delete the selected buffer.
  nnoremap <buffer> d :call <SID>MBEDeleteBuffer()<CR>:<BS>
  " The following allow us to use regular movement keys to 
  " scroll in a wrapped single line buffer
  nnoremap <buffer> j gj
  nnoremap <buffer> k gk
  nnoremap <buffer> <down> gj
  nnoremap <buffer> <up> gk
  " The following allows for quicker moving between buffer
  " names in the [MBE] window it also saves the last-pattern
  " and restores it.
  nnoremap <buffer> <TAB>   :call search('\[[0-9]*:[^\]]*\]')<CR>:<BS>
  nnoremap <buffer> <S-TAB> :call search('\[[0-9]*:[^\]]*\]','b')<CR>:<BS>
 
  call <SID>DisplayBuffers(a:delBufNum)

  let &report  = l:save_rep
  let &showcmd = l:save_sc

endfunction

"
" StopExplorer
"
" Looks for our explorer and closes the window if it is open
"
function! <SID>StopExplorer(sticky)
  call <SID>DEBUG('Entering StopExplorer()',10)

  if a:sticky == 1
    let g:miniBufExplorerAutoUpdate = 0
  endif

  let l:winNum = <SID>FindExplorer()

  if l:winNum != -1 
    exec l:winNum.' wincmd w'
    silent! close
    wincmd p
  endif
endfunction

"
" FindExplorer
"
" Return the window number of the explorer buffer, if none is found then 
" returns -1.
"
function! <SID>FindExplorer()
  call <SID>DEBUG('Entering FindExplorer()',10)

  " Try to find an existing window that contains 
  " -MiniBufExplorer-. 
  let l:bufNum = bufnr('MiniBufExplorer')
  if l:bufNum != -1
    call <SID>DEBUG('-MiniBufExplorer- found in buffer: '.l:bufNum,9)
    let l:winNum = bufwinnr(l:bufNum)
  else
    let l:winNum = -1
  endif

  return l:winNum

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

  " Try to find an existing explorer window
  let l:winNum = <SID>FindExplorer()

  " If found goto the existing window, otherwise 
  " split open a new window.
  if l:winNum != -1
    call <SID>DEBUG('Found window: '.l:winNum,9)
    exec l:winNum.' wincmd w'
    let l:winFound = 1
  else

    if g:miniBufExplSplitToEdge == 1
        if &splitbelow
            bo sp -MiniBufExplorer-
        else
            to sp -MiniBufExplorer-
        endif
    else
        sp -MiniBufExplorer-
    endif

    " Try to find an existing explorer window
    let l:winNum = <SID>FindExplorer()
    if l:winNum != -1
      call <SID>DEBUG('Created and then found window: '.l:winNum,9)
      exec l:winNum.' wincmd w'
    else
      call <SID>DEBUG('FindCreateExplorer failed to create -MiniBufExplorer- window.',1)
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
function! <SID>DisplayBuffers(delBufNum)
  call <SID>DEBUG('Entering DisplayBuffers()',10)
  
  " Make sure we are in our window
  if bufname('%') != '-MiniBufExplorer-'
    call <SID>DEBUG('DisplayBuffers called in invalid window',1)
    return
  endif

  " We need to be able to modify the buffer
  setlocal modifiable

  " Delete all lines in buffer.
  1,$d _
  
  call <SID>ShowBuffers(a:delBufNum)
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
  if bufname('%') != '-MiniBufExplorer-'
    call <SID>DEBUG('ResizeWindow called in invalid window',1)
    return
  endif

  let l:width  = winwidth('.')
  let l:length = strlen(getline('.'))
  if (l:width == 0 || l:length == 0)
    let l:height = winheight('.')
    exec('resize '.l:height)
  else
    let l:height = (l:length / l:width) 
    " handle truncation from div
    if (l:length % l:width) != 0
      let l:height = l:height + 1
    endif
    exec('resize '.l:height)
  endif

endfunction

" 
" ShowBuffers.
" 
" Makes sure we are in our explorer, then adds a list of all modifiable 
" buffers to the current buffer. Special marks are added for buffers that 
" are in one or more windows (*) and buffers that have been modified (+)
"
function! <SID>ShowBuffers(delBufNum)
  call <SID>DEBUG('Entering ShowBuffers()',10)

  " Make sure we are in our window
  if bufname('%') != '-MiniBufExplorer-'
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
   
    " If we have a delBufNum and it is the current
    " buffer then ignore the current buffer. 
    " Otherwise, continue.
    if (a:delBufNum == -1 || l:i != a:delBufNum)
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
             \BufName != '-MiniBufExplorer-')
            
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

          endif
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
" HasEligibleBuffers
" 
" Returns 1 if there are any buffers that can be displayed in a 
" mini buffer explorer. Otherwise returns 0. If delBufNum is
" any non -1 value then don't include that buffer in the list
" of eligible buffers.
"
function! <SID>HasEligibleBuffers(delBufNum)
  call <SID>DEBUG('Entering HasEligibleBuffers()',10)

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
   
    " If we have a delBufNum and it is the current
    " buffer then ignore the current buffer. 
    " Otherwise, continue.
    if (a:delBufNum == -1 || l:i != a:delBufNum)
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
             \(BufName != '-MiniBufExplorer-'))
            
              let l:found = l:found + 1
  
          endif
        endif
      endif
    endif
  endwhile

  let &report  = l:save_rep
  let &showcmd = l:save_sc

  call <SID>DEBUG('HasEligibleBuffers found '.l:found.' eligible buffers of '.l:needed.' needed',6)

  return (l:found >= l:needed)
  
endfunction

"
" Auto Update
"
" IF auto update is turned on     AND
"    we are in a real buffer      AND
"    we have an eligible buffer   THEN
" Update our explorer and get back to the current window
"
" If we get a buffer number for a buffer that 
" is being deleted, we need to make sure and 
" remove the buffer from the list of eligible 
" buffers in case we are down to one eligible
" buffer, in which case we will want to close
" the MBE window.
"
function! <SID>AutoUpdate(delBufNum)
  call <SID>DEBUG('Entering AutoUpdate()', 10)

  if (a:delBufNum != -1)
    call <SID>DEBUG('AutoUpdate will make sure that buffer '.a:delBufNum.' is not included in the buffer list.', 5)
  endif

  " Only allow updates when the AutoUpdate flag is set
  " this allows us to stop updates on startup.
  if g:miniBufExplorerAutoUpdate == 1
    " Only show MiniBufExplorer if we have a real buffer
    if bufnr('%') != -1 && bufname('%') != ""
      if <SID>HasEligibleBuffers(a:delBufNum) == 1
        call <SID>DEBUG('About to call StartExplorer', 10)
        call <SID>StartExplorer(0, a:delBufNum)
        " if we are not already in the -MiniBufExplorer- window
        " then goto the previous window (back to working buffer)
        if bufname('#') != '-MiniBufExplorer-'
          wincmd p
        endif
      else
        call <SID>DEBUG('Failed in eligible check', 10)
        call <SID>StopExplorer(0)
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
  if bufname('%') != '-MiniBufExplorer-'
    call <SID>DEBUG('GetSelectedBuffer called in invalid window',1)
    return -1
  endif

  let l:save_reg = @"
  let @" = ""
  normal yi[
  if @" != ""
    let l:retv = substitute(@",'\([0-9]*\):.*', '\1', '') + 0
    let @" = l:save_reg
    return l:retv
  else
    let @" = l:save_reg
    return -1
  endif

endfunction

" 
" MBESelectBuffer.
" 
" If we are in our explorer, then we attempt to open the buffer under the
" cursor in the previous window.
"
function! <SID>MBESelectBuffer()
  call <SID>DEBUG('Entering MBESelectBuffer()',10)

  " Make sure we are in our window
  if bufname('%') != '-MiniBufExplorer-'
    call <SID>DEBUG('MBESelectBuffer called in invalid window',1)
    return 
  endif

  let l:save_sc = &showcmd
  set noshowcmd 
  
  let l:bufnr = <SID>GetSelectedBuffer()

  if(l:bufnr != -1)             " If the buffer exists.
    " Switch to the previous window
    wincmd p
    " If we are in the buffer explorer then try another window
    let l:saveAutoUpdate = 0
    if bufname('%') == '-MiniBufExplorer-'
      wincmd w
      " The following nasty hack handles the case where -MiniBufExplorer-
      " is the only window left. In this case we need to replace our
      " window without triggering autoupdate then we need to call 
      " autoupdate to that we get a new -MiniBufExplorer- window.
      if bufname('%') == '-MiniBufExplorer-'
        resize
        let l:saveAutoUpdate = g:miniBufExplorerAutoUpdate
        let g:miniBufExplorerAutoUpdate = 0
        exec('b! '.l:bufnr)
        let g:miniBufExplorerAutoUpdate = l:saveAutoUpdate
      endif
    endif

    if (l:saveAutoUpdate == 1)
      call <SID>AutoUpdate(-1)
    else
      exec('b! '.l:bufnr)
    endif


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
function! <SID>MBEDeleteBuffer()
  call <SID>DEBUG('Entering MBEDeleteBuffer()',10)

  " Make sure we are in our window
  if bufname('%') != '-MiniBufExplorer-'
    call <SID>DEBUG('MBEDeleteBuffer called in invalid window',1)
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

        let l:origBuf = bufnr('%')
        call <SID>CycleBuffer(1)
        let l:curBuf  = bufnr('%')

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

    " Try to get back to the -MiniBufExplorer- window 
    let l:winNum = bufwinnr(bufnr('-MiniBufExplorer-'))
    if l:winNum != -1
        exec l:winNum.' wincmd w'
        call <SID>DEBUG('Got to -MiniBufExplorer- window: '.winnr(),5)
    else
        call <SID>DEBUG('Unable to get to -MiniBufExplorer- window',1)
    endif
  
    " Delete the buffer selected.
    call <SID>DEBUG('About to delete buffer: '.l:selBuf,5)
    exec('silent! bd '.l:selBuf)

  endif


  let &report  = l:save_rep
  let &showcmd = l:save_sc

endfunction

"
" Cycle Through Buffers 
"
" Move to next or previous buffer in the current window. If there 
" are no more modifiable buffers then stay on the current buffer.
"
function! <SID>CycleBuffer(forward)
  " Change buffer (keeping track of before and after buffers)
  let l:origBuf = bufnr('%')
  if (a:forward == 1)
    bn!
  else
    bp!
  endif
  let l:curBuf  = bufnr('%')
  
  " Skip any non-modifiable buffers, but don't cycle forever
  " This should stop us from stopping in any of the [Explorers]
  while getbufvar(l:curBuf, '&modifiable') == 0 && l:origBuf != l:curBuf
    if (a:forward == 1)
        bn!
    else
        bp!
    endif
    let l:curBuf = bufnr('%')
  endwhile

endfunction

"
" MBEDoubleClick - Double click with the mouse.
"
function! s:MBEDoubleClick()
  call <SID>DEBUG('Entering MBEDoubleClick()',10)
  call <SID>MBESelectBuffer()
endfunction

"
" DEBUG
"
" Display debug output when debugging is turned on
"
function! <SID>DEBUG(msg, level)
  if g:miniBufExplorerDebugLevel >= a:level
    call confirm(a:msg, 'OK')
  endif
endfunction
